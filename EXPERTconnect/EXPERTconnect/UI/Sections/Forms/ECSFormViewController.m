//
//  ECSFormViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSFormViewController.h"

#import "ECSFormItemViewController.h"
#import "ECSFormSubmittedViewController.h"

#import "UIViewController+ECSNibLoading.h"

@interface ECSFormViewController () <ECSFormItemViewControllerDelegate, ECSFormSubmittedViewDelegate, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet ECSButton *previousButton;
@property (weak, nonatomic) IBOutlet ECSButton *nextButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, assign) NSInteger questionIndex;
@property (nonatomic, strong) ECSFormItemViewController* formItemVC;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonViewBottomConstraint;

@property (nonatomic, strong) ECSLog *logger;

@end

@implementation ECSFormViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    if( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        self.showFormSubmittedView = YES; // Default value (backwards compatible with 5.8 and earlier)
        
    }
    
    return self; 
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.logger = [[EXPERTconnect shared] logger];
    
    ECSTheme* theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.view.backgroundColor = theme.primaryBackgroundColor;

    // Previous button customizations
    self.previousButton.ecsBackgroundColor = theme.secondaryButtonColor;
    [self.previousButton setTitle:ECSLocalizedString(ECSLocalizePreviousQuestionKey, @"Previous") forState:UIControlStateNormal];
    
    // Next button customizations
    self.nextButton.ecsBackgroundColor = theme.primaryColor;
    [self.nextButton setTitle:ECSLocalizedString(ECSLocalizeNextQuestionKey, @"Next") forState:UIControlStateNormal];
    
    [self updateTitle];
    
    [self updateButtonState];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];

    [self setLoadingIndicatorVisible:YES];
    
    [self initializeConversationForForm];
}

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    
    UIView* firstSubview = [self.formItemVC.view.subviews firstObject];
    
    if([firstSubview isKindOfClass:[UIScrollView class]]) {
        
        CGFloat topLayoutLength = self.topLayoutGuide.length;
        CGFloat bottomLayoutLength = self.bottomLayoutGuide.length;
        
        UIScrollView* scrollView = (UIScrollView*)firstSubview;
        
        UIEdgeInsets newInsets = UIEdgeInsetsMake(topLayoutLength, 0, bottomLayoutLength, 0);
        
        scrollView.contentInset = newInsets;
        scrollView.scrollIndicatorInsets = newInsets;
        scrollView.contentOffset = CGPointMake(0, -topLayoutLength);
    }
}

#pragma mark - Navigation Button Presses

- (IBAction)previousTapped:(id)sender {
    
    self.questionIndex--;
    
    if(self.questionIndex >= 0) {
        
        [self transitionToCurrentQuestionForwards:NO];
        
    } else {
        
        self.questionIndex = 0;
        
    }
}

- (IBAction)nextTapped:(id)sender {
    
    ECSFormActionType* formAction = (ECSFormActionType*)self.actionType;
    
    // If configured, invoke the delegate to inform them a question was answered.
    if(self.delegate && [self.delegate respondsToSelector:@selector(ECSFormViewController:answeredFormItem:atIndex:)]) {
        
        [self.delegate ECSFormViewController:self
                            answeredFormItem:formAction.form.formData[self.questionIndex]
                                     atIndex:(int)self.questionIndex];
    }
    
    if (self.questionIndex < formAction.form.formData.count - 1) {
        
        self.questionIndex++;
        
        [self transitionToCurrentQuestionForwards:YES];
        
    } else {
        
        [self submitForm];
        
    }
}

#pragma mark - General Helper Functions

- (void)updateTitle {
    
    ECSFormActionType* formAction = (ECSFormActionType*)self.actionType;
    
    if(formAction.form) {
        
        // In the navigationBar, we'll show which number form item your on. (eg "1 of 3")
        self.navigationItem.title = [NSString stringWithFormat:@"%ld of %ld", (long)(self.questionIndex + 1),
                                     (long)formAction.form.formData.count];
        
    }
}

