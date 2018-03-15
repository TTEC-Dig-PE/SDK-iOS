//
//  ECSFormItemClassTransformer.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSFormItemClassTransformer.h"

#import "ECSFormItem.h"

#import "ECSFormItemCheckbox.h"
#import "ECSFormItemRadio.h"
#import "ECSFormItemRating.h"
#import "ECSFormItemSlider.h"
#import "ECSFormItemText.h"
#import "ECSFormItemTextArea.h"

@implementation ECSFormItemClassTransformer

- (Class)defaultTransformClass
{
    return [ECSFormItem class];
}

- (Class)classForJSONObject:(NSDictionary *)jsonDictionary
{
    NSString* type = jsonDictionary[@"type"];
    if([type isEqualToString:ECSFormTypeCheckbox] || [type isEqualToString:ECSFormTypeMultiple])
    {
        return [ECSFormItemCheckbox class];
    }
    else if([type isEqualToString:ECSFormTypeRadio] || [type isEqualToString:ECSFormTypeSingle])
    {
        return [ECSFormItemRadio class];
    }
    else if([type isEqualToString:ECSFormTypeRating])
    {
        return [ECSFormItemRating class];
    }
    else if([type isEqualToString:ECSFormTypeSlider] || [type isEqualToString:ECSFormTypeRange])
    {
        return [ECSFormItemSlider class];
    }
    else if([type isEqualToString:ECSFormTypeText] || [type isEqualToString:@"date"])
    {
        return [ECSFormItemText class];
    }
    else if([type isEqualToString:ECSFormTypeTextArea])
    {
        return [ECSFormItemTextArea class];
    }
    
    return [self defaultTransformClass];
}

@end
