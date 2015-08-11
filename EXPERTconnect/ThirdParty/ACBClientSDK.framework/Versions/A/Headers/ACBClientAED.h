#import <Foundation/Foundation.h>
#import "ACBTopic.h"
/**
 A representation of the AED object which is accessible through an ACBUC instance.
 The ACBClientAED instance allows data sharing between users by creation of topics to which
 data can be added.
 */
@interface ACBClientAED : NSObject

/**
 Creates and connects to a topic. A user will then be able to use the topic object in order to add, remove data,
 receive updates and send messages to the topic.
 
 @param topicName Name of topic, which is also a unique identifier for the topic.
 @param delegate The topic delegate.
 */
-(ACBTopic *)createTopicWithName:(NSString *)topicName delegate:(id<ACBTopicDelegate>)delegate;

/**
 Creates a topic with an expiry time and then connects to it. A user will then be able to use the topic object in order to add, remove data,
 receive updates and send messages to the topic.
 
 @param topicName Name of topic, which is also a unique identifier for the topic.
 @param expiryTime Amount of time until the ACBTopic object expires on the server.
 @param delegate The topic delegate.
 */
-(ACBTopic *)createTopicWithName:(NSString *)topicName expiryTime:(int)expiryTime delegate:(id<ACBTopicDelegate>)delegate;

@end