- (void)updateButtonState {
    
    ECSFormActionType* formAction = (ECSFormActionType*)self.actionType;
    
    // Disable the left (PREVIOUS) button if we're on the first item.
    self.previousButton.enabled = self.questionIndex == 0 ? NO : YES;
    
    if(self.questionIndex == formAction.form.formData.count - 1) {
        
        if (formAction.form.submitText.length > 0) {
            
            // At the end of the form. We have submitText defined, so use that.
            [self.nextButton setTitle:formAction.form.submitText
                             forState:UIControlStateNormal];
            
        } else {
            
            // At the end of the form. No submitText defined, use SDK defaults.
            [self.nextButton setTitle:ECSLocalizedString(ECSLocalizeSubmitKey, @"Submit")
                             forState:UIControlStateNormal];
        }
        
    } else {
        
        // We're not at the end of the form, show a NEXT button.
        [self.nextButton setTitle:ECSLocalizedString(ECSLocalizeNextQuestionKey, @"Next")
                         forState:UIControlStateNormal];
        
    }
    
    // Apparently setting text cancels previous changes made when enabling / disabling, so reset that.
    self.nextButton.enabled = self.nextButton.enabled;
}

- (void)updateNextButtonForFormItem:(ECSFormItem*)item {
    
    // Disable the NEXT button if the question is required and the user has not answered.
    if([item.required boolValue]) {
        
        self.nextButton.enabled = item.answered;
        
    } else {
        
        self.nextButton.enabled = YES;
        
    }
}

- (void)transitionToCurrentQuestionForwards:(BOOL)forwards {
    
    // The user pressed the NEXT or PREVIOUS button. We're moving to another form item...
    
    ECSFormActionType* formAction = (ECSFormActionType*)self.actionType;
    
    // TODO: This should probably check "forwards" and make sure we're not running off the appropriate edge.
    if (formAction.form.formData.count > self.questionIndex) {
        
        ECSFormItem* currentItem = formAction.form.formData[self.questionIndex];
        
        ECSFormItemViewController* formVc = [ECSFormItemViewController viewControllerForFormItem:currentItem];
        
        formVc.delegate = self;
        
        [self addChildViewController:formVc];
        
        [self updateNextButtonForFormItem:currentItem];
        
        UIView* firstSubview = [formVc.view.subviews firstObject];
        
        if([firstSubview isKindOfClass:[UIScrollView class]]) {
            
            CGFloat topLayoutLength = self.topLayoutGuide.length;
            CGFloat bottomLayoutLength = self.bottomLayoutGuide.length;
            
            UIScrollView* scrollView = (UIScrollView*)firstSubview;
            
            UIEdgeInsets newInsets = UIEdgeInsetsMake(topLayoutLength, 0, bottomLayoutLength, 0);
            
            scrollView.contentInset = newInsets;
            scrollView.scrollIndicatorInsets = newInsets;
            scrollView.contentOffset = CGPointMake(0, -topLayoutLength);
            
            formVc.view.frame = self.contentView.bounds;
            
        } else {
            
            formVc.view.translatesAutoresizingMaskIntoConstraints = NO;
            
        }
        
        float transitionWidth = self.contentView.bounds.size.width;
        
        if(!forwards) {
            transitionWidth = -transitionWidth;
        }
        
        if(self.formItemVC) {
            
            formVc.view.transform = CGAffineTransformMakeTranslation(transitionWidth, 0);
            
            [self transitionFromViewController:self.formItemVC
                              toViewController:formVc
                                      duration:0.2f
                                       options:UIViewAnimationOptionCurveEaseInOut
                                    animations:^
            {
                                        
                formVc.view.transform = CGAffineTransformIdentity;
                
                if(![firstSubview isKindOfClass:[UIScrollView class]]) {
                    
                    [self addNonScrollviewConstraintsForView:formVc.view];
                    
                }
                
                self.formItemVC.view.transform = CGAffineTransformMakeTranslation(-transitionWidth, 0);
            }
            completion:^(BOOL finished) {
                
                [self didMoveToParentViewController:formVc];
                
                [self.formItemVC removeFromParentViewController];
                
                self.formItemVC = formVc;
                
                self.accessibilityElements = @[self.contentView, self.previousButton, self.nextButton];
                
                UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification,  self.contentView);
                
                [self updateTitle];
                
                [self updateButtonState];
                
            }];
            
        } else {
            
            [self.contentView addSubview:formVc.view];
            
            if(![firstSubview isKindOfClass:[UIScrollView class]]) {
                
                [self addNonScrollviewConstraintsForView:formVc.view];
                
            }
            
            [formVc didMoveToParentViewController:self];
            
            self.formItemVC = formVc;
        }
    }
}

