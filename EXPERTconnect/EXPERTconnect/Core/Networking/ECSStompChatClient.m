//
//  ECSStompChatClient.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSStompClient.h"
#import "ECSStompChatClient.h"
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
static NSString * const kECSHeaderBodyType = @"x-body-type";
static NSString * const kECSHeaderBodyVersion = @"x-body-version";

static NSString * const kECSMessageBodyVersion = @"1";
static NSString * const kECSChannelStateMessage = @"ChannelState";                  // state messages - agent connected, voice call sent, disconnection
/*
 ECSChannelStateDisconnected,
 ECSChannelStateConnected,
 ECSChannelStatePending,
 ECSChannelStateAnswered,
 ECSChannelStateQueued,
 ECSChannelStateNotify,
 ECSChannelStateFailed,
 ECSChannelStateTimeout,
 ECSChannelStateUnknown
 */
static NSString * const kECSChatMessage = @"ChatMessage";                           // Regular text chat message from agent
static NSString * const kECSChatNotificationMessage = @"NotificationMessage";       // Incoming images from agent
static NSString * const kECSChatStateMessage = @"ChatState";                        // Chat state (0, 1=paused, 2=composing)
static NSString * const kECSCommandMessage = @"CommandMessage";
static NSString * const kECSChatRenderURLMessage = @"RenderURLCommand";             // A hyperlink chat message from agent
static NSString * const kECSChatAddParticipantMessage = @"AddParticipant";          // An agent has joined the chat
static NSString * const kECSChatRemoveParticipantMessage = @"RemoveParticipant";    // An agent has left the chat
static NSString * const kECSChatAddChannelMessage = @"AddChannelCommand";
static NSString * const kECSChatAssociateInfoMessage = @"AssociateInfoCommand";
static NSString * const kECSChatCoBrowseMessage = @"CoBrowseMessage";
static NSString * const kECSCafeXMessage = @"CafeXCommand";
static NSString * const kECSVoiceAuthenticationMessage = @"VoiceAuthentication";
static NSString * const kECSChatRenderFormMessage = @"RenderFormCommand";           // A Forms chat message from agent
static NSString * const kECSSendQuestionMessage = @"SendQuestionCommand";
static NSString * const kECSChannelTimeoutWarning = @"ChannelTimeoutWarning";       // Idle timeout warning (approx. 1 minute remaining)

@interface ECSStompChatClient() <ECSStompDelegate>

@property (strong, nonatomic) ECSActionType *actionType;
@property (strong, nonatomic) ECSStompClient *stompClient;

@property (strong, nonatomic) NSString *sendMessageDestination;
@property (strong, nonatomic) NSString *sendNotificationDestination;
@property (strong, nonatomic) NSString *sendCoBrowseDestination;

@property (assign, nonatomic) NSInteger agentInteractionCount;

@property (weak, nonatomic) NSURLSessionTask *currentNetworkTask;

@property (assign, nonatomic) BOOL isReconnecting;

@end

@implementation ECSStompChatClient

@synthesize lastTimeStamp;
@synthesize lastChatMessageFromAgent;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _chatState = ECSChatStateUnknown;
        self.agentInteractionCount = 0;
        
        ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
        
        //TODO: This needs userID from somewhere...
        self.fromUsername = userManager.userDisplayName.length ? userManager.userDisplayName : @"Mobile User";
        self.logger = [[EXPERTconnect shared] logger];
    }
    return self;
}

- (void)dealloc
{
    [self disconnect];
}

