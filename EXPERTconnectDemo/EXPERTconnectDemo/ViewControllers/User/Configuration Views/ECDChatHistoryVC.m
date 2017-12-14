//
//  ECDChatHistoryVC.m
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 11/27/17.
//  Copyright © 2017 Humanify, Inc. All rights reserved.
//

#import "ECDChatHistoryVC.h"

@interface ECDChatHistoryVC ()

@end

@implementation ECDChatHistoryVC 

NSArray *historyMessages;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.historyTextView.text = @"Loading history data...";
    
    NSString *conversationID = [EXPERTconnect shared].urlSession.conversation.conversationID;

    [[EXPERTconnect shared] getTranscriptForConversation:conversationID withCompletion:^(NSArray *messages, NSError *error) {
        
        if( ! error ) {
            
            if( messages ) {
                
                // Happy path. We have history. Show it.
                historyMessages = messages;
                self.historyTextView.text = historyMessages.description;
                
            } else {
                
                // No history found.
                self.historyTextView.text = [NSString stringWithFormat:@"No chat history found for conversationID: %@ on journey: %@", conversationID, [EXPERTconnect shared].journeyID];
                
            }
            
        } else {
            
            // An error retrieving history. 
            self.historyTextView.text = [NSString stringWithFormat:@"Error loading history: %@", error];
            
        }
        
    }];
    
}

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
