//
//  ECSFormItemCheckbox.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSFormItem.h"

/**
 Checkbox / Multiselect form item
 */
@interface ECSFormItemCheckbox : ECSFormItem <NSCopying>

// Array of string options that the user can choose from. 
@property(nonatomic, strong) NSArray* options;

@end