- (void)setupChatClientWithActionType:(ECSActionType*)actionType
{
    __weak typeof(self) weakSelf = self;
    self.actionType = actionType;
    
    ECSLogVerbose(self.logger, @"Initiating a new chat client...");
    
    ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    if ([self.actionType isKindOfClass:[ECSChatActionType class]]) {
        
        self.currentNetworkTask = [urlSession startConversationForAction:actionType
                                                     andAlwaysCreate:YES
                                                      withCompletion:^(ECSConversationCreateResponse *conversation, NSError *error)
           {
               
               if ((error || !conversation || ![conversation isKindOfClass:[ECSConversationCreateResponse class]]) &&
                   (error.code != NSURLErrorCancelled)) {
                   
                   if ([self.delegate respondsToSelector:@selector(chatClient:didFailWithError:)]) {
                       
                       if (!error) {
                           
                           error = [NSError errorWithDomain:ECSErrorDomain
                                                       code:ECS_ERROR_API_ERROR
                                                   userInfo:@{NSLocalizedDescriptionKey: ECSLocalizedString(ECSLocalizeErrorText, nil)}];
                       }
                       
                       [self.delegate chatClient:self didFailWithError:error];
                   }
                   
                   return;
               }
               
               weakSelf.currentConversation = conversation;
               [weakSelf connectToHost:urlSession.hostName];
           }];
        
    } else {
        
        // Setup without a Conversation
        NSLog(@"Setting up StompChatClient with non-chat Action Type");
        [self connectToHost:urlSession.hostName];
        
    }
}

- (void)setupChatChannel
{
    ECSChannelConfiguration *configuration = [ECSChannelConfiguration new];
    
    ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
    ECSChatActionType *chatAction = (ECSChatActionType*)self.actionType;
    ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    if (chatAction) {
        if ((chatAction.agentId && chatAction.agentId.length > 0) &&
            (chatAction.agentSkill.length <= 0))
        {
            configuration.to = chatAction.agentId;
        }
        else
        {
            configuration.to = chatAction.agentSkill;
        }
    } else {
        ECSLogError(self.logger,@"setupChatChannel: Error converting actionType to chatAction.");
    }

    // check for video action type
    NSMutableDictionary *featuresDic = [[NSMutableDictionary alloc] init];
    if ([chatAction isKindOfClass:[ECSVideoChatActionType class]])
    {
        ECSVideoChatActionType *videoChatAction = (ECSVideoChatActionType *)chatAction;
        featuresDic[@"cafexmode"] = videoChatAction.cafexmode;
        featuresDic[@"cafextarget"] = videoChatAction.cafextarget;
        //configuration.features = @{ @"cafexmode": videoChatAction.cafexmode, @"cafextarget": videoChatAction.cafextarget };
    }
    
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSString *locale = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    NSString *languageLocale = [NSString stringWithFormat:@"%@_%@", language, locale];
    
    // Overwrite the device locale if the host app desires to do so.
    if(urlSession.localLocale && urlSession.localLocale.length>3)
    {
        languageLocale = urlSession.localLocale;
    }
    featuresDic[@"x-ia-locale"] = languageLocale;
    
    configuration.features = featuresDic; 
    
    if (self.actionType.channelOptions) {
        // Goes into "options" subcategory
        configuration.options = [NSDictionary dictionaryWithDictionary:self.actionType.channelOptions];
    }
    
    configuration.from = ( userManager.userToken ? userManager.userToken : @"Guest" );
    configuration.subject = chatAction.subject; 
    configuration.sourceType = chatAction.sourceType;
    configuration.mediaType = chatAction.mediaType;
    configuration.deviceId = userManager.deviceID;
    configuration.location = chatAction.location; 
    configuration.priority = @1;
    
    NSString *url = nil;
    
    __weak typeof(self) weakSelf = self;
    
    
    url = self.currentConversation.channelLink;

    if (url)
    {
        self.currentNetworkTask = [urlSession setupChannel:configuration
                                            inConversation:url
                                                completion:^(ECSChannelCreateResponse *response, NSError *error)
        {
                                                    
            if (!error && response && response.estimatedWait)
            {
                if ([weakSelf.delegate respondsToSelector:@selector(chatClient:didUpdateEstimatedWait:)])
                {
                    [weakSelf.delegate chatClient:self
                           didUpdateEstimatedWait:response.estimatedWait.integerValue];
                }
                
                weakSelf.currentChannelId = [response.channelId copy];
                weakSelf.channel = response;
                
                // Copy the channelID into the URLSession
                ECSURLSessionManager *urlSession2 = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
                urlSession2.lastChannelId = weakSelf.currentChannelId;
                
                [weakSelf setMessagingChannelConfiguration:response];
            }
            else if (!(error.code == NSURLErrorCancelled))
            {
                if ([self.delegate respondsToSelector:@selector(chatClient:didFailWithError:)])
                {
                    if (!error)
                    {
                        error = [NSError errorWithDomain:ECSErrorDomain
                                                    code:ECS_ERROR_API_ERROR
                                                userInfo:@{NSLocalizedDescriptionKey: ECSLocalizedString(ECSLocalizeErrorText, nil)}];
                    }
                    [self.delegate chatClient:self didFailWithError:error];
                }
            }
        }];
    }
}


