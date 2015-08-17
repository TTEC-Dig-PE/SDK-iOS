//
//  ReachabilityManager.h
//  WebRTCClient
//
//  Created by Ceri Hughes on 01/03/2013.
//  Copyright (c) 2013 Alice Calls Bob. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ReachabilityManagerListener

- (void) reachabilityDetermined:(BOOL)reachability;

@end

@interface ReachabilityManager : NSObject

- (void) addListener:(id<ReachabilityManagerListener>)listener;
- (void) removeListener:(id<ReachabilityManagerListener>)listener;
- (void) registerForReachabilityTo:(NSString*)url;

@end