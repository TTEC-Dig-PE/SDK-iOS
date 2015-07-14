//
//  HZMainScreenViewController.m
//  EXPERTconnectDemo
//
//  Created by Shammi Didla on 18/06/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "HZMainScreenViewController.h"

#import <EXPERTconnect/EXPERTconnect.h>
#import <MMDrawerController/UIViewController+MMDrawerController.h>

#import "HZAppDelegate.h"

static NSString * const kUserDefaultsAgentKey = @"agent_key";

@interface HZMainScreenViewController ()

@property (weak, nonatomic) IBOutlet UIView *debugMenuView;

@property (weak, nonatomic) IBOutlet UIButton *agentSelectButton;

@end

@implementation HZMainScreenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Debug menu : select agent
    NSString *agent = [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsAgentKey];
    [self updateAgentButtonWithAgentName:agent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)hamburgerButtonTapped:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Debug options

- (IBAction)debugMenuTapped:(UIButton *)sender
{
    if (sender.selected == NO) {
        sender.selected = YES;
        self.debugMenuView.hidden = NO;
        
    }
    else {
        sender.selected = NO;
        self.debugMenuView.hidden = YES;
    }
}

- (IBAction)agentSelectButtonTapped:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    __block UITextField *agentTextField;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Agent Name:"
                                                                   message:@""
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        agentTextField = textField;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *agent = agentTextField.text;
        [[NSUserDefaults standardUserDefaults] setObject:agent forKey:kUserDefaultsAgentKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [weakSelf updateAgentButtonWithAgentName:agent];
    }]];
    
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)updateAgentButtonWithAgentName:(NSString *)name {
    if (name.length > 0) {
        NSString *title = [NSString stringWithFormat:@"Debug agent: %@", name];
        [self.agentSelectButton setTitle:title forState:UIControlStateNormal];
    }
    else {
        [self.agentSelectButton setTitle:@"Set debug agent" forState:UIControlStateNormal];
    }
}

@end
