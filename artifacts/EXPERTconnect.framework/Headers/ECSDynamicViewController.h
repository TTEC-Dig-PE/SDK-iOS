//
//  ECSDynamicViewController.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECSRootViewController.h"

@class ECSNavigationContext;

/**
 The ECSDynamicViewController displays a ECSNavigationContext and its related dynamic view structure.
 */
@interface ECSDynamicViewController : ECSRootViewController <UITextFieldDelegate>

// The navigation context to display
@property (strong, nonatomic) ECSNavigationContext *navigationContext;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
