//
//  ECSQuickRatingViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSQuickRatingViewController.h"

#import "ECSButton.h"
#import "ECSDynamicLabel.h"
#import "ECSImageCache.h"
#import "ECSInjector.h"
#import "ECSLocalization.h"
#import "ECSTheme.h"
#import "ECSURLSessionManager.h"


@interface ECSQuickRatingViewController ()

@property (weak, nonatomic) IBOutlet UIView *ratingView;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *titleLabel;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIView *ratingContainerView;
@property (weak, nonatomic) IBOutlet UIView *starButtonContainer;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *ratingLabel;
@property (weak, nonatomic) IBOutlet ECSButton *submitButton;
@property (weak, nonatomic) IBOutlet UIView *submitCompleteContainer;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *submitCompleteHeaderLabel;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *submitCompleteDetailsLabel;

@property (strong, nonatomic) NSMutableArray *starButtons;
@property (assign, nonatomic) BOOL submitComplete;
@property (assign, nonatomic) NSInteger rating;
@end

@implementation ECSQuickRatingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.form.formTitle;
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:ECSLocalizedString(ECSLocalizedCloseKey, @"Close")
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(closeButtonTapped:)];
    self.navigationItem.leftBarButtonItem = closeButton;
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    NSLayoutConstraint *topLayout = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0f constant:15.0f];
    [self.view addConstraint:topLayout];
    
    [self.view setBackgroundColor:theme.primaryBackgroundColor];
    self.titleLabel.font = theme.headlineFont;
    self.titleLabel.textColor = theme.primaryTextColor;
    self.subtitleLabel.font = theme.bodyFont;
    self.subtitleLabel.textColor = theme.primaryTextColor;
    self.ratingContainerView.backgroundColor = theme.secondaryBackgroundColor;
    self.ratingLabel.font = theme.captionFont;
    self.ratingLabel.textColor = theme.primaryTextColor;
    self.submitCompleteHeaderLabel.font = theme.headlineFont;
    self.submitCompleteHeaderLabel.textColor = theme.primaryTextColor;
    self.submitCompleteDetailsLabel.font = theme.bodyFont;
    self.submitCompleteDetailsLabel.textColor = theme.primaryTextColor;
    
    self.titleLabel.text = self.form.formHeader;
    self.subtitleLabel.text = self.form.formDetailText;
    self.ratingLabel.text = self.form.formPromptText;
    [self.submitButton setTitle:self.form.submitButtonText forState:UIControlStateNormal];
    
    self.submitCompleteHeaderLabel.text = self.form.submitCompleteHeaderText;
    self.submitCompleteDetailsLabel.text = self.form.submitCompleteText;
    
    [self createRatingButtons];
}

- (IBAction)submitButtonTapped:(id)sender
{
    if (!self.submitComplete)
    {
        [self setLoadingIndicatorVisible:YES];
        
        ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
        
        __weak typeof(self) weakSelf = self;
        
        [sessionManager submitForm:[self.form formValueWithRating:@(self.rating)]
                        completion:^(ECSFormSubmitResponse *response, NSError *error) {
                            [weakSelf setLoadingIndicatorVisible:NO];
            if (!error)
            {
                [UIView animateWithDuration:0.3f
                                 animations:^{
                                     weakSelf.ratingView.alpha = 0.0f;
                                     weakSelf.submitCompleteContainer.alpha = 1.0f;
                                     [weakSelf.submitButton setTitle:ECSLocalizedString(ECSLocalizedCloseKey, @"Close")
                                                        forState:UIControlStateNormal];
                                 }];
                weakSelf.submitComplete = YES;
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:ECSLocalizedString(ECSLocalizeError, @"Error")
                                                                    message:ECSLocalizedString(ECSLocalizeErrorText, @"Error Text")
                                                                   delegate:nil
                                                          cancelButtonTitle:ECSLocalizedString(ECSLocalizedOkButton, @"OK")
                                                          otherButtonTitles:nil];
                [alertView show];
            }
                        }];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)closeButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createRatingButtons
{
    self.starButtons = [NSMutableArray new];
    ECSImageCache* imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];
    ECSTheme* theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    UIImage* emptyStarImage = [[imageCache imageForPath:@"ecs_input_star_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage* fullStarImage = [[imageCache imageForPath:@"ecs_input_star_active"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    int numRatingButtons = 5;
    
    for (int i = 0; i < numRatingButtons; ++i)
    {
        UIButton* button = [[UIButton alloc] init];
        [button setTintColor:theme.primaryColor];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button setImage:emptyStarImage forState:UIControlStateNormal];
        [button setImage:fullStarImage forState:UIControlStateHighlighted|UIControlStateSelected];
        [button setImage:fullStarImage forState:UIControlStateSelected];
        [button addTarget:self action:@selector(ratingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(ratingButtonDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(ratingButtonCancel:) forControlEvents:UIControlEventTouchUpOutside];
        
        button.tag = i + 1;
        
        [button addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:button attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];
        
        [self.starButtons addObject:button];
        [self.starButtonContainer addSubview:button];
        if(i == 0)
        {
            [self.starButtonContainer addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                          attribute:NSLayoutAttributeLeading
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.starButtonContainer
                                                                          attribute:NSLayoutAttributeLeading
                                                                         multiplier:1.0 constant:0]];
            

        }
        else
        {
            [self.starButtonContainer addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                          attribute:NSLayoutAttributeLeading
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.starButtons[i - 1]
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1.0 constant:5]];
            [self.starButtonContainer addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.starButtons[0] attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];
        }
        if(i == numRatingButtons - 1)
        {
            [self.starButtonContainer addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.starButtonContainer
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1.0 constant:0.0]];
        }
        
        [self.starButtonContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button]"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:@{@"button": button}]];
    }
}

- (void)ratingButtonPressed:(UIButton*)sender
{
    NSInteger tag = sender.tag;
    self.rating = tag;
}

- (void)ratingButtonDown:(UIButton*)sender
{
    NSInteger tag = sender.tag;
    for(NSInteger i = 0; i < self.starButtons.count; ++i)
    {
        UIButton* button = self.starButtons[i];
        [button setSelected:i < tag];
    }
}

- (void)ratingButtonCancel:(UIButton*)sender
{
    self.rating = 0;
}

- (void)setRating:(NSInteger)rating
{
    for(NSInteger i = 0; i < self.starButtons.count; ++i)
    {
        UIButton* button = self.starButtons[i];
        [button setSelected:i < rating];
    }
}

@end