- (void)connectToHost:(NSString *)host
{
    self.stompClient = [ECSStompClient new];
    self.stompClient.delegate = self;
    
    ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    [self.stompClient setAuthToken:sessionManager.authToken]; 
    
    NSString *hostName = [[NSURL URLWithString:host] host];
    //NSString *bearerToken = sessionManager.authToken;
    NSNumber *port = [[NSURL URLWithString:host] port];
    
    if (port)
    {
        hostName = [NSString stringWithFormat:@"%@:%@", hostName, port];
    }
    
    // Use secure STOMP (wss) if the host is using HTTPS
    NSString *stompProtocol = ([host containsString:@"https"] ? @"wss" : @"ws");
    NSString *stompHostName = [NSString stringWithFormat:@"%@://%@/conversationengine/async", stompProtocol, hostName];
    self.stompClient.authToken = sessionManager.authToken;
    [self.stompClient connectToHost:stompHostName];
}

-(bool) isConnected {
    return self.stompClient.connected;
}

- (void)reconnect {
    
    self.isReconnecting = YES;
    ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    self.stompClient.authToken = sessionManager.authToken;
    [self.stompClient reconnect];
}

- (void)disconnect {
    
    ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    [self.currentNetworkTask cancel];
    
    if (self.channel && ![self.channel.state isEqualToString:@"disconnected"] && ![self.channel.state isEqualToString:@"disconnecting"]) {
        
        NSString *closeURL = self.channel.closeLink;

        if (closeURL) {
            
            self.channel.state = @"disconnecting";
            
            [urlSession closeChannelAtURL:closeURL
                               withReason:@"Disconnected"
                    agentInteractionCount:self.agentInteractionCount
                                 actionId:self.actionType.actionId
                               completion:^(id result, NSError* error)
            {
                // Do nothing.
                self.channel.state = @"disconnected";
            }];
        }
    }
    
    if (self.stompClient && self.stompClient.connected) {
        
        self.stompClient.delegate = nil;
        
        //[self unsubscribeWithSubscriptionID:@"ios-1"];
        [self unsubscribe];
        
        [self.stompClient disconnect];
    }
}

- (void)setMessagingChannelConfiguration:(ECSChannelCreateResponse *)configuration
{
    self.channel = configuration;
    
    if (configuration.messagesLink)
    {
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

- (void)sendChatMessage:(ECSChatTextMessage *)message
{
    if (self.sendMessageDestination)
    {
        NSDictionary *additionalHeaders = @{
                                            kECSHeaderBodyType: kECSChatMessage,
                                            kECSHeaderBodyVersion: kECSMessageBodyVersion
                                            };
        NSDictionary *jsonDictionary = [ECSJSONSerializer jsonDictionaryFromObject:message];
        NSError *serializingError = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&serializingError];
        
        if (!serializingError)
        {
            NSString *destination = self.sendMessageDestination;
            
            [self.stompClient sendMessage:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
                            toDestination:destination
                              contentType:@"application/json"
                        additionalHeaders:additionalHeaders];
        }
    }
    else
    {
        ECSLogError(self.logger, @"Attempting to send message when destination is not set.");
    }
}

- (void)sendNotificationMessage:(ECSChatNotificationMessage *)message
{
    if (self.sendNotificationDestination)
    {
        NSDictionary *additionalHeaders = @{
                                            kECSHeaderBodyType: kECSChatNotificationMessage,
                                            kECSHeaderBodyVersion: kECSMessageBodyVersion
                                            };
        NSDictionary *jsonDictionary = [ECSJSONSerializer jsonDictionaryFromObject:message];
        NSError *serializingError = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&serializingError];
        
        if (!serializingError)
        {
            NSString *destination = self.sendNotificationDestination;
            
            [self.stompClient sendMessage:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
                            toDestination:destination
                              contentType:@"application/json"
                        additionalHeaders:additionalHeaders];
        }
    }
    else
    {
        ECSLogError(self.logger,@"Attempting to send message when destination is not set.");
    }
}

