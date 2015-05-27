//
//  ECSPlaceholderTextView.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 UITextView that provides placeholder text when no text is entered
 */
@interface ECSPlaceholderTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

@end
