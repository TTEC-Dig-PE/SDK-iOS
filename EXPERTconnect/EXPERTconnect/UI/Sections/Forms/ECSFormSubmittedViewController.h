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


@interface ECSFormSubmittedViewController : ECSRootViewController

@property (weak, nonatomic) IBOutlet ECSDynamicLabel *headerLabel;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet ECSButton *closeButton;

@end
