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
#import "ECSChatAddParticipantMessage.h"
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
#import "ECSStompChatClient.h"
#import "ECSWebViewController.h"
#import "ECSQuickRatingForm.h"
#import "ECSQuickRatingViewController.h"
#import "ECSUserManager.h"
#import "ECSURLSessionManager.h"
#import "ECSChatAddChannelMessage.h"
#import "ECSEndChatSurveyView.h"
#import "ECSRootViewController+Navigation.h"
#import "ECSCafeXController.h"

#import "UIView+ECSNibLoading.h"
#import "UIViewController+ECSNibLoading.h"

static NSString *const MessageCellID = @"AgentMessageCellID";
static NSString *const HtmlMessageCellID = @"HtmlMessageCellID";
static NSString *const ImageCellID = @"AgentImageCellID";
static NSString *const MessageTypingCellID = @"MessageTypingCellID";
static NSString *const ActionCellID = @"ActionCellID";
static NSString *const TextCellID = @"TextCellID";
static NSString *const ChatNetworkCellID = @"ChatNetworkCellID";
static NSString *const InlineFormCellID = @"ChatInlineFormCellID";

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

@interface ECSChatViewController () <UITableViewDataSource, UITableViewDelegate, ECSChatToolbarDelegate, ECSStompChatDelegate, ECSInlineFormViewControllerDelegate>
{
    BOOL _userDragging;
    NSInteger _agentTypingIndex;
    BOOL _userTyping;
    BOOL _networkDisconnected;
    BOOL _showingPostChatSurvey;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *chatToolbarContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatToolbarBottomConstraint;

@property (strong, nonatomic) NSMutableDictionary *participants;

@property (strong, nonatomic) ECSChatWaitView *waitView;
@property (strong, nonatomic) ECSCallbackViewController *callbackViewController;

@property (strong, nonatomic) ECSChatToolbarController *chatToolbar;
@property (assign, nonatomic) CGRect keyboardFrame;

@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) ECSStompChatClient *chatClient;

@property (assign, nonatomic) NSInteger currentReconnectIndex;

@property (strong, nonatomic) ECSInlineFormViewController *inlineFormController;
@property (strong, nonatomic) NSIndexPath *currentFormCellIndexPath;
@property (strong, nonatomic) NSLayoutConstraint *inlineFormBottomConstraint;
@property (assign, nonatomic) BOOL presentedForm;

@property (strong, nonatomic) NSArray *postChatActions;

@property (assign, nonatomic) NSUInteger agentInteractionCount;

@end

@implementation ECSChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _showingMoxtra = FALSE;
    
    ECSCafeXController *cafeXController = [[ECSInjector defaultInjector] objectForClass:[ECSCafeXController class]];
    [cafeXController setDefaultParent:self];
    
    self.agentInteractionCount = 0;
    
    [self configureNavigationBar];
    
    
    self.showFullScreenReachabilityMessage = NO;
    _agentTypingIndex = -1;
    self.currentReconnectIndex = -1;
    _networkDisconnected = NO;
    
    self.chatToolbar.sendEnabled = NO;
    
    [self registerForKeyboardNotifications];
    
    self.participants = [NSMutableDictionary new];
    self.messages = [NSMutableArray new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkConnectionChanged:)
                                                 name:ECSReachabilityChangedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenShareEnded:)
                                                 name:@"NotificationScreenShareEnded"
                                               object:nil];
    
    // If host app sends this notification, we will end the chat (no dialog).
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doGracefulEndChat)
                                                 name:ECSEndChatNotification
                                               object:nil];
    
#ifdef DEBUG
    //    ECSChatTextMessage *textMessage = [ECSChatTextMessage new];
    //    textMessage.from = @"Agent";
    //    textMessage.fromAgent = YES;
    //    textMessage.body = @"This is an example message from the agent";
    //
    //    [self.messages addObject:textMessage];
    //    [self.messages addObject:[textMessage copy]];
    //
    //    ECSChatTextMessage *userTextMessage = [ECSChatTextMessage new];
    //    userTextMessage.from = @"User";
    //    userTextMessage.fromAgent = NO;
    //    userTextMessage.body = @"This is an example message from the user. This is an example message from the user. This is an example message from the user. This is an example message from the user. ";
    //
    //    [self.messages addObject:userTextMessage];
    //    [self.messages addObject:[userTextMessage copy]];
    //
    //    [self.messages addObject:[ECSChatNetworkMessage new]];
    //    [self.messages addObject:[ECSChatIdleMessage new]];
    
#endif
    
    [self registerTableViewCells];
    [self addChatToolbarView];
    [self addChatWaitView];
    
}

