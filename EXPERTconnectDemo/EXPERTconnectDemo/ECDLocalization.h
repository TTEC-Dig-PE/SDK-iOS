//
//  ECDLocalization.h
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 7/20/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#ifndef EXPERTconnectDemo_ECDLocalization_h
#define EXPERTconnectDemo_ECDLocalization_h

#import <Foundation/Foundation.h>

/**
 ECDLocalization provides methods to load localized strings specific to the Host App.
 */

// Keys used in localization files
static NSString* const ECDLocalizedUnknownUser = @"ECDLocalizedUnknownUser";
static NSString* const ECDLocalizedLoginButton = @"ECDLocalizedLoginButton";
static NSString* const ECDLocalizedRegisterButton = @"ECDLocalizedRegisterButton";
static NSString* const ECDLocalizedSkipRegistrationButton = @"ECDLocalizedSkipRegistrationButton";

/**
 Loads a localized string first from the main bundle and if not found, then defaults to the localized
 string in the application bundle.
 
 @param key the key for the localized string
 @param comment an optional comment describing what the string is used for.
 
 @return a localized string or the key if the string is not found.
 */
FOUNDATION_EXPORT NSString* ECDLocalizedString(NSString *key, NSString *comment);

#endif
