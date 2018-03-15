//
//  ECSChatAddParticipantMessage.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatMessage.h"

@interface ECSChatAddParticipantMessage : ECSChatMessage

@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSNumber *version;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *avatarURL;

@end
