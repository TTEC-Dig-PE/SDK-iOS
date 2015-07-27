//
//  Moxtra.h
//  MoxtraSDK
//
// Created by KenYu on 6/16/14.
// Copyright (c) 2013 Moxtra, Inc. All rights reserved.
//
// Check detail information in Moxtra SDK API documents.
//

#import "MXClient.h"


//During development, you will point your app at Moxtra's "sandbox" development environment. When you are ready to test on production, we will upgrade your key. (You can create test accounts on sandbox by just going to sandbox.moxtra.com).
typedef enum enumServerType {
    sandboxServer = 0,
    productionServer
}MXServerType;


//Moxtra API
@interface Moxtra : NSObject

/**
 * Initialize the MoxtraClient app with client ID and client secret.
 * The 3rd party has to set their client ID and client Secret before call any other APIs.
 *
 * @return moxtra client instance.
 *
 * @param clientID
 *            The MoxtraClient app client id.
 * @param clientSecret
 *            The MoxtraClient app client secret.
 * @param serverType
 *            The connecting server type.
 */
+ (id<MXClient>)clientWithApplicationClientID:(NSString*)clientID applicationClientSecret:(NSString*)clientSecret serverType:(MXServerType)serverType;


/**
 * The 3rd party can get the shared moxtra client instance via this API after initialize the MoxtraClient app with client ID and client secret.
 *
 * @return moxtra client instance.
 *
 */
+ (id<MXClient>)sharedClient;

@end


#define MX_IOS_MEET_SDK_VERSION @"v2.1.1"