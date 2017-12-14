//
//  ECSChatStateMessage.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSAddressableChatMessage.h"
#import "ECSChatMessage.h"
#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

typedef NS_ENUM(NSUInteger, ECSChatState)
{
    ECSChatStateUnknown,
    ECSChatStateTypingPaused,
    ECSChatStateComposing
};

/**
 ECSChatStateMessage represents a state message over the STOMP chat protocol
 */
@interface ECSChatStateMessage : ECSChatMessage <ECSAddressableChatMessage>

//@property (strong, nonatomic) NSString *conversationId;
@property (strong, nonatomic) NSString *channelId;
@property (strong, nonatomic) NSString *from;
@property (strong, nonatomic) NSString *to;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSNumber *version;
@property (strong, nonatomic) NSString *object;
@property (strong, nonatomic) NSString *type; 

@property (readonly, nonatomic) ECSChatState chatState;

@end
