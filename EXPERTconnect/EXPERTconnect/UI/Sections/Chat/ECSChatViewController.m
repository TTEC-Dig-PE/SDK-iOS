//
//  ECSChatViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "ECSWebSocket.h"

#import "ECSChatActionType.h"
#import "ECSCallbackViewController.h"
#import "ECSConversationCreateResponse.h"
#import "ECSChannelConfiguration.h"
#import "ECSChannelCreateResponse.h"
#import "ECSChatAddParticipantMessage.h"
#import "ECSChatRemoveParticipantMessage.h"
#import "ECSChatAssociateInfoMessage.h"
#import "ECSChatCoBrowseMessage.h"
#import "ECSCafeXMessage.h"
#import "ECSChatVoiceAuthenticationMessage.h"
#import "ECSChatCellBackground.h"
#import "ECSChatHistoryResponse.h"
#import "ECSChatTableViewCell.h"
#import "ECSChatURLMessage.h"
#import "ECSChatMessage.h"
#import "ECSChatInfoMessage.h"
#import "ECSChatMediaMessage.h"
#import "ECSChatFormMessage.h"
#import "ECSChatImageTableViewCell.h"
#import "ECSChatMessage.h"
#import "ECSChatTextMessage.h"
#import "ECSSendQuestionMessage.h"
#import "ECSReceiveAnswerMessage.h"
#import "ECSChatTypingTableViewCell.h"
#import "ECSChatActionTableViewCell.h"
#import "ECSChatWaitView.h"
#import "ECSChatMessageTableViewCell.h"
#import "ECSHtmlMessageTableViewCell.h"
#import "ECSChatNetworkActionCell.h"
#import "ECSChatNotificationMessage.h"
#import "ECSChatTextTableViewCell.h"
#import "ECSChatToolbarController.h"
#import "ECSDynamicLabel.h"
#import "ECSFormViewController.h"
#import "ECSInlineFormTableViewCell.h"
#import "ECSInlineFormViewController.h"
#import "ECSCheckboxFormItemViewController.h"
#import "ECSRadioFormItemViewController.h"
#import "ECSImageCache.h"
#import "ECSInjector.h"
#import "ECSLog.h"
#import "ECSMediaInfoHelpers.h"
#import "ECSPhotoViewController.h"
#import "ECSWebViewController.h"
//#import "ECSQuickRatingForm.h"
//#import "ECSQuickRatingViewController.h"
#import "ECSUserManager.h"
#import "ECSURLSessionManager.h"
#import "ECSChatAddChannelMessage.h"
#import "ECSEndChatSurveyView.h"
#import "ECSRootViewController+Navigation.h"
#import "ECSCafeXController.h"
#import "UIImage+ECSBundle.h"

#import "UIView+ECSNibLoading.h"
#import "UIViewController+ECSNibLoading.h"
#import "ECSErrorBarView.h"

#import "ZSWTappableLabel.h"

static NSString *const MessageCellID        = @"AgentMessageCellID";
static NSString *const HtmlMessageCellID    = @"HtmlMessageCellID";
static NSString *const ImageCellID          = @"AgentImageCellID";
static NSString *const MessageTypingCellID  = @"MessageTypingCellID";
static NSString *const ActionCellID         = @"ActionCellID";
static NSString *const TextCellID           = @"TextCellID";
static NSString *const ChatNetworkCellID    = @"ChatNetworkCellID";
static NSString *const InlineFormCellID     = @"ChatInlineFormCellID";

#pragma mark - Chat Network Message
@interface ECSChatNetworkMessage : ECSChatMessage
@end

@implementation ECSChatNetworkMessage
@end

#pragma mark - Chat Idle Message
@interface ECSChatIdleMessage : ECSChatMessage
@end

@implementation ECSChatIdleMessage
@end

#pragma mark Chat View Controller

@interface ECSChatViewController () <UITableViewDataSource, UITableViewDelegate, ECSChatToolbarDelegate, ECSStompChatDelegate, ECSInlineFormViewControllerDelegate, ECSFormViewDelegate, ZSWTappableLabelTapDelegate>
{
    BOOL        _userDragging;              // Used to hide the keyboard if user starts scrolling
    NSInteger   _agentTypingIndex;          // Index in the array of messages of where the (...) item is.
    BOOL        _userTyping;                // State variable that helps us know if we should send an update to server or not.
    BOOL        _showingPostChatSurvey;     // Used when returning from post-chat survey. Make sure this window gets popped from stack as well.
    int         _reconnectCount;            // Number of reconnect attempts made so far
    
    NSTimer*    _reconnectTimer;
    
    BOOL        _previousReachableStatus;
    
    BOOL        _agentAnswered;
}

// Form controls
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *chatToolbarContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatToolbarBottomConstraint;
@property (strong, nonatomic) ECSChatWaitView *waitView;
@property (strong, nonatomic) ECSErrorBarView *networkErrorView;
@property (strong, nonatomic) ECSCallbackViewController *callbackViewController;
@property (strong, nonatomic) ECSChatToolbarController *chatToolbar;
@property (assign, nonatomic) CGRect keyboardFrame;
@property (strong, nonatomic) ECSInlineFormViewController *inlineFormController;
@property (strong, nonatomic) NSIndexPath *currentFormCellIndexPath;
@property (strong, nonatomic) NSLayoutConstraint *inlineFormBottomConstraint;

// Chat Stomp Client object
@property (strong, nonatomic) ECSStompChatClient *chatClient;

// Index of the "Reconnect" view in the current chat window.
@property (assign, nonatomic) NSInteger currentReconnectIndex;

// Set to true when a form is sent to user. Only returned to false after a user submits the form.
@property (assign, nonatomic) BOOL presentedForm;

// Returned from API calls. Can potentially hold actions that will occur after a chat is completed.
@property (strong, nonatomic) NSArray *postChatActions;

// Incremented each time an agent sends a message.
@property (assign, nonatomic) NSUInteger agentInteractionCount;
     
@property (strong, nonatomic) ECSCachingImageView *tempImageView;

@end

@implementation ECSChatViewController

@synthesize chatClient, messages, participants;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    _showingMoxtra = FALSE;
    
    self.logger = [[EXPERTconnect shared] logger];
    
    ECSCafeXController *cafeXController = [[ECSInjector defaultInjector] objectForClass:[ECSCafeXController class]];
    [cafeXController setDefaultParent:self];
    
    self.agentInteractionCount              = 0;
    self.showFullScreenReachabilityMessage  = NO;
    self.currentReconnectIndex              = -1;
    self.chatToolbar.sendEnabled            = NO;
    
    _agentTypingIndex       = -1;
    _reconnectCount         = 0;
    _previousReachableStatus = YES;
    _agentAnswered          = NO;
    
    self.participants = [NSMutableDictionary new];  // Create the new arrays for messages / participants
    self.messages = [NSMutableArray new];
    
    // Setup notification observers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkConnectionChanged:)
                                                 name:ECSReachabilityChangedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenShareEnded:)
                                                 name:@"NotificationScreenShareEnded"
                                               object:nil];
    
    // If host app sends this notification, we will end the chat (no dialog).
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(endChatByUser)
                                                 name:ECSEndChatNotification
                                               object:nil];
    
    // View Setup Functions
    [self registerForKeyboardNotifications];    // Keyboard observers
    [self configureNavigationBar];              // Show back button if nav bar present.
    [self registerTableViewCells];              // Register type of table view cells we might see
    [self addChatToolbarView];                  // Add the bottom toolbar to view.
    [self addChatWaitView];                     // Add the "waiting for agent" view.
    
}

- (void)configureNavigationBar
{
    self.navigationItem.title = self.actionType.displayName;
    
    if ([[self.navigationController viewControllers] count] > 1 && !self.navigationItem.leftBarButtonItem)
    {
        // Configure the "back" button on the nav bar
        ECSImageCache *imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];
        UIImage *backImage = [[imageCache imageForPath:@"ecs_ic_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(backButtonPressed:)];
    }
}

- (void)registerTableViewCells
{
    [self.tableView registerClass:[ECSChatMessageTableViewCell class] forCellReuseIdentifier:MessageCellID];
    [self.tableView registerClass:[ECSHtmlMessageTableViewCell class] forCellReuseIdentifier:HtmlMessageCellID];
    [self.tableView registerClass:[ECSChatImageTableViewCell class] forCellReuseIdentifier:ImageCellID];
    [self.tableView registerClass:[ECSChatTypingTableViewCell class] forCellReuseIdentifier:MessageTypingCellID];
    [self.tableView registerClass:[ECSChatActionTableViewCell class] forCellReuseIdentifier:ActionCellID];
    [self.tableView registerNib:[ECSChatTextTableViewCell ecs_nib] forCellReuseIdentifier:TextCellID];
    [self.tableView registerNib:[ECSChatNetworkActionCell ecs_nib] forCellReuseIdentifier:ChatNetworkCellID];
    [self.tableView registerClass:[ECSInlineFormTableViewCell class] forCellReuseIdentifier:InlineFormCellID];
}

- (void)addChatToolbarView
{
    if (!self.historyJourney)
    {
        self.chatToolbar = [ECSChatToolbarController ecs_loadFromNib];
        self.chatToolbar.delegate = self;
        [self addChildViewController:self.chatToolbar];
        self.chatToolbar.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.chatToolbarContainer addSubview:self.chatToolbar.view];
        
        // Fill the contents of it's container view.
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:@{@"view": self.chatToolbar.view}];
        NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:@{@"view": self.chatToolbar.view}];
        [self.chatToolbarContainer addConstraints:constraints];
        [self.chatToolbarContainer addConstraints:verticalConstraints];
    }
}

- (void)addChatWaitView
{
    self.waitView = [ECSChatWaitView ecs_loadInstanceFromNib];
    self.waitView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.waitView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"view": self.waitView}]];
    
    // Fill top to bottom
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.waitView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    
    // Fill left to right
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.waitView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f
                                                           constant:0.0f]];
}

- (void)dealloc {
    
    [self.chatClient disconnect]; // Disconnect Stomp
    self.tableView.delegate = nil;
    self.workflowDelegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    ECSLogVerbose(self.logger, @"viewWillAppear. InQueue? %d.", [self userInQueue]);
    
    if (self.waitView)
    {
        [self.waitView.loadingView startAnimating];
        
        if (!self.historyJourney)
        {
            ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
            if (userManager.userDisplayName.length > 0)
            {
                self.waitView.titleLabel.text = [NSString stringWithFormat:ECSLocalizedString(ECSLocalizeWelcomeWithUsername, @"Welcome with username"), userManager.userDisplayName];
            }
            else
            {
                self.waitView.titleLabel.text = ECSLocalizedString(ECSLocalizeWelcome, @"Welcome");
            }
            
            self.waitView.subtitleLabel.text = ECSLocalizedString(ECSLocalizeGenericWaitTime, @"Generic wait time");
        }
        else
        {
            self.waitView.titleLabel.text = @"";
            self.waitView.subtitleLabel.text = @"";
        }
    }
    
    if (self.historyJourney)
    {
        // Server has noted we are reconnecting to a chat with history. Load the history.
        if (!self.messages || self.messages.count == 0)
        {
            [self loadHistoryForJourney:self.historyJourney];
        }
    }
    else if (!self.chatClient)
    {
        // Initiate a new Chat Stomp client.
        self.chatClient = [ECSStompChatClient new];
        self.chatClient.delegate = self;
        [self.chatClient setupChatClientWithActionType:self.actionType];
    }
    
    // Reload selected table cell (used to update form cells)
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath)
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];

    if (_showingPostChatSurvey) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if (self.presentedForm) {
        
        self.presentedForm = NO;
        //[self sendFormNotification];  // mas 7-jun-2017 This notification is type=interview which currently says "form completed" in ExD. This is regardless of whether user completed form. Disabling notification until ExD reports the right text, or another notification can be sent (such as "user started survey but cancelled").
    }
    
    if( self.waitView ) {
        
        [self.waitView startLoadingAnimation];
    }
    
}
- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    [self updateEdgeInsets];
}

#pragma mark - View Navigation Functions

