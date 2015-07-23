//
//  ECDUIPicker.h
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 7/22/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <EXPERTconnect/EXPERTconnect.h>

@interface ECDUIPicker : UIPickerView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, retain) NSMutableArray *dataArray;

-(void)setup:(NSMutableArray *)data;

@end

