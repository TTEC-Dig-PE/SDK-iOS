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

NSString *const HZNewCustomer = @"new";
NSString *const HZExistingCustomer = @"existing";

NSString *const HZCustomerConcierge = @"concierge";
NSString *const HZCustomerStandard = @"standard";

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

- (NSString *)getActionType{
    NSString *customerStatus = [EXPERTconnect shared].customerType;
    NSString *customerType = [EXPERTconnect shared].treatmentType;
    
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
    // return {@"ActionType":<Some ActionType>}
    NSString *customerStatus = HZExistingCustomer;
    NSString *customerType = HZCustomerStandard;
    if ([workflowName isEqualToString:ECSActionTypeAnswerEngineString]) {
        
        if ([customerStatus isEqualToString:HZExistingCustomer]) {
            if ([customerType isEqualToString:HZCustomerStandard]) {
                if ([params valueForKey:@"InvalidResponseCount"]) {
                    NSNumber *count = [params valueForKey:@"InvalidResponseCount"];
                    if (count.intValue ==  3) {
                        return @{@"ActionType":ECSRequestChatAction};
                    }
                }
            } 
        } else if ([customerStatus isEqualToString:HZExistingCustomer]) {
            if ([customerType isEqualToString:HZCustomerConcierge]) {
                if ([params valueForKey:@"QuestionsAsked"]) {
                    NSNumber *count = [params valueForKey:@"QuestionsAsked"];
                    if (count.intValue ==  1) {
                        return @{@"ActionType":ECSRequestCallbackAction};
                    }
                }
            }
        }
    }
    return nil;
}
@end
