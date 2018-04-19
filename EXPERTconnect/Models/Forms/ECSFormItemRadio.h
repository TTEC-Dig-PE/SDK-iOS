//
//  ECSFormItemRadio.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSFormItem.h"

/**
 Form item for a radio / single options selection.
 */
@interface ECSFormItemRadio : ECSFormItem <NSCopying>

// An array of string options that the user can choose
@property(nonatomic, strong) NSArray* options;

@end
