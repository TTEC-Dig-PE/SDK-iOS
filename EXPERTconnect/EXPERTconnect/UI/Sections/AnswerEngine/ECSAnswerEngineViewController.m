//
//  ECSAnswerEngineViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSAnswerEngineViewController.h"

#import "ECSAnswerEngineActionType.h"
#import "ECSAnswerEngineResponse.h"
#import "ECSAnswerHistoryResponse.h"
#import "ECSAnswerEngineRateResponse.h"
#import "ECSAnswerViewController.h"

#import "ECSButton.h"
#import "ECSInjector.h"
#import "ECSListTableViewCell.h"
#import "ECSLocalization.h"
#import "ECSSearchTextField.h"
#import "ECSSectionHeader.h"
#import "ECSTheme.h"
#import "ECSURLSessionManager.h"
#import "ECSTopQuestionsViewController.h"
#import "ECSWebTableViewCell.h"
#import "ECSRootViewController+Navigation.h"
#import "ECSLocalization.h"

#import "UIView+ECSNibLoading.h"
#import "UIViewController+ECSNibLoading.h"
#import "NSBundle+ECSBundle.h"
#import "ECSViewControllerStack.h"

static NSString *const ECSListCellId = @"ECSListCellId";
static NSString *const ECSWebCellId = @"ECSWebCellId";

NSArray *_savedTopQuestions;
NSTimer *_delayTypeaheadTimer;

typedef NS_ENUM(NSInteger, AnswerAnimatePosition)
{
    AnswerAnimatePositionNone,
    AnswerAnimatePositionFromTop,
    AnswerAnimatePositionFromBottom
};

@interface ECSAnswerEngineViewController () <ECSTopQuestionsViewControllerDelegate, ECSAnswerViewControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIToolbar *searchToolbar;
@property (weak, nonatomic) IBOutlet ECSSearchTextField *searchTextField;

@property (strong, nonatomic) ECSAnswerViewController *answerViewController;
@property (strong, nonatomic) NSLayoutConstraint *topAnswerViewControllerConstraint;

@property (strong, nonatomic) UIBarButtonItem *faqBarButtonItem;
@property (strong, nonatomic) ECSTopQuestionsViewController *topQuestions;

// Question Tracking
@property (assign, nonatomic) NSInteger questionCount;

@property (strong, nonatomic) NSLayoutConstraint *topQuestionsTopConstraint;
@property (assign, nonatomic) BOOL faqIsShowing;

@property (strong, nonatomic) NSString *htmlString;

@property (strong, nonatomic) NSArray *escalationOptions;
@property (weak, nonatomic) IBOutlet UIView *escalationSeparator;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *escalationView;
@property (weak, nonatomic) IBOutlet UIView *escalationContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *escalationViewBottomConstraint;

@property (strong, nonatomic) UIBarButtonItem *shareButton;

@property (strong, nonatomic) NSURLSessionTask *currentQuestionTask;

@property (strong, nonatomic) NSMutableArray *answerEngineResponses;
@property (assign, nonatomic) NSInteger answerEngineResponseIndex;

@property (assign, nonatomic) CGRect keyboardFrame;

@property (assign, nonatomic) BOOL didAskInitialQuestion;

@property (assign, nonatomic) NSInteger invalidResponseCount;
@property (assign, nonatomic) NSInteger validQuestionsCount;

@end

@implementation ECSAnswerEngineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.actionType.displayName;
    
    self.didAskInitialQuestion = NO;
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    self.view.backgroundColor = theme.primaryBackgroundColor;
    self.searchToolbar.barTintColor = theme.secondaryBackgroundColor;
    
    self.answerEngineResponses = [NSMutableArray new];
    self.answerEngineResponseIndex = -1;
    
    self.questionCount = 0;
    self.invalidResponseCount = 0;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSArray *topToolbarConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[guide][toolbar]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"guide": self.topLayoutGuide,
                                                                                       @"toolbar": self.searchToolbar}];
    
    [self.view addConstraints:topToolbarConstraints];
    
    if (self.historyResponse)
    {
        [self configureForAnswerHistory];
    }
    else
    {
        [self configureForAnswerEngineAction];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.initialQuery && !self.didAskInitialQuestion)
    {
        self.searchTextField.text = self.initialQuery;
        self.didAskInitialQuestion = YES;
        [self askQuestion];
        [self hideFAQPopoverAnimated:NO];
    }
    if (!self.initialQuery && !self.didAskInitialQuestion &&
        self.answerEngineAction.topQuestions.count == 0 && self.answerEngineAction.answerEngineContext)
    {
        // Let's get top questions.
        ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
        
        [sessionManager getAnswerEngineTopQuestions:10
                                         forContext:self.answerEngineAction.answerEngineContext
                                     withCompletion:^(NSArray *context, NSError *error)
         {
             // Got our top questions...
             self.answerEngineAction.topQuestions = context;
             _savedTopQuestions = self.answerEngineAction.topQuestions; // Save off the top questionsk
             [self displayTopQuestions];
         }];
        
    }
}

