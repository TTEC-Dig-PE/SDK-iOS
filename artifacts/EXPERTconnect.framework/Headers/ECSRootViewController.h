//
//  ECSRootViewController.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <EXPERTconnect/ECSActionType.h>

/**
 ECSRootViewController is the base view controller used within the framework.  It provides common
 properties and utilities used across all of the UI elements.
 */
@interface ECSRootViewController : UIViewController

// The action type that is displayed by this view controller
@property (nonatomic, strong) ECSActionType *actionType;

@property (nonatomic, strong) NSString *parentNavigationContext;

// Indicates if a full screen reachability message should be displayed.  Defaults to YES.
@property (nonatomic, assign) BOOL showFullScreenReachabilityMessage;

/**
 Sets the loading indicator visible or invisible.
 
 @param visible specifies if the loading indicator is currently visible.
 */
- (void)setLoadingIndicatorVisible:(BOOL)visible;

/**
 Handles the specified action type.
 
 @param actionType the action to handle
 
 @return YES if the action had been handled, NO if this class did not handle the action.
 */
- (BOOL)handleAction:(ECSActionType *)actionType;

/**
 Handles the presurvey in the specified action type.  If the presurvey is completed successfully, 
 this view controller will then call handleAction again for the view controller to handle the 
 action post-authentication.
 
 @param actionType the action type containing the presurvey
 */
 
- (void)handlePreSurveyAction:(ECSActionType*)actionType;

/**
 Presents a view controller modaly, presenting from the parent navigation controller
 if specified
 
 @param controller the controller to present
 @param navigationController to controller to present from
 */
- (void)presentModal:(UIViewController*)controller withParentNavigationController:(UINavigationController*)navigationController;


- (void)presentModal:(UIViewController*)controller
withParentNavigationController:(UINavigationController*)navigationController
  fromViewController:(UIViewController*)presenting;

/** 
 * Shows a standard error dialog for the specified error.
 *
 * @param error the error to show
 */
- (void)showMessageForError:(NSError*)error;

- (void)closeButtonTapped:(id)sender;
@end
