//
//  ECSSendConfirmationViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSSendConfirmationViewController.h"
#import <AVKit/AVKit.h>

@import MediaPlayer;

#import "ECSInjector.h"
#import "ECSLocalization.h"
#import "ECSTheme.h"

@interface ECSSendConfirmationViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSURL *mediaURL;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation ECSSendConfirmationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    self.view.backgroundColor = theme.primaryBackgroundColor;
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.imageView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.topLayoutGuide
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0f
                                                                      constant:0.0f];
    [self.view addConstraint:topConstraint];
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:ECSLocalizedString(ECSLocalizeSend, @"Send")
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(sendTapped:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(cancelTapped:)];
    [self.navigationItem setRightBarButtonItem:sendButton];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    [self.imageView setImage:self.previewImage];
    self.playButton.alpha = 0.0f;
    self.playButton.enabled = NO;
    
    if (self.mediaInfo && [self.mediaInfo[UIImagePickerControllerMediaType] isEqualToString:@"public.movie"])
    {
        if (self.mediaInfo[UIImagePickerControllerMediaURL])
        {
            self.playButton.enabled = YES;
            self.playButton.alpha = 1.0f;
            self.mediaURL = self.mediaInfo[UIImagePickerControllerMediaURL];
        }
    }
}

- (IBAction)playButtonTapped:(id)sender
{
    if (self.mediaURL)
    {
        AVPlayer *player = [AVPlayer playerWithURL:self.mediaURL];
        AVPlayerViewController *playerViewController = [AVPlayerViewController new];
        playerViewController.player = player;
        [playerViewController.player play]; //Used to Play On start
        [self presentViewController:playerViewController animated:YES completion:nil];
        
//        MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:self.mediaURL];
//        [self presentMoviePlayerViewControllerAnimated:moviePlayer];
    }
}

- (void)setPreviewImage:(UIImage *)previewImage
{
    _previewImage = previewImage;
    
    if (self.imageView)
    {
        [self.imageView setImage:previewImage];
    }
}
- (void)sendTapped:(id)sender
{
    if (self.delegate)
    {
        [self.delegate userConfirmedSend:self];
    }
}

- (void)cancelTapped:(id)sender
{
    if (self.delegate)
    {
        [self.delegate userCancelledSend:self];
    }
}

@end