- (void)backButtonPressed:(id)sender {
    
    NSLog(@"Chat state = %lu", (unsigned long)self.chatClient.channelState);
    
    if (self.chatClient.channelState == ECSChannelStateConnected) {
        
        //- (void)exitChatButtonTapped:(id)sender
        [self exitChatButtonTapped:nil];
        
    } else {
        
        if(self.workflowDelegate) {
            
            //if([self.actionType.displayName isEqualToString:@"Chat Workflow"])
            //{
            [self.workflowDelegate chatEndedWithTotalInteractionCount:self.messages.count
                                                    agentInteractions:self.agentInteractionCount
                                                     userInteractions:self.messages.count-self.agentInteractionCount];
            //}
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            
            if( self.waitView ) {
                
                [self dialogLeaveQueue];
                
            } else {
//                [self.workflowDelegate endVideoChat];
//                [self.chatClient disconnect];
//                [self.navigationController popViewControllerAnimated:YES];
                [self endChatByUser];
            }
        }
    }
}

// Show a dialog asking the user if they are sure they want to leave the queue (they could lose their place...)
- (void)dialogLeaveQueue
{
    NSString *alertTitle = ECSLocalizedString(ECSLocalizedLeaveQueueTitle, @"Warning");
    NSString *alertMessage = ECSLocalizedString(ECSLocalizedLeaveQueueMessage, @"Chat Disconnect Prompt");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                             message:alertMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizedLeaveQueueNo, @"NO")
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizedLeaveQueueYes, @"YES")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action)
                                {
                                    // Remove the user from the queue and deconstruct the chat.
//                                    [self.workflowDelegate endVideoChat];
//                                    [self.chatClient disconnect];
//                                    [self.navigationController popViewControllerAnimated:YES];
                                    [self endChatByUser];
                                }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)minimizeButtonPressed:(id)sender
{
    if ([self.workflowDelegate respondsToSelector:@selector(minimizeButtonTapped:)])
    {
        [self.workflowDelegate minimizeButtonTapped:sender];
    }
}

- (void)pollForPostSurvey
{
    static NSUInteger pollInterval = 3;
    
    // Only make the call if the agent interval is met
    if (self.agentInteractionCount % pollInterval != 0)
    {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self checkForPostActions:^(NSArray *result, NSError *error)
    {
        if (!error && (result.count > 0) && ([result.firstObject isKindOfClass:[ECSFormActionType class]]))
        {
            weakSelf.postChatActions = result;
        }
    }];
}

- (void)handleDisconnectPostSurveyCall
{
    __weak typeof(self) weakSelf = self;
    [self checkForPostActions:^(NSArray *result, NSError *error)
    {
        [self.workflowDelegate endVideoChat];
        //ECSChatActionType *actionType = (ECSChatActionType *)self.actionType;
        
        if (result.count && !error) {
            weakSelf.postChatActions = result;
            [weakSelf showSurveyDisconnectMessage];
        }
        else {
            [weakSelf showNoSurveyDisconnectMessage];
        }
    }];
}

-(void)checkForPostActions:(void (^)(NSArray* result, NSError* error))completion
{
    
    ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    //__weak typeof(self) weakSelf = self;
    [sessionManager getEndChatActionsForConversationId:self.chatClient.currentConversation.conversationID
                             withAgentInteractionCount:self.agentInteractionCount
                                     navigationContext:self.parentNavigationContext
                                              actionId:self.actionType.actionId
                                            completion:^(NSArray* result, NSError *error)
    {
        completion(result, error);
    }];
}


-(void) handleReceiveSendQuestionMessage:(ECSSendQuestionMessage *)message
{
    NSString *question = message.questionText;
    NSString *context = message.interfaceName;
    
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    
    __weak typeof(self) weakSelf = self;
    
    [sessionManager getAnswerForQuestion:question
                               inContext:context
                         parentNavigator:@""
                                actionId:@""
                           questionCount:0
                              customData:nil
                              completion:^(ECSAnswerEngineResponse *response, NSError *error)
     {
         ECSReceiveAnswerMessage *answer = [ECSReceiveAnswerMessage new];
         
         answer.from = message.from;
         answer.answerText = response.answer;
         answer.fromAgent = YES;
         
         [weakSelf chatClient:nil didReceiveMessage:answer];
     }];
}


- (void)closeButtonTapped:(id)sender {
    
    ECSLogVerbose(self.logger, @"User pressed navigation close button.");
    
    [super closeButtonTapped:sender];
    [self.workflowDelegate endVideoChat];
    [self.chatClient disconnect];
    [self.navigationController popViewControllerAnimated:NO];
    
    if (self.chatClient.channelState != ECSChannelStateDisconnected) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ECSChatEndedNotification
                                                            object:self];
    }
}

- (void)showSurveyOrPopView
{
    [self.chatToolbar resignFirstResponder];
    
    if(self.workflowDelegate)
    {
        //if([self.actionType.displayName isEqualToString:@"Chat Workflow"])
        //{
        [self.workflowDelegate chatEndedWithTotalInteractionCount:self.messages.count
                                                agentInteractions:self.agentInteractionCount
                                                 userInteractions:self.messages.count-self.agentInteractionCount];
        //}
    }
    
    // Check to see if we have a chat action to act upon.
    if (self.postChatActions && (self.postChatActions.count > 0) &&
        ([self.postChatActions.firstObject isKindOfClass:[ECSFormActionType class]]))
    {
        ECSFormActionType *formAction = self.postChatActions.firstObject;
        
        UIViewController *surveyFormController = [ECSRootViewController ecs_viewControllerForActionType:formAction];
        
        [self presentModal:surveyFormController withParentNavigationController:self.navigationController fromViewController:self.navigationController];
        
        _showingPostChatSurvey = YES;
    }
    else
    {
        // No post-action. Close the window and send the notification so host app can act.
//        [self.navigationController popViewControllerAnimated:YES];
        
        if (self.isBeingPresented) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
//        if (self.chatClient.channelState != ECSChannelStateDisconnected) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ECSChatEndedNotification object:self];
//        }
    }
}

- (void)showNoSurveyDisconnectMessage {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        ECSChatInfoMessage *disconnectedMessage = [ECSChatInfoMessage new];
        disconnectedMessage.infoMessage = ECSLocalizedString(ECSLocalizeChatDisconnected, @"Disconnected");
        
        [self.messages addObject:disconnectedMessage];
        
        [self.tableView reloadData];
        
    });
}

- (void)showSurveyDisconnectMessage {
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        ECSEndChatSurveyView *endChatView = [ECSEndChatSurveyView ecs_loadInstanceFromNib];
        
        [endChatView.exitChatButton addTarget:self
                                       action:@selector(exitChatButtonTapped:)
                             forControlEvents:UIControlEventTouchUpInside];
        
        self.tableView.tableFooterView = endChatView;
        
        [self.tableView reloadData];
        
        [self.tableView scrollRectToVisible:CGRectMake(0,
                                                       self.tableView.contentSize.height - self.tableView.bounds.size.height,
                                                       self.tableView.bounds.size.width,
                                                       self.tableView.bounds.size.height) animated:YES];
        
    });
}

- (void)exitChatButtonTapped:(id)sender {
    
    ECSLogVerbose(self.logger, @"User pressed navigation exit chat button.");
    
    // Check for actions one more time. This should return
    __weak typeof(self) weakSelf = self;
    
    [weakSelf checkForPostActions:^(NSArray *results, NSError *error) {
        
        if (results && !error) {
            
            weakSelf.postChatActions = results;
             
            NSString *alertTitle = ECSLocalizedString(ECSLocalizeWarningKey, @"Warning");
            NSString *alertMessage = ECSLocalizedString(ECSLocalizeChatDisconnectPrompt, @"Chat Disconnect Prompt");
             
            // If we have something to do after, display a different message.
            if (self.postChatActions.count > 0) {
                
                alertMessage = ECSLocalizedString(ECSLocalizeChatDisconnectPromptSurvey, @"Chat Disconnect Prompt");
            }
             
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                                     message:alertMessage
                                                                              preferredStyle:UIAlertControllerStyleAlert];
             
            [alertController addAction:[UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizeYes, @"YES")
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action)
                                        {
                                             
                                            [self endChatByUser];
                                        }]];
             
            [alertController addAction:[UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizeNo, @"NO")
                                                                 style:UIAlertActionStyleCancel
                                                               handler:nil]];
             
            [weakSelf presentViewController:alertController animated:YES completion:nil];
            
        } else {
            
            NSLog(@"exitChatButtonTapped - Error checking for post actions: %@", error.description);
            
            if(weakSelf) {
                
                [self endChatByUser];
            }
        }
    }];
}

- (void)endChatByUser {
    
    [self.workflowDelegate endVideoChat];
    [self.chatClient disconnect];
    [self showSurveyOrPopView];
}

- (void)hideWaitView
{
     if (self.waitView)
     {
        [UIView animateWithDuration:0.3f
                         animations:^{self.waitView.alpha = 0.0f;}
                         completion:^(BOOL finished)
         {
             [self.waitView removeFromSuperview];
             self.waitView = nil;
               
             // mas - 11-oct-15 - only show "minimize" if we are in a workflow.
             // mas - 5-aug-16 - only show if the integrator has not already added a rightButton
             // mas - 10-aug-16 - never show minimize. Host app can add this. 
             /*if( self.workflowDelegate &&
                 self.navigationController &&
                 [self presentingViewController] &&
                 !self.navigationItem.rightBarButtonItem )
             {
                 self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Minimize"
                                                                                           style:UIBarButtonItemStylePlain
                                                                                          target:self
                                                                                          action:@selector(minimizeButtonPressed:)];
             }*/
         }]; // completion
     }
}

#pragma mark - Chat Toolbar callbacks
- (void)sendChatState:(NSString *)chatState
{
    NSString *sendState = nil;
    if ([chatState isEqualToString:@"composing"])
    {
        //        _userTyping = YES;
        sendState = chatState;
    }
    else if ([chatState isEqualToString:@"paused"])
    {
        //        _userTyping = NO;
        sendState = chatState;
    }
    
    if(sendState)
    {
        ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
        [urlSession sendChatState:chatState
                         duration:10000
                          channel:self.chatClient.currentChannelId
                       completion:^(NSString *response, NSError *error) {
             
             if(error) {
                 ECSLogError(self.logger, @"Error sending chat state message: %@", error);
             }
         }];
    }
}

