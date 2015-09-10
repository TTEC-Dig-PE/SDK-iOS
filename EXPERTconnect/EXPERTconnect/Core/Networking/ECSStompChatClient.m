//
//  ECSStompChatClient.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSStompChatClient.h"

#import "ECSChatActionType.h"
#import "ECSVideoChatActionType.h"
#import "ECSChatAddChannelMessage.h"
#import "ECSChatAddParticipantMessage.h"
#import "ECSChatAssociateInfoMessage.h"
#import "ECSChatCoBrowseMessage.h"
#import "ECSCafeXMessage.h"
#import "ECSChatVoiceAuthenticationMessage.h"
#import "ECSChannelConfiguration.h"
#import "ECSChatFormMessage.h"
#import "ECSChatNotificationMessage.h"
#import "ECSChatTextMessage.h"
#import "ECSChatURLMessage.h"
#import "ECSChannelCreateResponse.h"
#import "ECSChannelStateMessage.h"
#import "ECSSendQuestionMessage.h"
#import "ECSConversationCreateResponse.h"
#import "ECSJSONSerializer.h"
#import "ECSJSONSerializing.h"
#import "ECSInjector.h"
#import "ECSLog.h"
#import "ECSURLSessionManager.h"
#import "ECSUserManager.h"

#import "ECSStompClient.h"

// Custom tags for ECS Chat
static NSString * const kECSHeaderBodyType = @"x-body-type";
static NSString * const kECSHeaderBodyVersion = @"x-body-version";

static NSString * const kECSMessageBodyVersion = @"1";
static NSString * const kECSChannelStateMessage = @"ChannelState";
static NSString * const kECSChatMessage = @"ChatMessage";
static NSString * const kECSChatNotificationMessage = @"NotificationMessage";
static NSString * const kECSChatStateMessage = @"ChatState";
static NSString * const kECSCommandMessage = @"CommandMessage";
static NSString * const kECSChatRenderURLMessage = @"RenderURLCommand";
static NSString * const kECSChatAddParticipantMessage = @"AddParticipant";
static NSString * const kECSChatAddChannelMessage = @"AddChannelCommand";
static NSString * const kECSChatAssociateInfoMessage = @"AssociateInfoCommand";
static NSString * const kECSChatCoBrowseMessage = @"CoBrowseMessage";
static NSString * const kECSCafeXMessage = @"CafeXCommand";
static NSString * const kECSVoiceAuthenticationMessage = @"VoiceAuthentication";
static NSString * const kECSChatRenderFormMessage = @"RenderFormCommand";
static NSString * const kECSSendQuestionMessage = @"SendQuestionCommand";

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        _chatState = ECSChatStateUnknown;
        self.agentInteractionCount = 0;
        
        ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
        self.fromUsername = userManager.userDisplayName.length ? userManager.userDisplayName : @"Mobile User";

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
    
    ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    
    self.currentNetworkTask = [urlSession startConversationForAction:actionType
                                                     andAlwaysCreate:YES
                                                      withCompletion:^(ECSConversationCreateResponse *conversation, NSError *error) {
                                                          
                                                          if ((error || !conversation || conversation.conversationID.length == 0) &&
                                                              (error.code != NSURLErrorCancelled))
                                                          {
                                                              if ([self.delegate respondsToSelector:@selector(chatClient:didFailWithError:)])
                                                              {
                                                                  if (!error)
                                                                  {
                                                                      error = [NSError errorWithDomain:@"com.humanify" code:-1
                                                                                              userInfo:@{NSLocalizedDescriptionKey: ECSLocalizedString(ECSLocalizeErrorText, nil)}];
                                                                  }
                                                                  [self.delegate chatClient:self didFailWithError:error];
                                                              }
                                                              return;
                                                          }
                                                          
                                                          weakSelf.currentConversation = conversation;
                                                          [weakSelf connectToHost:urlSession.hostName];
                                                      }];
}

