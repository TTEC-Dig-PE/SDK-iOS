//
//  ECDSimpleChatViewController.m
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 12/15/15.
//  Copyright © 2015 Humanify, Inc. All rights reserved.
//


// <ECSStompChatDelegate> callback functions 2.0 (NEW):

//- (void) chatDidConnect;
//- (void) chatAgentDidAnswer;
//- (void) chatTimeoutWarning:              (int);
//- (void) chatDidFailWithError:            (NSError *);
//- (void) chatDisconnectedWithMessage:     (ECSChannelStateMessage *);
//- (void) chatReceivedTextMessage:         (ECSChatTextMessage *);               *new* (formerly mixed in with didRecieveMessage)
//- (void) chatReceivedChatStateMessage:    (ECSChatStateMessage *);
//- (void) chatReceivedChannelStateMessage: (ECSChannelStateMessage *);
//- (void) chatAddedParticipant:            (ECSChatAddParticipantMessage *);     *new* (formerly came from didRecieveChannelStateMessage)
//- (void) chatRemovedParticipant:          (ECSChatRemoveParticipantMessage *);  *new* (same as above)
//- (void) chatUpdatedEstimatedWait:        (int)minutes;
//- (void) chatAddChannelWithMessage:       (ECSChatAddChannelMessage*);
//- (void) chatReceivedNotificationMessage: (ECSChatNotificationMessage *);

// <ECSStompChatDelegate> callback functions 1.0 (OLD):

//- (void)chatClientDidConnect:      (ECSStompChatClient *);
//- (void)chatClientAgentDidAnswer:  (ECSStompChatClient *);
//- (void)chatClientTimeoutWarning:  (ECSStompChatClient *)   timeoutSeconds:(int);
//- (void)chatClient:  (ECSStompChatClient *)   didFailWithError:                   (NSError *);
//- (void)chatClient:  (ECSStompChatClient *)   disconnectedWithMessage:            (ECSChannelStateMessage *);
//- (void)chatClient:  (ECSStompChatClient *)   didReceiveMessage:                  (ECSChatMessage*);
//- (void)chatClient:  (ECSStompChatClient *)   didReceiveChatStateMessage:         (ECSChatStateMessage*);
//- (void)chatClient:  (ECSStompChatClient *)   didReceiveChannelStateMessage:      (ECSChannelStateMessage *);
//- (void)chatClient:  (ECSStompChatClient *)   didUpdateEstimatedWait:             (NSInteger);
//- (void)chatClient:  (ECSStompChatClient *)   didAddChannelWithMessage:           (ECSChatAddChannelMessage*);
//- (void)chatClient:  (ECSStompChatClient *)   didReceiveChatNotificationMessage:  (ECSChatNotificationMessage*);


#import "ECDSimpleChatViewController.h"

@interface ECDSimpleChatViewController () <ECSStompChatDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITextField    *chatTextBox;
@property (weak, nonatomic) IBOutlet UITextView     *chatTextLog;

@property (strong, nonatomic) ECSStompChatClient    *chatClient;

@end

@implementation ECDSimpleChatViewController

bool        _userTyping;
CGPoint     _originalCenter;

#pragma mark - Base UIViewController Loading / Init

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _userTyping     = NO;
    _originalCenter = self.view.center;
    
    self.chatTextBox.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self appendToChatLog:@"This view demonstrates a chat client using low-level API calls (limited UI)."];
    
    if (!self.chatClient) {
        
        // For our test harness, we want to show the app version & build number to the agent desktop client.
        NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleNameKey];
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
        NSString *chatSubject = [NSString stringWithFormat:@"%@ %@ %@ (low level)", appName, version, build];
        
        // Initialize the chat object
        self.chatClient = [ECSStompChatClient new];
        self.chatClient.delegate = self;
        
        // Chat start - Quick Start
//        [self.chatClient startChatWithSkill:@"CE_Mobile_Chat"
//                                    subject:chatSubject];
        
        // Chat start - Advanced (more customizable fields, priority, dataFields. Contact Humanify support for help using these two fields).
        [self.chatClient startChatWithSkill:@"CE_Mobile_Chat"
                                    subject:chatSubject
                                   priority:kECSChatPriorityUseServerDefault
                                 dataFields:@{@"subID": @"abc123", @"memberType": @"coach"}];
    }
    
    [self configureNavigationBar];
    
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    
//    [self.chatClient disconnect]; // Close the chat.
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureNavigationBar {
    
    self.navigationItem.title = @"Low Level Chat";
    
    if ([[self.navigationController viewControllers] count] > 1) {
        
        // Configure the "back" button on the nav bar
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"< Back"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(backButtonPressed:)];
    }
}

