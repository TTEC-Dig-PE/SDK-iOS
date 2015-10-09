//
//  ECDCalendarViewController.m
//  EXPERTconnectDemo
//
//  Created by AgilizTech Mac on 01/10/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECDCalendarViewController.h"

@interface ECDCalendarViewController ()

@property (weak, nonatomic) IBOutlet UIView *dateRangeView;
@property (weak, nonatomic) IBOutlet UILabel *calendarFromLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateRangeLabel;
@property (nonatomic, strong) ECSCalendarController *calendarControl;

@end

@implementation ECDCalendarViewController

static NSString *const dateFormat = @"dd-MM-yyyy";

@synthesize calendarControl;
@synthesize calendarFromLabel;
@synthesize dateRangeView;
@synthesize dateRangeLabel;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    BOOL isPopover = YES;
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.calendarControl = [[ECSCalendarController alloc] initWithThemeName:@"CalendarConfigiPad"];
    }
    else
    {
        self.calendarControl = [[ECSCalendarController alloc] initWithThemeName:@"CalendarConfigiPhone"];
    }
    self.calendarControl.delegate = self;
    self.calendarControl.mondayFirstDayOfWeek = NO;
    
    [self.calendarControl presentCalendarFromView:calendarFromLabel
              permittedArrowDirections:PMCalendarArrowDirectionAny
                             isPopover:isPopover
                              animated:YES];
    
    self.calendarControl.period = [ECSPeriod oneDayPeriodWithDate:[NSDate date]];
    [self calendarController:calendarControl didChangePeriod:calendarControl.period];
    
    self.calendarControl.view.backgroundColor = [UIColor clearColor];

    // Do any additional setup after loading the view from its nib.
}


- (void)calendarController:(ECSCalendarController *)calendarController didChangePeriod:(ECSPeriod *)newPeriod
{
    if(![[newPeriod.startDate dateStringWithFormat:dateFormat] isEqualToString:[newPeriod.endDate dateStringWithFormat:dateFormat]])
    {
        dateRangeLabel.text = [NSString stringWithFormat:@"%@ - %@"
                          , [newPeriod.startDate dateStringWithFormat:dateFormat]
                          , [newPeriod.endDate dateStringWithFormat:dateFormat]];
    }
    else
    {
        dateRangeLabel.text = [NSString stringWithFormat:@"%@", [newPeriod.endDate dateStringWithFormat:dateFormat]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
