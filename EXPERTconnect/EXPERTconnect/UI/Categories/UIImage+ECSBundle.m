//
//  UIImage+ECSBundle.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "UIImage+ECSBundle.h"

@implementation UIImage (ECSBundle)

+ (UIImage*)ecs_bundledImageNamed:(NSString*)imageName
{
    UIImage *image = [UIImage imageNamed:imageName inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil];
    
    if (!image)
    {
        image = [UIImage imageNamed:imageName
                           inBundle:[NSBundle bundleWithIdentifier:@"com.humanify.EXPERTconnect"]
      compatibleWithTraitCollection:nil];
    }

    return image;
}
@end
