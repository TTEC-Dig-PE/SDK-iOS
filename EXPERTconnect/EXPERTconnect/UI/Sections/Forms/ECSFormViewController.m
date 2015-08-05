//
//  ECSFormViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSFormViewController.h"

#import "ECSInjector.h"
#import "ECSTheme.h"
#import "ECSButton.h"
#import "ECSLocalization.h"
#import "ECSURLSessionManager.h"

#import "ECSFormItemViewController.h"
#import "ECSFormActionType.h"
#import "ECSForm.h"
#import "ECSFormItem.h"

#import "ECSFormSubmittedViewController.h"

#import "UIViewController+ECSNibLoading.h"

@interface ECSFormViewController () <ECSFormItemViewControllerDelegate>

@property (weak, nonatomic) IBOutlet ECSButton *previousButton;
@property (weak, nonatomic) IBOutlet ECSButton *nextButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, assign) NSInteger questionIndex;
@property (nonatomic, strong) ECSFormItemViewController* formItemVC;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonViewBottomConstraint;

@end

@implementation ECSFormViewController

- (void)dealloc
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ECSTheme* theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.view.backgroundColor = theme.primaryBackgroundColor;

    self.previousButton.ecsBackgroundColor = theme.secondaryButtonColor;
    [self.previousButton setTitle:ECSLocalizedString(ECSLocalizePreviousQuestionKey, @"Previous") forState:UIControlStateNormal];
    self.nextButton.ecsBackgroundColor = theme.primaryColor;
    [self.nextButton setTitle:ECSLocalizedString(ECSLocalizeNextQuestionKey, @"Next") forState:UIControlStateNormal];
    
    [self updateTitle];
    [self updateButtonState];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];

    [self setLoadingIndicatorVisible:YES];
    
    __weak typeof(self) weakSelf = self;
    ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    [urlSession startConversationForAction:self.actionType
                           andAlwaysCreate:NO
                             withCompletion:^(ECSConversationCreateResponse *conversation, NSError *error) {
                                 
                                 ECSFormActionType* formAction = (ECSFormActionType*)self.actionType;
                                 if(!formAction.form)
                                 {
                                     [urlSession getFormByName:formAction.actionId withCompletion:^(ECSForm *form, NSError *error) {
                                         formAction.form = [form copy];
                                         [weakSelf setLoadingIndicatorVisible:NO];
                                         
                                         [self transitionToCurrentQuestionForwards:YES];
                                     }];
                                 } else {
                                    [weakSelf setLoadingIndicatorVisible:NO];
                                    [self transitionToCurrentQuestionForwards:YES];
                                 }
                             }];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    UIView* firstSubview = [self.formItemVC.view.subviews firstObject];
    if([firstSubview isKindOfClass:[UIScrollView class]])
    {
        CGFloat topLayoutLength = self.topLayoutGuide.length;
        CGFloat bottomLayoutLength = self.bottomLayoutGuide.length;
        
        UIScrollView* scrollView = (UIScrollView*)firstSubview;
        UIEdgeInsets newInsets = UIEdgeInsetsMake(topLayoutLength, 0, bottomLayoutLength, 0);
        scrollView.contentInset = newInsets;
        scrollView.scrollIndicatorInsets = newInsets;
        scrollView.contentOffset = CGPointMake(0, -topLayoutLength);
    }
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    NSNumber *number = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    [UIView animateWithDuration:[number doubleValue]
                     animations:^{
                         CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
                         self.buttonViewBottomConstraint.constant = keyboardFrame.size.height;
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    NSNumber *number = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    [UIView animateWithDuration:[number doubleValue]
                     animations:^{
                         self.buttonViewBottomConstraint.constant = 0;
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillChangeFrame:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    NSNumber *number = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    [UIView animateWithDuration:[number doubleValue]
                     animations:^{
                         CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
                         self.buttonViewBottomConstraint.constant = keyboardFrame.size.height;
                         [self.view layoutIfNeeded];
                     }];
}

- (void)updateTitle
{
    ECSFormActionType* formAction = (ECSFormActionType*)self.actionType;
    if(formAction.form)
    {
        self.navigationItem.title = [NSString stringWithFormat:@"%ld of %ld", (long)(self.questionIndex + 1),
                                     (long)formAction.form.formData.count];
    }
}

- (void)updateButtonState
{
    ECSFormActionType* formAction = (ECSFormActionType*)self.actionType;
    
    self.previousButton.enabled = self.questionIndex == 0 ? NO : YES;
    if(self.questionIndex == formAction.form.formData.count - 1)
    {
        if (formAction.form.submitText.length > 0)
        {
            [self.nextButton setTitle:formAction.form.submitText forState:UIControlStateNormal];
        }
        else
        {
            [self.nextButton setTitle:ECSLocalizedString(ECSLocalizeSubmitKey, @"Submit")
                             forState:UIControlStateNormal];
        }
    }
    else
    {
        [self.nextButton setTitle:ECSLocalizedString(ECSLocalizeNextQuestionKey, @"Next") forState:UIControlStateNormal];
    }
    // Apparently setting text cancels previous changes made when enabling / disabling,
    // so reset that.
    self.nextButton.enabled = self.nextButton.enabled;
}

- (void)updateNextButtonForFormItem:(ECSFormItem*)item
{
    if([item.required boolValue])
    {
        self.nextButton.enabled = item.answered;
    }
    else
    {
        self.nextButton.enabled = YES;
    }
}

- (void)transitionToCurrentQuestionForwards:(BOOL)forwards
{
    ECSFormActionType* formAction = (ECSFormActionType*)self.actionType;
    
    if (formAction.form.formData.count > self.questionIndex)
    {
        ECSFormItem* currentItem = formAction.form.formData[self.questionIndex];
        ECSFormItemViewController* formVc = [ECSFormItemViewController viewControllerForFormItem:currentItem];
        formVc.delegate = self;
        [self addChildViewController:formVc];
        [self updateNextButtonForFormItem:currentItem];
        
        UIView* firstSubview = [formVc.view.subviews firstObject];
        if([firstSubview isKindOfClass:[UIScrollView class]])
        {
            CGFloat topLayoutLength = self.topLayoutGuide.length;
            CGFloat bottomLayoutLength = self.bottomLayoutGuide.length;
            
            UIScrollView* scrollView = (UIScrollView*)firstSubview;
            UIEdgeInsets newInsets = UIEdgeInsetsMake(topLayoutLength, 0, bottomLayoutLength, 0);
            scrollView.contentInset = newInsets;
            scrollView.scrollIndicatorInsets = newInsets;
            scrollView.contentOffset = CGPointMake(0, -topLayoutLength);
            formVc.view.frame = self.contentView.bounds;
        }
        else
        {
            formVc.view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        
        float transitionWidth = self.contentView.bounds.size.width;
        if(!forwards)
        {
            transitionWidth = -transitionWidth;
        }
        
        if(self.formItemVC)
        {
            formVc.view.transform = CGAffineTransformMakeTranslation(transitionWidth, 0);
            [self transitionFromViewController:self.formItemVC
                              toViewController:formVc
                                      duration:0.2f
                                       options:UIViewAnimationOptionCurveEaseInOut
                                    animations:^{
                                        formVc.view.transform = CGAffineTransformIdentity;
                                        if(![firstSubview isKindOfClass:[UIScrollView class]])
                                        {
                                            [self addNonScrollviewConstraintsForView:formVc.view];
                                        }
                                        self.formItemVC.view.transform = CGAffineTransformMakeTranslation(-transitionWidth, 0);
                                    }
                                    completion:^(BOOL finished) {
                                        [self didMoveToParentViewController:formVc];
                                        [self.formItemVC removeFromParentViewController];
                                        self.formItemVC = formVc;
                                        
                                        [self updateTitle];
                                        [self updateButtonState];
                                    }];
        }
        else
        {
            [self.contentView addSubview:formVc.view];
            if(![firstSubview isKindOfClass:[UIScrollView class]])
            {
                [self addNonScrollviewConstraintsForView:formVc.view];
            }
            [formVc didMoveToParentViewController:self];
            
            self.formItemVC = formVc;
        }
    }
}

- (void)addNonScrollviewConstraintsForView:(UIView*)view
{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayout][view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{ @"topLayout": self.topLayoutGuide,
                                                                                 @"view": view}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{ @"view": view}]];
}


- (IBAction)previousTapped:(id)sender
{
    self.questionIndex--;
    
    if(self.questionIndex >= 0)
    {
        [self transitionToCurrentQuestionForwards:NO];
    }
    else
    {
        self.questionIndex = 0;
    }
}

- (IBAction)nextTapped:(id)sender
{
    ECSFormActionType* formAction = (ECSFormActionType*)self.actionType;
    
    if (self.questionIndex < formAction.form.formData.count - 1)
    {
        self.questionIndex++;
        [self transitionToCurrentQuestionForwards:YES];
    }
    else
    {
        [self submitForm];
    }
}

- (void)submitForm
{
    [self setLoadingIndicatorVisible:YES];
    
    ECSFormActionType* formAction = (ECSFormActionType*)self.actionType;
    
    NSString *userIntent = [[EXPERTconnect shared] userIntent];
    formAction.intent = userIntent;
    
    __weak typeof(self) weakSelf = self;
    
    ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    [urlSession submitForm:[formAction.form formResponseValue]

                completion:^(ECSFormSubmitResponse *response, NSError *error) {
                    [weakSelf setLoadingIndicatorVisible:NO];
                    if (!error)
                    {
                        formAction.form.submitted = YES;
                        ECSFormSubmittedViewController *submitController = [ECSFormSubmittedViewController ecs_loadFromNib];
                        submitController.headerLabel.text = formAction.form.submitCompleteHeaderText;
                        submitController.descriptionLabel.text = formAction.form.submitCompleteText;
                        
                        if (weakSelf.navigationController)
                        {
                            [weakSelf.navigationController setViewControllers:@[submitController] animated:YES];
                        }
                    }
                    else
                    {
                        [weakSelf showMessageForError:error];
                    }
                }];
}
#pragma mark - ECSFormItemViewControllerDelegate

- (void)formItemViewController:(ECSFormItemViewController *)vc answerDidChange:(NSString *)answer forFormItem:(ECSFormItem *)formItem
{
    [self updateNextButtonForFormItem:formItem];
}

@end
