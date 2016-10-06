//
//  ECSChatToolbar.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatToolbarController.h"

#import "ECSChatLocationViewController.h"
#import "ECSChatPhotoOptionsViewController.h"

#import "ECSSendConfirmationViewController.h"
#import "ECSImageCache.h"
#import "ECSInjector.h"
#import "ECSLocalization.h"
#import "ECSMediaInfoHelpers.h"
#import "ECSTheme.h"
#import "ECSURLSessionManager.h"
#import "ECSChatStateMessage.h"

#import "UIView+ECSNibLoading.h"
#import "UIViewController+ECSNibLoading.h"

@interface ECSChatToolbarController() <UITextViewDelegate, ECSPhotoOptionsDelegate, ECSSendConfirmationDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;
@property (strong, nonatomic) UIColor *placeholderColor;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *separatorHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelSuperViewTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelSendTrailing;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) NSDictionary *mediaToSend;

@property (strong, nonatomic) UIViewController *currentChildViewController;

@property (strong, nonatomic) UIColor *inactiveColor;

@property (nonatomic) ECSChatState chatState;

@end

@implementation ECSChatToolbarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sendEnabled = YES;
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    self.inactiveColor = theme.disabledButtonColor;
    
    [self setup];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appHasGoneInBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)resignFirstResponder {
    return [self.textView resignFirstResponder];
}

- (void)initializeSendState {
    // Ready to be sent
    self.sendEnabled = YES;
    // Send button disabled as the textView is displaying placeholder text at this point
    //self.sendButton.enabled = NO;
    [self toggleSendButton:NO];
}

- (void)setSendEnabled:(BOOL)sendEnabled
{
    _sendEnabled = sendEnabled;
    
    self.sendButton.enabled = sendEnabled;
    self.photoButton.enabled = sendEnabled;
    self.audioButton.enabled = sendEnabled;
    self.locationButton.enabled = sendEnabled;
    
    if (!_sendEnabled) {
        [self.sendButton setAlpha:0.5f];
        [self.textView setUserInteractionEnabled:NO];
    } else {
        [self.sendButton setAlpha:1.0f];
        [self.textView setUserInteractionEnabled:YES];
    }
}

- (void)setup
{
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.textView.tintColor = theme.primaryColor;
    self.textView.font = theme.chatTextFieldFont;
    self.textView.delegate = self;
    
    self.view.backgroundColor = theme.secondaryBackgroundColor;
    
    ECSImageCache *imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];
    [self.photoButton setImage:[[imageCache imageForPath:@"ecs_ic_chat_photo"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                      forState:UIControlStateNormal];
    self.photoButton.tintColor = self.inactiveColor;
    
    if( theme.showChatImageUploadButton == NO )
    {
        self.chatTextToPhotoButton.constant = -36;
        [self.photoButton setHidden:YES];
    }
    
    /*[self.audioButton setImage:[[imageCache imageForPath:@"ecs_ic_chat_audio"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
     forState:UIControlStateNormal];
     self.audioButton.tintColor = self.inactiveColor;
     
     [self.locationButton setImage:[[imageCache imageForPath:@"ecs_ic_chat_location"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
     forState:UIControlStateNormal];
     self.locationButton.tintColor = self.inactiveColor;*/
    
    self.placeholderColor = theme.secondaryTextColor;
    self.textView.textColor = self.placeholderColor;
    self.textView.text = ECSLocalizedString(ECSLocalizedChatViewPlaceholder, @"Chat view placeholder text");
    
    self.separatorView.backgroundColor = theme.separatorColor;
    self.separatorHeightConstraint.constant = 1.0f / [[UIScreen mainScreen] scale];
    
    self.sendButton.backgroundColor = theme.primaryColor;
    self.sendButton.tintColor = theme.primaryTextColor;
    [self toggleSendButton:NO];
    [self.sendButton addTarget:self
                        action:@selector(sendTapped:)
              forControlEvents:UIControlEventTouchUpInside];
    
    if( theme.chatSendButtonUseImage )
    {
        self.sendButton.tintColor = theme.buttonTextColor;
        [self.sendButton setImage:theme.chatSendButtonImage forState:UIControlStateNormal];
        [self.sendButton setTitle:@"" forState:UIControlStateNormal];
    }
    else
    {
        self.sendButton.titleLabel.font = theme.chatSendButtonFont;
        [self.sendButton setTitle:ECSLocalizedString(ECSLocalizeSend, @"Send") forState:UIControlStateNormal];
    }
    
    self.cancelButton.backgroundColor = theme.primaryColor;
    self.cancelButton.tintColor = theme.primaryTextColor;
    [self.cancelButton setTitle:ECSLocalizedString(ECSLocalizeCancel, @"Cancel")
                       forState:UIControlStateNormal];
    
    // Default to paused internal state.
    _chatState = ECSChatStateTypingPaused;
    
}

- (IBAction)cancelTapped:(id)sender {
    ECSImageCache *imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         [self.photoButton setImage:[imageCache imageForPath:@"ecs_ic_chat_photo"] forState:UIControlStateNormal];
                         [self.audioButton setImage:[imageCache imageForPath:@"ecs_ic_chat_audio"] forState:UIControlStateNormal];
                         [self.locationButton setImage:[imageCache imageForPath:@"ecs_ic_chat_location"] forState:UIControlStateNormal];
                         self.sendButton.hidden = NO;
                         self.textViewHeightConstraint.constant = 30.0f;
                         self.cancelButton.hidden = YES;
                         //self.cancelSuperViewTrailing.active = NO;
                         //self.cancelSendTrailing.active = YES;
                         [self hideContainer];
                         [self.view setNeedsLayout];
                         
                     }];
}

