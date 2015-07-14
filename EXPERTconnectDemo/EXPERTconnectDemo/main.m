//
//  main.m
//  EXPERTconnectDemo
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "HZAppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        
#ifdef HORIZON_TARGET
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([HZAppDelegate class]));
#else
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
#endif
    }
}

