//
//  ECSStompClient.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ECSStompClient;

/**
 ECSStompFrame defines the basic frame structure for communicating over the STOMP protocol.
 */
@interface ECSStompFrame : NSObject

// The STOMP command type
@property (strong, nonatomic) NSString* command;

// Dictionary of STOMP headers to be used with the command
@property (strong, nonatomic) NSMutableDictionary *headers;

// The optional body for the command
@property (strong, nonatomic) NSString *body;

@end

/**
 The ECSStompDelegate defines methods that are called when asynchronous STOMP messages are 
 received.
 */
@protocol ECSStompDelegate <NSObject>

@optional

/**
 Called when the STOMP client receives a CONNECTED message from the server.
 
 @param stompClient the reference to the client that received the CONNECTED message
 */
- (void)stompClientDidConnect:(ECSStompClient *)stompClient;

- (void)stompClientDidDisconnect:(ECSStompClient *)stompClient; 

/**
 Called when the STOMP client fails to connect.
 
 @param stompClient the client that received the error message.
 @param error the error returned by the server
 */
- (void)stompClient:(ECSStompClient *)stompClient didFailWithError:(NSError *)error;

/**
 Called when the STOMP client receives a MESSAGE type.
 
 @param stompClient the client that received the message.
 @param message the STOMP frame containing the message.
 */
- (void)stompClient:(ECSStompClient *)stompClient didReceiveMessage:(ECSStompFrame*)message;

@end




/**
 The ECSStompClient implements the base level STOMP protocol as defined by https://stomp.github.io/.
 This client connects via a websocket to the specified host.
 */
@interface ECSStompClient : NSObject

// Indicates if the client is currently connected.
@property (assign, nonatomic) BOOL connected;

// The delegate for receiving asynchronous messages.
@property (weak, nonatomic) id<ECSStompDelegate> delegate;

@property (strong, nonatomic) NSString *authToken;

@property (strong, nonatomic) NSTimer *heartbeatTimer;

/**
 Connect to the specified STOMP host.  Upon successful connection the ECSStompDelegate will be sent 
 the stompClientDidConnect: message
 
 @param host the host to connect to
 */
- (void)connectToHost:(NSString*)host;

/**
 Disconnect from the current host
 */
- (void)disconnect;

/** 
 Reconnects to a host
 */
- (void)reconnect;

- (void)setAuthToken:(NSString *)token;

/**
 Subscribe for asynchronous messages on the specified destination with the given subscriber ID.
 
 @param destination the destination to subscribe to
 @param subscriptionID the id to use for the subscription
 @param subscriber the ECSStompDelegate used to receive messages.
 */
- (void)subscribeToDestination:(NSString*)destination
            withSubscriptionID:(NSString*)subscriptionID
                    subscriber:(__weak id<ECSStompDelegate>)subscriber;

/** 
 Unsubscribes from messages using the given subscription ID
 
 @param subscriptionID the identifier of the subscription to unsubscribe
 */
- (void)unsubscribe:(NSString*)subscriptionID;

/**
 Sends an ACK message to the STOMP server.
 
 @param messageId the message identifier to ACK
 @param transationId the optional transaction identifier to ACK
 */
- (void)sendAckForMessage:(NSString*)messageId andTransaction:(NSString*)transactionId;

/**
 Sends a NACK message to the STOMP server.
 
 @param messageId the message identifier to NCK
 @param transationId the optional transaction identifier to NACK
 */
- (void)sendNackForMessage:(NSString*)messageId andTransaction:(NSString*)transactionId;

/**
 Starts a STOMP transaction with the specified transaction ID.
 
 @param transactionId the identifier of the transaction to start
 */
- (void)startTransaction:(NSString*)transactionId;

/**
 Commits a STOMP transaction with the specified transaction ID.
 
 @param transactionId the identifier of the transaction to commit
 */
- (void)commitTransaction:(NSString*)transactionId;

/**
 Aborts a STOMP transaction with the specified transaction ID.
 
 @param transactionId the identifier of the transaction to abort
 */
- (void)abortTransaction:(NSString*)transactionId;

/**
 Sends a message to the specified destination using the specified contentType
 
 @param message the UTF-8 encoded message to send
 @param destination the destination to send the message to
 @param contentType the content type of the message (usually text/plain)
 @param additionalHeaders any additional STOMP headers to add to the message
 */
- (void)sendMessage:(NSString *)message
      toDestination:(NSString*)destination
        contentType:(NSString*)contentType
  additionalHeaders:(NSDictionary *)additionalHeaders;

@end
