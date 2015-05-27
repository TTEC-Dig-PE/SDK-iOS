//
//  ECSChatTableVIewCellTableViewCell.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatTableViewCell.h"

#import "ECSChatCellBackground.h"
#import "UIView+ECSNibLoading.h"

@interface ECSChatTableViewCell()

@end

@implementation ECSChatTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
        
        self.background = [ECSChatCellBackground ecs_loadInstanceFromNib];
        self.background.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.background];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[background]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:@{@"background": self.background}]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[background]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:@{@"background": self.background}]];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setUserMessage:(BOOL)userMessage
{
    _userMessage = userMessage;
    
    self.background.userMessage = userMessage;
}


@end
