//
//  ECSAnswerEngineHistoryViewConroller.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSAnswerEngineHistoryViewController.h"

#import "ECSAnswerEngineViewController.h"
#import "ECSAnswerHistoryResponse.h"
#import "ECSHistoryResponse.h"
#import "ECSHistoryList.h"
#import "ECSHistoryListItem.h"
#import "ECSJSONSerializer.h"
#import "ECSInjector.h"
#import "ECSListTableViewCell.h"
#import "ECSLocalization.h"
#import "ECSSectionHeader.h"
#import "ECSTheme.h"
#import "ECSUtilities.h"
#import "ECSURLSessionManager.h"

#import "UIView+ECSNibLoading.h"
#import "UIViewController+ECSNibLoading.h"

typedef NS_ENUM(NSUInteger, ECSAnswerEngineHistorySections)
{
    ECSAnswerEngineHistorySectionAnswers,
    ECSAnswerEngineHistorySectionsCount
};
@interface ECSAnswerEngineHistoryViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *answers;
@end

@implementation ECSAnswerEngineHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = ECSLocalizedString(ECSLocalizeHistory, @"History");
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [self.tableView registerNib:[ECSListTableViewCell ecs_nib] forCellReuseIdentifier:@"Cell"];
    self.tableView.sectionHeaderHeight = 42.0f;
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    self.view.backgroundColor = theme.primaryBackgroundColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!self.answers || self.answers.count == 0)
    {
        [self setLoadingIndicatorVisible:YES];
        ECSURLSessionManager *sessionManager = [[ECSInjector defaultInjector] objectForClass:[ECSURLSessionManager class]];
        
        __weak typeof(self) weakSelf = self;
        
        [sessionManager getAnswerEngineHistoryWithCompletion:^(ECSHistoryList *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
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

                NSMutableArray *answersArray = [NSMutableArray arrayWithCapacity:sortedHistory.count];
                
                for (ECSHistoryListItem *historyListItem in sortedHistory)
                {
                    if ([historyListItem.details isKindOfClass:[NSArray class]])
                    {
                        for (NSDictionary *answerItem in historyListItem.details)
                        {
                            [answersArray addObject:[ECSJSONSerializer objectFromJSONDictionary:answerItem                                                                                      withClass:[ECSAnswerHistoryResponse class]]];
                        }
                    }
                }
                    
                weakSelf.answers = answersArray;
                [weakSelf.tableView reloadData];
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
    return ECSAnswerEngineHistorySectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    switch (section) {
        case ECSAnswerEngineHistorySectionAnswers:
            rowCount = [self.answers count];
            break;
        default:
            break;
    }
    
    return rowCount;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECSListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case ECSAnswerEngineHistorySectionAnswers:
        {
            ECSAnswerHistoryResponse *response = self.answers[indexPath.row];
            cell.titleLabel.text = response.request;
    
        }
            break;
        default:
            break;
    }
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    switch (section) {
        case ECSAnswerEngineHistorySectionAnswers:
            title = ECSLocalizedString(ECSLocalizeAnswers, @"Answers");
            break;
            
        default:
            break;
    }
    
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
    ECSAnswerHistoryResponse *response = self.answers[indexPath.row];
    
    ECSAnswerEngineViewController *answerViewController = [ECSAnswerEngineViewController ecs_loadFromNib];
    answerViewController.historyResponse = response;
    
    [self.navigationController pushViewController:answerViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 42.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

@end
