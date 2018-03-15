//
//  ECSFormItemText.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSFormItem.h"

/**
 Form item to allow a user to enter a single line text string
 */
@interface ECSFormItemText : ECSFormItem <NSCopying>

// Hint text to display when no answer is entered
@property(nonatomic, strong) NSString* hint;

// Whether or not the text field should be "secure" (show dots instead of entered text)
@property(nonatomic, strong) NSNumber* secure;

@end
