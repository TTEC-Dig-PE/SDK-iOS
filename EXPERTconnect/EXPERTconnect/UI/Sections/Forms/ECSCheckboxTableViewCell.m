//
//  ECSCheckboxTableViewCell.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSCheckboxTableViewCell.h"

#import "ECSDynamicLabel.h"
#import "ECSTheme.h"
#import "ECSInjector.h"

NSString* const ECSCheckboxTableViewCellIdentifier = @"ECSCheckboxTableViewCellIdentifier";

@interface ECSCheckboxTableViewCell()

@property (nonatomic, strong) UIView* emptyPlaceholder;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *choiceLabel;

@end

@implementation ECSCheckboxTableViewCell

- (void)awakeFromNib
{
    ECSTheme* theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    [self setTintColor:theme.primaryColor];
    
    self.backgroundColor = theme.secondaryBackgroundColor;
    self.contentView.backgroundColor = theme.secondaryBackgroundColor;

    [self.choiceLabel setFont:theme.largeBodyFont];
    self.choiceLabel.textColor = theme.primaryTextColor;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.emptyPlaceholder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 23, 10)];
    self.accessoryView = self.emptyPlaceholder;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.checked = NO;
}

-(void) setChoiceText:(NSString *)choiceText
{
    _choiceText = choiceText;
    self.choiceLabel.text = choiceText;
}

-(void)setChecked:(BOOL)checked
{
    _checked = checked;
    if(checked)
    {
        self.accessoryView = nil;
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.accessoryView = self.emptyPlaceholder;
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setChecked:selected];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self setChecked:selected];
}

@end
