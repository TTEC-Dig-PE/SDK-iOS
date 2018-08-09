//
//  ECSStompChatClient.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//
#import "ECSStompChatClient.h"

#import "ECSStompClient.h"
#import "ECSInjector.h"
#import "ECSLog.h"
#import "ECSURLSessionManager.h"
#import "ECSUserManager.h"
#import "ECSJSONSerializer.h"
#import "ECSJSONSerializing.h"
#import "ECSChannelConfiguration.h"

#import "ECSChatAddChannelMessage.h"
#import "ECSChatAddParticipantMessage.h"
#import "ECSChatRemoveParticipantMessage.h"
#import "ECSChatAssociateInfoMessage.h"
#import "ECSChatCoBrowseMessage.h"
#import "ECSCafeXMessage.h"
#import "ECSChatVoiceAuthenticationMessage.h"
#import "ECSChatNotificationMessage.h"
#import "ECSChatTextMessage.h"
#import "ECSChannelStateMessage.h"
#import "ECSSendQuestionMessage.h"
#import "ECSChatFormMessage.h"
#import "ECSChatURLMessage.h"
#import "ECSChannelTimeoutWarningMessage.h"

#import "ECSChatActionType.h"
#import "ECSVideoChatActionType.h"

#import "ECSChannelCreateResponse.h"
#import "ECSConversationCreateResponse.h"

// Custom tags for ECS Chat
static NSString * const kECSHeaderBodyType =        @"x-body-type";
static NSString * const kECSHeaderBodyVersion =     @"x-body-version";

static NSString * const kECSMessageBodyVersion =    @"1";
static NSString * const kECSChannelStateMessage =   @"ChannelState"; // state messages - agent connected, voice call sent, disconnection

static NSString * const kECSChatMessage =                   @"ChatMessage";           // Regular text chat message from agent
static NSString * const kECSChatNotificationMessage =       @"NotificationMessage";   // Incoming images from agent
static NSString * const kECSChatStateMessage =              @"ChatState";             // Chat state (0, 1=paused, 2=composing)
static NSString * const kECSCommandMessage =                @"CommandMessage";
static NSString * const kECSChatRenderURLMessage =          @"RenderURLCommand";      // A hyperlink chat message from agent
static NSString * const kECSChatAddParticipantMessage =     @"AddParticipant";        // An agent has joined the chat
static NSString * const kECSChatRemoveParticipantMessage =  @"RemoveParticipant";     // An agent has left the chat
static NSString * const kECSChatAddChannelMessage =         @"AddChannelCommand";
static NSString * const kECSChatAssociateInfoMessage =      @"AssociateInfoCommand";
static NSString * const kECSChatCoBrowseMessage =           @"CoBrowseMessage";
static NSString * const kECSCafeXMessage =                  @"CafeXCommand";
static NSString * const kECSVoiceAuthenticationMessage =    @"VoiceAuthentication";
static NSString * const kECSChatRenderFormMessage =         @"RenderFormCommand";     // A Forms chat message from agent
static NSString * const kECSSendQuestionMessage =           @"SendQuestionCommand";
static NSString * const kECSChannelTimeoutWarning =         @"ChannelTimeoutWarning"; // Idle timeout warning (approx. 1 minute remaining)

@interface ECSStompChatClient() <ECSStompDelegate>

@property (strong, nonatomic) ECSActionType     *actionType;
@property (strong, nonatomic) ECSStompClient    *stompClient;
@property (strong, nonatomic) NSString          *sendMessageDestination;
@property (strong, nonatomic) NSString          *sendNotificationDestination;
@property (strong, nonatomic) NSString          *sendCoBrowseDestination;
@property (assign, nonatomic) NSInteger         agentInteractionCount;
@property (weak, nonatomic)   NSURLSessionTask  *currentNetworkTask;

@end

@implementation ECSStompChatClient

@synthesize lastTimeStamp;
@synthesize lastChatMessageFromAgent;

// Internal variables.
BOOL        _initialConnectionMade;

NSTimer     *_stompRetryTimer;
BOOL        _stompConnectionLost;
int         _stompRetryInterval;
int         _stompRetryAttempts;
int         _stompRetriesBlocked;

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
        
        _chatState                      = ECSChatStateUnknown;
        _channelState                   = ECSChannelStateUnknown;
        _stompConnectionLost            = NO;
        _initialConnectionMade          = NO;
        self.agentInteractionCount      = 0;
        self.logger                     = [[EXPERTconnect shared] logger];
        self.fromUsername               = userManager.userDisplayName.length ? userManager.userDisplayName : @"Mobile User";
        
    }
    
    return self;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ECSReachabilityChangedNotification object:nil];
    [self stompRetryTimerStop];
    [self disconnect];
    
}

#pragma mark - Starting a chat

// Easy setup.
- (void) startChatWithSkill:(NSString *)skill
                    subject:(NSString *)theSubject {
    
    [self startChatWithSkill:skill
                     subject:theSubject
                    priority:kECSChatPriorityUseServerDefault
                  dataFields:nil];
    
}

// For advanced use (priority and dataFields)
- (void) startChatWithSkill:(NSString *)skill
                    subject:(NSString *)theSubject
                   priority:(int)priority
                 dataFields:(NSDictionary *)fields {
    
    ECSChatActionType *action = [ECSChatActionType new];
    
    action.agentSkill =         skill;
    action.subject =            theSubject;
    action.channelOptions =     fields;
    action.priority =           priority;
    
    action.actionId =           @"";                        // not used?
    action.displayName =        @"low_level_chat";          // not used?
    action.shouldTakeSurvey =   NO;                         // not used?
    action.journeybegin =       [NSNumber numberWithInt:1]; // not used?
    
    [self startChannelWithAction:action];
    
}

// The core function (most customizable)
- (void) startChannelWithAction:(ECSChatActionType *) action {
    
    [self setupChatClientWithActionType:action];
    
}

#pragma mark - Start a Voice Callback

- (void) startVoiceCallbackWithSkill:(NSString *)skill
                             subject:(NSString *)subject
                         phoneNumber:(NSString *)phone
                            priority:(int)priority
                          dataFields:(NSDictionary *)fields {
    
    ECSChatActionType *action = [ECSChatActionType new];
    
    action.agentSkill =         skill;
    action.subject =            subject;
    action.channelOptions =     fields;
    action.priority =           priority;
    action.sourceAddress =      phone;
    action.sourceType =         @"Callback";
    action.mediaType =          @"Voice";
    
    action.actionId =           @"";                        // not used?
    action.displayName =        @"low_level_voice_callback";// not used?
    action.shouldTakeSurvey =   NO;                         // not used?
    action.journeybegin =       [NSNumber numberWithInt:1]; // not used?
    
    [self startChannelWithAction:action];
    
}

