//
//  ECSFormQuestionView.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSFormQuestionView.h"

#import "ECSTheme.h"
#import "ECSInjector.h"
#import "ECSDynamicLabel.h"

static const CGFloat ViewPadding = 15.0f;

@interface ECSFormQuestionView ()

@property (strong, nonatomic) ECSDynamicLabel *questionLabel;


@end

@implementation ECSFormQuestionView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    ECSTheme* theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.questionLabel = [[ECSDynamicLabel alloc] init];
    self.questionLabel.textColor = theme.primaryTextColor;
    self.questionLabel.numberOfLines = 0;
    self.questionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.questionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.questionLabel.font = theme.largeBodyFont;

    [self addSubview:self.questionLabel];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(padding)-[label]-(padding)-|"
                                                                 options:0
                                                                 metrics:@{ @"padding": @(ViewPadding) }
                                                                   views:@{ @"label": self.questionLabel }]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(padding)-[label]-(padding)-|"
                                                                 options:0
                                                                 metrics:@{ @"padding": @(ViewPadding) }
                                                                   views:@{ @"label": self.questionLabel }]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.questionLabel.preferredMaxLayoutWidth = self.frame.size.width - ViewPadding * 2;
    
    [super layoutSubviews];
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [self.questionLabel systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    size.width += ViewPadding * 2;
    size.height += ViewPadding * 2;
    
    return size;
}

- (void)setQuestionText:(NSString *)questionText
{
    _questionText = questionText;
    self.questionLabel.text = questionText;
    
    [self invalidateIntrinsicContentSize];
}

@end
