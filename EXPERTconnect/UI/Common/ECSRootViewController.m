//
//  ECSRootViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSRootViewController.h"

#import "ECSNavigationController.h"
#import "ECSDynamicLabel.h"
#import "ECSTheme.h"
#import "ECSLocalization.h"
#import "ECSUserManager.h"
#import "ECSInjector.h"
#import "ECSLoadingView.h"
#import "ECSPreSurveyViewController.h"
#import "ECSURLSessionManager.h"
#import "UIViewController+ECSNibLoading.h"

@interface ECSRootViewController () <ECSPreSurveyDelegate>

@property (strong, nonatomic) ECSLoadingView *loadingIndicator;
@property (strong, nonatomic) UIViewController *presurveyViewController;

@property (strong, nonatomic) ECSActionType *currentHandlingActionType;

@property (strong, nonatomic) UIView            *networkUnreachableView;
@property (strong, nonatomic) ECSDynamicLabel   *networkUnreachableLabel;

@end

@implementation ECSRootViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.showFullScreenReachabilityMessage = YES;
        self.shiftUpForKeyboard = YES; 
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    self.view.backgroundColor = theme.primaryBackgroundColor;

    self.loadingIndicator = [[ECSLoadingView alloc] initWithFrame:self.view.bounds];
    self.loadingIndicator.hidesWhenStopped = YES;
    
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.loadingIndicator];
    
    NSArray *horizontalContstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[loading]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:@{@"loading": self.loadingIndicator}];
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[loading]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:@{@"loading": self.loadingIndicator}];
    
    [self.view addConstraints:horizontalContstraints];
    [self.view addConstraints:verticalConstraints];
    
    //TODO: Need to move this code to custom navigation Controller if required.
    
    if ([self.navigationController.viewControllers count] < 2 && self.navigationItem.leftBarButtonItem == nil) {
        UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:ECSLocalizedString(ECSLocalizedCloseKey, @"Close")
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(closeButtonTapped:)];
        
        self.navigationItem.leftBarButtonItem = closeButton;
    }
    
    self.navigationController.navigationBar.translucent = NO;
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateReachability:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateReachability:)
                                                 name:ECSReachabilityChangedNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ECSReachabilityChangedNotification
                                                  object:nil];
}

- (void)updateReachability:(NSNotification*)notification
{
    if (self.showFullScreenReachabilityMessage)
    {
        ECSURLSessionManager* sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
        if(sessionManager.networkReachable)
        {
            if(self.networkUnreachableView != nil)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.networkUnreachableView.alpha = 0.0;
                    self.networkUnreachableLabel.alpha = 0.0;
                    
                } completion:^(BOOL finished) {
                    [self.networkUnreachableView removeFromSuperview];
                    self.networkUnreachableView = nil;
                    
                    [self.networkUnreachableLabel removeFromSuperview];
                    self.networkUnreachableLabel = nil;
                }];
            }
        }
        else
        {
            if(self.networkUnreachableView == nil)
            {
                UIVisualEffect *blurEffect;
                blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                
                UIVisualEffectView *visualEffectView;
                visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                
                self.networkUnreachableView = visualEffectView;
                self.networkUnreachableView.translatesAutoresizingMaskIntoConstraints = NO;
                
                [self.view addSubview:self.networkUnreachableView];
                
                [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:@{ @"view": self.networkUnreachableView}]];
                
                [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:@{ @"view": self.networkUnreachableView}]];
                
                ECSDynamicLabel* label = [ECSDynamicLabel new];
                label.text = ECSLocalizedString(ECSLocalizeReachabilityErrorKey, @"Network Unreachable");
                label.textColor = [UIColor whiteColor];
                label.translatesAutoresizingMaskIntoConstraints = NO;
                label.textAlignment = NSTextAlignmentCenter;
                label.numberOfLines = 0;
                label.lineBreakMode = NSLineBreakByWordWrapping;
                self.networkUnreachableLabel = label;
                
                [self.view addSubview:self.networkUnreachableLabel];
                
                [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-20-[label]-20-|"
                                                                                                    options:0
                                                                                                    metrics:nil
                                                                                                      views:@{ @"label": label}]];
                
                [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(115)-[label]"
                                                                                                    options:0
                                                                                                    metrics:nil
                                                                                                      views:@{ @"label": label}]];
                
                self.networkUnreachableView.alpha = 0;
                self.networkUnreachableLabel.alpha = 0;
                
                [UIView animateWithDuration:0.3f animations:^{
                    
                    self.networkUnreachableView.alpha = 1.0;
                    self.networkUnreachableLabel.alpha = 1.0;
                    
                }];
            }
        }
    }
}

