//
//  ECSAttributedDynamicLabel.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSAttributedDynamicLabel.h"

NSString *const ECSAttributedDynamicLabelBaseFont = @"ECSDynamicLabelBaseFont";

@interface ECSAttributedDynamicLabel()
@end

static NSArray *fontSizes;
static dispatch_once_t onceToken;
static CGFloat defaultFontIndex;

@implementation ECSAttributedDynamicLabel

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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setup
{
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

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:[self attributedStringForPreferredContentSize:attributedText]];
    
    NSLog(@"Set attributed text is %@", attributedText);
}

- (void)contentSizeChanged:(NSNotification*)notification
{
    NSLog(@"Content size changed");
    self.attributedText = [self attributedStringForPreferredContentSize:self.attributedText];
}

- (UIFont*)preferredFontFromBaseFont:(UIFont*)baseFont
{
    NSInteger categoryIndex = [fontSizes indexOfObject:[[UIApplication sharedApplication] preferredContentSizeCategory]];
    if (categoryIndex < 0)
    {
        categoryIndex = defaultFontIndex;
    }
    
    CGFloat fontSize = baseFont.fontDescriptor.pointSize;
    
    
    fontSize = fontSize + ((categoryIndex - defaultFontIndex) * 2.0f);
    
    // Make minimum 12pt otherwise you really can't read it
    fontSize = MAX(fontSize, 12.0f);
    
    return [UIFont fontWithDescriptor:baseFont.fontDescriptor size:fontSize];
}

- (NSAttributedString*)attributedStringForPreferredContentSize:(NSAttributedString*)attrString
{
    NSMutableAttributedString *newAttributedString = [attrString mutableCopy];
    
    [attrString enumerateAttributesInRange:NSMakeRange(0, attrString.length)
                                   options:0
                                usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
                                    if (attrs[ECSAttributedDynamicLabelBaseFont] && attrs[NSFontAttributeName])
                                    {
                                        NSMutableDictionary *mutableAttributes = [attrs mutableCopy];
                                        UIFont *baseFont = (UIFont*)mutableAttributes[ECSAttributedDynamicLabelBaseFont];
                                        mutableAttributes[NSFontAttributeName] = [self preferredFontFromBaseFont:baseFont];
                                        [newAttributedString setAttributes:mutableAttributes range:range];
                                    }
                                }];
    
    return newAttributedString;
}

@end