- (void)configureForAnswerHistory
{
    self.searchTextField.text = self.historyResponse.request;
    
    ECSAnswerEngineResponse *response = [ECSAnswerEngineResponse new];
    
    response.answerId = self.historyResponse.answerId;
    response.answer = self.historyResponse.response;
    response.requestRating = @NO;
    
    ECSAnswerViewController *viewController = [self displayAnswerEngineAnswer:response
                                                        withAnimationPosition:AnswerAnimatePositionNone];
    viewController.showPullToNext = NO;
    viewController.showPullToPrevious = NO;
}

- (void)configureForAnswerEngineAction
{
    [self registerForKeyboardNotifications];
    
    self.searchTextField.placeholder = ECSLocalizedString(ECSLocalizeAskAQuestionKey, @"Ask a Question");
    self.searchTextField.delegate = self;
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    self.escalationSeparator.backgroundColor = theme.separatorColor;
    
    
    [self displayTopQuestions];
}

- (void) displayTopQuestions
{
    if (self.answerEngineAction.topQuestions.count > 0 && !self.topQuestions)
    {
        self.topQuestions = [ECSTopQuestionsViewController ecs_loadFromNib];
        self.topQuestions.delegate = self;
        self.topQuestions.actionType = self.answerEngineAction;
        
        // If we have an initial query, don't display on first load
        if (!self.initialQuery)
        {
            [self.topQuestions willMoveToParentViewController:self];
            
            ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
            self.topQuestions.view.backgroundColor = theme.primaryBackgroundColor;
            [self addChildViewController:self.topQuestions];
            [self.topQuestions.view setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self.view insertSubview:self.topQuestions.view aboveSubview:self.containerView];
            
            NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topQuestions]|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:@{@"topQuestions": self.topQuestions.view}];
            NSArray *horizonalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[topQuestions]|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:@{@"topQuestions": self.topQuestions.view}];
            [self.view addConstraints:verticalConstraints];
            [self.view addConstraints:horizonalConstraints];
            [self.topQuestions didMoveToParentViewController:self];
        }
    }
    if (self.topQuestions) {
        // Refresh the answers.
        [self.topQuestions reloadTableData]; 
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    if (self.answerEngineAction.showSearchBar) {
        contentInsets.top = CGRectGetMaxY(self.searchToolbar.frame);
        [self.searchToolbar setAlpha:1.0f];
        [self.searchTextField setAlpha:1.0f];
    } else {
        contentInsets.top = 0;
        [self.searchToolbar setAlpha:0.0f];
        [self.searchTextField setAlpha:0.0f];
    }
    
    if (self.topQuestions)
    {
        if (self.faqIsShowing)
        {
            //contentInsets.top = CGRectGetMaxY(self.navigationController.navigationBar.frame);
        }
        
        self.topQuestions.faqTableView.contentInset = contentInsets;
    }
    
    if (self.answerViewController)
    {
        UIEdgeInsets insets = self.answerViewController.edgeInsets;
        if (self.answerEngineAction.showSearchBar)
            insets.top = CGRectGetMaxY(self.searchToolbar.frame);
        else
            insets.top = CGRectGetMaxY(self.navigationController.navigationBar.frame);
        self.answerViewController.edgeInsets = insets;
    }
}

