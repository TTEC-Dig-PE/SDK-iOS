//
//  ECSChatFormMessage.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatMessage.h"

#import "ECSAddressableChatMessage.h"
#import "ECSForm.h"

@class ECSFormActionType;

@interface ECSChatFormMessage : ECSChatMessage <ECSAddressableChatMessage>

@property (strong, nonatomic) NSString *conversationId;
@property (strong, nonatomic) NSString *channelId;
@property (strong, nonatomic) NSString *from;
@property (strong, nonatomic) NSString *formName;
@property (strong, nonatomic) ECSForm *formContents;
@property (strong, nonatomic) NSString *comment;
@property (strong, nonatomic) NSNumber *version;

@property (readonly, nonatomic) ECSFormActionType *formActionType;

@end
