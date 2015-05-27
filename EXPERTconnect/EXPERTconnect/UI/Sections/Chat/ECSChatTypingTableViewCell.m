//
//  ECSChatTypingTableViewCell.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatTypingTableViewCell.h"

#import "ECSImageCache.h"
#import "ECSChatCellBackground.h"
#import "ECSDynamicLabel.h"
#import "ECSInjector.h"
#import "ECSTheme.h"

@interface ECSChatTypingTableViewCell()

@property (strong, nonatomic) UIImageView *typingIndicator;

@end

@implementation ECSChatTypingTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        
        self.typingIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44.0f, 18.0f)];
        self.typingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        self.typingIndicator.contentMode = UIViewContentModeScaleAspectFit;
        
        ECSImageCache *imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];
        NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:109];
        for (int i = 0; i < 109; i++)
        {
            NSString *imageName = [NSString stringWithFormat:@"ecs_typingindicator_sequence_%04d", i];
            
            UIImage *image = [imageCache imageForPath:imageName];
            [images addObject:image];
        }
        self.typingIndicator.animationImages = images;
        
        [self.background.messageContainerView addSubview:self.typingIndicator];
        
        [self.typingIndicator addConstraint:[NSLayoutConstraint constraintWithItem:self.typingIndicator
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1.0f
                                                                          constant:44.0f]];
        
        [self.typingIndicator addConstraint:[NSLayoutConstraint constraintWithItem:self.typingIndicator
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1.0f
                                                                          constant:18.0f]];
        [self.typingIndicator setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.background.messageContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(10)-[label]-(10)-|"
                                                                                                     options:0
                                                                                                     metrics:nil
                                                                                                       views:@{@"label": self.typingIndicator}]];
        [self.background.messageContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[label]-(5)-|"
                                                                                                     options:0
                                                                                                     metrics:nil
                                                                                                       views:@{@"label": self.typingIndicator}]];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.typingIndicator startAnimating];
    }
    
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.typingIndicator startAnimating];
}

@end