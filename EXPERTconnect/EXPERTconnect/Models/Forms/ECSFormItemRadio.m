//
//  ECSFormItemRadio.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSFormItemRadio.h"

@implementation ECSFormItemRadio

- (NSDictionary*)ECSJSONMapping
{
    NSMutableDictionary* mapping = [[super ECSJSONMapping] mutableCopy];
    
    [mapping addEntriesFromDictionary:@{
                                        @"configuration.options": @"options"
                                        }];
    
    return mapping;
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSFormItemRadio *formItem = [super copyWithZone:zone];
    formItem.options = [[NSArray alloc] initWithArray:self.options copyItems:YES];
    
    return formItem;
}

- (BOOL)answered
{
    return self.formValue.length > 0;
}

@end
