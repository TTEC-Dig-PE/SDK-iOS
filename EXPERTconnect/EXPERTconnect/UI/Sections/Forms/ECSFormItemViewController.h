//
//  ECSFormItemViewController.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECSFormItem.h"

@class ECSFormItemViewController;

@protocol ECSFormItemViewControllerDelegate <NSObject>

@required

// Fired when a Form Item's answer has changed. When an answer is not a string (for example when it is a number), answer will be nil.
-(void)formItemViewController:(ECSFormItemViewController*)vc answerDidChange:(NSString*)answer forFormItem:(ECSFormItem*)formItem;

@end

/**
 Base (abstract) view controller for displaying a FormItem.
 */
@interface ECSFormItemViewController : UIViewController

@property(nonatomic, weak) id<ECSFormItemViewControllerDelegate> delegate;

// The form item being displayed
@property(nonatomic, strong) ECSFormItem* formItem;

// The default caption text for most form items. If a Form Item is required, this defaults to "Required" Otherwise it is "Optional".
- (NSString*)defaultCaptionText;

// Create a derived ECSFormItemViewController based on the provided formItem
+ (ECSFormItemViewController*)viewControllerForFormItem:(ECSFormItem*)formItem;

@end
