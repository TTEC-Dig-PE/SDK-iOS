//
//  ECSFormItem.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

FOUNDATION_EXPORT NSString *const ECSFormTypeRadio;
FOUNDATION_EXPORT NSString *const ECSFormTypeCheckbox;
FOUNDATION_EXPORT NSString *const ECSFormTypeSingle;
FOUNDATION_EXPORT NSString *const ECSFormTypeMultiple;
FOUNDATION_EXPORT NSString *const ECSFormTypeText;
FOUNDATION_EXPORT NSString *const ECSFormTypeTextArea;
FOUNDATION_EXPORT NSString *const ECSFormTypeSlider;
FOUNDATION_EXPORT NSString *const ECSFormTypeRange;
FOUNDATION_EXPORT NSString *const ECSFormTypeRating;

FOUNDATION_EXPORT NSString *const ECSFormTypeSliderTreatmentRating;
FOUNDATION_EXPORT NSString *const ECSFormTypeSliderTreatmentThumbs;
FOUNDATION_EXPORT NSString *const ECSFormTypeSliderTreatmentFaces;

FOUNDATION_EXPORT NSString *const ECSFormTreatmentFullName;
FOUNDATION_EXPORT NSString *const ECSFormTreatmentEmail;
FOUNDATION_EXPORT NSString *const ECSFormTreatmentPhoneNumber;
FOUNDATION_EXPORT NSString *const ECSFormTreatmentPassword;

/**
 ECSFormItem is the base type for various different types of form items.
 */
@interface ECSFormItem : ECSJSONObject <ECSJSONSerializing, NSCopying>

// itemId
@property (nonatomic, strong) NSString* itemId;

// The specified type of the form item
@property (nonatomic, strong) NSString *type;

// Label to display with the form item.
@property (nonatomic, strong) NSString* label;

// Metadata that is used to map server side items to other data should be sent in form responses.
@property (nonatomic, strong) NSString* metadata;

// Specifies that this form item requires a response
@property (nonatomic, strong) NSNumber* required;

// Optional treatment for styling this particular type of control
@property (nonatomic, strong) NSString *treatment;

// Type-specific configuration for this form item
@property (nonatomic, strong) NSDictionary* configuration;

// Whether or not this question has been answered. Must be defined in overrideen class
@property (nonatomic, assign, readonly) BOOL answered;

// Value that is already filled in the form
@property (nonatomic, strong) NSString *formValue;

@end
