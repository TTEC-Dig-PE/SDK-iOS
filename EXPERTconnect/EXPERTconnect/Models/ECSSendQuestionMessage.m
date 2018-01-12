//
//  ECSSendQuestionMessage.m
//  EXPERTconnect
//
//  Created by Ken Washington on 8/20/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSSendQuestionMessage.h"

@implementation ECSSendQuestionMessage

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *jsonMapping = [[super ECSJSONMapping] mutableCopy];
    
    [jsonMapping addEntriesFromDictionary:@{
                                            @"questionText": @"questionText",
                                            @"channelId": @"channelId",
                                            @"version": @"version",
                                            @"conversationId": @"conversationId",
                                            @"interfaceName": @"interfaceName",
                                            @"from": @"from",
                                            }];
    return jsonMapping;
}

- (id)copyWithZone:(NSZone*)zone
{
    ECSSendQuestionMessage *message = [[[self class] allocWithZone:zone] init];
    message.conversationId = [self.conversationId copyWithZone:zone];
    message.channelId = [self.channelId copyWithZone:zone];
    message.from = [self.from copyWithZone:zone];
    message.version = [self.version copyWithZone:zone];
    message.questionText = [self.questionText copyWithZone:zone];
    message.interfaceName = [self.interfaceName copyWithZone:zone];

    return message;
}

@end
