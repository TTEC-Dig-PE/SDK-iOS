//
//  ECSStompChatClient.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSChannelStateMessage.h"
#import "ECSChatStateMessage.h"
#import "ECSChannelStateMessage.h"
#import "ECSChatVoiceAuthenticationMessage.h"
#import "ECSStompClient.h"
#import "ECSChatHistoryResponse.h"

@class ECSActionType;
@class ECSChatActionType; 
@class ECSChatAddChannelMessage;
@class ECSChatCoBrowseMessage;
@class ECSChatTextMessage;
@class ECSChatNotificationMessage;
@class ECSStompChatClient;
@class ECSConversationCreateResponse;
@class ECSChannelCreateResponse;
@class ECSChatAddParticipantMessage;
@class ECSChatRemoveParticipantMessage;
@class ECSChatFormMessage;
@class ECSChatAssociateInfoMessage;
@class ECSSendQuestionMessage;
@class ECSChatURLMessage; 
@class ECSLog;

/**
 Defines callback messages used by a chat client
 */
@protocol ECSStompChatDelegate <NSObject>

@optional

#pragma mark - Delegates 2.0 - Use these!

// New delegate 2.0 functions

/*!
 * @discussion A channel was successfully created (chat, voice callback, etc)
 * @param response The channel create response
 */
- (void) chatChannelCreated:(ECSChannelCreateResponse *)response;

/*!
 * @discussion The Stomp Websocket has successfully connected to the server.
 */
- (void) chatDidConnect;

/*!
 * @discussion The chat channel has entered the "answered" state. Expect an "addParticipant" and additional messages soon after.
 */
- (void) chatAgentDidAnswer;

/*!
 * @discussion The server is notifying this client that it will idle timeout if the user does not interact soon (send a message or start typing)
 * @param seconds The number of seconds until an idle timeout occurs.
 */
- (void) chatTimeoutWarning:(int)seconds;

/*!
 * @discussion An error has occurred with the Stomp websocket.
 * @param error Contains the error description.
 */
- (void) chatDidFailWithError:(NSError *)error;

/*!
 * @discussion The server is notifying the client of a disconnect. This could be an idle timeout or an agent disconnection (or error).
 * @param message The channelStateMessage object. Important fields: terminatedBy (agent, system), disconnectReason (idleTimeout, disconnectByParticipant)
 */
- (void) chatDisconnectedWithMessage:(ECSChannelStateMessage *)message;

/*!
 * @discussion A participant (usually an associate) has sent a regular chat message.
 * @param message The ECSChatTextMessage object. Important fields: from, body, timestamp.
 */
- (void) chatReceivedTextMessage:(ECSChatTextMessage *)message;

/*!
 * @discussion An associate has sent their info message.
 * @param message The ECSChatAssociateInfoMessage object. Important fields: from, timestamp, message.
 */
- (void) chatReceivedAssociateInfo:(ECSChatAssociateInfoMessage *)message;

/*!
 * @discussion An associate has sent their info message.
 * @param message The ECSChatAssociateInfoMessage object. Important fields: from, timestamp, message.
 */
- (void) chatReceivedInlineForm:(ECSChatFormMessage *)message;

/*!
 * @discussion An associate has sent their info message.
 * @param message The ECSChatAssociateInfoMessage object. Important fields: from, timestamp, message.
 */
- (void) chatReceivedQuestion:(ECSSendQuestionMessage *)message;

/*!
 * @discussion An associate has sent their info message.
 * @param message The ECSChatAssociateInfoMessage object. Important fields: from, timestamp, message.
 */
- (void) chatReceivedURL:(ECSChatURLMessage *)message;

/*!
 * @discussion A participant has sent a chat state update. This typically indicates the operator on the other side is typing or not.
 * @param stateMessage The ECSChatStateMessage object. Important fields: chatState (ECSChatStateTypingPaused, ECSChatStateComposing)
 */
- (void) chatReceivedChatStateMessage:(ECSChatStateMessage *)stateMessage;

/**
 @discussion Called when a chat client receives a message from the chat server
 @param notificationMessage the notification message received from the server. Important fields: from, type (eg "pdf), objectData (eg the PDF file)
 */
- (void) chatReceivedNotificationMessage:(ECSChatNotificationMessage *)notificationMessage;

/*!
 * @discussion The server has sent a channel state update. This is a catch-all for many channel state updates, such as "answered", and "disconnected". This is called in addition to the other helper delegate calls (chatAgentDidAnswer or chatDisconnectedWithMessage). This could be used to handle all of those channel state updates in one place.
 * @param stateMessage the ECSChannelStateMessage object. Important fields: channelState, terminatedBy, disconnectReason.
 */
- (void) chatReceivedChannelStateMessage:(ECSChannelStateMessage *)stateMessage;