- (void)sendText:(NSString *)text
{
    NSString *timeStamp = [[EXPERTconnect shared] getTimeStampMessage];
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    ECSChatTextMessage *message = [ECSChatTextMessage new];
    
    message.from = self.chatClient.fromUsername;
    message.fromAgent = NO;
    message.channelId = self.chatClient.currentChannelId;
    message.conversationId = self.chatClient.currentConversation.conversationID;
    
    message.body = text;
    
    if(theme.showChatTimeStamp  == YES)
    {
        if(![timeStamp isEqualToString:self.chatClient.lastTimeStamp])
        {
            message.timeStamp = timeStamp;
        }
        else{
            if (self.chatClient.lastChatMessageFromAgent == YES) {
                message.timeStamp = timeStamp;
            }
        }
        self.chatClient.lastTimeStamp = timeStamp;
    }
	 	 
    [self.messages addObject:message];
    
    self.chatClient.lastChatMessageFromAgent = NO;
    // [self sendChatState:@"paused"];
    
    //[self.chatClient sendChatMessage:message];
    ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    [urlSession sendChatMessage:message.body
                           from:message.from
                        channel:message.channelId
                     completion:^(NSString *response, NSError *error)
     {
         if(error) {
             ECSLogError(self.logger, @"Error sending chat message: %@", error);
             
             [self showAlertForErrorTitle:ECSLocalizedString(ECSLocalizeError,@"Error")
                                  message:ECSLocalizedString(ECSLocalizeErrorText, nil)];
         }
     }];
    
//    // TODO: Testing only
//    [urlSession sendChatMessage:[NSString stringWithFormat:@"2 - %@", message.body]
//                           from:message.from
//                        channel:message.channelId
//                     completion:^(NSString *response, NSError *error){}];
//    [urlSession sendChatMessage:[NSString stringWithFormat:@"3 - %@", message.body]
//                           from:message.from
//                        channel:message.channelId
//                     completion:^(NSString *response, NSError *error){}];
//    [urlSession sendChatMessage:[NSString stringWithFormat:@"4 - %@", message.body]
//                           from:message.from
//                        channel:message.channelId
//                     completion:^(NSString *response, NSError *error){}];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

// NK 6/17
- (void)sendSystemText:(NSString *)text
{
    ECSChatTextMessage *message = [ECSChatTextMessage new];
    
    message.from = @"System";
    message.fromAgent = NO;
    message.channelId = self.chatClient.currentChannelId;
    message.conversationId = self.chatClient.currentConversation.conversationID;
    
    message.body = text;
    [self.messages addObject:message];
    //[self.chatClient sendChatMessage:message];
    ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    [urlSession sendChatMessage:message.body
                           from:message.from
                        channel:message.channelId
                     completion:^(NSString *response, NSError *error)
     {
         if(error) {
             ECSLogError(self.logger, @"Error sending system message: %@", error);
             
//             [self showAlertForErrorTitle:ECSLocalizedString(ECSLocalizeError,@"Error")
//                                  message:ECSLocalizedString(ECSLocalizeErrorText, nil)];
         }
     }];
    
    /* NK 6/29/2015 I've decided to not show the Consumer when he/she sends a System message. These are intended for
     the Expert to view, only. Also, this doesn't work well and would need to be refactored. */
    
    /*
     [self.tableView beginUpdates];
     [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
     [self.tableView endUpdates];
     [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
     */
}

- (void)sendMedia:(NSDictionary *)mediaInfo
{
    ECSChatMediaMessage *message = [ECSChatMediaMessage new];
    
    message.from = self.chatClient.fromUsername;
    message.fromAgent = NO;
    message.channelId = self.chatClient.currentChannelId;
    message.conversationId = self.chatClient.currentConversation.conversationID;
    message.imageThumbnail = [ECSMediaInfoHelpers thumbnailForMedia:mediaInfo];
    message.url = [ECSMediaInfoHelpers filePathForMedia:mediaInfo];
    
    NSString *mediaType = mediaInfo[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString*)kUTTypeImage])
    {
        message.mediaType = ECSChatMediaTypeImage;
    }
    else if ([mediaType isEqualToString:(NSString*)kUTTypeMovie])
    {
        message.mediaType = ECSChatMediaTypeMovie;
    }
    
    [self.messages addObject:message];
    
    self.chatClient.lastChatMessageFromAgent = NO;
    
    NSIndexPath *insertIndexPath = [NSIndexPath indexPathForItem:self.messages.count - 1 inSection:0];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[insertIndexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    ECSURLSessionManager *session = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    //__weak typeof(self) weakSelf = self;
    
    NSString *uploadName = [ECSMediaInfoHelpers uploadNameForMedia:mediaInfo];
    [session uploadFileData:[ECSMediaInfoHelpers uploadDataForMedia:mediaInfo]
                   withName:uploadName
            fileContentType:[ECSMediaInfoHelpers fileTypeForMedia:mediaInfo]
                 completion:^(__autoreleasing id *response, NSError *error)
     {
         if (error)
         {
             ECSLogError(self.logger,@"Failed to send media %@", error);
         }
         else
         {
             ECSLogVerbose(self.logger,@"Media uploaded successfully");
             /*ECSChatNotificationMessage *notification = [ECSChatNotificationMessage new];
              notification.from = self.chatClient.fromUsername;
              notification.channelId = self.chatClient.currentChannelId;
              notification.conversationId = self.chatClient.currentConversation.conversationID;
              notification.type = @"artifact";
              notification.objectData = uploadName;
              [weakSelf.chatClient sendNotificationMessage:notification];*/
             
             ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
             
             [urlSession sendChatNotificationFrom:self.chatClient.fromUsername
                                             type:@"artifact"
                                       objectData:uploadName
                                   conversationId:self.chatClient.currentConversation.conversationID
                                          channel:self.chatClient.currentChannelId
                                       completion:^(NSString *response, NSError *error)
              {
                  if(error)
                  {
                       NSLog(@"Error sending chat media message: %@", error);
//                      [self showReconnectInChat];
//                      [self showAlertForError:error fromFunction:@"sendMedia"];
                  }
              }];
         }
     }];
}

#pragma mark - StompClient

- (void)chatClientDidConnect:(ECSStompChatClient *)stompClient {
    
    ECSLogVerbose(self.logger, @"Stomp connect notification.");
                  
    // Delete the "Reconnect" button if it is still displayed in the chat
    [self hideNetworkErrorBar];
    
    if(_reconnectTimer) [_reconnectTimer invalidate];
    
    [self.chatToolbar initializeSendState];
}

//- (void)chatClientDisconnected:(ECSStompChatClient *)stompClient wasGraceful:(bool)graceful
- (void)chatClient:(ECSStompChatClient *)stompClient disconnectedWithMessage:(ECSChannelStateMessage *)message {
    
    ECSLogDebug(self.logger, @"Stomp disconnect notification. DisconnectReason=%@, TerminatedBy=%@",
                  message.disconnectReasonString,
                  message.terminatedByString);
    
    self.chatToolbar.sendEnabled = NO;
    
    if( ![EXPERTconnect shared].urlSession.networkReachable ) {
        
        // Network was down, so this disconnect message came locally. The red network error bar is shown. Do nothing.
        
    } else if ( message.disconnectReason == ECSDisconnectReasonError ) {
        
        // Some kind of Stomp error or the heartbeat has failed enough that we think we lost connection to the server.
        self.chatToolbar.sendEnabled = NO;
        [self showNetworkErrorBar];
        _reconnectCount = 0;
        
        [self scheduleAutomaticReconnect];
        
    } else {
        
        if( message.disconnectReason == ECSDisconnectReasonDisconnectByParticipant && message.terminatedBy == ECSTerminatedByAssociate ) {
            // The agent ended the chat.
            
            ECSLogDebug(self.logger, @"Issuing an UNSUBSCRIBE because agent ended chat. We have nothing else to listen for"); 
            [self.chatClient unsubscribe];
        }
        
        if( self.waitView ) {
            
            [self showAlertForErrorTitle:ECSLocalizedString(ECSLocalizeErrorKey,@"Error")
                                 message:ECSLocalizedString(ECSLocalizedChatQueueDisconnectMessage, @"Your chat request has timed out.")];
            
        } else {
            
//            ECSCafeXController *cafeXController = [[ECSInjector defaultInjector] objectForClass:[ECSCafeXController class]];
//            if ([cafeXController hasCafeXSession]) {
//                [cafeXController endCoBrowse];
//            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ECSChatEndedNotification object:self];
            
            [self handleDisconnectPostSurveyCall];
        }
    }
}

- (void)chatClient:(ECSStompChatClient *)stompClient didReceiveChatNotificationMessage:(ECSChatNotificationMessage*)notificationMessage
{
    [self.messages addObject:notificationMessage];
    
    self.chatClient.lastChatMessageFromAgent = YES;
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:[self indexPathsToUpdate] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ECSChatNotificationMessageReceivedNotification
                                                        object:notificationMessage];
}

- (void) scheduleAutomaticReconnect {
    
    ECSLogDebug(self.logger, @"Scheduling a reconnect 30 seconds from now...");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                                           target:self
                                                         selector:@selector(reconnectTimer_Tick:)
                                                         userInfo:nil
                                                          repeats:YES];
    });
}

- (void)chatClient:(ECSStompChatClient *)stompClient didFailWithError:(NSError *)error
{
    ECSLogDebug(self.logger, @"Error: %@", error);
    
    // Now handled in the StompClient code.
//    if([error.domain isEqualToString:ECSErrorDomain] && error.code == ECS_ERROR_STOMP) {
//        
//        // mas - jan-24-2017 - Ignore this error. User does not need to see it.
//        ECSLogVerbose(self.logger, @"Got redundant connection closed error from STOMP - ignoring.");
//    
//    } else
    
    if( [error.domain isEqualToString:@"ECSWebSocketErrorDomain"] ||
        [error.domain isEqualToString:@"kCFErrorDomainCFNetwork"] ||
        ( [error.domain isEqualToString:NSPOSIXErrorDomain] && (error.code >= ENETDOWN && error.code <= ENOTCONN) ) ) {
        
        [self showNetworkErrorBar];
        
        if( [error.userInfo[ECSHTTPResponseErrorKey] intValue] == 401 ) {
            // Let's immediately try to refresh the auth token.
            [self refreshAuthenticationToken];
        }
        
        [self scheduleAutomaticReconnect];
    
    } else {
        /* Example Errors:
                NSURLErrorDomain, -1004, "Could not connect to the server"
         */
        
        // Any unknown errors
        NSString *errorMessage = ECSLocalizedString(ECSLocalizeErrorText, nil);
        
        BOOL validError = (![error.userInfo[NSLocalizedDescriptionKey] isEqual:[NSNull null]] &&
                           error.userInfo[NSLocalizedDescriptionKey]);
        
        // We have an actual error message to display. We'll replace the generic one with this.
        if (error && validError)
        {
            // MAS - show generic error message
            //errorMessage = error.userInfo[NSLocalizedDescriptionKey];
            errorMessage = ECSLocalizedString(ECSLocalizeErrorText, nil);
            
            // NOTE: This is a specific case to handle "No agents available" until the server does it correctly.
            if([error.userInfo[NSLocalizedDescriptionKey] isEqualToString:@"No agents available"])
            {
                // Let's localize this.
                errorMessage = ECSLocalizedString(ECSLocalizeNoAgents, @"No Agents Available.");
            }
            
        }
        [self showAlertForErrorTitle:ECSLocalizedString(ECSLocalizeError,@"Error") message:errorMessage];
        
        //    if([error.domain isEqualToString:@"kCFErrorDomainCFNetwork"])
        //    {
        //        // Network error. Don't kill it. Give user a chance to reconnect.
        //        NSLog(@"chat::didFailWithError - Network error. Show reconnect button.");
        //        [self networkConnectionChanged:nil];
        //        _reconnectCount = 0; // Reset.
        //    }
        //    else if([error.domain isEqualToString:@"ECSWebSocketErrorDomain"] && _reconnectCount < 3)
        //    {
        //        // mas - jan-24-2017 - Separated out the error in the following else-if case. It did not need an error thrown to the user.
        //        // Let's attempt to get a new token.
        //        _reconnectCount++;
        //
        //        // mas - jan-24-2017 - Can cause threading & other issues to delay a reconnect.
        //        //[self performSelector:@selector(attemptReconnect) withObject:nil afterDelay:0.5];
        //        [self attemptReconnect];
        //    }
    }
}

- (void) reconnectTimer_Tick:(NSTimer *)timer {

    if ([EXPERTconnect shared].urlSession.networkReachable && [self.chatClient isConnected]) {
        
        ECSLogDebug(self.logger, @"Reconnect Timer - We're already connected. Invalidating.");
        dispatch_async(dispatch_get_main_queue(), ^{
            [_reconnectTimer invalidate];
            _reconnectTimer = nil;
        });
        
    } else {
        
        ECSLogDebug(self.logger, @"Reconnect Timer - Still disconnected. Attempting reconnect...");
        [self refreshAuthenticationToken];
        
    }
}

-(void) chatClientTimeoutWarning:(ECSStompChatClient *)stompClient
                  timeoutSeconds:(int)seconds {
    
    ECSChatInfoMessage *message = [ECSChatInfoMessage new];
//    message.fromAgent = YES;
    
    NSString *warningString = ECSLocalizedString(ECSChannelTimeoutWarningKey, @"Your chat will timeout in %d seconds due to inactivity.");
    message.infoMessage = [NSString stringWithFormat:warningString, seconds];
    [self.messages addObject:message];
    [self.tableView reloadData];
}

-(void) screenShareEnded:(NSNotification*)notification
{
    if ([notification.name isEqualToString:@"NotificationScreenShareEnded"])
    {
//        _showingMoxtra = FALSE;
        
        [self updateEdgeInsets];
    }
}

