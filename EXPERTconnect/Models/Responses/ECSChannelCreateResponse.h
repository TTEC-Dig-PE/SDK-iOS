//
//  ECSChannelCreateResponse.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"
#import "ECSConversationLink.h"

/**
 Response returnec when a channel is created.
 */
@interface ECSChannelCreateResponse : ECSJSONObject <ECSJSONSerializing>

// The ID of the channel
@property (strong, nonatomic) NSString *channelId;

// The ID of the conversation
@property (strong, nonatomic) NSString *conversationId;

// The media type for the conversation
@property (strong, nonatomic) NSString *mediaType;

// The creation date for the channel
@property (strong, nonatomic) NSString *creationDate;

// The last date the channel was modified.
@property (strong, nonatomic) NSString *lastModifiedDate;

// The date the channel expires
@property (strong, nonatomic) NSString *expirationDate;

// The current state of the channel
@property (strong, nonatomic) NSString *state;

// Link used to retrieve chat state
@property (strong, nonatomic) NSString *chatStateLink;

// Link used to close the channel
@property (strong, nonatomic) NSString *closeLink;

// Link used to subscribe to and post messages
@property (strong, nonatomic) NSString *messagesLink;

// Link used to subscribe to and post messages
@property (strong, nonatomic) NSString *stompMessagesLink;

// Self reference
@property (strong, nonatomic) NSString *selfLink;

// Estimated wait time to be connected to an agent
@property (strong, nonatomic) NSNumber *estimatedWait;
@end
