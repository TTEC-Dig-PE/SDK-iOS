//
//  PMDimmingView.m
//  PMCalendar
//
//  Created by Pavel Mazurin on 7/18/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import "ECSDimmingView.h"
#import "ECSCalendarConstants.h"
#import "ECSCalendarController.h"
#import "ECSCalendarHelpers.h"

@implementation ECSDimmingView

@synthesize controller = _controller;

- (id)initWithFrame:(CGRect)frame controller:(ECSCalendarController*)controller
{
    if (!(self = [super initWithFrame:frame])) 
    {
        return nil;
    }
    
    self.controller = controller;
    self.backgroundColor = UIColorMakeRGBA(0, 0, 0, 0.3);
    
    return self;
}

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if (![self.controller.delegate respondsToSelector:@selector(calendarControllerShouldDismissCalendar:)]
//        || [self.controller.delegate calendarControllerShouldDismissCalendar:self.controller])
//    {
//        [self.controller dismissCalendarAnimated:YES];
//    }
//}

@end
