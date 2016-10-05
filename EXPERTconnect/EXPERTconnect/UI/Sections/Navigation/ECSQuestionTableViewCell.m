//
//  ECSQuestionTableViewCell.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSQuestionTableViewCell.h"

#import "ECSInjector.h"
#import "ECSTheme.h"

@implementation ECSQuestionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.backgroundColor = theme.secondaryBackgroundColor;
    self.contentView.backgroundColor = theme.secondaryBackgroundColor;
}

@end
