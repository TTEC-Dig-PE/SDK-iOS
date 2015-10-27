//
//  PMCalendarController.m
//  PMCalendar
//
//  Created by Pavel Mazurin on 7/13/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import "ECSCalendarController.h"
#import "ECSCalendarBackgroundView.h"
#import "ECSCalendarView.h"
#import "ECSPeriod.h"
#import "NSDate+Helpers.h"
#import "ECSCalendarConstants.h"
#import "ECSCalendarHelpers.h"
#import "ECSDimmingView.h"
#import "ECSCalendarTheme.h"

NSString *kPMCalendarRedrawNotification = @"kPMCalendarRedrawNotification";

@interface ECSCalendarController ()

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIView *anchorView;
@property (nonatomic, assign) ECSCalendarArrowDirection savedPermittedArrowDirections;
@property (nonatomic, strong) UIView *calendarView;
@property (nonatomic, strong) ECSCalendarBackgroundView *backgroundView;
@property (nonatomic, strong) ECSCalendarView *digitsView;
@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) ECSCalendarArrowDirection calendarArrowDirection;
@property (nonatomic, assign) CGPoint savedArrowPosition;
@property (nonatomic, assign) UIDeviceOrientation currentOrientation;
@property (nonatomic, assign) CGRect initialFrame;
//@property (nonatomic, assign) CGSize initialSize;

@end

@implementation ECSCalendarController

@synthesize initialFrame = _initialFrame;
@synthesize position = _position;
@synthesize delegate = _delegate;

@dynamic period;
@dynamic allowedPeriod;
@dynamic mondayFirstDayOfWeek;
@dynamic allowsPeriodSelection;
@dynamic allowsLongPressMonthChange;

@synthesize calendarArrowDirection = _calendarArrowDirection;
@synthesize currentOrientation = _currentOrientation;
@synthesize calendarVisible = _calendarVisible;

@synthesize mainView = _mainView;
@synthesize anchorView = _anchorView;
@synthesize savedPermittedArrowDirections = _savedPermittedArrowDirections;
@synthesize calendarView = _calendarView;
@synthesize backgroundView = _backgroundView;
@synthesize digitsView = _digitsView;
@synthesize size = _size;
@synthesize savedArrowPosition = _savedArrowPosition;

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - object initializers -

- (void) initializeWithSize:(CGSize) size
{
//    self.initialSize = size;
    CGSize arrowSize = kPMThemeArrowSize;
    CGSize outerPadding = kPMThemeOuterPadding;
    self.calendarArrowDirection = PMCalendarArrowDirectionUnknown;
    
    self.initialFrame = CGRectMake(0
                                 , 0
                                 , size.width + kPMThemeShadowPadding.left + kPMThemeShadowPadding.right
                                 , size.height + kPMThemeShadowPadding.top + kPMThemeShadowPadding.bottom);
    self.calendarView = [[UIView alloc] initWithFrame:_initialFrame];
    self.calendarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    //Make insets from two sides of a calendar to have place for arrow
    CGRect calendarRectWithArrowInsets = CGRectMake(0, 0
                                                    , _initialFrame.size.width + arrowSize.height
                                                    , _initialFrame.size.height + arrowSize.height);
    self.mainView = [[UIView alloc] initWithFrame:calendarRectWithArrowInsets];

    self.backgroundView = [[ECSCalendarBackgroundView alloc] initWithFrame:CGRectInset(calendarRectWithArrowInsets
                                                                                      , outerPadding.width
                                                                                      , outerPadding.height)];
    self.backgroundView.clipsToBounds = NO;
    [self.mainView addSubview:self.backgroundView];
    
    self.digitsView = [[ECSCalendarView alloc] initWithFrame:UIEdgeInsetsInsetRect(CGRectInset(_initialFrame
                                                                                              , kPMThemeInnerPadding.width
                                                                                              , kPMThemeInnerPadding.height)
                                                                                  , kPMThemeShadowPadding)];
    self.digitsView.delegate = self;
    
//    self.calendarView.backgroundColor = [UIColor blueColor];
//    self.digitsView.backgroundColor = [UIColor blueColor];
//    self.mainView.backgroundColor = [UIColor blueColor];
    [self.calendarView addSubview:self.digitsView];
    [self.mainView addSubview:self.calendarView];
    
    self.allowsPeriodSelection = YES;
    self.allowsLongPressMonthChange = YES;
}

