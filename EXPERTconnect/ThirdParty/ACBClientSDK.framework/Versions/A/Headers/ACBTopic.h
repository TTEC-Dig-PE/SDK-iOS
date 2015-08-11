#import <Foundation/Foundation.h>

@class ACBTopic;

/**
 This can be used for any object that intends to become the delegate of the topic object.
 By implementing the methods specified by the delegate, the user will be able to receive
 a message associated with a topic.
 */
@protocol ACBTopicDelegate <NSObject>

/**
 Called on the successful creation of a topic.
 
 Triggered as a success response as a result of the following method being called:
 
      -(ACBTopic *)createTopicWithName:(NSString *)topicName delegate:(id<ACBTopicDelegate>)delegate;
      -(ACBTopic *)createTopicWithName:(NSString *)topicName expiryTime:(int)expiryTime delegate:(id<ACBTopicDelegate>)delegate;
 
 @param topic Topic object returning the message.
 @param data Contains the key value pairs that this topic consists of.
 */
- (void)topic:(ACBTopic *)topic didConnectWithData:(NSDictionary *)data;

/**
 Called as a result of topic successfully deleted.
 
 Triggered as a success response as a result of the following method being called with deleteTopic set to YES  
      -(void)disconnectWithDeleteFlag:(BOOL)deleteTopic
 
 @param topic Topic object returning the message.
 @param message Message string that contains details on the successful delete.
 */
- (void)topic:(ACBTopic *)topic didDeleteWithMessage:(NSString *)message;

/**
 Called when data has been successfully submitted.
 
 Triggered as a success response as a result of the following method being called
 
      -(void)submitDataWithKey:(NSString*)key value:(NSString*)value
 
 @param topic Topic object returning the message.
 @param key A unique identifier which is associated with a value.
 @param value The single value that is associated to the specified key.
 @param version The version of the change - it should be incremented by one for any change that is made to this key-value pair.
 */
- (void)topic:(ACBTopic *)topic didSubmitWithKey:(NSString *)key value:(NSString *)value version:(int)version;

/**
 Called on Data successfully deleted.
 
 Triggered as a success response as a result of the following method(s) being previously called by this user:
 
      -(void) deleteDataWithKey:(NSString*)key
 
 @param topic topic object returning the message.
 @param key A unique identifier which is associated with a value.
 @param version The version of the change - it should be incremented by one for any change that is made to this key-value pair.
 */
 - (void)topic:(ACBTopic *)topic didDeleteDataSuccessfullyWithKey:(NSString *)key version:(int)version;

/**
 Called as a result of message successfully sent.
 
 Triggered as a success response as a result of the following method(s) being previously called by this user:
 
      - (void) sendAedMessage:(NSString *)aedMessage
 
 @param topic topic object returning the message.
 @param message message returning the state of the operation.
 */
- (void)topic:(ACBTopic *)topic didSendMessageSuccessfullyWithMessage:(NSString *)message;

/**
 Called as a result of not being able to connect to a topic.
 
 Triggered as a failure response as a result of the following method(s) being previously called by this user:
 
     -(ACBTopic *)createTopicWithName:(NSString *)topicName delegate:(id<ACBTopicDelegate>)delegate;
     -(ACBTopic *)createTopicWithName:(NSString *)topicName expiryTime:(int)expiryTime delegate:(id<ACBTopicDelegate>)delegate;
 
 @param topic Topic object returning the message
 @param message Message returning the state of the operation
 */
- (void)topic:(ACBTopic *)topic didNotConnectWithMessage:(NSString *)message;

/**
 Called as a result of a topic not being deleted.
 
 Triggered as a failure response as a result of the following method(s) being previously called by this user:
 
      -(void)disconnectWithDeleteFlag:(BOOL)deleteTopic with deleteTopic set to YES.
 
 @param topic Topic object returning the message
 @param message Message returning the state of the operation
 */
- (void)topic:(ACBTopic *)topic didNotDeleteWithMessage:(NSString *)message;

/**
 Called as a result of data not being submitted.
 
 Triggered as a failure response as a result of the following method(s) being previously called by this user:
 
      -(void)submitDataWithKey:(NSString*)key value:(NSString*)value
 
 @param topic Topic object returning the message
 @param key A unique identifier which is associated with a value.
 @param value The single value that is associated to the specified key.
 @param message Message returning the state of the operation
 */
