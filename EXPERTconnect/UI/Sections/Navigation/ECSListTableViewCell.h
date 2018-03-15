//
//  ECSListTableViewCell.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECSCircleImageView;
@class ECSDynamicLabel;

/**
 Table view cell used to present the items in a list style navigation section
 */
@interface ECSListTableViewCell : UITableViewCell

// Left image view
@property (weak, nonatomic) IBOutlet ECSCircleImageView *circleImageView;

// Title for the table cell
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *titleLabel;

// Set to NO to hide the horizontal separator
@property (assign, nonatomic) BOOL horizontalSeparatorVisible;

// Set to NO to mark an item as disabled.
@property (assign, nonatomic) BOOL enabled;

@end
