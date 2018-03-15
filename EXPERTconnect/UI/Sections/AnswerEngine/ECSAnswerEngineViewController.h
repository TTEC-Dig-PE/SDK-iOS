//
//  ECSAnswerEngineViewController.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <EXPERTconnect/EXPERTconnect.h>

@class ECSAnswerEngineActionType;
@class ECSAnswerHistoryResponse;

/**
 Provides a view controller for managing answer engine interactions.
 */
@interface ECSAnswerEngineViewController : ECSRootViewController

// The action for this answer engine interface
@property (strong, nonatomic) ECSAnswerEngineActionType *answerEngineAction;

// If displaying a history then this will be shown in a history type model
@property (strong, nonatomic) ECSAnswerHistoryResponse *historyResponse;

// If set, the initialQuery will be used for an initial API call.
@property (strong, nonatomic) NSString *initialQuery;

@property (nonatomic, strong) ECSLog *logger;

@end
