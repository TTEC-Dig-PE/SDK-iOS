//
//  ECSBorderContainerView.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSBorderContainerView.h"

#import "ECSInjector.h"
#import "ECSTheme.h"

@interface ECSBorderContainerView()

@property (strong, nonatomic) UIView *topBorder;
@property (strong, nonatomic) UIView *bottomBorder;

@end

@implementation ECSBorderContainerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    self.topBorder = [[UIView alloc] initWithFrame:CGRectZero];
    self.topBorder.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.topBorder];
    
    NSArray *topHorizontalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"|[top]|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:@{@"top": self.topBorder}];
    NSLayoutConstraint *topPin = [NSLayoutConstraint constraintWithItem:self.topBorder
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0f
                                                               constant:0.0f];
    NSLayoutConstraint *topHeight = [NSLayoutConstraint constraintWithItem:self.topBorder
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0f
                                                                  constant:0.5f];
    
    [self.topBorder addConstraint:topHeight];
    [self addConstraints:topHorizontalConstraint];
    [self addConstraint:topPin];
    
    self.bottomBorder = [[UIView alloc] initWithFrame:CGRectZero];
    self.bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.bottomBorder];
    
    NSArray *bottomHorizontalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"|[bottom]|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:@{@"bottom": self.bottomBorder}];
    NSLayoutConstraint *bottomPin = [NSLayoutConstraint constraintWithItem:self.bottomBorder
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0f
                                                               constant:0.0f];
    NSLayoutConstraint *bottomHeight = [NSLayoutConstraint constraintWithItem:self.bottomBorder
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0f
                                                                  constant:0.5f];
    [self.bottomBorder addConstraint:bottomHeight];
    [self addConstraints:bottomHorizontalConstraint];
    [self addConstraint:bottomPin];

    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.topBorder.backgroundColor = theme.separatorColor;
    self.bottomBorder.backgroundColor = theme.separatorColor;

    self.backgroundColor = theme.secondaryBackgroundColor;
}

@end
