//
//  ECSChatWaitView.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ECSLoadingView.h"
#import "ECSDynamicLabel.h"

@interface ECSChatWaitView : UIView

@property (weak, nonatomic) IBOutlet ECSLoadingView *loadingView;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *titleLabel;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *subtitleLabel;
@end
