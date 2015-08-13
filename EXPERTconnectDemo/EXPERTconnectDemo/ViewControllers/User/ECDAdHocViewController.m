//
//  ECDAdHocViewController.m
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 8/3/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AirshipKit/AirshipKit.h>

#import "ECDLicenseViewController.h"
#import "ECDExtendedUserProfileViewController.h"
#import "ECDAPIConfigViewController.h"
#import "ECDAdHocViewController.h"
#import "ECDUserDefaultKeys.h"
#import "ECDAdHocChatPicker.h"
#import "ECDAdHocVoiceCallbackPicker.h"
#import "ECDAdHocAnswerEngineContextPicker.h"
#import "ECDAdHocFormsPicker.h"
#import "ECDAdHocWebPagePicker.h"
#import "ECDEnvironmentPicker.h"
#import "ECDRunModePicker.h"
#import "ECDLocalization.h"

#import <EXPERTconnect/EXPERTconnect.h>
#import <EXPERTconnect/ECSTheme.h>

// High-level SDK Services
// =======================
//
// Start an AdHoc Chat
// Start an AdHoc Answer Engine Session
// Start an AdHoc Survey (Form) by Name
// Start an AdHoc User Profile Form
// Start an AdHoc Voice Callback Request
// Start an AdHoc Email Message
// Start an AdHoc SMS Message
// Launch an AdHoc Web Page View
// View my Answer Engine History
// View my Chat History
// Display the Expert Select Chat Dialog
//
// Lower-level SDK Services
// ========================
//
// CRUD User Profile, including Extended Attributes
//
// Get Answer Engine Top Questions
// Ask an AdHoc Question from the Answer Engine
// Rate an Answer Engine Response
// Get list of available Forms
// Get list of available Media Files
// Retrieve Navigation or Navigation Segment
// Upload an AdHoc image
// Download and AdHoc image
//
// Display the Expert Select Voice Callback Dialog
// Display the Expert Select Video Dialog
// Display the Select Expert and Channel Dialog
//
// Additional SDK Services (may require new APIs to support)
// =========================================================
//
// Retrieve Available Agents by Skill?
// Invoke a "new" API Endpoint?
// Retrieve list of skills with availability of each (# agents online, # agents available)
// Retrieve list of agents (all) with availability state of each
// estimated time to wait for skill X" and
// generic API endpoint
// Push Notifications
// Start any High-level SDK Services with Host App ViewController or at least Host App controlled Navigation
//
typedef NS_ENUM(NSInteger, SettingsSections)
{
    SettingsSectionAdHocChat,
    SettingsSectionAdHocAnswerEngine,
    SettingsSectionAdHocForms,
    SettingsSectionAdHocUserProfile,
    SettingsSectionAdHocVoiceCallback,
    SettingsSectionAdHocEmailMessage,
    SettingsSectionAdHocSMSMessage,
    SettingsSectionAdHocWebPage,
    SettingsSectionAdHocAnswerEngineHistory,
    SettingsSectionAdHocChatHistory,
    SettingsSectionAdHocSelectExpert,
    SettingsSectionAdHocExtendedUserProfile,
    SettingsSectionThirteen,
    SettingsSectionFourteen,
    SettingsSectionFifteen,
    SettingsSectionCount
};

typedef NS_ENUM(NSInteger, AdHocChatSectionRows)
{
    AdHocChatSectionRowStart,
    AdHocChatSectionRowCount
};

typedef NS_ENUM(NSInteger, AnswerEngineSectionRows)
{
    AdHocAnswerEngineRowStart,
    AdHocAnswerEngineSectionRowCount
};

typedef NS_ENUM(NSInteger, FormsSectionRows)
{
    AdHocFormsSectionRowStart,
    AdHocFormsSectionRowCount
};

typedef NS_ENUM(NSInteger, UserProfileSectionRows)
{
    AdHocUserProfileSectionRowStart,
    AdHocUserProfileRowCount
};