- (void)askQuestion
{
    [self.searchTextField resignFirstResponder];
    [self setLoadingIndicatorVisible:YES];
    
    [self hideFAQPopoverAnimated:YES];
    
    if (!self.faqBarButtonItem && (self.answerEngineAction.topQuestions.count > 0))
    {
        if (self.navigationController)
        {
            self.faqBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:ECSLocalizedString(ECSLocalizeShortFAQKey, @"FAQ")
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(toggleFAQPopover:)];
            NSMutableArray *rightBarItems = [NSMutableArray arrayWithArray:self.navigationItem.rightBarButtonItems];
            [rightBarItems addObject:self.faqBarButtonItem];
            self.navigationItem.rightBarButtonItems = rightBarItems;
            
        }
    }
    ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    // If there is already a question being asked, then cancel first.
    if (self.currentQuestionTask)
    {
        [self.currentQuestionTask cancel];
    }
    
    __weak typeof(self) weakSelf = self;
    NSString *question = [self.searchTextField.text copy];
    
    [sessionManager startConversationForAction:self.answerEngineAction
                               andAlwaysCreate:NO
                                withCompletion:^(ECSConversationCreateResponse *conversation, NSError *error) {
                                    if (!error)
                                    {
                                        weakSelf.currentQuestionTask = [sessionManager getAnswerForQuestion:weakSelf.searchTextField.text
                                                                                                  inContext:weakSelf.answerEngineAction.answerEngineContext
                                                                                            parentNavigator:weakSelf.parentNavigationContext
                                                                                                   actionId:weakSelf.answerEngineAction.actionId
                                                                                              questionCount:weakSelf.questionCount
                                                                                                 customData:nil
                                                                                                 completion:^(ECSAnswerEngineResponse *response, NSError *error) {
                                                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                         [weakSelf handleAPIResponse:response forQuestion:question withError:error];
                                                                                                         
                                                                                                     });
                                                                                                     
                                                                                                 }];
                                    }
                                    else
                                    {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [weakSelf handleAPIResponse:nil forQuestion:nil withError:[NSError new]];
                                        });
                                    }
                                }];
}

- (void)handleAPIResponse:(ECSAnswerEngineResponse*)response forQuestion:(NSString*)question withError:(NSError*)error
{
    [self setLoadingIndicatorVisible:NO];
    if ([response isKindOfClass:[ECSAnswerEngineResponse class]])
    {
        if (error) {
            // Error processing request. 
            NSLog(@"Answer Engine Error - %@", error);
            self.htmlString = ECSLocalizedString(ECSLocalizedAnswerNotFoundMessage,@"Answer not found message");
            self.invalidResponseCount++;
            [self.workflowDelegate invalidResponseOnAnswerEngineWithCount:self.invalidResponseCount];
            
        } else if (response.answerId.integerValue == -1 && response.answer.length > 0) {
            // We did not find an answer.
            self.invalidResponseCount++;
            [self.workflowDelegate invalidResponseOnAnswerEngineWithCount:self.invalidResponseCount];
            
        } else {
            // We found a good answer.
            self.htmlString = response.answer;
        }
        
        response.question = question;
        [self.answerEngineResponses addObject:response];
        self.escalationOptions = response.actions;
        self.answerEngineResponseIndex = self.answerEngineResponses.count - 1;
        if (!self.answerViewController)
        {
            [self displayAnswerEngineAnswerAtIndex:self.answerEngineResponseIndex
                             withAnimationPosition:AnswerAnimatePositionNone];
        }
        else
        {
            [self displayAnswerEngineAnswerAtIndex:self.answerEngineResponseIndex
                             withAnimationPosition:AnswerAnimatePositionFromBottom];
        }
    }
    
    self.questionCount = self.questionCount + 1;
    [self.workflowDelegate requestedValidQuestionsOnAnswerEngineCount:self.questionCount];
}

