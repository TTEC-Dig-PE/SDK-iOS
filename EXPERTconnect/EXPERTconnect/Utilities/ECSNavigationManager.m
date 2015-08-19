//
//  ECSNavigationManager.m
//  EXPERTconnect
//
//  Created by Sam Solomon on 8/17/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSNavigationManager.h"
#import "ECSModalPresentation.h"
#import "ECSModalStackManager.h"

@interface ECSNavigationManager ()

@property (nonatomic, weak) UIViewController *hostViewController;
@property (nonatomic, strong) ECSModalStackManager *modalStack;

@property (nonatomic, strong) UIView *dimmingOverlay;
@property (nonatomic, strong) UIView *containerView;

@end

@implementation ECSNavigationManager

- (void)kickOffOnViewController:(UIViewController *)hostViewController {
    _hostViewController = hostViewController;
    _modalStack = [ECSModalStackManager new];
    [self addDimmingOverlay];
    [self addContainerView];
}

#pragma mark - Dimming Overlay & Container View

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

- (void)presentViewControllerModally:(UIViewController *)viewController
                            animated:(BOOL)shouldAnimate
        wrapWithNavigationController:(BOOL)wrapWithNavigationController
                          completion:(completionBlock)completion {
    
    if(wrapWithNavigationController) {
        viewController = [self wrapWithNavigationController:viewController];
    }
    
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
    newView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    newView.clipsToBounds = YES;
    
    // animate
    CGFloat initialAlpha = self.dimmingOverlay.alpha;
    CGFloat finalAlpha = initialAlpha + [self modalOverlayDimmingFactor];
    
    [self.dimmingOverlay setAlpha:initialAlpha];
    [self.containerView setHidden:NO];
    newView.transform = CGAffineTransformMakeTranslation(0, 1000);
    
    [UIView
     animateWithDuration: shouldAnimate ? [self modalAnimationDuration] : 0.0f
     animations:^{
         newView.transform = CGAffineTransformMakeTranslation(0, 0);
         [self.dimmingOverlay setAlpha:finalAlpha];
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
    CGFloat initialAlpha = self.dimmingOverlay.alpha;
    CGFloat finalAlpha = initialAlpha - [self modalOverlayDimmingFactor];
    
    [UIView
     animateWithDuration: shouldAnimate ? [self modalAnimationDuration] : 0.0f
     animations:^{
         viewController.view.transform = CGAffineTransformMakeTranslation(0, 1000);
         [self.dimmingOverlay setAlpha:finalAlpha];
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

#pragma mark - Modal VC Parameters

- (CGSize)modalSize {
    return CGSizeMake(500, 500);
}

- (UIColor *)modalBorderColor {
    return [UIColor darkGrayColor];
}

- (CGFloat)modalBorderWidth {
    return 1.0f;
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

#pragma mark - Convenience Methods


-(UINavigationController *)wrapWithNavigationController:(UIViewController *)viewController {
    
    UINavigationController *navigationController = [[UINavigationController alloc]init];
    [navigationController setViewControllers:@[viewController]];
    return navigationController;
}

@end