- (void)sendCoBrowseMessage:(ECSChatCoBrowseMessage *)message
{
    if (self.sendCoBrowseDestination)
    {
        NSDictionary *additionalHeaders = @{
                                            kECSHeaderBodyType: kECSChatCoBrowseMessage,
                                            kECSHeaderBodyVersion: kECSMessageBodyVersion
                                            };
        NSDictionary *jsonDictionary = [ECSJSONSerializer jsonDictionaryFromObject:message];
        NSError *serializingError = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&serializingError];
        
        if (!serializingError)
        {
            NSString *destination = self.sendCoBrowseDestination;
            
            [self.stompClient sendMessage:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
                            toDestination:destination
                              contentType:@"application/json"
                        additionalHeaders:additionalHeaders];
        }
    }
    else
    {
        ECSLogError(self.logger,@"Attempting to send message when destination is not set.");
    }
}


#pragma mark - ECSStompClient

- (void)stompClient:(ECSStompClient *)stompClient didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(chatClient:didFailWithError:)])
    {
        [self.delegate chatClient:self didFailWithError:error];
    }
}

- (void)stompClientDidConnect:(ECSStompClient *)stompClient {
    
    ECSLogVerbose(self.logger, @"connection detected.");
    
    if (self.isReconnecting)
    {
        // kwashington 09/25/2015 - With the new MQ Server in place, this unsubscribe was unsubscribing on
        //                          the new Stomp connection, which is an Error, which caused the subsequent
        //                          Subscribe to fail (as best we can tell anyway).
        //
        // [self unsubscribeWithSubscriptionID:@"ios-1"];
    }

    [self subscribeToDestination:self.currentConversation.conversationID
              withSubscriptionID:@"ios-1"];
    
    if (!self.currentChannelId)
    {
        [self setupChatChannel];
    }
    
    if ([self.delegate respondsToSelector:@selector(chatClientDidConnect:)])
    {
        [self.delegate chatClientDidConnect:self];
    }
}

// Something bad happened...
-(void)stompClientDidDisconnect:(ECSStompClient *)stompClient {

    if ([self.delegate respondsToSelector:@selector(chatClientDisconnected:wasGraceful:)]) {
        
        [self.delegate chatClientDisconnected:self wasGraceful:NO];
    }
    
    if( [self.delegate respondsToSelector:@selector(chatClient:disconnectedWithMessage:)]) {
        
        ECSChannelStateMessage *message = [[ECSChannelStateMessage alloc] init];
        message.state = @"disconnected";
        message.terminatedByString = @"error";
        message.disconnectReasonString = @"error";
        [self.delegate chatClient:self disconnectedWithMessage:message];
    }
}

- (void)stompClient:(ECSStompClient *)stompClient didReceiveMessage:(ECSStompFrame *)message
{
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
        [self handleCoBrowseMessage:message forClient:stompClient];
    }
    else if ([bodyType isEqualToString:kECSCafeXMessage])
    {
        [self handleCafeXMessage:message forClient:stompClient];
    }
    else if ([bodyType isEqualToString:kECSVoiceAuthenticationMessage])
    {
        [self handleVoiceAuthenticationMessage:message forClient:stompClient];
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

- (void)handleChatMessage:(ECSStompFrame*)message forClient:(ECSStompClient*)stompClient
{
	 self.agentInteractionCount++;
	 
	 if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveMessage:)])
	 {
		  NSError *serializationError = nil;
		  id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
													  options:0
                                                        error:&serializationError];
		  if (!serializationError)
		  {
			   ECSChatTextMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
																			   withClass:[ECSChatTextMessage class]];
			   message.fromAgent = YES;
			   
			   NSString *timeStamp = [self getTimeStampMessage];
			   ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
			   if(!message.timeStamp)
			   {
					if(theme.showChatTimeStamp  == YES)
					{
						 if(![timeStamp isEqualToString:self.lastTimeStamp])
						 {
							  message.timeStamp = timeStamp;
						 }
						 else{
                             // TODO: move this variable to an internal container.
							  if (self.lastChatMessageFromAgent == NO) {
								   message.timeStamp = timeStamp;
							  }
						 }
						 self.lastTimeStamp = timeStamp;
					}
			   }
              
              ECSLogDebug(self.logger, @"Received chat message from %@, body=%@", message.from, message.body);
              
			   [self.delegate chatClient:self didReceiveMessage:message];
		  }
		  else
		  {
			   ECSLogError(self.logger,@"Unable to parse chat message %@", serializationError);
		  }
	 }
}