- (void)topic:(ACBTopic *)topic didNotSubmitWithKey:(NSString *)key value:(NSString *)value message:(NSString *)message;

/**
 Called as a result of a topic's data failing to delete after a request for it to do so.
 
 Triggered as a failure response as a result of the following method(s) being previously called by this user:
 
      -(void)deleteDataWithKey:(NSString*)key
 
 @param topic topic object returning the message
 @param key a unique identifier which is associated with a value.
 @param message message returning the state of the operation, giving more detail on the error.  
 */
- (void)topic:(ACBTopic *)topic didNotDeleteDataWithKey:(NSString *)key message:(NSString *)message;

/**
 Called as a result of a message send failure.
 
 Triggered as a failure response as a result of the following method(s) being previously called by this user: 
 
      -(void)sendAedMessage:(NSString *)aedMessage
 
 @param topic Topic object returning the message
 @param originalMessage The message that the connected user was trying to send via the sendAedMessage.
 @param message Message returning the state of the operation, giving more detail on the error.
 */
- (void)topic:(ACBTopic *)topic didNotSendMessage:(NSString *)originalMessage message:(NSString *)message;

/**
 Called as a result of the topic expiring, or being deleted by another user that is connected to the topic.
 
 Triggered as a success response as a result of the following method being called with delete topic set to YES
 
     -(void)disconnectWithDeleteFlag:(BOOL)deleteTopic
 
 @param topic Topic object returning the message
 */
- (void)topicDidDelete:(ACBTopic *)topic;

/**
 Called when the topic is updated, by one of the users connected to the topic calling submit on the ACBTopic object.
 
 Triggered as a success response as a result of the following method being previously called
 
     -(void)submitDataWithKey:(NSString*)key value:(NSString*)value
 
 @param topic Topic object returning the message
 @param key A unique identifier which is associated with a value
 @param value A value that is retrieved via the use of the unique key.
 @param version The version of the change - it should be incremented by one for any change that is made to this key-value pair.
 @param deleted Whether or not the topic has been deleted.
 */
- (void)topic:(ACBTopic *)topic didUpdateWithKey:(NSString *)key value:(NSString *)value version:(int)version deleted:(BOOL)deleted;

/**
 Called as a result of message successfully received.
 
 Triggered as a success response as a result of the following method(s) being previously called by any user:
 
     - (void) sendAedMessage:(NSString *)aedMessage
 
 @param topic Topic object returning the message
 @param message Message that was received.
 */
- (void)topic:(ACBTopic *)topic didReceiveMessage:(NSString *)message;

@end

/**
 A representation of a single Topic within AED. This object allows
 the publishing and accessing of data within the topic, and provides
 a delegate protocol to notify a registered object with request results 
 and update notifications
 */
@interface ACBTopic : NSObject

/**
 The object that conforms to the delegate protocol and receives callbacks
 */
@property (nonatomic, weak) id<ACBTopicDelegate>delegate;

/**
 The name of the topic (which also uniquely identifies the topic) - set when creating a topic using ACBClientAED's createTopic method
 */
@property (readonly) NSString* name;

/**
 Connected state of the topic - YES if connected, NO if not
 */
@property (readonly) BOOL connected;

/**
 Disconnects from a topic. Does not delete the topic or it's data.
 */
- (void) disconnect;

/**
 Disconnects from a topic and optionally deletes the topic at the same time.

 @param deleteTopic Whether or not to delete the topic and it's data, as well as disconnect from it.
 */- (void) disconnectWithDeleteFlag:(BOOL)deleteTopic;

/**
 Submits data to a topic.
 
 @param key A unique identifier which is associated with a value.
 @param value The single value that is associated to the specified key.
 *
 */- (void) submitDataWithKey:(NSString*)key value:(NSString*)value;

/**
 Deletes data from a topic.
 
 @param key A unique identifier which is associated with a value.
 */
- (void) deleteDataWithKey:(NSString*)key;

/**
 Sends a custom message that will be received by any subscribers to the specified topic.

 @param aedMessage Message to send 
 */
- (void) sendAedMessage:(NSString *)aedMessage;

@end
