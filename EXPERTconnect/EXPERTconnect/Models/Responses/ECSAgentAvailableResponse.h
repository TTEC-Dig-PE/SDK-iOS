//
//  ECSAgentAvailableResponse.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"
//#import "ECSConversationLink.h"

/**
 Response returnec when a journey is created.
 */
@interface ECSAgentAvailableResponse : ECSJSONObject <ECSJSONSerializing>

// The last date the journey was modified.
@property (strong, nonatomic) NSString *lastModifiedDate;

// The date the journey expires
@property (strong, nonatomic) NSString *expirationDate;

// ???
@property (strong, nonatomic) NSString *conversationCount;

// The creation date for the journey
@property (strong, nonatomic) NSString *creationDate;

// ???
@property (strong, nonatomic) NSString *organization;

// The journey ID for the newly started Journey
@property (strong, nonatomic) NSString *journeyID;

// Self reference
@property (strong, nonatomic) NSString *selfLink;

// Link used to subscribe to and post messages
@property (strong, nonatomic) NSString *conversationLink;

@end
