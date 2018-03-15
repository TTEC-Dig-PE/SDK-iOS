//
//  ECSFormItemSlider.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSFormItem.h"

/**
 Form item for a slider rating
 */
@interface ECSFormItemSlider : ECSFormItem <NSCopying>

// The value of the lowest (left) end of the slider
@property(nonatomic, strong) NSNumber* minValue;

// The value for the highest (right) end of the slider
@property(nonatomic, strong) NSNumber* maxValue;

// The text to show at the low (left) end of the slider
@property(nonatomic, strong) NSString* minLabel;

// The text to show at the high (right) end of the slider
@property(nonatomic, strong) NSString* maxLabel;

@end
