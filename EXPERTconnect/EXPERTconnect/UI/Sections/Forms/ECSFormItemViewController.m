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
#import "ECSAxRatingFormItemViewController.h"
#import "ECSTextFormItemViewController.h"
#import "ECSCheckboxFormItemViewController.h"
#import "ECSSliderFormItemViewController.h"
#import "ECSTextAreaFormItemViewController.h"
#import "ECSBinaryImageViewController.h"

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
    NSString *type = formItem.type;
    NSString *treatment = formItem.treatment;
    ECSFormItemViewController* vc;
    
    if([type isEqualToString:ECSFormTypeRadio])
    {
        if ([treatment isEqualToString:ECSFormTreatmentThumbs]) {
            // Do stuff
            //vc = [ECSThumbsRatingFormItemViewController ecs_loadFromNib];
            vc = [ECSBinaryImageViewController ecs_loadFromNib]; 
        } else {
            vc = [ECSRadioFormItemViewController ecs_loadFromNib];
        }
    }
    else if([type isEqualToString:ECSFormTypeRating])
    {
        vc = [ECSRatingFormItemViewController ecs_loadFromNib];
        // vc = [ECSAxRatingFormItemViewController ecs_loadFromNib];
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
        // [US4545:TA10863] - Modify SDK to have two levels of UI Controls, Type and Treatment (Slider, Rating)
        //
        //NSString *treatment = formItem.treatment;
        
        if([treatment isEqualToString:ECSFormTreatmentRating])
        {
            vc = [ECSAxRatingFormItemViewController ecs_loadFromNib];
        }
        // else if([treatment isEqualToString:ECSFormTypeSliderTreatmentThumbs])
        // {
        //     vc = [ECSThumbsRatingFormItemViewController ecs_loadFromNib];
        // }
        // else if([treatment isEqualToString:ECSFormTypeSliderTreatmentFaces])
        // {
        //     vc = [ECSFacesRatingFormItemViewController ecs_loadFromNib];
        // }
        else
        {
            vc = [ECSSliderFormItemViewController ecs_loadFromNib];
        }
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
