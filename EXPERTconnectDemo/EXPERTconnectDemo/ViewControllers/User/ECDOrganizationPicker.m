//
//  ECDEnvironmentSelector.m
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 7/22/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECDOrganizationPicker.h"

@interface ECDOrganizationPicker ()

@property (nonatomic, retain) NSMutableArray *organizationArray;
@property (nonatomic, retain) NSString *currentEnvironment;

@end

@implementation ECDOrganizationPicker

static NSString *const organizationKey = @"organization";

-(void)setup {
    self.organizationArray = [NSMutableArray new];
    self.currentEnvironment = [[NSUserDefaults standardUserDefaults] objectForKey:@"environmentName"];
    if(!self.currentEnvironment) {
        self.currentEnvironment = @"IntDev";
    }
    
    if ([self.currentEnvironment isEqualToString:@"IllegalDev"] ||
        [self.currentEnvironment isEqualToString:@"IntDev"] ||
        [self.currentEnvironment isEqualToString:@"DceDev"])
    {
        [self.organizationArray addObject:@"mktwebextc"];
        [self.organizationArray addObject:@"horizon"];
        [self.organizationArray addObject:@"wwatchers"];
        [self.organizationArray addObject:@"ford"];
    }
    else if( [self.currentEnvironment isEqualToString:@"Demo"] ) {
        [self.organizationArray addObject:@"mktwebextc"];
        [self.organizationArray addObject:@"horizon"];
    }
    else if( [self.currentEnvironment isEqualToString:@"Test"]) {
        [self.organizationArray addObject:@"mktwebextc_test"];
        [self.organizationArray addObject:@"horizon_test"];
        [self.organizationArray addObject:@"wwatchers_test"];
        [self.organizationArray addObject:@"ford_test"];
    }
    else if( [self.currentEnvironment isEqualToString:@"DceSQA"]) {
        [self.organizationArray addObject:@"mktwebextc_sqa"];
        [self.organizationArray addObject:@"horizon_sqa"];
        [self.organizationArray addObject:@"wwatchers_sqa"];
        [self.organizationArray addObject:@"ford_sqa"];
    }
    else if( [self.currentEnvironment isEqualToString:@"DceProd"]) {
        [self.organizationArray addObject:@"mktwebextc"];
        [self.organizationArray addObject:@"horizon"];
        [self.organizationArray addObject:@"wwatchers"];
        [self.organizationArray addObject:@"ford"];
        [self.organizationArray addObject:@"ww_australia"];
        [self.organizationArray addObject:@"ww_europe"];
        [self.organizationArray addObject:@"ww_canada"];
    }
    
    NSString *currentOrganization = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@", self.currentEnvironment, organizationKey]];
    
    // Select the "current" Environment
    // 
    int currentRow = 0;
    int rowToSelect = 0;
    if(currentOrganization != nil)  {
        for(NSString* org in self.organizationArray) {
            if([org isEqualToString:currentOrganization])  {
                rowToSelect = currentRow;
            }
            currentRow++;
        }
    }
    
    [super setup:self.organizationArray withSelection:rowToSelect];
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"OrgPicker: You selected this: %@", [self.organizationArray objectAtIndex: row]);
    [super pickerView:pickerView didSelectRow:row inComponent:component];

    NSString *org = [self.organizationArray objectAtIndex: row];
    [[NSUserDefaults standardUserDefaults] setObject:org forKey:[NSString stringWithFormat:@"%@_%@", self.currentEnvironment, organizationKey]];
    
    // TODO: Actually set the clientID here.
    //ECSConfiguration *configuration = [ECS]
    [[EXPERTconnect shared] setClientID:org];
    
    
}

@end