- (void)configureNavigationBar {
    self.navigationItem.title = self.actionType.displayName;
    if ([[self.navigationController viewControllers] count] > 1) {
        ECSImageCache *imageCache = [[ECSInjector defaultInjector] objectForClass:[ECSImageCache class]];
        UIImage *backImage = [[imageCache imageForPath:@"ecs_ic_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:backImage
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(backButtonPressed:)];
    }
}

- (void)registerTableViewCells {
    [self.tableView registerClass:[ECSChatMessageTableViewCell class] forCellReuseIdentifier:MessageCellID];
    [self.tableView registerClass:[ECSHtmlMessageTableViewCell class] forCellReuseIdentifier:HtmlMessageCellID];
    [self.tableView registerClass:[ECSChatImageTableViewCell class]
           forCellReuseIdentifier:ImageCellID];
    [self.tableView registerClass:[ECSChatTypingTableViewCell class] forCellReuseIdentifier:MessageTypingCellID];
    [self.tableView registerClass:[ECSChatActionTableViewCell class] forCellReuseIdentifier:ActionCellID];
    [self.tableView registerNib:[ECSChatTextTableViewCell ecs_nib]
         forCellReuseIdentifier:TextCellID];
    [self.tableView registerNib:[ECSChatNetworkActionCell ecs_nib] forCellReuseIdentifier:ChatNetworkCellID];
    [self.tableView registerClass:[ECSInlineFormTableViewCell class] forCellReuseIdentifier:InlineFormCellID];
}

- (void)addChatToolbarView {
    if (!self.historyJourney) {
        self.chatToolbar = [ECSChatToolbarController ecs_loadFromNib];
        self.chatToolbar.delegate = self;
        [self addChildViewController:self.chatToolbar];
        self.chatToolbar.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.chatToolbarContainer addSubview:self.chatToolbar.view];
        
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

- (void)addChatWaitView {
    self.waitView = [ECSChatWaitView ecs_loadInstanceFromNib];
    self.waitView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.waitView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:@{@"view": self.waitView}]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.waitView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.waitView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0f
                                                           constant:0.0f]];
}

- (void)dealloc
{
    [self.chatClient disconnect];
    self.tableView.delegate = nil;
    self.workflowDelegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
    
    if (self.waitView)
    {
        [self.waitView.loadingView startAnimating];
        if (!self.historyJourney)
        {
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
        if (!self.messages || self.messages.count == 0)
        {
            ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
            __weak typeof(self) weakSelf = self;
            [urlSession getChatHistoryDetailsForJourneyId:self.historyJourney
                                           withCompletion:^(ECSChatHistoryResponse *response, NSError *error)
            {
               weakSelf.messages = [[NSMutableArray alloc] initWithArray:[response chatMessages]];
               for (ECSChatMessage *message in weakSelf.messages)
               {
                   if ([message isKindOfClass:[ECSChatAddParticipantMessage class]])
                   {
                       [weakSelf.participants setObject:message
                                                 forKey:((ECSChatAddParticipantMessage*)message).userId];
                   }
               }
               [weakSelf.tableView reloadData];
               [weakSelf hideWaitView];
           }];
        }
    }
    else if (!self.chatClient)
    {
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_showingPostChatSurvey)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if (self.presentedForm)
    {
        self.presentedForm = NO;
        [self sendFormNotification];
    }
    
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self updateEdgeInsets];
}

#pragma mark - UINavigationBarDelegate

- (void)backButtonPressed:(id)sender
{
    if (self.chatClient.channelState == ECSChannelStateConnected)
    {
        [self handleBackNavigationAlert];
    }
    else
    {
        [self.workflowDelegate endVideoChat];
        [self.chatClient disconnect];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)minimizeButtonPressed:(id)sender {
    if ([self.workflowDelegate respondsToSelector:@selector(minimizeButtonTapped:)]) {
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
    ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    __weak typeof(self) weakSelf = self;
    [sessionManager getEndChatActionsForConversationId:self.chatClient.currentConversation.conversationID
                             withAgentInteractionCount:self.agentInteractionCount
                                     navigationContext:self.parentNavigationContext
                                              actionId:self.actionType.actionId
                                            completion:^(NSArray* result, NSError *error) {
                                                if (!error &&
                                                    (result.count > 0) &&
                                                    ([result.firstObject isKindOfClass:[ECSFormActionType class]]))
                                                {
                                                    weakSelf.postChatActions = result;
                                                }
                                            }];
}
- (void)handleDisconnectPostSurveyCall
{
    ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    __weak typeof(self) weakSelf = self;
    [sessionManager getEndChatActionsForConversationId:self.chatClient.currentConversation.conversationID
                             withAgentInteractionCount:self.agentInteractionCount
                                     navigationContext:self.parentNavigationContext
                                              actionId:self.actionType.actionId
                                            completion:^(NSArray* result, NSError *error) {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    [self.workflowDelegate endVideoChat];
                                                    ECSChatActionType *actionType = (ECSChatActionType *)self.actionType;
                                                    if (actionType.shouldTakeSurvey) {
                                                        weakSelf.postChatActions = result;
                                                        [weakSelf showSurveyDisconnectMessage];
                                                    } else {
                                                        if([self.actionType.displayName isEqualToString:@"Chat Workflow"])
                                                        {
                                                            [self showSurveyDisconnectMessage];
                                                        }
                                                        else
                                                        {
                                                        [weakSelf showNoSurveyDisconnectMessage];
                                                        }
                                                    }
                                                    //TODO: Need to we need some data from results, Navigations should be taken care by host app in Demo 2.0
                                                    //                                                    if (error || (result.count == 0)) //|| !([result.firstObject isKindOfClass:[ECSFormActionType class]])
                                                    //                                                    {
                                                    //                                                        [weakSelf showNoSurveyDisconnectMessage];
                                                    //                                                    }
                                                    //                                                    else
                                                    //                                                    {
                                                    //                                                        weakSelf.postChatActions = result;
                                                    //                                                        [weakSelf showSurveyDisconnectMessage];
                                                    // }
                                                });
                                            }];
}


