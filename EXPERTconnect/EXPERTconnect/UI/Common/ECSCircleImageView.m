//
//  ECSCircleImageView.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSCircleImageView.h"

#import "ECSCachingImageView.h"

@implementation ECSCircleImageView

- (void)layoutSubviews
{
    self.clipsToBounds = YES;
    self.layer.cornerRadius = CGRectGetWidth(self.frame) / 2.0f;
    [super layoutSubviews];
    
}

@end
