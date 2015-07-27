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

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelSuperViewTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelSendTrailing;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) NSDictionary *mediaToSend;

@property (strong, nonatomic) UIViewController *currentChildViewController;

@property (strong, nonatomic) UIColor *inactiveColor;

@end

@implementation ECSChatToolbarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sendEnabled = YES;
    self.inactiveColor = [UIColor colorWithRed:0.73 green:0.73 blue:0.73 alpha:1];
    
    [self setup];
    
}

- (BOOL)resignFirstResponder {
    return [self.textView resignFirstResponder];
}

- (void)initializeSendState {
    // Ready to be sent
    self.sendEnabled = YES;
    // Send button disabled as the textView is displaying placeholder text at this point
    self.sendButton.enabled = NO;
}

- (void)setSendEnabled:(BOOL)sendEnabled
{
    _sendEnabled = sendEnabled;
    
    self.sendButton.enabled = sendEnabled;
    self.photoButton.enabled = sendEnabled;
    self.audioButton.enabled = sendEnabled;
    self.locationButton.enabled = sendEnabled;
}

- (void)setup
{
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.textView.tintColor = theme.primaryColor;
    self.textView.font = theme.chatTextFieldFont;
    self.textView.delegate = self;
    
    ECSImageCache *imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];
    [self.photoButton setImage:[[imageCache imageForPath:@"ecs_ic_chat_photo"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                      forState:UIControlStateNormal];
    self.photoButton.tintColor = self.inactiveColor;
    
    [self.audioButton setImage:[[imageCache imageForPath:@"ecs_ic_chat_audio"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                      forState:UIControlStateNormal];
    self.audioButton.tintColor = self.inactiveColor;
    
    [self.locationButton setImage:[[imageCache imageForPath:@"ecs_ic_chat_location"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                      forState:UIControlStateNormal];
    self.locationButton.tintColor = self.inactiveColor;
    
    self.placeholderColor = theme.secondaryTextColor;
    self.textView.textColor = self.placeholderColor;
    self.textView.text = ECSLocalizedString(ECSLocalizedChatViewPlaceholder, @"Chat view placeholder text");
    
    self.separatorView.backgroundColor = theme.separatorColor;
    self.separatorHeightConstraint.constant = 1.0f / [[UIScreen mainScreen] scale];
    
    self.sendButton.tintColor = theme.primaryColor;
    self.sendButton.enabled = NO;
    self.sendButton.titleLabel.font = theme.chatSendButtonFont;
    [self.sendButton setTitle:ECSLocalizedString(ECSLocalizeSend, @"Send") forState:UIControlStateNormal];
    [self.sendButton addTarget:self
                        action:@selector(sendTapped:)
              forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.tintColor = theme.primaryColor;
    [self.cancelButton setTitle:ECSLocalizedString(ECSLocalizeCancel, @"Cancel")
                       forState:UIControlStateNormal];

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
                         self.cancelSuperViewTrailing.active = NO;
                         self.cancelSendTrailing.active = YES;
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
        self.sendButton.enabled = NO;
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
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGSize size = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, CGFLOAT_MAX)];
    
    self.textViewHeightConstraint.constant = size.height;
    
    self.sendButton.enabled = (textView.text.length > 0);
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
        self.cancelSendTrailing.active = NO;
        self.cancelSuperViewTrailing.active = YES;

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
@end