- (void)chatClient:(ECSStompChatClient *)stompClient didReceiveMessage:(ECSChatMessage *)message {
    
    // This section is for special handling of a few types of messages.
    
    if ([message isKindOfClass:[ECSCafeXMessage class]]) {
        
        [self handleCafeXMessage:((ECSCafeXMessage*)message)];
        return; // no UI
        
    } else if ([message isKindOfClass:[ECSChatVoiceAuthenticationMessage class]]) {
        
        [self handleVoiceItMessage:message];
        return; // no UI
        
    } else if ([message isKindOfClass:[ECSChatAddParticipantMessage class]]) {
        
        [self.participants setObject:message forKey:((ECSChatAddParticipantMessage*)message).userId];
        
    } else if ([message isKindOfClass:[ECSSendQuestionMessage class]]) {
        
        [self handleReceiveSendQuestionMessage:(ECSSendQuestionMessage *)message];
        return; // When Response is received, handler will send through an ECSReceiveAnswerMessage
        
    }
        
    if( [message isKindOfClass:[ECSChatTextMessage class]] ) {
        if( [self isNonLocalizedInBandSystemMessage:(ECSChatTextMessage *)message] ) {
            return; // no UI
        }
    }
    
    // This is the meat & potatoes of displaying messages.
    
    if (message.fromAgent) {
        
        self.agentInteractionCount += 1;
        [self pollForPostSurvey];
        self.chatClient.lastChatMessageFromAgent = YES;
    }
    
    // Replace the typing (...) with the message if it is still at the end of the array of messages.
    if (_agentTypingIndex != -1 && (_agentTypingIndex == self.messages.count - 1)) {
        
        [self.messages replaceObjectAtIndex:_agentTypingIndex withObject:message];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_agentTypingIndex inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        _agentTypingIndex = -1;
        
    } else {
        
        // Remove the agent typing (...) from the chat history and append this new message.
        if (_agentTypingIndex != -1) {
            
            [self.messages removeObjectAtIndex:_agentTypingIndex];
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_agentTypingIndex inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            
            _agentTypingIndex = -1;
        }
        
        [self.messages addObject:message];
        [self.tableView beginUpdates];
        
        /* NK 7/27/2015 Note that this change (indexPathsToUpdate) was made to fix a crash with scrolling to the
         bottom of the chat list under certain circumstances. Change made by Mutual Mobile. */
        [self.tableView insertRowsAtIndexPaths:[self indexPathsToUpdate] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.tableView endUpdates];
    }
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ECSChatMessageReceivedNotification
                                                        object:message];
    
}

- (bool)isNonLocalizedInBandSystemMessage:(ECSChatTextMessage *)message {
    
    // Note: We want to filter out these in-band non-localized "system" messages from the old legacy system.
    // They usually say: "Mike (mike_mktwebextc) has joined the chat.", "Mike (mike_mktwebextc) has left the chat."
    
    if( [message.from isEqualToString:@"System"] &&
       ([message.body containsString:@") has joined the chat."] ||
        [message.body containsString:@") has left the chat."] ||
        [message.body containsString:@"This chat is being transferred..."]) ) {
        // NOTE: Except for the first agent, any agent that joins or leaves the chat will trigger a
        // 'System' message informing the user of the change. The 'joins' are redundant because of the
        // AddParticipant message. So, we'll squelch them here.
        
        return YES;
    }
    return NO;
}

- (void)chatClient:(ECSStompChatClient *)stompClient didReceiveChatStateMessage:(ECSChatStateMessage *)state
{
    //if(state.object && [state.type isEqualToString:@"artifact"])
    //{
    // We have an incoming document from the server.
    //(NSURLSessionDataTask *)getMediaFileNamesWithCompletion
    //}
    
    if (state.chatState == ECSChatStateComposing) {
        
        // If display had no (...), then add one.
        if (_agentTypingIndex == -1)
        {
            _agentTypingIndex = [self.messages count];
            [self.messages addObject:state];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
    } else if(state.chatState == ECSChatStateTypingPaused) {
        
        // If display has a (...), remove it.
        if (_agentTypingIndex != -1)
        {
            [self.messages removeObjectAtIndex:_agentTypingIndex];
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_agentTypingIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
        _agentTypingIndex = -1;
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ECSChatStateMessageReceivedNotification
                                                        object:state];
}

- (void) chatClient:(ECSStompChatClient *)stompClient didReceiveChannelStateMessage:(ECSChannelStateMessage *)channelStateMessage {
    
    if( channelStateMessage.channelState == ECSChannelStateQueued ) {
    
        // If already connected, then we're being transferred...
    
        if( _agentAnswered ) {
    
            ECSChatInfoMessage *newInfoMessage = [[ECSChatInfoMessage alloc]
                                         initWithInfoMessage:ECSLocalizedString(ECSLocalizeChatTransfer, @"The chat is being transferred...")
                                                  biggerFont:YES];

            [self.messages addObject:newInfoMessage];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}



- (void)chatClient:(ECSStompChatClient *)stompClient didUpdateEstimatedWait:(NSInteger)waitTime;
{
//    waitTime = -3; // TESTING ONLY. (in seconds)
//    waitMinutes = waitTime / 60.0f; // Convert seconds to minutes
    int waitMinutes = round(waitTime / 60.0f);

    NSString *waitStringKey = ECSLocalizeWaitTimeShort;
    
    if ( waitTime <= 60 ) // seconds
    {
        waitStringKey = ECSLocalizeWaitTimeShort;
    }
    else if ( waitTime > 60 && waitMinutes < 300 ) // 1 to 5 minutes
    {
        waitStringKey = ECSLocalizeWaitTime;
    }
    else if ( waitMinutes >= 300 ) // Greater than 5 minutes
    {
        waitStringKey = ECSLocalizeWaitTimeLong;
    }
    
    // Grab the localized string value based on the key provided above.
    NSString *waitString = ECSLocalizedString(waitStringKey, @"Wait time");
    
    // If the string has a place to put the wait minutes (%1d) then replace it with actual minutes.
    if( [waitString containsString:@"%1d"])
    {
        waitString = [NSString stringWithFormat:waitString, waitMinutes];
    }
    
    self.waitView.subtitleLabel.text = waitString;
}

- (void)chatClientAgentDidAnswer:(ECSStompChatClient *)stompClient {
    
    ECSLogVerbose(self.logger, @"Stomp chat answered notification.");
    
    _agentAnswered = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ECSChatStartedNotification
                                                         object:self];
    [self hideWaitView];
}

- (void)voiceCallbackDidAnswer:(ECSStompChatClient *)stompClient
{
    if (_callbackViewController != nil) {
        //        [self.navigationController popToViewController:self animated:YES];
        //        _callbackViewController = nil;
        
        [_callbackViewController voiceCallbackDidAnswer:stompClient.delegate];
    }
}

- (void)chatClient:(ECSStompChatClient *)stompClient didAddChannelWithMessage:(ECSChatAddChannelMessage *)message {
    
    ECSLogDebug(self.logger, @"Add Channel Messages from: %@, channelID=%@", message.from, message.channelId);
    
    [self.messages addObject:message];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

#pragma mark - Connect / Reconnect / Disconnect

- (void)refreshAuthenticationToken {
    
    ECSLogDebug(self.logger,@"Refreshing auth token (forcing reconnect attempt). Retry #%d", _reconnectCount);

    // Attempt to get a new authToken.
    int retryCount = 0;
    [[EXPERTconnect shared].urlSession refreshIdentityDelegate:retryCount
                                                withCompletion:^(NSString *authToken, NSError *error)
     {
         // AuthToken updated. Try to reconnect. If error, the 30-second timer will continue and try again.
         if( !error ) [self.chatClient connectToHost:[EXPERTconnect shared].urlSession.hostName];
     }];
}

// The action when the user presses the "reconnect" button in the Network Action cell
- (void)reconnectWebsocket:(id)sender {
    
    if ( !self.chatClient.isConnected ) {
        
        ECSLogVerbose(self.logger, @"Attempting to reconnect to Stomp channel.");
        [self.chatClient reconnect];
        
    } else {
        
        ECSLogVerbose(self.logger, @"Stomp channel already connected.");
        
    }
}

// delegate method called when the status of the network on the device changes.
- (void)networkConnectionChanged:(id)sender {
    
    if( [[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground ) {
        ECSLogVerbose(self.logger, @"Network changed, but view is not active. Ignoring.");
        return;
    }
    
    bool reachable = [EXPERTconnect shared].urlSession.networkReachable;
    
    ECSLogDebug(self.logger, @"Network changed. Reachable? %d", reachable);
    
    if ( reachable && _previousReachableStatus == NO ) {
        
        // Network is now GOOD
        self.chatToolbar.sendEnabled = YES;
        [self hideNetworkErrorBar];
        [self reconnectWebsocket:nil];

    } else if ( !reachable ) {
        
        // Network is now BAD
        self.chatToolbar.sendEnabled = NO;
        [self showNetworkErrorBar];
        _reconnectCount = 0;
    }
    
    _previousReachableStatus = reachable;
}

#pragma mark - Network Error Handling

//- (void)addChatReconnectMessage {
//    
//    if(self.currentReconnectIndex < 0) {
//        
//        self.currentReconnectIndex = self.messages.count - 1;
//        [self.messages addObject:[ECSChatNetworkMessage new]];
//        [self.tableView reloadData];
//    }
//}
//
//- (void)removeChatReconnectMessage {
//    
//    // Remove reconnect message.
//    int i;
//    
//    for (i=0; i<self.messages.count; i++) {
//        if( [self.messages[i] isKindOfClass:[ECSChatNetworkMessage class]]) {
//            [self.messages removeObjectAtIndex:i]; // Remove the old
//            [self.tableView reloadData];
//            break;
//        }
//    }
//}

- (void) showNetworkErrorBar {
    
    // Show the red network error bar. Try to reconnect.
    if( !self.networkErrorView ) {
        
        ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
        
        self.networkErrorView = [ECSErrorBarView ecs_loadInstanceFromNib];
        self.networkErrorView.textLabel.text = ECSLocalizedString(ECSLocalizedChatQueueNetworkError, @"Network error.");
        self.networkErrorView.textLabel.font = theme.chatNetworkErrorFont;
        self.networkErrorView.textLabel.textColor = theme.chatNetworkErrorTextColor;
        self.networkErrorView.backgroundColor = theme.chatNetworkErrorBackgroundColor;
    
        // Start with the view above the top of the screen.
        [self.networkErrorView setFrame:CGRectMake(0,
                                                   -self.networkErrorView.bounds.size.height,
                                                   self.view.bounds.size.width,
                                                   self.networkErrorView.bounds.size.height)];
        [self.view addSubview:self.networkErrorView];
        [self.view bringSubviewToFront:self.networkErrorView];
        
        // Lock the height in at 55pixels.
        self.networkErrorView.translatesAutoresizingMaskIntoConstraints = NO;
        
        // Set the red bar to a fixed height equal to it's height setting.
        NSString *verticalConstraint = [NSString stringWithFormat:@"V:[networkView(==%f)]", self.networkErrorView.bounds.size.height];
        [self.networkErrorView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalConstraint
                                                                                      options:0
                                                                                      metrics:nil
                                                                                        views:@{@"networkView": self.networkErrorView}]];
        
        // Stretch it to the parent view's complete width.
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[networkView]-(0)-|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:@{@"networkView": self.networkErrorView}]];
        
        // Attach it to the top of the parent view.
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.networkErrorView
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0f
                                                              constant:0]];
        
        // The bar will drop down from above the top of the view.
        [UIView transitionWithView:self.view
                          duration:0.7
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            
            [self.networkErrorView setFrame:CGRectMake(0,
                                                       0,
                                                       self.view.bounds.size.width,
                                                       self.networkErrorView.bounds.size.height)];
                            
            
            
        }
        completion:^(BOOL success){
            ECSLogVerbose(self.logger, @"Displaying network error bar to the user.");
        }];
        
    }
}

- (void) hideNetworkErrorBar {
    
    if( self.networkErrorView ) {
        
        // Send the network error bar back to above the top of the view.
        
        [UIView transitionWithView:self.view
                          duration:0.7
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            
            [self.networkErrorView setFrame:CGRectMake(0,
                                                       -self.networkErrorView.bounds.size.height,
                                                       self.view.bounds.size.width,
                                                       self.networkErrorView.bounds.size.height)];
            
        }
        completion:^(BOOL success) {
            
            [self.networkErrorView removeFromSuperview];
            self.networkErrorView = nil;
            ECSLogVerbose(self.logger, @"Hiding the network error bar (network may be recovered).");
        }];
        
    }
}

#pragma mark - Convienence Functions