/*- (void)handleAPIResponse:(ECSAnswerEngineResponse*)response forQuestion:(NSString*)question withError:(NSError*)error
{
    [self setLoadingIndicatorVisible:NO];
    if (!error && [response isKindOfClass:[ECSAnswerEngineResponse class]])
    {
        if (response.answerId.integerValue == -1 && response.answer.length > 0)
        {
            if(![self.actionType.displayName isEqualToString:@"Answer Engine Worklflow"])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:response.answer delegate:nil cancelButtonTitle:ECSLocalizedString(ECSLocalizedOkButton, @"OK") otherButtonTitles:nil];
                [alert show];
            }
            //[self.searchTextField becomeFirstResponder];
            self.invalidResponseCount++;
            
            if(self.workflowDelegate)
            {
                [self.workflowDelegate invalidResponseOnAnswerEngineWithCount:self.invalidResponseCount];
            }
        }
        else
        {
            self.htmlString = response.answer;
            response.question = question;
            [self.answerEngineResponses addObject:response];
            self.escalationOptions = response.actions;
            self.answerEngineResponseIndex = self.answerEngineResponses.count - 1;
            if (!self.answerViewController)
            {
                [self displayAnswerEngineAnswerAtIndex:self.answerEngineResponseIndex
                                 withAnimationPosition:AnswerAnimatePositionNone];
            }
            else
            {
                [self displayAnswerEngineAnswerAtIndex:self.answerEngineResponseIndex
                                 withAnimationPosition:AnswerAnimatePositionFromBottom];
            }
        }
    }
    else if (error && error.code != NSURLErrorCancelled)
    {
        NSString *title = ECSLocalizedString(ECSLocalizedAnswerNotFoundTitle,
                                             @"Answer not found title");
        NSString *message = ECSLocalizedString(ECSLocalizedAnswerNotFoundMessage,
                                               @"Answer not found message");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:ECSLocalizedString(ECSLocalizedOkButton, @"Ok Button")
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    self.questionCount = self.questionCount + 1;
    [self.workflowDelegate requestedValidQuestionsOnAnswerEngineCount:self.questionCount];
}*/

- (void)displayAnswerEngineAnswerAtIndex:(NSInteger)index
                   withAnimationPosition:(AnswerAnimatePosition)animatePosition
{
    ECSAnswerViewController *answerViewController = [self displayAnswerEngineAnswer:self.answerEngineResponses[index]
                                                              withAnimationPosition:animatePosition];
    if (self.answerEngineResponses.count > 1)
    {
        if (index < self.answerEngineResponses.count - 1)
        {
            answerViewController.showPullToNext = YES;
        }
        
        if (index > 0)
        {
            answerViewController.showPullToPrevious = YES;
        }
    }
    else
    {
        answerViewController.showPullToPrevious = NO;
        answerViewController.showPullToNext = NO;
    }
    
    self.searchTextField.text = [((ECSAnswerEngineResponse*)self.answerEngineResponses[index]) question];
}

