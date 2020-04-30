//
//  ECSWebViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSWebViewController.h"

#import "ECSInjector.h"
#import "ECSTheme.h"
#import "ECSImageCache.h"
#import <WebKit/WebKit.h>


@interface ECSWebViewController () <WKNavigationDelegate>


@property (weak, nonatomic) IBOutlet UIView *webViewContainer;
@property(nonatomic, strong)WKWebView *webView;


@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@property (strong, nonatomic) NSString *currentPath;
@property (strong, nonatomic) NSURLRequest *request;

@end

@implementation ECSWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.webView.navigationDelegate = self;
    self.webView = [self createWebView];
    [self addWebView:self.webViewContainer];
    
    self.backButton.enabled = NO;
    self.forwardButton.enabled = NO;
    
    [self updateNavigationButtonStates];
    
    if (self.actionType)
    {
        self.navigationItem.title = self.actionType.displayName;
    }
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    self.toolbar.tintColor = theme.primaryColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	 
	 if(!self.request)
	 {
		  self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.currentPath]];
	 }
	 [self.webView loadRequest:self.request];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UIEdgeInsets contentInsets = self.webView.scrollView.contentInset;
    contentInsets.bottom = CGRectGetHeight(self.toolbar.frame);
    self.webView.scrollView.contentInset = contentInsets;
}

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

- (void)loadItemAtPath:(NSString *)path
{
    self.currentPath = path;
    
    if (![self.currentPath hasPrefix:@"http://"] && ![self.currentPath hasPrefix:@"https://"])
    {
        self.currentPath = [@"https://" stringByAppendingString:self.currentPath];
    }

    // URL encode the link. 
    self.currentPath = [self.currentPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.currentPath]];
    [self.webView loadRequest:request];
}

- (void)loadRequest:(NSURLRequest*)request
{
    self.request=request;
    self.currentPath = request.URL.absoluteString;
    [self.webView loadRequest:request];
}

- (IBAction)backButtonTapped:(id)sender {
    [self.webView goBack];
}

- (IBAction)forwardButtonTapped:(id)sender {
    [self.webView goForward];
}

- (IBAction)refreshTapped:(id)sender {
    [self.webView reload];
}

- (IBAction)shareTapped:(id)sender {
    NSURL *URL = [NSURL URLWithString:self.currentPath];
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[URL]
                                      applicationActivities:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        activityViewController.popoverPresentationController.barButtonItem = self.shareButton;
    }

    [self presentViewController:activityViewController
                       animated:YES
                     completion:nil];
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
      [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
       [self setLoadingIndicatorVisible:YES];
        decisionHandler(WKNavigationActionPolicyAllow);
}



- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self setLoadingIndicatorVisible:NO];
}


- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self setLoadingIndicatorVisible:NO];
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self setLoadingIndicatorVisible:NO];
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
    
    [self updateNavigationButtonStates];
}

- (void)updateNavigationButtonStates
{
    ECSImageCache *imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];
    
    if (self.backButton.enabled)
    {
        self.backButton.image = [imageCache imageForPath:@"ecs_ic_webview_back_disabled"];
    }
    else
    {
        self.backButton.image = [[imageCache imageForPath:@"ecs_ic_webview_back_enabled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];;
    }
    
    if (self.forwardButton.enabled)
    {
        self.forwardButton.image = [imageCache imageForPath:@"ecs_ic_webview_forward_disabled"];
    }
    else
    {
        self.forwardButton.image = [[imageCache imageForPath:@"ecs_ic_webview_forward_enabled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
}

@end
