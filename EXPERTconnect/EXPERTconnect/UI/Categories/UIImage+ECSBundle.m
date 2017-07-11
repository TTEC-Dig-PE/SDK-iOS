//
//  UIImage+ECSBundle.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "UIImage+ECSBundle.h"
#import "EXPERTconnect.h"

@implementation UIImage (ECSBundle)

+ (UIImage*)ecs_bundledImageNamed:(NSString*)imageName {
    
    UIImage *image = [UIImage imageNamed:imageName inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil];
    
    if (!image) {
        
        image = [UIImage imageNamed:imageName
                           inBundle:[NSBundle bundleWithIdentifier:@"com.humanify.EXPERTconnect"]
      compatibleWithTraitCollection:nil];
        
    }
    
    // Cocoapods
    if(!image) {
        
        NSBundle *bundle = [NSBundle bundleForClass:[EXPERTconnect class]];
        NSURL *bundleURL = [[bundle resourceURL] URLByAppendingPathComponent:@"EXPERTconnect.bundle"];
        NSBundle *resourceBundle = [NSBundle bundleWithURL:bundleURL];
        
        image = [UIImage imageNamed:imageName inBundle:resourceBundle compatibleWithTraitCollection:nil];
        
    }

    return image;
}
@end
