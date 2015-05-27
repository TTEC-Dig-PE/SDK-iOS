//
//  NSBundle+ECSBundle.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (ECSBundle)

/**
 Retrieves the current SDK bundle.
 
 @return the bundle for the SDK.
 */
+ (NSBundle*)ecs_bundle;

/**
 Retrieves the current version of the SDK bundle.
 
 @return the bundle version.
 */
+ (NSString*)ecs_bundleVersion;

@end
