//
//  ECDCustomizeThemeViewController.m
//  EXPERTconnectDemo
//
//  Created by AgilizTech Mac on 09/12/15.
//  Copyright © 2015 Humanify, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "ECDCustomizeThemeViewController.h"
#import "ECDUserDefaultKeys.h"
#import "ECDLocalization.h"

#import <EXPERTconnect/EXPERTconnect.h>
#import <EXPERTconnect/ECSTheme.h>

typedef NS_ENUM(NSInteger, SettingsSections)
{
	 SettingsSectionShowAvatarImages,
	 SettingsSectionCount
};

typedef NS_ENUM(NSInteger, WorkflowEscalateToChatSectionRows)
{
	 ThemeAvatarImagesSectionRowStart,
	 ThemeAvatarImagesSectionRowCount
};

@interface ECDCustomizeThemeViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UISwitch *showAvatarImagesSwitch;

@end

@implementation ECDCustomizeThemeViewController

- (void)viewDidLoad {
	 [super viewDidLoad];
	 
	 self.navigationItem.title = @"Theme Customization";
	 
	 ECSTheme *theme = [[EXPERTconnect shared] theme];
	 
	 self.view.backgroundColor = theme.primaryBackgroundColor;
	 self.tableView.backgroundColor = theme.primaryBackgroundColor;
	 
	 [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
	 
	 self.tableView.sectionHeaderHeight = 42.0f;
	 self.tableView.sectionFooterHeight = 0.0f;
	 
	 self.showAvatarImagesSwitch = [UISwitch new];
	 NSString *switchState = [[NSUserDefaults standardUserDefaults]
							  stringForKey:[NSString stringWithFormat:@"%@", ECDShowAvatarImagesKey]];
	 if (!switchState) {
		  [self.showAvatarImagesSwitch setOn:YES animated:NO];
	 }
	 else
	 {
		  self.showAvatarImagesSwitch.on = [switchState intValue];
	 }
	 [self.showAvatarImagesSwitch addTarget:self
									 action:@selector(showAvatarImagesSwitchChanged:)
						   forControlEvents:UIControlEventValueChanged];
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
		  case SettingsSectionShowAvatarImages:
			   rowCount = ThemeAvatarImagesSectionRowCount;
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
		  case SettingsSectionShowAvatarImages:
			   switch (indexPath.row) {
					case ThemeAvatarImagesSectionRowStart:
						 cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartShowAvatarImagesLabel, @"Show Avatar Images");
						 cell.accessoryView = self.showAvatarImagesSwitch;
						 self.showAvatarImagesSwitch.tintColor = theme.primaryColor;
						 self.showAvatarImagesSwitch.onTintColor = theme.primaryColor;
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	 return tableView.sectionHeaderHeight;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	 NSString *title = nil;
	 switch (section) {
			   
		  case SettingsSectionShowAvatarImages:
		  {
			   NSString *versionString = ECDLocalizedString(ECDLocalizedStartShowAvatarImagesHeader, @"Hide/Show Avatar Images");
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

- (void)showAvatarImagesSwitchChanged:(id)sender
{
	 [[NSUserDefaults standardUserDefaults] setObject:@(self.showAvatarImagesSwitch.on) forKey:ECDShowAvatarImagesKey];
	 
	 if(self.showAvatarImagesSwitch.on == NO)
	 {
		  [EXPERTconnect shared].theme.showAvatarImages = NO;
	 }
	 else
	 {
		  [EXPERTconnect shared].theme.showAvatarImages = YES;
	 }
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