-(void) handleReceiveSendQuestionMessage:(ECSSendQuestionMessage *)message {
    NSString *question = message.questionText;
    NSString *context = message.interfaceName;
    
    ECSURLSessionManager* sessionManager = [[EXPERTconnect shared] urlSession];
    
    __weak typeof(self) weakSelf = self;
    
    [sessionManager getAnswerForQuestion:question inContext:context parentNavigator:@"" actionId:@"" questionCount:0
                              customData:nil completion:^(ECSAnswerEngineResponse *response, NSError *error)
     {
         ECSReceiveAnswerMessage *answer = [ECSReceiveAnswerMessage new];
         
         answer.from = message.from;
         answer.answerText = response.answer;
         
         answer.fromAgent = YES;
         
         [weakSelf chatClient:nil didReceiveMessage:answer];
     }];
}


- (void)closeButtonTapped:(id)sender
{
    [super closeButtonTapped:sender];
    [self.workflowDelegate endVideoChat];
    [self.chatClient disconnect];
    [self.navigationController popViewControllerAnimated:NO];
    
    if (self.chatClient.channelState != ECSChannelStateDisconnected) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ECSChatEndedNotification
                                                            object:self];
    }
}

- (void)showSurvey
{
    [self.chatToolbar resignFirstResponder];
//    [self.workflowDelegate disconnectedFromChat];
    
    if(!self.workflowDelegate)   {
        if (self.postChatActions &&
            (self.postChatActions.count > 0) &&
            ([self.postChatActions.firstObject isKindOfClass:[ECSFormActionType class]]))
        {
            ECSFormActionType *formAction = self.postChatActions.firstObject;
            UIViewController *surveyFormController = [ECSRootViewController ecs_viewControllerForActionType:formAction];
            
            [self presentModal:surveyFormController withParentNavigationController:self.navigationController fromViewController:self.navigationController];
            _showingPostChatSurvey = YES;
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
            
            if (self.chatClient.channelState != ECSChannelStateDisconnected) {
                [[NSNotificationCenter defaultCenter] postNotificationName:ECSChatEndedNotification
                                                                    object:self];
            }
        }
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
        
        if([self.actionType.displayName isEqualToString:@"Chat Workflow"])
        {
            [self.workflowDelegate chatEndedWithTotalInteractionCount:self.messages.count agentInteractions:self.agentInteractionCount userInteractions:self.messages.count-self.agentInteractionCount];
        }
    }
}

- (void)showNoSurveyDisconnectMessage
{
    ECSChatInfoMessage *disconnectedMessage = [ECSChatInfoMessage new];
    disconnectedMessage.fromAgent = YES;
    disconnectedMessage.infoMessage = ECSLocalizedString(ECSLocalizeChatDisconnected, @"Disconnected");
    [self.messages addObject:disconnectedMessage];
    [self.tableView reloadData];
}

- (void)showSurveyDisconnectMessage
{
    ECSEndChatSurveyView *endChatView = [ECSEndChatSurveyView ecs_loadInstanceFromNib];
    [endChatView.exitChatButton addTarget:self action:@selector(exitChatButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableFooterView = endChatView;
    [self.tableView reloadData];
    
    [self.tableView scrollRectToVisible:CGRectMake(0,
                                                   self.tableView.contentSize.height - self.tableView.bounds.size.height,
                                                   self.tableView.bounds.size.width,
                                                   self.tableView.bounds.size.height) animated:YES];
}

- (void)exitChatButtonTapped:(id)sender
{
    NSString *alertTitle = ECSLocalizedString(ECSLocalizeWarningKey, @"Warning");
    NSString *alertMessage = ECSLocalizedString(ECSLocalizeChatDisconnectPromptSurvey, @"Chat Disconnect Prompt");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                             message:alertMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizeYes, @"YES")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [self showSurvey];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizeNo, @"NO")
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)handleBackNavigationAlert
{
    NSString *alertTitle = ECSLocalizedString(ECSLocalizeWarningKey, @"Warning");
    
    NSString *alertMessage = ECSLocalizedString(ECSLocalizeChatDisconnectPrompt, @"Chat Disconnect Prompt");
    
    if (self.postChatActions.count > 0)
    {
        alertMessage = ECSLocalizedString(ECSLocalizeChatDisconnectPromptSurvey, @"Chat Disconnect Prompt");
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                             message:alertMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizeYes, @"YES")
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [self doGracefulEndChat];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizeNo, @"NO")
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)doGracefulEndChat {
    [self.workflowDelegate endVideoChat];
    [self.chatClient disconnect];
    [self showSurvey];
}