- (void)addNonScrollviewConstraintsForView:(UIView*)view {
    
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

#pragma mark Keyboard Delegate

//- (void)keyboardWillShow:(NSNotification*)notification {
//
//    NSDictionary* info = [notification userInfo];
//
//    NSNumber *number = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//
//    [UIView animateWithDuration:[number doubleValue]
//                     animations:^{
//                         CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//                         self.buttonViewBottomConstraint.constant = keyboardFrame.size.height;
//                         [self.view layoutIfNeeded];
//                     }];
//}

- (void)keyboardWillHide:(NSNotification*)notification {
    
    NSDictionary* info = [notification userInfo];
    
    NSNumber *number = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    [UIView animateWithDuration:[number doubleValue]
                     animations:^{
                         
                         // Works if no bottom bar. Breaks if any view below.
                         if( self.shiftUpForKeyboard ) {
                             self.buttonViewBottomConstraint.constant = 0;
                         }
                         
                         [self.view layoutIfNeeded];
                     }];
}

- (void)keyboardWillChangeFrame:(NSNotification*)notification {
    
    NSDictionary* info = [notification userInfo];
    
    NSNumber *number = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    [UIView animateWithDuration:[number doubleValue]
                     animations:^{
                         
                         // Works if no bottom bar. Breaks if any view below.
                         if( self.shiftUpForKeyboard ) {
                             CGRect keyboardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
                             self.buttonViewBottomConstraint.constant = keyboardFrame.size.height;
                         }
                         
                         [self.view layoutIfNeeded];
                     }];
}

#pragma mark Public Getters & Setters

// Set public variables so integrators can pull form data from the viewController object.
- (NSString *) getFormName {
    
    ECSFormActionType* formAction = (ECSFormActionType*)self.actionType;
    
    return formAction.actionId;
    
}

- (ECSForm *) getForm {
    
    ECSFormActionType* formAction = (ECSFormActionType*)self.actionType;
    
    return formAction.form;
    
}

#pragma mark Internal Humanify API Code

- (void) initializeConversationForForm {
    
    __weak typeof(self) weakSelf = self;
    
    [[EXPERTconnect shared].urlSession startConversationForAction:self.actionType
                                                  andAlwaysCreate:NO
                                                   withCompletion:^(ECSConversationCreateResponse *conversation, NSError *error)
     {
         
         ECSFormActionType* formAction = (ECSFormActionType*)self.actionType;
         
         if(!formAction.form) {
             
             [self fetchFormNamed:formAction.actionId];
             
         } else {
             
             [weakSelf setLoadingIndicatorVisible:NO];
             [self transitionToCurrentQuestionForwards:YES];
         }
     }];
}

- (void) fetchFormNamed:(NSString *)formName {
    
    __weak typeof(self) weakSelf = self;
    [[EXPERTconnect shared].urlSession getFormByName:formName
                                      withCompletion:^(ECSForm *form, NSError *error)
     {
         
         if (!error && [form isKindOfClass:[ECSForm class]] ) {
             
             ECSFormActionType* formAction = (ECSFormActionType*)self.actionType;
             formAction.form = [form copy];
             [weakSelf setLoadingIndicatorVisible:NO];
             
             [self transitionToCurrentQuestionForwards:YES];
             
         } else {
             
             ECSLogError(self.logger, @"Error fetching form data. Error=%@", error);
             [weakSelf showMessageForError:error];
             [weakSelf dismissViewControllerAnimated:YES completion:nil];
         }
     }];
}

- (void)submitForm {
    
    [self setLoadingIndicatorVisible:YES];
    
    ECSFormActionType* formAction = (ECSFormActionType*)self.actionType;
    
    NSArray *configuration = [formAction.form.formData valueForKey:@"configuration"];
    NSNumber *maxValue = [[configuration objectAtIndex:0] valueForKey:@"maxValue"];
    NSNumber *value = [NSNumber numberWithFloat:[self.formItemVC.formItem.formValue floatValue]];

    //TODO : move this inside the session block
    NSString *lastSurveyScore;
    if([value intValue] > ([maxValue intValue]/2)) {
        lastSurveyScore = @"high";
    } else {
        lastSurveyScore = @"low";
    }
    [[EXPERTconnect shared] setLastSurveyScore:lastSurveyScore];

    NSString *userIntent = [[EXPERTconnect shared] userIntent];
    formAction.intent = userIntent;

    __weak typeof(self) weakSelf = self;
    
    ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    [urlSession submitForm:[formAction.form formResponseValue]
                    intent:userIntent
         navigationContext:formAction.navigationContext
                withCompletion:^(ECSFormSubmitResponse *response, NSError *error)
    {
                    
        [weakSelf setLoadingIndicatorVisible:NO];
        
        if ( !error ) {
            
            formAction.form.submitted = YES;
            
            if( self.delegate && [self.delegate respondsToSelector:@selector(ECSFormViewController:submittedForm:withName:error:)]) {
                
                [self.delegate ECSFormViewController:self submittedForm:formAction.form withName:formAction.actionId error:error];
                
            }
            
            if (!weakSelf.workflowDelegate) {
                
                if (response.action) {
                    
                    [weakSelf ecs_navigateToViewControllerForActionType:response.action];
                    
                } else {
                    
                    if( self.showFormSubmittedView == YES ) {
                        
                        ECSFormSubmittedViewController *submitController = [ECSFormSubmittedViewController ecs_loadFromNib];
                        submitController.workflowDelegate       = self.workflowDelegate;
                        submitController.headerLabel.text       = formAction.form.submitCompleteHeaderText;
                        submitController.descriptionLabel.text  = formAction.form.submitCompleteText;
                        submitController.delegate               = self;
                        
                        if (weakSelf.navigationController) {
                            
                            [weakSelf.navigationController pushViewController:submitController animated:YES];
                        }
                    }
                }
                
            } else {
                
                [weakSelf.workflowDelegate form:weakSelf.actionType.actionId submittedWithValue:lastSurveyScore];
            }
            
        } else {
            
            // Show error in form view
            [weakSelf showMessageForError:error];
        }
        
        // Always log the error.
        if( error ) {
            ECSLogError(self.logger, @"Error submitting form. Error=%@", error);
        }
    }];
}

#pragma mark - ECSFormItemViewControllerDelegate

- (void)formItemViewController:(ECSFormItemViewController *)vc answerDidChange:(NSString *)answer forFormItem:(ECSFormItem *)formItem {
    
    [self updateNextButtonForFormItem:formItem];
    
}

#pragma mark - ECSFormSubmittedViewDelegate

// This allows control of the navigation all to be contained within this view controller. This is important so that the integrator can have delegate functions that override our default behavior.
- (void) closeTappedInSubmittedView:(id)sender {
    
    ECSFormActionType* formAction = (ECSFormActionType*)self.actionType;
    
    bool proceedWithTransition = YES;
    
    if( self.delegate && [self.delegate respondsToSelector:@selector(ECSFormViewController:closedWithForm:)]) {
        
        proceedWithTransition = [self.delegate ECSFormViewController:self closedWithForm:formAction.form];
        
    }
    
    if( proceedWithTransition ) {
        
        // mas - 11-oct-2015 - Added condition for workflowDelegate
        if (self.workflowDelegate) {
            
            [self.workflowDelegate endWorkFlow];
            
        } else {
            
            ECSFormSubmittedViewController *submittedView = (ECSFormSubmittedViewController *)sender;
            
            if (submittedView.navigationController) {
                
                if([submittedView presentingViewController]) {
                    
                    [submittedView dismissViewControllerAnimated:YES completion:nil];
                    
                } else {
                    
                    [submittedView.navigationController popToRootViewControllerAnimated:YES];
                }
            }
        }
    }
    
}

@end
