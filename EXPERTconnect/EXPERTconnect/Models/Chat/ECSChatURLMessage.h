//
//  ECSChatURLMessage.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatMessage.h"

#import "ECSAddressableChatMessage.h"

@interface ECSChatURLMessage : ECSChatMessage <ECSAddressableChatMessage>

@property (strong, nonatomic) NSString *conversationId;
@property (strong, nonatomic) NSString *channelId;
@property (strong, nonatomic) NSString *from;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *urlType;
@property (strong, nonatomic) NSString *comment;
@property (strong, nonatomic) NSNumber *version;


@end
