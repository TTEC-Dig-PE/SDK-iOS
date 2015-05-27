//
//  ECSConverstaionCreateResponse.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

#import "ECSConversationLink.h"

/**
 Response object from a conversation creation
 */
@interface ECSConversationCreateResponse : ECSJSONObject <ECSJSONSerializing>

// The number of channels in the conversation
@property (strong, nonatomic) NSNumber *channelCount;

// The identifier for the conversation
@property (strong, nonatomic) NSString *conversationID;

// The identifier for the journey
@property (strong, nonatomic) NSString *journeyID;

// The conversation location
@property (strong, nonatomic) NSString *location;

// The device ID that created the conversation
@property (strong, nonatomic) NSString *deviceID;

// The creation date of the conversation
@property (strong, nonatomic) NSString *creationDate;

// The conversation last modified date
@property (strong, nonatomic) NSString *lastModifiedDate;

// The conversation expiration date
@property (strong, nonatomic) NSString *expirationDate;

// The current state of the conversation
@property (strong, nonatomic) NSString *state;

// Link to retrieve channels from
@property (strong, nonatomic) NSString *channelLink;

// Link used to close a conversation
@property (strong, nonatomic) NSString *closeLink;

// Journey information
@property (strong, nonatomic) NSString *journeyLink;

// Reference to this conversation
@property (strong, nonatomic) NSString *selfLink;

@end
