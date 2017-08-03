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
@property (nonatomic, retain) NSMutableArray *environmentsArray;

@end

@implementation ECDEnvironmentPicker

static NSString *const serverUrlKey = @"serverURL";
static NSString *const environmentNameKey = @"environmentName";

-(void)setup {
    self.environmentsArray = [NSMutableArray new];
    self.serverUrlsArray = [NSMutableArray new];
    
    // First try to load from the JSON file. If that fails, load hardcoded values. 
    if (![self addItemsFromUserDefaults]) {
        [self addItemsFromHardcodedValues];
    }
    
    NSString *currentUrl = [[NSUserDefaults standardUserDefaults] objectForKey:serverUrlKey];
    
    // Select the "current" Environment
    int currentRow = 0;
    int rowToSelect = 0;
    if(currentUrl != nil)  {
        for(NSString* url in self.serverUrlsArray) {
            if([url isEqualToString:currentUrl])  {
                rowToSelect = currentRow;
                break;
            }
            currentRow++;
        }
    }
    
    // Because this is new, let's populate it on load. 
    [[NSUserDefaults standardUserDefaults] setObject:[self.environmentsArray objectAtIndex:rowToSelect]
                                              forKey:environmentNameKey];
    
    [super setup:self.environmentsArray withSelection:rowToSelect];
    NSLog(@"Test Harness::Env Picker - Setup with item %@ selected.", self.environmentsArray[rowToSelect]);
}


-(void)pickerView:(UIPickerView *)pickerView
     didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    [super pickerView:pickerView didSelectRow:row inComponent:component];

    NSString *url = [self.serverUrlsArray objectAtIndex: row];
    [[NSUserDefaults standardUserDefaults] setObject:url forKey:serverUrlKey];
    
    NSString *env = [self.environmentsArray objectAtIndex:row];
    [[NSUserDefaults standardUserDefaults] setObject:env forKey:environmentNameKey];
    
    NSLog(@"Test Harness::Env Picker - User selected %@ (URL=%@)", self.environmentsArray[row], self.serverUrlsArray[row]);
    
    // This will set host and reconfigure the session.
    NSAssert(url.length>0, @"Environment Picker - Chosen serverURL must exist.");
    [[EXPERTconnect shared] setHost:url];
    //[[EXPERTconnect shared] startJourneyWithCompletion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EnvironmentPickerChanged" object:nil];
}

// mas - 16-oct-2015 - This loads the available environments from the JSON file we fetched
// from our server on startup.
-(BOOL)addItemsFromUserDefaults {
    
    NSArray *environmentConfig = [[NSUserDefaults standardUserDefaults] objectForKey:@"environmentConfig"];
    
    if (!environmentConfig) {
        return NO;
    }
    
    for( NSDictionary *envData in environmentConfig) {
        if ([envData objectForKey:@"name"] && [envData objectForKey:@"baseURL"]) {
            [self.environmentsArray addObject:[envData objectForKey:@"name"]];
            [self.serverUrlsArray addObject:[envData objectForKey:@"baseURL"]];
        }
    }
    
    return YES;
}

// Load the old hardcoded values if something went wrong with the method above.
-(void) addItemsFromHardcodedValues {
    [self.environmentsArray addObject:@"IllegalDev"];
    [self.environmentsArray addObject:@"IntDev"];
    [self.environmentsArray addObject:@"DceDev"];
    [self.environmentsArray addObject:@"Demo"];
    [self.environmentsArray addObject:@"Test"];
    [self.environmentsArray addObject:@"SQA"];
    [self.environmentsArray addObject:@"Prod"];
    
    [self.serverUrlsArray addObject:@"http://uldcd-cldap02.ttechenabled.net:8080"];
    [self.serverUrlsArray addObject:@"http://api.humanify.com:8080"];
    [self.serverUrlsArray addObject:@"http://api.dce1.humanify.com"];
    [self.serverUrlsArray addObject:@"http://demo.humanify.com"];
    [self.serverUrlsArray addObject:@"http://api.tce2.humanify.com"];
    [self.serverUrlsArray addObject:@"http://api.ice3.humanify.com"];
    [self.serverUrlsArray addObject:@"http://api.prod.humanify.com"];
}

@end