- (ECSAnswerViewController*)displayAnswerEngineAnswer:(ECSAnswerEngineResponse*)response
                                withAnimationPosition:(AnswerAnimatePosition)animatePosition
{
    [self.searchTextField resignFirstResponder];
    
    if (self.faqIsShowing)
    {
        [self hideFAQPopoverAnimated:YES];
    }
    
    if (![self.navigationItem.rightBarButtonItems containsObject:self.shareButton])
    {
        NSMutableArray *rightBarItems = [[NSMutableArray alloc] initWithArray:self.navigationItem.rightBarButtonItems];
        self.shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButtonTapped:)];
        [rightBarItems addObject:self.shareButton];
        self.navigationItem.rightBarButtonItems = rightBarItems;
    }
    
    ECSAnswerViewController *answerViewController = [ECSAnswerViewController ecs_loadFromNib];
    [answerViewController willMoveToParentViewController:self];
    
    [self addChildViewController:answerViewController];
    answerViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:answerViewController.view];
    
    NSArray *horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:@{@"view": answerViewController.view}];
    
    CGFloat startingTopOffset = 0.0f;
    switch (animatePosition) {
        case AnswerAnimatePositionFromTop:
            startingTopOffset = -CGRectGetHeight(self.containerView.frame);
            break;
        case AnswerAnimatePositionFromBottom:
            startingTopOffset = CGRectGetHeight(self.containerView.frame);
            break;
        default:
            break;
    }
    
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:answerViewController.view
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.containerView
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0f
                                                            constant:startingTopOffset];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:answerViewController.view
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.containerView
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0f
                                                               constant:0.0f];
    
    [self.containerView addConstraints:horizontal];
    [self.containerView addConstraints:@[top, height]];
    
    UIEdgeInsets answerInsets = answerViewController.edgeInsets;
    answerInsets.top = CGRectGetMaxY(self.searchToolbar.frame);
    if (self.keyboardFrame.size.height > 0)
    {
        answerInsets.bottom = self.keyboardFrame.size.height;
    }
    else
    {
        answerInsets.bottom = CGRectGetHeight(self.escalationView.frame);
    }
    answerViewController.automaticallyAdjustsScrollViewInsets = NO;
    answerViewController.edgeInsets = answerInsets;
    answerViewController.tableView.contentOffset = CGPointMake(0, -answerInsets.top);
    
    answerViewController.answer = response;
    
    answerViewController.delegate = self;
    [answerViewController didMoveToParentViewController:self];
    [answerViewController.view layoutIfNeeded];
    
    
    if (self.answerViewController)
    {
        // Since we will be removing this view from the stack, we need to kill the table view
        // callbacks and cancel scrolling.
        CGPoint offset = self.answerViewController.tableView.contentOffset;
        self.answerViewController.tableView.delegate = nil;
        self.answerViewController.tableView.dataSource = nil;
        [self.answerViewController.tableView setContentOffset:offset animated:NO];
        
        [self.answerViewController willMoveToParentViewController:nil];
        
        [UIView animateWithDuration:0.3f delay:0.0f options:0
                         animations:^{
                             switch (animatePosition) {
                                 case AnswerAnimatePositionFromBottom:
                                     self.topAnswerViewControllerConstraint.constant = -CGRectGetHeight(self.containerView.frame);
                                     break;
                                 case AnswerAnimatePositionFromTop:
                                     self.topAnswerViewControllerConstraint.constant = CGRectGetHeight(self.containerView.frame);
                                     break;
                                 default:
                                     break;
                             }
                             
                             top.constant = 0.0f;
                             [self.view layoutIfNeeded];
                         } completion:^(BOOL finished) {
                             self.answerViewController = answerViewController;
                             self.topAnswerViewControllerConstraint = top;
                             [self buildEscalationItems];
                         }];
    }
    else
    {
        [answerViewController didMoveToParentViewController:self];
        self.answerViewController = answerViewController;
        self.topAnswerViewControllerConstraint = top;
        [self buildEscalationItems];
    }
    
    return answerViewController;
}

- (BOOL)navigateToPreviousAnswer
{
    if (self.answerEngineResponseIndex > 0)
    {
        self.answerEngineResponseIndex = self.answerEngineResponseIndex - 1;
        [self displayAnswerEngineAnswerAtIndex:self.answerEngineResponseIndex
                         withAnimationPosition:AnswerAnimatePositionFromTop];
        return YES;
    }
    return NO;
}

- (BOOL)navigateToNextAnswer
{
    if (self.answerEngineResponseIndex < self.answerEngineResponses.count - 1)
    {
        self.answerEngineResponseIndex = self.answerEngineResponseIndex + 1;
        [self displayAnswerEngineAnswerAtIndex:self.answerEngineResponseIndex
                         withAnimationPosition:AnswerAnimatePositionFromBottom];
        return YES;
    }
    
    return NO;
}

- (void)askSuggestedQuestion:(NSString *)suggestedQuestion
{
    self.searchTextField.text = suggestedQuestion;
    [self.searchTextField layoutIfNeeded];
    [self askQuestion];
}

- (void)didRateAnswer:(ECSAnswerEngineResponse *)answer withRating:(NSNumber *)rating
{
    ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    __weak typeof(self) weakSelf = self;
    [sessionManager rateAnswerWithAnswerID:answer.answerId
                                 inquiryID:answer.inquiryId
                           parentNavigator:self.parentNavigationContext
                                  actionId:self.actionType.actionId
                                    rating:rating
                             questionCount:@(self.questionCount)
                                completion:^(ECSAnswerEngineRateResponse *response, NSError *error) {
                                    
                                    if (!error && response)
                                    {
                                        [weakSelf handleRatingResponse:response];
                                    }
                                }];
}

- (void)isReadyToRemoveFromParent:(UIViewController *)controller
{
    [controller removeFromParentViewController];
    controller = nil;
}

