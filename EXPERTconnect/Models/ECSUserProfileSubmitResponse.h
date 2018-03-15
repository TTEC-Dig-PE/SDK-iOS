//
//  ECSUserProfileSubmitResponse.h
//  EXPERTconnect
//
//  Created by Ken Washington on 8/12/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

@interface ECSUserProfileSubmitResponse : ECSJSONObject <ECSJSONSerializing>

@property (strong, nonatomic) NSArray *actions;
@property (strong, nonatomic) NSString *submitted;

@end
