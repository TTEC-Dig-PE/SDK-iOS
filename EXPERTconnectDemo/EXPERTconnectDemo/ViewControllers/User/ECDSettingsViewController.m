//
//  ECDSettingsViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECDSettingsViewController.h"

#import <AirshipKit/AirshipKit.h>

#import "ECDLicenseViewController.h"
#import "ECDUserDefaultKeys.h"
#import "ECDEnvironmentPicker.h"
#import "ECDRunModePicker.h"
#import "ECDLocalization.h"

#import <EXPERTconnect/EXPERTconnect.h>
#import <EXPERTconnect/ECSTheme.h>

typedef NS_ENUM(NSInteger, SettingsSections)
{
    SettingsSectionPushNotifications,
    SettingsSectionVersion,
    SettingsSectionEnvironment,
    SettingsSectionRunMode,
    SettingsSectionVoiceIt,
    SettingsSectionCount
};

typedef NS_ENUM(NSInteger, PushSectionRows)
{
    PushSectionRowRecieve,
    PushSectionRowCount
};

typedef NS_ENUM(NSInteger, LicenseSectionRows)
{
    LicenseSectionRowLicenses,
    LicenseSectionRowCount
};

typedef NS_ENUM(NSInteger, EnvironmentSectionRows)
{
    EnvironmentSectionRowLicenses,
    EnvironmentSectionRowCount
};

typedef NS_ENUM(NSInteger, VoiceItSectionRows)
{
    VoiceItSectionRowRecord,
    VoiceItSectionRowReset,
    VoiceItSectionRowAuthenticate,
    VoiceItSectionRowCount
};


typedef NS_ENUM(NSInteger, RunModeSectionRows)
{
    RunModeSectionRowLicenses,
    RunModeSectionRowCount
};

@interface ECDSettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet ECSButton *logoutButton;
@property (strong, nonatomic) UISwitch *pushNotificationSwitch;
@property (strong, nonatomic) ECDEnvironmentPicker *selectEnvironmentPicker;
@property (strong, nonatomic) ECDRunModePicker *selectRunModePicker;
@property (weak, nonatomic) IBOutlet UIView *bottomContainer;


@property (nonatomic, retain) NSMutableArray *environmentsArray;
@property (nonatomic, retain) NSMutableArray *runModeArray;

@end

@implementation ECDSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Settings";
    
    ECSTheme *theme = [[EXPERTconnect shared] theme];
    
    self.view.backgroundColor = theme.primaryBackgroundColor;
    self.tableView.backgroundColor = theme.primaryBackgroundColor;
    
    if ([[EXPERTconnect shared] authenticationRequired])
    {
        [self.logoutButton setEnabled:NO];
    }
    [self.logoutButton setTitle:ECSLocalizedString(ECSLocalizedLogoutButton, @"Log out button state.")
                       forState:UIControlStateNormal];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    self.tableView.sectionHeaderHeight = 42.0f;
    self.tableView.sectionFooterHeight = 0.0f;

    self.pushNotificationSwitch = [UISwitch new];
    self.pushNotificationSwitch.on = [[UAPush shared] userPushNotificationsEnabled];
    [self.pushNotificationSwitch addTarget:self
                                    action:@selector(pushNotificationSwitchChanged:)
                          forControlEvents:UIControlEventValueChanged];
    self.bottomContainer.backgroundColor = theme.secondaryBackgroundColor;
    
    // self.environmentsArray = [NSMutableArray new];
    // self.runModeArray = [NSMutableArray new];
    
    self.selectEnvironmentPicker = [ECDEnvironmentPicker new];
    self.selectRunModePicker = [ECDRunModePicker new];
    
    // [self.environmentsArray addObject:@"IntDev"];
    // [self.environmentsArray addObject:@"Demo"];
    
    // [self.runModeArray addObject:@"Expert Demo"];
    // [self.runModeArray addObject:@"Horizon Demo"];
    
    // [self.selectEnvironmentPicker setDataSource: self];
    // [self.selectEnvironmentPicker setDelegate: self];
    // [self.selectEnvironmentPicker setFrame: CGRectMake(10.0f, 50.0f, 100.0f, 200.0f)];
    [self.selectEnvironmentPicker setup];
    [self.selectRunModePicker setup];
    // [self.selectEnvironmentPicker setFrame: CGRectMake(0.0f, 0.0f, 100.0f, 200.0f)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Number of components.
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.environmentsArray count];
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.environmentsArray objectAtIndex: row];
}