#pragma mark - Chat Toolbar callbacks
- (void)sendChatState:(NSString *)chatState
{
    NSString *sendState = nil;
    if (!_userTyping && [chatState isEqualToString:@"composing"]) {
        _userTyping = YES;
        sendState = chatState;
    } else if (_userTyping && [chatState isEqualToString:@"paused"]) {
        _userTyping = NO;
        sendState = chatState;
    }
    
    if(sendState) {
        ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
        [urlSession sendChatState:chatState
                         duration:10000
                          channel:self.chatClient.currentChannelId
                       completion:^(NSString *response, NSError *error)
         {
             
             if(error) {
                 NSLog(@"Sending chat state error: %@", error);
             }
         }];
    }
}

- (void)sendText:(NSString *)text
{
    ECSChatTextMessage *message = [ECSChatTextMessage new];
    
    message.from = self.chatClient.fromUsername;
    message.fromAgent = NO;
    message.channelId = self.chatClient.currentChannelId;
    message.conversationId = self.chatClient.currentConversation.conversationID;
    
    message.body = text;
    [self.messages addObject:message];
    
   // [self sendChatState:@"paused"];
    
    //[self.chatClient sendChatMessage:message];
    ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    [urlSession sendChatMessage:message.body
                           from:message.from
                        channel:message.channelId
                     completion:^(NSString *response, NSError *error)
     {
         if(error) {
             NSLog(@"Error sending chat message: %@", error);
         }
     }];
    
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
             NSLog(@"Error sending chat message: %@", error);
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
             ECSLogError(@"Failed to send media %@", error);
         }
         else
         {
             ECSLogVerbose(@"Media uploaded successfully");
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
                  if(error) {
                      NSLog(@"Error sending chat notification message: %@", error);
                  }
              }];
         }
     }];
}


#pragma mark - StompClient
- (void)chatClientDidConnect:(ECSStompChatClient *)stompClient
{
    if (self.currentReconnectIndex >= 0)
    {
        [self.tableView beginUpdates];
        [self.messages removeLastObject];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.currentReconnectIndex inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        self.currentReconnectIndex = -1;
    }
    
    [self.chatToolbar initializeSendState];
}

-(void) screenShareEnded:(NSNotification*)notification
{
    if ([notification.name isEqualToString:@"NotificationScreenShareEnded"])
    {
        _showingMoxtra = FALSE;
        
        [self updateEdgeInsets];
    }
}

