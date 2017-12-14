//
//  ECSChatVoiceAuthenticationMessage.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatMessage.h"

#import "ECSAddressableChatMessage.h"

@interface ECSChatVoiceAuthenticationMessage : ECSChatMessage <ECSAddressableChatMessage>

//@property (strong, nonatomic) NSString *conversationId;
@property (strong, nonatomic) NSString *channelId;
@property (strong, nonatomic) NSString *messageId;
@property (strong, nonatomic) NSString *from;

@end
