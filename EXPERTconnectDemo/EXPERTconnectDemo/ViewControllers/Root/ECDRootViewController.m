//
//  ECDRootViewController.m
//  EXPERTconnectDemo
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECDRootViewController.h"

#import "ECDMainMenuViewController.h"

@interface ECDRootViewController ()

@end

@implementation ECDRootViewController

- (ECDZoomViewController*)zoomViewController
{
    
    return _zoomViewController;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.zoomViewController preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden
{
    return [self.zoomViewController prefersStatusBarHidden];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return [self.zoomViewController preferredStatusBarUpdateAnimation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.zoomViewController = [[ECDZoomViewController alloc] initWithNibName:nil bundle:nil];
    [self.zoomViewController.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addChildViewController:self.zoomViewController];
    [self.view addSubview:self.zoomViewController.view];
    
    
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"view": self.zoomViewController.view}];
    [self.view addConstraints:horizontalConstraints];
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:@{@"view": self.zoomViewController.view}];
    [self.view addConstraints:verticalConstraints];

    ECDMainMenuViewController *mainMenu = [[ECDMainMenuViewController alloc] initWithNibName:nil bundle:nil];
    [self.zoomViewController setLeftViewController:mainMenu];
}

@end
