//
//  ECSChatAddParticipantMessage.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

/*
 "x-body-type" = RemoveParticipant;
 "x-body-version" = 1;
 }
 Body: {"version":1,"reason":"left","userId":"Wei"}
 */

#import "ECSChatMessage.h"

@interface ECSChatRemoveParticipantMessage : ECSChatMessage

@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) NSString *reason;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;

@end
