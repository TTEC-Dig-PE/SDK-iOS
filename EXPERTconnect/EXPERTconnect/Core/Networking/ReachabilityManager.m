//
//  ReachabilityManager.m
//  WebRTCClient
//
//  Created by Ceri Hughes on 01/03/2013.
//  Copyright (c) 2013 Alice Calls Bob. All rights reserved.
//

#import "ReachabilityManager.h"
#import <SystemConfiguration/SCNetworkReachability.h>

typedef enum
{
	ReachabilityManagerConnectivityNone,
	ReachabilityManagerConnectivityWifi,
	ReachabilityManagerConnectivityWwan
}
ReachabilityManagerConnectivity;

@interface ReachabilityManager()

@property ReachabilityManagerConnectivity connectivity;
@property (retain) NSMutableArray *listeners;

- (void) networkReachabilityFlagsChanged:(SCNetworkReachabilityFlags)flags forTarget:(SCNetworkReachabilityRef)target;

@end

static void networkReachabilityCallBack(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
	ReachabilityManager *instance = (__bridge ReachabilityManager *)(info);
	[instance networkReachabilityFlagsChanged:flags forTarget:target];
}

@implementation ReachabilityManager
{
    SCNetworkReachabilityContext _proxyReachabilityContext;
    SCNetworkReachabilityRef _proxyReachability;
}

- (id) init
{
    if (self = [super init])
    {
        self.connectivity = ReachabilityManagerConnectivityNone;
        self.listeners = [NSMutableArray array];
    }
    return self;
}

-(void) dealloc
{
    NSLog(@"Releasing ReachabilityManager");
    
    [self.listeners removeAllObjects];
    
    if (_proxyReachability != NULL)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(_proxyReachability, CFRunLoopGetCurrent(),kCFRunLoopDefaultMode);
        _proxyReachability = NULL;
        _proxyReachabilityContext.info = NULL;
    }
}

- (void) addListener:(id<ReachabilityManagerListener>)listener
{
    [self.listeners addObject:listener];
}

- (void) removeListener:(id<ReachabilityManagerListener>)listener
{
    [self.listeners removeObject:listener];
}

- (void) informListenersOfReachability:(BOOL)reachability
{
    for (id<ReachabilityManagerListener> listener in self.listeners)
    {
        [listener reachabilityDetermined:reachability];
    }
}

- (void) registerForReachabilityTo:(NSString *)url
{
    _proxyReachability = SCNetworkReachabilityCreateWithName(NULL, [url cStringUsingEncoding:NSUTF8StringEncoding]);
    
    if (_proxyReachability != NULL)
    {
        SCNetworkReachabilityFlags reachabilityFlags;
        // If reachability information is available now, we don't get notification until it changes.
        if (SCNetworkReachabilityGetFlags (_proxyReachability, &reachabilityFlags))
        {
            networkReachabilityCallBack(_proxyReachability, reachabilityFlags, (__bridge void *)(self));
        }

        _proxyReachabilityContext.info = (__bridge void *)(self);
        SCNetworkReachabilitySetCallback(_proxyReachability, (SCNetworkReachabilityCallBack)networkReachabilityCallBack, &_proxyReachabilityContext);
        SCNetworkReachabilityScheduleWithRunLoop(_proxyReachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}

- (void) logNetworkFlags:(SCNetworkReachabilityFlags)flags
{
	NSString* string;
	if (flags == 0)
    {
		string = @" None";
	}
    else
    {
		string = @"";
		if (flags & kSCNetworkReachabilityFlagsTransientConnection)
        {
			string = [string stringByAppendingString:@" TransientConnection"];
		}
		if (flags & kSCNetworkReachabilityFlagsReachable)
        {
			string = [string stringByAppendingString:@" Reachable"];
		}
		if (flags & kSCNetworkReachabilityFlagsConnectionRequired)
        {
			string = [string stringByAppendingString:@" ConnectionRequired"];
		}
		if (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)
        {
			string = [string stringByAppendingString:@" ConnectionOnTraffic"];
		}
		if (flags & kSCNetworkReachabilityFlagsInterventionRequired)
        {
			string = [string stringByAppendingString:@" InterventionRequired"];
		}
		if (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)
        {
			string = [string stringByAppendingString:@" ConnectionOnDemand"];
		}
		if (flags & kSCNetworkReachabilityFlagsIsLocalAddress)
        {
			string = [string stringByAppendingString:@" IsLocalAddress"];
		}
		if (flags & kSCNetworkReachabilityFlagsIsDirect)
        {
			string = [string stringByAppendingString:@" IsDirect"];
		}
		if (flags & kSCNetworkReachabilityFlagsIsWWAN)
        {
			string = [string stringByAppendingString:@" IsWWAN"];
		}
	}
	NSLog(@"Reachability callback - Network connection flags:%@", string);
}

- (void) networkReachabilityFlagsChanged:(SCNetworkReachabilityFlags)flags forTarget:(SCNetworkReachabilityRef)target
{
    ReachabilityManagerConnectivity nwc;
    [self logNetworkFlags:flags];

    if ((flags == 0)
        | (flags & (kSCNetworkReachabilityFlagsConnectionRequired
        | kSCNetworkReachabilityFlagsConnectionOnTraffic)))
    {
        nwc = ReachabilityManagerConnectivityNone;
    }
    else
    {
        nwc = flags & kSCNetworkReachabilityFlagsIsWWAN ? ReachabilityManagerConnectivityWwan : ReachabilityManagerConnectivityWifi;
    }

    NSLog(@"Reachability: %@", (nwc == ReachabilityManagerConnectivityNone) ? @"none" : (nwc == ReachabilityManagerConnectivityWifi) ? @"wifi" : @"wwan");

    if (self.connectivity != nwc)
    {
        [self informListenersOfReachability:NO];
        if (nwc != ReachabilityManagerConnectivityNone)
        {
            [self informListenersOfReachability:YES];
        }
    }
    self.connectivity = nwc;
}

@end