- (void)chatClient:(ECSStompChatClient *)stompClient didReceiveMessage:(ECSChatMessage *)message
{
    /* Deprecated. Moxtra SDK has been removed. Should use CafeX instead.
     if ([message isKindOfClass:[ECSChatCoBrowseMessage class]])
     {
     ECSChatAddParticipantMessage *participant = [self participantInfoForID:((ECSChatStateMessage*)message).from];
     NSString *expertName = [participant firstName];
     if (expertName == nil || expertName.length == 0) {
     expertName = @"The Expert"; // TODO: Translate
     }
     // Confirm with User:
     NSString *alertTitle = @"Share Screen?"; // TODO: Translate
     NSString *alertMessage = [NSString stringWithFormat:@"%@ has requested to see your screen. Allow?", expertName]; // TODO: Translate
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
     NSLog(@"Start meet successfully with MeetID [%@]", meetID);
     
     // Alert Agent to the MeetID:
     [self sendCoBrowseMessage:meetID];
     
     // Make room for Moxtra panel:
     _showingMoxtra = TRUE;
     [self updateEdgeInsets];
     } else {
     NSLog(@"Start meet failed! No Meet ID returned by delegate");
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
     NSLog(@"User rejected Screen Share request.");
     [self sendSystemText:@"User rejected Screen Share request."];
     }]];
     [self presentViewController:alertController animated:YES completion:nil];
     
     return; // no UI
     }
     */
    
    if ([message isKindOfClass:[ECSCafeXMessage class]])
    {
        ECSChatAddParticipantMessage *participant = [self participantInfoForID:((ECSChatStateMessage*)message).from];
        NSString *expertName = [participant firstName];
        if (expertName == nil || expertName.length == 0) {
            expertName = @"The Expert"; // TODO: Translate
        }
        NSString *channelName = nil;
        NSString *channelType = ((ECSCafeXMessage*)message).parameter1;
        if ([channelType isEqualToString:@"voice_escalate"]) {
            channelName = @"a Voice Call"; // TODO: Translate
        } else if ([channelType isEqualToString:@"video_escalate"]) {
            channelName = @"a Video Call"; // TODO: Translate
        } else if ([channelType isEqualToString:@"cobrowse_start"]) {
            channelName = @"that you share your screen."; // TODO: Translate
        } else if ([channelType isEqualToString:@"cobrowse_stop"]) {
            /* no op */
        } else {
            NSLog(@"Unable to parse CafeX TT:Command: Unknown channel type %@", channelType);
            return; // no UI
        }
        NSString *targetID = ((ECSCafeXMessage*)message).parameter2;
        // Confirm with User only if video or voice:
        if ([channelType isEqualToString:@"cobrowse_start"]) {
            // CafeX will prompt user.
            ECSCafeXController *cafeXController = [[ECSInjector defaultInjector] objectForClass:[ECSCafeXController class]];
            [cafeXController startCoBrowse:targetID usingParentViewController:self];
        } else if ([channelType isEqualToString:@"cobrowse_stop"]) {
            ECSCafeXController *cafeXController = [[ECSInjector defaultInjector] objectForClass:[ECSCafeXController class]];
            [cafeXController endCoBrowse];
        } else {
            NSString *alertTitle = @"Accept Call?"; // TODO: Translate
            NSString *alertMessage = [NSString stringWithFormat:@"%@ has requested %@. Allow?", expertName, channelName]; // TODO: Translate
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                                     message:alertMessage
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizeYes, @"YES")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  ECSCafeXController *cafeXController = [[ECSInjector defaultInjector] objectForClass:[ECSCafeXController class]];
                                                                  
                                                                  // Do a login if there's no session:
                                                                  if (![cafeXController hasCafeXSession]) {
                                                                      [cafeXController setupCafeXSessionWithTask:^{
                                                                          [cafeXController dial:targetID withVideo:[channelType isEqualToString:@"video_escalate"] andAudio:YES usingParentViewController:self];
                                                                      }];
                                                                  } else {
                                                                      [cafeXController dial:targetID withVideo:[channelType isEqualToString:@"video_escalate"] andAudio:YES usingParentViewController:self];
                                                                  }
                                                              }]];
            [alertController addAction:[UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizeNo, @"NO")
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction *action) {
                                                                  // No
                                                                  NSLog(@"User rejected %@ request.", channelType);
                                                                  [self sendSystemText:[NSString stringWithFormat:@"User rejected request for %@.", channelName]];
                                                              }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
        return; // no UI
    }
    
    if ([message isKindOfClass:[ECSChatVoiceAuthenticationMessage class]])
    {
        ECSChatAddParticipantMessage *participant = [self participantInfoForID:((ECSChatStateMessage*)message).from];
        NSString *expertName = [participant firstName];
        if (expertName == nil || expertName.length == 0) {
            expertName = @"The Expert"; // TODO: Translate
        }
        // Confirm with User:
        NSString *alertTitle = @"Voice Authentication"; // TODO: Translate
        NSString *alertMessage = [NSString stringWithFormat:@"%@ has requested that you authenticate by voice print. Press OK to continue.", expertName]; // TODO: Translate
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                                 message:alertMessage
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizedOkButton, @"OK")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              /* Kick off internal VoiceIT auth check */
                                                              [[EXPERTconnect shared] voiceAuthRequested:[[EXPERTconnect shared] userName] callback:^(NSString *response) {
                                                                  // Alert Agent to the response:
                                                                  [self sendVoiceAuthConfirmation:response];
                                                              }];
                                                          }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
        return; // no UI
    }
    
    if ([message isKindOfClass:[ECSChatAddParticipantMessage class]])
    {
        [self.participants setObject:message forKey:((ECSChatAddParticipantMessage*)message).userId];
    }
    
    if ([message isKindOfClass:[ECSSendQuestionMessage class]])
    {
        [self handleReceiveSendQuestionMessage:(ECSSendQuestionMessage *)message];
        return; // When Response is received, handler will send through an ECSReceiveAnswerMessage
    }
    
    if (message.fromAgent)
    {
        self.agentInteractionCount += 1;
        [self pollForPostSurvey];
    }
    
    if (_agentTypingIndex != -1 && (_agentTypingIndex == self.messages.count - 1))
    {
        [self.messages replaceObjectAtIndex:_agentTypingIndex withObject:message];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_agentTypingIndex inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        
        _agentTypingIndex = -1;
        
    }
    else
    {
        if (_agentTypingIndex != -1)
        {
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
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ECSChatMessageReceivedNotification
                                                        object:message];
}

