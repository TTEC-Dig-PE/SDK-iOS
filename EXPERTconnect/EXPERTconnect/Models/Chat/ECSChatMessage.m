//
//  ECSChatMessage.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatMessage.h"

@implementation ECSChatMessage

- (NSDictionary *)ECSJSONMapping {
    
    return @{ @"date": @"timeStamp" };
}

- (id)copyWithZone:(NSZone*)zone {
    
    ECSChatMessage *message = [[self class] new];
    
    message.fromAgent       = self.fromAgent;
    message.conversationId  = self.conversationId;
    message.channelId       = self.channelId; 
    message.messageId       = self.messageId;
    message.timeStamp       = self.timeStamp;
    
    return message;
}

@end
