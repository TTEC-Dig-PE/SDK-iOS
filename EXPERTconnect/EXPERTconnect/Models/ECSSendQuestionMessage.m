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

@end
