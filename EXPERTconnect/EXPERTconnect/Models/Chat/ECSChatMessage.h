//
//  ECSChatMessage.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

@interface ECSChatMessage : ECSJSONObject <NSCopying, ECSJSONSerializing>

@property (assign, nonatomic) BOOL      fromAgent;
@property (strong, nonatomic) NSString  *conversationId;
@property (strong, nonatomic) NSString  *channelId;
@property (strong, nonatomic) NSString  *messageId;
@property (strong, nonatomic) NSString  *timeStamp;

@end