- (void)handleVoiceItMessage:(ECSChatMessage *)message
{
    ECSChatAddParticipantMessage *participant = [self participantInfoForID:((ECSChatStateMessage*)message).from];
    NSString *expertName = [participant firstName];
    
    if (expertName == nil || expertName.length == 0)
    {
        expertName = @"The Expert";
    }
    
    // Confirm with User:
    NSString *alertTitle = @"Voice Authentication";
    NSString *alertMessage = [NSString stringWithFormat:@"%@ has requested that you authenticate by voice print. Press OK to continue.",
                              expertName];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                             message:alertMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizedOkButton, @"OK")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action)
                                {
                                    
                                    /* Kick off internal VoiceIT auth check */
                                    [[EXPERTconnect shared] voiceAuthRequested:[[EXPERTconnect shared] userName] callback:^(NSString *response)
                                     {
                                         // Alert Agent to the response:
                                         [self sendVoiceAuthConfirmation:response];
                                     }];
                                }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)handleCafeXMessage:(ECSCafeXMessage *)message
{
    ECSChatAddParticipantMessage *participant = [self participantInfoForID:message.from];
    NSString *expertName = [participant firstName];
    
    if (expertName == nil || expertName.length == 0)
    {
        expertName = @"The Expert";
    }
    
    NSString *channelName = nil;
    NSString *channelType = message.parameter1;
    
    if ([channelType isEqualToString:@"voice_escalate"])
    {
        channelName = @"a Voice Call";
    }
    else if ([channelType isEqualToString:@"video_escalate"])
    {
        channelName = @"a Video Call";    }
    else if ([channelType isEqualToString:@"cobrowse_start"])
    {
        channelName = @"that you share your screen.";
    }
    else if ([channelType isEqualToString:@"cobrowse_stop"])
    {
        /* no op */
    }
    else
    {
        ECSLogError(self.logger,@"Unable to parse CafeX TT:Command: Unknown channel type %@", channelType);
        return; // no UI
    }
    
    NSString *targetID = message.parameter2;
    
    // Confirm with User only if video or voice:
    if ([channelType isEqualToString:@"cobrowse_start"])
    {
        // CafeX will prompt user.
        ECSCafeXController *cafeXController = [[ECSInjector defaultInjector] objectForClass:[ECSCafeXController class]];
        [cafeXController startCoBrowse:targetID usingParentViewController:self];
    }
    else if ([channelType isEqualToString:@"cobrowse_stop"])
    {
        ECSCafeXController *cafeXController = [[ECSInjector defaultInjector] objectForClass:[ECSCafeXController class]];
        [cafeXController endCoBrowse];
    }
    else
    {
        NSString *alertTitle = @"Accept Call?";
        NSString *alertMessage = [NSString stringWithFormat:@"%@ has requested %@. Allow?", expertName, channelName];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                                 message:alertMessage
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizeYes, @"YES")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              
                                                              ECSCafeXController *cafeXController = [[ECSInjector defaultInjector] objectForClass:[ECSCafeXController class]];
                                                              
                                                              // Do a login if there's no session:
                                                              if (![cafeXController hasCafeXSession])
                                                              {
                                                                  [cafeXController setupCafeXSessionWithTask:^{
                                                                      [cafeXController dial:targetID
                                                                                  withVideo:[channelType isEqualToString:@"video_escalate"]
                                                                                   andAudio:YES
                                                                  usingParentViewController:self];
                                                                  }];
                                                              }
                                                              else
                                                              {
                                                                  [cafeXController dial:targetID
                                                                              withVideo:[channelType isEqualToString:@"video_escalate"]
                                                                               andAudio:YES
                                                              usingParentViewController:self];
                                                              }
                                                          }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizeNo, @"NO")
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
                                                              // No
                                                              ECSLogVerbose(self.logger,@"User rejected %@ request.", channelType);
                                                              [self sendSystemText:[NSString stringWithFormat:@"User rejected request for %@.", channelName]];
                                                          }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (NSArray *)indexPathsToUpdate
{
    NSInteger numberOfIndexPathsToBeInserted = (self.messages.count - [self.tableView numberOfRowsInSection:0]);
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:numberOfIndexPathsToBeInserted];
    
    for (NSInteger i = 1; i <= numberOfIndexPathsToBeInserted; i++)
    {
        NSInteger row = (self.messages.count - i);
        [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
    }
    
    return [NSArray arrayWithArray:indexPaths];
}

- (NSIndexPath*)indexPathForLastRow
{
    return [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] - 1 inSection:0];
}

// Show an alert popup to the user with the generic "an error has occurred" style message.
//- (void)showAlertForError:(NSError *)theError fromFunction:(NSString *)theFunction {
- (void)showAlertForErrorTitle:(NSString *)theTitle message:(NSString *)theMessage {
    
    ECSLogError(self.logger,@"%@ - %@", theTitle, theMessage);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:theTitle
                                                                             message:theMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizedOkButton, @"OK")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          // Make alert go away.
                                                          if(self.waitView)
                                                          {
                                                              [self endChatByUser];
                                                          }
                                                      }]];
    
    [self presentViewController:alertController animated:NO completion:nil];
}

- (void) loadHistoryForJourney:(NSString *)journeyID
{
    ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    __weak typeof(self) weakSelf = self;
    
    [urlSession getChatHistoryDetailsForJourneyId:journeyID
                                   withCompletion:^(ECSChatHistoryResponse *response, NSError *error)
     {
         weakSelf.messages = [[NSMutableArray alloc] initWithArray:[response chatMessages]];
         for (ECSChatMessage *message in weakSelf.messages)
         {
             if ([message isKindOfClass:[ECSChatAddParticipantMessage class]])
             {
                 // Add this participant to the array. Key is UserID.
                 [weakSelf.participants setObject:message
                                           forKey:((ECSChatAddParticipantMessage*)message).userId];
             }
         }
         [weakSelf.tableView reloadData];
         [weakSelf hideWaitView];
     }];
}

- (void)sendFormNotification {
    
    ECSLogVerbose(self.logger, @"Form complete notification");
//    ECSChatNotificationMessage *notification = [ECSChatNotificationMessage new];
//    notification.from = self.chatClient.fromUsername;
//    notification.channelId = self.chatClient.currentChannelId;
//    notification.conversationId = self.chatClient.currentConversation.conversationID;
//    notification.type = @"interview";
//    notification.objectData = nil;
    
    ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    [urlSession sendChatNotificationFrom:self.chatClient.fromUsername
                                    type:@"interview"
                              objectData:@""
                          conversationId:self.chatClient.currentConversation.conversationID
                                 channel:self.chatClient.currentChannelId
                              completion:^(NSString *response, NSError *error)
     {
         if(error)
         {
             NSLog(@"Error sending chat notification message: %@", error);
//             [self showReconnectInChat];
//             [self showAlertForError:error fromFunction:@"sendFormNotification"];
         }
     }];
    
    //    [self.chatClient sendNotificationMessage:notification];
}

- (void)sendCoBrowseMessage:(NSString *)meetID
{
    // meetID is an 8-digit number, which will get flagged as a SSN on the
    // backend. So, we must obfuscate it:
    meetID = [meetID stringByAppendingString:@"0000"];
    
    ECSLogVerbose(self.logger,@"Co Browse Meet Started notification");
    ECSChatCoBrowseMessage *notification = [ECSChatCoBrowseMessage new];
    notification.from = self.chatClient.fromUsername;
    notification.channelId = self.chatClient.currentChannelId;
    notification.conversationId = self.chatClient.currentConversation.conversationID;
    notification.start = @"true";
    notification.guid = meetID;
    [self.chatClient sendCoBrowseMessage:notification];
}

- (void)sendVoiceAuthConfirmation:(NSString *)response
{
    [self sendSystemText:response];
}

- (BOOL)formItemHasResponse:(ECSFormActionType*)formActionType
{
    BOOL hasResponse = NO;
    
    if (formActionType.form.formData.count > 0)
    {
        ECSFormItem *item = formActionType.form.formData.firstObject;
        if (item.formValue.length > 0)
        {
            hasResponse = YES;
        }
    }
    
    return hasResponse;
}

