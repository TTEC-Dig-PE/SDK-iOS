//
//  ECSViewControllerStack.m
//  EXPERTconnect
//
//  Created by Sam Solomon on 8/17/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSViewControllerStack.h"

@interface ECSViewControllerStack()

@property (nonatomic, strong) NSMutableArray *viewControllers;

@end

@implementation ECSViewControllerStack

- (instancetype)init {
    self = [super init];
    if (self) {
        _viewControllers = [NSMutableArray new];
    }
    return self;
}

- (void)pushViewController:(UIViewController *)viewController {
    [self.viewControllers insertObject:viewController atIndex:0];
}

- (UIViewController *)popViewController {
    if (self.viewControllers.count == 0) {
        return nil;
    }
    
    UIViewController *firstVC = [self.viewControllers firstObject];
    [self.viewControllers removeObjectAtIndex:0];
    return firstVC;
}

- (UIViewController *)topViewController {
    if (self.viewControllers.count == 0) {
        return nil;
    }
    
    UIViewController *firstVC = [self.viewControllers firstObject];
    return firstVC;
}

- (NSInteger)viewControllerCount {
    return [self.viewControllers count];
}

- (BOOL)isEmpty {
    return (self.viewControllers.count == 0) ? YES : NO;
}

@end