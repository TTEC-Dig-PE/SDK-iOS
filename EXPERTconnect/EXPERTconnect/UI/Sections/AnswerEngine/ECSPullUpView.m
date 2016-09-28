//
//  ECSPullUpView.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSPullUpView.h"

#import "ECSDynamicLabel.h"
#import "ECSInjector.h"
#import "ECSLocalization.h"
#import "ECSTheme.h"

@interface ECSPullUpView()

@property (weak, nonatomic) IBOutlet ECSDynamicLabel *label;

@end

@implementation ECSPullUpView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib]; 
    [self setup];
}

- (void)setup
{
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    self.label.font = theme.bodyFont;
    self.label.textColor = theme.secondaryTextColor;
    self.label.text = ECSLocalizedString(ECSLocalizedViewNextAnswer, @"View Next Answer");
}

@end