#pragma mark - Externally accessible functions

- (bool)isConnected {
    return self.stompClient.connected;
}

- (bool)isConnecting {
    return self.stompClient.isConnecting;
}

- (void)reconnect {
    
    // Grab the latest auth token from the EXPERTconnect object.
    ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    self.stompClient.authToken = sessionManager.authToken;
    
    [self.stompClient reconnect];
    
}

- (void)disconnect {
    
    [self.currentNetworkTask cancel];
    
    if (self.channel &&
        ![self.channel.state isEqualToString:@"disconnected"] &&
        ![self.channel.state isEqualToString:@"disconnecting"]) {
        
        NSString *closeURL = self.channel.closeLink;
        
        if (closeURL) {
            
            self.channel.state = @"disconnected";
            
            ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
            
//            __weak typeof(self) weakSelf = self;
            
            [urlSession closeChannelAtURL:closeURL
                               withReason:@"Disconnected"
                    agentInteractionCount:self.agentInteractionCount
                                 actionId:self.actionType.actionId
                               completion:^(id result, NSError* error)
             {
                 // Do nothing.
//                 if( weakSelf) weakSelf.channel.state = @"disconnected";
             }];
        }
    }
    
    if (self.stompClient && self.stompClient.connected) {
        
        self.stompClient.delegate = nil;
        
        [self unsubscribe];
        
        [self.stompClient disconnect];
        
    }
}

#pragma mark - Internal Convienence Functions

- (void) networkConnectionChanged:(NSNotification *) notification {
    
    bool reachable = [EXPERTconnect shared].urlSession.networkReachable;
   
    ECSLogDebug(self.logger, @"Network update. Chat active? %d. Network good? %d", [self isChatActive], reachable);
    
    if( [self isChatActive] ) {
        
        if ( reachable ) {

            [self stompRetryTimerStartWithDelay:0];
            
        } else if ( !reachable ) {
            
            // Close the WebSocket.
            [self.stompClient closeSocket];
            
            if( !_stompRetryTimer ) [self stompRetryTimerStartWithDelay:10];
            
        }
        
        if ( [self.delegate respondsToSelector:@selector(chatReachabilityEvent:)] ) {
            [self.delegate chatReachabilityEvent:reachable];
        }
    }
}

- (bool) isChatActive {
    
    return _channelState == ECSChannelStateAnswered || _channelState == ECSChannelStateQueued || _channelState == ECSChannelStatePending || _channelState == ECSChannelStateConnected;
    
}

// Unit Test: EXPERTconnectTests::testProperties
-(NSString *)getTimeStampMessage {
    
    // get current date/time
    NSDate *today = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *currentTime = [dateFormatter stringFromDate:today];
    
    return currentTime;
}

- (void)resetClient {
    self.currentChannelId = nil;
    self.currentConversation = nil;
    self.lastTimeStamp = nil;
    self.lastChatMessageFromAgent = NO;
}

// Internal only.
- (void)setupChatClientWithActionType:(ECSActionType*)actionType {
    
    __weak typeof(self) weakSelf = self;
    
    self.actionType = actionType;
    
    [self resetClient]; // mas - Aug-3-2018 - Clear out previous chat data (channels, conversations, etc).
    
    ECSLogVerbose(self.logger, @"Initiating a new chat client...");
    
    ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    if ([self.actionType isKindOfClass:[ECSChatActionType class]]) {
        
        self.currentNetworkTask = [urlSession startConversationForAction:actionType
                                                         andAlwaysCreate:YES
                                                          withCompletion:^(ECSConversationCreateResponse *conversation, NSError *error) {
                                                              
                if ((error || !conversation || ![conversation isKindOfClass:[ECSConversationCreateResponse class]]) &&
                  (error.code != NSURLErrorCancelled)) {
                    
                  if (!error) {
                      
                      error = [NSError errorWithDomain:ECSErrorDomain
                                                  code:ECS_ERROR_API_ERROR
                                              userInfo:@{NSLocalizedDescriptionKey: ECSLocalizedString(ECSLocalizeErrorText, nil)}];
                  }
                    
                    [self handleStompError:error];
                  
                    return;
                    
                } else {
                    // Happy path.
                    
                    weakSelf.currentConversation = conversation;
                    
                    [weakSelf connectToHost:urlSession.hostName];
                    
                }
                                                              
           }];
        
    } else {
        
        // Setup without a Conversation
        NSLog(@"Setting up StompChatClient with non-chat Action Type");
        [self connectToHost:urlSession.hostName];
        
    }
}

// Internal only.
- (void)handleStompError:(NSError *) error {
    
    if ([self.delegate respondsToSelector:@selector(chatClient:didFailWithError:)]) {
        
        [self.delegate chatClient:self didFailWithError:error];
        
    }
    
    if ([self.delegate respondsToSelector:@selector(chatDidFailWithError:)]) {
        
        [self.delegate chatDidFailWithError:error];
        
    }
}