- (id) initWithSize:(CGSize) size
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    if (![ECSThemeEngine sharedInstance].themeName)
    {
        [ECSThemeEngine sharedInstance].themeName = @"default";
    }
    [self initializeWithSize: size];
    
    return self;
}

- (id) init
{
    return [self initWithSize: [ECSThemeEngine sharedInstance].defaultSize];
}

- (id) initWithThemeName:(NSString *) themeName
{
    [ECSThemeEngine sharedInstance].themeName = themeName;
    return [self init];
}

- (id) initWithThemeName:(NSString *) themeName andSize:(CGSize) size
{
    [ECSThemeEngine sharedInstance].themeName = themeName;
    return [self initWithSize:size];
}

#pragma mark - rotation handling -

- (void)didRotate:(NSNotification *) notice
{
//    self.anchorView.hidden = YES;
    if (self.anchorView)
    {
        CGRect rectInAppWindow = [self.view convertRect:self.anchorView.frame
                                               fromView:self.anchorView.superview];

        [UIView animateWithDuration:0.3
                         animations:^{
                             [self adjustCalendarPositionForPermittedArrowDirections:_savedPermittedArrowDirections
                                                                   arrowPointsToRect:rectInAppWindow];
                         }];
    }
}

#pragma mark - controller presenting methods -

