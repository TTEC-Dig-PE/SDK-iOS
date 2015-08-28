//
//  ECSWorkflowNavigation.m
//  EXPERTconnect
//
//  Created by Sam Solomon on 8/17/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSWorkflowNavigation.h"
#import "ECSViewControllerStack.h"
#import "ECSWorkflow.h"

#import "ECSCafeXController.h"

#import "ECSURLSessionManager.h"
#import "ECSImageCache.h"
#import "ECSInjector.h"
#import "ECSTheme.h"
#import "ECSUserManager.h"
#import "ECSLocalization.h"

#import "NSBundle+ECSBundle.h"
#import "UIViewController+ECSNibLoading.h"
#import "ECSAnswerEngineViewController.h"

@interface ECSWorkflowNavigation ()

@property (nonatomic, weak) UIViewController *hostViewController;
@property (nonatomic, strong) ECSViewControllerStack *modalStack;

@property (nonatomic, strong) UINavigationController *navigationController;

@property (nonatomic, strong) UIView *dimmingOverlay;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UIButton *minimizedButton;

@end

@implementation ECSWorkflowNavigation

- (instancetype)initWithHostViewController:(UIViewController *)hostViewController {
    self = [super init];
    if (self) {
        _hostViewController = hostViewController;
        _modalStack = [ECSViewControllerStack new];
        [self addDimmingOverlay];
        [self addContainerView];
    }
    return self;
}

#pragma mark - Dimming Overlay

- (void)addDimmingOverlay {
    self.dimmingOverlay = [UIView new];
    [self.dimmingOverlay setBackgroundColor:[UIColor blackColor]];
    [self.dimmingOverlay setAlpha:0.0];
    [self.hostViewController.view addSubview:self.dimmingOverlay];
    [self addDimmingOverlayConstraints];
}

- (void)addContainerView {
    self.containerView = [UIView new];
    [self.hostViewController.view addSubview:self.containerView];
    [self addContainerViewConstraints];
}

- (void)addDimmingOverlayConstraints {
    
    UIView *dimmingOverlay = self.dimmingOverlay;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(dimmingOverlay);
    
    NSArray *h = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[dimmingOverlay]|"
                                                         options:0
                                                         metrics:nil
                                                           views:views];
    NSArray *v = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[dimmingOverlay]|"
                                                         options:0
                                                         metrics:nil
                                                           views:views];
    
    [self.dimmingOverlay setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.hostViewController.view addConstraints:h];
    [self.hostViewController.view addConstraints:v];
}

- (void)addContainerViewConstraints {
    
    UIView *containerView = self.containerView;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(containerView);
    
    NSArray *h = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[containerView]|"
                                                         options:0
                                                         metrics:nil
                                                           views:views];
    NSArray *v = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[containerView]|"
                                                         options:0
                                                         metrics:nil
                                                           views:views];
    
    [self.containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.hostViewController.view addConstraints:h];
    [self.hostViewController.view addConstraints:v];
}

#pragma mark - Present/Dismiss methods

- (void)presentViewControllerInNavigationControllerModally:(UIViewController *)viewController
                                                  animated:(BOOL)shouldAnimate
                                                completion:(completionBlock)completion {
    
    if (self.navigationController) {
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [self presentViewControllerModally:navController animated:YES completion:completion];
        self.navigationController = navController;
    }
    
}

- (void)presentViewControllerModally:(UIViewController *)viewController
                            animated:(BOOL)shouldAnimate
                          completion:(completionBlock)completion {
    
    CGSize modalSize = [self modalSize];
    UIView *newView = viewController.view;
    UIView *hostView = self.containerView;
    [self.hostViewController addChildViewController:viewController];
    [hostView addSubview:newView];
    
    //constraints
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:newView
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeNotAnAttribute
                                                            multiplier:1.0 constant:modalSize.width];
    
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:newView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0 constant:modalSize.height];
    
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:hostView
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:newView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0.0];
    
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:hostView
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:newView
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.0
                                                                constant:0.0];
    
    [newView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [hostView addConstraints:@[centerX, centerY]];
    [newView addConstraints:@[width, height]];
    
    // visuals
    newView.layer.cornerRadius = [self modalBorderRadius];
    newView.layer.borderWidth = [self modalBorderWidth];
    newView.layer.borderColor = [[self modalBorderColor] CGColor];
    newView.clipsToBounds = YES;
    
    // animate
    CGFloat dimmingAlpha = ([self.modalStack viewControllerCount] + 1) * [self modalOverlayDimmingFactor];
    
    [self.containerView setHidden:NO];
    newView.transform = CGAffineTransformMakeTranslation(0, 1000);
    
    [UIView
     animateWithDuration: shouldAnimate ? [self modalAnimationDuration] : 0.0f
     animations:^{
         newView.transform = CGAffineTransformMakeTranslation(0, 0);
         [self.dimmingOverlay setAlpha:dimmingAlpha];
     }
     completion:^(BOOL finished) {
         
         [self.hostViewController didMoveToParentViewController:viewController];
         [self.modalStack pushViewController:viewController];
         if (completion) completion();
     }];
}

