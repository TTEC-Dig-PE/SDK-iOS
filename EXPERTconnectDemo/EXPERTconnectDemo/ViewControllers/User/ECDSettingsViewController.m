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
#import <EXPERTconnect/EXPERTconnect.h>
#import <EXPERTconnect/ECSTheme.h>

typedef NS_ENUM(NSInteger, SettingsSections)
{
    SettingsSectionPushNotifications,
    SettingsSectionVersion,
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

@interface ECDSettingsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet ECSButton *logoutButton;
@property (strong, nonatomic) UISwitch *pushNotificationSwitch;
@property (weak, nonatomic) IBOutlet UIView *bottomContainer;

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
        case SettingsSectionPushNotifications:
            rowCount = PushSectionRowCount;
            break;
        
        case SettingsSectionVersion:
            rowCount = LicenseSectionRowCount;
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
    }
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
