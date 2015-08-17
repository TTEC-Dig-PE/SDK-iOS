//
//  ECSCafeXMessage.h
//  EXPERTconnect
//
//  Created by Nathan Keeney on 8/13/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatMessage.h"

#import "ECSAddressableChatMessage.h"

@interface ECSCafeXMessage : ECSChatMessage <ECSAddressableChatMessage>

@property (strong, nonatomic) NSString *conversationId;
@property (strong, nonatomic) NSString *channelId;
@property (strong, nonatomic) NSString *messageId;
@property (strong, nonatomic) NSString *from;
@property (strong, nonatomic) NSString *start;
@property (strong, nonatomic) NSString *parameter1;
@property (strong, nonatomic) NSString *parameter2;
@property (strong, nonatomic) NSString *guid;

@end