- (void) adjustCalendarPositionForPermittedArrowDirections:(ECSCalendarArrowDirection) arrowDirections
                                         arrowPointsToRect:(CGRect)rect
{
    CGSize arrowSize = kPMThemeArrowSize;

    if (arrowDirections & PMCalendarArrowDirectionUp)
    {
        if ((CGRectGetMaxY(rect) + self.size.height + arrowSize.height <= self.view.bounds.size.height)
            && (CGRectGetMidX(rect) >= (arrowSize.width / 2 +  kPMThemeCornerRadius + kPMThemeShadowPadding.left))
            && (CGRectGetMidX(rect) <= (self.view.bounds.size.width - arrowSize.width / 2 -  kPMThemeCornerRadius - kPMThemeShadowPadding.right)))
        {
            self.calendarArrowDirection = PMCalendarArrowDirectionUp;
        }
    }
    
    if ((_calendarArrowDirection == PMCalendarArrowDirectionUnknown) 
        && (arrowDirections & PMCalendarArrowDirectionLeft))
    {
        if ((CGRectGetMidX(rect) + self.size.width + arrowSize.height <= self.view.bounds.size.width)
            && (CGRectGetMidY(rect) >= (arrowSize.width / 2 +  kPMThemeCornerRadius + kPMThemeShadowPadding.top))
            && (CGRectGetMidY(rect) <= (self.view.bounds.size.height - arrowSize.width / 2 -  kPMThemeCornerRadius - kPMThemeShadowPadding.bottom)))
            
        {
            self.calendarArrowDirection = PMCalendarArrowDirectionLeft;
        }
    }
    
    if ((_calendarArrowDirection == PMCalendarArrowDirectionUnknown) 
        && (arrowDirections & PMCalendarArrowDirectionDown))
    {
        if ((CGRectGetMidY(rect) - self.size.height - arrowSize.height >= 0)
            && (CGRectGetMidX(rect) >= (arrowSize.width / 2 +  kPMThemeCornerRadius + kPMThemeShadowPadding.left))
            && (CGRectGetMidX(rect) <= (self.view.bounds.size.width - arrowSize.width / 2 -  kPMThemeCornerRadius - kPMThemeShadowPadding.right)))
        {
            self.calendarArrowDirection = PMCalendarArrowDirectionDown;
        }
    }
    
    if ((_calendarArrowDirection == PMCalendarArrowDirectionUnknown) 
        && (arrowDirections & PMCalendarArrowDirectionRight))
    {
        if ((CGRectGetMidX(rect) - self.size.width - arrowSize.height >= 0)
            && (CGRectGetMidY(rect) >= (arrowSize.width / 2 +  kPMThemeCornerRadius + kPMThemeShadowPadding.top))
            && (CGRectGetMidY(rect) <= (self.view.bounds.size.height - arrowSize.width / 2 -  kPMThemeCornerRadius - kPMThemeShadowPadding.bottom)))
        {
            self.calendarArrowDirection = PMCalendarArrowDirectionRight;
        }
    }
    
    if (_calendarArrowDirection == PMCalendarArrowDirectionUnknown) // nothing suits
    {
        // TODO: check rect's quad and pick direction automatically
        self.calendarArrowDirection = PMCalendarArrowDirectionUp;
    }
    
    CGRect calendarFrame = self.mainView.frame;
    CGRect frm = CGRectMake(0
                            , 0
                            , calendarFrame.size.width - arrowSize.height
                            , calendarFrame.size.height - arrowSize.height);
    CGPoint arrowPosition = CGPointZero;
    CGPoint arrowOffset = CGPointZero;
    
    switch (_calendarArrowDirection)
    {
        case PMCalendarArrowDirectionUp:
        case PMCalendarArrowDirectionDown:
            arrowPosition.x = CGRectGetMidX(rect) - kPMThemeShadowPadding.right;
            
            if (arrowPosition.x < frm.size.width / 2)
            {
                calendarFrame.origin.x = 0;
            }
            else if (arrowPosition.x > self.view.bounds.size.width - frm.size.width / 2)
            {
                calendarFrame.origin.x = self.view.bounds.size.width - frm.size.width - kPMThemeShadowPadding.right;
            }
            else
            {
                calendarFrame.origin.x = arrowPosition.x - frm.size.width / 2 + kPMThemeShadowPadding.left;
            }
            
            if (_calendarArrowDirection == PMCalendarArrowDirectionUp)
            {
                arrowOffset.y = arrowSize.height;
                calendarFrame.origin.y = CGRectGetMaxY(rect) - kPMThemeShadowPadding.top;
            }
            else 
            {
                calendarFrame.origin.y = CGRectGetMinY(rect) - self.backgroundView.frame.size.height + kPMThemeShadowPadding.bottom;
            }
            
            break;
        case PMCalendarArrowDirectionLeft:
        case PMCalendarArrowDirectionRight:
            arrowPosition.y = CGRectGetMidY(rect) - kPMThemeShadowPadding.top;
            
            if (arrowPosition.y < frm.size.height / 2)
            {
                calendarFrame.origin.y = 0;
            }
            else if (arrowPosition.y > self.view.bounds.size.height - frm.size.height / 2)
            {
                calendarFrame.origin.y = self.view.bounds.size.height - frm.size.height;
            }
            else
            {
                calendarFrame.origin.y = arrowPosition.y - calendarFrame.size.height / 2 + arrowSize.height;
            }
            
            if (_calendarArrowDirection == PMCalendarArrowDirectionLeft)
            {
                arrowOffset.x = arrowSize.height;
                calendarFrame.origin.x = CGRectGetMaxX(rect) - kPMThemeShadowPadding.left;
            }
            else 
            {
                calendarFrame.origin.x = CGRectGetMinX(rect) - calendarFrame.size.width + kPMThemeShadowPadding.right;
            }
            break;
        default:
            NSAssert(NO, @"arrow direction is not set! JACKPOT!! :)");
            break;
    }
    self.mainView.frame = calendarFrame;
    frm.origin = CGPointOffsetByPoint(frm.origin, arrowOffset);
    self.calendarView.frame = frm;
    
    arrowPosition = [self.view convertPoint:arrowPosition toView:self.mainView];
    
    if ((_calendarArrowDirection == PMCalendarArrowDirectionUp)
        || (_calendarArrowDirection == PMCalendarArrowDirectionDown))
    {
        arrowPosition.x = MIN(arrowPosition.x, frm.size.width - arrowSize.width / 2 -  kPMThemeCornerRadius);
        arrowPosition.x = MAX(arrowPosition.x, arrowSize.width / 2 +  kPMThemeCornerRadius);
    }
    else if ((_calendarArrowDirection == PMCalendarArrowDirectionRight)
             || (_calendarArrowDirection == PMCalendarArrowDirectionLeft)) 
    {
        arrowPosition.y = MIN(arrowPosition.y, frm.size.height - arrowSize.width / 2 -  kPMThemeCornerRadius);
        arrowPosition.y = MAX(arrowPosition.y, arrowSize.width / 2 +  kPMThemeCornerRadius);
    }
    
    self.backgroundView.arrowPosition = arrowPosition;
    self.savedArrowPosition = arrowPosition;
}


