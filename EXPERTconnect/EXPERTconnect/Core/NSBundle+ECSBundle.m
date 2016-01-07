//
//  NSBundle+ECSBundle.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "NSBundle+ECSBundle.h"

static NSString* const ECSBundleIdentifier = @"com.humanify.EXPERTconnect";

@implementation NSBundle (ECSBundle)

+ (NSBundle*)ecs_bundle
{
    return [NSBundle bundleWithIdentifier:ECSBundleIdentifier];
}

+ (NSString*)ecs_bundleVersion
{
    NSDictionary* infoDict = [[NSBundle ecs_bundle] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    return version;
}

+ (NSString*)ecs_buildVersion
{
    NSDictionary* infoDict = [[NSBundle ecs_bundle] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleVersion"];
    return version;
}

@end
