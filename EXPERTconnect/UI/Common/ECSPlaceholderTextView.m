//
//  ECSPlaceholderTextView.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSPlaceholderTextView.h"

#import "ECSDynamicLabel.h"

static const float PlaceholderAnimationDuration = 0.3;

@interface ECSPlaceholderTextView ()

@property (nonatomic, retain) ECSDynamicLabel *placeholderLabel;

@end

@implementation ECSPlaceholderTextView

- (id)initWithFrame:(CGRect)frame
{
    if( (self = [super initWithFrame:frame]) )
    {
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (!self.placeholder)
    {
        self.placeholder = @"";
    }
    
    if (!self.placeholderColor)
    {
        self.placeholderColor = [UIColor lightGrayColor];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)textChanged:(NSNotification *)notification
{
    if(self.placeholder.length == 0)
    {
        return;
    }
    
    [UIView animateWithDuration:PlaceholderAnimationDuration animations:^{
        if([[self text] length] == 0)
        {
            self.placeholderLabel.alpha = 1;
        }
        else
        {
            self.placeholderLabel.alpha = 0;
        }
    }];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    if(self.placeholderLabel)
    {
        self.placeholderLabel.text = placeholder;
        [self.placeholderLabel sizeToFit];
    }
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    if(self.placeholderLabel)
    {
        self.placeholderLabel.textColor = placeholderColor;
    }
}

- (void)drawRect:(CGRect)rect
{
    if(self.placeholder.length > 0)
    {
        if (!self.placeholderLabel)
        {
            self.placeholderLabel = [[ECSDynamicLabel alloc] initWithFrame:CGRectMake(8,8,self.bounds.size.width - 16,0)];
            self.placeholderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            self.placeholderLabel.numberOfLines = 0;
            self.placeholderLabel.font = self.font;
            self.placeholderLabel.backgroundColor = [UIColor clearColor];
            self.placeholderLabel.textColor = self.placeholderColor;
            self.placeholderLabel.alpha = 0;
            [self addSubview:self.placeholderLabel];
        }
        
        self.placeholderLabel.text = self.placeholder;
        [self.placeholderLabel sizeToFit];
        [self sendSubviewToBack:self.placeholderLabel];
    }
    
    if(self.text.length == 0 && self.placeholder.length > 0 )
    {
        self.placeholderLabel.alpha = 1.0;
    }
    
    [super drawRect:rect];
}

@end
