//
//  ECSFormItemViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSFormItemViewController.h"

#import "ECSFormItem.h"
#import "ECSLocalization.h"
#import "UIViewController+ECSNibLoading.h"

#import "ECSRadioFormItemViewController.h"
#import "ECSRatingFormItemViewController.h"
#import "ECSTextFormItemViewController.h"
#import "ECSCheckboxFormItemViewController.h"
#import "ECSSliderFormItemViewController.h"
#import "ECSTextAreaFormItemViewController.h"

@interface ECSFormItemViewController ()

@end

@implementation ECSFormItemViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSString*)defaultCaptionText
{
    if(self.formItem.required)
    {
        return ECSLocalizedString(ECSLocalizeRequiredKey, @"Required");
    }
    else
    {
        return ECSLocalizedString(ECSLocalizeOptionalKey, @"Optional");
    }
}

+ (ECSFormItemViewController*)viewControllerForFormItem:(ECSFormItem*)formItem
{
    NSString* type = formItem.type;
    ECSFormItemViewController* vc;
    if([type isEqualToString:ECSFormTypeRadio])
    {
        vc = [ECSRadioFormItemViewController ecs_loadFromNib];
    }
    else if([type isEqualToString:ECSFormTypeRating])
    {
        vc = [ECSRatingFormItemViewController ecs_loadFromNib];
    }
    else if([type isEqualToString:ECSFormTypeText] || [type isEqualToString:@"date"])
    {
        vc = [ECSTextFormItemViewController ecs_loadFromNib];
    }
    else if([type isEqualToString:ECSFormTypeCheckbox] || [type isEqualToString:ECSFormTypeSingle] ||
            [type isEqualToString:ECSFormTypeMultiple])
    {
        vc = [ECSCheckboxFormItemViewController ecs_loadFromNib];
    }
    else if([type isEqualToString:ECSFormTypeSlider])
    {
        vc = [ECSSliderFormItemViewController ecs_loadFromNib];
    }
    else if([type isEqualToString:ECSFormTypeTextArea])
    {
        vc = [ECSTextAreaFormItemViewController ecs_loadFromNib];
    }
    else
    {
        vc = [[ECSFormItemViewController alloc] init];
    }
    
    vc.formItem = formItem;
    return vc;
}

@end
