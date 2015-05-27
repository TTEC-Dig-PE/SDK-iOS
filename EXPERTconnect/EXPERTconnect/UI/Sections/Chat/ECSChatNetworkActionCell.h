//
//  ECSChatNetworkActionCell.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECSDynamicLabel;
@class ECSButton;

@interface ECSChatNetworkActionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet ECSDynamicLabel *messageLabel;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *submessageLabel;
@property (weak, nonatomic) IBOutlet ECSButton *actionButton;

@end
