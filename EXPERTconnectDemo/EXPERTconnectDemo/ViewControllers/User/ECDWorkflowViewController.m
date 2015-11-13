//
//  ECDWorkflowViewController.m
//  EXPERTconnectDemo
//
//  Created by AgilizTech Mac on 03/11/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECDWorkflowViewController.h"
#import "ECDAdHocAnswerEngineContextPicker.h"
#import "ECDAdHocChatPicker.h"
#import "ECDLocalization.h"

#import <EXPERTconnect/EXPERTconnect.h>
#import <EXPERTconnect/ECSTheme.h>

typedef NS_ENUM(NSInteger, SettingsSections)
{
    SettingsSectionWorkflowEscalateToChat,
    SettingsSectionWorkflowChatWithPostSurvey,
    SettingsSectionWorkflowChatWithPreSurvey,
    SettingsSectionCount
};

typedef NS_ENUM(NSInteger, WorkflowEscalateToChatSectionRows)
{
    WorkflowEscalateToChatSectionRowStart,
    WorkflowEscalateToChatSectionRowCount
};

typedef NS_ENUM(NSInteger, WorkflowChatWithPostSurveySectionRows)
{
    WorkflowChatWithPostSurveySectionRowStart,
    WorkflowChatWithPostSurveySectionRowCount
};

typedef NS_ENUM(NSInteger, WorkflowChatWithPreSurveySectionRows)
{
    WorkflowChatWithPreSurveySectionRowStart,
    WorkflowChatWithPreSurveySectionRowCount
};

@interface ECDWorkflowViewController ()<UITableViewDataSource,UITableViewDelegate,ECSWorkflowDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) ECDAdHocAnswerEngineContextPicker *selectWorkflowAnswerEngineContextPicker;
@property (strong, nonatomic) ECDAdHocChatPicker *selectWorkflowPostSurveyChatPicker;
@property (strong, nonatomic) ECDAdHocChatPicker *selectWorkflowPreSurveyChatPicker;
@property (nonatomic, strong) ECSWorkflow *workflow;

@end

@implementation ECDWorkflowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Workflow";
    
    ECSTheme *theme = [[EXPERTconnect shared] theme];
    
    self.view.backgroundColor = theme.primaryBackgroundColor;
    self.tableView.backgroundColor = theme.primaryBackgroundColor;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.tableView.sectionHeaderHeight = 42.0f;
    self.tableView.sectionFooterHeight = 0.0f;
    
    self.selectWorkflowAnswerEngineContextPicker = [ECDAdHocAnswerEngineContextPicker new];
    self.selectWorkflowPostSurveyChatPicker = [ECDAdHocChatPicker new];
    self.selectWorkflowPreSurveyChatPicker = [ECDAdHocChatPicker new];
    
    [self.selectWorkflowAnswerEngineContextPicker setup];
    [self.selectWorkflowPostSurveyChatPicker setup];
    [self.selectWorkflowPreSurveyChatPicker setup];
    
    // Do any additional setup after loading the view from its nib.
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
            
        case SettingsSectionWorkflowChatWithPostSurvey:
            rowCount = WorkflowChatWithPostSurveySectionRowCount;
            break;
            
        case SettingsSectionWorkflowChatWithPreSurvey:
            rowCount = WorkflowChatWithPreSurveySectionRowCount;
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
                    cell.accessoryView = self.selectWorkflowAnswerEngineContextPicker;
                    break;
                default:
                    break;
            }
            break;
        case SettingsSectionWorkflowChatWithPostSurvey:
            switch (indexPath.row) {
                case WorkflowChatWithPostSurveySectionRowStart:
                    cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartWorkflowChatWithPostSurveyLabel, @"Workflow Chat With Post Survey");
                    cell.accessoryView = self.selectWorkflowPostSurveyChatPicker;
                    break;
                    
                default:
                    break;
            }
            break;
            
        case SettingsSectionWorkflowChatWithPreSurvey:
            switch (indexPath.row) {
                case WorkflowChatWithPreSurveySectionRowStart:
                    cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartWorkflowChatWithPreSurveyLabel, @"Workflow Chat With Pre Survey");
                    cell.accessoryView = self.selectWorkflowPreSurveyChatPicker;
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
    
    if (indexPath.section == SettingsSectionWorkflowChatWithPostSurvey && indexPath.row == WorkflowChatWithPostSurveySectionRowStart)
    {
        [self startChatWithPostSurvey];;
    }
    
    if (indexPath.section == SettingsSectionWorkflowChatWithPreSurvey && indexPath.row == WorkflowChatWithPreSurveySectionRowStart)
    {
        [self startChatWithPreSurvey];
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
            
        case SettingsSectionWorkflowChatWithPostSurvey:
        {
            title = ECDLocalizedString(ECDLocalizedStartChatWithPostSurveyHeader, @"Workflow Post Chat Survey");
        }
            break;
            
        case SettingsSectionWorkflowChatWithPreSurvey:
        {
            title = ECDLocalizedString(ECDLocalizedStartChatWithPreSurveyHeader, @"Workflow Pre Chat Survey");
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

-(void)localBreadCrumb:(NSString *)action description:(NSString *)desc {
    [[EXPERTconnect shared] breadcrumbWithAction:action
                                     description:desc
                                          source:@"ECDemo"
                                     destination:@"Humanify"
                                     geolocation:nil];
}

-(void)handleEscalateToChat
{
    NSLog(@"Starting an Workflow EscalateToChat");
    
    NSString *aeContext = [self.selectWorkflowAnswerEngineContextPicker currentSelection];
    
    [self localBreadCrumb:@"startAnswerEngine"
              description:[NSString stringWithFormat:@"Answer engine with context=%@", aeContext]];
    
    ECSRootViewController *answerEngineController = (ECSRootViewController *)[[EXPERTconnect shared] startAnswerEngine:aeContext withDisplayName:@"Answer Engine Worklflow"];
    
    ECSWorkflowNavigation *navManager = [[ECSWorkflowNavigation alloc] initWithHostViewController:answerEngineController];
    self.workflow = [[ECSWorkflow alloc] initWithWorkflowName:ECSActionTypeAnswerEngineString
                                             workflowDelegate:self
                                            navigationManager:navManager];
    answerEngineController.workflowDelegate = self.workflow;
    
    for (UIView *containerView in answerEngineController.view.subviews) {
        if(containerView.tag == 1)
        {
            [containerView setHidden:YES];
        }
    }
    answerEngineController.navigationItem.leftBarButtonItem = nil;
    [self.navigationController pushViewController:answerEngineController animated:YES];
}


-(void)startChatWithPostSurvey
{
    NSLog(@"Starting an Workflow Chat Session");
    
    NSString *chatSkill = [self.selectWorkflowPostSurveyChatPicker currentSelection];
    
    [self localBreadCrumb:@"startChat"
              description:[NSString stringWithFormat:@"Starting chat with skill %@", chatSkill]];
    
    ECSRootViewController *chatController = (ECSRootViewController *)[[EXPERTconnect shared] startChat:chatSkill withDisplayName:@"Chat Workflow" withSurvey:NO];
    
    ECSWorkflowNavigation *navManager = [[ECSWorkflowNavigation alloc] initWithHostViewController:self];
    self.workflow = [[ECSWorkflow alloc] initWithWorkflowName:ECSActionTypeChatString
                                             workflowDelegate:self
                                            navigationManager:navManager];
    chatController.workflowDelegate = self.workflow;
    
    for (UIView *containerView in self.view.subviews) {
        if(containerView.tag == 1)
        {
            [containerView setHidden:YES];
        }
    }
    [self.navigationController pushViewController:chatController animated:YES];
}

-(void)startChatWithPreSurvey
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[EXPERTconnect shared] setSurveyFormName:@"agentperformance"];
        [[EXPERTconnect shared] startWorkflow:ECSActionTypeFormString withAction:ECSActionTypeFormString delgate:self viewController:self];
    });
}

