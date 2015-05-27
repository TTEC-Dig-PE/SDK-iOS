//
//  ECSChatActionTableViewCell.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatActionTableViewCell.h"

#import "ECSChatCellBackground.h"
#import "ECSDynamicLabel.h"
#import "ECSImageCache.h"
#import "ECSInjector.h"
#import "ECSTheme.h"


@implementation ECSChatActionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.actionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.actionImageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.actionImageView.contentMode = UIViewContentModeCenter;
        
        [self.background.messageContainerView addSubview:self.actionImageView];
        
        [self.actionImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.actionImageView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0f
                                                               constant:20.0f]];
        [self.actionImageView addConstraint:[NSLayoutConstraint constraintWithItem:self.actionImageView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0f
                                                               constant:20.0f]];

        [self.background.messageContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(10)-[image]"
                                                                                                     options:0
                                                                                                     metrics:nil
                                                                                                       views:@{@"image": self.actionImageView}]];
        [self.background.messageContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[image]-(>=5)-|"
                                                                                                     options:0
                                                                                                     metrics:nil
                                                                                                       views:@{@"image": self.actionImageView}]];

        
        
        self.messageLabel = [[ECSDynamicLabel alloc] initWithFrame:self.background.messageContainerView.frame];
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.background.messageContainerView addSubview:self.messageLabel];
        
        [self.messageLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.messageLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.messageLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.background.messageContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[image]-(5)-[label]-(10)-|"
                                                                                                     options:0
                                                                                                     metrics:nil
                                                                                                       views:@{@"image": self.actionImageView,
                                                                                                               @"label": self.messageLabel}]];
        [self.background.messageContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[label]-(5)-|"
                                                                                                     options:0
                                                                                                     metrics:nil
                                                                                                       views:@{@"label": self.messageLabel}]];
        
        ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
        self.messageLabel.font = theme.bodyFont;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.messageLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.messageLabel.bounds);
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

- (void)setActionCellType:(ECSChatActionCellType)actionCellType
{
    _actionCellType = actionCellType;

    ECSImageCache *imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];
    switch (actionCellType) {
        case ECSChatActionCellTypeForm:
            self.actionImageView.image = [imageCache imageForPath:@"ecs_ic_chat_form"];
            break;
        case ECSChatActionCellTypeLink:
            self.actionImageView.image = [imageCache imageForPath:@"ecs_ic_chat_url"];
            break;
        case ECSChatActionCellTypeCallback:
            self.actionImageView.image = [imageCache imageForPath:@"ecs_ic_chat_callback"];
            break;
        case ECSChatActionCellTypeTextback:
            self.actionImageView.image = [imageCache imageForPath:@"ecs_ic_chat_textback"];
            break;
        default:
            self.actionImageView.image = nil;
            break;
    }
}

@end
