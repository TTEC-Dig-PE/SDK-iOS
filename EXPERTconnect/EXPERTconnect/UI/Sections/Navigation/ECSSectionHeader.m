//
//  ECSSectionHeader.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSSectionHeader.h"

#import "ECSInjector.h"
#import "ECSTheme.h"

@implementation ECSSectionHeader

- (void)awakeFromNib
{
    [super awakeFromNib]; 
    [self setup];
}

- (void)setup
{
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.textLabel.textColor = theme.sectionHeaderTextColor;
    self.textLabel.font = theme.buttonFont;
    self.backgroundColor = theme.primaryBackgroundColor;
}

- (void)layoutSubviews
{
    self.textLabel.text = [self.textLabel.text uppercaseStringWithLocale:[NSLocale currentLocale]];
    [super layoutSubviews];
}
@end