- (void)handleChatStateMessage:(ECSStompFrame*)message forClient:(ECSStompClient*)stompClient
{
    if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveChatStateMessage:)])
    {
        NSError *serializationError = nil;
        id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:0 error:&serializationError];
        if (!serializationError)
        {
            ECSChatStateMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                        withClass:[ECSChatStateMessage class]];
            _chatState = message.chatState;
            message.fromAgent = YES;
            
            ECSLogDebug(self.logger, @"Chat state change to %@", message.state);
            
            [self.delegate chatClient:self didReceiveChatStateMessage:message];
        }
        else
        {
            ECSLogError(self.logger,@"Unable to parse chat state message %@", serializationError);
        }
    }
    
}

- (void)handleChatNotificationMessage:(ECSStompFrame*)message forClient:(ECSStompClient*)stompClient
{
	 if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveChatNotificationMessage:)])
	 {
		  NSError *serializationError = nil;
		  id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
													  options:0 error:&serializationError];
		  if (!serializationError)
		  {
			   ECSChatNotificationMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
																					   withClass:[ECSChatNotificationMessage class]];
			   message.fromAgent = YES;
			   NSString *fileName = message.objectData;
			   NSString *tempString = [[fileName componentsSeparatedByString:@"."] lastObject];
			   if([tempString isEqualToString:@"pdf"])
			   {
					ECSChatURLMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
																				   withClass:[ECSChatURLMessage class]];
					message.comment = fileName;
					message.url = fileName;
					message.urlType = @"PDF Document";
					message.fromAgent = YES;
					
                   ECSLogDebug(self.logger, @"Received PDF from %@. Filename=%@, URL=%@", message.from, message.comment, message.url);
                   
					[self.delegate chatClient:self didReceiveMessage:message];
			   }
			   else
			   {
                   ECSLogDebug(self.logger, @"Chat notification. From=%@, ObjectData=%@", message.from, message.objectData);
                   
					[self.delegate chatClient:self didReceiveChatNotificationMessage:message];
			   }
		  }
		  else
		  {
			   ECSLogError(self.logger,@"Unable to parse chat state message %@", serializationError);
		  }
	 }
}


- (void)handleChannelStateMessage:(ECSStompFrame*)message forClient:(ECSStompClient*)stompClient {

    NSError *serializationError = nil;
    id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                options:0 error:&serializationError];
    
    if (!serializationError) {
        
        ECSChannelStateMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                            withClass:[ECSChannelStateMessage class]];
        _channelState = message.channelState;
        
        ECSLogDebug(self.logger, @"Received channel state update to %@", message.state);

        // Make sure this message is for our current channelId.
        if( [message.channelId isEqualToString:self.currentChannelId] ) {
        
            // Estimated wait data included
            if (message.estimatedWait && [self.delegate respondsToSelector:@selector(chatClient:didUpdateEstimatedWait:)]) {
                
                [self.delegate chatClient:self didUpdateEstimatedWait:message.estimatedWait.integerValue];

            }
        
            if (message.channelState == ECSChannelStateConnected) {
                
                // Connected means an agent has answered the chat.
                if([self.delegate respondsToSelector:@selector(chatClientAgentDidAnswer:)]) {
                    [self.delegate chatClientAgentDidAnswer:self];
                }
                
                if([self.delegate respondsToSelector:@selector(voiceCallbackDidAnswer:)]) {
                    [self.delegate voiceCallbackDidAnswer:self];
                }
                
            } else if (message.channelState == ECSChannelStateDisconnected) {
            
                // First check for the older, deprecated function
                if( [self.delegate respondsToSelector:@selector(chatClientDisconnected:wasGraceful:)]) {
                    [self.delegate chatClientDisconnected:self wasGraceful:YES];
                }
                
                if( [self.delegate respondsToSelector:@selector(chatClient:disconnectedWithMessage:)]) {
                    [self.delegate chatClient:self disconnectedWithMessage:message]; 
                }
            } else if (message.channelState == ECSChannelStateQueued) {
                
                if( [self.delegate respondsToSelector:@selector(chatClient:didReceiveChannelStateMessage:)]) {
                    [self.delegate chatClient:self didReceiveChannelStateMessage:message];
                }
                
            }
        }
    } else {
        ECSLogError(self.logger,@"Unable to parse channel state message %@", serializationError);
    }
}

