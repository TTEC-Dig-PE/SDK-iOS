//
//  ECDUIPicker.m
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 7/22/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECDUIPicker.h"


@implementation ECDUIPicker


-(void)setup:(NSMutableArray *)data {
    self.dataArray = data;
    
    [self setDataSource: self];
    [self setDelegate: self];
    [self setFrame: CGRectMake(0.0f, 0.0f, 180.0f, 180.0f)];
}

-(void)setup:(NSMutableArray *)data withSelection:(int)rowToSelect {
    
    [self setup:data];
    [self selectRow:rowToSelect inComponent:0 animated:YES];

    self.selection = [self.dataArray objectAtIndex:rowToSelect];
}

// Number of components.
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.dataArray count];
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.dataArray objectAtIndex: row];
}

// Do something with the selected row.
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selection = [self.dataArray objectAtIndex: row];
    NSLog(@"You selected this: %@", self.selection);
}

-(NSString *)currentSelection
{
    return self.selection;
}

@end