// Internal only.
- (void)setupChatChannel {
    
    ECSChannelConfiguration *configuration = [ECSChannelConfiguration new];
    ECSChatActionType       *chatAction =    (ECSChatActionType*)self.actionType;
    ECSUserManager          *userManager =   [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
    ECSURLSessionManager    *urlSession =    [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    if (chatAction) {
        
        if ((chatAction.agentId && chatAction.agentId.length > 0) &&
            (chatAction.agentSkill.length <= 0)) {
            
            configuration.to = chatAction.agentId;
            
        } else {
            
            configuration.to = chatAction.agentSkill;
        }
        
    } else {
        
        ECSLogError(self.logger,@"setupChatChannel: Error converting actionType to chatAction.");
    }

    // check for video action type
    NSMutableDictionary *featuresDic = [[NSMutableDictionary alloc] init];
    
//    if ([chatAction isKindOfClass:[ECSVideoChatActionType class]]) {
//
//        ECSVideoChatActionType *videoChatAction = (ECSVideoChatActionType *)chatAction;
//
//        featuresDic[@"cafexmode"] = videoChatAction.cafexmode;
//        featuresDic[@"cafextarget"] = videoChatAction.cafextarget;
//        //configuration.features = @{ @"cafexmode": videoChatAction.cafexmode, @"cafextarget": videoChatAction.cafextarget };
//    }
    
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *locale = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    NSString *languageLocale = [NSString stringWithFormat:@"%@_%@", language, locale];
    
    // Overwrite the device locale if the host app desires to do so.
    if(urlSession.localLocale && urlSession.localLocale.length>3) {
        
        languageLocale = urlSession.localLocale;
    }
    
    featuresDic[@"x-ia-locale"] = languageLocale;
    
    configuration.features = featuresDic; 
    
    if (self.actionType.channelOptions) {
        
        // Goes into "options" subcategory
        configuration.options = [NSDictionary dictionaryWithDictionary:self.actionType.channelOptions];
    }
    
    configuration.from          = ( userManager.userToken ? userManager.userToken : @"Guest" );
    configuration.subject       = chatAction.subject;
    configuration.sourceType    = chatAction.sourceType;
    
    configuration.mediaType     = chatAction.mediaType;
    configuration.sourceAddress = chatAction.sourceAddress;
    
    configuration.deviceId      = userManager.deviceID;
    configuration.location      = chatAction.location;
    
    // Only send if value is 1-10, otherwise send a nil/null.

    configuration.priority = (chatAction.priority > 0 && chatAction.priority < 11 ? [NSNumber numberWithInt:chatAction.priority] : nil);
    
    NSString *url = nil;
    
    __weak typeof(self) weakSelf = self;
    
    url = self.currentConversation.channelLink;

    if (url) {
        
        // Setup the channel
        self.currentNetworkTask = [urlSession setupChannel:configuration
                                            inConversation:url
                                                completion:^(ECSChannelCreateResponse *response, NSError *error)
        {
                                                    
            if ( !error && response ) {
                
#ifdef DEBUG
                 //TESTING ONLY!!! (Pretends like an "answered" stomp message arrives right as the channel response is returned (before a channelID is fetched)
//                ECSStompFrame *msg = [[ECSStompFrame alloc] init];
//                msg.body = @"{\"conversationId\":\"conversation_abc123\",\"channelId\":\"channel_abc123\",\"state\":\"answered\",\"estimatedWait\":0,\"version\":1}";
//                [self handleChannelStateMessage:msg forClient:_stompClient];
#endif
                
                if( response.estimatedWait ) {
                    [self sendUpdatedEstimatedWait:response.estimatedWait.intValue];
                }
                
                weakSelf.currentChannelId = [response.channelId copy];
                ECSLogDebug(self.logger, "Setting currentChannelId to %@", weakSelf.currentChannelId);
                
                weakSelf.channel = response;
                
                // Copy the channelID into the URLSession
                ECSURLSessionManager *urlSession2 = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
                
                urlSession2.lastChannelId = weakSelf.currentChannelId;
                
                [weakSelf setMessagingChannelConfiguration:response];
                
                if( [weakSelf.delegate respondsToSelector:@selector(chatChannelCreated:)] ) {
                    [weakSelf.delegate chatChannelCreated:response];
                }
                
            } else if (!(error.code == NSURLErrorCancelled)) {
                
                if (!error) {
                    
                    error = [NSError errorWithDomain:ECSErrorDomain
                                                code:ECS_ERROR_API_ERROR
                                            userInfo:@{NSLocalizedDescriptionKey: ECSLocalizedString(ECSLocalizeErrorText, nil)}];
                }
                
                [self handleStompError:error];
            }
        }];
    }
}

// Internal only as of 6.2.1.
- (void)connectToHost:(NSString *)host {
    
    self.stompClient = [ECSStompClient new];
    self.stompClient.delegate = self;
    
    ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    [self.stompClient setAuthToken:sessionManager.authToken]; 
    
    NSString *hostName = [[NSURL URLWithString:host] host];
    //NSString *bearerToken = sessionManager.authToken;
    NSNumber *port = [[NSURL URLWithString:host] port];
    
    if (port) {
        
        hostName = [NSString stringWithFormat:@"%@:%@", hostName, port];
    }
    
    // Use secure STOMP (wss) if the host is using HTTPS
    NSString *stompProtocol = ([host containsString:@"https"] ? @"wss" : @"ws");
    NSString *stompHostName = [NSString stringWithFormat:@"%@://%@/conversationengine/async", stompProtocol, hostName];
    
    self.stompClient.authToken = sessionManager.authToken;
    
    [self.stompClient connectToHost:stompHostName];
}

// Internal only.
- (void)setMessagingChannelConfiguration:(ECSChannelCreateResponse *)configuration {
    
    self.channel = configuration;
    
    if (configuration.messagesLink) {
        
        /* Nathan Keeney 10/20/2015 - With a recent change to the URL format of STOMP links,
           "URLByDeletingLastPathComponent" is no longer the correct way to modify a link.
         
           Instead, URLByDeletingPathExtension will remove everything after the last dot.
         */
        self.sendMessageDestination = [[NSURL URLWithString:configuration.messagesLink] path];
        
        NSURL *notificationURL = [[NSURL URLWithString:configuration.messagesLink] URLByDeletingPathExtension];
        notificationURL = [notificationURL URLByAppendingPathExtension:@"notifications"];
        self.sendNotificationDestination = [notificationURL path];
        
        NSURL *cobrowseURL = [[NSURL URLWithString:configuration.messagesLink] URLByDeletingPathExtension];
        cobrowseURL = [cobrowseURL URLByAppendingPathExtension:@"cobrowse"];
        self.sendCoBrowseDestination = [cobrowseURL path];
    }
}

- (void)subscribeToDestination:(NSString *)destination
            withSubscriptionID:(NSString *)subscriptionId {
    
    NSString *fullDestination = [NSString stringWithFormat:@"/topic/conversations.%@", destination];
    
    self.subscriptionId = subscriptionId;
    
    [self.stompClient subscribeToDestination:fullDestination
                          withSubscriptionID:subscriptionId
                                  subscriber:self];
}

- (void)unsubscribe {
    
    [self.stompClient unsubscribe:self.subscriptionId];
    
}

- (void)unsubscribeWithSubscriptionID:(NSString*)subscriptionId {
    
    [self.stompClient unsubscribe:subscriptionId];
}

- (void)sendChatMessage:(ECSChatTextMessage *)message {
    
    if (self.sendMessageDestination) {
        
        NSDictionary *additionalHeaders = @{
                                            kECSHeaderBodyType: kECSChatMessage,
                                            kECSHeaderBodyVersion: kECSMessageBodyVersion
                                            };
        
        NSDictionary *jsonDictionary = [ECSJSONSerializer jsonDictionaryFromObject:message];
        NSError *serializingError = nil;
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:0
                                                         error:&serializingError];
        
        if (!serializingError) {
            
            NSString *destination = self.sendMessageDestination;
            
            [self.stompClient sendMessage:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
                            toDestination:destination
                              contentType:@"application/json"
                        additionalHeaders:additionalHeaders];
            
        }
        
    } else {
        
        ECSLogError(self.logger, @"Attempting to send message when destination is not set.");
        
    }
}

- (void)sendNotificationMessage:(ECSChatNotificationMessage *)message {
    
    if (self.sendNotificationDestination) {
        
        NSDictionary *additionalHeaders = @{
                                            kECSHeaderBodyType: kECSChatNotificationMessage,
                                            kECSHeaderBodyVersion: kECSMessageBodyVersion
                                            };
        NSDictionary *jsonDictionary = [ECSJSONSerializer jsonDictionaryFromObject:message];
        NSError *serializingError = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&serializingError];
        
        if (!serializingError) {
            
            NSString *destination = self.sendNotificationDestination;
            
            [self.stompClient sendMessage:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
                            toDestination:destination
                              contentType:@"application/json"
                        additionalHeaders:additionalHeaders];
        }
        
    } else {
        
        ECSLogError(self.logger,@"Attempting to send message when destination is not set.");
    }
}

