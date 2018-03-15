//
//  ECSCallbackSetupResponse.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSCallbackSetupResponse.h"

@implementation ECSCallbackSetupResponse

- (NSDictionary*)ECSJSONMapping
{
    return @{
             @"callId": @"callID",
             @"estimatedWaitTime": @"estimatedWaitTime"
             };
}

@end
