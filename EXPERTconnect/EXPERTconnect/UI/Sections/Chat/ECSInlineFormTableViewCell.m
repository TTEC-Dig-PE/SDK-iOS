//
//  ECSInlineFormTableViewCell.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSInlineFormTableViewCell.h"

#import "ECSChatCellBackground.h"
#import "ECSInjector.h"
#import "ECSTheme.h"

@implementation ECSInlineFormTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.messageLabel = [[ECSDynamicLabel alloc] initWithFrame:self.background.messageContainerView.frame];
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.background.messageContainerView addSubview:self.messageLabel];
        
        [self.messageLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.messageLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.messageLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.background.messageContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(10)-[label]-(10)-|"
                                                                                                     options:0
                                                                                                     metrics:nil
                                                                                                       views:@{@"label": self.messageLabel}]];
        [self.background.messageContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[label]-(5)-|"
                                                                                                     options:0
                                                                                                     metrics:nil
                                                                                                       views:@{@"label": self.messageLabel}]];
        
        ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
        self.messageLabel.font = theme.chatFont;
        
        self.responseLabel = [[ECSDynamicLabel alloc] initWithFrame:self.background.responseContainerView.frame];
        self.responseLabel.numberOfLines = 0;
        self.responseLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.responseLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.background.responseContainerView addSubview:self.responseLabel];
        
        
        [self.responseLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.responseLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.responseLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.background.responseContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(10)-[label]-(10)-|"
                                                                                                     options:0
                                                                                                     metrics:nil
                                                                                                       views:@{@"label": self.responseLabel}]];
        [self.background.responseContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[label]-(5)-|"
                                                                                                     options:0
                                                                                                     metrics:nil
                                                                                                       views:@{@"label": self.responseLabel}]];
        self.messageLabel.font = theme.chatFont;
        self.messageLabel.textColor = theme.agentChatTextColor;
        
        self.responseLabel.font = theme.chatFont;
        self.responseLabel.textColor = theme.userChatTextColor;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.messageLabel.preferredMaxLayoutWidth = (self.frame.size.width * 0.5f) - 20.0f;
    ;
    [super layoutSubviews];
}

- (void)setUserMessage:(BOOL)userMessage
{
    [super setUserMessage:userMessage];
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    if (self.isUserMessage)
    {
        self.messageLabel.textColor = theme.userChatTextColor;
    }
    else
    {
        self.messageLabel.textColor = theme.primaryTextColor;
    }
}

@end
