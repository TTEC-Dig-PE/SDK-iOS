//
//  ECDAdHocAnswerEngineContextPicker.m
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 8/4/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECDAdHocAnswerEngineContextPicker.h"

@implementation ECDAdHocAnswerEngineContextPicker

static NSString *const lastAnswerEngineContextSelected = @"lastAnswerEngineContextSelected";

NSMutableArray *contextsArray;
NSString *currentEnvironment;
NSString *currentContext;

-(void)setup {
    
    currentEnvironment = [[NSUserDefaults standardUserDefaults] objectForKey:@"environmentName"];
    if(!currentEnvironment) {
        currentEnvironment = @"IntDev";
    }
    
    if(![self addContextsFromServer]) {
        [self addContextsHardcoded];
    }
    
    // Attempt to load the selected context for the selected environment
    currentContext = [[NSUserDefaults standardUserDefaults]
                      stringForKey:[NSString stringWithFormat:@"%@_%@", currentEnvironment, lastAnswerEngineContextSelected]];
    
    // Select the current context in the flipper control.
    int currentRow = 0;
    int rowToSelect = 0;
    if(currentContext != nil)  {
        for(NSString* context in contextsArray) {
            if([context isEqualToString:currentContext])  {
                rowToSelect = currentRow;
                break;
            }
            currentRow++;
        }
    }
    
    [super setup:contextsArray withSelection:rowToSelect];
    
    double width = (UIScreen.mainScreen.traitCollection.horizontalSizeClass == 1 ? 220.0f : 440.0f);
    [self setFrame: CGRectMake(0.0f, 0.0f, width, 180.0f)];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [super pickerView:pickerView didSelectRow:row inComponent:component];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:(int)row]
                                              forKey:[NSString stringWithFormat:@"%@_%@", currentEnvironment, lastAnswerEngineContextSelected]];
}

-(BOOL)addContextsFromServer {
    NSArray *environmentConfig = [[NSUserDefaults standardUserDefaults] objectForKey:@"environmentConfig"];
    
    if (!environmentConfig) {
        return NO;
    }
    
    for( NSDictionary *envData in environmentConfig) {
        
        if (envData[@"name"] && [envData[@"name"] isEqualToString:currentEnvironment]) {
            
            if(envData[@"answer_engine"]) {
                
                contextsArray = [NSMutableArray new];
                for ( NSString *context in envData[@"answer_engine"] ) {
                    [contextsArray addObject:context];
                }
            }
        }
    }
    
    return YES;
}

-(void)addContextsHardcoded {
    contextsArray = [NSMutableArray new];
    
    [contextsArray addObject:@"Telecommunications"];
    [contextsArray addObject:@"SDK Demo Technical Support"];
    [contextsArray addObject:@"SDK Demo Account Support"];
    [contextsArray addObject:@"SDK Demo Technical Support FR"];
    [contextsArray addObject:@"SDK Demo Account Support FR"];
    [contextsArray addObject:@"SDK Demo Technical Support ES"];
    [contextsArray addObject:@"SDK Demo Account Support ES"];
    [contextsArray addObject:@"Demo AppT1"];
    [contextsArray addObject:@"Demo AppT2"];
    [contextsArray addObject:@"Demo AppT3"];
    [contextsArray addObject:@"Demo AppT4"];
    [contextsArray addObject:@"Cable"];
    [contextsArray addObject:@"Live Connect"];
    [contextsArray addObject:@"Financial Services"];
}

@end