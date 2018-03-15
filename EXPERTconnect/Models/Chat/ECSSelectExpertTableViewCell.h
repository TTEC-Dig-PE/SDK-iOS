//
//  ECSSelectExpertTableViewCell.h
//  EXPERTconnect
//
//  Created by Mohammad Abdurraafay on 21/06/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECSCircleImageView;
@class ECSDynamicLabel;
@class ECSExpertDetail;

@protocol ECSSelectExpertTableViewCellDelegate <NSObject>

- (void)didSelectCallBackButton:(id)sender forExpert:(ECSExpertDetail *)expert;
- (void)didSelectChatButton:(id)sender forExpert:(ECSExpertDetail *)expert;
- (void)didSelectVideoChatButton:(id)sender forExpert:(ECSExpertDetail *)expert;
- (void)didSelectVoiceChatButton:(id)sender forExpert:(ECSExpertDetail *)expert;

@end

@interface ECSSelectExpertTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet ECSCircleImageView *profileImage;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *name;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *region;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *expertiese;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *interests;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *regionHeightConstraints;

@property (strong, nonatomic) IBOutlet UIView *firstLineView;

@property (weak, nonatomic) IBOutlet UIView *regionView;

@property (nonatomic, weak) id <ECSSelectExpertTableViewCellDelegate> selectExpertCellDelegate;

- (void)configureCellForActionType:(NSString *)actionType withExpert:(ECSExpertDetail *)expert;

- (void)configureConstraints;

@end
