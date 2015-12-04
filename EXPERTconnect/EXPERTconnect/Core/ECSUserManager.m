//
//  ECSUserManager.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//
#import "ECSUserManager.h"
#import "CommonCrypto/CommonDigest.h"
#import "ECSKeychainSupport.h"
#import "ECSNotifications.h"

static NSString* const ECSUserDisplayNameKey = @"com.humanify.userDisplayName";
static NSString* const ECSUserAvatarKey = @"com.humanify.userAvatar";

@interface ECSUserManager()
{
    NSString *_deviceID;
    NSString *_userToken;
}

@property (strong, nonatomic) ECSKeychainSupport *keychain;

@end

@implementation ECSUserManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.keychain = [ECSKeychainSupport new];
        if (!self.keychain.deviceId)
        {
            self.keychain.deviceId = [self generateDeviceId];
        }
        
        _deviceID = self.keychain.deviceId;
        _userToken = self.keychain.userToken;
    }
    
    return self;
}

- (NSString *)deviceID
{
    if (!_deviceID)
    {
        _deviceID = self.keychain.deviceId;
    }
    return _deviceID;
}

- (NSString *)userToken
{
    if (!_userToken)
    {
        _userToken = self.keychain.userToken;
    }
    
    return _userToken;
}

- (void)setUserToken:(NSString *)userToken
{
    _userToken = userToken;
    self.keychain.userToken = userToken;
}

- (BOOL)isUserAuthenticated
{
    return _userToken != nil;
}

- (void)unauthenticateUser
{
    ECSKeychainSupport *keychain = [ECSKeychainSupport new];
    
    [keychain deleteUserData];
    _userToken = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ECSUserDisplayNameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:ECSUserSessionInvalidNotification object:nil];
}

- (NSString*)userDisplayName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:ECSUserDisplayNameKey];
}

- (void)setUserDisplayName:(NSString *)userDisplayName
{
    [[NSUserDefaults standardUserDefaults] setObject:userDisplayName forKey:ECSUserDisplayNameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIImage *)userAvatar
{
    if(![[NSUserDefaults standardUserDefaults] objectForKey:ECSUserAvatarKey]) return nil;
    
    NSData* imageData = [[NSUserDefaults standardUserDefaults] objectForKey:ECSUserAvatarKey];
    return [UIImage imageWithData:imageData];
}
- (void)setUserAvatar:(UIImage *)userAvatar
{
    [[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(userAvatar) forKey:ECSUserAvatarKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*)generateDeviceId
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfstring = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    const char *cStr = CFStringGetCStringPtr(cfstring, CFStringGetFastestEncoding(cfstring));
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int)strlen(cStr), result );
    CFRelease(uuid);
    CFRelease(cfstring);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

@end
