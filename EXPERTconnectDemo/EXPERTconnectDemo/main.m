//
//  main.m
//  EXPERTconnectDemo
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "HZAppDelegate.h"


static int const startExpertDemo = 0;
//static int const startHorizonDemo = 1;  // unused variable

static NSString *const applicationRunMode = @"applicationRunMode";

int main(int argc, char * argv[]) {
    @autoreleasepool {

        
        int demo_mode = [[[NSUserDefaults standardUserDefaults] objectForKey:applicationRunMode] intValue];
        
#ifdef HORIZON_TARGET
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([HZAppDelegate class]));
#endif
        
        switch (demo_mode) {
            case startExpertDemo:
                // [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:startHorizonDemo] forKey:applicationRunMode];
                return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
                break;
                
            default:
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:startExpertDemo] forKey:applicationRunMode];
                return UIApplicationMain(argc, argv, nil, NSStringFromClass([HZAppDelegate class]));
                break;

        }
    }
}