- (void)sendTapped:(id)sender
{
    [self sendText];
}

- (void)sendText
{
    if (self.sendEnabled && self.delegate && self.textView.text.length > 0)
    {
        [self.delegate sendText:self.textView.text];
        self.textView.text = @"";
        [self textViewDidChange:self.textView];
        [self toggleSendButton:NO];
    }
}

- (void)toggleSendButton:(BOOL)isEnabled
{
    self.sendButton.enabled = isEnabled;
    if (self.sendButton.enabled) {
        [self.sendButton setAlpha:1.0f];
    } else {
        [self.sendButton setAlpha:0.5f];
    }
}

- (void)sendChatState:(NSString *)chatState
{
    if( [chatState isEqualToString:@"paused"])
    {
        _chatState = ECSChatStateTypingPaused;
    }
    else if( [chatState isEqualToString:@"composing"])
    {
        _chatState = ECSChatStateComposing;
    }
    
    if (self.delegate)
    {
        [self.delegate sendChatState:chatState];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    if ([textView.text isEqualToString:ECSLocalizedString(ECSLocalizedChatViewPlaceholder, @"Chat view placeholder text")])
    {
        textView.textColor = theme.primaryTextColor;
        textView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length == 0)
    {
        textView.text = ECSLocalizedString(ECSLocalizedChatViewPlaceholder, @"Chat view placeholder text");
        textView.textColor = self.placeholderColor;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text containsString:@"\n"])
    {
        [self sendText];
        return NO;
    }
    else
    {
        if (self.myTimer) {
            [self.myTimer invalidate];
            self.myTimer = nil;
        }
        self.myTimer =  [NSTimer scheduledTimerWithTimeInterval:15.0
                                                         target:self
                                                       selector:@selector(timeFired:)
                                                       userInfo:nil
                                                        repeats:NO];
        
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGSize size = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, CGFLOAT_MAX)];
    
    self.textViewHeightConstraint.constant = size.height;
    
    if( _chatState == ECSChatStateTypingPaused && textView.text.length > 0)
    {
        [self sendChatState:@"composing"];
    }
    else if( _chatState == ECSChatStateComposing && textView.text.length == 0)
    {
        [self sendChatState:@"paused"];
    }
    
    [self toggleSendButton: (textView.text.length > 0)];
}

- (void)appHasGoneInBackground:(NSNotification *)notification
{
    [self.myTimer invalidate];
    self.myTimer = nil;
    [self sendChatState:@"paused"];
}

- (void)timeFired:(NSTimer *)timer
{
    if (_textView.text) {
        [self sendChatState: @"paused"];
    }
}

- (void)displayViewController:(UIViewController*)controller
{
    [self.currentChildViewController willMoveToParentViewController:nil];
    [controller willMoveToParentViewController:self];
    [self addChildViewController:controller];
    
    
    if (self.currentChildViewController)
    {
        [self.currentChildViewController willMoveToParentViewController:nil];
        
        controller.view.alpha = 0.0f;
        
        [self transitionFromViewController:self.currentChildViewController
                          toViewController:controller
                                  duration:0.3f
                                   options:UIViewAnimationOptionCurveEaseInOut
                                animations:^{
                                    controller.view.translatesAutoresizingMaskIntoConstraints = NO;
                                    [self pinViewToContainer:controller.view];
                                    controller.view.alpha = 1.0f;
                                    self.currentChildViewController.view.alpha = 0.0f;
                                }
                                completion:^(BOOL finished) {
                                    [self.currentChildViewController removeFromParentViewController];
                                    self.currentChildViewController = controller;
                                }];
        
    }
    else
    {
        controller.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.containerView addSubview:controller.view];
        [self pinViewToContainer:controller.view];
        [controller didMoveToParentViewController:self];
        
        if (self.containerView.frame.size.height == 0)
        {
            // mas - 11-oct-2015 - The height of the container must be manually adjusted
            self.containerViewHeightConstraint.constant = controller.view.frame.size.height;
            [self.view setNeedsLayout];
            [UIView animateWithDuration:0.3f
                             animations:^{
                                 [self.view setNeedsLayout];
                             }];
        }
        
        self.currentChildViewController = controller;
    }
}

