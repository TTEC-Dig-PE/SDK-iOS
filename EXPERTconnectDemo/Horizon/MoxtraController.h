//
//  MoxtraPAnel.h
//  IMP
//
//  Created by Nathan Keeney on 6/8/2015
//  Copyright (c) 2015 Humanify. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Moxtra.h"

@interface MoxtraController : NSObject <MXClientMeetDelegate>
- (void)loadContent:(void(^)())successCallback
            failure:(void(^)(NSError *error))failureCallback;
- (void)startMeet:(void(^)(NSString *meetID))successCallback
          failure:(void(^)(NSError *error))failureCallback;
- (void)endMeet;
@end