//
//  ECSFormActionType.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSFormActionType.h"

#import "ECSForm.h"

@implementation ECSFormActionType

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.type = ECSActionTypeFormString;
    }
    
    return self;
}

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *mapping = [[NSMutableDictionary alloc] initWithDictionary:[super ECSJSONMapping]];
    
    [mapping addEntriesFromDictionary:@{
                                        @"configuration": @"form"
                                        }];
    
    
    return mapping;
}

- (NSDictionary*)ECSJSONTransformMapping
{
    NSMutableDictionary *mapping = [[NSMutableDictionary alloc] initWithDictionary:[super ECSJSONTransformMapping]];
    
    [mapping addEntriesFromDictionary:@{
                                        @"configuration": [ECSForm class]
                                        }];
    
    
    return mapping;
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSFormActionType *actionType = [super copyWithZone:zone];
    
    actionType.form = [self.form copyWithZone:zone];
    
    return actionType;
}

@end
