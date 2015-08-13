//
//  ECSCafeXController.h
//  EXPERTconnect
//
//  Created by Nathan Keeney on 8/12/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#ifndef EXPERTconnect_ECSCafeXController_h
#define EXPERTconnect_ECSCafeXController_h

#import <ACBClientSDK/ACBUC.h>

@interface ECSCafeXController : NSObject <ACBUCDelegate, ACBClientCallDelegate, ACBClientPhoneDelegate> {
    ACBUC *cafeXConnection;
    NSString *username;
    NSString *configuration; // Session ID
    NSString *server; // TODO: Store somewhere
    NSString *port; // TODO: Store somewhere
}
- (BOOL)hasCafeXSession;
- (void)setupCafeXSession;
- (void)endCafeXSession;

+ (void)requestCameraAccess;

@end

#endif
