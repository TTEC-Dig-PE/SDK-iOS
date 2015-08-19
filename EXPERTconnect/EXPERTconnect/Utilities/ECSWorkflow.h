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

- (NSDictionary *)workflowResponseForWorkflow:(ECSWorkflow *)workflow request:(NSDictionary *)request;

@end

@interface ECSWorkflow : NSObject

@property (nonatomic, copy, readonly) NSString *workflowName;

- (instancetype)initWithWorkflowName:(NSString *)workflowName
                    workflowDelegate:(id <ECSWorkflowDelegate>)workflowDelegate
                   navigationManager:(ECSWorkflowNavigation *)navigationManager;

- (void)start;
- (void)end;

@end
