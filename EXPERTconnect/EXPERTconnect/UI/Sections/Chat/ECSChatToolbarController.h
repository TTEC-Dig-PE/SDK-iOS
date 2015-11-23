//
//  ECSChatToolbar.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ECSChatToolbarDelegate <NSObject>

- (void)sendText:(NSString*)text;
- (void)sendChatState:(NSString *)chatState;
- (void)sendMedia:(NSDictionary*)mediaInfo;

@end

@interface ECSChatToolbarController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) id<ECSChatToolbarDelegate> delegate;

@property (assign, nonatomic) BOOL sendEnabled;

- (void)initializeSendState;

@end
