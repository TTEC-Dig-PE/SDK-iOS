//
//  UIView+ECSNibLoading.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ECSNibLoading)

/**
 Returns a nib with the specified name from the framework bundle
 
 @param nibName the name of the nib
 
 @return the UINib from the bundle
 */
+ (UINib *)nibNamed:(NSString *)nibName;

/**
 Returns the default nib for the view.
 
 @return the UINib from the bundle
 */
+ (UINib *)ecs_nib;

/**
 Creates a new view with the specified nib
 
 @param nib the nib to load the view from
 
 @return the created view
 */
+ (instancetype)ecs_loadInstanceWithNib:(UINib *)nib;

/**
 Creates a new view from the default nib in the framework
 
 @return the created view
 */
+ (instancetype)ecs_loadInstanceFromNib;

@end
