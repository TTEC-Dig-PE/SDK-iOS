//
//  ECSCafeXVideoViewController.h
//  EXPERTconnect
//
//  Created by Nathan Keeney on 8/12/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSRootViewController.h"
#if !(TARGET_IPHONE_SIMULATOR)
//#import <ACBClientSDK/ACBUC.h>
#endif

@protocol CafeXVideoViewDelegate <NSObject>

- (void)CafeXViewDidAppear;
- (void)CafeXViewDidUnload;
- (void)CafeXViewDidMuteAudio:(BOOL)muted;
- (void)CafeXViewDidHideVideo:(BOOL)hidden;
- (void)CafexViewDidEndVideo;
- (void)CafeXViewDidMinimize;

@end

@interface ECSCafeXVideoViewController : ECSRootViewController

@property (weak, nonatomic) IBOutlet UIView *previewVideoView;
@property (weak, nonatomic) IBOutlet UIView *remoteVideoView;
@property (weak, nonatomic) id<CafeXVideoViewDelegate> delegate;

- (void) configWithVideo:(BOOL)showVideo andAudio:(BOOL)showAudio;
- (void) hideVideoPanels:(BOOL)hidden;
- (void) didHideRemoteVideo:(BOOL)hidden;

@end
