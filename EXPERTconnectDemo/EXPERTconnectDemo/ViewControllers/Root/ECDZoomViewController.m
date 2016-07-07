//
//  ECDZoomViewController.m
//  EXPERTconnectDemo
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECDZoomViewController.h"
#import <objc/runtime.h>
#import "AppConfig.h"

#import "ECDDefaultTheme.h"

static const char *ECDZoomViewControllerKey = "ECDZoomViewControllerKey";

@implementation UIViewController (ECDZoomViewController)

- (ECDZoomViewController *)ecd_zoomViewController
{
    ECDZoomViewController *panNavigationController = objc_getAssociatedObject(self, &ECDZoomViewControllerKey);
    if (!panNavigationController)
    {
        panNavigationController = [[self parentViewController] ecd_zoomViewController];
    }
    
    return panNavigationController;
}

- (void)setEcd_zoomViewController:(ECDZoomViewController *)ecd_zoomViewController
{
    objc_setAssociatedObject(self, &ECDZoomViewControllerKey, ecd_zoomViewController, OBJC_ASSOCIATION_ASSIGN);
}

@end

@interface ECDZoomViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *contentContainerView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *showContentButton;

@property (nonatomic, assign) CGFloat leftViewSlideOffset;
@property (nonatomic, assign) CGFloat leftViewParallax;
@property (nonatomic, assign) CGFloat contentContainerXOffset;
@property (strong, nonatomic) UIScreenEdgePanGestureRecognizer *screenEdgeGestureRecognizer;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, assign) CGFloat startPanPosition;

@end

@implementation ECDZoomViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

#pragma mark - UIViewController Overrides
- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.leftViewSlideOffset = 240.0f;
    self.leftViewParallax = 0.5f;
    
    [self.leftView.layer setTransform:CATransform3DMakeTranslation(-self.leftViewSlideOffset, 0, 0)];

    self.screenEdgeGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureDidPan:)];
    [self.screenEdgeGestureRecognizer setEdges:UIRectEdgeLeft];
    [self.view addGestureRecognizer:self.screenEdgeGestureRecognizer];
    [self.screenEdgeGestureRecognizer setDelegate:self];
    
    [self.panGestureRecognizer requireGestureRecognizerToFail:self.screenEdgeGestureRecognizer];
    
    [self.contentContainerView setBackgroundColor:[UIColor whiteColor]];
    
    
    [[self.contentContainerView layer] setShadowOffset:CGSizeMake(0.0f, 0.0f)];
    [[self.contentContainerView layer] setShadowColor:[[UIColor blackColor] CGColor]];
    [[self.contentContainerView layer] setShadowOpacity:0.25f];
    [[self.contentContainerView layer] setShadowRadius:10.0f];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:[self.contentContainerView bounds]];
    [[self.contentContainerView layer] setShadowPath:[path CGPath]];

    [self.leftView setBackgroundColor:[UIColor clearColor]];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.84f green:0.84f blue:0.84f alpha:1]];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [[self childViewControllerForStatusBarStyle] preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden
{
    return (self.contentContainerXOffset > 0);
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:[self.contentContainerView bounds]];
    [[self.contentContainerView layer] setShadowPath:[path CGPath]];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    self.contentContainerView.layer.transform = CATransform3DIdentity;
    self.contentContainerXOffset = 0.0f;
    self.leftView.layer.transform = CATransform3DMakeTranslation(-self.leftViewSlideOffset, 0, 0);
    self.leftView.alpha = 0.0f;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (IBAction)panGestureDidPan:(id)sender {
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer*)sender;
    CGPoint translationInView = [panGesture translationInView:self.view];
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateEnded:
        {
            CGPoint velocity = [panGesture velocityInView:self.view];
            
            if (velocity.x > 0 || (self.contentContainerXOffset > (self.leftViewSlideOffset / 2.0f)))
            {
                [self showLeftViewController];
            }
            else
            {
                [self hideLeftViewController];
            }
        }
            break;
            
        default:
        {
            if (panGesture == self.screenEdgeGestureRecognizer)
            {
                self.contentContainerXOffset = translationInView.x;
            }
            else
            {
                self.contentContainerXOffset = self.leftViewSlideOffset + translationInView.x;
            }
            
            [self updateViewsForContainerOffset:self.contentContainerXOffset];
            [self setNeedsStatusBarAppearanceUpdate];
            [self.view layoutIfNeeded];
        }
            break;
    }

}

