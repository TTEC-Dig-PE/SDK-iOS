//
//  ECSAnswerEngineActionType.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <EXPERTconnect/EXPERTconnect.h>

/**
 ECSAnswerEngineActionType is an action type defining an answer engine interaction
 */
@interface ECSAnswerEngineActionType : ECSActionType <NSCopying>

// Specifies the default question to ask when using the answer engine
@property (strong, nonatomic) NSString *defaultQuestion;

// Specifies the list of top questions for the answer engine
@property (strong, nonatomic) NSArray *topQuestions;

// Specifies alternate actions that may be taken within the answer engine context
@property (strong, nonatomic) NSArray *actions;

// Specifies the context of the answer engine
@property (strong, nonatomic) NSString *answerEngineContext;

@end
