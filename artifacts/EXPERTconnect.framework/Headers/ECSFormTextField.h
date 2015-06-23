//
//  ECSFormTextField.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE @interface ECSFormTextField : UITextField

// Item identifier for the field returned by the form.
@property (strong, nonatomic) NSString *itemId;

// Metadata for the item shown in the form field
@property (strong, nonatomic) NSString *metadata;

// Indicates if the form field is required
@property (assign, nonatomic) BOOL required;

@end
