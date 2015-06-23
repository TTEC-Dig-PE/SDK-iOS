//
//  ECSNavigationSection.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

/**
 Defined section display types for navigation contexts.
 */
typedef NS_ENUM(NSInteger, ECSNavigationSectionType)
{
    // Displays cells as featured items
    ECSNavigationSectionFeatured,
    
    // Displays cells as single buttons
    ECSNavigationSectionButtons,
    
    // Displays cells as a list style
    ECSNavigationSectionList,
    
    // Displays an ask a question section type
    ECSNavigationSectionQuestion
};

@interface ECSNavigationSection : ECSJSONObject <ECSJSONSerializing, NSCopying>

// Specifies the title to be displayed in the section header
@property (nonatomic, strong) NSString *sectionTitle;

// String representation of the section display type
@property (nonatomic, strong) NSString *sectionTypeString;

// The display type for the section
@property (nonatomic, assign) ECSNavigationSectionType sectionType;

// Array of ECSActionType objects that are to be displayed in this section.
@property (nonatomic, strong) NSArray *items;

/**
 Post import configuration that populates the sectionType property.
 */
- (void)didImportObject;


@end