- (void)sendCoBrowseMessage:(ECSChatCoBrowseMessage *)message {
    
    if (self.sendCoBrowseDestination) {
        
        NSDictionary *additionalHeaders = @{
                                            kECSHeaderBodyType: kECSChatCoBrowseMessage,
                                            kECSHeaderBodyVersion: kECSMessageBodyVersion
                                            };
        NSDictionary *jsonDictionary = [ECSJSONSerializer jsonDictionaryFromObject:message];
        NSError *serializingError = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&serializingError];
        
        if (!serializingError) {
            
            NSString *destination = self.sendCoBrowseDestination;
            
            [self.stompClient sendMessage:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
                            toDestination:destination
                              contentType:@"application/json"
                        additionalHeaders:additionalHeaders];
        }
        
    } else {
        
        ECSLogError(self.logger,@"Attempting to send message when destination is not set.");
    }
}

- (void)sendChatText:(NSString *)messageBody
             completion:(void(^)(NSString *response, NSError *error))completion {
    
    ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    [urlSession sendChatMessage:messageBody
                           from:_fromUsername
                        channel:_currentChannelId
                     completion:completion];
}

- (void) sendChatState:(ECSChatState)theChatState
            completion:(void(^)(NSString *response, NSError *error))completion {
    
    ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    int duration_not_used = 0;
    NSString *chatStateString = @"unknown";
    
    if( theChatState == ECSChatStateComposing) {
        chatStateString = @"composing";
    } else if ( theChatState == ECSChatStateTypingPaused) {
        chatStateString = @"paused";
    }
    
    [urlSession sendChatState:chatStateString 
                     duration:duration_not_used
                      channel:_currentChannelId
                   completion:completion];
}

- (void)sendMedia:(NSDictionary *)mediaInfo
      notifyAgent:(bool)notify
       completion:(void(^)(NSString *response, NSError *error))completion {
    
    NSString *uploadName =              [ECSMediaInfoHelpers uploadNameForMedia:mediaInfo];
    ECSURLSessionManager *urlSession =  [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    // Upload the media file to Humanify servers.
    [urlSession uploadFileData:[ECSMediaInfoHelpers uploadDataForMedia:mediaInfo]
                      withName:uploadName
               fileContentType:[ECSMediaInfoHelpers fileTypeForMedia:mediaInfo]
                    completion:^(__autoreleasing id *response, NSError *error)
     {
         
         if (error) {
             
             NSLog(@"Error sending media: %@", error);
             
             completion(nil, error);
             
         } else {
             
             if( notify ) {
                 
                 ECSURLSessionManager *urlSession2 = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
                 
                 // Notify the agent client that they just received a media file.
                 [urlSession2 sendChatNotificationFrom:self.fromUsername
                                                 type:@"artifact"
                                           objectData:uploadName
                                       conversationId:self.currentConversation.conversationID
                                              channel:self.currentChannelId
                                           completion:^(NSString *response, NSError *error)
                  {
                      
                      if( error ) {
                          
                          NSLog(@"Error sending chat media message: %@", error);
                          
                          completion(nil, error);
                          
                      } else {
                          
                          completion(response, nil);
                          
                      }
                      
                  }];
                 
             } else {
                 
                 completion(@"success", nil);
                 
             }
         }
     }];
}

#pragma mark - ECSStompClient

- (void)stompClientDidCloseWithCode:(NSInteger)code reason:(NSString *)reason {
    
    if( [self isChatActive] && ![self.stompClient isConnecting] ) {
        // Chat was active and we got a close event. Start polling for reconnect.
        
        [self stompRetryTimerStartWithDelay:5];
        
    }
    
}

- (void) stompRetryTimerStartWithDelay:(int)delay {
    
    if( _stompRetryTimer ) [self stompRetryTimerStop];
    
    ECSLogVerbose(self.logger, @"Scheduling WebSocket reconnect in %d seconds.", delay);
    
    _stompConnectionLost = YES;
    _stompRetryInterval = delay; // Base retry (increases over time)
    _stompRetryAttempts = 1;
    _stompRetriesBlocked = 0;
    _stompRetryTimer = [NSTimer scheduledTimerWithTimeInterval:_stompRetryInterval
                                                        target:self
                                                      selector:@selector(stompRetryTimerTick)
                                                      userInfo:nil
                                                       repeats:NO];
}

- (void) stompRetryTimerTick {
    
    _stompRetryInterval = _stompRetryInterval + 5;
    _stompRetryAttempts = _stompRetryAttempts + 1;
    ECSLogVerbose(self.logger, @"WebSocket reconnect attempt. Next attempt in %d seconds.", _stompRetryInterval);
    
    // Shoot off a reconnect. If we get connected, we'll invalidate the timer.
    if( ![self.stompClient reconnect] ) {
        _stompRetriesBlocked += 1; 
    }
    
    // Something was bungled in the WebSocket state machine. Force a reconnect. 
    if( _stompRetriesBlocked >= 3 ) {
        ECSLogVerbose(self.logger, @"WebSocket state stuck in %@. Forcing new connection...", [self.stompClient readyStateString]);
        [self.stompClient closeSocket];
        [self.stompClient reconnect]; 
    }
       
    _stompRetryTimer = [NSTimer scheduledTimerWithTimeInterval:_stompRetryInterval
                                                        target:self
                                                      selector:@selector(stompRetryTimerTick)
                                                      userInfo:nil
                                                       repeats:NO];
    
}

- (void) stompRetryTimerStop {
    
    if( _stompRetryTimer ) {
        
        ECSLogDebug(self.logger, @"Stopping WebSocket reconnect timer.");
        
        [_stompRetryTimer invalidate];
        _stompRetryTimer = nil;
    }
    _stompConnectionLost = NO;
}

- (void)stompClient:(ECSStompClient *)stompClient didFailWithError:(NSError *)error {
    
    ECSLogError(self.logger, @"WebSocket error: %@", error);
    
    // A 401 error occurred trying to start the stomp connection back up. Fetch a new auth token and try again.
    
    if( (error.code == ECS_ERROR_STOMP_OPEN && [error.userInfo[@"HTTPResponseStatusCode"] intValue] == 401) ||
        ([error.userInfo[@"description"] isEqualToString:@"Authentication failed."]) ) {
        
        // Let's immediately try to refresh the auth token.

        int retryCount = 0;
        [[EXPERTconnect shared].urlSession refreshIdentityDelegate:retryCount
                                                    withCompletion:^(NSString *authToken, NSError *error)
         {
             // AuthToken updated. Try to reconnect.
             if( !error ) {
                 
                 // TODO: There is a scenario where if the auth token expires right as the "Subscribe" is sent, two chats can be initiated. 
                 [self connectToHost:[EXPERTconnect shared].urlSession.hostName];
                 
             } else {
                 
                 [self handleStompError:error];
             }
         }];
        
    } else if ( error.code >= ENETDOWN && error.code <= ENOTCONN) {
        
        // Network is down. We will get a reachability notification for instant reconnect, but we'll also poll.
        if( !_stompRetryTimer ) [self stompRetryTimerStartWithDelay:10];
        
        [self handleStompError:error];
        
    } else {
    
        // Any other error we simply pass on to the host implementation.
        
        [self handleStompError:error];
    }
}

- (void)stompClientDidConnect:(ECSStompClient *)stompClient {
    
    ECSLogVerbose(self.logger, @"connection detected.");

    [self stompRetryTimerStop]; // If started, stop the retry timer (we just got connected). 
    
    // Start listening for reachability events.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ECSReachabilityChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkConnectionChanged:)
                                                 name:ECSReachabilityChangedNotification
                                               object:nil];
    
    
    if (!_initialConnectionMade) {
        _initialConnectionMade = YES;
    } else {
        //[self checkChatState];
        [self performSelector:@selector(checkChatState) withObject:nil afterDelay:5];
    }

    [self subscribeToDestination:self.currentConversation.conversationID
              withSubscriptionID:@"ios-1"];
    
    if (!self.currentChannelId) {
        
        _channelState = ECSChannelStateQueued; // Manually set state to queued.
        
        [self setupChatChannel];
    }
    
    // Older
    if ([self.delegate respondsToSelector:@selector(chatClientDidConnect:)]) {
        
        [self.delegate chatClientDidConnect:self];
    }
    
    // New
    if( [self.delegate respondsToSelector:@selector(chatDidConnect)]) {
        
        [self.delegate chatDidConnect];
    }
}

