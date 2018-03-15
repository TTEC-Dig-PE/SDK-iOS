//
//  ECSChatActionType.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <EXPERTconnect/EXPERTconnect.h>

@interface ECSVideoChatActionType : ECSChatActionType <NSCopying>

/* CafeX Modes:
 
 - 'videoauto' Video auto start [mutually exclusive with voice auto, and voice/video escalation]
 - 'voiceauto' Voice auto start [mutually exclusive with video auto, and voice/video escalation]
 - 'videocapable' Video escalation allowed [mutually exclusive with voice and video auto start]
 - 'voicecapable' Voice escalation allowed [mutually exclusive with voice and video auto start]
 - 'cobrowsecapable' CafeX Co-Browse escalation allowed (existing Co-Browse Button w/software switch)
 */

// CafeX Video mode
@property (strong, nonatomic) NSString *cafexmode;

// CafeX Video target
@property (strong, nonatomic) NSString *cafextarget;

@end