- (void)setupChatChannel
{
    ECSChannelConfiguration *configuration = [ECSChannelConfiguration new];
    
    ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
    ECSChatActionType *chatAction = (ECSChatActionType*)self.actionType;
    
    if ((chatAction.agentId && chatAction.agentId.length > 0) &&
        (chatAction.agentSkill.length <= 0))
    {
        configuration.to = chatAction.agentId;
    }
    else
    {
        configuration.to = chatAction.agentSkill;
    }

    // check for video action type
    if ([chatAction isKindOfClass:[ECSVideoChatActionType class]]) {
        ECSVideoChatActionType *videoChatAction = (ECSVideoChatActionType *)chatAction;
        
        configuration.features = @{ @"cafexmode": videoChatAction.cafexmode, @"cafextarget": videoChatAction.cafextarget };
    }
    
    configuration.from = userManager.userToken;
    configuration.subject = @"help";
    configuration.sourceType = @"Mobile";
    configuration.mediaType = @"Chat";
    configuration.deviceId = userManager.deviceID;
    configuration.location = @"Mobile";
    configuration.priority = @1;
    
    NSString *url = nil;
    
    __weak typeof(self) weakSelf = self;
    ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    url = self.currentConversation.channelLink;

    if (url)
    {
        self.currentNetworkTask = [urlSession setupChannel:configuration inConversation:url
                                                completion:^(ECSChannelCreateResponse *response, NSError *error) {
                                                    
                                                    if (!error && response)
                                                    {
                                                        if ([weakSelf.delegate respondsToSelector:@selector(chatClient:didUpdateEstimatedWait:)])
                                                        {
                                                            [weakSelf.delegate chatClient:self
                                                                   didUpdateEstimatedWait:response.estimatedWait.integerValue];
                                                        }
                                                        
                                                        weakSelf.currentChannelId = [response.channelId copy];
                                                        weakSelf.channel = response;
                                                        [weakSelf setMessagingChannelConfiguration:response];
                                                    }
                                                    else if (!(error.code == NSURLErrorCancelled))
                                                    {
                                                        if ([self.delegate respondsToSelector:@selector(chatClient:didFailWithError:)])
                                                        {
                                                            if (!error)
                                                            {
                                                                error = [NSError errorWithDomain:@"com.humanify" code:-1
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
    
    NSString *hostName = [[NSURL URLWithString:host] host];
    NSNumber *port = [[NSURL URLWithString:host] port];
    
    if (port)
    {
        hostName = [NSString stringWithFormat:@"%@:%@", hostName, port];
    }
    
    NSString *stompHostName = [NSString stringWithFormat:@"ws://%@/conversationengine/async", hostName];
    
    [self.stompClient connectToHost:stompHostName];
}

- (void)reconnect
{
    self.isReconnecting = YES;
    [self.stompClient reconnect];
}

- (void)disconnect
{
    ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    [self.currentNetworkTask cancel];
    
    if (self.channel)
    {
        NSString *closeURL = self.channel.closeLink;

        if (closeURL)
        {
            [urlSession closeChannelAtURL:closeURL
                               withReason:@"Disconnected"
                    agentInteractionCount:self.agentInteractionCount
                                 actionId:self.actionType.actionId
                               completion:nil];
        }
    }
    
    if (self.stompClient && self.stompClient.connected)
    {
        self.stompClient.delegate = nil;
        [self.stompClient disconnect];
    }
}

- (void)setMessagingChannelConfiguration:(ECSChannelCreateResponse *)configuration
{
    self.channel = configuration;
    
    if (configuration.messagesLink)
    {
        self.sendMessageDestination = [[NSURL URLWithString:configuration.messagesLink] path];
        NSURL *notificationURL = [[NSURL URLWithString:configuration.messagesLink] URLByDeletingLastPathComponent];
        notificationURL = [notificationURL URLByAppendingPathComponent:@"notifications"];
        self.sendNotificationDestination = [notificationURL path];
        
        NSURL *cobrowseURL = [[NSURL URLWithString:configuration.messagesLink] URLByDeletingLastPathComponent];
        cobrowseURL = [cobrowseURL URLByAppendingPathComponent:@"cobrowse"];
        self.sendCoBrowseDestination = [cobrowseURL path];
    }
}

- (void)subscribeToDestination:(NSString *)destination withSubscriptionID:(NSString *)subscriptionId
{
    NSString *fullDestination = [NSString stringWithFormat:@"/topic/conversations/%@", destination];
    
    [self.stompClient subscribeToDestination:fullDestination
                          withSubscriptionID:subscriptionId
                                  subscriber:self];
}

- (void)unsubscribeWithSubscriptionID:(NSString*)subscriptionId;
{
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
        ECSLogError(@"Attempting to send message when destination is not set.");
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
        ECSLogError(@"Attempting to send message when destination is not set.");
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
        ECSLogError(@"Attempting to send message when destination is not set.");
    }
}


#pragma mark - ECSStompClient

- (void)stompClientDidConnect:(ECSStompClient *)stompClient
{
    if (self.isReconnecting)
    {
        [self unsubscribeWithSubscriptionID:@"ios-1"];
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
}

- (void)handleChatMessage:(ECSStompFrame*)message forClient:(ECSStompClient*)stompClient
{
    self.agentInteractionCount++;
    
    if ([self.delegate respondsToSelector:@selector(chatClient:didReceiveMessage:)])
    {
        NSError *serializationError = nil;
        id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:0 error:&serializationError];
        if (!serializationError)
        {
            ECSChatTextMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                            withClass:[ECSChatTextMessage class]];
            message.fromAgent = YES;
            [self.delegate chatClient:self didReceiveMessage:message];
        }
        else
        {
            ECSLogError(@"Unable to parse chat message %@", serializationError);
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
            [self.delegate chatClient:self didReceiveChatStateMessage:message];
        }
        else
        {
            ECSLogError(@"Unable to parse chat state message %@", serializationError);
        }
    }
    
}

- (void)handleChatNotificationMessage:(ECSStompFrame*)message forClient:(ECSStompClient*)stompClient
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
            [self.delegate chatClient:self didReceiveChatStateMessage:message];
        }
        else
        {
            ECSLogError(@"Unable to parse chat state message %@", serializationError);
        }
    }
    
}


- (void)handleChannelStateMessage:(ECSStompFrame*)message forClient:(ECSStompClient*)stompClient
{

    NSError *serializationError = nil;
    id result = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding]
                                                options:0 error:&serializationError];
    if (!serializationError)
    {
        ECSChannelStateMessage *message = [ECSJSONSerializer objectFromJSONDictionary:(NSDictionary*)result
                                                                            withClass:[ECSChannelStateMessage class]];
        _channelState = message.channelState;
        
        if (message.estimatedWait && [self.delegate respondsToSelector:@selector(chatClient:didUpdateEstimatedWait:)])
        {
            [self.delegate chatClient:self didUpdateEstimatedWait:message.estimatedWait.integerValue];
        }
        
        if ((message.channelState == ECSChannelStateConnected) &&
            [self.delegate respondsToSelector:@selector(chatClientAgentDidAnswer:)])
        {
            [self.delegate chatClientAgentDidAnswer:self];
        }
        
        // NK 6/24 check for a voice callback channel
        if ((message.channelState == ECSChannelStateConnected) &&
            ![message.channelId isEqualToString:self.currentChannelId] &&
            [self.delegate respondsToSelector:@selector(voiceCallbackDidAnswer:)])
        {
            [self.delegate voiceCallbackDidAnswer:self];
        }
        
        // Check to make sure that the disconnect is based on the chat channel and not another channel
        // before calling disconnect.
        else if ((message.channelState == ECSChannelStateDisconnected) &&
                 [message.channelId isEqualToString:self.currentChannelId] &&
                 [self.delegate respondsToSelector:@selector(chatClientDisconnected:)])
        {
            [self.delegate chatClientDisconnected:self];
        }
    }
    else
    {
        ECSLogError(@"Unable to parse channel state message %@", serializationError);
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
            [self.delegate chatClient:self didReceiveMessage:message];
        }
        else
        {
            ECSLogError(@"Unable to parse chat state message %@", serializationError);
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
            [self.delegate chatClient:self didReceiveMessage:message];
        }
        else
        {
            ECSLogError(@"Unable to parse chat form message %@", serializationError);
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
            [self.delegate chatClient:self didReceiveMessage:message];
        }
        else
        {
            ECSLogError(@"Unable to parse chat state message %@", serializationError);
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
            [self.delegate chatClient:self didAddChannelWithMessage:message];
        }
        else
        {
            ECSLogError(@"Unable to parse chat state message %@", serializationError);
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
            [self.delegate chatClient:self didReceiveMessage:message];
        }
        else
        {
            ECSLogError(@"Unable to parse chat message %@", serializationError);
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
            ECSLogError(@"Unable to parse chat message %@", serializationError);
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
            ECSLogError(@"Unable to parse chat message %@", serializationError);
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
            ECSLogError(@"Unable to parse chat message %@", serializationError);
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
            
            [self.delegate chatClient:self didReceiveMessage:message];
        }
        else
        {
            ECSLogError(@"Unable to parse chat message %@", serializationError);
        }
    }
    
}



@end
