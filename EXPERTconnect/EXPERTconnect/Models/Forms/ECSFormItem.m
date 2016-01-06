//
//  ECSFormItem.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSFormItem.h"

NSString *const ECSFormTypeRadio = @"radio";
NSString *const ECSFormTypeSingle = @"single";
NSString *const ECSFormTypeMultiple = @"multiple";
NSString *const ECSFormTypeCheckbox = @"checkbox";
NSString *const ECSFormTypeText = @"text";
NSString *const ECSFormTypeTextArea = @"textarea";
NSString *const ECSFormTypeSlider = @"slider";
NSString *const ECSFormTypeRange = @"range";
NSString *const ECSFormTypeRating = @"rating";

NSString *const ECSFormTreatmentRating = @"rating";  // 5-Stars Rating Treatment
NSString *const ECSFormTreatmentThumbs = @"thumbs";  // Thumbs Up / Thumbs Down Treatment
NSString *const ECSFormTreatmentFaces = @"faces";    // Happy Face / Sad Face Treatment

NSString *const ECSFormTreatmentFullName = @"full name";
NSString *const ECSFormTreatmentEmail = @"email";
NSString *const ECSFormTreatmentPhoneNumber = @"phone number";
NSString *const ECSFormTreatmentPassword = @"password";

@implementation ECSFormItem

- (NSDictionary*)ECSJSONMapping
{
    return @{
             @"itemId" : @"itemId",
             @"type": @"type",
             @"label" : @"label",
             @"metadata": @"metadata",
             @"treatment": @"treatment",
             @"required": @"required",
             @"configuration": @"configuration",
             @"value": @"formValue"
             };
}

- (BOOL)answered
{
    NSAssert(NO, @"Calling answered on base ECSFormItem is not supported. Must be overriden in subclass.");
    return NO;
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSFormItem *formItem = [[self class] allocWithZone:zone];
    
    formItem.itemId = [self.itemId copyWithZone:zone];
    formItem.type = [self.type copyWithZone:zone];
    formItem.label = [self.label copyWithZone:zone];
    formItem.metadata = [self.metadata copyWithZone:zone];
    formItem.required = [self.required copyWithZone:zone];
    formItem.configuration = [[NSDictionary alloc] initWithDictionary:self.configuration copyItems:YES];
    formItem.treatment = [self.treatment copyWithZone:zone];
    formItem.formValue = [self.formValue copyWithZone:zone];
    
    return formItem;
}

@end
