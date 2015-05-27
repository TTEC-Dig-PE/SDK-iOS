//
//  ECSKeychainSupport.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 ECSKeychainSupport adds helpers for retrieving and saving data in the iOS keychain.
 */
@interface ECSKeychainSupport : NSObject

// The device ID stored in the keychain.  Sets will persist the value to the keychain.
@property (nonatomic, strong) NSString *deviceId;

// The user token stored in the keychain.
@property (nonatomic, strong) NSString *userToken;

/**
 Removes the user token from the keychain and sends a notification to the system indicating that
 the user has been invalided.
 
 @return YES if the deletion was successful
 */
- (BOOL)deleteUserData;

@end
