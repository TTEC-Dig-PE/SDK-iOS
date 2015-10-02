//
//  ECDEnvironmentSelector.m
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 7/22/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECDEnvironmentPicker.h"

@interface ECDEnvironmentPicker ()

@property (nonatomic, retain) NSMutableArray *serverUrlsArray;

@end

@implementation ECDEnvironmentPicker

static NSString *const serverUrlKey = @"serverURL";

-(void)setup {
    NSMutableArray *environmentsArray = [NSMutableArray new];
    self.serverUrlsArray = [NSMutableArray new];
    
    [environmentsArray addObject:@"IllegalDev"];
    [environmentsArray addObject:@"IntDev"];
    [environmentsArray addObject:@"DceDev"];
    [environmentsArray addObject:@"Demo"];
    [environmentsArray addObject:@"Test"];
    [environmentsArray addObject:@"SQA"];
    [environmentsArray addObject:@"Prod"];
    
    [self.serverUrlsArray addObject:@"http://uldcd-cldap02.ttechenabled.net:8080"];
    [self.serverUrlsArray addObject:@"http://api.humanify.com:8080"];
    [self.serverUrlsArray addObject:@"http://api.dce1.humanify.com:8080"];
    [self.serverUrlsArray addObject:@"http://demo.humanify.com"];
    [self.serverUrlsArray addObject:@"http://api.dce2.humanify.com:8080"];
    [self.serverUrlsArray addObject:@"http://api.dce3.humanify.com:8080"];
    [self.serverUrlsArray addObject:@"http://api.prod.humanify.com:8080"];

    
    NSString *currentUrl = [[NSUserDefaults standardUserDefaults] objectForKey:serverUrlKey];
    
    // Select the "current" Environment
    // 
    int currentRow = 0;
    int rowToSelect = 0;
    if(currentUrl != nil)  {
        for(NSString* url in self.serverUrlsArray) {
            if([url isEqualToString:currentUrl])  {
                rowToSelect = currentRow;
            }
            currentRow++;
        }
    }
    
    [super setup:environmentsArray withSelection:rowToSelect];
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [super pickerView:pickerView didSelectRow:row inComponent:component];

    NSString *url = [self.serverUrlsArray objectAtIndex: row];
    [[NSUserDefaults standardUserDefaults] setObject:url forKey:serverUrlKey];
}

@end