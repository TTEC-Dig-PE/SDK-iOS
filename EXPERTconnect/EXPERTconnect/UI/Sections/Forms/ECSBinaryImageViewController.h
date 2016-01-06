//
//  ECSBinaryImageViewController.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSFormItemViewController.h"
#import "ECSDynamicLabel.h"

/**
 * View controller for presenting a radio (single select) form item. Expected to be
 * used as a child view controller of ECSFormViewController
 */
@interface ECSBinaryImageViewController : ECSFormItemViewController

@property (weak, nonatomic) IBOutlet UIButton *rightButton;
- (IBAction)rightButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *leftButton;
- (IBAction)leftButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet ECSDynamicLabel *captionLabel;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *questionLabel;

@end
