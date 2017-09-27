//
//  ECDSimpleChatViewController.m
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 12/15/15.
//  Copyright © 2015 Humanify, Inc. All rights reserved.
//

#import "ECDSimpleChatViewController.h"

@interface ECDSimpleChatViewController () <ECSStompChatDelegate>

@property (weak, nonatomic) IBOutlet UITextField *chatTextBox;
@property (weak, nonatomic) IBOutlet UITextView *chatTextLog;
@property (strong, nonatomic) ECSStompChatClient *chatClient;
@property (strong, nonatomic) ECSChatActionType *action;
@end

@implementation ECDSimpleChatViewController

bool _userTyping;
CGPoint _originalCenter;

#pragma mark - Base UIViewController Loading / Init
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _userTyping = NO;
    _originalCenter = self.view.center;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self appendToChatLog:@"This view demonstrates a chat client using low-level API calls (limited UI)."];
    
    if (!self.chatClient) {
        
        self.chatClient = [ECSStompChatClient new];
        self.chatClient.delegate = self;
        
        self.action = [ECSChatActionType new];
        
        self.action.actionId =          @"";
        self.action.agentSkill =        @"CE_Mobile_Chat";
        self.action.displayName =       @"SimpleChatter";
        self.action.shouldTakeSurvey =  NO;
        self.action.subject =           @"My Chat";
        self.action.channelOptions =    @{@"subID": @"abc123", @"memberType": @"coach"};
        self.action.journeybegin =      [NSNumber numberWithInt:1];
        
        // New parameter for 6.2.0: Set the chat priority. Default is 1 already (Low). Uncommenting this will raise the chat priority.
//        self.action.priority =        kECSChatPriorityHigh;
        
        [self.chatClient setupChatClientWithActionType:self.action];
    }
    [super viewWillAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
    [self.chatClient disconnect];
}

#pragma mark - View Interactive Objects

- (IBAction)sendButton_Touch:(id)sender {
    if (self.chatTextBox.text.length > 0) {
        [self sendText:self.chatTextBox.text];
        
        [self appendToChatLog:[NSString stringWithFormat:@"Me: %@", self.chatTextBox.text]];
        self.chatTextBox.text = @"";
        [self hideKeyboard];
    }
}

#pragma mark - StompClient Callbacks
- (void)chatClientDidConnect:(ECSStompChatClient *)stompClient {
    // We are now connected to an agent.
    //NSLog(@"Chat session initiated (waiting for agent to answer...)");
    [self appendToChatLog:@"Chat session initiated. Waiting for agent to answer..."];
}

- (void)chatClient:(ECSStompChatClient *)stompClient didReceiveMessage:(ECSChatMessage *)message {
    NSLog(@"Received message: %@", message);
    
    if ([message isKindOfClass:[ECSChatAddParticipantMessage class]])
    {
        // An agent has joined the chat.
        ECSChatAddParticipantMessage *addMsg = (ECSChatAddParticipantMessage*)message;
        [self appendToChatLog:[NSString stringWithFormat:@"%@ has joined the chat.", addMsg.fullName]];
    }
    else if ([message isKindOfClass:[ECSChatRemoveParticipantMessage class]])
    {
        // An agent has left the chat.
        ECSChatRemoveParticipantMessage *removeMsg = (ECSChatRemoveParticipantMessage*)message;
        [self appendToChatLog:[NSString stringWithFormat:@"%@ has left the chat.", removeMsg.fullName]];
    }
    else if ([message isKindOfClass:[ECSSendQuestionMessage class]])
    {
        // An agent has left the chat.
        ECSSendQuestionMessage *aeMsg = (ECSSendQuestionMessage *)message;
        [self appendToChatLog:[NSString stringWithFormat:@"Agent sent answer engine article: %@", aeMsg.questionText]];
        
        // Send user to the answer engine view.
        // [self showAnswerEngineWithQuestion:aeMsg.questionText];
    }
    else if ([message isKindOfClass:[ECSChatAssociateInfoMessage class]])
    {
        // An "associate info" message. A configured greeting message an agent can send via a button on the agent client.
        ECSChatAssociateInfoMessage *associateMsg = (ECSChatAssociateInfoMessage *)message;
        [self appendToChatLog:[NSString stringWithFormat:@"Associate Info: %@", associateMsg.message]];
    }
    else if( [message isKindOfClass:[ECSChatURLMessage class]] )
    {
        // The agent has sent a URL to the user.
        ECSChatURLMessage *urlMsg = (ECSChatURLMessage *)message;
        [self appendToChatLog:[NSString stringWithFormat:@"URL Sent: %@", urlMsg.url]];
    }
    else if( [message isKindOfClass:[ECSChatMessage class]])
    {
        // Standard text chat message.
        ECSChatTextMessage *chatMessage = (ECSChatTextMessage *)message;
        if (message.fromAgent) {
            // This is a message from the agent.
            [self appendToChatLog:[NSString stringWithFormat:@"Agent: %@", chatMessage.body]];
        }
    }
    else
    {
        [self appendToChatLog:@"Unknown message type received."];
    }
}

