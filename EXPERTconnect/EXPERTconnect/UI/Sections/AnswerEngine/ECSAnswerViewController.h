//
//  ECSAnswerViewController.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECSAnswerEngineResponse.h"

@protocol ECSAnswerViewControllerDelegate <NSObject>

- (BOOL)navigateToPreviousAnswer;
- (BOOL)navigateToNextAnswer;

- (void)askSuggestedQuestion:(NSString*)suggestedQuestion;
- (void)didRateAnswer:(ECSAnswerEngineResponse*)answer withRating:(int)rating;

- (void)isReadyToRemoveFromParent:(UIViewController*)controller;

@end

@interface ECSAnswerViewController : UIViewController

@property (strong, nonatomic) ECSAnswerEngineResponse *answer;

@property (weak, nonatomic) id<ECSAnswerViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) BOOL showPullToPrevious;
@property (assign, nonatomic) BOOL showPullToNext;

@property (assign, nonatomic) UIEdgeInsets edgeInsets;

@end