- (void)checkChatState {
    
    ECSLogVerbose(self.logger, @"Checking chat state via API. Usually called after a long period of idleness.");
    
    [[EXPERTconnect shared].urlSession getDetailsForChannelId:self.currentChannelId
                                                   completion:^(ECSChannelConfiguration *channelConfig, NSError *error) {
        
        if( channelConfig.channelState == ECSChannelStateDisconnected &&
            self.channelState != ECSChannelStateDisconnected ) {
            
            // The channel has disconnected. Send a disconnect so the low level delegate knows to act upon it.
            ECSLogDebug(self.logger, @"API check of chat state revealed it was disconnected. Sending disconnect callback. channelConfig=%@", channelConfig);
            
            [self sendDisconnectCallbackWithReason:@"idleTimeout"
                                      terminatedBy:@"system"];
        }
    }];
}

// Something bad happened...
-(void)stompClientDidDisconnect:(ECSStompClient *)stompClient {

    // Stop listening for reachability events.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ECSReachabilityChangedNotification object:nil];
    
    [self sendDisconnectCallbackWithReason:@"error"
                              terminatedBy:@"error"];
}

- (void)stompClient:(ECSStompClient *)stompClient didReceiveMessage:(ECSStompFrame *)message {
    
    NSString *bodyType = message.headers[kECSHeaderBodyType];
    
    if ([bodyType isEqualToString:kECSChatMessage])
    {
        [self handleChatMessage:message forClient:stompClient];
    }
    
    else if ([bodyType isEqualToString:kECSChatStateMessage])
    {
        [self handleChatStateMessage:message forClient:stompClient];
    }
    
    else if ([bodyType isEqualToString:kECSChatNotificationMessage])
    {
        [self handleChatNotificationMessage:message forClient:stompClient];
    }
    
    else if ([bodyType isEqualToString:kECSChannelStateMessage])
    {
        [self handleChannelStateMessage:message forClient:stompClient];
    }
    
    else if ([bodyType isEqualToString:kECSChatRenderURLMessage])
    {
        [self handleURLMessage:message forClient:stompClient];
    }
    
    else if ([bodyType isEqualToString:kECSChatRenderFormMessage])
    {
        [self handleFormMessage:message forClient:stompClient];
    }
    
    else if ([bodyType isEqualToString:kECSChatAddParticipantMessage])
    {
        [self handleAddParticipantMessage:message forClient:stompClient];
    }
    
    else if ([bodyType isEqualToString:kECSChatRemoveParticipantMessage])
    {
        [self handleRemoveParticipantMessage:message forClient:stompClient];
    }
    
    else if ([bodyType isEqualToString:kECSChatAddChannelMessage])
    {
        [self handleAddChannelMessage:message forClient:stompClient];
    }
    
    else if ([bodyType isEqualToString:kECSChatAssociateInfoMessage])
    {
        [self handleAssociateInfoMessage:message forClient:stompClient];
    }
    
    else if ([bodyType isEqualToString:kECSChatCoBrowseMessage])
    {
//        [self handleCoBrowseMessage:message forClient:stompClient];
    }
    
    else if ([bodyType isEqualToString:kECSCafeXMessage])
    {
//        [self handleCafeXMessage:message forClient:stompClient];
    }
    
    else if ([bodyType isEqualToString:kECSVoiceAuthenticationMessage])
    {
//        [self handleVoiceAuthenticationMessage:message forClient:stompClient];
    }
    
    else if ([bodyType isEqualToString:kECSSendQuestionMessage])
    {
        [self handleSendQuestionMessage:message forClient:stompClient];
    }
    
    else if ([bodyType isEqualToString:kECSChannelTimeoutWarning])
    {
        [self handleChannelTimeoutWarning:message forClient:stompClient];
        //TODO: Handle channel timeout warning.
    }
}

