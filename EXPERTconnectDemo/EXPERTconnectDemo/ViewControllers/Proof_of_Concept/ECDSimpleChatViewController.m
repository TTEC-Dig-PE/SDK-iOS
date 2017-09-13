//
//  ECDSimpleChatViewController.m
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 12/15/15.
//  Copyright © 2015 Humanify, Inc. All rights reserved.
//

#import "ECDSimpleChatViewController.h"

@interface ECDSimpleChatViewController () <ECSStompChatDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *chatTextBox;
@property (weak, nonatomic) IBOutlet UITextView *chatTextLog;

@property (strong, nonatomic) ECSStompChatClient *chatClient;

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
    self.chatTextBox.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self appendToChatLog:@"This view demonstrates a chat client using low-level API calls (limited UI)."];
    
    if (!self.chatClient) {
        
        self.chatClient = [ECSStompChatClient new];
        self.chatClient.delegate = self;

        // New
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey];
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
        
        [self.chatClient startChatWithSkill:@"CE_Mobile_Chat"
                                    subject:[NSString stringWithFormat:@"%@ %@ %@ (low level)", appName, version, build]
                                   priority:kECSChatPriorityUseServerDefault
                                 dataFields:@{@"subID": @"abc123", @"memberType": @"coach"}];
    }
    
    [super viewWillAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
    
    [self.chatClient disconnect];
}

#pragma mark - View Interactive Objects

- (IBAction)sendButton_Touch:(id)sender {
    
    if (self.chatTextBox.text.length > 0) {
        
        // Send the actual text message to the server.
        
        
        [self.chatClient sendChatText:self.chatTextBox.text
                           completion:^(NSString *response, NSError *error) {
            if(error) {
                NSLog(@"Error sending chat message: %@", error);
            }
        }];
        
        [self appendToChatLog:[NSString stringWithFormat:@"Me: %@", self.chatTextBox.text]];
        
        self.chatTextBox.text = @"";
        
        [self hideKeyboard];
    }
}

#pragma mark - StompClient Callbacks

- (void) chatDidConnect {
    
    [self appendToChatLog:@"Chat session initiated. Waiting for an agent to answer..."];
}

- (void) chatAgentDidAnswer {
    
    [self appendToChatLog:@"An agent is connecting..."];
}

- (void) chatAddedParticipant:(ECSChatAddParticipantMessage *)participant {
    
    [self appendToChatLog:[NSString stringWithFormat:@"%@ %@ (%@) has joined the chat.", participant.firstName, participant.lastName, participant.userId]];
}

- (void) chatRemovedParticipant:(ECSChatRemoveParticipantMessage *)participant {
    
    [self appendToChatLog:[NSString stringWithFormat:@"%@ %@ (%@) has left the chat.", participant.firstName, participant.lastName, participant.userId]];
}

- (void) chatReceivedTextMessage:(ECSChatTextMessage *)message {
    
    [self appendToChatLog:[NSString stringWithFormat:@"%@: %@", message.from, message.body]];
}

- (void) chatStateUpdatedTo:(ECSChatState)state {
    
    if (state == ECSChatStateComposing) {
        
        NSLog(@"Agent is typing...");
        
    } else if (state == ECSChatStateTypingPaused) {
        
        NSLog(@"Agent has stopped typing.");
        
    }
}

- (void) chatDisconnectedWithMessage:(ECSChannelStateMessage *)message {
    
    if ( message.disconnectReason == ECSDisconnectReasonIdleTimeout ) {
        [self appendToChatLog:@"Chat has timed out."];
        
    } else if ( message.disconnectReason == ECSDisconnectReasonDisconnectByParticipant ) {
        [self appendToChatLog:[NSString stringWithFormat:@"Chat was ended by: %@", message.terminatedByString]];
        
    } else {
        [self appendToChatLog:@"Chat was ended for an unknown reason"];
    }
    
}

- (void) chatDidFailWithError:(NSError *)error {
    
    [self appendToChatLog:[NSString stringWithFormat:@"Chat error: %@", [error.userInfo objectForKey:@"NSLocalizedDescription"]]];
}

- (void) chatTimeoutWarning:(int)seconds {
    
    [self appendToChatLog:[NSString stringWithFormat:@"Chat will timeout in %d seconds.", seconds]];
}

// Receive other types of messages.
- (void)chatClient:(ECSStompChatClient *)stompClient didReceiveMessage:(ECSChatMessage *)message {
    
    NSLog(@"Received message: %@", message);
    
}

// A channel was added (e.g. escalate to voice)
- (void)chatClient:(ECSStompChatClient *)stompClient didAddChannelWithMessage:(ECSChatAddChannelMessage *)message {
    
    NSString *msg = [NSString stringWithFormat:@"Adding %@ channel with address: %@", message.mediaType, message.suggestedAddress];
    NSLog(@"%@", msg);
    [self appendToChatLog:msg];
}

- (void)chatClient:(ECSStompChatClient *)stompClient didUpdateEstimatedWait:(NSInteger)waitTime {
    
    NSLog(@"Updated estimated wait time is %ld", (long)waitTime);
}

// A notification message received.
- (void)chatClient:(ECSStompChatClient *)stompClient didReceiveChatNotificationMessage:(ECSChatNotificationMessage*)notificationMessage {
    
    // A media upload.
    NSLog(@"Received file with filename: %@", notificationMessage.objectData);
}

#pragma mark - Chat Client Functions

// Pass this function the string "composing" or "paused"
- (void)sendChatState:(ECSChatState)chatState {
    
    ECSChatState sendState = ECSChatStateUnknown;
    
    if (!_userTyping && chatState == ECSChatStateComposing) {
        
        _userTyping = YES;
        sendState = chatState;
        
    } else if (_userTyping && chatState == ECSChatStateTypingPaused) {
        
        _userTyping = NO;
        sendState = chatState;
        
    }
    
    if(sendState) {

        [self.chatClient sendChatState:sendState
                            completion:^(NSString *response, NSError *error)
         {
             if(error) {
                 NSLog(@"Sending chat state error: %@", error);
             }
         }];
    }
}



#pragma mark - Helper Functions

- (void) appendToChatLog:(NSString *)text {
    
    self.chatTextLog.text = [NSString stringWithFormat:@"%@\n%@", self.chatTextLog.text, text];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.25];
//    self.view.center = CGPointMake(_originalCenter.x, _originalCenter.y-255);
//    [UIView commitAnimations];
    
    [self sendChatState:ECSChatStateComposing];
}

- (BOOL) hideKeyboard {
    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.25];
//    self.view.center = CGPointMake(_originalCenter.x, _originalCenter.y);
//    [UIView commitAnimations];
    
    return [self.chatTextBox resignFirstResponder];
}

- (BOOL)resignFirstResponder {
    
    return [self hideKeyboard];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    return [self hideKeyboard];
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
