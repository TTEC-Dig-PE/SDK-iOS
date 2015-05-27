//
//  UIView+ECSNibLoading.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "UIView+ECSNibLoading.h"

@implementation UIView (ECSNibLoading)

+ (UINib *)nibNamed:(NSString *)nibName
{
    return [UINib nibWithNibName:nibName bundle:nil];
}

+ (UINib *)ecs_nib
{
    return [UINib nibWithNibName:NSStringFromClass([self class])
                          bundle:[NSBundle bundleForClass:[self class]]];
}

+ (instancetype)ecs_loadInstanceWithNib:(UINib *)nib
{
    UIView *result = nil;
    NSArray *topLevelObjects = [nib instantiateWithOwner:nil options:nil];
    for (id anObject in topLevelObjects)
    {
        if ([anObject isKindOfClass:[self class]])
        {
            result = anObject;
            break;
        }
    }
    
    return result;
}

+ (instancetype)ecs_loadInstanceFromNib
{
    return [self ecs_loadInstanceWithNib:[self ecs_nib]];
}

@end