- (void)presentInlineForm:(ECSFormActionType*)formActionType
{
    if (formActionType.form.formData.count > 0 && !self.inlineFormController)
    {
        [self.chatToolbar.textView endEditing:YES];
        self.inlineFormController = [ECSInlineFormViewController ecs_loadFromNib];
        self.inlineFormController.delegate = self;
        self.inlineFormController.form = formActionType.form;
        
        [self.inlineFormController willMoveToParentViewController:self];
        self.inlineFormController.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addChildViewController:self.inlineFormController];
        [self.view addSubview:self.inlineFormController.view];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:@{@"view": self.inlineFormController.view}]];
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.inlineFormController.view
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                  toItem:self.view
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0f
                                                                constant:0.0f];
        top.priority = UILayoutPriorityRequired;
        
        NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.inlineFormController.view
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0f
                                                                   constant:self.inlineFormController.preferredHeight];
        
        self.inlineFormBottomConstraint = [NSLayoutConstraint constraintWithItem:self.inlineFormController.view
                                                                       attribute:NSLayoutAttributeBottom
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1.0f
                                                                        constant:self.inlineFormController.preferredHeight];
        [self.view addConstraints:@[top, self.inlineFormBottomConstraint]];
        [self.inlineFormController.view addConstraint:height];
        
        [self.inlineFormController didMoveToParentViewController:self];
        [self.view layoutIfNeeded];
        
        [UIView animateWithDuration:0.3f animations:^{
            self.inlineFormBottomConstraint.constant = 0.0f;
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)formCompleteWithItem:(ECSForm *)formItem
{
    [self.inlineFormController willMoveToParentViewController:nil];
    
    [self sendFormNotification];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.inlineFormBottomConstraint.constant = CGRectGetHeight(self.inlineFormController.view.frame);
        
    } completion:^(BOOL finished) {
        
        [self.inlineFormController.view removeFromSuperview];
        [self.inlineFormController removeFromParentViewController];
        
        // MAS - may-18-2017 - don't submit the form if user was not finished with it. Close button at end of survey does not hit this function. PAAS-1929
//        ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
//        [urlSession submitForm:self.inlineFormController.form completion:nil];
        
        [self.tableView reloadRowsAtIndexPaths:@[self.currentFormCellIndexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        self.currentFormCellIndexPath = nil;
        self.inlineFormController = nil;
    }];
    
}

- (ECSChatAddParticipantMessage*)participantInfoForID:(NSString*)userID
{
    if (userID && userID.length > 0)
    {
        return [self.participants objectForKey:userID];
    }
    
    return nil;
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    [sizingCell layoutSubviews];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height; // Add 1.0f for the cell separator height
}

- (void)updateEdgeInsets
{
    UIEdgeInsets insets = self.tableView.contentInset;
    
    CGFloat bottomOffset = 0;
    if (self.keyboardFrame.size.height) {
        CGRect viewFrameInWindow = [self.view.window convertRect:self.view.frame fromView:self.view.superview];
        bottomOffset = viewFrameInWindow.origin.y + viewFrameInWindow.size.height - self.keyboardFrame.origin.y;
    }
    
    insets.bottom = bottomOffset;
    
    //    self.tableView.contentInset = insets;
    //    self.tableView.scrollIndicatorInsets = insets;
    
    self.chatToolbarBottomConstraint.constant = bottomOffset;
}

- (BOOL)showAvatarAtIndexPath:(NSIndexPath*)indexPath
{
    BOOL showAvatar = YES;
    
    ECSChatMessage *message = (ECSChatMessage*)self.messages[indexPath.row];
    //showAvatar = message.fromAgent;
     if (showAvatar)
     {
          if (indexPath.row > 1 || (indexPath.row > 0 && message.fromAgent))
          {
               ECSChatMessage *previousMessage = (ECSChatMessage*)self.messages[indexPath.row - 1];
               
               if (previousMessage.fromAgent == message.fromAgent && ![previousMessage isKindOfClass:[ECSChatInfoMessage class]] && ![previousMessage isKindOfClass:[ECSChatAddParticipantMessage class]])
               {
                    showAvatar = NO;
               }
               
               //Avatar does match when conference.
               NSString *currentMessageClassNameString = NSStringFromClass([self.messages[indexPath.row] class]);
               NSString *previousMessageClassNameString = NSStringFromClass([self.messages[indexPath.row - 1] class]);
               Class currentMessageClassName = NSClassFromString(currentMessageClassNameString);
               Class previousMessageClassName = NSClassFromString(previousMessageClassNameString);
               id currrentChatMessage = [currentMessageClassName new];
               currrentChatMessage = self.messages[indexPath.row];
               id previousChatMessage = [previousMessageClassName new];
               previousChatMessage = self.messages[indexPath.row -1];
               if(previousMessage.fromAgent)
               {
                    if (![[currrentChatMessage from] isEqualToString:[previousChatMessage from]]) {
                         showAvatar = YES;
                    }
               }
          }
     }
    return showAvatar;
}

- (void)showAddChannelModalForMessage:(ECSChatAddChannelMessage*)message
{
    _callbackViewController = [ECSCallbackViewController ecs_loadFromNib];
    ECSCallbackActionType *callbackAction = [ECSCallbackActionType new];
//    [_callbackViewController setChatClient:_chatClient];
    
    // Set the parent agent skill and id for callback.
    ECSChatActionType *chatAction = (ECSChatActionType*)self.actionType;
    callbackAction.agentSkill = chatAction.agentSkill;
    callbackAction.agentId = chatAction.agentId;
    callbackAction.actionId = @""; // NK 6/24 - This seemed to be missing, and was throwing an exception later when nil
    
    _callbackViewController.actionType = callbackAction;
    //_callbackViewController.skipConfirmationView = YES;
    
    if (![message.mediaType isEqualToString:@"voice"])
    {
        _callbackViewController.displaySMSOption = YES;
    }
    
    [self presentModal:_callbackViewController withParentNavigationController:self.navigationController];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 20.0f)];
    footer.backgroundColor = [UIColor clearColor];
    
    return footer;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    id message = self.messages[indexPath.row];
    
    if ([message isKindOfClass:[ECSChatTextMessage class]])
    {
        ECSChatTableViewCell *textCell = [self.tableView dequeueReusableCellWithIdentifier:MessageCellID
                                                                              forIndexPath:indexPath];
        
        [self configureMessageCell:textCell withMessage:(ECSChatTextMessage*)message atIndexPath:(NSIndexPath*)indexPath];
        cell = textCell;
    }
    if ([message isKindOfClass:[ECSReceiveAnswerMessage class]])
    {
        ECSChatTableViewCell *textCell = [self.tableView dequeueReusableCellWithIdentifier:HtmlMessageCellID
                                                                              forIndexPath:indexPath];
        
        [self configureMessageCell:textCell withReceiveAnswerMessage:(ECSReceiveAnswerMessage*)message atIndexPath:(NSIndexPath*)indexPath];
        cell = textCell;
    }
    else if ([message isKindOfClass:[ECSChatAssociateInfoMessage class]])
    {
        ECSChatTableViewCell *textCell = [self.tableView dequeueReusableCellWithIdentifier:MessageCellID
                                                                              forIndexPath:indexPath];
        
        [self configureAssociateInfoCell:textCell withMessage:(ECSChatAssociateInfoMessage*)message atIndexPath:(NSIndexPath*)indexPath];
        cell = textCell;
    }
    else if ([message isKindOfClass:[ECSChatStateMessage class]])
    {
        ECSChatTypingTableViewCell *typingCell = [self.tableView dequeueReusableCellWithIdentifier:MessageTypingCellID
                                                                                      forIndexPath:indexPath];
        
        typingCell.background.showAvatar = [self showAvatarAtIndexPath:indexPath];
        if (typingCell.background.showAvatar)
        {
            ECSChatAddParticipantMessage *participant = [self participantInfoForID:((ECSChatStateMessage*)message).from];
            if(participant)
            {
                [typingCell.background.avatarImageView setImageWithPath:participant.avatarURL];
            }
        }
        
        cell = typingCell;
    }
    else if ([message isKindOfClass:[ECSChatURLMessage class]])
    {
        ECSChatActionTableViewCell *actionCell = [self.tableView dequeueReusableCellWithIdentifier:ActionCellID
                                                                                      forIndexPath:indexPath];
        [self configureActionCell:actionCell withMessage:message atIndexPath:indexPath];
        cell = actionCell;
    }
    else if ([message isKindOfClass:[ECSChatFormMessage class]])
    {
        if (![[((ECSChatFormMessage*)message) formContents] isInline])
        {
            ECSChatActionTableViewCell *actionCell = [self.tableView dequeueReusableCellWithIdentifier:ActionCellID
                                                                                          forIndexPath:indexPath];
            [self configureActionCell:actionCell withMessage:message atIndexPath:indexPath];
            cell = actionCell;
        }
        else
        {
            ECSInlineFormTableViewCell *actionCell = [self.tableView dequeueReusableCellWithIdentifier:InlineFormCellID
                                                                                          forIndexPath:indexPath];
            [self configureInlineFormCell:actionCell withMessage:message atIndexPath:indexPath];
            cell = actionCell;
            
        }
    }
    
    else if ([message isKindOfClass:[ECSChatAddParticipantMessage class]])
    {
        ECSChatTextTableViewCell *textCell = [self.tableView dequeueReusableCellWithIdentifier:TextCellID
                                                                                  forIndexPath:indexPath];
        [self configureChatTextCell:textCell withAddParticipantMessage:message];
        cell = textCell;
    }
    else if ([message isKindOfClass:[ECSChatRemoveParticipantMessage class]])
    {
        ECSChatTextTableViewCell *textCell = [self.tableView dequeueReusableCellWithIdentifier:TextCellID
                                                                                  forIndexPath:indexPath];
        [self configureChatTextCell:textCell withRemoveParticipantMessage:message];
        cell = textCell;
    }
    else if ([message isKindOfClass:[ECSChatInfoMessage class]])
    {
        ECSChatTextTableViewCell *textCell = [self.tableView dequeueReusableCellWithIdentifier:TextCellID
                                                                                  forIndexPath:indexPath];
        [self configureChatTextCell:textCell withInfoMessage:message];
        cell = textCell;
    }
    else if ([message isKindOfClass:[ECSChatNetworkMessage class]])
    {
        ECSChatNetworkActionCell *networkCell = [self.tableView dequeueReusableCellWithIdentifier:ChatNetworkCellID
                                                                                     forIndexPath:indexPath];
        [self configureNetworkActionCell:networkCell withMessage:message];
        cell = networkCell;
    }
    else if ([message isKindOfClass:[ECSChatIdleMessage class]])
    {
        ECSChatNetworkActionCell *networkCell = [self.tableView dequeueReusableCellWithIdentifier:ChatNetworkCellID
                                                                                     forIndexPath:indexPath];
        [self configureIdleActionCell:networkCell withMessage:message];
        cell = networkCell;
    }
    else if ([message isKindOfClass:[ECSChatMediaMessage class]])
    {
        ECSChatImageTableViewCell *imageCell = [self.tableView dequeueReusableCellWithIdentifier:ImageCellID
                                                                                    forIndexPath:indexPath];
        [self configureMediaCell:imageCell withMessage:message atIndexPath:(NSIndexPath *)indexPath];
        cell = imageCell;
    }
    else if ([message isKindOfClass:[ECSChatNotificationMessage class]])
    {
        ECSChatImageTableViewCell *imageCell = [self.tableView dequeueReusableCellWithIdentifier:ImageCellID
                                                                                    forIndexPath:indexPath];
        [self configureMediaCell:imageCell withNotificationMessage:message atIndexPath:(NSIndexPath*)indexPath];
        cell = imageCell;
        
    }
    else if ([message isKindOfClass:[ECSChatAddChannelMessage class]])
    {
        ECSChatActionTableViewCell *actionCell = [self.tableView dequeueReusableCellWithIdentifier:ActionCellID
                                                                                      forIndexPath:indexPath];
         
        [self configureCallbackCell:actionCell withMessage:message atIndexPath:(NSIndexPath*)indexPath];

        cell = actionCell;
    }
    
     [cell layoutIfNeeded];
     [cell layoutSubviews];
     
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id message = self.messages[indexPath.row];
    
    if ([message isKindOfClass:[ECSChatURLMessage class]])
    {
        if([[(ECSChatURLMessage*)message urlType] isEqualToString:@"PDF Document"])
        {
            ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
            NSURLRequest *request = [sessionManager urlRequestForMediaWithName:[(ECSChatURLMessage*)message url]];
            ECSWebViewController *webController = [ECSWebViewController ecs_loadFromNib];
            [webController loadRequest:request];
            [self.navigationController pushViewController:webController animated:YES];
        }
        else
        {
            ECSWebViewController *webController = [ECSWebViewController ecs_loadFromNib];
            [webController loadItemAtPath:[(ECSChatURLMessage*)message url]];
            [self.navigationController pushViewController:webController animated:YES];
        }
    }
    else if ([message isKindOfClass:[ECSChatMediaMessage class]])
    {
        ECSPhotoViewController *photoController = [ECSPhotoViewController ecs_loadFromNib];
        if ([(ECSChatMediaMessage*)message imageThumbnail])
        {
            photoController.image = [(ECSChatMediaMessage*)message imageThumbnail];
        }
        else if ([(ECSChatMediaMessage*)message url])
        {
            photoController.imagePath = [(ECSChatMediaMessage*)message url];
        }
        
        if ([(ECSChatMediaMessage*)message mediaType] == ECSChatMediaTypeMovie)
        {
            photoController.mediaPath = [(ECSChatMediaMessage*)message url];
        }
        
        [self.navigationController pushViewController:photoController animated:YES];
    }
    else if ([message isKindOfClass:[ECSChatNotificationMessage class]])
    {
        ECSChatNotificationMessage *notificationMessage = (ECSChatNotificationMessage*)message;
        
        if ([notificationMessage.type isEqualToString:@"artifact"])
        {
            ECSURLSessionManager *session = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
            NSURLRequest *request = [session urlRequestForMediaWithName:notificationMessage.objectData];
            ECSPhotoViewController *photoController = [ECSPhotoViewController ecs_loadFromNib];
            photoController.imageURLRequest = request;
            [self.navigationController pushViewController:photoController animated:YES];
        }
    }
    else if ([message isKindOfClass:[ECSChatFormMessage class]])
    {
        ECSFormActionType *formActionType = [message formActionType];
        
        if (formActionType.form.isInline)
        {
            // Only show response if the user has not responsed.
            if (![self formItemHasResponse:formActionType])
            {
                self.currentFormCellIndexPath = indexPath;
                [self presentInlineForm:formActionType];
            }
        }
        else if (!formActionType.form.submitted)
        {
            ECSFormViewController *formController = [ECSFormViewController ecs_loadFromNib];
            
            formController.actionType = [message formActionType];
            formController.delegate = self;
            
            self.presentedForm = YES;
            [self presentModal:formController withParentNavigationController:self.navigationController];
        }
    }
    else if ([message isKindOfClass:[ECSChatAddChannelMessage class]])
    {
        [self showAddChannelModalForMessage:message];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECSChatMessage *chatMessage = self.messages[indexPath.row];
    
    static ECSChatMessageTableViewCell *messageSizingCell = nil;
    static ECSHtmlMessageTableViewCell *htmlSizingCell = nil;
    static ECSChatImageTableViewCell *imageSizingCell = nil;
    static ECSChatTypingTableViewCell *typingCell = nil;
    static ECSChatActionTableViewCell *actionCell = nil;
    static ECSChatTextTableViewCell *textCell = nil;
    static ECSChatNetworkActionCell *networkActionCell = nil;
    static ECSInlineFormTableViewCell *inlineFormCell = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        messageSizingCell = [self.tableView dequeueReusableCellWithIdentifier:MessageCellID];
        htmlSizingCell = [self.tableView dequeueReusableCellWithIdentifier:HtmlMessageCellID];
        imageSizingCell = [self.tableView dequeueReusableCellWithIdentifier:ImageCellID];
        typingCell = [self.tableView dequeueReusableCellWithIdentifier:MessageTypingCellID];
        actionCell = [self.tableView dequeueReusableCellWithIdentifier:ActionCellID];
        textCell = [self.tableView dequeueReusableCellWithIdentifier:TextCellID];
        networkActionCell = [self.tableView dequeueReusableCellWithIdentifier:ChatNetworkCellID];
        inlineFormCell = [self.tableView dequeueReusableCellWithIdentifier:InlineFormCellID];
    });
    
    CGFloat height = 0.0f;
    
    if ([chatMessage isKindOfClass:[ECSChatTextMessage class]])
    {
        messageSizingCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44.0f);
        messageSizingCell.messageLabel.preferredMaxLayoutWidth = messageSizingCell.contentView.frame.size.width;
        [self configureMessageCell:messageSizingCell
                       withMessage:(ECSChatTextMessage*)chatMessage
                       atIndexPath:indexPath];
        height = [self calculateHeightForConfiguredSizingCell:messageSizingCell];
    }
    else if ([chatMessage isKindOfClass:[ECSReceiveAnswerMessage class]])
    {
        [self configureMessageCell:htmlSizingCell
          withReceiveAnswerMessage:(ECSReceiveAnswerMessage*)chatMessage
                       atIndexPath:indexPath];
        height = [self calculateHeightForConfiguredSizingCell:htmlSizingCell];
        
        // htmlSizingCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), height);
    }
    else if ([chatMessage isKindOfClass:[ECSChatAssociateInfoMessage class]])
    {
        messageSizingCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44.0f);
        messageSizingCell.messageLabel.preferredMaxLayoutWidth = messageSizingCell.contentView.frame.size.width;
        [self configureAssociateInfoCell:messageSizingCell
                             withMessage:(ECSChatAssociateInfoMessage*)chatMessage
                             atIndexPath:indexPath];
        
        height = [self calculateHeightForConfiguredSizingCell:messageSizingCell];
    }
    else if ([chatMessage isKindOfClass:[ECSChatStateMessage class]])
    {
        typingCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44.0f);
        typingCell.background.showAvatar = [self showAvatarAtIndexPath:indexPath];
        height = [self calculateHeightForConfiguredSizingCell:typingCell];
    }
    else if ([chatMessage isKindOfClass:[ECSChatURLMessage class]])
    {
        actionCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44.0f);
        
        actionCell.messageLabel.preferredMaxLayoutWidth = messageSizingCell.contentView.frame.size.width;
        [self configureActionCell:actionCell
                      withMessage:chatMessage
                      atIndexPath:indexPath];
        height = [self calculateHeightForConfiguredSizingCell:actionCell];
    }
    else if ([chatMessage isKindOfClass:[ECSChatFormMessage class]])
    {
        if (![[((ECSChatFormMessage*)chatMessage) formContents] isInline])
        {
            actionCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44.0f);
            
            actionCell.messageLabel.preferredMaxLayoutWidth = messageSizingCell.contentView.frame.size.width;
            [self configureActionCell:actionCell
                          withMessage:chatMessage
                          atIndexPath:indexPath];
            height = [self calculateHeightForConfiguredSizingCell:actionCell];
        }
        else
        {
            inlineFormCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44.0f);
            
            inlineFormCell.messageLabel.preferredMaxLayoutWidth = messageSizingCell.contentView.frame.size.width;
            inlineFormCell.responseLabel.preferredMaxLayoutWidth = messageSizingCell.contentView.frame.size.width;
            [self configureInlineFormCell:inlineFormCell
                              withMessage:chatMessage
                              atIndexPath:indexPath];
            
            height = [self calculateHeightForConfiguredSizingCell:inlineFormCell];
        }
    }
    else if ([chatMessage isKindOfClass:[ECSChatAddParticipantMessage class]])
    {
        textCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44.0f);
        [self configureChatTextCell:textCell withAddParticipantMessage:(ECSChatAddParticipantMessage*)chatMessage];
        height = [self calculateHeightForConfiguredSizingCell:textCell];
    }
    else if ([chatMessage isKindOfClass:[ECSChatRemoveParticipantMessage class]])
    {
        textCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44.0f);
        [self configureChatTextCell:textCell withRemoveParticipantMessage:(ECSChatRemoveParticipantMessage*)chatMessage];
        height = [self calculateHeightForConfiguredSizingCell:textCell];
    }
    else if ([chatMessage isKindOfClass:[ECSChatInfoMessage class]])
    {
        textCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44.0f);
        [self configureChatTextCell:textCell withInfoMessage:(ECSChatInfoMessage*)chatMessage];
        height = [self calculateHeightForConfiguredSizingCell:textCell];
    }
    
    else if ([chatMessage isKindOfClass:[ECSChatNetworkMessage class]] ||
             [chatMessage isKindOfClass:[ECSChatIdleMessage class]])
    {
        networkActionCell.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 44.0f);
        [self configureNetworkActionCell:networkActionCell withMessage:(ECSChatNetworkMessage*)chatMessage];
        height = [self calculateHeightForConfiguredSizingCell:networkActionCell];
    }
    else if ([chatMessage isKindOfClass:[ECSChatMediaMessage class]] ||
             [chatMessage isKindOfClass:[ECSChatNotificationMessage class]])
    {
        if ([chatMessage isKindOfClass:[ECSChatNotificationMessage class]] &&
            ![((ECSChatNotificationMessage*)chatMessage).type isEqualToString:@"artifact"])
        {
            height = 0.0f;
            
        }
        else
        {
             //              UIImage *thumbnail = nil;
             //
             //              if ([chatMessage isKindOfClass:[ECSChatMediaMessage class]])
             //              {
             //                   thumbnail = ((ECSChatMediaMessage*)chatMessage).imageThumbnail;
             //              }
             
             //
             //              CGFloat maxWidth = (CGRectGetWidth(self.tableView.frame) * 0.5f);
             //              if (thumbnail)
             //              {
             //                   height = (thumbnail.size.height / thumbnail.size.width) * maxWidth;
             //              }
             //              else
             //              {
             height = 160.0f;
             //              }
        }
    }
    else if ([chatMessage isKindOfClass:[ECSChatAddChannelMessage class]])
    {
        [self configureCallbackCell:actionCell withMessage:(ECSChatAddChannelMessage*)chatMessage atIndexPath:indexPath];
        height = [self calculateHeightForConfiguredSizingCell:actionCell];
    }
    
    return height;
}