- (void)chatClient:(ECSStompChatClient *)stompClient didReceiveChatStateMessage:(ECSChatStateMessage *)state
{
    if(state.object && [state.type isEqualToString:@"artifact"]) {
        // We have an incoming document from the server.
        
        //(NSURLSessionDataTask *)getMediaFileNamesWithCompletion
    }
    
    if (state.chatState == ECSChatStateComposing)
    {
        if (_agentTypingIndex == -1)
        {
            _agentTypingIndex = [self.messages count];
            [self.messages addObject:state];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
    else
    {
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

- (void)chatClient:(ECSStompChatClient *)stompClient didReceiveChatNotificationMessage:(ECSChatNotificationMessage*)notificationMessage
{
	 [self.messages addObject:notificationMessage];
	 [self.tableView beginUpdates];
	 
	 [self.tableView insertRowsAtIndexPaths:[self indexPathsToUpdate] withRowAnimation:UITableViewRowAnimationAutomatic];
	 
	 [self.tableView endUpdates];
	 [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ECSChatNotificationMessageReceivedNotification
                                                        object:notificationMessage];
}

- (void)chatClient:(ECSStompChatClient *)stompClient didFailWithError:(NSError *)error
{
    NSString *errorMessage = ECSLocalizedString(ECSLocalizeErrorText, nil);
    
    BOOL validError = (![error.userInfo[NSLocalizedDescriptionKey] isEqual:[NSNull null]] &&
                       error.userInfo[NSLocalizedDescriptionKey]);
    
    if (error && validError)
    {
        errorMessage = error.userInfo[NSLocalizedDescriptionKey];
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ECSLocalizedString(ECSLocalizeError, nil)
                                                                             message:errorMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [alertController addAction:[UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizedOkButton, nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          if (weakSelf.isBeingPresented)
                                                          {
                                                              [weakSelf dismissViewControllerAnimated:YES completion:nil];
                                                          }
                                                          else if (weakSelf.navigationController.viewControllers.count > 1)
                                                          {
                                                              [weakSelf.navigationController popViewControllerAnimated:YES];
                                                              
                                                              // Post chat ended notification
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:ECSChatEndedNotification
                                                                                                                  object:self
                                                                                                                userInfo:@{@"reason":@"error",
                                                                                                                            @"error":errorMessage}];
                                                          }
                                                      }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)chatClient:(ECSStompChatClient *)stompClient didUpdateEstimatedWait:(NSInteger)waitTime;
{
    //waitTime = 180; // TESTING ONLY. (in seconds)
    //waitMinutes = waitTime / 60.0f; // Convert seconds to minutes
    int waitMinutes = waitTime / 60.0f;
    if (waitTime <= 60)
    {
        self.waitView.subtitleLabel.text = ECSLocalizedString(ECSLocalizeWaitTimeShort, @"Wait time");
    }
    else if (waitTime > 60 && waitTime < 300)
    {
        self.waitView.subtitleLabel.text = [NSString stringWithFormat:ECSLocalizedString(ECSLocalizeWaitTime, @"Wait time"), waitMinutes];
    }
    else if (waitTime >= 300)
    {
        self.waitView.subtitleLabel.text = ECSLocalizedString(ECSLocalizeWaitTimeLong, @"Wait time");
    }
}

- (void)chatClientAgentDidAnswer:(ECSStompChatClient *)stompClient
{
    [self hideWaitView];
}

- (void)voiceCallbackDidAnswer:(ECSStompChatClient *)stompClient
{
    if (_callbackViewController != nil) {
        [self.navigationController popToViewController:self animated:YES];
        _callbackViewController = nil;
    }
}

- (void)hideWaitView
{
    if (self.waitView)
    {
        [UIView animateWithDuration:0.3f animations:^{
            self.waitView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self.waitView removeFromSuperview];
            self.waitView = nil;
            if(![self.actionType.displayName isEqualToString:@"Chat Workflow"])
            {
                // mas - 11-oct-15 - only show "minimize" if we are in a workflow.
                if(self.workflowDelegate) {
                    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Minimize"
                                                                                              style:UIBarButtonItemStylePlain
                                                                                             target:self
                                                                                             action:@selector(minimizeButtonPressed:)];
                }
            }
        }];
    }
    
}

- (void)chatClientDisconnected:(ECSStompChatClient *)stompClient
{
    ECSLogVerbose(@"Chat client was disconnected.");
    
    //[[EXPERTconnect shared].externalDelegate meetNeedstoEnd];
    
    ECSCafeXController *cafeXController = [[ECSInjector defaultInjector] objectForClass:[ECSCafeXController class]];
    
    // Do a login if there's no session:
    if ([cafeXController hasCafeXSession]) {
        [cafeXController endCoBrowse];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ECSChatEndedNotification
                                                        object:self];
    
    [self handleDisconnectPostSurveyCall];
    self.chatToolbar.sendEnabled = NO;
}

- (void)chatClient:(ECSStompChatClient *)stompClient didAddChannelWithMessage:(ECSChatAddChannelMessage *)message
{
    [self.messages addObject:message];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

#pragma mark - Convenience

- (NSArray *)indexPathsToUpdate {
    NSInteger numberOfIndexPathsToBeInserted = (self.messages.count - [self.tableView numberOfRowsInSection:0]);
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:numberOfIndexPathsToBeInserted];
    for (NSInteger i = 1; i <= numberOfIndexPathsToBeInserted; i++) {
        NSInteger row = (self.messages.count - i);
        [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];
    }
    
    return [NSArray arrayWithArray:indexPaths];
}

- (NSIndexPath*)indexPathForLastRow
{
    return [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] - 1 inSection:0];
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
            [typingCell.background.avatarImageView setImageWithPath:participant.avatarURL];
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
        [self configureMediaCell:imageCell withMessage:message];
        cell = imageCell;
    }
    else if ([message isKindOfClass:[ECSChatNotificationMessage class]])
    {
        ECSChatImageTableViewCell *imageCell = [self.tableView dequeueReusableCellWithIdentifier:ImageCellID
                                                                                    forIndexPath:indexPath];
        [self configureMediaCell:imageCell withNotificationMessage:message];
        cell = imageCell;
        
    }
    else if ([message isKindOfClass:[ECSChatAddChannelMessage class]])
    {
        ECSChatActionTableViewCell *actionCell = [self.tableView dequeueReusableCellWithIdentifier:ActionCellID
                                                                                      forIndexPath:indexPath];
        [self configureCallbackCell:actionCell withMessage:message];
        cell = actionCell;
    }
    
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id message = self.messages[indexPath.row];
    
    if ([message isKindOfClass:[ECSChatURLMessage class]])
    {
        ECSWebViewController *webController = [ECSWebViewController ecs_loadFromNib];
        [webController loadItemAtPath:[(ECSChatURLMessage*)message url]];
        [self.navigationController pushViewController:webController animated:YES];
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
            
            self.presentedForm = YES;
            [self presentModal:formController withParentNavigationController:self.navigationController];
        }
    }
    else if ([message isKindOfClass:[ECSChatAddChannelMessage class]])
    {
        [self showAddChannelModalForMessage:message];
    }
    
}

