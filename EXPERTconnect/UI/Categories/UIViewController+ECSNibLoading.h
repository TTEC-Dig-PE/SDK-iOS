//
//  UIViewController+ECSNibLoading.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ECSNibLoading)

/**
 Creates a new view controller using the default nib in the framework bundle.
 
 @return a new view controller
 */
+ (instancetype)ecs_loadFromNib;

@end
