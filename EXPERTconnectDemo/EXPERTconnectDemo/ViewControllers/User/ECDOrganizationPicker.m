//
//  ECDOrganizationPicker.m
//  EXPERTconnectDemo
//
//  Created by Mike Schmoyer on 10/16/15.
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
    
    // First try to load from the JSON file. If that fails, load hardcoded values. 
    if (![self addItemsFromUserDefaults]) {
        [self addItemsFromHardcodedValues];
    }
    
    // Attempt to load the selected organization for the selected environment
    NSString *currentOrganization = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@", self.currentEnvironment, organizationKey]];
    
    // Select the current organization in the flipper control.
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
    
    // This will set clientID and blow away authToken so that we will reauthenticate with the new clientId.
    [[EXPERTconnect shared] setClientID:currentOrganization];
    
    [super setup:self.organizationArray withSelection:rowToSelect];
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"OrgPicker: You selected this: %@", [self.organizationArray objectAtIndex: row]);
    [super pickerView:pickerView didSelectRow:row inComponent:component];

    NSString *org = [self.organizationArray objectAtIndex: row];
    [[NSUserDefaults standardUserDefaults] setObject:org forKey:[NSString stringWithFormat:@"%@_%@", self.currentEnvironment, organizationKey]];
    
    // This will set clientID and blow away authToken so that we will reauthenticate with the new clientId.
    [[EXPERTconnect shared] setClientID:org];
    
}

// mas - 16-oct-2015 - This loads the available organizations from the JSON file we fetched
// from our server on startup.
-(BOOL)addItemsFromUserDefaults {
    
    NSArray *environmentConfig = [[NSUserDefaults standardUserDefaults] objectForKey:@"environmentConfig"];
    
    if (!environmentConfig) {
        return NO;
    }
    
    for( NSDictionary *envData in environmentConfig) {
        
        if ([envData objectForKey:@"name"] && [envData objectForKey:@"orgs"]) {
            
            if ([[envData objectForKey:@"name"] isEqualToString:self.currentEnvironment]) {

                for ( NSString *org in [envData objectForKey:@"orgs"] ) {
                    [self.organizationArray addObject:org];
                }
            }
        }
    }
    
    return YES;
}

-(void) addItemsFromHardcodedValues {
    // Hardcoded sample data. Soon to be replaced by fetching a JSON file.
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
}

@end