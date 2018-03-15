////
////  ECSStompCallbackClient.h
////  EXPERTconnect
////
////  Created by Nathan Keeney on 10/8/15.
////  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//
//#import <Foundation/Foundation.h>
//
//#import "ECSChannelStateMessage.h"
//#import "ECSChatStateMessage.h"
//#import "ECSChatVoiceAuthenticationMessage.h"
//
//@class ECSActionType;
//@class ECSChatAddChannelMessage;
//@class ECSChatCoBrowseMessage;
//@class ECSChatTextMessage;
//@class ECSChatNotificationMessage;
//@class ECSStompChatClient;
//@class ECSStompCallbackClient;
//@class ECSConversationCreateResponse;
//@class ECSChannelCreateResponse;
//@class ECSChatAddParticipantMessage;
//@class ECSLog;
//
///**
// Defines callback messages used by a chat client
// */
//@protocol ECSStompCallbackDelegate <NSObject>
//
//@optional
//
///**
// Called when a chat client connects to the chat server.
// 
// @param stompClient the chat client that connected
// */
//- (void)chatClientDidConnect:(ECSStompCallbackClient *)stompClient;
//
///**
// Called when an agent answers the voice call.
// 
// @param stompClient the chat client that had an agent answer
// */
//- (void)voiceCallbackDidAnswer:(ECSStompCallbackClient *)stompClient;
//
///**
// Called when a client disconnects.
// 
// @param stompClient the chat client that had an agent disconnect
// */
//- (void)chatClientDisconnected:(ECSStompCallbackClient *)stompClient wasGraceful:(bool)graceful;
////__attribute__((deprecated("Use chatClientDisconnected:withReason:")));
//
//- (void)chatClient:(ECSStompCallbackClient *)stompClient disconnectedWithMessage:(ECSChannelStateMessage *)message;
//
///**
// Called when a chat client fails to connect to the chat server.
// 
// @param stompClient the chat client that failed
// @param error the error returned by the failure
// */
//- (void)chatClient:(ECSStompCallbackClient *)stompClient didFailWithError:(NSError *)error;
//
///**
// Called when the chat client receives a state update from the chat server
// 
// @param stompClient the chat client that received the state change
// @param state the updated state
// */
//- (void)chatClient:(ECSStompCallbackClient *)stompClient didReceiveChatStateMessage:(ECSChatStateMessage*)state;
//
///**
// Called when the chat client receives an add channel message.
// 
// @param stompClient the chat client that received the state change
// @param message the updated state
// */
//- (void)chatClient:(ECSStompCallbackClient *)stompClient didAddChannelWithMessage:(ECSChatAddChannelMessage*)message;
//
//@end
//
///**
// ECSStompChatClient is a chat client that sits on top of an ECSStompClient instance and handles
// messaging at a higher level of abstraction than the STOMP protocol.
// */
//@interface ECSStompCallbackClient : NSObject
//
//// Delegate to receive asynchronous messages on
//@property (weak, nonatomic) id<ECSStompCallbackDelegate> delegate;
//
//@property (readonly) ECSChatState chatState;
//@property (readonly) ECSChannelState channelState;
//
//@property (strong, nonatomic) NSString *currentChannelId;
//
//@property (strong, nonatomic) ECSChannelCreateResponse *channel;
//@property (strong, nonatomic) ECSConversationCreateResponse *currentConversation;
//
//@property (strong, nonatomic) NSString *fromUsername;
//
//@property (nonatomic, strong) ECSLog *logger;
//
///**
// Runs the entire chat setup for the current stomp chat client. Errors and status are sent through
// the delegate callbacks.
// 
// @param actionType the action type that specifies this chat connection.
// */
//- (void)setupChatClientWithActionType:(ECSActionType*)actionType;
//
///**
// Connects to the specified chat host.
// 
// @param host the host to connect to
// */
//- (void)connectToHost:(NSString*)host;
//
///**
// Disconnects from chat, closing the channel and the stomp client.
// */
//- (void)disconnect;
//
///**
// Reconnect the API.
// */
//- (void)reconnect;
//
///**
// Sets the channel information for sending messages
// 
// @param configuration the configuration for channel create response
// */
//- (void)setMessagingChannelConfiguration:(ECSChannelCreateResponse*)configuration;
//
///**
// Subscribes to the specified chat destination
// 
// @param destination the chat destination to subscribe to
// @param subscriptionId the subscription ID to use for the subscription
// */
//- (void)subscribeToDestination:(NSString*)destination withSubscriptionID:(NSString*)subscriptionId;
//
//
//@end

