//
//  ECSModalStackManager.h
//  EXPERTconnect
//
//  Created by Sam Solomon on 8/17/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface ECSModalStackManager : NSObject

- (void)pushViewController:(UIViewController *)viewController;
- (UIViewController *)popViewController;
- (UIViewController *)topViewController;

- (BOOL)isEmpty;
- (NSInteger)viewControllerCount;

@end