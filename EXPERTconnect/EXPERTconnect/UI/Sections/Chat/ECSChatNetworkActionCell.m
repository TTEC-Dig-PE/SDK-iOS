//
//  ECSChatNetworkActionCell.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatNetworkActionCell.h"

#import "ECSDynamicLabel.h"
#import "ECSButton.h"
#import "ECSTheme.h"
#import "ECSInjector.h"

@implementation ECSChatNetworkActionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.contentView.backgroundColor = theme.primaryBackgroundColor;
    self.backgroundColor = theme.primaryBackgroundColor;
    self.messageLabel.textColor = theme.primaryTextColor;
    self.messageLabel.font = theme.titleFont;
    
    self.submessageLabel.textColor = theme.primaryTextColor;
    self.submessageLabel.font = theme.subheaderFont;
    
}

@end