#pragma mark - STOMP Message Handling

- (void)handleChatMessage:(ECSStompFrame*)message
                forClient:(ECSStompClient*)stompClient {
    
    self.agentInteractionCount++;
    
    NSError *serializationError = nil;
    
    id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                options:0
                                                  error:&serializationError];
    if (!serializationError) {
        
        ECSChatTextMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                        withClass:[ECSChatTextMessage class]];
        message.fromAgent = YES;
        
        NSString *timeStamp = [self getTimeStampMessage];
        ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
        
        if(!message.timeStamp) {
            
            if(theme.showChatTimeStamp  == YES) {
                
                if(![timeStamp isEqualToString:self.lastTimeStamp]) {
                    
                    message.timeStamp = timeStamp;
                    
                } else {
                    
                    // TODO: move this variable to an internal container.
                    if (self.lastChatMessageFromAgent == NO) {
                        message.timeStamp = timeStamp;
                    }
                }
                
                self.lastTimeStamp = timeStamp;
            }
        }
        
        ECSLogDebug(self.logger, @"Received chat message from %@, body=%@", message.from, message.body);
        
        // Older method
        if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveMessage:)]) {
            [self.delegate chatClient:self didReceiveMessage:message];
        }
        
        // New specific method
        if ([self.delegate respondsToSelector:@selector(chatReceivedTextMessage:)]) {
            
            [self.delegate chatReceivedTextMessage:message]; 
        }
        
    } else {
        
        ECSLogError(self.logger,@"Unable to parse chat message %@", serializationError);
    }
	 
}

- (void)handleChatStateMessage:(ECSStompFrame*)message
                     forClient:(ECSStompClient*)stompClient {
    
    NSError *serializationError = nil;
    
    id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                options:0 error:&serializationError];
    
    if (!serializationError) {
        
        ECSChatStateMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                         withClass:[ECSChatStateMessage class]];
        
        _chatState = message.chatState;
        
        message.fromAgent = YES;
        
        ECSLogDebug(self.logger, @"Chat state change to %@", message.state);
        
        // Older method
        if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveChatStateMessage:)]) {
            [self.delegate chatClient:self didReceiveChatStateMessage:message];
        }
        
        // Newer specific method.
        if ([self.delegate respondsToSelector:@selector(chatReceivedChatStateMessage:)]) {
            [self.delegate chatReceivedChatStateMessage:message];
        }
        
    } else {
        
        ECSLogError(self.logger,@"Unable to parse chat state message %@", serializationError);
    }
    
}

- (void)handleChatNotificationMessage:(ECSStompFrame*)message
                            forClient:(ECSStompClient*)stompClient {
    
    NSError *serializationError = nil;
    
    id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                options:0
                                                  error:&serializationError];
    
    if (!serializationError) {
        
        ECSChatNotificationMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                                withClass:[ECSChatNotificationMessage class]];
        message.fromAgent = YES;
        NSString *fileName = message.objectData;
        NSString *tempString = [[fileName componentsSeparatedByString:@"."] lastObject];
        
        // TODO: Odd that we handle PDFs as a URL message. Update this?
        if( [tempString isEqualToString:@"pdf"] ) {
            
            ECSChatURLMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                           withClass:[ECSChatURLMessage class]];
            message.comment = fileName;
            message.url = fileName;
            message.urlType = @"PDF Document";
            message.fromAgent = YES;
            
            ECSLogDebug(self.logger, @"Received PDF from %@. Filename=%@, URL=%@", message.from, message.comment, message.url);
            
            // Old
            if( [self.delegate respondsToSelector:@selector(chatClient:didReceiveMessage:)] ) {
                [self.delegate chatClient:self didReceiveMessage:message];
            }
//            // New
//            if( [self.delegate respondsToSelector:@selector(chatReceivedTextMessage:)] ) {
//                [self.delegate chatReceivedTextMessage:message];
//            }
            
        } else {
            
            ECSLogDebug(self.logger, @"Chat notification. From=%@, ObjectData=%@", message.from, message.objectData);
            
            // Old
            if ( [self.delegate respondsToSelector:@selector(chatClient:didReceiveChatNotificationMessage:)] ) {
                [self.delegate chatClient:self didReceiveChatNotificationMessage:message];
            }
            // New
            if( [self.delegate respondsToSelector:@selector(chatReceivedNotificationMessage:)] ) {
                [self.delegate chatReceivedNotificationMessage:message];
            }
        }
        
    } else {
        
        ECSLogError(self.logger,@"Unable to parse chat state message %@", serializationError);
        
    }
}


- (void)handleChannelStateMessage:(ECSStompFrame*)message
                        forClient:(ECSStompClient*)stompClient {

    NSError *serializationError = nil;
    id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                options:0 error:&serializationError];
    
    if (!serializationError) {
        
        ECSChannelStateMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                            withClass:[ECSChannelStateMessage class]];
        _channelState = message.channelState;
        
        ECSLogVerbose(self.logger, @"Received channel state update to %@. message.channelId = %@, currentChannelId = %@", message.state, message.channelId, self.currentChannelId);
        
        // mas - Aug-3-2018 - It is possible to receive an "answered" STOMP message before a channelID has been received via HTTP POST,
        // therefore as a work-around I have moved this call to outside the "check if channelID is ours" IF check. This is a breaking change
        // for supporting 2 or more chats on the same device (not a feature we currently support).
        if( message.channelState == ECSChannelStateConnected) {
            ECSLogVerbose(self.logger, @"Sending agent answered callback to listeners...");
            [self sendAgentAnsweredCallback];
        }
        
        // Make sure this message is for our current channelId.
        if( [message.channelId isEqualToString:self.currentChannelId] ) {
        
            // (old) Estimated wait data included
            if( message.estimatedWait ) {
                [self sendUpdatedEstimatedWait:message.estimatedWait.intValue];
            }
        
            if (message.channelState == ECSChannelStateConnected) {

                // ECSChannelStateConnect = "answered" from the server.
                
                // mas - Aug-3-2018 - Handled above (for now).
//                [self sendAgentAnsweredCallback];
                
            } else if (message.channelState == ECSChannelStateDisconnected) {
                
                // The associate or system has disconnected. We have nothing left to listen for. Let's unsubscribe.
                if( message.disconnectReason != ECSDisconnectReasonError ) {
                    
                    ECSLogDebug(self.logger, @"Issuing an UNSUBSCRIBE. We will have nothing else to listen for.");
                    
                    [self unsubscribe];
                }
                
                [self sendDisconnectCallbackWithReason:message.disconnectReasonString
                                          terminatedBy:message.terminatedByString];
                
            } else if (message.channelState == ECSChannelStateQueued) {
                
                if( [self.delegate respondsToSelector:@selector(chatClient:didReceiveChannelStateMessage:)]) {
                    [self.delegate chatClient:self didReceiveChannelStateMessage:message];
                }
                
            }
            
            // In delegate 2.0, always report a channelStateMessage (we might also report a friendly delegate callback as well)
            if( [self.delegate respondsToSelector:@selector(chatReceivedChannelStateMessage:)] ) {
                [self.delegate chatReceivedChannelStateMessage:message];
            }
            
        } else {
            
            ECSLogError(self.logger, @"Possible error: Received a message with a different channelID than ours. Message.channelId=%@, currentChannelID=%@", message.state, self.currentChannelId);
        }

    } else {
        
        ECSLogError(self.logger, @"Unable to parse channel state message %@", serializationError);
    }
}

