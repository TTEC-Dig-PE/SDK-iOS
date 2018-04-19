//
//  ECSFormItemTextArea.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSFormItem.h"

/**
 Form item for a user to enter multiple lines of text
 */
@interface ECSFormItemTextArea : ECSFormItem <NSCopying>

// Text displayed when no answer is entered
@property(nonatomic, strong) NSString* hint;

@end
