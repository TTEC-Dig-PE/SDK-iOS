//
//  ECDWorkflowsViewController.m
//  EXPERTconnectDemo
//
//  Created by AgilizTech Mac on 20/10/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//
#import "ECDWorkflowsViewController.h"
#import "ECDAdHocAnswerEngineContextPicker.h"
#import "ECDLocalization.h"

#import <EXPERTconnect/EXPERTconnect.h>
#import <EXPERTconnect/ECSTheme.h>
#import <EXPERTconnect/ECSWorkflow.h>

typedef NS_ENUM(NSInteger, SettingsSections)
{
    SettingsSectionWorkflowEscalateToChat,
    SettingsSectionCount
};

typedef NS_ENUM(NSInteger, AdHocEscalateToChatSectionRows)
{
    WorkflowEscalateToChatSectionRowStart,
    WorkflowEscalateToChatSectionRowCount
};

@interface ECDWorkflowsViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) ECDAdHocAnswerEngineContextPicker *selectAdHocAnswerEngineContextPicker;

@end

@implementation ECDWorkflowsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Workflow";

    ECSTheme *theme = [[EXPERTconnect shared] theme];
    
    self.view.backgroundColor = theme.primaryBackgroundColor;
    self.tableView.backgroundColor = theme.primaryBackgroundColor;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.tableView.sectionHeaderHeight = 42.0f;
    self.tableView.sectionFooterHeight = 0.0f;
    
    self.selectAdHocAnswerEngineContextPicker = [ECDAdHocAnswerEngineContextPicker new];
    
    [self.selectAdHocAnswerEngineContextPicker setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SettingsSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    switch (section) {
        case SettingsSectionWorkflowEscalateToChat:
            rowCount = WorkflowEscalateToChatSectionRowCount;
            break;
            
        default:
            break;
    }
    return rowCount;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    ECSTheme *theme = [[EXPERTconnect shared] theme];
    cell.contentView.backgroundColor = theme.secondaryBackgroundColor;
    cell.backgroundColor = theme.secondaryBackgroundColor;
    cell.textLabel.textColor = theme.primaryTextColor;
    
    switch (indexPath.section) {
        case SettingsSectionWorkflowEscalateToChat:
            switch (indexPath.row) {
                case WorkflowEscalateToChatSectionRowStart:
                    cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartWorkflowEscalateToChatLabel, @"Workflow Escalate To Chat");
                    cell.accessoryView = self.selectAdHocAnswerEngineContextPicker;
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SettingsSectionWorkflowEscalateToChat && indexPath.row == WorkflowEscalateToChatSectionRowStart)
    {
        [self handleEscalateToChat];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return tableView.sectionHeaderHeight;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    switch (section) {
        case SettingsSectionWorkflowEscalateToChat:
        {
            title = ECDLocalizedString(ECDLocalizedStartEscalateToChatHeader, @"Workflow Escalate To Chat");
        }
            break;
            
        default:
            break;
    }
    
    if (title && (title.length > 0))
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

-(void)handleEscalateToChat
{
    NSLog(@"Starting an Workflow EscalateToChat");
    
    NSString *aeContext = [self.selectAdHocAnswerEngineContextPicker currentSelection];
    
    [[EXPERTconnect shared] breadcrumbsAction:@"startAnswerEngine"
                            actionDescription:[NSString stringWithFormat:@"Answer engine with context=%@", aeContext]
                                 actionSource:@"ECDemo"
                            actionDestination:@"Humanify"];
    
    UIViewController *answerEngineController = [[EXPERTconnect shared] startAnswerEngine:aeContext withDisplayName:@"Answer Engine Worklflow"];
    [self.navigationController pushViewController:answerEngineController animated:YES];
}

@end