- (void)handleURLMessage:(ECSStompFrame*)message
               forClient:(ECSStompClient*)stompClient {
    
    NSError *serializationError = nil;
    
    id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                options:0 error:&serializationError];
    if (!serializationError) {
        
        ECSChatURLMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                       withClass:[ECSChatURLMessage class]];
        message.fromAgent = YES;
        
        ECSLogDebug(self.logger, @"Received URL message from %@. URL=%@", message.from, message.url);
        
        if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveMessage:)]) {
            [self.delegate chatClient:self didReceiveMessage:message];
        }
        
        if([self.delegate respondsToSelector:@selector(chatReceivedURL:)]) {
            [self.delegate chatReceivedURL:message];
        }
        
    } else {
        
        ECSLogError(self.logger,@"Unable to parse chat state message %@", serializationError);
        
    }
}

- (void)handleFormMessage:(ECSStompFrame*)message
                forClient:(ECSStompClient*)stompClient {
    
    NSError *serializationError = nil;
    
    id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                options:0 error:&serializationError];
    if (!serializationError) {
        
        ECSChatFormMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                        withClass:[ECSChatFormMessage class]];
        message.fromAgent = YES;
        
        ECSLogDebug(self.logger, @"Received Form message from %@. Form name=%@", message.from, message.formName);
        
        if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveMessage:)]) {
            [self.delegate chatClient:self didReceiveMessage:message];
        }
        
        if([self.delegate respondsToSelector:@selector(chatReceivedInlineForm:)]) {
            [self.delegate chatReceivedInlineForm:message];
        }
        
    } else {
        
        ECSLogError(self.logger,@"Unable to parse chat form message %@", serializationError);
        
    }
    
}


- (void)handleAddParticipantMessage:(ECSStompFrame*)message
                          forClient:(ECSStompClient*)stompClient {
    
    NSError *serializationError = nil;
    
    id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                options:0 error:&serializationError];
    
    if (!serializationError) {
        
        ECSChatAddParticipantMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                                  withClass:[ECSChatAddParticipantMessage class]];
        
        message.fromAgent = NO;
        
        ECSLogDebug(self.logger, @"Received add participant. Participant=%@ %@ (%@)", message.firstName, message.lastName, message.userId);
        
        // Older method
        if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveMessage:)]) {
            [self.delegate chatClient:self didReceiveMessage:message];
        }
        
        // Newer specific method.
        if ([self.delegate respondsToSelector:@selector(chatAddedParticipant:)]) {
            [self.delegate chatAddedParticipant:message];
        }
        
        // mas - Aug-3-2018 - If we're receiving an AddParticipant message, and we're not "answered", we must have missed something.
        // Go ahead and set the chat status to "answered" (since a participant is literally joining the chat) and throw the callback.
        // Since this is a work-around, we're not going to muck with the current channelState. Hopefully it gets fixed.
        if( _channelState != ECSChannelStateConnected ) {
            ECSLogError(self.logger, @"Error: AddParticipant received but chat state \"answered\" was not. Assuming chat state is answered...");
            [self sendAgentAnsweredCallback];
        }
        
    } else {
        
        ECSLogError(self.logger,@"Unable to parse chat state message %@", serializationError);
    }
}

- (void)handleRemoveParticipantMessage:(ECSStompFrame*)message
                             forClient:(ECSStompClient*)stompClient {
    
    NSError *serializationError = nil;
    
    id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                options:0 error:&serializationError];
    
    if (!serializationError) {
        
        ECSChatRemoveParticipantMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                                     withClass:[ECSChatRemoveParticipantMessage class]];
        
        message.fromAgent = NO;
        
        ECSLogDebug(self.logger, @"Received remove participant. Participant=%@ %@ (%@). Reason=%@",
                    message.firstName, message.lastName, message.userId, message.reason);
        
        if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveMessage:)]) {
            [self.delegate chatClient:self didReceiveMessage:message];
        }
        
        if([self.delegate respondsToSelector:@selector(chatRemovedParticipant:)]) {
            [self.delegate chatRemovedParticipant:message];
        }
        
    } else {
        ECSLogError(self.logger,@"Unable to parse chat state message %@", serializationError);
    }
}

- (void)handleAddChannelMessage:(ECSStompFrame*)message
                      forClient:(ECSStompClient*)stompClient {
    
    NSError *serializationError = nil;
    
    id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                options:0
                                                  error:&serializationError];
    if (!serializationError) {
        
        ECSChatAddChannelMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                              withClass:[ECSChatAddChannelMessage class]];
        message.fromAgent = YES;
        
        ECSLogDebug(self.logger, @"Received add channel. ChannelID=%@", message.channelId);
        
        // Old
        if ( [self.delegate respondsToSelector:@selector(chatClient:didAddChannelWithMessage:)] ) {
            [self.delegate chatClient:self didAddChannelWithMessage:message];
        }
        // New
        if( [self.delegate respondsToSelector:@selector(chatAddChannelWithMessage:)] ) {
            [self.delegate chatAddChannelWithMessage:message];
        }
        
    } else {
        
        ECSLogError(self.logger,@"Unable to parse chat state message %@", serializationError);
    }
}

