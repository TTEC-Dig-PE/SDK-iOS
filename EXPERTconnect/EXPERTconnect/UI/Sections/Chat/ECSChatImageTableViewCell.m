//
//  ECSChatImageTableViewCell.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatImageTableViewCell.h"

#import "ECSChatCellBackground.h"
#import "ECSCachingImageView.h"
#import "ECSInjector.h"
#import "ECSTheme.h"
#import "UIImage+ECSBundle.h"

@interface ECSChatImageTableViewCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *avatarHeightConstraint;

@property (strong, nonatomic) NSLayoutConstraint *messageBoxHorizontalAlignConstraint;
@property (strong, nonatomic) UIImageView *playImageView;

@end
@implementation ECSChatImageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.messageImageView = [[ECSCachingImageView alloc] init];
    self.messageImageView.clipsToBounds = YES;
    self.messageImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.messageImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.background.messageContainerView addSubview:self.messageImageView];
    [self.background.messageContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[image]-(0)-|"
                                                                                                 options:0
                                                                                                 metrics:nil
                                                                                                   views:@{@"image": self.messageImageView}]];
    [self.background.messageContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[image]-(0)-|"
                                                                                                 options:0
                                                                                                 metrics:nil
                                                                                                   views:@{@"image": self.messageImageView}]];
}

- (void)setShowPlayIcon:(BOOL)showPlayIcon
{
    _showPlayIcon = showPlayIcon;
 
    if (!self.playImageView && showPlayIcon)
    {
        self.playImageView = [[UIImageView alloc] initWithImage:[UIImage ecs_bundledImageNamed:@"ecs_ic_playbutton"]];
        self.playImageView.contentMode = UIViewContentModeCenter;
        self.playImageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.background.messageContainerView insertSubview:self.playImageView aboveSubview:self.messageImageView];
        [self.background.messageContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.playImageView
                                                                                         attribute:NSLayoutAttributeCenterX
                                                                                         relatedBy:NSLayoutRelationEqual
                                                                                            toItem:self.background.messageContainerView
                                                                                         attribute:NSLayoutAttributeCenterX
                                                                                        multiplier:1.0f
                                                                                          constant:0.0f]];
        [self.background.messageContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.playImageView
                                                                                         attribute:NSLayoutAttributeCenterY
                                                                                         relatedBy:NSLayoutRelationEqual
                                                                                            toItem:self.background.messageContainerView
                                                                                         attribute:NSLayoutAttributeCenterY
                                                                                        multiplier:1.0f
                                                                                          constant:0.0f]];
    }
    else if (self.playImageView && !showPlayIcon)
    {
        [self.playImageView removeFromSuperview];
        self.playImageView = nil;
    }
    
}

@end
