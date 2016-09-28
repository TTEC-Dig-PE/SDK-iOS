//
//  ECSRadioTableViewCell.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSRadioTableViewCell.h"

#import "ECSDynamicLabel.h"
#import "ECSInjector.h"
#import "ECSImageCache.h"
#import "ECSTheme.h"

NSString *const ECSRadioTableViewCellIdentifier = @"ECSRadioTableViewCellIdentifier";

@interface ECSRadioTableViewCell()

@property (weak, nonatomic) IBOutlet ECSDynamicLabel *choiceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *radioImageView;

@end

@implementation ECSRadioTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib]; 
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    ECSTheme* theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.backgroundColor = theme.secondaryBackgroundColor;
    self.contentView.backgroundColor = theme.secondaryBackgroundColor;
    self.choiceLabel.font = theme.largeBodyFont;
    self.choiceLabel.textColor = theme.primaryTextColor;
    
    ECSImageCache* imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];
    
    self.radioImageView.image = [[imageCache imageForPath:@"ecs_input_radio_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.radioImageView setTintColor:theme.primaryColor];

    
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    ECSImageCache* imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];
    
    self.radioImageView.image = [[imageCache imageForPath:@"ecs_input_radio_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)setChoiceText:(NSString*)choiceText
{
    _choiceText = choiceText;
    self.choiceLabel.text = choiceText;
}

- (void)setRadioSelected:(BOOL)selected
{
    ECSImageCache* imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];
    
    if(selected)
    {
        UIImage* image = [[imageCache imageForPath:@"ecs_input_radio_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.radioImageView.image = image;
    }
    else
    {
        self.radioImageView.image = [[imageCache imageForPath:@"ecs_input_radio_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setRadioSelected:selected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self setRadioSelected:selected];
}

@end
