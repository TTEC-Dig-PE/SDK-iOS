//
//  ECSConversationLink.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

/**
 ECSConversationLink defines the structure of a link returned by channel or conversation creation.
 */
@interface ECSConversationLink : ECSJSONObject <ECSJSONSerializing>

// The type of link
@property (strong, nonatomic) NSString *linkType;

// The URL of the link.
@property (strong, nonatomic) NSString *URL;

@end