/*!
 * @discussion A participant has joined the chat. In the normal case, this would be an associate joining the chat. It could also be a second associate joining after a transfer or consult operation.
 * @param participant Contains details on the joininig participant. Important fields: userId, avatarURL, firstname, lastname
 */
- (void) chatAddedParticipant:(ECSChatAddParticipantMessage *)participant;

/*!
 * @discussion A participant has left the chat. In the normal case, this would be an associate leaving the chat. It could also be a second associate leaving after a transfer or consult operation.
 * @param participant Contains details on the exiting participant. Important fields: userId, avatarURL, firstname, lastname
 */
- (void) chatRemovedParticipant:(ECSChatRemoveParticipantMessage *)participant;

/**
 @discussion Called when the estimated wait time is updated.
 @param seconds the estimated wait time in seconds
 */
- (void) chatUpdatedEstimatedWait:(int)seconds;

/**
 @discussion Called when the chat client receives an add channel message.
 @param message the add channel message
 */
- (void) chatAddChannelWithMessage:(ECSChatAddChannelMessage*)message;


#pragma mark - Delegates 1.0 - Soon to be deprecated

/**
 @discussion Called when a chat client connects to the chat server.
 @param stompClient the chat client that connected
 */
- (void)chatClientDidConnect:(ECSStompChatClient *)stompClient;

/**
 @discussion Called when an agent answers the voice call.
 @param stompClient the chat client that had an agent answer
 */
//- (void)voiceCallbackDidAnswer:(ECSStompChatClient *)stompClient;

/**
 @discussion Called when an agent answers the chat call.
 @param stompClient the chat client that had an agent answer
 */
- (void)chatClientAgentDidAnswer:(ECSStompChatClient *)stompClient;

/**
 @discussion Called when a timeout warning is received.
 */
-(void) chatClientTimeoutWarning:(ECSStompChatClient *)stompClient timeoutSeconds:(int)seconds;


/**
 @discussion Called when a client disconnects.
 @param stompClient the chat client that had an agent disconnect
 */
- (void)chatClientDisconnected:(ECSStompChatClient *)stompClient wasGraceful:(bool)graceful
__attribute__((deprecated("Use chatClientDisconnected:withReason:")));

- (void)chatClient:(ECSStompChatClient *)stompClient disconnectedWithMessage:(ECSChannelStateMessage *)message;

/**
 @discussion Called when the estimated wait time is updated.
 @param stompClient the chat client that is returning the wait time.
 @param waitTime the estimated wait time in minutes
 */
- (void)chatClient:(ECSStompChatClient *)stompClient didUpdateEstimatedWait:(NSInteger)waitTime;

/**
 @discussion Called when a chat client fails to connect to the chat server.
 @param stompClient the chat client that failed
 @param error the error returned by the failure
 */
- (void)chatClient:(ECSStompChatClient *)stompClient didFailWithError:(NSError *)error;

/**
 @discussion Called when a chat client receives a message from the chat server
 @param stompClient the chat client that connected
 @param message the chat message received from the server
 */
- (void)chatClient:(ECSStompChatClient *)stompClient didReceiveMessage:(ECSChatMessage*)message;

/**
 @discussion Called when the chat client receives a state update from the chat server
 @param stompClient the chat client that received the state change
 @param state the updated state
 */
- (void)chatClient:(ECSStompChatClient *)stompClient didReceiveChatStateMessage:(ECSChatStateMessage*)state;

/**
 @discussion Called when the chat client receives an add channel message.
 @param stompClient the chat client that received the state change
 @param message the add channel message
 */
- (void)chatClient:(ECSStompChatClient *)stompClient didAddChannelWithMessage:(ECSChatAddChannelMessage*)message;

/**
 @discussion Called when a chat client receives a message from the chat server
 @param stompClient the chat client that received notification message
 @param notificationMessage the notification message received from the server
 */
- (void)chatClient:(ECSStompChatClient *)stompClient didReceiveChatNotificationMessage:(ECSChatNotificationMessage*)notificationMessage;

/**
 @discussion Called when a chat client receives a channel state message from the chat server
 @param stompClient the chat client that received notification message
 @param channelStateMessage the channel message received from the server
 */
- (void)chatClient:(ECSStompChatClient *)stompClient didReceiveChannelStateMessage:(ECSChannelStateMessage *)channelStateMessage;

@end



/**
 ECSStompChatClient is a chat client that sits on top of an ECSStompClient instance and handles
 messaging at a higher level of abstraction than the STOMP protocol.
 */
@interface ECSStompChatClient : NSObject

@property (weak, nonatomic)     id<ECSStompChatDelegate>        delegate;

@property (readonly)            ECSChatState                    chatState;
@property (readonly)            ECSChannelState                 channelState;
@property (strong, nonatomic)   ECSChannelCreateResponse        *channel;
@property (strong, nonatomic)   ECSConversationCreateResponse   *currentConversation;

