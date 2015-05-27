//
//  ECSSendConfirmationViewController.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECSSendConfirmationViewController;

/** 
 Delegate for notifying if a user has confirmed or cancelled sending an image.
 */
@protocol ECSSendConfirmationDelegate <NSObject>

/**
 Called when the user cancels sending the image
 
 @param controller the controller that the cancel orignates from.
 */
- (void)userCancelledSend:(ECSSendConfirmationViewController*)controller;

/**
 Called when the user confirms sending the image
 
 @param conroller the controller that the send originates from.
 */
- (void)userConfirmedSend:(ECSSendConfirmationViewController*)controller;

@end

/**
 ECSSendConfirmationViewConroller presents a preview view with an image and allows a user to 
 confirm or reject sending an item.
 */
@interface ECSSendConfirmationViewController : UIViewController

// The image to show in the preview.
@property (strong, nonatomic) UIImage *previewImage;

// Path to the media info for preview.
@property (strong, nonatomic) NSDictionary *mediaInfo;

// The delegate to call back on user selection.
@property (weak, nonatomic) id<ECSSendConfirmationDelegate> delegate;

@end
