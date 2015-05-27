//
//  ECSInlineFormTableViewCell.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatTableViewCell.h"

#import "ECSDynamicLabel.h"

@interface ECSInlineFormTableViewCell : ECSChatTableViewCell

@property (strong, nonatomic) ECSDynamicLabel *messageLabel;
@property (strong, nonatomic) ECSDynamicLabel *responseLabel;

@end
