//
//  ECSCafeXVideoViewController.h
//  EXPERTconnect
//
//  Created by Nathan Keeney on 8/12/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#ifndef EXPERTconnect_ECSCafeXVideoViewController_h
#define EXPERTconnect_ECSCafeXVideoViewController_h

#import <UIKit/UIKit.h>
#import <ACBClientSDK/ACBUC.h>

@protocol CafeXVideoViewDelegate <NSObject>

- (void)CafeXViewDidAppear;
- (void)CafeXViewDidUnload;

@end

@interface ECSCafeXVideoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *previewVideoView;
@property (weak, nonatomic) IBOutlet UIView *remoteVideoView;
@property (weak, nonatomic) id<CafeXVideoViewDelegate> delegate;

@end

#endif
