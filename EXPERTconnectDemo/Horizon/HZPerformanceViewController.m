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
{
    NSString *customerType;
    NSString *customerTreatmentType;
    NSString *lastSurveyScore;
}
@end

@implementation HZPerformanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)hamburgerButtonTapped:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (NSString *)getSkillTypeForMap{
    NSString *customerStatus = [EXPERTconnect shared].customerType;
    NSString *customerType = [EXPERTconnect shared].treatmentType;
    
    if ([customerStatus isEqualToString:HZNewCustomer]) {
        if ([customerType isEqualToString:HZCustomerConcierge]) {
            return @"Calls for frank_horizon";
        }
    }
    
    if ([customerStatus isEqualToString:HZExistingCustomer]) {
        if ([customerType isEqualToString:HZCustomerStandard]) {
            return @"communications";
        }
    }
    
    return nil;
}

- (IBAction)giveFeedbackButtonTapped:(id)sender {
    customerTreatmentType = [EXPERTconnect shared].treatmentType;
    customerType = [EXPERTconnect shared].customerType;
    lastSurveyScore = [EXPERTconnect shared].lastSurveyScore;
    
    //Ray
//    customerTreatmentType = @"standard";
//    customerType = @"existing";

     //Gwen
//     customerTreatmentType = @"concierge";
//     customerType = @"new";

    if ([customerType isEqualToString:HZNewCustomer] && [customerTreatmentType isEqualToString:HZCustomerConcierge]) {
        if([lastSurveyScore isEqualToString:@"low"]) {
            [self startWorkflowWithAction:ECSActionTypeSelectExpertVideo];
        }
        else {
            [self startWorkflowWithAction:ECSActionTypeAnswerEngineString];
        }
    }
    else {
        [self startWorkflowWithAction:ECSActionTypeAnswerEngineString];
    }
}

-(void)startWorkflowWithAction:(NSString *)actionType {
    [[EXPERTconnect shared] setUserIntent:@"mutual funds"];
    [EXPERTconnect shared].surveyFormName = @"RateHorizonComm";
    [[EXPERTconnect shared] startWorkflow:@"Gwen Flow"
                               withAction:actionType
                                  delgate:self
                           viewController:self];
}


- (NSDictionary *)workflowResponseForWorkflow:(NSString *)workflowName
                               requestCommand:(NSString *)command
                                requestParams:(NSDictionary *)params {
    if ([customerType isEqualToString:HZNewCustomer] && [customerTreatmentType isEqualToString:HZCustomerConcierge]) {
        
        if ([workflowName isEqualToString:ECSActionTypeAnswerEngineString]) {
            if ([params valueForKey:@"InvalidResponseCount"]) {
                NSNumber *count = [params valueForKey:@"InvalidResponseCount"];
                if (count.intValue ==  1) {
                        return @{@"ActionType":ECSRequestVideoAction};
                }
            }
        }
        else if([workflowName isEqualToString:ECSActionTypeSelectExpertVideo]) {
                return @{@"ActionType":ECSActionTypeFormString};
        }
    }
    else {
        if ([workflowName isEqualToString:ECSActionTypeAnswerEngineString]) {
            NSNumber *count;
             if ([params valueForKey:@"InvalidResponseCount"]) {
             count = [params valueForKey:@"InvalidResponseCount"];
     
                if(![lastSurveyScore isEqualToString:@"low"]) {
                    if (count.intValue ==  3) {
                        return @{@"ActionType":ECSRequestChatAction};
                    }
                }
                else {
                    if (count.intValue ==  1) {
                        return @{@"ActionType":ECSRequestCallbackAction};
                    }
                }
            }
        }
        else if([workflowName isEqualToString:ECSActionTypeChatString]) {
            return @{@"ActionType":ECSActionTypeFormString};
        }
        else if ([workflowName isEqualToString:ECSActionTypeCallbackString]) {
            return @{@"ActionType":ECSActionTypeFormString};
        }
    }
    if ([workflowName isEqualToString:ECSActionTypeFormString]) {
        if ([params valueForKey:@"formName"]) {
            NSString *formName = [params valueForKey:@"formName"];
            if ([formName isEqualToString:@"RateHorizonComm"]) {
                if ([params valueForKey:@"formValue"]) {
                    NSString *formValue = [params valueForKey:@"formValue"];
                    if ([formValue isEqualToString:@"low"] ) {
                        return @{@"ActionType":ECSActionTypeSelectExpertChat};
                    }else {
                        return @{@"ActionType":ECSActionTypeFormSubmitted};
                    }
                }
            }
        }
    }
    
    return nil;
}

@end
