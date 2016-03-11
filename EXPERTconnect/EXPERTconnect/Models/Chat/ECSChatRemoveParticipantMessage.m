//
//  ECSChatAddParticipantMessage.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatRemoveParticipantMessage.h"

@implementation ECSChatRemoveParticipantMessage

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *jsonMapping = [[super ECSJSONMapping] mutableCopy];
    
    [jsonMapping addEntriesFromDictionary:@{
                                            @"reason": @"reason",
                                            @"userId": @"userId",
                                            @"version": @"version",
                                            @"fullname": @"fullname",
                                            @"firstName": @"firstName",
                                            @"lastName": @"lastName"
                                            }];

    return jsonMapping;
}

@end
