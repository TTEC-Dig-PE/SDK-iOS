//
//  ECSPresurveyFormItem.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

@interface ECSPresurveyFormItem : ECSJSONObject <ECSJSONSerializing, NSCopying>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *metadata;
@property (strong, nonatomic) NSString *value;

@end
