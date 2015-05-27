//
//  ECSFormTextField.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSFormTextField.h"

#import "ECSInjector.h"
#import "ECSTheme.h"

@interface ECSFormTextField()

@property (strong, nonatomic) UIView *separatorView;
@end

@implementation ECSFormTextField

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    self.backgroundColor = theme.secondaryBackgroundColor;
    
    self.tintColor = theme.primaryTextColor;
    
    self.separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1.0)];
    self.separatorView.backgroundColor = theme.separatorColor;
    self.textColor = theme.primaryTextColor;
    [self.separatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:self.separatorView];
    [self.separatorView addConstraint:[NSLayoutConstraint constraintWithItem:self.separatorView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1.0f
                                                                    constant:(1.0f / [[UIScreen mainScreen] scale])]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(15)-[separator]-(0)-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:@{@"separator": self.separatorView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[separator]-(0)-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:@{@"separator": self.separatorView}]];
    [self.separatorView setContentHuggingPriority:UILayoutPriorityDefaultLow - 1 forAxis:UILayoutConstraintAxisHorizontal];

    
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect textRect = [super textRectForBounds:bounds];

    CGRect newRect =  CGRectMake(15, textRect.origin.y, textRect.size.width - 30, textRect.size.height);
    return newRect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect editingRect = [super textRectForBounds:bounds];
    
    CGRect newRect =  CGRectMake(15, editingRect.origin.y, editingRect.size.width - 30, editingRect.size.height);
    return newRect;
}

@end
