//
//  ECSFeaturedTableViewCell.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSFeaturedTableViewCell.h"

#import "ECSCircleImageView.h"
#import "ECSDynamicLabel.h"
#import "ECSTheme.h"
#import "ECSInjector.h"

@interface ECSFeaturedTableViewCell()
{
    BOOL _isInitializing;
    NSInteger _selectedItem;
}

@property (weak, nonatomic) IBOutlet UIView *verticalDivider;
@property (weak, nonatomic) IBOutlet UIView *horizontalDivider;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSeparatorWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *horizontalSeparatorHeightConstraint;

@property (assign, nonatomic) CGPoint lastTouchPoint;

@end

@implementation ECSFeaturedTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];

    self.featuredBackgroundColor = [theme secondaryBackgroundColor];
    self.contentView.backgroundColor = [theme secondaryBackgroundColor];
    self.leftFeaturedView.backgroundColor = self.featuredBackgroundColor;
    self.rightFeaturedView.backgroundColor = self.featuredBackgroundColor;
    _featuredBackgroundColor = [theme secondaryBackgroundColor];
    _selectedBackgroundColor = [theme primaryBackgroundColor];
    _highlightedTitleTextColor = [theme primaryTextColor];
    _titleTextColor = [theme primaryTextColor];
    _selectedItem = 0;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.titleTextColor = theme.primaryTextColor;
    self.verticalSeparatorWidthConstraint.constant = (1.0f / [[UIScreen mainScreen] scale]);
    self.horizontalSeparatorHeightConstraint.constant = (1.0f / [[UIScreen mainScreen] scale]);
    self.leftFeaturedView.backgroundColor = theme.secondaryBackgroundColor;
    self.rightFeaturedView.backgroundColor = theme.secondaryBackgroundColor;
    self.leftImageView.backgroundColor = theme.primaryColor;
    self.rightImageView.backgroundColor = theme.primaryColor;
    self.leftTitleLabel.font = theme.buttonFont;
    self.rightTitleLabel.font = theme.buttonFont;
    
    self.verticalDivider.backgroundColor = theme.separatorColor;
    self.horizontalDivider.backgroundColor = theme.separatorColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.leftTitleLabel.preferredMaxLayoutWidth = self.leftTitleLabel.frame.size.width;
    self.rightTitleLabel.preferredMaxLayoutWidth = self.rightTitleLabel.frame.size.width;
    [super layoutSubviews];
    
}
- (NSInteger)selectedIndex
{
    return _selectedItem;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (!selected)
    {
        [self removeHighlights];
    }
    else
    {
        if (self.leftViewEnabled && CGRectContainsPoint(self.leftFeaturedView.frame, self.lastTouchPoint))
        {
            _selectedItem = 0;
        }
        else if (self.rightViewEnabled && CGRectContainsPoint(self.rightFeaturedView.frame, self.lastTouchPoint))
        {
            _selectedItem = 1;
        }
        else
        {
            _selectedItem = -1;
        }
        
        [self setHighlightsForTouchPoint:self.lastTouchPoint];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (!highlighted)
    {
        [self removeHighlights];
    }
    else
    {
        [self setHighlightsForTouchPoint:self.lastTouchPoint];
    }

}

- (void)setHighlightsForTouchPoint:(CGPoint)touchPoint
{
    if (self.leftViewEnabled && CGRectContainsPoint(self.leftFeaturedView.frame, touchPoint))
    {
        [self.leftFeaturedView setBackgroundColor:self.selectedBackgroundColor];
        [self.leftTitleLabel setTextColor:self.highlightedTitleTextColor];
        [self.rightFeaturedView setBackgroundColor:self.featuredBackgroundColor];
        [self.rightTitleLabel  setTextColor:self.titleTextColor];
    }
    else if (self.rightViewEnabled && CGRectContainsPoint(self.rightFeaturedView.frame, touchPoint))
    {
        [self.leftFeaturedView setBackgroundColor:self.featuredBackgroundColor];
        [self.leftTitleLabel setTextColor:self.titleTextColor];
        [self.rightFeaturedView setBackgroundColor:self.selectedBackgroundColor];
        [self.rightTitleLabel  setTextColor:self.highlightedTitleTextColor];
    }
}

- (void)removeHighlights
{
    [self.leftFeaturedView setBackgroundColor:self.featuredBackgroundColor];
    [self.leftTitleLabel setTextColor:self.titleTextColor];
    [self.rightFeaturedView setBackgroundColor:self.featuredBackgroundColor];
    [self.rightTitleLabel  setTextColor:self.titleTextColor];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    self.lastTouchPoint = [touch locationInView:self.contentView];
    [super touchesBegan:touches withEvent:event];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    self.lastTouchPoint = [touch locationInView:self.contentView];

    [self setHighlighted:YES animated:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    self.lastTouchPoint = [touch locationInView:self.contentView];
    [super touchesEnded:touches withEvent:event];
}

- (void)setFeaturedBackgroundColor:(UIColor *)backgroundColor
{
    _featuredBackgroundColor = backgroundColor;
    [self.contentView setBackgroundColor:backgroundColor];
}

- (void)setSelectedBackgroundColor:(UIColor *)selectedBackgroundColor
{
    _selectedBackgroundColor = selectedBackgroundColor;
}

- (void)setTitleTextColor:(UIColor *)titleTextColor
{
    _titleTextColor = titleTextColor;
    [self.leftTitleLabel setTextColor:titleTextColor];
    [self.rightTitleLabel setTextColor:titleTextColor];
}

- (void)setLeftViewEnabled:(BOOL)leftViewEnabled
{
    _leftViewEnabled = leftViewEnabled;
    
    self.leftFeaturedView.alpha = _leftViewEnabled ? 1.0f : 0.4f;
}

- (void)setRightViewEnabled:(BOOL)rightViewEnabled
{
    _rightViewEnabled = rightViewEnabled;
    
     self.rightFeaturedView.alpha = _rightViewEnabled ? 1.0f : 0.4f;
}

@end
