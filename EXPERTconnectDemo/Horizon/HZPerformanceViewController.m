//
//  HZPerformanceViewController.m
//  EXPERTconnectDemo
//
//  Created by Shammi Didla on 24/06/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "HZPerformanceViewController.h"

#import <EXPERTconnect/EXPERTconnect.h>

#import <MMDrawerController/UIViewController+MMDrawerController.h>

@interface HZPerformanceViewController () <ECSWorkflowDelegate>

@end

@implementation HZPerformanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)hamburgerButtonTapped:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (IBAction)giveFeedbackButtonTapped:(id)sender {
    
    UIAlertController *workflowNameController = [UIAlertController alertControllerWithTitle:@"Hello!" message:@"Enter a workflow name" preferredStyle:UIAlertControllerStyleAlert];
    [workflowNameController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField setPlaceholder:@"Workflow Name"];
        [textField setTextAlignment:NSTextAlignmentCenter];
    }];
    
    UIAlertAction *alertActionStop = [UIAlertAction actionWithTitle:@"Back" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [workflowNameController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *alertActionContinue = [UIAlertAction actionWithTitle:@"Start" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *workflowNameTextField = [[workflowNameController textFields] objectAtIndex:0];
        if(workflowNameTextField.text.length > 0) {
            [self startWorkflowWith:workflowNameTextField.text];
        } else {
            [self presentViewController:workflowNameController animated:YES completion:nil];
        }
    }];
    
    [workflowNameController addAction:alertActionStop];    
    [workflowNameController addAction:alertActionContinue];
    [self presentViewController:workflowNameController animated:YES completion:nil];
}

-(void)startWorkflowWith:(NSString *)workflowName {
    [[EXPERTconnect shared] setUserIntent:@"mutual funds"];
    [[EXPERTconnect shared] startWorkflowWithName:workflowName
                                          delgate:self
                                   viewController:self];
}


- (NSDictionary *)workflowResponseForWorkflow:(ECSWorkflow *)workflow
                               requestCommand:(NSString *)command
                                requestParams:(NSDictionary *)params {
    if ([workflow.workflowName isEqualToString:@"agentSelection"]) {
        return @{@"dfafa":@"dafsd"};
    }
    return nil;
}
@end
