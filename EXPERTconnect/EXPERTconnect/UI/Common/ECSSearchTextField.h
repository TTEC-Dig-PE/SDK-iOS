//
//  ECSSearchTextField.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECSActionType;

IB_DESIGNABLE
@interface ECSSearchTextField : UITextField

@property (strong, nonatomic) ECSActionType *searchAction;

@end
