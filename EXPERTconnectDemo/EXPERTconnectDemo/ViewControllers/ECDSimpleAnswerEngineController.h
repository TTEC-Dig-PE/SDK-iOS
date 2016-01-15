//
//  ECDSimpleAnswerEngineController.h
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 1/13/16.
//  Copyright © 2016 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EXPERTconnect/EXPERTconnect.h>

@interface ECDSimpleAnswerEngineController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@property (strong, nonatomic) NSURLSessionTask *currentQuestionTask;
@property (weak, nonatomic) NSString *answerEngineContext;

@end