@property (strong, nonatomic)   NSString    *currentChannelId;
@property (strong, nonatomic)   NSString    *subscriptionId;
@property (strong, nonatomic)   NSString    *fromUsername;
@property (copy, nonatomic)     NSString    *lastTimeStamp;

@property (assign, nonatomic)   BOOL        lastChatMessageFromAgent;

@property (nonatomic, strong)   ECSLog      *logger;

/**
 @discussion Starts a new low-level chat session.
 @param skill The chat skill to connect with. Often a string provided by Humanify, such as "CustomerServiceReps" that contains a group of associates who recieve the chats.
 @param theSubject This is displayed on the associate desktop client as text at the start of a chat.
 */
- (void) startChatWithSkill:(NSString *)skill
                    subject:(NSString *)theSubject;

/**
 @discussion Starts a new low-level chat session.
 @param skill The chat skill to connect with. Often a string provided by Humanify, such as "CustomerServiceReps" that contains a group of associates who recieve the chats.
 @param theSubject This is displayed on the associate desktop client as text at the start of a chat.
 @param priority Higher priority values will be fed to associates faster than lower ones.
 @param fields These data fields can be used to provide extra information to the associate. Eg: { "userType": "student" }
 */
- (void) startChatWithSkill:(NSString *)skill
                    subject:(NSString *)theSubject
                   priority:(int)priority
                 dataFields:(NSDictionary *)fields;

/**
 @discussion Starts a new low-level chat session.
 @param action This object contains a number of chat fields for customizing your low-level chat experience.
 */
- (void) startChannelWithAction:(ECSChatActionType *) action;

- (void) startVoiceCallbackWithSkill:(NSString *)skill
                             subject:(NSString *)subject
                         phoneNumber:(NSString *)phone
                            priority:(int)priority
                          dataFields:(NSDictionary *)fields;

/**
 Runs the entire chat setup for the current stomp chat client. Errors and status are sent through
 the delegate callbacks.
 
 @param actionType the action type that specifies this chat connection.
 */
//- (void)setupChatClientWithActionType:(ECSActionType*)actionType;

/**
 Connects to the specified chat host.
 
 @param host the host to connect to
 */
//- (void)connectToHost:(NSString*)host;

/**
 Disconnects from chat, closing the channel and the stomp client.
 */
- (void)disconnect;

/**
 Reconnect the API.
 */
- (void)reconnect;

/**
 Is the stomp currently connected? 
 */
-(bool) isConnected;

-(bool) isConnecting;

/**
 Sets the channel information for sending messages
 
 @param configuration the configuration for channel create response
 */
//- (void)setMessagingChannelConfiguration:(ECSChannelCreateResponse*)configuration;

/**
 Subscribes to the specified chat destination
 
 @param destination the chat destination to subscribe to
 @param subscriptionId the subscription ID to use for the subscription
 */
- (void)subscribeToDestination:(NSString*)destination
            withSubscriptionID:(NSString*)subscriptionId;

/**
 Unsubscribe from the channel
 
  @param subscriptionId the subscription ID to use for the subscription
 */
//- (void)unsubscribeWithSubscriptionID:(NSString*)subscriptionId;

- (void)unsubscribe;

/**
 Sends a chat message on the STOMP websocket connection
 
 @param message the message to send
 */
- (void)sendChatMessage:(ECSChatMessage*)message;

/**
 Sends a notification that an image has been uploaded to the server.
 */
- (void)sendNotificationMessage:(ECSChatNotificationMessage *)message;

/**
 Sends a notification that cobrowse is set up and ready to connect
 */
- (void)sendCoBrowseMessage:(ECSChatCoBrowseMessage *)message;

/**
 @discussion Sends a chat message on the STOMP websocket connection
 
 @param messageBody The chat text to send. It will be sent from the user.
 @param completion Called after the HTTP POST completes. Response will typically echo or ACK.
 */
- (void)sendChatText:(NSString *)messageBody
          completion:(void(^)(NSString *response, NSError *error))completion;

/**
 @discussion Sends a chat message on the STOMP websocket connection
 
 @param theChatState The chat state to send. An enum with values for "composing" and "paused". 
 @param completion Called after the HTTP POST completes. Response will typically echo or ACK.
 */
- (void) sendChatState:(ECSChatState)theChatState
            completion:(void(^)(NSString *response, NSError *error))completion;

/*!
 * @discussion Sends a media file to Humanify servers. The associate should see this media on his or her display.
 * @param mediaInfo The NSDictionary media information (comes straight from Apple's didFinishPickingMediaWithInfo callback)
 * @param notify Recommended to set to YES. This causes the agent display to notify the associate a new media file has arrived.
 * @param completion Returns the response data and/or error if one is present.
 */
- (void)sendMedia:(NSDictionary *)mediaInfo
      notifyAgent:(bool)notify
       completion:(void(^)(NSString *response, NSError *error))completion;

@end
