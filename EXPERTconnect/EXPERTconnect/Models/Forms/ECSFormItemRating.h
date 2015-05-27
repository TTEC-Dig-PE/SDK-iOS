//
//  ECSFormItemRating.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSFormItem.h"

/**
 Form item for providing a star / rating
 */
@interface ECSFormItemRating : ECSFormItem <NSCopying>

// The max rating a user can assign. Defines the number of unfilled stars that are shown in the form item.
@property(nonatomic, strong) NSNumber* maxValue;

@end
