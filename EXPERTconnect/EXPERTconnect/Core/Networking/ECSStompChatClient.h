//
//  ECSStompChatClient.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSChannelStateMessage.h"
#import "ECSChatStateMessage.h"

@class ECSActionType;
@class ECSChatAddChannelMessage;
@class ECSChatTextMessage;
@class ECSChatNotificationMessage;
@class ECSStompChatClient;
@class ECSConversationCreateResponse;
@class ECSChannelCreateResponse;
@class ECSChatAddParticipantMessage;

/**
 Defines callback messages used by a chat client
 */
@protocol ECSStompChatDelegate <NSObject>

@optional

/**
 Called when a chat client connects to the chat server.
 
 @param stompClient the chat client that connected
 */
- (void)chatClientDidConnect:(ECSStompChatClient *)stompClient;

/**
 Called when an agent answers the chat call.
 
 @param stompClient the chat client that had an agent answer
 */
- (void)chatClientAgentDidAnswer:(ECSStompChatClient *)stompClient;

/**
 Called when a client disconnects.
 
 @param stompClient the chat client that had an agent disconnect
 */
- (void)chatClientDisconnected:(ECSStompChatClient *)stompClient;

/**
 Called when the estimated wait time is updated.
 
 @param stompClient the chat client that is returning the wait time.
 @param waitTime the estimated wait time in minutes
 */
- (void)chatClient:(ECSStompChatClient *)stompClient didUpdateEstimatedWait:(NSInteger)waitTime;

/**
 Called when a chat client fails to connect to the chat server.
 
 @param stompClient the chat client that failed
 @param error the error returned by the failure
 */
- (void)chatClient:(ECSStompChatClient *)stompClient didFailWithError:(NSError *)error;

/**
 Called when a chat client receives a message from the chat server
 
 @param stompClient the chat client that connected
 @param the chat message received from the server
 */
- (void)chatClient:(ECSStompChatClient *)stompClient didReceiveMessage:(ECSChatMessage*)message;

/**
 Called when the chat client receives a state update from the chat server
 
 @param stompClient the chat client that received the state change
 @param state the updated state
 */
- (void)chatClient:(ECSStompChatClient *)stompClient didReceiveChatStateMessage:(ECSChatStateMessage*)state;

/**
 Called when the chat client receives an add channel message.
 
 @param stompClient the chat client that received the state change
 @param state the updated state
 */
- (void)chatClient:(ECSStompChatClient *)stompClient didAddChannelWithMessage:(ECSChatAddChannelMessage*)message;

@end

/**
 ECSStompChatClient is a chat client that sits on top of an ECSStompClient instance and handles
 messaging at a higher level of abstraction than the STOMP protocol.
 */
@interface ECSStompChatClient : NSObject

// Delegate to receive asynchronous messages on
@property (weak, nonatomic) id<ECSStompChatDelegate> delegate;

@property (readonly) ECSChatState chatState;
@property (readonly) ECSChannelState channelState;

@property (strong, nonatomic) NSString *currentChannelId;

@property (strong, nonatomic) ECSChannelCreateResponse *channel;
@property (strong, nonatomic) ECSConversationCreateResponse *currentConversation;

@property (strong, nonatomic) NSString *fromUsername;

/**
 Runs the entire chat setup for the current stomp chat client. Errors and status are sent through
 the delegate callbacks.
 
 @param actionType the action type that specifies this chat connection.
 */
- (void)setupChatClientWithActionType:(ECSActionType*)actionType;

/**
 Connects to the specified chat host.
 
 @param host the host to connect to
 */
- (void)connectToHost:(NSString*)host;

/**
 Disconnects from chat, closing the channel and the stomp client.
 */
- (void)disconnect;

/**
 Reconnect the API.
 */
- (void)reconnect;

/**
 Sets the channel information for sending messages
 
 @param configuration the configuration for channel create response
 */
- (void)setMessagingChannelConfiguration:(ECSChannelCreateResponse*)configuration;

/**
 Subscribes to the specified chat destination
 
 @param destination the chat destination to subscribe to
 @param subscriptionID the subscription ID to use for the subscription
 */
- (void)subscribeToDestination:(NSString*)destination withSubscriptionID:(NSString*)subscriptionId;

/**
 Sends a chat message on the STOMP websocket connection
 
 @param message the message to send
 */
- (void)sendChatMessage:(ECSChatMessage*)message;

/**
 Sends a notification that an image has been uploaded to the server.
 */
- (void)sendNotificationMessage:(ECSChatNotificationMessage *)message;

@end
