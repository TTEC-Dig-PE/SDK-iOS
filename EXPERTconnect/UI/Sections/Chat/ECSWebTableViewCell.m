//
//  ECSWebTableViewCell.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSWebTableViewCell.h"

#import "ECSInjector.h"
#import "ECSTheme.h"


@interface ECSWebTableViewCell () <WKNavigationDelegate>
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
   
    self.webView = [self createWebView];
    [self addWebView:self.webViewContainer];
    
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.scrollView.scrollsToTop = NO;
    self.webView.configuration.suppressesIncrementalRendering = YES;
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

//Setting Up WKWebview Programatically
-(WKWebView *)createWebView
{
     WKWebViewConfiguration *configuration =
               [[WKWebViewConfiguration alloc] init];
     return [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
}
-(void)addWebView:(UIView *)view
{
      [view addSubview:self.webView];
      [self.webView setTranslatesAutoresizingMaskIntoConstraints:false];
      self.webView.frame = view.frame;
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
