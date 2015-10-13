//
//  ECSStompCallbackClient.m
//  EXPERTconnect
//
//  Created by Nathan Keeney on 10/8/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.

#import "ECSStompCallbackClient.h"

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

@interface ECSStompCallbackClient() <ECSStompDelegate>

@property (strong, nonatomic) ECSActionType *actionType;
@property (strong, nonatomic) ECSStompClient *stompClient;

@property (strong, nonatomic) NSString *sendMessageDestination;
@property (strong, nonatomic) NSString *sendNotificationDestination;
@property (strong, nonatomic) NSString *sendCoBrowseDestination;

@property (assign, nonatomic) NSInteger agentInteractionCount;

@property (weak, nonatomic) NSURLSessionTask *currentNetworkTask;

@property (assign, nonatomic) BOOL isReconnecting;

@end

@implementation ECSStompCallbackClient

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
    
    // Setup without a Conversation
    NSLog(@"Setting up StompChatClient with non-chat Action Type");
    [self connectToHost:urlSession.hostName];
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
    NSString *fullDestination = [NSString stringWithFormat:@"/topic/conversations.%@", destination];
    
    [self.stompClient subscribeToDestination:fullDestination
                          withSubscriptionID:subscriptionId
                                  subscriber:self];
}

- (void)unsubscribeWithSubscriptionID:(NSString*)subscriptionId;
{
    [self.stompClient unsubscribe:subscriptionId];
}

#pragma mark - ECSStompClient

- (void)stompClientDidConnect:(ECSStompClient *)stompClient
{
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
    
    if ([self.delegate respondsToSelector:@selector(chatClientDidConnect:)])
    {
        [self.delegate chatClientDidConnect:self];
    }
}


- (void)stompClient:(ECSStompClient *)stompClient didReceiveMessage:(ECSStompFrame *)message
{
    NSString *bodyType = message.headers[kECSHeaderBodyType];
    
    if ([bodyType isEqualToString:kECSChatStateMessage])
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
    else if ([bodyType isEqualToString:kECSChatAddChannelMessage])
    {
        [self handleAddChannelMessage:message forClient:stompClient];
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
        
        // NK 6/24 check for a voice callback channel
        if ((message.channelState == ECSChannelStateConnected) &&
            [message.channelId isEqualToString:self.currentChannelId] &&
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



@end
