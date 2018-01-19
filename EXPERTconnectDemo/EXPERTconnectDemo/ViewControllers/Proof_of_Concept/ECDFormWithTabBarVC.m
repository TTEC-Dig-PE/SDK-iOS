//
//  ECDFormWithTabBarVC.m
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 11/29/17.
//  Copyright © 2017 Humanify, Inc. All rights reserved.
//

#import "ECDFormWithTabBarVC.h"

@interface ECDFormWithTabBarVC () <UITabBarDelegate>

@property (assign, nonatomic) CGRect keyboardFrame;

@end

@implementation ECDFormWithTabBarVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.formController.shiftUpForKeyboard = NO; 
    [self addChildViewController:self.formController];
    
//    self.formController.bottomFrameOffset = self.tabBar.frame.size.height;
    
    self.formController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.formController.view
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.chatView
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1
                                                            constant:0];
    
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.formController.view
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.chatView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:0];
    
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.formController.view
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.chatView
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1
                                                             constant:0];
    
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.formController.view
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.chatView
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1
                                                              constant:0];
    
    [self.chatView addSubview:self.formController.view];
    
    [self.chatView addConstraints:@[top, bottom, left, right]];
    
    [self.formController didMoveToParentViewController:self];
    
    [self.view layoutIfNeeded];
    
    [self registerForNotifications];
    
    [self configureNavigationBar];
    
    self.tabBar.delegate = self; 
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [self unregisterForNotifications]; 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureNavigationBar {
    
    self.navigationItem.title = @"Tab Bar Chat";
    
    if ([[self.navigationController viewControllers] count] > 1) {
        
        // Configure the "back" button on the nav bar
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"< Back"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(backButtonPressed:)];
    }
}

- (void)backButtonPressed:(id)sender {
//    [self.chatController endChatByUser];
    [self.navigationController popViewControllerAnimated:YES]; 
}

- (void) tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    if( item.tag == 0 ) {
        // Favorites
    } else if ( item.tag == 1 ) {
        // History
        
        UIViewController *historyView = [[EXPERTconnect shared] startChatHistory];
        [self.navigationController pushViewController:historyView animated:YES];
        
    }
    
}

- (void)keyboardWillChangeFrame:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *animationTime = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    self.keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];

    [UIView animateWithDuration:[animationTime floatValue] animations:^{
        [UIView setAnimationCurve:[animationCurve intValue]];
        [self updateEdgeInsets];

    } completion:^(BOOL finished) {

    }];
    
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *animationTime = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    self.keyboardFrame = CGRectZero;

    [UIView animateWithDuration:[animationTime floatValue] animations:^{
        [UIView setAnimationCurve:[animationCurve intValue]];
        [self updateEdgeInsets];
    }];
}

- (void)updateEdgeInsets {
 
    CGFloat bottomOffset = 0;
    if (self.keyboardFrame.size.height) {
        CGRect viewFrameInWindow = [self.view.window convertRect:self.view.frame fromView:self.view.superview];
        bottomOffset = viewFrameInWindow.origin.y + viewFrameInWindow.size.height - self.keyboardFrame.origin.y;
    }

    self.tabBarBottom.constant = bottomOffset;
}

- (void) registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unregisterForNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