- (void)presentCalendarFromRect:(CGRect) rect
                         inView:(UIView *) view
       permittedArrowDirections:(ECSCalendarArrowDirection) arrowDirections
                      isPopover:(BOOL) isPopover
                       animated:(BOOL) animated
{
    if (!isPopover)
    {
        self.view = self.mainView;
    }
    else
    {
        self.view = [[ECSDimmingView alloc] initWithFrame:view.bounds
                                              controller:self];
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.mainView];
    }

    [view addSubview:self.view];

    CGRect rectInAppWindow = [self.view convertRect:rect fromView:view];
    [self adjustCalendarPositionForPermittedArrowDirections:arrowDirections
                                          arrowPointsToRect:rectInAppWindow];
    self.initialFrame = self.mainView.frame;//CGRectMake(self.mainView.frame.origin.x, self.mainView.frame.origin.y, self.initialSize.width, self.initialSize.height);
    [self fullRedraw];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotate:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    if (animated)
    {
        self.mainView.alpha = 0;
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.mainView.alpha = 1;
                         }];
    }

    if (!_digitsView.period)
    {
        self.period = [ECSPeriod oneDayPeriodWithDate:[NSDate date]];
    }
    
    _calendarVisible = YES;
}

- (void)presentCalendarFromView:(UIView *) anchorView
       permittedArrowDirections:(ECSCalendarArrowDirection) arrowDirections
                      isPopover:(BOOL) isPopover
                       animated:(BOOL) animated
{
    self.anchorView = anchorView;
    self.savedPermittedArrowDirections = arrowDirections;
    
    [self presentCalendarFromRect:anchorView.frame
                           inView:self.anchorView.superview
         permittedArrowDirections:arrowDirections
                        isPopover:isPopover
                         animated:animated];
}

- (void) dismissCalendarAnimated:(BOOL) animated
{
    self.view.alpha = 1;
    void (^completionBlock)(BOOL) = ^(BOOL finished){
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.view removeFromSuperview];
        _calendarVisible = NO;
        if ([self.delegate respondsToSelector:@selector(calendarControllerDidDismissCalendar:)])
        {
            [self.delegate calendarControllerDidDismissCalendar:self];
        }
    };
    
    
    if (animated)
    {
        [UIView animateWithDuration:0.2 
                         animations:^{
                             self.view.alpha = 0;
                             self.mainView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                         }
                         completion:completionBlock];
    }
    else
    {
        completionBlock(YES);
    }
}

- (void) fullRedraw
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kPMCalendarRedrawNotification 
                                                        object:nil];
}

- (void)setCalendarArrowDirection:(ECSCalendarArrowDirection)calendarArrowDirection
{
    self.backgroundView.arrowDirection = calendarArrowDirection;
    _calendarArrowDirection = calendarArrowDirection;
}

#pragma mark - date/period management -

- (BOOL)mondayFirstDayOfWeek
{
    return self.digitsView.mondayFirstDayOfWeek;
}

- (void)setMondayFirstDayOfWeek:(BOOL)mondayFirstDayOfWeek
{
    self.digitsView.mondayFirstDayOfWeek = mondayFirstDayOfWeek;
}

- (BOOL)showOnlyCurrentMonth
{
    return  self.digitsView.showOnlyCurrentMonth;
}

- (void)setShowOnlyCurrentMonth:(BOOL)showOnlyCurrentMonth
{
    self.digitsView.showOnlyCurrentMonth = showOnlyCurrentMonth;
    [self.digitsView setDisplayCurrentMonthOnly];
}

- (BOOL)allowsPeriodSelection
{
    return self.digitsView.allowsPeriodSelection;
}

- (void)setAllowsPeriodSelection:(BOOL)allowsPeriodSelection
{
    self.digitsView.allowsPeriodSelection = allowsPeriodSelection;
}

- (BOOL)allowsLongPressMonthChange
{
    return self.digitsView.allowsLongPressMonthChange;
}

