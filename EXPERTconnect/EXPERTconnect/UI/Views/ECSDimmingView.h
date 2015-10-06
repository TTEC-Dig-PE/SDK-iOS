//
//  PMDimmingView.h
//  PMCalendar
//
//  Created by Pavel Mazurin on 7/18/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ECSCalendarController;

/**
 * PMDimmingView is an internal class.
 *
 * PMDimmingView is a view which is shown below the calendar. It catches  
 * user interaction outside of the calendar and dismisses calendar. 
 */
@interface ECSDimmingView : UIView

@property (nonatomic, strong) ECSCalendarController *controller;

- (id)initWithFrame:(CGRect)frame controller:(ECSCalendarController*)controller;

@end