- (void)updateViewsForContainerOffset:(CGFloat)containerOffset
{
    CGFloat leftViewXTranslation = MAX(-self.leftViewSlideOffset, MIN(0, -self.leftViewSlideOffset + containerOffset));;
    self.leftView.layer.transform = CATransform3DMakeTranslation(leftViewXTranslation, 0, 0);
    
    self.leftView.alpha = (self.contentContainerXOffset / self.leftViewSlideOffset);
    CGFloat scale = MAX((self.leftViewSlideOffset - self.contentContainerXOffset * 0.25) / self.leftViewSlideOffset, 0.5f);
    CATransform3D contentTransform = CATransform3DConcat(CATransform3DMakeTranslation(MAX(0, self.contentContainerXOffset), 0, 0),
                                                         CATransform3DMakeScale(scale, scale, 1.0f));
    self.contentContainerView.layer.transform = contentTransform;
    self.leftView.layer.transform = CATransform3DMakeTranslation(leftViewXTranslation, 0.0f, 0.0f);
}

- (BOOL)isLeftViewVisible
{
    return (self.contentContainerXOffset > 0);
}

- (void)showLeftViewController
{
    AppConfig *appConfig = [AppConfig sharedAppConfig];
    if(appConfig.userName && appConfig.organization) {
    
        [UIView animateWithDuration:0.5f delay:0.0f usingSpringWithDamping:0.6f initialSpringVelocity:1.0f options:0 animations:^{
            [self.contentViewController.view endEditing:YES];
            self.contentContainerXOffset = self.leftViewSlideOffset;
            [self updateViewsForContainerOffset:self.contentContainerXOffset];
            [self setNeedsStatusBarAppearanceUpdate];
        } completion:^(BOOL finished) {
            [self.panGestureRecognizer setEnabled:YES];
            [self.showContentButton setEnabled:YES];
            [self.screenEdgeGestureRecognizer setEnabled:NO];
        }];
        
    }
    else
    {
        NSString *message;
        if(!appConfig.userName) {
            message = @"Must login with a user to proceed.";
        } else if (!appConfig.organization) {
            message = @"Must select an organiztion/environment to proceed.";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Test Harness Error"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)hideLeftViewController
{
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:0
                     animations:^{
                         self.contentContainerXOffset = 0;
                         [self updateViewsForContainerOffset:self.contentContainerXOffset];
                         [self setNeedsStatusBarAppearanceUpdate];
    } completion:^(BOOL finished) {
        [self.showContentButton setEnabled:NO];
        [self.panGestureRecognizer setEnabled:NO];
        [self.screenEdgeGestureRecognizer setEnabled:YES];
    }];

}

- (IBAction)showContentViewTapped:(id)sender {
    [self hideLeftViewController];
}

#pragma mark - Accessors

- (void)setContentViewController:(UIViewController *)contentViewController
{
    if (![self isViewLoaded])
    {
        [self view];
    }
    
    UIViewController *currentContentViewController = [self contentViewController];
    _contentViewController = contentViewController;
    
    [self replaceController:currentContentViewController
              newController:_contentViewController
                  container:[self contentView]];
}

- (void)setLeftViewController:(UIViewController *)leftViewController
{
    if (![self isViewLoaded])
    {
        [self view];
    }
    UIViewController *currentLeftViewController = [self leftViewController];
    _leftViewController = leftViewController;
    [self replaceController:currentLeftViewController
              newController:_leftViewController
                  container:[self leftView]];
    [self.view setNeedsLayout];
}

- (void)replaceController:(UIViewController *)oldController newController:(UIViewController *)newController container:(UIView *)container
{
    if (newController)
    {
        [newController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addChildViewController:newController];
        [newController setEcd_zoomViewController:self];
        
        if (oldController)
        {
            [self transitionFromViewController:oldController toViewController:newController duration:0.0 options:0 animations:nil completion:^(BOOL finished) {
                
                [self constrainView:newController.view toParentView:container];
                [newController didMoveToParentViewController:self];
                
                [oldController willMoveToParentViewController:nil];
                [oldController removeFromParentViewController];
                [oldController setEcd_zoomViewController:nil];
                
            }];
        }
        else
        {
            [newController beginAppearanceTransition:YES animated:YES];
            [container addSubview:[newController view]];
         
            [self constrainView:newController.view toParentView:container];
            
            [newController didMoveToParentViewController:self];
            [newController endAppearanceTransition];
        }
    }
    else
    {
        [[oldController view] removeFromSuperview];
        [oldController willMoveToParentViewController:nil];
        [oldController removeFromParentViewController];
        [oldController setEcd_zoomViewController:nil];
    }
}

- (void)constrainView:(UIView*)view toParentView:(UIView*)parentView
{
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"view": view}];
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:@{@"view": view}];
    [parentView addConstraints:horizontalConstraints];
    [parentView addConstraints:verticalConstraints];

}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    UIViewController *viewController;
    if (self.contentContainerXOffset > 0)
    {
        viewController = [self leftViewController];
    }
    else
    {
        viewController = [self contentViewController];
    }
    return viewController;
}

@end
