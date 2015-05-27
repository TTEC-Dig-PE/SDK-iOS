//
//  ECSPhotoViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSPhotoViewController.h"

@import MediaPlayer;

#import "ECSCachingImageView.h"

@interface ECSPhotoViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet ECSCachingImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIBarButtonItem *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation ECSPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                     target:self
                                                                     action:@selector(shareTapped:)];
    self.navigationItem.rightBarButtonItem = self.shareButton;
    
    if (self.imageURLRequest)
    {
        [self.imageView setImageWithRequest:self.imageURLRequest];
    }
    else if (self.imagePath.length > 0)
    {
        [self.imageView setImageWithPath:self.imagePath];
    }
    else if (self.image)
    {
        [self.imageView setImage:self.image];
    }
    
    if (self.mediaPath)
    {
        self.scrollView.scrollEnabled = NO;
        self.playButton.alpha = 1.0f;
    }
    else
    {
        self.playButton.alpha = 0.0f;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playButtonTapped:(id)sender {
    if (self.mediaPath)
    {
        MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:self.mediaPath]];
        [self presentMoviePlayerViewControllerAnimated:moviePlayer];
    }
}

- (void)shareTapped:(id)sender {
    
    NSMutableArray *activityItems = [NSMutableArray new];
    
    if (self.imagePath.length > 0)
    {
        NSURL *URL = [NSURL URLWithString:self.imagePath];
        [activityItems addObject:URL];
    }
    
    if (self.imageView.image)
    {
        [activityItems addObject:self.imageView.image];
    }
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                      applicationActivities:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        activityViewController.popoverPresentationController.barButtonItem = self.shareButton;
    }
    
    [self presentViewController:activityViewController
                       animated:YES
                     completion:nil];
}


- (void)setImagePath:(NSString *)imagePath
{
    _imagePath = imagePath;
    [self.imageView setImageWithPath:imagePath];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self updateZoomContstraints];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)updateZoomContstraints;
{
    
    CGSize boundsSize = self.scrollView.bounds.size;
    boundsSize.height -= fabs(self.scrollView.contentInset.top);
    CGRect frameToCenter = self.imageView.frame;
    
    // Center content view horizontally
    if (frameToCenter.size.width < boundsSize.width)
    {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else
    {
        frameToCenter.origin.x = 0;
    }
    
    // Center content view vertically
    if (frameToCenter.size.height < boundsSize.height)
    {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else
    {
        frameToCenter.origin.y = 0;
    }
    
    [[self imageView] setFrame:frameToCenter];
}

- (void)resetZoomScale
{
    [self.scrollView setMinimumZoomScale:1.0];
    [self.scrollView setMaximumZoomScale:1.0];
    [self.scrollView setZoomScale:1.0];
}

- (void)setZoomScaleForContentSize
{
    [self resetZoomScale];

    CGRect contentFrame = CGRectMake(0, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height - fabs(self.scrollView.contentInset.top));
    self.imageView.frame = contentFrame;
    
    NSAssert(contentFrame.size.width > 0.0, @"Content width must be greater than 0");
    NSAssert(contentFrame.size.height > 0.0, @"Content height must be greater than 0");
    
    // Reset zoom before making calculations
    [self.scrollView setMinimumZoomScale:1.0f];
    [self.scrollView setMaximumZoomScale:10.0f];
    [self.scrollView setZoomScale:1.0f];
    [self.scrollView setContentSize:self.imageView.frame.size];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat x = CGRectGetMidX(self.scrollView.frame) - (CGRectGetWidth(self.playButton.frame) / 2);
    CGFloat y = CGRectGetMidY(self.scrollView.frame) - (CGRectGetHeight(self.playButton.frame) / 2);
    self.playButton.frame = CGRectMake(x, y,
                                       self.playButton.frame.size.width,
                                       self.playButton.frame.size.height);
    
    self.imageView.frame = self.scrollView.bounds;
    [self setZoomScaleForContentSize];
    [self updateZoomContstraints];

    [super viewDidLayoutSubviews];
}
     
@end
