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
#import "ECSActionType.h"

@interface ECSSelectExpertTableViewCell ()

@property (weak, nonatomic) IBOutlet ECSDynamicLabel *regionTitle;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *expertieseTitle;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *interestsTitle;

@property (weak, nonatomic) IBOutlet UIView *buttonsContainerView;

@property (weak, nonatomic) IBOutlet UIButton *actionButton;

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

- (void)configureCellForActionType:(NSString *)actionType {
    [self.buttonsContainerView setHidden:YES];
    [self.actionButton setHidden:NO];
    if ([actionType isEqualToString:ECSActionTypeSelectExpertChat]) {
      //  [self.actionButton setImage:[UIImage imageNamed:@"messagebtn"] forState:UIControlStateNormal];
    } else if ([actionType isEqualToString:ECSActionTypeSelectExpertVideo]) {
       // [self.actionButton setImage:[UIImage imageNamed:@"callbtn"] forState:UIControlStateNormal];
    } else if ([actionType isEqualToString:ECSActionTypeSelectExpertVoiceCallback]){
      //  [self.actionButton setImage:[UIImage imageNamed:@"callbtn"] forState:UIControlStateNormal];
    } else if ([actionType isEqualToString:ECSActionTypeSelectExpertAndChannel]) {
        [self.buttonsContainerView setHidden:NO];
        [self.actionButton setHidden:YES];
    }
}

- (IBAction)chatPressed:(id)sender {
    [self.selectExpertCellDelegate chatPressed];
}

- (IBAction)callBackPressed:(id)sender {
    [self.selectExpertCellDelegate callBackPressed];
}

- (IBAction)voiceCallBackPressed:(id)sender {
}

- (IBAction)videoPressed:(id)sender {
    [self.selectExpertCellDelegate videoPressed];
}

- (IBAction)actionPressed:(id)sender {
    [self.selectExpertCellDelegate actionPressed];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