#pragma mark Table View Message Cells

- (void)configureMessageCell:(ECSChatTableViewCell*)cell
                 withMessage:(ECSChatTextMessage *)chatMessage
                 atIndexPath:(NSIndexPath*)indexPath
{
    ECSChatMessageTableViewCell *messageCell = (ECSChatMessageTableViewCell*)cell;
    
    messageCell.userMessage = !chatMessage.fromAgent;

    [self configureCellAvatarImage:cell from:chatMessage.from fromAgent:chatMessage.fromAgent atIndexPath:indexPath];
    
    
    // the next line throws an exception if string is nil - make sure you check
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeAddress | NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber error:NULL];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:chatMessage.body attributes:nil];
    // the next line throws an exception if string is nil - make sure you check
    [detector enumerateMatchesInString:chatMessage.body options:0 range:NSMakeRange(0, chatMessage.body.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        attributes[ZSWTappableLabelTappableRegionAttributeName] = @YES;
        attributes[ZSWTappableLabelHighlightedBackgroundAttributeName] = [UIColor lightGrayColor];
        attributes[ZSWTappableLabelHighlightedForegroundAttributeName] = [UIColor whiteColor];
        attributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
        attributes[@"NSTextCheckingResult"] = result;
        [attributedString addAttributes:attributes range:result.range];
    }];
    messageCell.messageLabel.attributedText = attributedString;
    messageCell.messageLabel.tapDelegate = self;
    
    //messageCell.messageLabel.text = chatMessage.body;
    
    [messageCell.background.timestampLabel setText:chatMessage.timeStamp];
}

// This occurs if the user clicks a link within the message bubble.
// Details here: https://github.com/zacwest/ZSWTappableLabel

- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel
        tappedAtIndex:(NSInteger)idx
       withAttributes:(NSDictionary<NSString *,id> *)attributes {
    
    NSURL *URL;
    
    NSTextCheckingResult *result = attributes[@"NSTextCheckingResult"];
    
    if ([result isKindOfClass:[NSTextCheckingResult class]]) {
        
        switch (result.resultType) {
            case NSTextCheckingTypeAddress: {
                NSLog(@"Address components: %@", result.addressComponents);
                
                NSMutableString *resultString = [NSMutableString string];
                for (NSString* value in [result.addressComponents allValues]){
                    if ([resultString length]>0) {
                        [resultString appendString:@","];
                    }
                    [resultString appendFormat:@"%@", value];
                }
                
                NSString *encodedString = [resultString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 
                
                URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/?q=%@", encodedString]];
                break;
                
            } case NSTextCheckingTypePhoneNumber: {
                NSURLComponents *components = [[NSURLComponents alloc] init];
                components.scheme = @"tel";
                components.host = result.phoneNumber;
                URL = components.URL;
                break;
            }
                
            case NSTextCheckingTypeDate:
                NSLog(@"Date: %@", result.date);
                break;
                
            case NSTextCheckingTypeLink:
                URL = result.URL;
                break;
                
            default:
                break;
        }
    }
    
    ECSLogVerbose(self.logger, @"Data detector found tappable item. Opening URL: %@", URL.absoluteString);
    
    if ([URL isKindOfClass:[NSURL class]]) {
        [[UIApplication sharedApplication] openURL:URL];
    }
}

- (void)configureCellAvatarImage:(ECSChatTableViewCell*)cell
                            from:(NSString *)theFrom
                       fromAgent:(BOOL)theFromAgent
                     atIndexPath:(NSIndexPath*)indexPath
{
    cell.background.showAvatar = [self showAvatarAtIndexPath:indexPath];
    if (cell.background.showAvatar)
    {
         if (!theFromAgent)
         {
              ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
              if(userManager.userAvatar)
              {
                   [cell.background.avatarImageView setImage:userManager.userAvatar];
              }
              else
              {
                   ECSImageCache *imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];
                   [cell.background.avatarImageView setImage:[imageCache imageForPath:@"ecs_img_avatar"]];
              }
            //ECSLogVerbose(self.logger,@"Setting (user) avatar image for participant %@.", theFrom);
        } else {
            ECSChatAddParticipantMessage *participant = [self participantInfoForID:theFrom];
            [cell.background.avatarImageView setImageWithPath:participant.avatarURL];
            //ECSLogVerbose(self.logger,@"Setting (agent) avatar image for participant %@.", theFrom);
        }
    }
}

- (void)configureMessageCell:(ECSChatTableViewCell*)cell
    withReceiveAnswerMessage:(ECSReceiveAnswerMessage *)receiveAnswerMessage
                 atIndexPath:(NSIndexPath*)indexPath
{
    ECSHtmlMessageTableViewCell *messageCell = (ECSHtmlMessageTableViewCell*)cell;
    
    messageCell.userMessage = !receiveAnswerMessage.fromAgent;
    messageCell.background.showAvatar = [self showAvatarAtIndexPath:indexPath];
    
    if (messageCell.background.showAvatar)
    {
        ECSChatAddParticipantMessage *participant = [self participantInfoForID:receiveAnswerMessage.from];
        [messageCell.background.avatarImageView setImageWithPath:participant.avatarURL];
    }
    
    [messageCell.webContent loadHTMLString:receiveAnswerMessage.answerText baseURL:nil];
    [messageCell.background.timestampLabel setText:[[EXPERTconnect shared] getTimeStampMessage]];
}

- (void)configureAssociateInfoCell:(ECSChatTableViewCell*)cell
                       withMessage:(ECSChatAssociateInfoMessage *)chatMessage
                       atIndexPath:(NSIndexPath*)indexPath
{
    ECSChatMessageTableViewCell *messageCell = (ECSChatMessageTableViewCell*)cell;
    
    messageCell.userMessage = !chatMessage.fromAgent;
    messageCell.background.showAvatar = [self showAvatarAtIndexPath:indexPath];
    
    if (messageCell.background.showAvatar)
    {
        ECSChatAddParticipantMessage *participant = [self participantInfoForID:chatMessage.from];
        [messageCell.background.avatarImageView setImageWithPath:participant.avatarURL];
    }
    messageCell.messageLabel.text = chatMessage.message;
    [messageCell.background.timestampLabel setText:[[EXPERTconnect shared] getTimeStampMessage]];
}

- (void)configureActionCell:(ECSChatActionTableViewCell*)cell
                withMessage:(ECSChatMessage *)message
                atIndexPath:(NSIndexPath*)indexPath
{
    cell.userMessage = NO;
    cell.background.showAvatar = [self showAvatarAtIndexPath:indexPath];
    
    ECSChatAddParticipantMessage *participant = nil;
    if ([message isKindOfClass:[ECSChatURLMessage class]])
    {
        // A URL message
        cell.actionCellType = ECSChatActionCellTypeLink;
        ECSChatURLMessage *urlMesssage = (ECSChatURLMessage*)message;
        cell.messageLabel.text = (urlMesssage.comment && urlMesssage.comment.length > 0) ? urlMesssage.comment : urlMesssage.url;
        participant = [self participantInfoForID:urlMesssage.from];
        
    }
    else if ([message isKindOfClass:[ECSChatFormMessage class]])
    {
        cell.actionCellType = ECSChatActionCellTypeForm;
        
        ECSChatFormMessage *formMessage = (ECSChatFormMessage *)message;
        
        BOOL submitted = formMessage.formContents.submitted;
        
        NSString *title = formMessage.formContents.name;
        
        if (submitted)
        {
            cell.messageLabel.text = @"Form Submitted";
        }
        else
        {
            if (![title isKindOfClass:[NSString class]] || title.length == 0)
            {
                title = ECSLocalizedString(ECSLocalizeTapToRespond, nil);
            }
            cell.messageLabel.text = title;
            participant = [self participantInfoForID:formMessage.from];
        }
    }
    
    if (cell.background.showAvatar && participant)
    {
        [cell.background.avatarImageView setImageWithPath:participant.avatarURL];
    }
    [cell.background.timestampLabel setText:[[EXPERTconnect shared] getTimeStampMessage]];
}

