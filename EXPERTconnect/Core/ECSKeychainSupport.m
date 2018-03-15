//
//  ECSKeychainSupport.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <Security/Security.h>

#import "ECSKeychainSupport.h"

static const char * kKeychainItemIdentifier = "com.humanify.EXPERTconnect\0";

@implementation ECSKeychainSupport

- (instancetype)init
{
    self = [super init];
    if (self)
    {
    }
    
    return self;
}

- (void)setDeviceId:(NSString *)deviceId
{
    [self setValue:deviceId forKeychainItemWithName:@"DeviceID"];
}

- (NSString *)deviceId
{
    return [self valueForKeychainItemWithName:@"DeviceID"];
}

- (void)setUserToken:(NSString *)userToken
{
    [self setValue:userToken forKeychainItemWithName:@"UserToken"];
}

- (NSString *)userToken
{
    return [self valueForKeychainItemWithName:@"UserToken"];
}

- (BOOL)deleteUserData
{
    return [self deleteKeychainItemWithName:@"UserToken"];
}

- (BOOL)setValue:(NSString*)value forKeychainItemWithName:(NSString*)name
{
    BOOL success = [self deleteKeychainItemWithName:name];
    
    if (value)
    {
        NSMutableDictionary *query = [self queryForKeychainItemWithName:name];
    
        query[(__bridge id)kSecValueData] = [value dataUsingEncoding:NSUTF8StringEncoding];
        
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef) query, NULL);
        
        success = (status == errSecSuccess);
    }
    
    return success;
}

- (BOOL)deleteKeychainItemWithName:(NSString*)name
{
    NSMutableDictionary *query = [self queryForKeychainItemWithName:name];
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);

    return (status == errSecSuccess);
}

- (NSString*)valueForKeychainItemWithName:(NSString*)name
{
    NSMutableDictionary *query = [self queryForKeychainItemWithName:name];
    
    query[(__bridge id)kSecReturnData] = @YES;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    
    CFTypeRef result = nil;
    
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    
    if (status == errSecSuccess && result)
    {
        NSData *data = (__bridge_transfer NSData*)result;
        if (data.length > 0)
        {
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        else
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }
}

- (NSMutableDictionary*)queryForKeychainItemWithName:(NSString*)name
{
    NSMutableDictionary *query = [NSMutableDictionary new];
    query[(__bridge id)(kSecClass)] = (__bridge id)(kSecClassGenericPassword);
    
    NSData *keychainItemId = [NSData dataWithBytes:kKeychainItemIdentifier
                                            length:strlen(kKeychainItemIdentifier)];

    
    query[(__bridge id)kSecAttrService] = keychainItemId;
    query[(__bridge id)kSecAttrAccount] = [name dataUsingEncoding:NSUTF8StringEncoding];
    
    return query;
}


@end
