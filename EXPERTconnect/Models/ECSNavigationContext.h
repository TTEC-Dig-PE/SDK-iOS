//
//  ECSNavigationContext.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONSerializing.h"

/**
 The ECSNavigationContext defines a top level navigation view hierarchy.
 */
@interface ECSNavigationContext : NSObject <ECSJSONSerializing, NSCopying>

// The title of the navigation context
@property (nonatomic, strong) NSString *title;

// An array of ECSNavigationSections containing ECSActionTypes
@property (nonatomic, strong) NSArray *sections;

@end
