//
//  ECDSimpleChatViewController.m
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 12/15/15.
//  Copyright © 2015 Humanify, Inc. All rights reserved.
//

#import "ECDSimpleChatViewController.h"

@interface ECDSimpleChatViewController () <ECSStompChatDelegate>

@property (strong, nonatomic) ECSStompChatClient *chatClient;
//@property (nonatomic, strong) ECSActionType *actionType;

@end

@implementation ECDSimpleChatViewController

bool _userTyping;

#pragma mark - Base UIViewController Loading / Init
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _userTyping = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    if (!self.chatClient)
    {
        self.chatClient = [ECSStompChatClient new];
        self.chatClient.delegate = self;
        
        ECSVideoChatActionType *chatAction = [ECSVideoChatActionType new];
        chatAction.actionId = @"";
        chatAction.agentSkill = @"CE_Mobile_Chat";
        chatAction.displayName = @"SimpleChatMike";
        chatAction.shouldTakeSurvey = YES;
        chatAction.journeybegin = [NSNumber numberWithInt:1];
        
        [self.chatClient setupChatClientWithActionType:chatAction];
    }
}

#pragma mark - StompClient Callbacks
- (void)chatClientDidConnect:(ECSStompChatClient *)stompClient {
    // We are now connected to an agent.
    NSLog(@"Chat session initiated (waiting for agent to answer...)");
}

- (void)chatClient:(ECSStompChatClient *)stompClient didReceiveMessage:(ECSChatMessage *)message {
    NSLog(@"Received message: %@", message);
    
    if ([message isKindOfClass:[ECSChatAddParticipantMessage class]])
    {
        NSLog(@"A new participant has joined the chat!");
        
    } else {
    
        if (message.fromAgent) {
            // This is a message from the agent.
        } else {
            // This is a message from the client (user).
        }
    }
}

- (void)chatClientAgentDidAnswer:(ECSStompChatClient *)stompClient {
    NSLog(@"Agent answered!");
}

- (void)voiceCallbackDidAnswer:(ECSStompChatClient *)stompClient {
    NSLog(@"An agent is calling you back.");
}

- (void)chatClientDisconnected:(ECSStompChatClient *)stompClient {
    NSLog(@"Chat client was disconnected.");
}

- (void)chatClient:(ECSStompChatClient *)stompClient didAddChannelWithMessage:(ECSChatAddChannelMessage *)message {
    NSLog(@"Channel added with message: %@", message);
}

- (void)chatClient:(ECSStompChatClient *)stompClient didUpdateEstimatedWait:(NSInteger)waitTime {
    NSLog(@"Updated estimated wait time is %ld", (long)waitTime);
}

- (void)chatClient:(ECSStompChatClient *)stompClient didReceiveChatStateMessage:(ECSChatStateMessage *)state {
    
    if(state.object && [state.type isEqualToString:@"artifact"]) {
        // We have an incoming document from the server.
    }
    
    if (state.chatState == ECSChatStateComposing) {
        NSLog(@"Agent is composing a message...");
    }
}

- (void)chatClient:(ECSStompChatClient *)stompClient didFailWithError:(NSError *)error {
    NSLog(@"Chat failure. Error: %@", error);
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
    
    ECSURLSessionManager *urlSession = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
    
    [urlSession sendChatMessage:message.body
                           from:message.from
                        channel:message.channelId
                     completion:^(NSString *response, NSError *error)
    {
        if(!error) {
            NSLog(@"Message sent to server!");
        } else {
            NSLog(@"Error sending chat message: %@", error);
        }
    }];
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
