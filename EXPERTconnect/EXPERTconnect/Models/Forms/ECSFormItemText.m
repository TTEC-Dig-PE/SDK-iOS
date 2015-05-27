//
//  ECSFormItemText.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSFormItemText.h"

@implementation ECSFormItemText

- (NSDictionary*)ECSJSONMapping
{
    NSMutableDictionary* mapping = [[super ECSJSONMapping] mutableCopy];
    
    [mapping addEntriesFromDictionary:@{
                                        @"configuration.hint": @"hint",
                                        @"configuration.secure": @"secure"
                                        }];
    
    return mapping;
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSFormItemText *formItem = [super copyWithZone:zone];
    formItem.hint = [self.hint copy];
    formItem.secure = [self.secure copy];
    
    return formItem;
}


-(BOOL)answered
{
    return self.formValue.length > 0;
}

@end
