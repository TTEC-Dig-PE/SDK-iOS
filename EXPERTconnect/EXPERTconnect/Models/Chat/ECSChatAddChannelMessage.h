//
//  ECSChatAddChannelMessage.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatMessage.h"

#import "ECSAddressableChatMessage.h"

@interface ECSChatAddChannelMessage : ECSChatMessage <ECSAddressableChatMessage>

//@property (strong, nonatomic) NSString *conversationId;
//@property (strong, nonatomic) NSString *channelId;
@property (strong, nonatomic) NSString *from;
@property (strong, nonatomic) NSString *mediaType;
@property (strong, nonatomic) NSString *suggestedAddress;
@property (strong, nonatomic) NSNumber *version;

@end