- (void)handleURLMessage:(ECSStompFrame*)message forClient:(ECSStompClient*)stompClient
{
    if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveMessage:)])
    {
        NSError *serializationError = nil;
        id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:0 error:&serializationError];
        if (!serializationError)
        {
            ECSChatURLMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                             withClass:[ECSChatURLMessage class]];
            message.fromAgent = YES;
            
            ECSLogDebug(self.logger, @"Received URL message from %@. URL=%@", message.from, message.url);
            
            [self.delegate chatClient:self didReceiveMessage:message];
        }
        else
        {
            ECSLogError(self.logger,@"Unable to parse chat state message %@", serializationError);
        }
    }
}

- (void)handleFormMessage:(ECSStompFrame*)message forClient:(ECSStompClient*)stompClient
{
    if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveMessage:)])
    {
        NSError *serializationError = nil;
        id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:0 error:&serializationError];
        if (!serializationError)
        {
            ECSChatFormMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                           withClass:[ECSChatFormMessage class]];
            message.fromAgent = YES;
            
            ECSLogDebug(self.logger, @"Received Form message from %@. Form name=%@", message.from, message.formName);
            
            [self.delegate chatClient:self didReceiveMessage:message];
        }
        else
        {
            ECSLogError(self.logger,@"Unable to parse chat form message %@", serializationError);
        }
    }
    
}


- (void)handleAddParticipantMessage:(ECSStompFrame*)message forClient:(ECSStompClient*)stompClient
{
    if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveMessage:)])
    {
        NSError *serializationError = nil;
        id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:0 error:&serializationError];
        if (!serializationError)
        {
            ECSChatAddParticipantMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                           withClass:[ECSChatAddParticipantMessage class]];
            
            message.fromAgent = NO;
            
            ECSLogDebug(self.logger, @"Received add participant. Participant=%@ %@ (%@)", message.firstName, message.lastName, message.userId);
            
            [self.delegate chatClient:self didReceiveMessage:message];
            
        }
        else
        {
            ECSLogError(self.logger,@"Unable to parse chat state message %@", serializationError);
        }
    }
    
}

- (void)handleRemoveParticipantMessage:(ECSStompFrame*)message forClient:(ECSStompClient*)stompClient
{
    if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveMessage:)])
    {
        NSError *serializationError = nil;
        id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:0 error:&serializationError];
        if (!serializationError)
        {
            ECSChatRemoveParticipantMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                                         withClass:[ECSChatRemoveParticipantMessage class]];
            
            message.fromAgent = NO;
            
            ECSLogDebug(self.logger, @"Received remove participant. Participant=%@ %@ (%@). Reason=%@",
                        message.firstName, message.lastName, message.userId, message.reason);
            
            [self.delegate chatClient:self didReceiveMessage:message];
        }
        else
        {
            ECSLogError(self.logger,@"Unable to parse chat state message %@", serializationError);
        }
    }
    
}

- (void)handleAddChannelMessage:(ECSStompFrame*)message forClient:(ECSStompClient*)stompClient
{
    if ([self.delegate respondsToSelector:@selector(chatClient:didAddChannelWithMessage:)])
    {
        NSError *serializationError = nil;
        id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:0 error:&serializationError];
        if (!serializationError)
        {
            ECSChatAddChannelMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                                      withClass:[ECSChatAddChannelMessage class]];
            message.fromAgent = YES;
            
            ECSLogDebug(self.logger, @"Received add channel. ChannelID=%@", message.channelId);
            
            [self.delegate chatClient:self didAddChannelWithMessage:message];
        }
        else
        {
            ECSLogError(self.logger,@"Unable to parse chat state message %@", serializationError);
        }
    }
    
}