- (void)setAllowsLongPressMonthChange:(BOOL)allowsLongPressMonthChange
{
    self.digitsView.allowsLongPressMonthChange = allowsLongPressMonthChange;
}

- (ECSPeriod *) period
{
    return self.digitsView.period;
}

- (void) setPeriod:(ECSPeriod *) period
{
    self.digitsView.period = period;
    self.digitsView.currentDate = period.startDate;
}

- (ECSPeriod *) allowedPeriod
{
    return self.digitsView.allowedPeriod;
}

- (void) setAllowedPeriod:(ECSPeriod *) allowedPeriod
{
    self.digitsView.allowedPeriod = allowedPeriod;
}

#pragma mark - PMdigitsViewDelegate methods -

- (void) periodChanged:(ECSPeriod *) newPeriod
{
    if ([self.delegate respondsToSelector:@selector(calendarController:didChangePeriod:)])
    {
        [self.delegate calendarController:self didChangePeriod:[newPeriod normalizedPeriod]];
    }
}

- (void) currentDateChanged:(NSDate *) currentDate
{
    CGSize arrowSize = kPMThemeArrowSize;
    CGSize outerPadding = kPMThemeOuterPadding;
    
	int numDaysInMonth      = (int)[currentDate numberOfDaysInMonth];
    NSInteger monthStartDay = [[currentDate monthStartDate] weekday];
    numDaysInMonth         += (monthStartDay + (self.digitsView.mondayFirstDayOfWeek?5:6)) % 7;
    CGFloat height          = _initialFrame.size.height - outerPadding.height * 2 - arrowSize.height;
    CGFloat vDiff           = (height - kPMThemeHeaderHeight - kPMThemeInnerPadding.height * 2 - kPMThemeShadowPadding.bottom - kPMThemeShadowPadding.top) / ((kPMThemeDayTitlesInHeader)?6:7);
    CGRect frm              = CGRectInset(_initialFrame, outerPadding.width, outerPadding.height);
    int numberOfRows        = ceil((CGFloat)numDaysInMonth / 7);
    frm.size.height         = ceil(((numberOfRows + ((kPMThemeDayTitlesInHeader)?0:1)) * vDiff) + kPMThemeHeaderHeight + kPMThemeInnerPadding.height * 2 + arrowSize.height) + kPMThemeShadowPadding.bottom + kPMThemeShadowPadding.top;
    
    
    if (self.calendarArrowDirection == PMCalendarArrowDirectionDown)
    {
        frm.origin.y += _initialFrame.size.height - frm.size.height;
    }
    
    // TODO: recalculate arrow position for left & right
//    else if ((self.calendarArrowDirection == PMCalendarArrowDirectionLeft) 
//             || (self.calendarArrowDirection == PMCalendarArrowDirectionRight))
//    {
//        frm.origin.y = (self.mainView.bounds.size.height - frm.size.height) / 2;
//        self.backgroundView.arrowPosition = 
//    }
    CGRect rect = [UIScreen mainScreen].bounds;
    CGRect frame1 = CGRectMake(rect.size.width/2-frm.size.width/2, frm.origin.y, frm.size.width, frm.size.height);
    self.mainView.frame = frame1;
    [self fullRedraw];
}

- (void)setSize:(CGSize)size
{
    CGRect frm = self.mainView.frame;
    frm.size = size;
    self.mainView.frame = frm;
    [self fullRedraw];
}

- (CGSize)size
{
    return self.mainView.frame.size;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Deprecated methods -

- (void) presentCalendarFromRect:(CGRect) rect
                          inView:(UIView *) view
        permittedArrowDirections:(ECSCalendarArrowDirection) arrowDirections
                        animated:(BOOL) animated
{
    [self presentCalendarFromRect:rect
                           inView:view
         permittedArrowDirections:arrowDirections
                        isPopover:YES
                         animated:animated];
}

- (void) presentCalendarFromView:(UIView *) anchorView
        permittedArrowDirections:(ECSCalendarArrowDirection) arrowDirections
                        animated:(BOOL) animated
{
    [self presentCalendarFromView:anchorView
         permittedArrowDirections:arrowDirections
                        isPopover:YES
                         animated:animated];
}

@end
