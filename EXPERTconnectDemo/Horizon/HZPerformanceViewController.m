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

NSString *const HZNewCustomer = @"New Customer";
NSString *const HZCustomerConcierge = @"Concierge";

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
    
    NSString *actionType = [self getActionType];
    if (actionType) {
        [self startWorkflowWithAction:actionType];
    }
}

- (NSString *)getActionType {
    NSString *customerStatus = HZNewCustomer;
    NSString *customerType = HZCustomerConcierge;
    
    if ([customerStatus isEqualToString:HZNewCustomer]) {
        if ([customerType isEqualToString:HZCustomerConcierge]) {
            return ECSActionTypeAnswerEngineString;
        }
    }
    
    return nil;
}

-(void)startWorkflowWithAction:(NSString *)actionType {
    [[EXPERTconnect shared] setUserIntent:@"mutual funds"];
    [[EXPERTconnect shared] startWorkflow:@"Gwen Flow"
                               withAction:actionType
                                  delgate:self
                           viewController:self];
}


- (NSDictionary *)workflowResponseForWorkflow:(NSString *)workflowName
                               requestCommand:(NSString *)command
                                requestParams:(NSDictionary *)params {
    //{@"ActionType":<Some ActionType>}
    NSString *customerStatus = HZNewCustomer;
    NSString *customerType = HZCustomerConcierge;
    if ([workflowName isEqualToString:ECSActionTypeAnswerEngineString]) {
        
        if ([customerStatus isEqualToString:HZNewCustomer]) {
            if ([customerType isEqualToString:HZCustomerConcierge]) {
                if ([params valueForKey:@"InvalidResponseCount"]) {
                    NSNumber *count = [params valueForKey:@"InvalidResponseCount"];
                    if (count.intValue ==  1) {
                        return @{@"ActionType":ECSRequestChatAction};
                    }
                }
            }
        }
    }
    return nil;
}
@end
