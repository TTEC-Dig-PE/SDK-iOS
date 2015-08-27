//
//  ECSWorkflow.h
//  EXPERTconnect
//
//  Created by Shammi Didla on 19/08/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECSWorkflowNavigation.h"

@class ECSWorkflow;

@protocol ECSWorkflowDelegate <NSObject>

- (NSDictionary *)workflowResponseForWorkflow:(ECSWorkflow *)workflow
                               requestCommand:(NSString *)command
                                requestParams:(NSDictionary *)params;

@end

@interface ECSWorkflow : NSObject

@property (nonatomic, copy, readonly) NSString *workflowName;

- (instancetype)initWithWorkflowName:(NSString *)workflowName
                    workflowDelegate:(id <ECSWorkflowDelegate>)workflowDelegate
                   navigationManager:(ECSWorkflowNavigation *)navigationManager;

- (void)start;
- (void)end;

- (void)invalidResponseOnAnswerEngineWithCount:(NSInteger)count;

@end
