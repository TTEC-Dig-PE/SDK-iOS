//
//  ECDMainMenuTableViewCell.m
//  EXPERTconnectDemo
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECDMainMenuTableViewCell.h"

@implementation ECDMainMenuTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];

    [self.menuItemTitleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
}

- (void)setItemColor:(UIColor *)itemColor
{
    _itemColor = itemColor;
    
    [self.menuItemImageView setBackgroundColor:itemColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected)
    {
        [self.menuItemTitleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    }
    else
    {
        [self.menuItemTitleLabel setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline]];
    }
}

@end
