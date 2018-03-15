//
//  ECSFormItemTextArea.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSFormItemTextArea.h"

@implementation ECSFormItemTextArea

- (NSDictionary*)ECSJSONMapping
{
    NSMutableDictionary* mapping = [[super ECSJSONMapping] mutableCopy];
    
    [mapping addEntriesFromDictionary:@{
                                        @"configuration.hint": @"hint",
                                        }];
    
    return mapping;
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSFormItemTextArea *formItem = [super copyWithZone:zone];
    formItem.hint = [self.hint copy];
    
    return formItem;
}

-(BOOL)answered
{
    return self.formValue.length > 0;
}

@end
