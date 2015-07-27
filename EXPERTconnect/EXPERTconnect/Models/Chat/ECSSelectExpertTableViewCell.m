//
//  ECSSelectExpertTableViewCell.m
//  EXPERTconnect
//
//  Created by Mohammad Abdurraafay on 21/06/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSSelectExpertTableViewCell.h"
#import "ECSCircleImageView.h"
#import "ECSDynamicLabel.h"
#import "ECSTheme.h"
#import "ECSInjector.h"

@interface ECSSelectExpertTableViewCell ()

@property (weak, nonatomic) IBOutlet ECSDynamicLabel *regionTitle;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *expertieseTitle;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *interestsTitle;

@end

@implementation ECSSelectExpertTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.contentView.backgroundColor = [theme secondaryBackgroundColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.profileImage.backgroundColor = theme.primaryColor;
    self.name.font = theme.buttonFont;
    self.name.textColor = theme.primaryTextColor;
    
    self.regionTitle.textColor = theme.secondaryTextColor;
    self.expertieseTitle.textColor = theme.secondaryTextColor;
    self.interestsTitle.textColor = theme.secondaryTextColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.name.preferredMaxLayoutWidth = self.name.frame.size.width;
    self.region.preferredMaxLayoutWidth = self.region.frame.size.width;
    [super layoutSubviews];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