- (void)sendFormNotification
{
    ECSLogVerbose(@"Form complete notification");
    ECSChatNotificationMessage *notification = [ECSChatNotificationMessage new];
    notification.from = self.chatClient.fromUsername;
    notification.channelId = self.chatClient.currentChannelId;
    notification.conversationId = self.chatClient.currentConversation.conversationID;
    notification.type = @"interview";
    notification.objectData = nil;
	 
	 ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
	 
	 [urlSession sendChatNotificationFrom:self.chatClient.fromUsername
									 type:@"interview"
							   objectData:@""
						   conversationId:self.chatClient.currentConversation.conversationID
								  channel:self.chatClient.currentChannelId
							   completion:^(NSString *response, NSError *error)
	  {
		   if(error) {
				NSLog(@"Error sending chat notification message: %@", error);
		   }
	  }];

//    [self.chatClient sendNotificationMessage:notification];
}

- (void)sendCoBrowseMessage:(NSString *)meetID
{
    // meetID is an 8-digit number, which will get flagged as a SSN on the
    // backend. So, we must obfuscate it:
    meetID = [meetID stringByAppendingString:@"0000"];
    
    ECSLogVerbose(@"Co Browse Meet Started notification");
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
        
        ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
        [urlSession submitForm:self.inlineFormController.form completion:nil];
        [self.tableView reloadRowsAtIndexPaths:@[self.currentFormCellIndexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        self.currentFormCellIndexPath = nil;
        self.inlineFormController = nil;
    }];
    
}