- (void)handleAssociateInfoMessage:(ECSStompFrame*)message forClient:(ECSStompClient*)stompClient
{
    if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveMessage:)])
    {
        NSError *serializationError = nil;
        id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:0
                                                      error:&serializationError];
        if (!serializationError)
        {
            ECSChatAssociateInfoMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                            withClass:[ECSChatAssociateInfoMessage class]];
            message.fromAgent = YES;
            
            ECSLogDebug(self.logger, @"Received associate info from %@. Body=%@", message.from, message.message);
            
            [self.delegate chatClient:self didReceiveMessage:message];
        }
        else
        {
            ECSLogError(self.logger,@"Unable to parse chat message %@", serializationError);
        }
    }
}

- (void)handleCoBrowseMessage:(ECSStompFrame*)message forClient:(ECSStompClient*)stompClient
{
    if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveMessage:)])
    {
        NSError *serializationError = nil;
        id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:0
                                                      error:&serializationError];
        if (!serializationError)
        {
            ECSChatCoBrowseMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                                withClass:[ECSChatCoBrowseMessage class]];
            message.fromAgent = YES;
            [self.delegate chatClient:self didReceiveMessage:message];
        }
        else
        {
            ECSLogError(self.logger,@"Unable to parse chat message %@", serializationError);
        }
    }
}

- (void)handleCafeXMessage:(ECSStompFrame*)message forClient:(ECSStompClient*)stompClient
{
    if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveMessage:)])
    {
        NSError *serializationError = nil;
        id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:0
                                                      error:&serializationError];
        if (!serializationError)
        {
            ECSCafeXMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                                withClass:[ECSCafeXMessage class]];
            message.fromAgent = YES;
            [self.delegate chatClient:self didReceiveMessage:message];
        }
        else
        {
            ECSLogError(self.logger,@"Unable to parse chat message %@", serializationError);
        }
    }
}

- (void)handleVoiceAuthenticationMessage:(ECSStompFrame*)message forClient:(ECSStompClient*)stompClient
{
    if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveMessage:)])
    {
        NSError *serializationError = nil;
        id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:0
                                                      error:&serializationError];
        if (!serializationError)
        {
            ECSChatVoiceAuthenticationMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                                           withClass:[ECSChatVoiceAuthenticationMessage class]];
            message.fromAgent = YES;
            [self.delegate chatClient:self didReceiveMessage:message];
        }
        else
        {
            ECSLogError(self.logger,@"Unable to parse chat message %@", serializationError);
        }
    }
}

- (void)handleSendQuestionMessage:(ECSStompFrame*)message forClient:(ECSStompClient*)stompClient
{
    self.agentInteractionCount++;
    
    if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveMessage:)])
    {
        NSError *serializationError = nil;
        id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:0 error:&serializationError];
        if (!serializationError)
        {
            ECSSendQuestionMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                            withClass:[ECSSendQuestionMessage class]];
            
            message.fromAgent = YES;
            
            ECSLogDebug(self.logger, @"Received send question from %@. QuestionText=%@", message.from, message.questionText);
            
            [self.delegate chatClient:self didReceiveMessage:message];
        }
        else
        {
            ECSLogError(self.logger,@"Unable to parse chat message %@", serializationError);
        }
    }
    
}

- (void)handleChannelTimeoutWarning:(ECSStompFrame*)message forClient:(ECSStompClient*)stompClient
{
    // TODO: Handle chat timeout warning message.
    if( [self.delegate respondsToSelector:@selector(chatClientTimeoutWarning:timeoutSeconds:)] )
    {
        NSError *serializationError = nil;
        id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:0 error:&serializationError];
        if (!serializationError)
        {
            ECSChannelTimeoutWarningMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                      withClass:[ECSChannelTimeoutWarningMessage class]];

            ECSLogDebug(self.logger, @"Received channel timeout warning. Timeout Seconds=%@", message.timeoutSeconds);
            
            [self.delegate chatClientTimeoutWarning:self timeoutSeconds:[message.timeoutSeconds intValue]];

        }
        else
        {
            ECSLogError(self.logger,@"Unable to parse chat message %@", serializationError);
        }
    }
}

// Unit Test: EXPERTconnectTests::testProperties
-(NSString *)getTimeStampMessage
{
    // get current date/time
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // display in 12HR/24HR (i.e. 11:25PM or 23:25) format according to User Settings
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    
    return currentTime;
}

@end
