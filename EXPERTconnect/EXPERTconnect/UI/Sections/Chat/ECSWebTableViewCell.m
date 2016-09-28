//
//  ECSWebTableViewCell.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSWebTableViewCell.h"

#import "ECSInjector.h"
#import "ECSTheme.h"

@interface ECSWebTableViewCell () <UIWebViewDelegate>
{
    BOOL _loaded;
}


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeightConstraint;

@end
@implementation ECSWebTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib]; 
    [self setup];
}

- (void)setup
{
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.separator.backgroundColor = theme.separatorColor;
    self.separatorHeightConstraint.constant = (1.0f / [[UIScreen mainScreen] scale]);
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.scrollView.scrollsToTop = NO;
    self.webView.suppressesIncrementalRendering = YES;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    _loaded = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UIWebViewDelegate
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
//    NSLog(@"SHould start %@", request);
//    return !_loaded;
//}
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    _loaded = YES;
//    CGFloat contentHeight = [[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.body.scrollHeight;"]] floatValue];
//    _requestedHeight = webView.scrollView.contentSize.height;
//    
//    NSLog(@"Did load height is %f", webView.scrollView.contentSize.height);
//    self.webView.scrollView.scrollEnabled = NO;
//    
//    if (self.delegate)
//    {
//        [self.delegate cell:self didFinishLoadForIndexPath:self.indexPath withSize:webView.scrollView.contentSize.height];
//    }
//}

@end
