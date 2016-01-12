//
//  ECSTopQuestionsViewController.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "ECSRootViewController.h"

@class ECSTopQuestionsViewController;

@protocol ECSTopQuestionsViewControllerDelegate <NSObject>

- (void)controller:(ECSTopQuestionsViewController*)controller didSelectQuestion:(NSString*)question;

@end

@interface ECSTopQuestionsViewController : ECSRootViewController

@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;
@property (weak, nonatomic) IBOutlet UITableView *faqTableView;

@property (weak, nonatomic) id<ECSTopQuestionsViewControllerDelegate> delegate;

-(void)reloadTableData;

@end
