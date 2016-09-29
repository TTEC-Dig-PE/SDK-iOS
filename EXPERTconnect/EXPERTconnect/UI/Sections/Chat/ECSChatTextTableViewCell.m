//
//  ECSChatTextTableViewCell.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatTextTableViewCell.h"

#import "ECSTheme.h"
#import "ECSInjector.h"

@implementation ECSChatTextTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    self.chatTextLabel.font = theme.titleFont;
    self.chatTextLabel.textColor = theme.primaryTextColor;
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
}

@end