- (void)handleAssociateInfoMessage:(ECSStompFrame*)message
                         forClient:(ECSStompClient*)stompClient {
    
    NSError *serializationError = nil;
    
    id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                options:0
                                                  error:&serializationError];
    
    if (!serializationError) {
        
        ECSChatAssociateInfoMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                                 withClass:[ECSChatAssociateInfoMessage class]];
        message.fromAgent = YES;
        
        ECSLogDebug(self.logger, @"Received associate info from %@. Body=%@", message.from, message.message);
        
        if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveMessage:)]) {
            [self.delegate chatClient:self didReceiveMessage:message];
        }
        
        if([self.delegate respondsToSelector:@selector(chatReceivedAssociateInfo:)]) {
            [self.delegate chatReceivedAssociateInfo:message];
        }
        
    } else {
        
        ECSLogError(self.logger,@"Unable to parse chat message %@", serializationError);
        
    }
}

- (void)handleSendQuestionMessage:(ECSStompFrame*)message
                        forClient:(ECSStompClient*)stompClient {
    
    self.agentInteractionCount++;
    
    NSError *serializationError = nil;
    
    id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                options:0 error:&serializationError];
    
    if (!serializationError) {
        ECSSendQuestionMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                            withClass:[ECSSendQuestionMessage class]];
        
        message.fromAgent = YES;
        
        ECSLogDebug(self.logger, @"Received send question from %@. QuestionText=%@", message.from, message.questionText);
        
        if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveMessage:)]) {
            [self.delegate chatClient:self didReceiveMessage:message];
        }
        
        if([self.delegate respondsToSelector:@selector(chatReceivedQuestion:)]) {
            [self.delegate chatReceivedQuestion:message];
        }
        
    } else {
        
        ECSLogError(self.logger,@"Unable to parse chat message %@", serializationError);
        
    }
}

- (void)handleChannelTimeoutWarning:(ECSStompFrame*)message
                          forClient:(ECSStompClient*)stompClient {
    
    NSError *serializationError = nil;
    
    id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                options:0 error:&serializationError];
    
    if (!serializationError) {
        
        ECSChannelTimeoutWarningMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                                     withClass:[ECSChannelTimeoutWarningMessage class]];
        
        ECSLogDebug(self.logger, @"Received channel timeout warning. Timeout Seconds=%@", message.timeoutSeconds);
        
        // Older
        if( [self.delegate respondsToSelector:@selector(chatClientTimeoutWarning:timeoutSeconds:)] ) {
            [self.delegate chatClientTimeoutWarning:self timeoutSeconds:[message.timeoutSeconds intValue]];
        }
        
        // New
        if( [self.delegate respondsToSelector:@selector(chatTimeoutWarning:)]) {
            [self.delegate chatTimeoutWarning:[message.timeoutSeconds intValue]];
        }
        
    } else {
        
        ECSLogError(self.logger,@"Unable to parse chat message %@", serializationError);
        
    }
    
}

-(void)sendUpdatedEstimatedWait:(int)estWait {
    // (old) Estimated wait data included
    if ( [self.delegate respondsToSelector:@selector(chatClient:didUpdateEstimatedWait:)] ) {
        [self.delegate chatClient:self didUpdateEstimatedWait:(NSInteger)estWait];
    }
    
    if( [self.delegate respondsToSelector:@selector(chatUpdatedEstimatedWait:)] ) {
        [self.delegate chatUpdatedEstimatedWait:estWait];
    }
}

-(void)sendAgentAnsweredCallback {
    // Connected means an agent has answered the chat.
    if([self.delegate respondsToSelector:@selector(chatClientAgentDidAnswer:)]) {
        [self.delegate chatClientAgentDidAnswer:self];
    }
    
    if([self.delegate respondsToSelector:@selector(chatAgentDidAnswer)]) {
        [self.delegate chatAgentDidAnswer];
    }
}

-(void)sendDisconnectCallbackWithReason:(NSString *)reason terminatedBy:(NSString *)terminatedBy {
    
    ECSChannelStateMessage *message = [[ECSChannelStateMessage alloc] init];
    message.state = @"disconnected";
    message.terminatedByString = terminatedBy;
    message.disconnectReasonString = reason;
    message.channelId = self.currentChannelId;
    message.conversationId = self.currentConversation.conversationID;
    
    if( [self.delegate respondsToSelector:@selector(chatClient:disconnectedWithMessage:)] ) {
        [self.delegate chatClient:self disconnectedWithMessage:message];
    }
    
    if( [self.delegate respondsToSelector:@selector(chatDisconnectedWithMessage:)]) {
        [self.delegate chatDisconnectedWithMessage:message];
    }
}

//- (void)handleCoBrowseMessage:(ECSStompFrame*)message forClient:(ECSStompClient*)stompClient
//{
//    if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveMessage:)])
//    {
//        NSError *serializationError = nil;
//        id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
//                                                    options:0
//                                                      error:&serializationError];
//        if (!serializationError)
//        {
//            ECSChatCoBrowseMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
//                                                                                withClass:[ECSChatCoBrowseMessage class]];
//            message.fromAgent = YES;
//            [self.delegate chatClient:self didReceiveMessage:message];
//        }
//        else
//        {
//            ECSLogError(self.logger,@"Unable to parse chat message %@", serializationError);
//        }
//    }
//}
//
//- (void)handleCafeXMessage:(ECSStompFrame*)message forClient:(ECSStompClient*)stompClient
//{
//    if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveMessage:)])
//    {
//        NSError *serializationError = nil;
//        id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
//                                                    options:0
//                                                      error:&serializationError];
//        if (!serializationError)
//        {
//            ECSCafeXMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
//                                                                                withClass:[ECSCafeXMessage class]];
//            message.fromAgent = YES;
//            [self.delegate chatClient:self didReceiveMessage:message];
//        }
//        else
//        {
//            ECSLogError(self.logger,@"Unable to parse chat message %@", serializationError);
//        }
//    }
//}
//
//- (void)handleVoiceAuthenticationMessage:(ECSStompFrame*)message forClient:(ECSStompClient*)stompClient
//{
//    if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveMessage:)])
//    {
//        NSError *serializationError = nil;
//        id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
//                                                    options:0
//                                                      error:&serializationError];
//        if (!serializationError)
//        {
//            ECSChatVoiceAuthenticationMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
//                                                                                           withClass:[ECSChatVoiceAuthenticationMessage class]];
//            message.fromAgent = YES;
//            [self.delegate chatClient:self didReceiveMessage:message];
//        }
//        else
//        {
//            ECSLogError(self.logger,@"Unable to parse chat message %@", serializationError);
//        }
//    }
//}

@end
