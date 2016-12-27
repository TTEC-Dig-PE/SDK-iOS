//
//  ECDAdHocAnswerEngineContextPicker.h
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 8/4/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <EXPERTconnect/EXPERTconnect.h>

#import "ECDUIPicker.h"

@interface ECDAdHocAnswerEngineContextPicker : ECDUIPicker {
    NSMutableArray *contextsArray;
    NSString *currentEnvironment;
    NSString *currentContext;
}

-(void)setup;

@end

