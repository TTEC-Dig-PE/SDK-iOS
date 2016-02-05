//
//  ECDSimpleAnswerEngineController.m
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 1/13/16.
//  Copyright © 2016 Humanify, Inc. All rights reserved.
//

#import "ECDSimpleAnswerEngineController.h"

@interface ECDSimpleAnswerEngineController ()

@end

@implementation ECDSimpleAnswerEngineController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)viewDidAppear:(BOOL)animated {
    // Let's get top questions.
    ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    [sessionManager getAnswerEngineTopQuestions:10
                                     forContext:@"park"
                                 withCompletion:^(NSArray *answers, NSError *error)
     {
         // Got our top questions...
         NSLog(@"Result: %@", answers);
     }];
}

- (void)askQuestion:(NSString *)theQuestion {
    
    ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    __weak typeof(self) weakSelf = self;
    
    ECSAnswerEngineActionType *answerEngineAction;
    
    [sessionManager startConversationForAction:answerEngineAction
                               andAlwaysCreate:NO
                                withCompletion:^(ECSConversationCreateResponse *conversation, NSError *error)
    {
        if (!error)
        {
            weakSelf.currentQuestionTask = [sessionManager getAnswerForQuestion:weakSelf.searchTextField.text
                                                                      inContext:weakSelf.answerEngineContext
                                                                parentNavigator:@"simpleAEcontroller"
                                                                       actionId:@""
                                                                  questionCount:0
                                                                     customData:nil
                                                                     completion:^(ECSAnswerEngineResponse *response, NSError *error)
            {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [weakSelf handleAPIResponse:response forQuestion:weakSelf.searchTextField.text withError:error];
                     
                 });
                 
             }];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf handleAPIResponse:nil forQuestion:nil withError:[NSError new]];
            });
        }
    }];
}

- (void)handleAPIResponse:(ECSAnswerEngineResponse*)response
              forQuestion:(NSString*)question
                withError:(NSError*)error
{

    if ([response isKindOfClass:[ECSAnswerEngineResponse class]])
    {
        if (error) {
            // Error processing request.
            NSLog(@"Answer Engine Error - %@", error);
            
        } else if (response.answerId.integerValue == -1 && response.answer.length > 0) {
            // We did not find an answer.
            NSLog(@"No answer found.");
            
        } else {
            // We found a good answer.
            NSLog(@"Answer found!");
        }
    }
}

// called from a timer after user types a search term.
-(void)doTypeAheadSearch
{
    ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    [sessionManager getAnswerEngineTopQuestionsForKeyword:self.searchTextField.text
                                      withOptionalContext:nil
                                               completion:^(ECSAnswerEngineResponse *response, NSError *error)
     {
         // Got our top questions...
         if (response.suggestedQuestions) {
             
             //self.answerEngineAction.topQuestions = response[@"suggestedQuestions"];
             //[self displayTopQuestions];
         }
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
