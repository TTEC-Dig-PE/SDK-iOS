//
//  ECDNavigationController.m
//  EXPERTconnectDemo
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECDNavigationController.h"

#import "ECDZoomViewController.h"

@interface ECDNavigationController ()

@end

@implementation ECDNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self)
    {
        UIButton *menuButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [menuButton setImage:[UIImage imageNamed:@"ecs_ic_nav_burger"] forState:UIControlStateNormal];
        menuButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [menuButton addTarget:self action:@selector(showMainMenu:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *menuButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];

        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -16;
        rootViewController.navigationItem.leftBarButtonItems = @[negativeSpacer, menuButtonItem];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)showMainMenu:(id)sender
{
    if ([[self ecd_zoomViewController] isLeftViewVisible])
    {
        [[self ecd_zoomViewController] hideLeftViewController];
    }
    else
    {
        [[self ecd_zoomViewController] showLeftViewController];
    }
}

@end
