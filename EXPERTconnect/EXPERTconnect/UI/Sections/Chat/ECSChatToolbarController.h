//
//  ECSChatToolbar.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@protocol ECSChatToolbarDelegate <NSObject>

- (void)sendText:(NSString*)text;
- (void)sendChatState:(NSString *)chatState;
- (void)chatViewSendMedia:(NSDictionary*)mediaInfo;

@end

@interface ECSChatToolbarController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) id<ECSChatToolbarDelegate> delegate;

@property (assign, nonatomic) BOOL sendEnabled;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextToLeftEdge;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTextToPhotoButton;

- (void)initializeSendState;

@property (strong, nonatomic) NSTimer *myTimer;

@end