- (void)configureInlineFormCell:(ECSInlineFormTableViewCell*)cell
                    withMessage:(ECSChatMessage *)message
                    atIndexPath:(NSIndexPath*)indexPath
{
    cell.userMessage = NO;
    cell.background.showAvatar = [self showAvatarAtIndexPath:indexPath];
    
    ECSChatAddParticipantMessage *participant = nil;
    
    if ([message isKindOfClass:[ECSChatFormMessage class]])
    {
        ECSFormItem *formItem = ((ECSChatFormMessage*)message).formContents.formData.firstObject;
        
        cell.messageLabel.text = formItem.label;
        
        if (formItem.formValue.length > 0)
        {
            cell.responseLabel.text = ((ECSChatFormMessage*)message).formContents.inlineFormResponse;
        }
        else
        {
            cell.responseLabel.text = ECSLocalizedString(ECSLocalizeTapToRespond, nil);
        }
        participant = [self participantInfoForID:((ECSChatFormMessage*)message).from];
    }
    
    if (cell.background.showAvatar && participant)
    {
        [cell.background.avatarImageView setImageWithPath:participant.avatarURL];
    }
    
    [cell.background.timestampLabel setText:[[EXPERTconnect shared] getTimeStampMessage]];
}


- (void)configureMediaCell:(ECSChatImageTableViewCell*)cell
               withMessage:(ECSChatMediaMessage*)chatMessage
               atIndexPath:(NSIndexPath*)indexPath;
{
    cell.userMessage = !chatMessage.fromAgent;
    [cell.messageImageView setImage:chatMessage.imageThumbnail];
    cell.showPlayIcon = (chatMessage.mediaType == ECSChatMediaTypeMovie);
    [cell.background.timestampLabel setText:[[EXPERTconnect shared] getTimeStampMessage]];
    
    [self configureCellAvatarImage:cell from:chatMessage.from fromAgent:chatMessage.fromAgent atIndexPath:indexPath];
    
    [cell.background.timestampLabel setText:[[EXPERTconnect shared] getTimeStampMessage]];
}

- (void)configureMediaCell:(ECSChatImageTableViewCell*)cell
   withNotificationMessage:(ECSChatNotificationMessage*)chatMessage
               atIndexPath:(NSIndexPath*)indexPath
{
    if ([chatMessage.type isEqualToString:@"artifact"])
    {
        cell.userMessage = !chatMessage.fromAgent;
        NSString *fileName = chatMessage.objectData;
        
        ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
        NSURLRequest *request = [sessionManager urlRequestForMediaWithName:fileName];
         cell.messageImageView.image = [UIImage ecs_bundledImageNamed:@"expertconnect_chat_loading"];
        [cell.messageImageView setImageWithRequest:request];
        
        cell.showPlayIcon = NO;
    }
    
    [self configureCellAvatarImage:cell from:chatMessage.from fromAgent:chatMessage.fromAgent atIndexPath:indexPath];
    
    [cell.background.timestampLabel setText:[[EXPERTconnect shared] getTimeStampMessage]];
}

- (void)configureChatTextCell:(ECSChatTextTableViewCell*)cell
    withAddParticipantMessage:(ECSChatAddParticipantMessage*)message {
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    cell.chatTextLabel.font = theme.chatInfoTitleFont;
    cell.chatTextLabel.textColor = theme.primaryTextColor;
    
    // First name if available, otherwise choose userId.
    NSString *displayName = (message.firstName && message.firstName.length > 0 ? message.firstName : message.fullName);
    if(!displayName) displayName = @"";
    
    // By default (backwards compatibility), %1 is replaced with displayname
    NSString *chatJoin = ECSLocalizedString(ECSLocalizeChatJoin, @"Chat Join");
    
    // Replace any of the three tokens with real data: [firstname], [lastname], [userid]
    chatJoin = [chatJoin stringByReplacingOccurrencesOfString:@"[firstname]" withString:message.firstName];
    chatJoin = [chatJoin stringByReplacingOccurrencesOfString:@"[lastname]" withString:message.lastName];
    chatJoin = [chatJoin stringByReplacingOccurrencesOfString:@"[userid]" withString:message.userId];
    
    // Backwards compatibility
    chatJoin = [chatJoin stringByReplacingOccurrencesOfString:@"%1@" withString:displayName];
    
    cell.chatTextLabel.text = chatJoin;
}

- (void)configureChatTextCell:(ECSChatTextTableViewCell*)cell
 withRemoveParticipantMessage:(ECSChatRemoveParticipantMessage*)message {
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    cell.chatTextLabel.font = theme.chatInfoTitleFont;
    cell.chatTextLabel.textColor = theme.primaryTextColor;
    
    // First name if available, otherwise choose userId.
    NSString *displayName = (message.firstName && message.firstName.length > 0 ? message.firstName : message.fullName);
    if(!displayName) displayName = @"";
    
    // By default (backwards compatibility), %1 is replaced with displayname
    NSString *chatLeave = ECSLocalizedString(ECSLocalizeChatLeave, @"Chat Leave");
    
    // Replace any of the three tokens with real data: [firstname], [lastname], [userid]
    chatLeave = [chatLeave stringByReplacingOccurrencesOfString:@"[firstname]" withString:message.firstName];
    chatLeave = [chatLeave stringByReplacingOccurrencesOfString:@"[lastname]" withString:message.lastName];
    chatLeave = [chatLeave stringByReplacingOccurrencesOfString:@"[userid]" withString:message.userId];
    
    // Backwards compatibility
    chatLeave = [chatLeave stringByReplacingOccurrencesOfString:@"%1@" withString:displayName];
    
    cell.chatTextLabel.text = chatLeave;
}

- (void)configureChatTextCell:(ECSChatTextTableViewCell*)cell withText:(NSString *)message {
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    cell.chatTextLabel.font = theme.chatInfoTitleFont;
    cell.chatTextLabel.textColor = theme.primaryTextColor;
    
    cell.chatTextLabel.text = message;
}

- (void)configureChatTextCell:(ECSChatTextTableViewCell*)cell
              withInfoMessage:(ECSChatInfoMessage*)message
{
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    
    if(message.useBiggerFont) {
        cell.chatTextLabel.font = theme.chatInfoTitleFont;
        cell.chatTextLabel.textColor = theme.primaryTextColor;
    } else {
        cell.chatTextLabel.font = theme.captionFont;
        cell.chatTextLabel.textColor = theme.secondaryTextColor;
    }
    
    cell.chatTextLabel.text = message.infoMessage;
}

- (void)configureNetworkActionCell:(ECSChatNetworkActionCell*)cell
                       withMessage:(ECSChatNetworkMessage*)message
{
    cell.messageLabel.text = ECSLocalizedString(ECSLocalizeChatReachabilityErrorKey, @"Temporarily Disconnected");
    cell.submessageLabel.text = ECSLocalizedString(ECSLocalizeChatReachabilityReconnectErrorKey, @"Check Internet Connection");
    [cell.actionButton setTitle:ECSLocalizedString(ECSLocalizeChatReachabilityReconnectButtonKey, @"Try Reconnecting")
                       forState:UIControlStateNormal];
    [cell.actionButton addTarget:self
                          action:@selector(reconnectWebsocket:)
                forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureIdleActionCell:(ECSChatNetworkActionCell*)cell
                    withMessage:(ECSChatNetworkMessage*)message
{
    cell.messageLabel.text = ECSLocalizedString(ECSLocalizeIdleMessageKey, @"Idle Message");
    cell.submessageLabel.text = ECSLocalizedString(ECSLocalizeContinueChattingKey, @"Continue Chatting");
    [cell.actionButton setTitle:ECSLocalizedString(ECSLocalizedStayConnectedKey, @"Stay Connected")
                       forState:UIControlStateNormal];
}

- (void)configureCallbackCell:(ECSChatActionTableViewCell*)cell
                  withMessage:(ECSChatAddChannelMessage*)message
                  atIndexPath:(NSIndexPath*)indexPath
{
    if ([message.mediaType isEqualToString:@"voice"])
    {
        cell.messageLabel.text = ECSLocalizedString(ECSLocalizeRequestAPhoneCall, nil);
        cell.actionCellType = ECSChatActionCellTypeCallback;
    }
    else
    {
        cell.messageLabel.text = ECSLocalizedString(ECSLocalizeRequestASMS, nil);
        cell.actionCellType = ECSChatActionCellTypeTextback;
    }
    [self configureCellAvatarImage:cell from:message.from fromAgent:message.fromAgent atIndexPath:indexPath];
    [cell.background.timestampLabel setText:[[EXPERTconnect shared] getTimeStampMessage]];
}

#pragma mark - UIScrollView


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_userDragging)
    {
        [self.chatToolbar.textView resignFirstResponder];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _userDragging = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _userDragging = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        _userDragging = NO;
    }
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
        
    } completion:^(BOOL finished) {
        if (self.messages.count > 0)
        {
            [self.tableView scrollToRowAtIndexPath:[self indexPathForLastRow]
             
                                  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
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

#pragma mark - Functions Accessible to the ECSChatViewController object

- (BOOL) userInQueue {
    return (self.waitView ? YES : NO);
}

- (ECSStompChatClient *)getChatClient {
    return self.chatClient;
}

#pragma mark ECSFormViewDelegate Functions

- (void) ECSFormViewController:(ECSFormViewController *)formVC
                 submittedForm:(ECSForm *)form
                      withName:(NSString *)name
                         error:(NSError *)error {
    
    [self sendFormNotification];
    
}

@end

/* Deprecated. Moxtra SDK has been removed. Should use CafeX instead.
 if ([message isKindOfClass:[ECSChatCoBrowseMessage class]])
 {
 ECSChatAddParticipantMessage *participant = [self participantInfoForID:((ECSChatStateMessage*)message).from];
 NSString *expertName = [participant firstName];
 if (expertName == nil || expertName.length == 0) {
 expertName = @"The Expert"; // Translate
 }
 // Confirm with User:
 NSString *alertTitle = @"Share Screen?"; // Translate
 NSString *alertMessage = [NSString stringWithFormat:@"%@ has requested to see your screen. Allow?", expertName]; // Translate
 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
 message:alertMessage
 preferredStyle:UIAlertControllerStyleAlert];
 [alertController addAction:[UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizeYes, @"YES")
 style:UIAlertActionStyleDefault
 handler:^(UIAlertAction *action) {
 // Yes
 [[EXPERTconnect shared].externalDelegate meetRequested:^(NSString *meetID) {
 if (meetID != nil) {
 // Delegate should call this callback with a Meet ID
 ECSLogVerbose(@"Start meet successfully with MeetID [%@]", meetID);
 
 // Alert Agent to the MeetID:
 [self sendCoBrowseMessage:meetID];
 
 // Make room for Moxtra panel:
 _showingMoxtra = TRUE;
 [self updateEdgeInsets];
 } else {
 ECSLogVerbose(@"Start meet failed! No Meet ID returned by delegate");
 _showingMoxtra = FALSE;
 [self updateEdgeInsets];
 // Alert agent of failure
 [self sendSystemText:@"Screen Share request failed. No Meet ID created."];
 }
 }];
 }]];
 [alertController addAction:[UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizeNo, @"NO")
 style:UIAlertActionStyleCancel
 handler:^(UIAlertAction *action) {
 // No
 _showingMoxtra = FALSE;
 [self updateEdgeInsets];
 ECSLogVerbose(@"User rejected Screen Share request.");
 [self sendSystemText:@"User rejected Screen Share request."];
 }]];
 [self presentViewController:alertController animated:YES completion:nil];
 
 return; // no UI
 }
 */
