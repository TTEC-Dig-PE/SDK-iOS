//
//  UIViewController+ECSNibLoading.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "UIViewController+ECSNibLoading.h"

@implementation UIViewController (ECSNibLoading)

+ (instancetype)ecs_loadFromNib
{
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    
    return  [[self.class alloc] initWithNibName:NSStringFromClass(self.class) bundle:bundle];
}
@end