- (void)dismissViewControllerModallyAnimated:(BOOL)shouldAnimate
                                  completion:(completionBlock)completion {
    
    UIViewController *viewController = [self.modalStack popViewController];
    
    // animate out
    CGFloat dimmingAlpha = [self.modalStack viewControllerCount] * [self modalOverlayDimmingFactor];
    
    [UIView
     animateWithDuration: shouldAnimate ? [self modalAnimationDuration] : 0.0f
     animations:^{
         viewController.view.transform = CGAffineTransformMakeTranslation(0, 1000);
         [self.dimmingOverlay setAlpha:dimmingAlpha];
     }
     completion:^(BOOL finished) {
         
         // remove child view controller
         [viewController willMoveToParentViewController:nil];
         [viewController.view removeFromSuperview];
         [viewController removeFromParentViewController];
         
         if ([self.modalStack isEmpty]) {
             [self.containerView setHidden:YES];
         }
         
         if (completion) completion();
     }];
}

- (void)dismissAllViewControllersAnimated:(BOOL)shouldAnimate
                               completion:(completionBlock)completion {
    while ( [self.modalStack viewControllerCount] > 0 ) {
        [self dismissViewControllerModallyAnimated:shouldAnimate completion:completion];
    };
}

- (void)displayAlertForActionType:(NSString *)actionType completion:(void (^)(BOOL selected))completion {
    NSString *alertTitle = @"Video Chat";
    NSString *alertMsg = @"Please try a video chat With an Agent";
    if ([actionType isEqualToString:ECSRequestChatAction]) {
        alertTitle = @"Chat With Agent";
        alertMsg = @"Please try a chat with agent";
    } else if ([actionType isEqualToString:ECSRequestCallbackAction]) {
        alertTitle = @"Voice Callback";
        alertMsg = @"Please try talking with an agent";
    }
    
    UIAlertController *workflowNameController = [UIAlertController alertControllerWithTitle:alertTitle message:alertMsg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertActionStop = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [workflowNameController dismissViewControllerAnimated:YES completion:^{
            if (completion) {
                completion(NO);
            }
        }];
        
    }];
    
    UIAlertAction *alertActionContinue = [UIAlertAction actionWithTitle:@"Start Video Chat" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (completion) {
            completion(YES);
        }
    }];
    
    [workflowNameController addAction:alertActionStop];
    [workflowNameController addAction:alertActionContinue];
    [[self.modalStack topViewController] presentViewController:workflowNameController animated:YES completion:nil];
}

#pragma mark - Minimize Restore

- (void)minmizeAllViewControllersWithCompletion:(completionBlock)completion {
    
    // take screenshot
    UIView *viewToDraw = [[[self modalStack] topViewController] view];
    UIGraphicsBeginImageContextWithOptions(viewToDraw.bounds.size, NO, [UIScreen mainScreen].scale);
    [viewToDraw drawViewHierarchyInRect:viewToDraw.bounds afterScreenUpdates:YES];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *targetImage = [UIImage imageNamed:@"avatar"];
    
    // make minimize button
    self.minimizedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.minimizedButton.layer.borderWidth = [self modalBorderWidth];
    self.minimizedButton.layer.borderColor = [[self modalBorderColor] CGColor];
    self.minimizedButton.layer.cornerRadius = [self modalBorderRadius];
    self.minimizedButton.clipsToBounds = YES;
    [self.minimizedButton addTarget:self
                             action:@selector(maxmimizeButtonTapped:)
                   forControlEvents:UIControlEventTouchUpInside];
    [self.containerView.superview addSubview:self.minimizedButton];
    
    // animate
    self.minimizedButton.frame = viewToDraw.bounds;
    self.minimizedButton.center = self.containerView.center;
    [self.containerView setAlpha:0.0];
    
    [UIView
     animateWithDuration: [self modalAnimationDuration]
     animations:^{
         [self.dimmingOverlay setAlpha:0.0];
         self.minimizedButton.frame = CGRectMake(0, 0, targetImage.size.width, targetImage.size.width);
         self.minimizedButton.center = [self minimizePosition];
     }
     completion:^(BOOL finished) {
         if (completion) completion();
     }];
    
    // animate image transition
    //self.minimizedButton.screenshotImage = screenshot;
    //self.minimizedButton.minimizedImage = targetImage;
    //[self.minimizedButton transitionToScreenshotWithDuration:0.0];
    //[self.minimizedButton transitionToMinimizedImageWithDuration:[self modalAnimationDuration]];
}

- (void)restoreAllViewControllersWithCompletion:(completionBlock)completion {
    
    // animate out
    CGFloat dimmingAlpha = [self.modalStack viewControllerCount] * [self modalOverlayDimmingFactor];
    CGSize modalSize = [self modalSize];
    
    [UIView
     animateWithDuration: [self modalAnimationDuration]
     animations:^{
         [self.dimmingOverlay setAlpha:dimmingAlpha];
         self.minimizedButton.frame = CGRectMake(0, 0, modalSize.width, modalSize.height);
         self.minimizedButton.center = self.containerView.center;
     }
     completion:^(BOOL finished) {
         [self.containerView setAlpha:1.0];
         [self.minimizedButton removeFromSuperview];
         self.minimizedButton = nil;
         
         if (completion) completion();
     }];
}

- (void)maxmimizeButtonTapped:(id)sender {
    [self restoreAllViewControllersWithCompletion:nil];
}

- (CGPoint)minimizePosition {
    return CGPointMake(72, 144);
}

#pragma mark - Modal VC Parameters

- (CGSize)modalSize {
    return CGSizeMake(500, 500);
}

- (UIColor *)modalBorderColor {
    return [UIColor darkGrayColor];
}

- (CGFloat)modalBorderWidth {
    return 2.0f;
}

- (CGFloat)modalAnimationDuration {
    return 0.5f;
}

- (CGFloat)modalOverlayDimmingFactor {
    return 0.2f;
}

- (CGFloat)modalBorderRadius {
    return 10.0f;
}

@end
