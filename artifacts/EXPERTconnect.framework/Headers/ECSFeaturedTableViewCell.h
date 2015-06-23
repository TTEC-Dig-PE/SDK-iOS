//
//  ECSFeaturedTableViewCell.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECSCircleImageView;
@class ECSDynamicLabel;

/**
 ECSFeaturedTableViewCell provides a table cell for displaying navigation sections that are
 specified as having the featured display type.
 */
@interface ECSFeaturedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *leftFeaturedView;
@property (weak, nonatomic) IBOutlet UIView *rightFeaturedView;
@property (weak, nonatomic) IBOutlet ECSCircleImageView *leftImageView;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *leftTitleLabel;
@property (weak, nonatomic) IBOutlet ECSCircleImageView *rightImageView;
@property (weak, nonatomic) IBOutlet ECSDynamicLabel *rightTitleLabel;

// The selected index when the cell is selected. (0 - left, 1 - right, -1 - no selection)
@property (readonly, nonatomic) NSInteger selectedIndex;

// Indicates if the left view is enabled.
@property (assign, nonatomic) BOOL leftViewEnabled;

// Indicates if the right view is enabled.
@property (assign, nonatomic) BOOL rightViewEnabled;

// The default background color
@property (strong, nonatomic) UIColor *featuredBackgroundColor;

// Color of the background when selected
@property (strong, nonatomic) UIColor *selectedBackgroundColor;

// Default title text color
@property (strong, nonatomic) UIColor *titleTextColor UI_APPEARANCE_SELECTOR;

// The title color when the cell is highlighted
@property (strong, nonatomic) UIColor *highlightedTitleTextColor UI_APPEARANCE_SELECTOR;

@end