// Do something with the selected row.
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"You selected this: %@", [self.environmentsArray objectAtIndex: row]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SettingsSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    switch (section) {
        case SettingsSectionPushNotifications:
            rowCount = PushSectionRowCount;
            break;
            
        case SettingsSectionVersion:
            rowCount = LicenseSectionRowCount;
            break;
            
        case SettingsSectionEnvironment:
            rowCount = EnvironmentSectionRowCount;
            break;
            
        case SettingsSectionRunMode:
            rowCount = RunModeSectionRowCount;
            break;
            
        case SettingsSectionVoiceIt:
            rowCount = VoiceItSectionRowCount;
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
        case SettingsSectionPushNotifications:
            switch (indexPath.row) {
                case PushSectionRowRecieve:
                    cell.textLabel.text = ECSLocalizedString(ECSLocalizedReceiveNotificationsRow, @"Receive Push Notifications");
                    cell.accessoryView = self.pushNotificationSwitch;
                    self.pushNotificationSwitch.tintColor = theme.primaryColor;
                    self.pushNotificationSwitch.onTintColor = theme.primaryColor;
                    break;
                default:
                    break;
            }
            break;
            
        case SettingsSectionVersion:
            switch (indexPath.row) {
                case LicenseSectionRowLicenses:
                    cell.textLabel.text = ECSLocalizedString(ECSLocalizedLicensesRow, @"Open Source Licenses");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionEnvironment:
            switch (indexPath.row) {
                case LicenseSectionRowLicenses:
                    cell.textLabel.text = @"Dev";
                    cell.accessoryView = self.selectEnvironmentPicker;

                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionRunMode:
            switch (indexPath.row) {
                case LicenseSectionRowLicenses:
                    cell.textLabel.text = @"Expert Demo";
                    cell.accessoryView = self.selectRunModePicker;
                    break;
                    
                default:
                    break;
            }
            break;
            
            
        case SettingsSectionVoiceIt:
            switch (indexPath.row) {
                case VoiceItSectionRowAuthenticate:
                    cell.textLabel.text = @"Authenticate with VoiceIt";
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                    
                case VoiceItSectionRowRecord:
                    cell.textLabel.text = @"Record Voice Print";
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                    
                case VoiceItSectionRowReset:
                    cell.textLabel.text = @"Clear All Voice Prints";
                    cell.accessoryType = UITableViewCellAccessoryNone;
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
    if (indexPath.section == SettingsSectionVersion && indexPath.row == LicenseSectionRowLicenses)
    {
        ECDLicenseViewController *license = [[ECDLicenseViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:license animated:YES];
    } else if (indexPath.section == SettingsSectionVoiceIt && indexPath.row == VoiceItSectionRowAuthenticate) {
        [self voiceItAuthenticate:nil];
    } else if (indexPath.section == SettingsSectionVoiceIt && indexPath.row == VoiceItSectionRowRecord) {
        [self voiceItRecord:nil];
    } else if (indexPath.section == SettingsSectionVoiceIt && indexPath.row == VoiceItSectionRowReset) {
        [self voiceItReset:nil];
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
        case SettingsSectionPushNotifications:
            title = ECSLocalizedString(ECSLocalizedPushNotificationsHeader, @"Push Notifications");
            break;
            
        case SettingsSectionVersion:
        {
            NSString *versionString = ECSLocalizedString(ECSLocalizedVersionHeader, @"Version");
            versionString = [NSString stringWithFormat:versionString, [[EXPERTconnect shared] EXPERTconnectVersion]];
            title = versionString;
        }
            break;
            
        case SettingsSectionEnvironment:
        {
            NSString *versionString = ECDLocalizedString(ECDLocalizedEnvironmentsHeader, @"Version");
            versionString = [NSString stringWithFormat:versionString, [[EXPERTconnect shared] EXPERTconnectVersion]];
            title = versionString;
        }
            break;
            
        case SettingsSectionRunMode:
        {
            NSString *versionString = ECDLocalizedString(ECDLocalizedRunModeHeader, @"Version");
            versionString = [NSString stringWithFormat:versionString, [[EXPERTconnect shared] EXPERTconnectVersion]];
            title = versionString;
        }
            break;
            
        case SettingsSectionVoiceIt:
        {
            NSString *versionString = ECDLocalizedString(ECDLocalizedVoiceItHeader, @"Version");
            versionString = [NSString stringWithFormat:versionString, [[EXPERTconnect shared] EXPERTconnectVersion]];
            title = versionString;
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

- (IBAction)logoutTapped:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ECSLocalizedString(ECSLocalizeLogoutTitle, nil)
                                                                             message:ECSLocalizedString(ECSLocalizeLogoutText, nil) preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizeNo, nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:ECSLocalizedString(ECSLocalizeYes, nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [[EXPERTconnect shared] setUserToken:nil];
                                                      }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)voiceItAuthenticate:(id)sender
{
    [[EXPERTconnect shared] voiceAuthRequested:[[EXPERTconnect shared] userToken] callback:^(NSString *response) {
        // Alert Agent to the response:
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:response delegate:nil cancelButtonTitle:ECSLocalizedString(ECSLocalizedOkButton, @"OK") otherButtonTitles:nil];
        [alert show];
    }];

}

- (void)voiceItRecord:(id)sender
{
    [[EXPERTconnect shared] recordNewEnrollment];
}

- (void)voiceItReset:(id)sender
{
    [[EXPERTconnect shared] clearEnrollments];
}

- (void)pushNotificationSwitchChanged:(id)sender
{
    [[UAPush shared] setUserPushNotificationsEnabled:self.pushNotificationSwitch.on];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.pushNotificationSwitch.on) forKey:ECDPushNotificationsEnabledKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