- (void)updateEdgeInsets
{
    UIEdgeInsets insets = self.answerViewController.edgeInsets;
    
    insets.top = CGRectGetMaxY(self.searchToolbar.frame);
    if (self.keyboardFrame.size.height > 0)
    {
        insets.bottom = self.keyboardFrame.size.height;
    }
    else if (CGRectGetHeight(self.escalationContainerView.frame) > 0)
    {
        insets.bottom = CGRectGetHeight(self.escalationContainerView.frame);
    }
    else
    {
        insets.bottom = 0;
    }
    
    self.answerViewController.edgeInsets = insets;
}

- (void)shareButtonTapped:(id)sender
{
    id<UIActivityItemSource> answer = nil;
    
    if (self.historyResponse)
    {
        answer = self.historyResponse;
    }
    else if (self.answerEngineResponses.count > self.answerEngineResponseIndex)
    {
        answer = self.answerEngineResponses[self.answerEngineResponseIndex];
    }
    
    if (answer)
    {
        UIActivityViewController *activityViewController =
        [[UIActivityViewController alloc] initWithActivityItems:@[answer]
                                          applicationActivities:nil];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            activityViewController.popoverPresentationController.barButtonItem = self.shareButton;
        }
        
        [self presentViewController:activityViewController
                           animated:YES
                         completion:nil];
    }
}

#pragma mark - ECSTopQuestionsViewControllerDelegate and Popover
- (void)controller:(ECSTopQuestionsViewController *)controller didSelectQuestion:(NSString *)question
{
    self.searchTextField.text = question;
    [self.searchTextField layoutIfNeeded];
    
    [self askQuestion];
    
    [self hideFAQPopoverAnimated:YES];
}

- (void)toggleFAQPopover:(id)sender
{
    if (self.faqIsShowing)
    {
        [self hideFAQPopoverAnimated:YES];
    }
    else
    {
        [self showFAQPopover:sender];
    }
}

- (void)showFAQPopover:(id)sender
{
    self.faqIsShowing = YES;
    [self.view endEditing:YES];
    //self.topQuestions.view.backgroundColor = [UIColor clearColor];
    //[self.topQuestions.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    //self.topQuestions.blurView.hidden = NO;
    
    self.topQuestions = nil;
    [self displayTopQuestions];
    /*
    [self.topQuestions willMoveToParentViewController:self];
    [self.topQuestions.view setAlpha:0.0f];
    [self.view addSubview:self.topQuestions.view];
    
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.topQuestions.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.topQuestions.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
    
    self.topQuestionsTopConstraint = [NSLayoutConstraint constraintWithItem:self.topQuestions.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:-CGRectGetHeight(self.view.frame)];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.topQuestions.view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
    
    [self.view addConstraints:@[width, height, self.topQuestionsTopConstraint, left]];
    [self.view layoutIfNeeded];
    */
    self.topQuestions.view.alpha = 1.0f;
    [UIView animateWithDuration:0.3f animations:^{
        [self.faqBarButtonItem setTitle:ECSLocalizedString(ECSLocalizeShortHideFAQKey, @"Hide FAQ")];
        //self.topQuestionsTopConstraint.constant = 0.0f;
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        //[self.topQuestions didMoveToParentViewController:self];
    }];
    
}

- (void)hideFAQPopoverAnimated:(BOOL)animated
{
    [self.topQuestions willMoveToParentViewController:nil];
    
    CGFloat animationTime = 0.3f;
    if (!animated)
    {
        animationTime = 0.0f;
    }
    
    [UIView animateWithDuration:animationTime animations:^{
        self.topQuestionsTopConstraint.constant = -CGRectGetHeight(self.view.frame);
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.faqBarButtonItem setTitle:ECSLocalizedString(ECSLocalizeShortFAQKey, @"FAQ")];
        [self.topQuestions.view removeFromSuperview];
        [self.topQuestions removeFromParentViewController];
        self.faqIsShowing = NO;
    }];
}

#pragma mark - Keyboard
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrame:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
}

