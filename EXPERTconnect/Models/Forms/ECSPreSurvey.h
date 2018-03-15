//
//  ECSPreSurvey.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

@class ECSForm;

@interface ECSPreSurvey : ECSJSONObject <ECSJSONSerializing, NSCopying>

@property (strong, nonatomic) NSString *formFooter;
@property (strong, nonatomic) NSString *formTitle;
@property (strong, nonatomic) NSString *formHeader;
@property (strong, nonatomic) NSString *formSubHeader;
@property (strong, nonatomic) NSString *formName;
@property (strong, nonatomic) NSArray *questions;

- (ECSForm*)formValue;

@end
