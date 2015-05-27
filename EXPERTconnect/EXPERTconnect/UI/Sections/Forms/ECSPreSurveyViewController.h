//
//  ECSPreSurveyViewController.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECSActionType.h"
#import "ECSRootViewController.h"

/**
 Survey delegate protocol
 */
@protocol ECSPreSurveyDelegate <NSObject>

/**
 Called when the survey had been successfully completed.
 */
- (void)surveyComplete;

/**
 Called when the user taps the close button on the survey.
 */
- (void)surveyCanceled;

@end

/**
 View controller for handling the presurveys.
 */
@interface ECSPreSurveyViewController : ECSRootViewController <UITextFieldDelegate>

// Delegate for survey callbacks
@property (weak, nonatomic) id<ECSPreSurveyDelegate> delegate;

@end
