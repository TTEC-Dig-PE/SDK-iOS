//
//  ECDSimpleChatViewController.m
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 12/15/15.
//  Copyright © 2015 Humanify, Inc. All rights reserved.
//

#import "ECDSimpleCallbackVC.h"
#import <EXPERTconnect/EXPERTconnect.h>

@interface ECDSimpleCallbackVC () <ECSStompChatDelegate>

@property (strong, nonatomic) ECSStompChatClient *callbackClient;

@property (assign, nonatomic) BOOL displaySMSOption;
@property (strong, nonatomic) NSNumber *waitTime;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *callID;
@property (strong, nonatomic) NSString *closeChannelURL;
@property (strong, nonatomic) NSString *actionId;
@end

@implementation ECDSimpleCallbackVC

bool _waitingForCall;
//CGPoint _originalCenter;

#pragma mark - Base UIViewController Loading / Init
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _waitingForCall = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    
    // Let's use this call to pre-emptively check agent availability and estimated wait time.
    // We will display this result in a text box. This could also be used to choose whether or not to
    // Show the user a chat icon or a "contact us later" style of communication (say after business hours).
    
    // Initialize the chat object
    self.callbackClient = [ECSStompChatClient new];
    self.callbackClient.delegate = self;
    
    self.lblEstimatedWait.text = @"Determining...";
    
    [[EXPERTconnect shared] getDetailsForExpertSkill:self.callbackSkill
                                          completion:^(ECSSkillDetail *details, NSError *error)
    {
          if ( !details || details.estWait < 0 ) {
              
              self.lblEstimatedWait.text = @"No agents available.";
              
          } else {
              
              self.lblEstimatedWait.text = [NSString stringWithFormat:@"%d minute(s)", details.estWait];
              
          }
      }];
    
    // Check to see if a call is already queued or pending. If so, display the cancel button.
    if (self.callbackClient.currentChannelId) {
        
        [[[EXPERTconnect shared] urlSession] getDetailsForChannelId:self.callbackClient.currentChannelId
                                                         completion:^(ECSChannelConfiguration *response, NSError *error)
         {
             /*
              States:    ECSChannelStateConnected,
              ECSChannelStateDisconnected,
              ECSChannelStateFailed,
              ECSChannelStateNotify,
              ECSChannelStatePending,
              ECSChannelStateQueued,
              ECSChannelStateTimeout
              */
             if ([response channelState] == ECSChannelStateQueued ||
                 [response channelState] == ECSChannelStatePending)
             {
                 [self.btnCallback setTitle:@"Cancel Callback" forState:UIControlStateNormal];
                 _waitingForCall = YES;
             }
         }];
    }
    
    [super viewWillAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated {
    //[self.chatClient disconnect];
    
    [self appendToChatLog:[NSString stringWithFormat:@"Starting callback with skill: %@", self.callbackSkill]];
}

#pragma mark - View Interactive Objects

- (IBAction)btnCallBack_Touch:(id)sender {
    
    if (_waitingForCall) {
        // This is now the "Cancel callback" button.
        [self cancelCallback];
        
    } else {
    
        [self.btnCallback setTitle:@"Processing..." forState:UIControlStateDisabled];
        
//        self.btnCallback.enabled = NO;
        
        [self appendToChatLog:@"Requesting callback from server..."];
        
        [self startCallback];
    }
}

- (void) startCallback {
    
//    ECSActionType *actionType = [[ECSActionType alloc] init];
    
//    actionType.journeybegin = [NSNumber numberWithBool:NO];
    
    NSString *strPhone = [[self.phoneTextField.text
                           componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                          componentsJoinedByString:@""];
    
    [self.callbackClient startVoiceCallbackWithSkill:self.callbackSkill
                                             subject:@"Voice Callback Help"
                                         phoneNumber:strPhone
                                            priority:kECSChatPriorityUseServerDefault
                                          dataFields:nil];
}

#pragma mark - Voice callback functions

- (void)cancelCallback {
    
    [self.callbackClient disconnect];
    [self performCancelUI];
    
}

-(void) performCancelUI {
    
    NSLog(@"User cancelled callback.");
    
    [self appendToChatLog:@"User cancelled callback."];
    
    [self.btnCallback setTitle:@"Request Callback" forState:UIControlStateNormal];
    
    _waitingForCall = NO;
    
}

#pragma mark - StompClient Callbacks

- (void)chatDidConnect {
    // We are now connected to an agent.
    //NSLog(@"Chat session initiated (waiting for agent to answer...)");
    [self appendToChatLog:@"Chat session initiated. Waiting for agent to answer..."];
    
    [self.btnCallback setTitle:@"Cancel Callback" forState:UIControlStateNormal];
    _waitingForCall = YES;
}

- (void) chatAgentDidAnswer {
    
    //NSLog(@"An agent is calling you back.");
    [self appendToChatLog:@"An agent is calling you back."];
    
    [self.btnCallback setTitle:@"End Callback" forState:UIControlStateNormal];
}

// This is fired when the call has ended.
- (void)chatDisconnectedWithMessage:(ECSChannelStateMessage *)message {
    
    //This is where you might display a post-chat survey or display a post-call screen (aka "Thanks for the call", etc.)
    
    [self appendToChatLog:@"Call has ended."];
    _waitingForCall = NO;
    [self.btnCallback setTitle:@"Request Callback" forState:UIControlStateNormal];
}

- (void) chatDidFailWithError:(NSError *)error {
    
    //NSLog(@"Chat failure. Error: %@", error);
    [self appendToChatLog:[NSString stringWithFormat:@"Chat error: %@", [error.userInfo objectForKey:@"NSLocalizedDescription"]]];
    _waitingForCall = NO;
    [self.btnCallback setTitle:@"Request Callback" forState:UIControlStateNormal];
}

#pragma mark - Helper Functions

- (void) appendToChatLog:(NSString *)text
{
    self.logTextView.text = [NSString stringWithFormat:@"%@\n%@", self.logTextView.text, text];
}


#pragma mark - Base UIViewController Functions
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