typedef NS_ENUM(NSInteger, VoiceCallbackSectionRows)
{
    AdHocVoiceCallbackSectionRowStart,
    AdHocVoiceCallbackRowCount
};

typedef NS_ENUM(NSInteger, EmailMessageSectionRows)
{
    AdHocEmailMessageSectionRowStart,
    AdHocEmailMessageRowCount
};

typedef NS_ENUM(NSInteger, SMSMessageSectionRows)
{
    AdHocSMSMessageSectionRowStart,
    AdHocSMSMessageRowCount
};

typedef NS_ENUM(NSInteger, WebPagebackSectionRows)
{
    AdHocWebPageSectionRowStart,
    AdHocWebPageRowCount
};

typedef NS_ENUM(NSInteger, AnswerEngineHistorySectionRows)
{
    AdHocAnswerEngineHistoryRowStart,
    AdHocAnswerEngineHistoryRowCount
};

typedef NS_ENUM(NSInteger, ChatHistorySectionRows)
{
    AdHocChatHistoryRowStart,
    AdHocChatHistoryRowCount
};

typedef NS_ENUM(NSInteger, SelectExpertSectionRows)
{
    AdHocSelectExpertRowStart,
    AdHocSelectExpertRowCount
};

typedef NS_ENUM(NSInteger, ExtendedUserProfileSectionRows)
{
    AdHocExtendedUserProfileRowStart,
    AdHocExtendedUserProfileRowCount
};

typedef NS_ENUM(NSInteger, SettingsSectionRowThirteenRows)
{
    SettingsSectionThirteenRowStart,
    SettingsSectionThirteenRowCount
};

typedef NS_ENUM(NSInteger, SettingsSectionRowFourteenRows)
{
    SettingsSectionFourteenRowStart,
    SettingsSectionFourteenRowCount
};

typedef NS_ENUM(NSInteger, SettingsSectionRowFifteenRows)
{
    SettingsSectionFifteenRowStart,
    SettingsSectionFifteenRowCount
};

@interface ECDAdHocViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) ECDAdHocChatPicker *selectAdHocChatPicker;
@property (strong, nonatomic) ECDAdHocVoiceCallbackPicker *selectAdHocVoiceCallbackPicker;
@property (strong, nonatomic) ECDAdHocAnswerEngineContextPicker *selectAdHocAnswerEngineContextPicker;
@property (strong, nonatomic) ECDAdHocFormsPicker *selectAdHocFormsPicker;
@property (strong, nonatomic) ECDAdHocWebPagePicker *selectAdHocWebPagePicker;
@end

