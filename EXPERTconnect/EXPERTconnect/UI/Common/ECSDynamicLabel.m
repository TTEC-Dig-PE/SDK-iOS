//
//  ECSDynamicLabel.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//
// ZSWTappableLabel details: https://github.com/zacwest/ZSWTappableLabel

#import "ECSDynamicLabel.h"

@interface ECSDynamicLabel()

@property (strong, nonatomic) UIFont *baseFont;

@end

static NSArray *fontSizes;
static dispatch_once_t onceToken;
static CGFloat defaultFontIndex;

@implementation ECSDynamicLabel

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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setup
{
    self.baseFont = self.font;
    
    dispatch_once(&onceToken, ^{
        fontSizes = @[
                      UIContentSizeCategoryExtraSmall,
                      UIContentSizeCategorySmall,
                      UIContentSizeCategoryMedium,
                      UIContentSizeCategoryLarge,
                      UIContentSizeCategoryExtraLarge,
                      UIContentSizeCategoryExtraExtraLarge,
                      UIContentSizeCategoryExtraExtraExtraLarge,
                      UIContentSizeCategoryAccessibilityMedium,
                      UIContentSizeCategoryAccessibilityLarge,
                      UIContentSizeCategoryAccessibilityExtraLarge,
                      UIContentSizeCategoryAccessibilityExtraExtraLarge,
                      UIContentSizeCategoryAccessibilityExtraExtraExtraLarge
                      ];
        defaultFontIndex = 3;
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentSizeChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
}

- (void)setFont:(UIFont *)font
{
    self.baseFont = font;
    
    NSInteger categoryIndex = [fontSizes indexOfObject:[[UIApplication sharedApplication] preferredContentSizeCategory]];
    if (categoryIndex < 0)
    {
        categoryIndex = defaultFontIndex;
    }
    
    CGFloat fontSize = self.baseFont.fontDescriptor.pointSize;
    
    
    fontSize = fontSize + ((categoryIndex - defaultFontIndex) * 2.0f);
    
    // Make minimum 12pt otherwise you really can't read it
    fontSize = MAX(fontSize, 12.0f);
    
    [super setFont:[UIFont fontWithDescriptor:self.baseFont.fontDescriptor size:fontSize]];
}

- (void)contentSizeChanged:(NSNotification*)notification
{
    self.font = self.baseFont;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.preferredMaxLayoutWidth = self.bounds.size.width;
    [super layoutSubviews];
}

- (void) setHtml: (NSString*) html
{
    NSError *err = nil;
    NSMutableAttributedString *attribString =
    [[NSMutableAttributedString alloc]
     initWithData: [html dataUsingEncoding:NSUTF8StringEncoding]
     options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
     documentAttributes: nil
     error: &err];
    
//    [attribString addAttribute:NSFontAttribute value:self.font range: NSMakeRange(0, attribString.length)];
    
    self.attributedText = attribString;
    
    if(err)
        NSLog(@"Unable to parse label text: %@", err);
}

@end
