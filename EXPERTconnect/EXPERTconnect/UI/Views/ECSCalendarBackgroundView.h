//
//  PMCalendarBackgroundView.h
//  PMCalendar
//
//  Created by Pavel Mazurin on 7/13/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSCalendarConstants.h"

/**
 * PMCalendarBackgroundView is an internal class.
 *
 * PMCalendarBackgroundView is a view which contains backgound image including an arrow.
 */
@interface ECSCalendarBackgroundView : UIView

@property (nonatomic, assign) ECSCalendarArrowDirection arrowDirection;

/**
 * Point which arrow points to.
 */
@property (nonatomic, assign) CGPoint arrowPosition;

@end
