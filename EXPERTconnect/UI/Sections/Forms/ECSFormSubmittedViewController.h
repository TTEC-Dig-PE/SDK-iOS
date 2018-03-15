//
//  ECSFormSubmittedViewController.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECSButton.h"
#import "ECSDynamicLabel.h"
#import "ECSRootViewController.h"

@protocol ECSFormSubmittedViewDelegate <NSObject>

- (void) closeTappedInSubmittedView:(id)sender;

@end

@interface ECSFormSubmittedViewController : ECSRootViewController

@property(nonatomic, weak) id<ECSFormSubmittedViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet ECSDynamicLabel *headerLabel;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet ECSButton *closeButton;

@end
