//
//  ECSInlineFormViewController.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECSForm.h"

@protocol ECSInlineFormViewControllerDelegate <NSObject>

- (void)formCompleteWithItem:(ECSForm*)formItem;

@end

@interface ECSInlineFormViewController : UIViewController

@property (nonatomic, strong) ECSForm *form;
@property (nonatomic, weak) id<ECSInlineFormViewControllerDelegate> delegate;

- (CGFloat)preferredHeight;

@end
