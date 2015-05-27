//
//  ECSChatTableViewCell.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatCellBackground.h"

#import "ECSDynamicLabel.h"
#import "ECSInjector.h"
#import "ECSTheme.h"


@interface ECSChatCellBackground()


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *messageWidthConstraint;

@property (strong, nonatomic) NSLayoutConstraint *messageBoxHorizontalAlignConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorContstraint;

@end

@implementation ECSChatCellBackground

- (void)awakeFromNib {
    // Initialization code
    [self setup];
    
    self.messageWidthConstraint = [NSLayoutConstraint constraintWithItem:self.messageContainerView attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationLessThanOrEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:0.5 constant:0.0f];
    [self addConstraint:self.messageWidthConstraint];
    
    [self configureConstraints];
}

- (void)setup
{
    [self setUserMessage:NO];
}

- (void)setUserMessage:(BOOL)userMessage
{
    _userMessage = userMessage;
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    if (_userMessage)
    {
        self.messageContainerView.backgroundColor = theme.userChatBackground;
    }
    else
    {
        self.messageContainerView.backgroundColor = theme.secondaryBackgroundColor;
    }
    
    self.responseContainerView.backgroundColor = theme.userChatBackground;
    
    [self configureConstraints];
}

- (void)setShowAvatar:(BOOL)showAvatar
{
    _showAvatar = showAvatar;
    if (_showAvatar)
    {
        [self.avatarImageView setAlpha:1.0f];
    }
    else
    {
        [self.avatarImageView setAlpha:0.0f];
    }
    
    [self configureConstraints];
}

- (void)configureConstraints
{
    self.avatarWidthConstraint.constant = (!self.isUserMessage && self.showAvatar) ? 40.0f : 0.0f;
    
    [self removeConstraint:self.messageBoxHorizontalAlignConstraint];
    
    if (self.isUserMessage)
    {
        self.messageBoxHorizontalAlignConstraint = [NSLayoutConstraint constraintWithItem:self.messageContainerView
                                                                                attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-15.0f];
        [self addConstraint:self.messageBoxHorizontalAlignConstraint];
    }
    else
    {
        self.messageBoxHorizontalAlignConstraint = [NSLayoutConstraint constraintWithItem:self.messageContainerView
                                                                                attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.avatarImageView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:15.0f];
        [self addConstraint:self.messageBoxHorizontalAlignConstraint];
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    if (self.responseContainerView.subviews.count)
    {
        self.separatorContstraint.constant = 5.0f;
    }
    else
    {
        self.separatorContstraint.constant = 0.0f;
    }
    
    [super layoutSubviews];
}
@end
