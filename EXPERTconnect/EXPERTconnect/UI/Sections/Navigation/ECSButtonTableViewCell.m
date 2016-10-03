//
//  ECSButtonTableViewCell.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSButtonTableViewCell.h"

#import "ECSInjector.h"
#import "ECSTheme.h"

@implementation ECSButtonTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    self.button.backgroundColor = theme.primaryColor;
    [self.button setTitleColor:theme.secondaryBackgroundColor forState:UIControlStateNormal];
    
    self.button.layer.cornerRadius = 5.0f;
    self.button.userInteractionEnabled = NO;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted)
    {
        self.button.alpha = 0.5f;
    }
    else
    {
        self.button.alpha = 1.0f;
    }
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    
    self.button.alpha = enabled ? 1.0f : 0.4f;
}

@end