- (void)pinViewToContainer:(UIView*)view
{
    
    
    NSArray *horizontalLayout = [NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:@{@"view": view}];
    NSArray *verticalLayout = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"view": view}];
    
    
    [self.containerView addConstraints:horizontalLayout];
    [self.containerView addConstraints:verticalLayout];
    
    
}

- (void)hideContainer
{
    for (UIViewController *childController in self.childViewControllers)
    {
        [childController.view removeFromSuperview];
        [childController willMoveToParentViewController:nil];
        [childController removeFromParentViewController];
    }
    
    self.currentChildViewController = nil;
    
    // mas - 11-oct-2015 - This shrinks the container back to "hidden". Without this, it would
    // occupy the entire view including overwritting the chat area.
    self.containerViewHeightConstraint.constant = 0;
    [self.view setNeedsLayout];
    
}

- (void)updateToolbarStateForSelectedButton:(UIButton*)selectedButton
{
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    [self.textView resignFirstResponder];
    self.textViewHeightConstraint.constant = 0.0f;
    
    NSArray *buttons = @[self.photoButton, self.locationButton, self.audioButton];
    for (UIButton *button in buttons)
    {
        if (button == selectedButton)
        {
            button.tintColor = theme.primaryColor;
        }
        else
        {
            button.tintColor = self.inactiveColor;
        }
    }
    
    if (self.photoButton == selectedButton)
    {
        self.sendButton.hidden = YES;
        self.cancelButton.hidden = NO;
        //self.cancelSendTrailing.active = NO;
        //self.cancelSuperViewTrailing.active = YES;
        
    }
}

- (IBAction)photoButtonTapped:(id)sender
{
    [self updateToolbarStateForSelectedButton:self.photoButton];
    
    ECSChatPhotoOptionsViewController *photoView = [ECSChatPhotoOptionsViewController ecs_loadFromNib];
    photoView.delegate = self;
    [self displayViewController:photoView];
}

- (IBAction)audioButtonTapped:(id)sender
{
    [self updateToolbarStateForSelectedButton:self.audioButton];
    
}

- (IBAction)locationButtonTapped:(id)sender
{
    [self updateToolbarStateForSelectedButton:self.locationButton];
    ECSImageCache *imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];
    [self.locationButton setImage:[[imageCache imageForPath:@"ecs_ic_chat_location"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                         forState:UIControlStateNormal];
    
    
    ECSChatLocationViewController *locationView = [ECSChatLocationViewController ecs_loadFromNib];
    //    photoView.delegate = self;
    [self displayViewController:locationView];
}

- (void)mediaSelected:(NSDictionary *)mediaInfo
{
    if ([self.delegate respondsToSelector:@selector(sendMedia:)])
    {
        self.mediaToSend = mediaInfo;
        
        ECSSendConfirmationViewController *sendConfirmation = [ECSSendConfirmationViewController ecs_loadFromNib];
        sendConfirmation.delegate = self;
        sendConfirmation.previewImage = [ECSMediaInfoHelpers thumbnailForMedia:mediaInfo];
        sendConfirmation.mediaInfo = mediaInfo;
        
        UINavigationController *navWrapper = [[UINavigationController alloc] initWithRootViewController:sendConfirmation];
        
        if (self.navigationController.navigationBar)
        {
            navWrapper.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
            navWrapper.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;
            navWrapper.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        }
        
        [self presentViewController:navWrapper animated:YES completion:nil];
        [self cancelTapped:self];
    }
}

- (void)userConfirmedSend:(ECSSendConfirmationViewController*)controller
{
    if ([self.delegate respondsToSelector:@selector(sendMedia:)])
    {
        NSString *mediaType = self.mediaToSend[UIImagePickerControllerMediaType];
        if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
            // Scale and rotate the image before sending.
            UIImage *mediaFile = self.mediaToSend[UIImagePickerControllerOriginalImage];
            [self.mediaToSend setValue:[self scaleAndRotateImage:mediaFile] forKey:UIImagePickerControllerOriginalImage];
        }
        
        [self.delegate sendMedia:self.mediaToSend];
    }
    self.mediaToSend = nil;
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)userCancelledSend:(ECSSendConfirmationViewController*)controller
{
    self.mediaToSend = nil;
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)scaleAndRotateImage:(UIImage *)image {
    int kMaxResolution = 1024; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = roundf(bounds.size.width / ratio);
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = roundf(bounds.size.height * ratio);
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

@end
