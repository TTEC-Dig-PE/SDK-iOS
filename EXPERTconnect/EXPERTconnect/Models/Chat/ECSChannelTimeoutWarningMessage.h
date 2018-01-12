//
//  ECSChannelTimeoutWarningMessage.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSAddressableChatMessage.h"
#import "ECSChatMessage.h"
#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

/**
 ECSChannelTimeoutWarningMessage represents a state message over the STOMP chat protocol
 */
@interface ECSChannelTimeoutWarningMessage : ECSChatMessage <ECSAddressableChatMessage>

//@property (strong, nonatomic) NSString *conversationId;
//@property (strong, nonatomic) NSString *channelId;
@property (strong, nonatomic) NSNumber *version;
@property (strong, nonatomic) NSString *timeoutSeconds;

@property (strong, nonatomic) NSString *from;
//@property (strong, nonatomic) NSString *to;
//@property (strong, nonatomic) NSString *state;
//@property (strong, nonatomic) NSString *object;
//@property (strong, nonatomic) NSString *type;

@end