- (void)configureMessageCell:(ECSChatTableViewCell*)cell
                 withMessage:(ECSChatTextMessage *)chatMessage
                 atIndexPath:(NSIndexPath*)indexPath
{
    ECSChatMessageTableViewCell *messageCell = (ECSChatMessageTableViewCell*)cell;
    
    messageCell.userMessage = !chatMessage.fromAgent;
    messageCell.background.showAvatar = [self showAvatarAtIndexPath:indexPath];
    
    if (messageCell.background.showAvatar)
    {
        ECSChatAddParticipantMessage *participant = [self participantInfoForID:chatMessage.from];
        //[messageCell.background.avatarImageView setImageWithPath:participant.avatarURL];
        
        if (!chatMessage.fromAgent)
        {
            ECSUserManager *userManager = [[ECSInjector defaultInjector] objectForClass:[ECSUserManager class]];
            if(userManager.userAvatar)
            {
                [messageCell.background setAvatarImage:userManager.userAvatar];
            }
        }
        else
        {
            if (participant.avatarURL)
            {
                [messageCell.background setAvatarImageFromPath:participant.avatarURL];
            }
            
        }
        
    }
    messageCell.messageLabel.text = chatMessage.body;
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
        cell.actionCellType = ECSChatActionCellTypeLink;
        ECSChatURLMessage *urlMesssage = (ECSChatURLMessage*)message;
        cell.messageLabel.text = (urlMesssage.comment && urlMesssage.comment.length > 0) ? urlMesssage.comment : urlMesssage.url;
        participant = [self participantInfoForID:urlMesssage.from];
        
    }
    else if ([message isKindOfClass:[ECSChatFormMessage class]])
    {
        cell.actionCellType = ECSChatActionCellTypeForm;
        
        BOOL submitted = ((ECSChatFormMessage*)message).formContents.submitted;
        
        NSString *title = ((ECSChatFormMessage*)message).formContents.formTitle;
        
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
            participant = [self participantInfoForID:((ECSChatFormMessage*)message).from];
        }
    }
    
    if (cell.background.showAvatar && participant)
    {
        [cell.background.avatarImageView setImageWithPath:participant.avatarURL];
    }
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
}


- (void)configureMediaCell:(ECSChatImageTableViewCell*)cell withMessage:(ECSChatMediaMessage*)chatMessage;
{
    cell.userMessage = !chatMessage.fromAgent;
    [cell.messageImageView setImage:chatMessage.imageThumbnail];
    cell.showPlayIcon = (chatMessage.mediaType == ECSChatMediaTypeMovie);
}

- (void)configureMediaCell:(ECSChatImageTableViewCell*)cell withNotificationMessage:(ECSChatNotificationMessage*)chatMessage;
{
    if ([chatMessage.type isEqualToString:@"artifact"])
    {
        cell.userMessage = !chatMessage.fromAgent;
        NSString *fileName = chatMessage.objectData;
        
        ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
        NSURLRequest *request = [sessionManager urlRequestForMediaWithName:fileName];
        [cell.messageImageView setImageWithRequest:request];
        
        cell.showPlayIcon = NO;
    }
}

- (void)configureChatTextCell:(ECSChatTextTableViewCell*)cell
    withAddParticipantMessage:(ECSChatAddParticipantMessage*)message
{
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    cell.chatTextLabel.font = theme.chatInfoTitleFont;
    cell.chatTextLabel.textColor = theme.primaryTextColor;
    cell.chatTextLabel.text = [NSString stringWithFormat:ECSLocalizedString(ECSLocalizeChatJoin, @"Chat Join"), message.firstName];
}

- (void)configureChatTextCell:(ECSChatTextTableViewCell*)cell
              withInfoMessage:(ECSChatInfoMessage*)message
{
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    cell.chatTextLabel.font = theme.captionFont;
    cell.chatTextLabel.textColor = theme.secondaryTextColor;
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
            UIImage *thumbnail = nil;
            
            if ([chatMessage isKindOfClass:[ECSChatMediaMessage class]])
            {
                thumbnail = ((ECSChatMediaMessage*)chatMessage).imageThumbnail;
            }
            
            CGFloat maxWidth = (CGRectGetWidth(self.tableView.frame) * 0.5f);
            if (thumbnail)
            {
                height = (thumbnail.size.height / thumbnail.size.width) * maxWidth;
            }
            else
            {
                height = (CGRectGetWidth(self.tableView.frame) * 0.5);
            }
        }
    }
    else if ([chatMessage isKindOfClass:[ECSChatAddChannelMessage class]])
    {
        [self configureCallbackCell:actionCell withMessage:(ECSChatAddChannelMessage*)chatMessage];
        height = [self calculateHeightForConfiguredSizingCell:actionCell];
    }
    
    return height;
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
            
            if (previousMessage.fromAgent == message.fromAgent)
            {
                showAvatar = NO;
            }
        }
    }
    
    return showAvatar;
}

- (void)showAddChannelModalForMessage:(ECSChatAddChannelMessage*)message
{
    _callbackViewController = [ECSCallbackViewController ecs_loadFromNib];
    ECSCallbackActionType *callbackAction = [ECSCallbackActionType new];
    [_callbackViewController setChatClient:_chatClient];
    
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

- (void)reconnectWebsocket:(id)sender
{
    if (self.chatClient)
    {
        [self.chatClient reconnect];
    }
}

- (void)networkConnectionChanged:(id)sender
{
    ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    if (sessionManager.networkReachable && _networkDisconnected)
    {
        _networkDisconnected = NO;
    }
    else if (!sessionManager.networkReachable && !_networkDisconnected)
    {
        self.chatToolbar.sendEnabled = NO;
        if (self.currentReconnectIndex < 0)
        {
            [self.messages addObject:[ECSChatNetworkMessage new]];
            self.currentReconnectIndex = self.messages.count - 1;
            [self.tableView reloadData];
        }
        _networkDisconnected = YES;
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

@end
