//
//  ECSChatNotificationMessage.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSAddressableChatMessage.h"
#import "ECSChatMessage.h"
#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

@interface ECSChatNotificationMessage : ECSChatMessage <ECSJSONSerializing, ECSAddressableChatMessage>

@property (strong, nonatomic) NSString *conversationId;
@property (strong, nonatomic) NSString *channelId;
@property (strong, nonatomic) NSString *from;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *objectData;

@end
