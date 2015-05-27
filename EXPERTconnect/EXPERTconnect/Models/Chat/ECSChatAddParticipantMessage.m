//
//  ECSChatAddParticipantMessage.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatAddParticipantMessage.h"

@implementation ECSChatAddParticipantMessage

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *jsonMapping = [[super ECSJSONMapping] mutableCopy];
    
    [jsonMapping addEntriesFromDictionary:@{
                                            @"fullName": @"fullName",
                                            @"userId": @"userId",
                                            @"version": @"version",
                                            @"firstName": @"firstName",
                                            @"lastName": @"lastName",
                                            @"avatarUrl": @"avatarURL",
                                            }];
    return jsonMapping;
}

@end