- (void)setLoadingIndicatorVisible:(BOOL)visible
{
    if (visible)
    {
        [self.view bringSubviewToFront:self.loadingIndicator];
        [self.loadingIndicator startAnimating];
    }
    else
    {
        [self.loadingIndicator stopAnimating];
    }
}

- (BOOL)handleAction:(ECSActionType *)actionType
{
    BOOL handled = NO;
    
    ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
    
    if (actionType.presurvey && !userManager.isUserAuthenticated)
    {
        [self handlePreSurveyAction:actionType];
        handled = YES;
    }
    
    return handled;
}

- (void)handlePreSurveyAction:(ECSActionType*)actionType
{
    self.currentHandlingActionType = actionType;
    if (actionType.presurvey != nil)
    {
        ECSPreSurveyViewController *presurvey = [ECSPreSurveyViewController ecs_loadFromNib];
        presurvey.actionType = actionType;
        presurvey.delegate = self;

        [self presentModal:presurvey withParentNavigationController:self.navigationController];
    }
}

- (void)presentModal:(UIViewController*)controller
withParentNavigationController:(UINavigationController*)navigationController
{
    [self presentModal:controller withParentNavigationController:navigationController fromViewController:self];
}

- (void)presentModal:(UIViewController*)controller
withParentNavigationController:(UINavigationController*)navigationController
  fromViewController:(UIViewController*)presenting
{
    ECSNavigationController *presentController = [[ECSNavigationController alloc] initWithRootViewController:controller];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:ECSLocalizedString(ECSLocalizedCloseKey, @"Close")
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:presentController
                                                                   action:@selector(closeButtonTapped:)];
    controller.navigationItem.leftBarButtonItem = closeButton;
    
    if (navigationController.navigationBar)
    {
        presentController.navigationBar.tintColor = navigationController.navigationBar.tintColor;
        presentController.navigationBar.barStyle = navigationController.navigationBar.barStyle;
        presentController.navigationBar.barTintColor = navigationController.navigationBar.barTintColor;
    }
    else
    {
        ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
        presentController.navigationBar.barTintColor = theme.primaryColor;
    }
    
    self.presurveyViewController = presentController;
    
    [presenting presentViewController:presentController animated:YES completion:nil];
}
     
- (void)surveyComplete
{
    [self.presurveyViewController dismissViewControllerAnimated:YES completion:nil];
    [self handleAction:self.currentHandlingActionType];
}

- (void)surveyCanceled
{
    [self.presurveyViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)closeButtonTapped:(id)sender
{
    [self.workflowDelegate endWorkFlow];
    //[self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)showMessageForError:(NSError*)error
{
    // Ensure the alert box is shown on the main thread only.
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        
        NSString *title = ECSLocalizedString(ECSLocalizeErrorKey,
                                             @"Error");
        
        // mas - Jun-15-16 - Changed to display a generic error message. 
        //NSString *message = error.userInfo[NSLocalizedDescriptionKey];
        NSString *message = ECSLocalizedString(ECSLocalizeErrorText, @"Error text");
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizedOkButton, @"OK")
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
//                                                        message:message
//                                                       delegate:nil
//                                              cancelButtonTitle:ECSLocalizedString(ECSLocalizedOkButton, @"Ok Button")
//                                              otherButtonTitles:nil];
//        [alert show];
        
    }];
}

@end
