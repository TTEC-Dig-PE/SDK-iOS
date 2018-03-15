//
//  ECSLoadingView.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 
 A custom loading indicator that follows the same API as UIActivityIndicator
 */

IB_DESIGNABLE
@interface ECSLoadingView : UIView

// Set to YES to hide this view when it is not animating
@property (assign, nonatomic) IBInspectable BOOL hidesWhenStopped;

/**
 Start animating the loading indicator
 */
- (void)startAnimating;

/**
 Stop animating the loading indicator.
 */
- (void)stopAnimating;

@end
