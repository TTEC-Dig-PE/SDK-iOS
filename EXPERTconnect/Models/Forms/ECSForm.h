//
//  ECSForm.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

/**
 ECSForm contains the basic information for creating and submitting a form,
 including all form items.
 */
@interface ECSForm : ECSJSONObject <ECSJSONSerializing, NSCopying>

// Name of the form
@property(nonatomic, strong) NSString* name;

// Title for the form
@property (nonatomic, strong) NSString *formTitle;

// Determines if the form should be displayed inline
@property (nonatomic, assign) BOOL isInline;

// Submission id for posting the form back to the endpoint
@property(nonatomic, strong) NSString* formSubmitId;

// Collection of ECSFormItems
@property(nonatomic, strong) NSArray* formData;

// The text for the Submit button of the form.
@property (nonatomic, strong) NSString* submitText;

// The text for the submit complete header text
@property (nonatomic, strong) NSString* submitCompleteHeaderText;

// The text for the submit complete body text
@property (nonatomic, strong) NSString* submitCompleteText;

// Indicates if this form had been submitted by the user.
@property (nonatomic, assign) BOOL submitted;

- (ECSForm*)formResponseValue;

- (NSString*)inlineFormResponse;

@end