// workflowName: String!, requestCommand command: String!, requestParams params: [NSObject : AnyObject]
//
- (NSDictionary *) workflowResponseForWorkflow:(NSString *)workflowName requestCommand:(NSString *)command requestParams:(NSDictionary *)params {
    
    NSLog(@"Delegate notified for workflowName: %@, command: %@", workflowName, command);
    if ([workflowName isEqualToString:ECSActionTypeChatString]) {
        if ([params valueForKey:@"PostChatSurvey"]) {
            NSNumber *count = [params valueForKey:@"PostChatSurvey"];
            if (count.intValue >  0) {
                return @{@"ActionType":ECSActionTypeFormString};
            }
        }
    }
    if ([workflowName isEqualToString:ECSActionTypeFormString]) {
        NSString *formName = [params valueForKey:@"formName"];
        if ([formName isEqualToString:@"agentperformance"]) {
            if ([params valueForKey:@"formValue"]) {
                NSString *formValue = [params valueForKey:@"formValue"];
                if ([formValue isEqualToString:@"low"] ) {
                    return @{@"ActionType":ECSRequestChatAction};
                }
            }
        }
    }
    if ([workflowName isEqualToString:ECSActionTypeAnswerEngineString]) {
        if ([params valueForKey:@"InvalidResponseCount"]) {
            NSNumber *count = [params valueForKey:@"InvalidResponseCount"];
            if (count.intValue >  0) {
                return @{@"ActionType":ECSRequestChatAction};
            }
        }
    }
    if ([workflowName isEqualToString:ECSActionTypeAnswerEngineString]) {
        if ([params valueForKey:@"QuestionsAsked"]) {
            NSNumber *count = [params valueForKey:@"QuestionsAsked"];
            if (count.intValue >  0) {
                return @{@"ActionType":ECSRequestCallbackAction};
            }
        }
    }
    return nil;
}

-(void)unrecognizedAction:(NSString *)action {
    NSLog(@"Unrecognized action in workflow Forms Controller: %@", action.description);
    if([action isEqualToString:ECSRequestChatAction])
    {
        NSString *chatSkill = [self.selectWorkflowPreSurveyChatPicker currentSelection];
        
        [self localBreadCrumb:@"startChat"
                  description:[NSString stringWithFormat:@"Starting chat with skill %@", chatSkill]];
        UIViewController *chatController = [[EXPERTconnect shared] startChat:chatSkill withDisplayName:@"Chat" withSurvey:NO];
        
        [self.navigationController pushViewController:chatController animated:YES];
    }
}

@end
