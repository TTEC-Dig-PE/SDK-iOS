//
//  ECSQuickRatingForm.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSQuickRatingForm.h"

#import "ECSForm.h"
#import "ECSFormItem.h"

@implementation ECSQuickRatingForm

- (NSDictionary*)ECSJSONMapping
{
    return @{
             @"formId": @"formId",
             @"formTitle": @"formTitle",
             @"formHeader": @"formHeader",
             @"formDetailText": @"formDetailText",
             @"formPromptText": @"formPromptText",
             @"submitButtonText": @"submitButtonText",
             @"submitCompleteHeaderText": @"submitCompleteHeaderText",
             @"submitCompleteText": @"submitCompleteText",
             };
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSQuickRatingForm *form = [[[self class] allocWithZone:zone] init];
    form.formId = [self.formId copyWithZone:zone];
    form.formTitle = [self.formTitle copyWithZone:zone];
    form.formHeader = [self.formHeader copyWithZone:zone];
    form.formDetailText = [self.formDetailText copyWithZone:zone];
    form.formPromptText = [self.formPromptText copyWithZone:zone];
    form.submitButtonText = [self.submitButtonText copyWithZone:zone];
    form.submitCompleteHeaderText = [self.submitCompleteHeaderText copyWithZone:zone];
    form.submitCompleteText = [self.submitCompleteText copyWithZone:zone];
    
    return form;
}


- (ECSForm*)formValueWithRating:(NSNumber*)rating
{
    ECSForm *form = [ECSForm new];
    form.name = self.formId;
    
    ECSFormItem *formItem = [ECSFormItem new];
    formItem.label = @"rating";
    formItem.formValue = [rating stringValue];
    
    form.formData = @[formItem];
    
    return form;
}

@end
