//
//  ECSEndChatSurveyView.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSEndChatSurveyView.h"

#import "ECSLocalization.h"
#import "ECSInjector.h"
#import "ECSTheme.h"
#import "ECSButton.h"

@implementation ECSEndChatSurveyView

- (void)awakeFromNib
{
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.backgroundColor = theme.primaryBackgroundColor;
    self.titleLabel.text = ECSLocalizedString(ECSLocalizedChatSessionEnded, nil);
    self.subtitleLabel.text = ECSLocalizedString(ECSLocalizedChatSessionEndedSubtitle, nil);
    self.directionsLabel.text = ECSLocalizedString(ECSLocalizedChatSessionEndedDirections, nil);
    [self.exitChatButton setTitle:ECSLocalizedString(ECSLocalizedExitChatButton, nil)
                         forState:UIControlStateNormal];
    
    self.titleLabel.font = theme.titleFont;
    self.titleLabel.textColor = theme.primaryTextColor;
    self.subtitleLabel.font = theme.bodyFont;
    self.subtitleLabel.textColor = theme.secondaryTextColor;
    self.directionsLabel.font = theme.bodyFont;
    self.directionsLabel.textColor = theme.primaryTextColor;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