- (void)chatClientAgentDidAnswer:(ECSStompChatClient *)stompClient
{
    NSLog(@"Agent answered!");
    [self appendToChatLog:@"An agent is connecting..."];
}

// Dev Note: Older method. Does not contain disconnectReason or terminatedBy. Recommend using the method below.
//- (void)chatClientDisconnected:(ECSStompChatClient *)stompClient wasGraceful:(bool)graceful
//{
//    //NSLog(@"Chat client was disconnected.");
//    if( graceful )
//    {
//        [self appendToChatLog:@"Chat has disconnected."];
//    }
//    else
//    {
//        [self appendToChatLog:@"Chat disconnected (error!)"];
//    }
//}

- (void)chatClient:(ECSStompChatClient *)stompClient disconnectedWithMessage:(ECSChannelStateMessage *)message {
    
    if ( message.disconnectReason == ECSDisconnectReasonIdleTimeout ) {
        [self appendToChatLog:@"Chat has timed out."];
        
    } else if ( message.disconnectReason == ECSDisconnectReasonDisconnectByParticipant ) {
        [self appendToChatLog:[NSString stringWithFormat:@"Chat was ended by: %@", message.terminatedByString]];
        
    } else {
        [self appendToChatLog:@"Chat was ended for an unknown reason"];
    }
    
}

// A channel was added (e.g. escalate to voice)
- (void)chatClient:(ECSStompChatClient *)stompClient didAddChannelWithMessage:(ECSChatAddChannelMessage *)message
{
    NSString *msg = [NSString stringWithFormat:@"Adding %@ channel with address: %@", message.mediaType, message.suggestedAddress];
    NSLog(@"%@", msg);
    [self appendToChatLog:msg];
}

- (void)chatClient:(ECSStompChatClient *)stompClient didUpdateEstimatedWait:(NSInteger)waitTime
{
    NSLog(@"Updated estimated wait time is %ld", (long)waitTime);
}

// A chat state message received.
- (void)chatClient:(ECSStompChatClient *)stompClient didReceiveChatStateMessage:(ECSChatStateMessage *)state
{
    if (state.chatState == ECSChatStateComposing)
    {
        NSLog(@"Agent is typing...");
    }
    else if (state.chatState == ECSChatStateTypingPaused)
    {
        NSLog(@"Agent has stopped typing.");
    }
}

// A notification message received.
- (void)chatClient:(ECSStompChatClient *)stompClient didReceiveChatNotificationMessage:(ECSChatNotificationMessage*)notificationMessage
{
    // A media upload.
    NSLog(@"Received file with filename: %@", notificationMessage.objectData);
}

// An error has occurred on the STOMP channel
- (void)chatClient:(ECSStompChatClient *)stompClient didFailWithError:(NSError *)error {
    
    if( [error.domain isEqualToString:@"ECSWebSocketErrorDomain"] &&
           [error.userInfo[@"HTTPResponseStatusCode"] intValue] == 401 ) {
            
        // Fetch a new auth token and retry the stomp connect.
        int retryCount = 0;
        [[EXPERTconnect shared].urlSession refreshIdentityDelegate:retryCount
                                                    withCompletion:^(NSString *authToken, NSError *error)
         {
             // AuthToken updated. Try to reconnect.
             if( !error ) {
                 
                 [self.chatClient connectToHost:[EXPERTconnect shared].urlSession.hostName];
                 
             } else {
                 
                 [self appendToChatLog:[NSString stringWithFormat:@"Chat error: %@", [error.userInfo objectForKey:@"NSLocalizedDescription"]]];
             }
         }];
        
    } else {

        [self appendToChatLog:[NSString stringWithFormat:@"Chat error: %@", [error.userInfo objectForKey:@"NSLocalizedDescription"]]];
        
    }
}

#pragma mark - Chat Client Functions

// Pass this function the string "composing" or "paused"
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
    
    if(sendState)
    {
        [[[EXPERTconnect shared] urlSession] sendChatState:chatState
                                                  duration:10000
                                                   channel:self.chatClient.currentChannelId
                                                completion:^(NSString *response, NSError *error)
         {
             if(error)
             {
                 NSLog(@"Sending chat state error: %@", error);
             }
         }];
    }
}

- (void)sendText:(NSString *)text
{
    
    [[[EXPERTconnect shared] urlSession] sendChatMessage:text
                                                    from:self.chatClient.fromUsername
                                                 channel:self.chatClient.currentChannelId
                                              completion:^(NSString *response, NSError *error)
     {
         if(!error) {
             NSLog(@"Message sent to server!");
         } else {
             NSLog(@"Error sending chat message: %@", error);
         }
     }];
}

#pragma mark - Helper Functions

- (void) appendToChatLog:(NSString *)text {
    self.chatTextLog.text = [NSString stringWithFormat:@"%@\n%@", self.chatTextLog.text, text];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    self.view.center = CGPointMake(_originalCenter.x, _originalCenter.y-255);
    [UIView commitAnimations];
}

- (void)hideKeyboard {
    [self.chatTextBox resignFirstResponder];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    self.view.center = CGPointMake(_originalCenter.x, _originalCenter.y);
    [UIView commitAnimations];
}

#pragma mark - Base UIViewController Functions
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
