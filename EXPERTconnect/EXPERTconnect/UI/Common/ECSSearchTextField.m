//
//  ECSSearchTextField.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSSearchTextField.h"

#import "ECSCachingImageView.h"
#import "ECSInjector.h"
#import "ECSTheme.h"

@interface ECSSearchTextField ()

@property (strong, nonatomic) NSMutableDictionary *placeholderAttributes;

@end

@implementation ECSSearchTextField

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
    [self setup];
}

- (void)setup
{
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.tintColor = theme.primaryColor;
    self.backgroundColor = theme.secondaryBackgroundColor;
    self.textColor = theme.primaryTextColor;
    
    NSMutableDictionary *defaultAttributes = [self.defaultTextAttributes mutableCopy];
    defaultAttributes[NSForegroundColorAttributeName] = theme.primaryTextColor;
    
    self.placeholderAttributes = [self.defaultTextAttributes mutableCopy];
    self.placeholderAttributes[NSForegroundColorAttributeName] = theme.primaryColor;
    
    if (self.placeholder)
    {
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder
                                                                     attributes:self.placeholderAttributes];
    }
    
    ECSCachingImageView *searchIcon = [[ECSCachingImageView alloc] initWithImagePath:@"ecs_ic_searchglass"];
    self.leftViewMode = UITextFieldViewModeAlways;
    self.leftView = searchIcon;
    
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    [super setPlaceholder:placeholder];
    
    if (placeholder)
    {
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder
                                                                     attributes:self.placeholderAttributes];
    }

}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect viewRect = [super leftViewRectForBounds:bounds];
    
    CGSize textSize = CGSizeZero;
    if ([self.text length] == 0)
    {
        textSize = [self.placeholder sizeWithAttributes:self.placeholderAttributes];

    }
    else
    {
        textSize = [self.text sizeWithAttributes:self.defaultTextAttributes];
    }
    
    CGFloat x = CGRectGetMidX(self.bounds) - ((textSize.width + self.leftView.frame.size.width) / 2.0f);
    viewRect.origin.x = MAX(10, (int)x);

    return viewRect;
    
}

@end
