//
//  ECSListTableViewCell.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSListTableViewCell.h"

#import "ECSCircleImageView.h"
#import "ECSDynamicLabel.h"
#import "ECSInjector.h"
#import "ECSTheme.h"

@interface ECSListTableViewCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *horizontalSeparatorHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *horizontalSeparator;

@end

@implementation ECSListTableViewCell

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
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.horizontalSeparator.backgroundColor = theme.separatorColor;
    self.backgroundColor = theme.secondaryBackgroundColor;
    self.titleLabel.textColor = theme.primaryTextColor;
    self.titleLabel.font = theme.largeBodyFont;
    
    // Add constraint for separator so it's always all the way to the right edge of the cell
    NSLayoutConstraint *horizontalTrailing = [NSLayoutConstraint constraintWithItem:self.horizontalSeparator
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1.0f
                                                                           constant:0.0f];
    [self addConstraint:horizontalTrailing];
    
    self.horizontalSeparatorVisible = YES;
    self.horizontalSeparatorHeightConstraint.constant = (1.0f / [[UIScreen mainScreen] scale]);
}

- (void)setHorizontalSeparatorVisible:(BOOL)horizontalSeparatorVisible
{
    _horizontalSeparatorVisible = horizontalSeparatorVisible;
    
    if (horizontalSeparatorVisible)
    {
        self.horizontalSeparator.alpha = 1.0f;
    }
    else
    {
        self.horizontalSeparator.alpha = 0.0f;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.circleImageView.image != nil)
    {
        self.imageViewWidthConstraint.constant = 40.0f;
        self.imageViewTrailingConstraint.constant = 15.0f;
    }
    else
    {
        self.imageViewWidthConstraint.constant = 0.0f;
        self.imageViewTrailingConstraint.constant = 0.0f;
    }
    
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
    [super layoutSubviews];
}

- (void)prepareForReuse
{
    self.horizontalSeparatorVisible = YES;
    self.enabled = YES;
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;

    self.imageView.alpha = enabled ? 1.0f : 0.4f;
    self.titleLabel.alpha = enabled ? 1.0f : 0.4f;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:(selected && self.enabled)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:(selected && self.enabled) animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:(highlighted && self.enabled)];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:(highlighted && self.enabled) animated:animated];
}

@end
