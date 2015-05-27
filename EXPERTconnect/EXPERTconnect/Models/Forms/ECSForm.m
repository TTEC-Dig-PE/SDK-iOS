//
//  ECSForm.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSForm.h"

#import "ECSFormItem.h"
#import "ECSFormItemClassTransformer.h"

@implementation ECSForm

- (NSDictionary*)ECSJSONMapping
{
    return @{
             @"name": @"name",
             @"inline": @"isInline",
             @"title": @"formTitle",
             @"formSubmitId": @"formSubmitId",
             @"formData": @"formData",
             @"submitText": @"submitText",
             @"submitCompleteText": @"submitCompleteText",
             @"submitCompleteHeaderText": @"submitCompleteHeaderText",
             };
}

- (NSDictionary*)ECSJSONTransformMapping
{
    return @{ @"formData": [ECSFormItemClassTransformer class] };
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSForm *form = [[[self class] allocWithZone:zone] init];
    
    form.name = [self.name copyWithZone:zone];
    form.isInline = self.isInline;
    form.formTitle = [self.formTitle copyWithZone:zone];
    form.formSubmitId = [self.formSubmitId copyWithZone:zone];
    form.formData = [[NSArray alloc] initWithArray:self.formData copyItems:YES];
    form.submitText = [self.submitText copyWithZone:zone];
    form.submitCompleteText = [self.submitCompleteText copyWithZone:zone];
    form.submitCompleteHeaderText = [self.submitCompleteHeaderText copyWithZone:zone];

    return form;
}

- (BOOL)ignoreNilValues
{
    return YES;
}

- (ECSForm*)formResponseValue
{
    ECSForm *form = [ECSForm new];
    form.name = self.name;
    
    NSMutableArray *formItems = [[NSMutableArray alloc] initWithCapacity:self.formData.count];
    
    for (ECSFormItem *formDataItem in self.formData)
    {
        ECSFormItem *formItem = [ECSFormItem new];
        formItem.itemId = formDataItem.itemId;
        
        formItem.formValue = formDataItem.formValue;
        formItem.metadata = formDataItem.metadata;
        [formItems addObject:formItem];
    }
    
    form.formData = formItems;
    
    return form;
}

- (NSString*)inlineFormResponse
{
    NSString *inlineFormResponse = nil;
    if (self.formData.count > 0)
    {
        ECSFormItem *firstItem = self.formData[0];
        NSArray *component = [firstItem.formValue componentsSeparatedByString:@","];
        
        NSMutableString *responseString = [NSMutableString new];
        for (NSString *response in component)
        {
            NSString *fixedResponse = [response stringByReplacingOccurrencesOfString:@"&comma;" withString:@","];
            [responseString appendFormat:@"- %@\n", fixedResponse];
        }
        inlineFormResponse = [responseString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    }
    
    return inlineFormResponse;
}

@end
