//
//  ECSButton.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSButton.h"

#import "ECSInjector.h"
#import "ECSTheme.h"

@implementation ECSButton

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
    self.layer.cornerRadius = 5.0f;
    
    if(!self.ecsBackgroundColor)
    {
        ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
        self.ecsBackgroundColor = theme.primaryColor;
    }
    
    self.backgroundColor = self.ecsBackgroundColor;
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.contentEdgeInsets = UIEdgeInsetsMake(10, 15, 10, 15);
}

- (void)setEcsBackgroundColor:(UIColor *)backgroundColor
{
    _ecsBackgroundColor = backgroundColor;
    self.backgroundColor = self.ecsBackgroundColor;
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    float alpha = enabled ? 1.0 : 0.5;
    self.backgroundColor = [self.ecsBackgroundColor colorWithAlphaComponent:alpha];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    self.backgroundColor = highlighted ? theme.secondaryButtonColor : self.ecsBackgroundColor;
}
@end
