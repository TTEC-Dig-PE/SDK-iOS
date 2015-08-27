//
//  ECSWorkflow.m
//  EXPERTconnect
//
//  Created by Shammi Didla on 19/08/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSWorkflow.h"

#import "ECSActionType.h"

@interface ECSWorkflow ()

@property (nonatomic, strong) ECSWorkflowNavigation *navigationManager;
@property (nonatomic, weak) id <ECSWorkflowDelegate> workflowDelegate;
@property (nonatomic, copy) NSString *workflowName;

@end

@implementation ECSWorkflow

#pragma mark - Setup

- (instancetype)initWithWorkflowName:(NSString *)workflowName
                    workflowDelegate:(id<ECSWorkflowDelegate>)workflowDelegate
                   navigationManager:(ECSWorkflowNavigation *)navigationManager {
    
    self = [super init];
    if (self) {
        _workflowName = workflowName;
        _workflowDelegate = workflowDelegate;
        _navigationManager = navigationManager;
    }
    return self;
}

- (void)start {
    
}

- (void)end {
    [self.navigationManager dismissAllViewControllersAnimated:YES completion:nil];
}

- (void)invalidResponseOnAnswerEngineWithCount:(NSInteger)count {
    NSDictionary *actions = nil;
    if ([self.workflowDelegate respondsToSelector:@selector(workflowResponseForWorkflow:requestCommand:requestParams:)]) {
       actions = [self.workflowDelegate workflowResponseForWorkflow:self
                                                     requestCommand:nil
                                                      requestParams:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:count] forKey:@"InvalidResponseCount"]];
    }
    
    if (actions) {
        NSString *actionType = [actions valueForKey:@"ActionType"];
        [self.navigationManager preformActionForActionType:actionType];
    }
}

@end
