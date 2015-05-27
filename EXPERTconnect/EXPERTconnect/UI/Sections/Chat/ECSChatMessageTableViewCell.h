//
//  ECSChatMessage.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatTableViewCell.h"

#import "ECSDynamicLabel.h"

@interface ECSChatMessageTableViewCell : ECSChatTableViewCell

@property (strong, nonatomic) ECSDynamicLabel *messageLabel;
@end
