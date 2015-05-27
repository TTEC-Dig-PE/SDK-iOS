//
//  ECSChatPhotoOptionsView.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Delegate methods to be called when a photo is selected.
 */
@protocol ECSPhotoOptionsDelegate <NSObject>

/**
 Called when media has been selected.
 
 @param mediaInfo the dictionary containing the media information to send.
 */
- (void)mediaSelected:(NSDictionary*)mediaInfo;

@end

/**
 View controller used in the chat view for presenting photo selectin options.
 */
@interface ECSChatPhotoOptionsViewController : UIViewController

// The delegate to call when an image is selected.
@property (weak, nonatomic) id<ECSPhotoOptionsDelegate> delegate;

@end
