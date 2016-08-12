//
//  ECSChatLogsViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatLogsViewController.h"

#import "ECSChatHistoryResponse.h"
#import "ECSChatViewController.h"
#import "ECSHistoryList.h"
#import "ECSHistoryListItem.h"
#import "ECSInjector.h"
#import "ECSListTableViewCell.h"
#import "ECSLocalization.h"
#import "ECSSectionHeader.h"
#import "ECSTheme.h"
#import "ECSUtilities.h"
#import "ECSURLSessionManager.h"

#import "UIView+ECSNibLoading.h"
#import "UIViewController+ECSNibLoading.h"

static NSDateFormatter *sectionTitleDateFormatter;

@interface ECSChatLogsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *historyList;
@property (strong, nonatomic) NSMutableArray *historyDayList;
@end

@implementation ECSChatLogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sectionTitleDateFormatter = [[NSDateFormatter alloc] init];
    //sectionTitleDateFormatter.dateFormat = @"MMMM dd, yyyy";
    sectionTitleDateFormatter.dateStyle = NSDateFormatterLongStyle;
    self.navigationItem.title = ECSLocalizedString(ECSLocalizeChatLogs, @"Chat Logs");
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [self.tableView registerNib:[ECSListTableViewCell ecs_nib] forCellReuseIdentifier:@"Cell"];
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    self.view.backgroundColor = theme.primaryBackgroundColor;
    self.tableView.backgroundColor = theme.primaryBackgroundColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!self.historyList || self.historyList.count == 0)
    {
        [self setLoadingIndicatorVisible:YES];
        
        ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
            
        __weak typeof(self) weakSelf = self;
        
        [sessionManager getChatHistoryWithCompletion:^(ECSHistoryList *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (response.journeys)
                {
                    weakSelf.historyList = response.journeys;
                    weakSelf.historyDayList = [NSMutableArray new];
                    ECSHistoryListItem *previousListItem = nil;
                    NSMutableArray *currentDayGroup = nil;
                    
                    NSArray *sortedHistory = response.journeys;
                    sortedHistory = [sortedHistory sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(ECSHistoryListItem* obj1, ECSHistoryListItem* obj2) {
                        
                        if ([obj1.date compare:obj2.date] == NSOrderedAscending)
                        {
                            return NSOrderedDescending;
                        }
                        else
                        {
                            return NSOrderedAscending;
                        }
                    }];
                    
                    for (ECSHistoryListItem *listItem in sortedHistory)
                    {
                        if (previousListItem &&
                            currentDayGroup &&
                            [[NSCalendar currentCalendar] isDate:listItem.date inSameDayAsDate:previousListItem.date])
                        {
                            [currentDayGroup addObject:listItem];
                        }
                        else
                        {
                            currentDayGroup = [[NSMutableArray alloc] initWithArray:@[listItem]];
                            [weakSelf.historyDayList addObject:currentDayGroup];
                        }
                        
                        previousListItem = listItem;
                    }
                    [weakSelf.tableView reloadData];
                }
                [weakSelf setLoadingIndicatorVisible:NO];
            });
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.historyDayList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArray = self.historyDayList[section];
    
    return sectionArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECSListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    ECSHistoryListItem *listItem = self.historyDayList[indexPath.section][indexPath.row];
    cell.titleLabel.text = listItem.title;
    
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    NSArray *sectionArray = self.historyDayList[section];
    ECSHistoryListItem *firstItem = sectionArray.firstObject;
    
    title = [sectionTitleDateFormatter stringFromDate:firstItem.date];
    
    if (!IsNullOrEmpty(title))
    {
        UINib *sectionNib = [UINib nibWithNibName:[[ECSSectionHeader class] description] bundle:[NSBundle bundleForClass:[ECSSectionHeader class]]];
        ECSSectionHeader *sectionHeader = [[sectionNib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        
        sectionHeader.textLabel.text = title;
        
        return sectionHeader;
    }
    else
    {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECSChatViewController *chatViewController = [ECSChatViewController ecs_loadFromNib];
    ECSHistoryListItem *listItem = self.historyDayList[indexPath.section][indexPath.row];
    chatViewController.historyJourney = listItem.journeyId;
    
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}



@end
