//
//  ECSPreSurvey.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSPreSurvey.h"

#import "ECSFormItem.h"
#import "ECSForm.h"
#import "ECSPresurveyFormItem.h"

@implementation ECSPreSurvey

- (NSDictionary *)ECSJSONMapping
{
    return @{
             @"formFooter": @"formFooter",
             @"formTitle": @"formTitle",
             @"formHeader": @"formHeader",
             @"formSubHeader": @"formSubHeader",
             @"formName": @"formName",
             @"questions": @"questions"
             };
}

- (NSDictionary *)ECSJSONTransformMapping
{
    return @{ @"questions": [ECSPresurveyFormItem class]};
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSPreSurvey *preSurvey = [[[self class] allocWithZone:zone] init];
    preSurvey.formFooter = [self.formFooter copyWithZone:zone];
    preSurvey.formTitle = [self.formTitle copyWithZone:zone];
    preSurvey.formHeader = [self.formHeader copyWithZone:zone];
    preSurvey.formSubHeader = [self.formSubHeader copyWithZone:zone];
    preSurvey.formName = [self.formName copyWithZone:zone];
    preSurvey.questions = [[NSArray alloc] initWithArray:self.questions copyItems:YES];
    
    return preSurvey;
}

- (ECSForm*)formValue
{
    ECSForm *form = [ECSForm new];
    form.name = self.formName;
    form.submitText = self.formHeader;

    NSMutableArray *formItems = [[NSMutableArray alloc] initWithCapacity:self.questions.count];
    
    for (ECSPresurveyFormItem *presurveyItem in self.questions)
    {
        ECSFormItem *formItem = [ECSFormItem new];
        formItem.label = presurveyItem.name;
        formItem.metadata = presurveyItem.metadata;
        formItem.formValue = presurveyItem.value;
        [formItems addObject:formItem];
    }

    form.formData = formItems;
    
    return form;
}

@end