@implementation ECDAdHocViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"AdHoc";
    
    ECSTheme *theme = [[EXPERTconnect shared] theme];
    
    self.view.backgroundColor = theme.primaryBackgroundColor;
    self.tableView.backgroundColor = theme.primaryBackgroundColor;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.tableView.sectionHeaderHeight = 42.0f;
    self.tableView.sectionFooterHeight = 0.0f;

    self.selectAdHocChatPicker = [ECDAdHocChatPicker new];
    self.selectAdHocAnswerEngineContextPicker = [ECDAdHocAnswerEngineContextPicker new];
    self.selectAdHocFormsPicker = [ECDAdHocFormsPicker new];
    self.selectAdHocVoiceCallbackPicker = [ECDAdHocVoiceCallbackPicker new];
    self.selectAdHocWebPagePicker = [ECDAdHocWebPagePicker new];
    
    [self.selectAdHocChatPicker setup];
    [self.selectAdHocAnswerEngineContextPicker setup];
    [self.selectAdHocFormsPicker setup];
    [self.selectAdHocVoiceCallbackPicker setup];
    [self.selectAdHocWebPagePicker setup];
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
        case SettingsSectionAdHocChat:
            rowCount = AdHocChatSectionRowCount;
            break;
            
        case SettingsSectionAdHocAnswerEngine:
            rowCount = AdHocAnswerEngineSectionRowCount;
            break;
            
        case SettingsSectionAdHocForms:
            rowCount = AdHocFormsSectionRowCount;
            break;
            
        case SettingsSectionAdHocUserProfile:
            rowCount = AdHocUserProfileRowCount;
            break;
            
        case SettingsSectionAdHocVoiceCallback:
            rowCount = AdHocVoiceCallbackRowCount;
            break;
            
        case SettingsSectionAdHocEmailMessage:
            rowCount = AdHocEmailMessageRowCount;
            break;
            
        case SettingsSectionAdHocSMSMessage:
            rowCount = AdHocSMSMessageRowCount;
            break;
            
        case SettingsSectionAdHocWebPage:
            rowCount = AdHocWebPageRowCount;
            break;
            
        case SettingsSectionAdHocAnswerEngineHistory:
            rowCount = AdHocAnswerEngineHistoryRowCount;
            break;
            
        case SettingsSectionAdHocChatHistory:
            rowCount = AdHocChatHistoryRowCount;
            break;
            
        case SettingsSectionAdHocSelectExpert:
            rowCount = AdHocSelectExpertRowCount;
            break;
            
        case SettingsSectionAdHocExtendedUserProfile:
            rowCount = AdHocExtendedUserProfileRowCount;
            break;
            
        case SettingsSectionThirteen:
            rowCount = SettingsSectionThirteenRowCount;
            break;
            
        case SettingsSectionFourteen:
            rowCount = SettingsSectionFourteenRowCount;
            break;
            
        case SettingsSectionFifteen:
            rowCount = SettingsSectionFifteenRowCount;
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
        case SettingsSectionAdHocChat:
            switch (indexPath.row) {
                case AdHocChatSectionRowStart:
                    cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartChatLabel, @"AdHoc Chat");
                    cell.accessoryView = self.selectAdHocChatPicker;
                    break;
                default:
                    break;
            }
            break;
            
        case SettingsSectionAdHocAnswerEngine:
            switch (indexPath.row) {
                case AdHocAnswerEngineRowStart:
                    cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartAnswerEngineLabel, @"AdHoc Answer Engine");
                    cell.accessoryView = self.selectAdHocAnswerEngineContextPicker;
                    break;
                    
                default:
                    break;
            }
            break;
            
        case SettingsSectionAdHocForms:
            switch (indexPath.row) {
                case AdHocFormsSectionRowStart:
                    cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartFormsLabel, @"AdHoc Forms Interview");
                    cell.accessoryView = self.selectAdHocFormsPicker;
                    break;
                    
                default:
                    break;
            }
            break;
            
        case SettingsSectionAdHocUserProfile:
            switch (indexPath.row) {
                case AdHocUserProfileSectionRowStart:
                    cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartUserProfileLabel, @"AdHoc User Profile");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionAdHocVoiceCallback:
            switch (indexPath.row) {
                case AdHocUserProfileSectionRowStart:
                    cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartVoiceCallbackLabel, @"AdHoc Voice Callback");
                    cell.accessoryView = self.selectAdHocVoiceCallbackPicker;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionAdHocEmailMessage:
            switch (indexPath.row) {
                case AdHocUserProfileSectionRowStart:
                    cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartEmailMessageLabel, @"AdHoc Email Message");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionAdHocSMSMessage:
            switch (indexPath.row) {
                case AdHocUserProfileSectionRowStart:
                    cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartSMSMessageLabel, @"AdHoc SMS Message");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionAdHocWebPage:
            switch (indexPath.row) {
                case AdHocUserProfileSectionRowStart:
                    cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartWebPageLabel, @"AdHoc Web Page");
                    cell.accessoryView = self.selectAdHocWebPagePicker;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionAdHocAnswerEngineHistory:
            switch (indexPath.row) {
                case AdHocUserProfileSectionRowStart:
                    cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartAnswerEngineHistoryLabel, @"AdHoc Answer Engine History");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionAdHocChatHistory:
            switch (indexPath.row) {
                case AdHocUserProfileSectionRowStart:
                    cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartChatHistoryLabel, @"AdHoc Chat History");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionAdHocSelectExpert:
            switch (indexPath.row) {
                case AdHocUserProfileSectionRowStart:
                    cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartSelectExpertLabel, @"AdHoc Select Expert Dialog");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionAdHocExtendedUserProfile:
            switch (indexPath.row) {
                case AdHocExtendedUserProfileRowStart:
                    cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartExtendedUserProfileLabel, @"AdHoc Registration Edit User Profile");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionThirteen:
            switch (indexPath.row) {
                case AdHocUserProfileSectionRowStart:
                    cell.textLabel.text = ECDLocalizedString(@"Localized Section Thirteen", @"Section Thirteen");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionFourteen:
            switch (indexPath.row) {
                case AdHocUserProfileSectionRowStart:
                    cell.textLabel.text = ECDLocalizedString(@"Localized Section Fourteen", @"Section Fourteen");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionFifteen:
            switch (indexPath.row) {
                case AdHocUserProfileSectionRowStart:
                    cell.textLabel.text = ECDLocalizedString(@"Localized Section Fifteen", @"Section Fifteen");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    if (indexPath.section == SettingsSectionAdHocChat && indexPath.row == AdHocChatSectionRowStart)
    {
        [self handleAdHocStartChat];
    }
    
    if (indexPath.section == SettingsSectionAdHocAnswerEngine && indexPath.row == AdHocAnswerEngineRowStart)
    {
        [self handleAdHocStartAnswerEngine];
    }
    
    if (indexPath.section == SettingsSectionAdHocForms && indexPath.row == AdHocFormsSectionRowStart)
    {
        [self handleAdHocRenderForm];
    }
    
    if (indexPath.section == SettingsSectionAdHocUserProfile && indexPath.row == AdHocUserProfileSectionRowStart)
    {
        [self handleAdHocEditUserProfile];
    }
    
    if (indexPath.section == SettingsSectionAdHocVoiceCallback && indexPath.row == AdHocVoiceCallbackSectionRowStart)
    {
        [self handleAdHocVoiceCallback];
    }
    
    if (indexPath.section == SettingsSectionAdHocEmailMessage && indexPath.row == AdHocEmailMessageSectionRowStart)
    {
        [self handleAdHocEmailMessage];
    }
    
    if (indexPath.section == SettingsSectionAdHocSMSMessage && indexPath.row == AdHocSMSMessageSectionRowStart)
    {
        [self handleAdHocSMSMessage];
    }
    
    if (indexPath.section == SettingsSectionAdHocWebPage && indexPath.row == AdHocWebPageSectionRowStart)
    {
        [self handleAdHocWebPage];
    }
    
    if (indexPath.section == SettingsSectionAdHocAnswerEngineHistory && indexPath.row == AdHocAnswerEngineHistoryRowStart)
    {
        [self handleAdHocAnswerEngineHistory];
    }
    
    if (indexPath.section == SettingsSectionAdHocChatHistory && indexPath.row == AdHocChatHistoryRowStart)
    {
        [self handleAdHocChatHistory];
    }
    
    if (indexPath.section == SettingsSectionAdHocSelectExpert && indexPath.row == AdHocSelectExpertRowStart)
    {
        [self handleAdHocSelectExpert];
    }
    
    if (indexPath.section == SettingsSectionAdHocExtendedUserProfile && indexPath.row == AdHocExtendedUserProfileRowStart)
    {
        [self handleAdHocEditUserProfileExtended];
    }
    
    if (indexPath.section == SettingsSectionThirteen && indexPath.row == SettingsSectionThirteenRowStart)
    {
        [self handleAdHocAPIConfigEditor];
    }
    
    if (indexPath.section == SettingsSectionFourteen && indexPath.row == SettingsSectionFourteenRowStart)
    {
        [self handleAdHocShowLicense];
    }
    
    if (indexPath.section == SettingsSectionFifteen && indexPath.row == SettingsSectionFifteenRowStart)
    {
        [self handleAdHocShowLicense];
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
        case SettingsSectionAdHocChat:
        {
            title = ECDLocalizedString(ECDLocalizedStartChatHeader, @"AdHoc Chat");
        }
            break;
            
        case SettingsSectionAdHocAnswerEngine:
        {
            title = ECDLocalizedString(ECDLocalizedStartAnswerEngineHeader, @"AdHoc Answer Engine Session");
        }
            break;
            
        case SettingsSectionAdHocForms:
        {
            title = ECDLocalizedString(ECDLocalizedStartFormsHeader, @"AdHoc Forms Interview");
        }
            break;
            
        case SettingsSectionAdHocUserProfile:
        {
            title = ECDLocalizedString(ECDLocalizedStartUserProfileHeader, @"AdHoc Edit User Profile");
        }
            break;
    
            
        case SettingsSectionAdHocVoiceCallback:
        {
            title = ECDLocalizedString(ECDLocalizedStartVoiceCallbackHeader, @"AdHoc Voice Callback");
        }
            break;
            
            
        case SettingsSectionAdHocEmailMessage:
        {
            title = ECDLocalizedString(ECDLocalizedStartEmailMessageHeader, @"AdHoc Email Messsage");
        }
            break;
            
            
        case SettingsSectionAdHocSMSMessage:
        {
            title = ECDLocalizedString(ECDLocalizedStartSMSMessageHeader, @"AdHoc SMS Message");
        }
            break;
            
            
        case SettingsSectionAdHocWebPage:
        {
            title = ECDLocalizedString(ECDLocalizedStartWebPageHeader, @"AdHoc Launch Web Page");
        }
            break;
            
            
        case SettingsSectionAdHocAnswerEngineHistory:
        {
            title = ECDLocalizedString(ECDLocalizedStartAnswerEngineHistoryHeader, @"AdHoc Answer Engine History");
        }
            break;
            
            
        case SettingsSectionAdHocChatHistory:
        {
            title = ECDLocalizedString(ECDLocalizedStartChatHistoryHeader, @"AdHoc Chat History");
        }
            break;
            
            
        case SettingsSectionAdHocSelectExpert:
        {
            title = ECDLocalizedString(ECDLocalizedStartSelectExpertHeader, @"AdHoc Select Expert Dialog");
        }
            break;
            
            
        case SettingsSectionAdHocExtendedUserProfile:
        {
            title = ECDLocalizedString(ECDLocalizedStartExtendedUserProfileHeader, @"Twelve Header");
        }
            break;
            
            
        case SettingsSectionThirteen:
        {
            title = ECDLocalizedString(@"Localized Section Thirteen Header", @"Thirteen Header");
        }
            break;
            
            
        case SettingsSectionFourteen:
        {
            title = ECDLocalizedString(@"Localized Section Fourteen Header", @"Fourteen Header");
        }
            break;
            
            
        case SettingsSectionFifteen:
        {
            title = ECDLocalizedString(@"Localized Section Fifteen Header", @"Fifteen Header");
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

-(void)handleAdHocStartChat
{
    NSLog(@"Starting an ad-hoc Chat Session");
    
    NSString *chatSkill = [self.selectAdHocChatPicker currentSelection];
    
    UIViewController *chatController = [[EXPERTconnect shared] startChat:chatSkill withDisplayName:@"Chat"];
    [self.navigationController pushViewController:chatController animated:YES];
}

-(void)handleAdHocVoiceCallback
{
    NSLog(@"Starting an ad-hoc Voice Callback Session");
    
    NSString *callSkill = @"CE_Mobile_Chat";   //   [self.selectAdHocCallbackPicker currentSelection];
    
    UIViewController *chatController = [[EXPERTconnect shared] startVoiceCallback:callSkill withDisplayName:@"Voice Callback"];
    [self.navigationController pushViewController:chatController animated:YES];
}

-(void)handleAdHocStartAnswerEngine
{
    NSLog(@"Starting an ad-hoc Answer Engine Session");
    
    NSString *aeContext = [self.selectAdHocAnswerEngineContextPicker currentSelection];
    
    UIViewController *answerEngineController = [[EXPERTconnect shared] startAnswerEngine:aeContext];
    [self.navigationController pushViewController:answerEngineController animated:YES];
}


-(void)handleAdHocRenderForm
{
    NSLog(@"Rendering an ad-hoc Form");
    
    NSString *formName = [self.selectAdHocFormsPicker currentSelection];
    
    UIViewController *formsController = [[EXPERTconnect shared] startSurvey:formName];
    [self.navigationController pushViewController:formsController animated:YES];
}

-(void)handleAdHocEditUserProfile
{
    NSLog(@"Rendering an ad-hoc User Profile Form");
    
    UIViewController *profileController = [[EXPERTconnect shared] startUserProfile];
    [self.navigationController pushViewController:profileController animated:YES];
}

-(void)handleAdHocEmailMessage
{
    NSLog(@"Rendering an ad-hoc Email Form");
    
    UIViewController *emailController = [[EXPERTconnect shared] startEmailMessage];
    [self.navigationController pushViewController:emailController animated:YES];
}

-(void)handleAdHocSMSMessage
{
    NSLog(@"Rendering an ad-hoc SMS Messaging Form");
    
    UIViewController *smsController = [[EXPERTconnect shared] startSMSMessage];
    [self.navigationController pushViewController:smsController animated:YES];
}

-(void)handleAdHocWebPage
{
    NSLog(@"Rendering an ad-hoc Web Page");
    
    NSString *url = [self.selectAdHocWebPagePicker currentSelection];
    
    UIViewController *webController = [[EXPERTconnect shared] startWebPage:url];
    [self.navigationController pushViewController:webController animated:YES];
}

-(void)handleAdHocAnswerEngineHistory
{
    NSLog(@"Rendering an ad-hoc Answer Engine History Page");
    
    UIViewController *aeController = [[EXPERTconnect shared] startAnswerEngineHistory];
    [self.navigationController pushViewController:aeController animated:YES];
}

-(void)handleAdHocChatHistory
{
    NSLog(@"Rendering an ad-hoc Chat History Page");
    
    UIViewController *chistController = [[EXPERTconnect shared] startChatHistory];
    [self.navigationController pushViewController:chistController animated:YES];
}

-(void)handleAdHocSelectExpert
{
    NSLog(@"Rendering an ad-hoc Answer Engine History Page");
    
    UIViewController *selectExpertController = [[EXPERTconnect shared] startSelectExpert];
    [self.navigationController pushViewController:selectExpertController animated:YES];
}

-(void)handleAdHocEditUserProfileExtended
{
    NSLog(@"Rendering an ad-hoc User Profile Form with Extended Attributes");
    
    ECDExtendedUserProfileViewController *profileController = [[ECDExtendedUserProfileViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:profileController animated:YES];
}

-(void)handleAdHocAPIConfigEditor
{
    NSLog(@"Rendering an ad-hoc API Config Editor with Extended Attributes");
    
    ECDAPIConfigViewController *configController = [[ECDAPIConfigViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:configController animated:YES];
}


-(void)handleAdHocShowLicense
{
    NSLog(@"Showing the ad-hoc License");
    
    ECDLicenseViewController *license = [[ECDLicenseViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:license animated:YES];
}

@end
