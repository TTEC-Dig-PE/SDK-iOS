//
//  HZDrawerViewController.m
//  EXPERTconnectDemo
//
//  Created by Shammi Didla on 18/06/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "HZDrawerViewController.h"

#import "HZAppDelegate.h"

#import <MMDrawerController/UIViewController+MMDrawerController.h>

@interface HZDrawerViewController ()

@property (weak, nonatomic) IBOutlet UIButton *primaryCheckingButton;
@property (weak, nonatomic) IBOutlet UIButton *mutualFundsButton;
@property (weak, nonatomic) IBOutlet UIButton *researchButton;
@property (weak, nonatomic) IBOutlet UIButton *riskButton;

@end

@implementation HZDrawerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self deselectAllButtons];
    self.primaryCheckingButton.selected = YES;
}

- (IBAction)logoutButtonTapped:(id)sender {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Settings"
                                          message:@""
                                          preferredStyle:UIAlertControllerStyleActionSheet];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Logout"
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction *action) {
                                                          [[EXPERTconnect shared] setUserToken:nil];
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    UIPopoverPresentationController *presentationController = [alertController popoverPresentationController];
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    presentationController.sourceView = sender;
    presentationController.sourceRect = [sender bounds];
}

- (IBAction)primaryCheckingButtonTapped:(id)sender {
    [self selectButton:sender];
    
    HZAppDelegate *appDelegate = (HZAppDelegate *) [[UIApplication sharedApplication] delegate];
    [self selectViewController:[appDelegate mainViewController]];
}

- (IBAction)mutualFundsButtonTapped:(id)sender {
    [self selectButton:sender];
    
    HZAppDelegate *appDelegate = (HZAppDelegate *) [[UIApplication sharedApplication] delegate];
    [self selectViewController:[appDelegate performanceViewController]];
}

- (IBAction)researchButtonTapped:(id)sender {
    [self selectButton:sender];
    
    HZAppDelegate *appDelegate = (HZAppDelegate *) [[UIApplication sharedApplication] delegate];
    [self selectViewController:[appDelegate researchViewController]];
}

- (IBAction)riskButtonTapped:(id)sender {
    [self selectButton:sender];
    
    HZAppDelegate *appDelegate = (HZAppDelegate *) [[UIApplication sharedApplication] delegate];
    [self selectViewController:[appDelegate riskViewController]];
}

#pragma mark - Helper Methods

- (void)deselectAllButtons {
    self.primaryCheckingButton.selected = NO;
    self.mutualFundsButton.selected = NO;
    self.researchButton.selected = NO;
    self.riskButton.selected = NO;
}

- (void)selectButton:(UIButton *)button {
    [self deselectAllButtons];
    button.selected = YES;
}

- (void)selectViewController:(UIViewController *)viewController {
    [self.mm_drawerController setCenterViewController:viewController withCloseAnimation:YES completion:nil];
}

@end