- (void)keyboardWillChangeFrame:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *animationTime = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    self.keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:[animationTime floatValue] animations:^{
        [UIView setAnimationCurve:[animationCurve intValue]];
        [self updateEdgeInsets];
    }];
    
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSNumber *animationTime = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    self.keyboardFrame = CGRectZero;
    
    [UIView animateWithDuration:[animationTime floatValue] animations:^{
        [UIView setAnimationCurve:[animationCurve intValue]];
        [self updateEdgeInsets];
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0)
    {
        [self askQuestion];
    }
    
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length >= 3)
    {
        // Reset timer to 1 second until we search for suggested terms.
        [_delayTypeaheadTimer invalidate];
        _delayTypeaheadTimer = nil;
        _delayTypeaheadTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                target:self
                                                              selector:@selector(doTypeAheadSearch)
                                                              userInfo:nil
                                                               repeats:NO];
    }
    
    // If the user just deleted the last character and went back to an empty box...
    if (!string.length && !range.location && range.length == 1)
    {
        // Display the top questions again.
        self.answerEngineAction.topQuestions = _savedTopQuestions;
        [self displayTopQuestions];
    }
    
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    // Display the top questions again.
    self.answerEngineAction.topQuestions = _savedTopQuestions;
    [self displayTopQuestions];
    return YES;
}

// called from a timer after user types a search term.
-(void)doTypeAheadSearch
{
    ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    [sessionManager getAnswerEngineTopQuestionsForKeyword:self.searchTextField.text
                                      withOptionalContext:self.answerEngineAction.answerEngineContext
                                               completion:^(ECSAnswerEngineResponse *response, NSError *error)
     {
         // Got our top questions...
         if (response.suggestedQuestions) {
             
             self.answerEngineAction.topQuestions = response.suggestedQuestions;
             [self displayTopQuestions];
         }
     }];
}

- (void)buildEscalationItems
{
    BOOL animateDisplay = NO;
    
    if ([self.escalationContainerView.subviews count] == 0)
    {
        animateDisplay = YES;
    }
    
    if (animateDisplay)
    {
        self.escalationViewBottomConstraint.constant = -(self.escalationOptions.count * (44.0f + 15.0f) + 15.0f);
        [self.view layoutIfNeeded];
    }
    
    [self.escalationContainerView.subviews enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    UIView *previousView = nil;
    for (int i = 0; i < self.escalationOptions.count; i++)
    {
        ECSActionType *actionType = (ECSActionType*)self.escalationOptions[i];
        ECSButton *button = [[ECSButton alloc] initWithFrame:CGRectZero];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button setTitle:actionType.displayName forState:UIControlStateNormal];
        button.tag = i;
        [button addTarget:self
                   action:@selector(escalationTapped:)
         forControlEvents:UIControlEventTouchUpInside];
        
        
        
        [self.escalationContainerView addSubview:button];
        
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:button
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0f
                                                                   constant:44.0f];
        [button addConstraint:height];
        
        if (!previousView)
        {
            NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:button
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.escalationContainerView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0f
                                                                    constant:15.0f];
            [self.escalationContainerView addConstraint:top];
        }
        else
        {
            NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:button
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:previousView
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0f
                                                                    constant:15.0f];
            [self.escalationContainerView addConstraint:top];
        }
        
        NSArray *horizontalConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"|-(15)-[button]-(15)-|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:@{@"button": button}];
        [self.escalationContainerView addConstraints:horizontalConstraint];
        
        if (i == self.escalationOptions.count - 1)
        {
            NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:button
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.escalationContainerView
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1.0f
                                                                       constant:-15.0f];
            [self.escalationContainerView addConstraint:bottom];
            
        }
        
        previousView = button;
    }
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.escalationViewBottomConstraint.constant = 0.0f;
                         [self updateEdgeInsets];
                         [self.view layoutIfNeeded];
                     } completion:nil];
}

- (void)escalationTapped:(UIButton*)button
{
    NSInteger tagIndex = button.tag;
    
    if (tagIndex < self.escalationOptions.count)
    {
        ECSActionType *actionType = self.escalationOptions[tagIndex];
        [self ecs_navigateToViewControllerForActionType:actionType];
    }
}

- (void)handleRatingResponse:(ECSAnswerEngineRateResponse*)response
{
    for (ECSActionType *actionType in response.actions)
    {
        if (actionType.autoRoute.boolValue)
        {
            [self ecs_navigateToViewControllerForActionType:actionType];
            break;
        }
    }
}

@end
