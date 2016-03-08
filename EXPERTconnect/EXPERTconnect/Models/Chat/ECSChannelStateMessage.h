//
//  ECSChannelStateMessage.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatMessage.h"

typedef NS_ENUM(NSUInteger, ECSChannelState)
{
    ECSChannelStateDisconnected,
    ECSChannelStateConnected,
    ECSChannelStatePending,
    ECSChannelStateAnswered,
    ECSChannelStateQueued,
    ECSChannelStateNotify,
    ECSChannelStateFailed,
    ECSChannelStateTimeout,
    ECSChannelStateUnknown
};

@interface ECSChannelStateMessage : ECSChatMessage

@property (strong, nonatomic) NSString *conversationId;
@property (strong, nonatomic) NSString *channelId;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSNumber *estimatedWait;
@property (strong, nonatomic) NSNumber *version;

@property (readonly, nonatomic) ECSChannelState channelState;
@end
