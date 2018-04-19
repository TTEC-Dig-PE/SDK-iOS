//
//  ECSChatToolbar.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@protocol ECSChatToolbarDelegate <NSObject>

// Instruct the chatView to send a text chat message.
- (void) sendText:(NSString*)text;

// Instruct the chatView to send a chat state update (typing, not typing)
- (void) sendChatState:(NSString *)chatState;

// Instruct the chatView to send a picture or video message.
- (void) chatViewSendMedia:(NSDictionary*)mediaInfo;

@end


@interface ECSChatToolbarController : UIViewController

@property (weak, nonatomic) id<ECSChatToolbarDelegate> delegate;

// Is message sending currently enabled or disabled? (Causes UI to show enabled or disabled buttons & textView)
@property (assign, nonatomic) BOOL sendEnabled;

// Initialize the toolbar for an active chat (called when chat connects with an agent)
- (void) initializeSendState;

// Resign first responder on the toolbar's textView.
- (void) hideKeyboard;

@end
