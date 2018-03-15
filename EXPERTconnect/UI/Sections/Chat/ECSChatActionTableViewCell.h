//
//  ECSChatURLTableViewCell.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatTableViewCell.h"

#import "ECSDynamicLabel.h"

typedef NS_ENUM(NSUInteger, ECSChatActionCellType)
{
    ECSChatActionCellTypeLink,
    ECSChatActionCellTypeForm,
    ECSChatActionCellTypeCallback,
    ECSChatActionCellTypeTextback,
};

@interface ECSChatActionTableViewCell : ECSChatTableViewCell

@property (strong, nonatomic) ECSDynamicLabel *messageLabel;
@property (strong, nonatomic) UIImageView *actionImageView;
@property (assign, nonatomic) ECSChatActionCellType actionCellType;

@end
