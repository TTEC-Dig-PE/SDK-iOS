//
//  ECSAnswerEngineActionType.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSAnswerEngineActionType.h"

@implementation ECSAnswerEngineActionType

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.type = ECSActionTypeAnswerEngineString;
    }
    
    return self;
}


- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *mapping = [[NSMutableDictionary alloc] initWithDictionary:[super ECSJSONMapping]];
    
    [mapping addEntriesFromDictionary:@{
                                        @"configuration.defaultQuestions": @"defaultQuestions",
                                        @"configuration.topQuestions": @"topQuestions",
                                        @"configuration.actions": @"actions",
                                        @"configuration.answerEngineContext": @"answerEngineContext"
                                        }];
                                        
    
    return mapping;
}

- (NSDictionary *)ECSJSONTransformMapping
{
    return @{@"configuration.answerEngineContext": [ECSActionTypeClassTransformer class]};
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSAnswerEngineActionType *actionType = [super copyWithZone:zone];
    
    actionType.defaultQuestion = [self.defaultQuestion copyWithZone:zone];
    actionType.topQuestions = [[NSArray alloc] initWithArray:self.topQuestions copyItems:YES];
    actionType.actions = [[NSArray alloc] initWithArray:self.actions copyItems:YES];
    actionType.answerEngineContext = [self.answerEngineContext copyWithZone:zone];
    
    return actionType;
}

@end