- (void)backButtonPressed:(id)sender {
    
    [self.chatClient disconnect];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - ECSStompChatClient delegate callbacks


// The WebSocket has connected to the server. This may be when you flip your view to the chat screen or dislpay a message to the user "connecting..."
- (void) chatDidConnect {
    
    [self appendToChatLog:@"Chat session initiated. Waiting for an agent to answer..."];
}


// The chat has entered the "answered" state. In normal cases this callback would not be needed,
// but you could say "an associate is connecting...". Very soon after an "AddParticipant" message should arrive.
- (void) chatAgentDidAnswer {
    
    [self appendToChatLog:@"An agent is connecting..."];
}


// An associate has joined the chat. This contains their userID, name, and avatarURL. Here is where you would typically display "John has joined the chat."
- (void) chatAddedParticipant:(ECSChatAddParticipantMessage *)participant {
    
    [self appendToChatLog:[NSString stringWithFormat:@"%@ %@ (%@) has joined the chat.", participant.firstName, participant.lastName, participant.userId]];
}


// An associate has left the chat. This contains their userID, name, and avatarURL. Here is where you would typically display "John has left the chat." This might occur during a transfer. During a normal "associate disconnected", a disconnect would soon follow.
- (void) chatRemovedParticipant:(ECSChatRemoveParticipantMessage *)participant {
    
    [self appendToChatLog:[NSString stringWithFormat:@"%@ %@ (%@) has left the chat.", participant.firstName, participant.lastName, participant.userId]];
}


// An associate has sent a regular chat text message. The from field contains the userID, which should match an AddParticipant previously received.
- (void) chatReceivedTextMessage:(ECSChatTextMessage *)message {
    
    [self appendToChatLog:[NSString stringWithFormat:@"%@: %@", message.from, message.body]];
}


// A chat state message has arrrived. Typically used to detect when the agent has started typing and display that to the user.
- (void) chatReceivedChatStateMessage:(ECSChatStateMessage *)stateMessage {
    
    if (stateMessage.chatState == ECSChatStateComposing) {
        
        NSLog(@"Agent is typing...");
        
    } else if (stateMessage.chatState == ECSChatStateTypingPaused) {
        
        NSLog(@"Agent has stopped typing.");
        
    }
}


// The chat was disconnected from the serve side. Typically because the associated ended the chat or an idle timeout has occurred.
- (void) chatDisconnectedWithMessage:(ECSChannelStateMessage *)message {
    
    if ( message.disconnectReason == ECSDisconnectReasonIdleTimeout ) {
        
        [self appendToChatLog:@"Chat has timed out."];
        
    } else if ( message.disconnectReason == ECSDisconnectReasonDisconnectByParticipant ) {
        
        [self appendToChatLog:[NSString stringWithFormat:@"Chat was ended by: %@", message.terminatedByString]];
        
    } else {
        
        [self appendToChatLog:@"Chat was ended for an unknown reason"];
        
    }
    
}


// The server is sending a warning that this client will idle timeout in X seconds if the user does not interact (type a message, or send one).
- (void) chatTimeoutWarning:(int)seconds {
    
    [self appendToChatLog:[NSString stringWithFormat:@"Chat will timeout in %d seconds.", seconds]];
}


// An error has occurred on the WebSocket stream.
- (void) chatDidFailWithError:(NSError *)error {
    
    [self appendToChatLog:[NSString stringWithFormat:@"Chat error: %@", [error.userInfo objectForKey:@"NSLocalizedDescription"]]];
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


#pragma mark - Outbound chat messages & states


- (IBAction)sendButton_Touch:(id)sender {
    
    if ( self.chatTextBox.text.length > 0 ) {
        
        // Send the actual text message to the server.
        
        [self.chatClient sendChatText:self.chatTextBox.text
                           completion:^(NSString *response, NSError *error)
         {
             if( error ) {
                 NSLog(@"Error sending chat message: %@", error);
             }
         }];
        
        [self appendToChatLog:[NSString stringWithFormat:@"Me: %@", self.chatTextBox.text]];
        
        self.chatTextBox.text = @"";
        
        [self hideKeyboard];
    }
}


// Pass this function the string "composing" or "paused"
- (void)sendChatState:(ECSChatState)chatState {
    
    ECSChatState sendState = ECSChatStateUnknown;
    
    if ( !_userTyping && chatState == ECSChatStateComposing ) {
        
        _userTyping = YES;
        sendState = chatState;
        
    } else if ( _userTyping && chatState == ECSChatStateTypingPaused ) {
        
        _userTyping = NO;
        sendState = chatState;
        
    }
    
    if(sendState) {

        [self.chatClient sendChatState:sendState
                            completion:^(NSString *response, NSError *error)
         {
             if( error ) {
                 NSLog(@"Sending chat state error: %@", error);
             }
         }];
    }
}

- (IBAction)imageButton_Touch:(id)sender {
    
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Select image from"
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:@"From library",@"From camera", nil];
    
    [action showInView:self.view];
}



#pragma mark - ActionSheet delegates

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if( buttonIndex == 0 ) {
        
        UIImagePickerController *pickerView = [[UIImagePickerController alloc] init];
        pickerView.allowsEditing = YES;
        pickerView.delegate = self;
        [pickerView setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:pickerView animated:YES completion:nil];
        
        
    } else if( buttonIndex == 1 ) {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *pickerView =[[UIImagePickerController alloc]init];
            pickerView.allowsEditing = YES;
            pickerView.delegate = self;
            pickerView.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:pickerView animated:YES completion:nil];
        }
    }
}

#pragma mark - PickerDelegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self.chatClient sendMedia:info
                       notifyAgent:YES
                        completion:^(NSString *response, NSError *error)
     {
         if( error ) {
             
             NSLog(@"Error sending media: %@", error);
             
         } else {
             
             [self appendToChatLog:@"Media file sent successfully."];
             
         }
         
     }];
    
}

#pragma mark - Helper Functions (not directly SDK related)

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
    
    if( [textField.text containsString:@"reconnect"] ) {
        [self appendToChatLog:@"Executing manual reconnect command..."];
        [self.chatClient reconnect];
    } else if ( [textField.text containsString:@"disconnect"]) {
        [self appendToChatLog:@"Executing manual disconnect command..."];
        [self.chatClient disconnect];
    }    
    
    return [self hideKeyboard];
}

@end
