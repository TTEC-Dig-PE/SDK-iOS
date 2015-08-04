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
#import "ECDAdHocViewController.h"
#import "ECDUserDefaultKeys.h"
#import "ECDAdHocChatPicker.h"
#import "ECDAdHocAnswerEngineContextPicker.h"
#import "ECDEnvironmentPicker.h"
#import "ECDRunModePicker.h"
#import "ECDLocalization.h"

#import <EXPERTconnect/EXPERTconnect.h>
#import <EXPERTconnect/ECSTheme.h>

// Start an AdHoc Chat
// Start an AdHoc Answer Engine Session
// Get Answer Engine Top Questions
// Ask an AdHoc Question from the Answer Engine
// Rate an Answer Engine Response
// Initiate an AdHoc Voice Callback
// Retrieve my Conversation History
// View my Chat History
// View my Answer Engine History
// Render an AdHoc Form
// Retrieve Navigation or Navigation Segment
// Upload an AdHoc image
// Download and AdHoc image
// Retrieve my User Profile
// Update my User Profile
// Update User Profile Extended Attributes
//
// Retrieve Available Agents by Skill?
// Display the Expert Select Dialog?
// Invoke a "new" API Endpoint?
//

typedef NS_ENUM(NSInteger, SettingsSections)
{
    SettingsSectionAdHocChat,
    SettingsSectionAnswerEngine,
    SettingsSectionThree,
    SettingsSectionFour,
    SettingsSectionFive,
    SettingsSectionSix,
    SettingsSectionSeven,
    SettingsSectionEight,
    SettingsSectionNine,
    SettingsSectionTen,
    SettingsSectionEleven,
    SettingsSectionTwelve,
    SettingsSectionThirteen,
    SettingsSectionFourteen,
    SettingsSectionFifteen,
    SettingsSectionCount
};

typedef NS_ENUM(NSInteger, AdHocChatSectionRows)
{
    AdHocChatSectionRowStartChat,
    AdHocChatSectionRowCount
};

typedef NS_ENUM(NSInteger, AnswerEngineSectionRows)
{
    AdHocAnswerEngineRowStartAnswerEngine,
    AnswerEngineSectionRowCount
};

typedef NS_ENUM(NSInteger, SettingsSectionRowThreeRows)
{
    SettingsSectionThreeRowStart,
    SettingsSectionThreeRowCount
};

typedef NS_ENUM(NSInteger, SettingsSectionRowFourRows)
{
    SettingsSectionFourRowStart,
    SettingsSectionFourRowCount
};

typedef NS_ENUM(NSInteger, SettingsSectionRowFiveRows)
{
    SettingsSectionFiveRowStart,
    SettingsSectionFiveRowCount
};

typedef NS_ENUM(NSInteger, SettingsSectionRowSixRows)
{
    SettingsSectionSixRowStart,
    SettingsSectionSixRowCount
};

typedef NS_ENUM(NSInteger, SettingsSectionRowSevenRows)
{
    SettingsSectionSevenRowStart,
    SettingsSectionSevenRowCount
};

typedef NS_ENUM(NSInteger, SettingsSectionRowEightRows)
{
    SettingsSectionEightRowStart,
    SettingsSectionEightRowCount
};

typedef NS_ENUM(NSInteger, SettingsSectionRowNineRows)
{
    SettingsSectionNineRowStart,
    SettingsSectionNineRowCount
};

typedef NS_ENUM(NSInteger, SettingsSectionRowTenRows)
{
    SettingsSectionTenRowStart,
    SettingsSectionTenRowCount
};

typedef NS_ENUM(NSInteger, SettingsSectionRowElevenRows)
{
    SettingsSectionElevenRowStart,
    SettingsSectionElevenRowCount
};

