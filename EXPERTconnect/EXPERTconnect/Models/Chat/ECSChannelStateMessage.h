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

// When a DISCONNECT is received, it will also pass a reason.
typedef NS_ENUM(NSInteger, ECSDisconnectReason)
{
    ECSDisconnectReasonDisconnectByParticipant,
    ECSDisconnectReasonIdleTimeout,
    ECSDisconnectReasonError,
    ECSDisconnectReasonUnknown
};

// When a DISCONNECT is received, it will also pass who terminated the chat.
typedef NS_ENUM(NSInteger, ECSTerminatedBy)
{
    ECSTerminatedByClient,
    ECSTerminatedByAssociate,
    ECSTerminatedBySystem,
    ECSTerminatedByAdmin,
    ECSTerminatedByError,
    ECSTerminatedByQueue,
    
    ECSTerminatedByUnknown
};

@interface ECSChannelStateMessage : ECSChatMessage

@property (strong, nonatomic) NSString *conversationId;
@property (strong, nonatomic) NSString *channelId;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSNumber *estimatedWait;
@property (strong, nonatomic) NSNumber *version;

@property (strong, nonatomic) NSString *disconnectReasonString;
@property (readonly, nonatomic) ECSDisconnectReason disconnectReason;

@property (strong, nonatomic) NSString *terminatedByString;
@property (readonly, nonatomic) ECSTerminatedBy terminatedBy; 

@property (readonly, nonatomic) ECSChannelState channelState;
@end
