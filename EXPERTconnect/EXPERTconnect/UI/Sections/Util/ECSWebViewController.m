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

@interface ECSWebViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@property (strong, nonatomic) NSString *currentPath;
@end

@implementation ECSWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
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
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.currentPath]];
    [self.webView loadRequest:request];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UIEdgeInsets contentInsets = self.webView.scrollView.contentInset;
    contentInsets.bottom = CGRectGetHeight(self.toolbar.frame);
    self.webView.scrollView.contentInset = contentInsets;
}

- (void)loadItemAtPath:(NSString *)path
{
    if (![path hasPrefix:@"http"])
    {
        self.currentPath = [NSString stringWithFormat:@"http://%@", path];
    }
    else
    {
        self.currentPath = path;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    [self.webView loadRequest:request];
}

- (void)loadRequest:(NSURLRequest*)request
{
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

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self setLoadingIndicatorVisible:YES];
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self setLoadingIndicatorVisible:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
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