typedef NS_ENUM(NSInteger, SettingsSectionRowTwelveRows)
{
    SettingsSectionTwelveRowStart,
    SettingsSectionTwelveRowCount
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
@property (strong, nonatomic) ECDAdHocAnswerEngineContextPicker *selectAdHocAnswerEngineContextPicker;
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
    
    [self.selectAdHocChatPicker setup];
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
        case SettingsSectionAdHocChat:
            rowCount = AdHocChatSectionRowCount;
            break;
            
        case SettingsSectionAnswerEngine:
            rowCount = AnswerEngineSectionRowCount;
            break;
            
        case SettingsSectionThree:
            rowCount = SettingsSectionThreeRowCount;
            break;
            
        case SettingsSectionFour:
            rowCount = SettingsSectionFourRowCount;
            break;
            
        case SettingsSectionFive:
            rowCount = SettingsSectionFiveRowCount;
            break;
            
        case SettingsSectionSix:
            rowCount = SettingsSectionSixRowCount;
            break;
            
        case SettingsSectionSeven:
            rowCount = SettingsSectionSevenRowCount;
            break;
            
        case SettingsSectionEight:
            rowCount = SettingsSectionEightRowCount;
            break;
            
        case SettingsSectionNine:
            rowCount = SettingsSectionNineRowCount;
            break;
            
        case SettingsSectionTen:
            rowCount = SettingsSectionTenRowCount;
            break;
            
        case SettingsSectionEleven:
            rowCount = SettingsSectionElevenRowCount;
            break;
            
        case SettingsSectionTwelve:
            rowCount = SettingsSectionTwelveRowCount;
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
                case AdHocChatSectionRowStartChat:
                    cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartChatLabel, @"AdHoc Chat");
                    cell.accessoryView = self.selectAdHocChatPicker;
                    break;
                default:
                    break;
            }
            break;
            
        case SettingsSectionAnswerEngine:
            switch (indexPath.row) {
                case AdHocAnswerEngineRowStartAnswerEngine:
                    cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartAnswerEngineLabel, @"AdHoc Answer Engine");
                    cell.accessoryView = self.selectAdHocAnswerEngineContextPicker;
                    break;
                    
                default:
                    break;
            }
            break;
            
        case SettingsSectionThree:
            switch (indexPath.row) {
                case SettingsSectionThreeRowStart:
                    cell.textLabel.text = ECSLocalizedString(@"Localized Section Three", @"Section Three");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
            break;
            
        case SettingsSectionFour:
            switch (indexPath.row) {
                case SettingsSectionFourRowStart:
                    cell.textLabel.text = ECSLocalizedString(@"Localized Section Four", @"Section Four");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionFive:
            switch (indexPath.row) {
                case SettingsSectionFourRowStart:
                    cell.textLabel.text = ECSLocalizedString(@"Localized Section Five", @"Section Five");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionSix:
            switch (indexPath.row) {
                case SettingsSectionFourRowStart:
                    cell.textLabel.text = ECSLocalizedString(@"Localized Section Six", @"Section Six");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionSeven:
            switch (indexPath.row) {
                case SettingsSectionFourRowStart:
                    cell.textLabel.text = ECSLocalizedString(@"Localized Section Seven", @"Section Seven");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionEight:
            switch (indexPath.row) {
                case SettingsSectionFourRowStart:
                    cell.textLabel.text = ECSLocalizedString(@"Localized Section Eight", @"Section Eight");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionNine:
            switch (indexPath.row) {
                case SettingsSectionFourRowStart:
                    cell.textLabel.text = ECSLocalizedString(@"Localized Section Nine", @"Section Nine");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionTen:
            switch (indexPath.row) {
                case SettingsSectionFourRowStart:
                    cell.textLabel.text = ECSLocalizedString(@"Localized Section Ten", @"Section Ten");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionEleven:
            switch (indexPath.row) {
                case SettingsSectionFourRowStart:
                    cell.textLabel.text = ECSLocalizedString(@"Localized Section Eleven", @"Section Eleven");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionTwelve:
            switch (indexPath.row) {
                case SettingsSectionFourRowStart:
                    cell.textLabel.text = ECSLocalizedString(@"Localized Section Twelve", @"Section Twelve");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionThirteen:
            switch (indexPath.row) {
                case SettingsSectionFourRowStart:
                    cell.textLabel.text = ECSLocalizedString(@"Localized Section Thirteen", @"Section Thirteen");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionFourteen:
            switch (indexPath.row) {
                case SettingsSectionFourRowStart:
                    cell.textLabel.text = ECSLocalizedString(@"Localized Section Fourteen", @"Section Fourteen");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionFifteen:
            switch (indexPath.row) {
                case SettingsSectionFourRowStart:
                    cell.textLabel.text = ECSLocalizedString(@"Localized Section Fifteen", @"Section Fifteen");
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
    if (indexPath.section == SettingsSectionAdHocChat && indexPath.row == AdHocChatSectionRowStartChat)
    {
        [self handleAdHocStartChat];
    }
    
    if (indexPath.section == SettingsSectionAnswerEngine && indexPath.row == AdHocAnswerEngineRowStartAnswerEngine)
    {
        [self handleAdHocStartAnswerEngine];
    }
    
    if (indexPath.section == SettingsSectionThree && indexPath.row == SettingsSectionThreeRowStart)
    {
        [self handleAdHocShowLicense];
    }
    
    if (indexPath.section == SettingsSectionFour && indexPath.row == SettingsSectionFourRowStart)
    {
        [self handleAdHocShowLicense];
    }
    
    if (indexPath.section == SettingsSectionFive && indexPath.row == SettingsSectionFiveRowStart)
    {
        [self handleAdHocShowLicense];
    }
    
    if (indexPath.section == SettingsSectionSix && indexPath.row == SettingsSectionSixRowStart)
    {
        [self handleAdHocShowLicense];
    }
    
    if (indexPath.section == SettingsSectionSeven && indexPath.row == SettingsSectionSevenRowStart)
    {
        [self handleAdHocShowLicense];
    }
    
    if (indexPath.section == SettingsSectionEight && indexPath.row == SettingsSectionEightRowStart)
    {
        [self handleAdHocShowLicense];
    }
    
    if (indexPath.section == SettingsSectionNine && indexPath.row == SettingsSectionNineRowStart)
    {
        [self handleAdHocShowLicense];
    }
    
    if (indexPath.section == SettingsSectionTen && indexPath.row == SettingsSectionTenRowStart)
    {
        [self handleAdHocShowLicense];
    }
    
    if (indexPath.section == SettingsSectionEleven && indexPath.row == SettingsSectionElevenRowStart)
    {
        [self handleAdHocShowLicense];
    }
    
    if (indexPath.section == SettingsSectionTwelve && indexPath.row == SettingsSectionTwelveRowStart)
    {
        [self handleAdHocShowLicense];
    }
    
    if (indexPath.section == SettingsSectionThirteen && indexPath.row == SettingsSectionThirteenRowStart)
    {
        [self handleAdHocShowLicense];
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
            
        case SettingsSectionAnswerEngine:
        {
            title = ECDLocalizedString(ECDLocalizedStartAnswerEngineHeader, @"AdHoc Answer Engine Session");
        }
            break;
            
        case SettingsSectionThree:
        {
            title = ECDLocalizedString(@"Localized Section Three Header", @"Three Header");
        }
            break;
            
        case SettingsSectionFour:
        {
            title = ECDLocalizedString(@"Localized Section Four Header", @"Four Header");
        }
            break;
    
            
        case SettingsSectionFive:
        {
            title = ECDLocalizedString(@"Localized Section Five Header", @"Five Header");
        }
            break;
            
            
        case SettingsSectionSix:
        {
            title = ECDLocalizedString(@"Localized Section Six Header", @"Six Header");
        }
            break;
            
            
        case SettingsSectionSeven:
        {
            title = ECDLocalizedString(@"Localized Section Seven Header", @"Seven Header");
        }
            break;
            
            
        case SettingsSectionEight:
        {
            title = ECDLocalizedString(@"Localized Section Eight Header", @"Eight Header");
        }
            break;
            
            
        case SettingsSectionNine:
        {
            title = ECDLocalizedString(@"Localized Section Nine Header", @"Nine Header");
        }
            break;
            
            
        case SettingsSectionTen:
        {
            title = ECDLocalizedString(@"Localized Section Ten Header", @"Ten Header");
        }
            break;
            
            
        case SettingsSectionEleven:
        {
            title = ECDLocalizedString(@"Localized Section Eleven Header", @"Eleven Header");
        }
            break;
            
            
        case SettingsSectionTwelve:
        {
            title = ECDLocalizedString(@"Localized Section Twelve Header", @"Twelve Header");
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

-(void)handleAdHocStartAnswerEngine
{
    NSLog(@"Starting an ad-hoc Answer Engine Session");
    
    NSString *aeContext = [self.selectAdHocAnswerEngineContextPicker currentSelection];
    
    UIViewController *answerEngineController = [[EXPERTconnect shared] startAnswerEngine:aeContext];
    [self.navigationController pushViewController:answerEngineController animated:YES];
}

-(void)handleAdHocShowLicense
{
    NSLog(@"Showing the ad-hoc License");
    
    ECDLicenseViewController *license = [[ECDLicenseViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:license animated:YES];
}

@end
