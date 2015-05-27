//
//  ECSNavigationSection.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSNavigationSection.h"

#import "ECSActionType.h"
#import "ECSActionTypeClassTransformer.h"

static NSString *const ECSNavigationSectionFeaturedString = @"featured";
static NSString *const ECSNavigationSectionQuestionString = @"question";
static NSString *const ECSNavigationSectionButtonsString = @"buttons";
static NSString *const ECSNavigationSectionListString = @"list";

@implementation ECSNavigationSection

- (NSDictionary *)ECSJSONMapping
{
    return @{
             @"sectionTitle": @"sectionTitle",
             @"sectionType": @"sectionTypeString",
             @"items": @"items",
             };
}

- (NSDictionary *)ECSJSONTransformMapping
{
    return @{@"items": [ECSActionTypeClassTransformer class]};
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSNavigationSection *section = [[[self class] allocWithZone:zone] init];
    section.sectionTitle = [self.sectionTitle copyWithZone:zone];
    section.sectionTypeString = [self.sectionTypeString copyWithZone:zone];
    section.items = [self.items copyWithZone:zone];
    
    return section;
}

- (void)didImportObject
{
    // Convert section type string to an enumeration
    self.sectionType = ECSNavigationSectionList;
    
    if ([self.sectionTypeString isEqualToString:ECSNavigationSectionFeaturedString])
    {
        self.sectionType = ECSNavigationSectionFeatured;
    }
    else if ([self.sectionTypeString isEqualToString:ECSNavigationSectionQuestionString])
    {
        self.sectionType = ECSNavigationSectionQuestion;
    }
    else if ([self.sectionTypeString isEqualToString:ECSNavigationSectionButtonsString])
    {
        self.sectionType = ECSNavigationSectionButtons;
    }
}
@end
