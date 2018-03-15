//
//  ECSQuickRatingForm.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

@class ECSForm;

/**
 Object used to configure a quick rating survey
 */
@interface ECSQuickRatingForm : ECSJSONObject <ECSJSONSerializing, NSCopying>

@property (strong, nonatomic) NSString *formId;
@property (strong, nonatomic) NSString *formTitle;
@property (strong, nonatomic) NSString *formHeader;
@property (strong, nonatomic) NSString *formDetailText;
@property (strong, nonatomic) NSString *formPromptText;
@property (strong, nonatomic) NSString *submitButtonText;
@property (strong, nonatomic) NSString *submitCompleteHeaderText;
@property (strong, nonatomic) NSString *submitCompleteText;

- (ECSForm*)formValueWithRating:(NSNumber*)rating;

@end
