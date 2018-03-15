//
//  ECSChatFormMessage.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatFormMessage.h"

#import "ECSFormActionType.h"

@implementation ECSChatFormMessage

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *jsonMapping = [[super ECSJSONMapping] mutableCopy];
    
    [jsonMapping addEntriesFromDictionary:@{
                                            @"conversationId": @"conversationId",
                                            @"channelId": @"channelId",
                                            @"from": @"from",
                                            @"formName": @"formName",
                                            @"formContents": @"formContents",
                                            @"version": @"version"
                                            }];
    return jsonMapping;
}

- (NSDictionary *)ECSJSONTransformMapping
{
    return @{@"formContents": [ECSForm class]};
}

- (ECSFormActionType *)formActionType
{
    ECSFormActionType *formActionType = [ECSFormActionType new];
    
    formActionType.form = self.formContents;
    
    return formActionType;
}
@end
