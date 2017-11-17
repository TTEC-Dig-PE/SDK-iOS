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
#import "ECDAdHocFormsController.h"
#import "ECDAdHocViewController.h"
#import "ECDAdHocVideoChatPicker.h"
#import "ECDUserDefaultKeys.h"
#import "ECDAdHocChatPicker.h"
#import "ECDAdHocVoiceCallbackPicker.h"
#import "ECDAdHocAnswerEngineContextPicker.h"
#import "ECDAdHocFormsPicker.h"
#import "ECDAdHocWebPagePicker.h"
#import "ECDEnvironmentPicker.h"
#import "ECDRunModePicker.h"
#import "ECDLocalization.h"
//#import "ECDCalendarViewController.h"
//#import "ECDTextEditorViewController.h"
#import "ECDBeaconViewController.h"
#import "ECDReportBugViewController.h"

#import "ECDChatConfigVC.h"
#import "ECDBreadcrumbConfigVC.h"
#import "ECDJourneyConfigVC.h"
#import "ECDDecisionConfigVC.h"

#import <EXPERTconnect/EXPERTconnect.h>
#import <EXPERTconnect/ECSTheme.h>

// High-level SDK Services
// =======================
//
// Start an AdHoc Chat
// Start an AdHoc Video Chat (CafeX)
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
// Submit an AdHoc Form
// Upload an AdHoc image
// Download an AdHoc image
//
// Display the Expert Select Voice Callback Dialog
// Display the Expert Select Video Dialog
// Display the Select Expert and Channel Dialog
//
//
// SDK Provided UI Supports - Carousel Items
// =========================================
// Five Stars Control
// Thumbs Up / Thumbs Down Control
// WYSIWYG Editor
// Date Picker
// Date Range
//
//
// Additional SDK Services (may require new APIs to support)
// =========================================================
//
// Retrieve Available Agents by Skill?
// Retrieve list of skills with availability of each (# agents online, # agents available)
// Retrieve list of agents (all) with availability state of each
// Estimated time to wait for skill X" and ?
// Generic API endpoint
// Push Notifications
// Start any High-level SDK Services with Host App ViewController or at least Host App controlled Navigation
// AdHoc startup Async Stomp Channel, Register for Notifications
//

typedef NS_ENUM(NSInteger, SettingsSections)
{
	 SettingsSectionAdHocChat,
//     SettingsSectionAdHocVideoChat,
	 SettingsSectionAdHocAnswerEngine,
	 SettingsSectionAdHocForms,
	 SettingsSectionAdHocUserProfile,
	 SettingsSectionAdHocVoiceCallback,
//	 SettingsSectionAdHocEmailMessage,
//	 SettingsSectionAdHocSMSMessage,
	 SettingsSectionAdHocWebPage,
	 SettingsSectionAdHocAnswerEngineHistory,
	 SettingsSectionAdHocChatHistory,
//     SettingsSectionAdHocSelectExpert,
	 SettingsSectionAdHocExtendedUserProfile,
	 SettingsSectionAdHocAPIConfig,
	 SettingsSectionAdHocSubmitForm,
//	 SettingsSectionAdHocDatePicker,
//	 SettingsSectionAdHocWYSIWYGEditor,
	 SettingsSectionSeventeen,
	 SettingsSectionCount
};


typedef NS_ENUM(NSInteger, AdHocChatSectionRows)
{
	 AdHocChatSectionRowStart,
     AdHocChatSectionRowBreadcrumb,
     AdHocChatSectionRowJourney,
     AdHocChatSectionRowDecision,
     AdHocChatSectionRowDebug,
	 AdHocChatSectionRowCount
};

typedef NS_ENUM(NSInteger, VideoChatSectionRows)
{
	 AdHocVideoChatRowStart,
	 AdHocVideoChatSectionRowCount
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
	 AdHocUtilityBeaconRow,
	 AdHocUserProfileRowCount
};

typedef NS_ENUM(NSInteger, VoiceCallbackSectionRows)
{
	 AdHocVoiceCallbackSectionRowStart,
	 AdHocVoiceCallbackRowCount
};

//typedef NS_ENUM(NSInteger, EmailMessageSectionRows)
//{
//	 AdHocEmailMessageSectionRowStart,
//	 AdHocEmailMessageRowCount
//};
//
//typedef NS_ENUM(NSInteger, SMSMessageSectionRows)
//{
//	 AdHocSMSMessageSectionRowStart,
//	 AdHocSMSMessageRowCount
//};

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

typedef NS_ENUM(NSInteger, APIConfigSectionRows)
{
	 AdHocAPIConfigRowStart,
	 AdHocAPIConfigRowCount
};

typedef NS_ENUM(NSInteger, AdHocSubmitFormRows)
{
	 AdHocSubmitFormRowStart,
	 AdHocSubmitFormRowCount
};

//typedef NS_ENUM(NSInteger, AdHocDatePickerRows)
//{
//	 AdHocDatePickerRowStart,
//	 AdHocDatePickerRowCount
//};
//
//typedef NS_ENUM(NSInteger, AdHocWYSIWYGEditorRows)
//{
//	 AdHocWYSIWYGEditorRowStart,
//	 AdHocWYSIWYGEditorRowCount
//};

typedef NS_ENUM(NSInteger, SettingsSectionRowSeventeenRows)
{
	 SettingsSectionSeventeenRowStart,
	 SettingsSectionSeventeenRowCount
};

@interface ECDAdHocViewController () <UITableViewDataSource, UITableViewDelegate, ECSFormViewDelegate> {
	 CLLocation *currentLocation;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) ECDAdHocChatPicker *selectAdHocChatPicker;
@property (strong, nonatomic) ECDAdHocVoiceCallbackPicker *selectAdHocVoiceCallbackPicker;
@property (strong, nonatomic) ECDAdHocAnswerEngineContextPicker *selectAdHocAnswerEngineContextPicker;
@property (strong, nonatomic) ECDAdHocVideoChatPicker *selectAdHocVideoChatPicker;
@property (strong, nonatomic) ECDAdHocFormsPicker *selectAdHocFormsPicker;
@property (strong, nonatomic) ECDAdHocWebPagePicker *selectAdHocWebPagePicker;
@end

int chatAgentsLoggedOn,videoChatAgentsLoggedOn,callbackAgentsLoggedOn;
bool chatAgentAvailable,videoChatAgentAvailable,callbackAgentAvailable;
int chatEstimatedWait,videoChatEstimatedWait,callbackEstimatedWait;

bool _chatActive;

ECSFormViewController *_formsController;

@implementation ECDAdHocViewController

- (void)viewDidLoad {
	 [super viewDidLoad];
	 
	 self.navigationItem.title = @"AdHoc";
    
    // This means we have not fetched data from server yet.
    chatAgentsLoggedOn = -1;
    videoChatAgentsLoggedOn = -1;
    callbackAgentsLoggedOn = -1;
	 
	 ECSTheme *theme = [[EXPERTconnect shared] theme];
	 
	 self.locationManager = [[CLLocationManager alloc] init];
    
    [self checkAndUpdateLocaleOverride];
	 
	 // In our demo app, we will only use GPS while the app is in the foreground
	 [self.locationManager requestWhenInUseAuthorization];
	 
	 if ([CLLocationManager locationServicesEnabled]) {
		  self.locationManager.delegate = self;
		  self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		  self.locationManager.distanceFilter = 5; // meters
		  
		  [self.locationManager startUpdatingLocation];
	 }
	 
	 self.view.backgroundColor = theme.primaryBackgroundColor;
	 self.tableView.backgroundColor = theme.primaryBackgroundColor;
	 
	 [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
	 
	 self.tableView.sectionHeaderHeight = 42.0f;
	 self.tableView.sectionFooterHeight = 0.0f;
	 
	 self.selectAdHocChatPicker = [ECDAdHocChatPicker new];
	 self.selectAdHocAnswerEngineContextPicker = [ECDAdHocAnswerEngineContextPicker new];
	 self.selectAdHocVideoChatPicker = [ECDAdHocVideoChatPicker new];
	 self.selectAdHocFormsPicker = [ECDAdHocFormsPicker new];
	 self.selectAdHocVoiceCallbackPicker = [ECDAdHocVoiceCallbackPicker new];
	 self.selectAdHocWebPagePicker = [ECDAdHocWebPagePicker new];
	 
	 [self.selectAdHocChatPicker setup];
	 [self.selectAdHocAnswerEngineContextPicker setup];
	 [self.selectAdHocVideoChatPicker setup];
	 [self.selectAdHocFormsPicker setup];
	 [self.selectAdHocVoiceCallbackPicker setup];
	 [self.selectAdHocWebPagePicker setup];
	 
	 [[NSNotificationCenter defaultCenter] addObserver:self
											  selector:@selector(callbackEnded:)
												  name:ECSCallbackEndedNotification
												object:nil];
	 
	 [[NSNotificationCenter defaultCenter] addObserver:self
											  selector:@selector(chatInfoUpdated:)
												  name:@"ChatSkillAgentInfoUpdated"
												object:nil];
	 [[NSNotificationCenter defaultCenter] addObserver:self
											  selector:@selector(videoChatInfoUpdated:)
												  name:@"VideoChatSkillAgentInfoUpdated"
												object:nil];
	 [[NSNotificationCenter defaultCenter] addObserver:self
											  selector:@selector(callbackInfoUpdated:)
												  name:@"CallbackSkillAgentInfoUpdated"
												object:nil];
}

- (void)didReceiveMemoryWarning {
	 [super didReceiveMemoryWarning];
	 // Dispose of any resources that can be recreated.
}

#pragma mark Location Functions

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (fabs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        currentLocation = location;
        
        //[self getLocationAddress:currentLocation];
    }
}

-(void) getLocationAddress:(CLLocation *)location {

    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    
    [ceo reverseGeocodeLocation:location
              completionHandler:^(NSArray *placemarks, NSError *error)
    {
                  
        if(!error)
        {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSLog(@"placemark %@",placemark);
            //String to hold address
            NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
            NSLog(@"addressDictionary %@", placemark.addressDictionary);

            NSLog(@"placemark %@",placemark.region);
            NSLog(@"placemark %@",placemark.country);  // Give Country Name
            NSLog(@"placemark %@",placemark.locality); // Extract the city name
            NSLog(@"location %@",placemark.name);
            NSLog(@"location %@",placemark.ocean);
            NSLog(@"location %@",placemark.postalCode);
            NSLog(@"location %@",placemark.subLocality);

            NSLog(@"location %@",placemark.location);
            //Print the location to console
            NSLog(@"I am currently at %@",locatedAt);
        }
        else
        {
            NSLog(@"Could not locate");
        }
    }];
}

#pragma mark TableView Construction

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
			   
//          case SettingsSectionAdHocVideoChat:
//               rowCount = AdHocVideoChatSectionRowCount;
//               break;
			   
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
			   
//		  case SettingsSectionAdHocEmailMessage:
//			   rowCount = AdHocEmailMessageRowCount;
//			   break;
//			   
//		  case SettingsSectionAdHocSMSMessage:
//			   rowCount = AdHocSMSMessageRowCount;
//			   break;
			   
		  case SettingsSectionAdHocWebPage:
			   rowCount = AdHocWebPageRowCount;
			   break;
			   
		  case SettingsSectionAdHocAnswerEngineHistory:
			   rowCount = AdHocAnswerEngineHistoryRowCount;
			   break;
			   
		  case SettingsSectionAdHocChatHistory:
			   rowCount = AdHocChatHistoryRowCount;
			   break;
			   
//          case SettingsSectionAdHocSelectExpert:
//               rowCount = AdHocSelectExpertRowCount;
//               break;
			   
		  case SettingsSectionAdHocExtendedUserProfile:
			   rowCount = AdHocExtendedUserProfileRowCount;
			   break;
			   
		  case SettingsSectionAdHocAPIConfig:
			   rowCount = AdHocAPIConfigRowCount;
			   break;
			   
//          case SettingsSectionAdHocSubmitForm:
//               rowCount = AdHocSubmitFormRowCount;
//               break;
			   
//		  case SettingsSectionAdHocDatePicker:
//			   rowCount = AdHocDatePickerRowCount;
//			   break;
//			   
//		  case SettingsSectionAdHocWYSIWYGEditor:
//			   rowCount = AdHocWYSIWYGEditorRowCount;
//			   break;
			   
		  case SettingsSectionSeventeen:
			   rowCount = SettingsSectionSeventeenRowCount;
			   break;
			   
		  default:
			   break;
	 }
	 
	 return rowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
	 return 44;
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

//                       cell.textLabel.text = @"Test Chat";
                        cell.textLabel.text = ECDLocalizedString(ECDLocalizedTestChatLabel, @"Test Chat");
                        break;
                       
                   case AdHocChatSectionRowBreadcrumb:
                       
//                       cell.textLabel.text = @"Test Breadcrumbs";
                       cell.textLabel.text = ECDLocalizedString(ECDLocalizedTestBreadcrumbsLabel, @"Test Breadcrumbs");
                       break;
                       
                   case AdHocChatSectionRowJourney:
//                       cell.textLabel.text = @"Test Journey";
                         cell.textLabel.text = ECDLocalizedString(ECDLocalizedTestJourneyLabel, @"Test Journey");
                       break;
                    
                   case AdHocChatSectionRowDecision:
                         cell.textLabel.text = ECDLocalizedString(ECDLocalizedTestDecisionLabel, @"Test Decision");
                       break;

                   case AdHocChatSectionRowDebug:
                       cell.textLabel.text = ECDLocalizedString(ECDLocalizedTestDebugLabel, @"View SDK Debug");
                       break;

					default:
						 break;
			   }
			   break;
			   
//          case SettingsSectionAdHocVideoChat:
//               switch (indexPath.row) {
//                    case AdHocVideoChatRowStart:
//                         cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartVideoChatLabel, @"AdHoc Video Chat");
//                         if (videoChatAgentsLoggedOn) {
//                              cell.textLabel.text = [NSString stringWithFormat:@"%@",
//                                                     cell.textLabel.text];
//                         }
//                         cell.accessoryView = self.selectAdHocVideoChatPicker;
//                         break;
//
//                    default:
//                         break;
//               }
//               break;
			   
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
						 
					case AdHocUtilityBeaconRow:
						 cell.textLabel.text = ECDLocalizedString(ECDLocalizedBeaconLabel, @"iBeacon Demo");
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
					  if (callbackAgentsLoggedOn) {
						   cell.textLabel.text = [NSString stringWithFormat:@"%@",
												  cell.textLabel.text];
					  }
					  cell.accessoryView = self.selectAdHocVoiceCallbackPicker;
					  break;
					  
				 default:
					  break;
			   }
			   break;
			   
//			   
//		  case SettingsSectionAdHocEmailMessage:
//			   switch (indexPath.row) {
//					case AdHocUserProfileSectionRowStart:
//						 cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartEmailMessageLabel, @"AdHoc Email Message");
//						 cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//						 break;
//						 
//					default:
//						 break;
//			   }
//			   break;
//			   
//			   
//		  case SettingsSectionAdHocSMSMessage:
//			   switch (indexPath.row) {
//					case AdHocSMSMessageSectionRowStart:
//						 cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartSMSMessageLabel, @"AdHoc SMS Message");
//						 cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//						 break;
//						 
//					default:
//						 break;
//			   }
//			   break;
//			   
			   
		  case SettingsSectionAdHocWebPage:
			   switch (indexPath.row) {
					case 0:
						 cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartWebPageLabel, @"AdHoc Web Page");
						 cell.accessoryView = self.selectAdHocWebPagePicker;
						 break;
						 
					default:
						 break;
			   }
			   break;
			   
			   
		  case SettingsSectionAdHocAnswerEngineHistory:
			   switch (indexPath.row) {
					case 0:
						 cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartAnswerEngineHistoryLabel, @"AdHoc Answer Engine History");
						 cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
						 break;
						 
					default:
						 break;
			   }
			   break;
			   
			   
		  case SettingsSectionAdHocChatHistory:
			   switch (indexPath.row) {
					case 0:
						 cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartChatHistoryLabel, @"AdHoc Chat History");
						 cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
						 break;
						 
					default:
						 break;
			   }
			   break;
			   
			   
//          case SettingsSectionAdHocSelectExpert:
//               switch (indexPath.row) {
//                    case 0:
//                         cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartSelectExpertLabel, @"AdHoc Select Expert Dialog");
//                         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//                         break;
//
//                    default:
//                         break;
//               }
//               break;
			   
			   
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
			   
			   
		  case SettingsSectionAdHocAPIConfig:
			   switch (indexPath.row) {
					case 0:
						 cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartAPIConfigLabel, @"AdHoc API Configuration");
						 cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
						 break;
						 
					default:
						 break;
			   }
			   break;
			   
			   
//          case SettingsSectionAdHocSubmitForm:
//               switch (indexPath.row) {
//                    case 0:
//                         cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartSubmitFormLabel, @"AdHoc Submit Form");
//                         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//                         break;
//
//                    default:
//                         break;
//               }
//               break;
			   
			   
//		  case SettingsSectionAdHocDatePicker:
//			   switch (indexPath.row) {
//					case AdHocDatePickerRowStart:
//						 cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartDatePickerLabel, @"AdHoc Date Picker");
//						 cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//						 break;
//						 
//					default:
//						 break;
//			   }
//			   break;
//			   
//		  case SettingsSectionAdHocWYSIWYGEditor:
//			   switch (indexPath.row) {
//					case AdHocWYSIWYGEditorRowStart:
//						 cell.textLabel.text = ECDLocalizedString(ECDLocalizedStartWYSIWYGEditorLabel, @"AdHoc WYSIWYG Editor");
//						 cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//						 break;
//						 
//					default:
//						 break;
//			   }
//			   break;
			   
		  case SettingsSectionSeventeen:
			   switch (indexPath.row) {
					case 0:
						 cell.textLabel.text = ECDLocalizedString(@"Localized Section Seventeen", @"Section Seventeen");
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
    
    if (indexPath.section == SettingsSectionAdHocChat && indexPath.row == AdHocChatSectionRowBreadcrumb)
    {
        [self handleBreadcrumbConfig];
    }
    
    if (indexPath.section == SettingsSectionAdHocChat && indexPath.row == AdHocChatSectionRowJourney)
    {
        [self handleJourneyConfig];
    }
     
     if (indexPath.section == SettingsSectionAdHocChat && indexPath.row == AdHocChatSectionRowDecision)
     {
          [self handleDecisionConfig];
     }
    
    if (indexPath.section == SettingsSectionAdHocChat && indexPath.row == AdHocChatSectionRowDebug)
    {
        [self handleSDKDebugConfig];
    }
	 
//     if (indexPath.section == SettingsSectionAdHocVideoChat && indexPath.row == AdHocVideoChatRowStart)
//     {
//          [self handleAdHocStartVideoChat];
//     }
	 
	 if (indexPath.section == SettingsSectionAdHocAnswerEngine && indexPath.row == AdHocAnswerEngineRowStart)
	 {
		  [self handleAdHocStartAnswerEngine];
	 }
	 
	 if (indexPath.section == SettingsSectionAdHocForms && indexPath.row == AdHocFormsSectionRowStart)
	 {
		  [self handleAdHocRenderForm];
	 }
	 
	 if (indexPath.section == SettingsSectionAdHocUserProfile)
	 {
		  switch (indexPath.row) {
			   case AdHocUserProfileSectionRowStart:
					[self handleAdHocEditUserProfile];
					break;
					
			   case AdHocUtilityBeaconRow:
					[self handleAdHocBeaconDemo];
					
			   default:
					break;
		  }
	 }
	 
	 if (indexPath.section == SettingsSectionAdHocVoiceCallback && indexPath.row == AdHocVoiceCallbackSectionRowStart)
	 {
		  [self handleAdHocVoiceCallback];
	 }
	 
//	 if (indexPath.section == SettingsSectionAdHocEmailMessage && indexPath.row == AdHocEmailMessageSectionRowStart)
//	 {
//		  [self handleAdHocEmailMessage];
//	 }
//	 
//	 if (indexPath.section == SettingsSectionAdHocSMSMessage && indexPath.row == AdHocSMSMessageSectionRowStart)
//	 {
//		  [self handleAdHocSMSMessage];
//	 }
	 
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
	 
//     if (indexPath.section == SettingsSectionAdHocSelectExpert && indexPath.row == AdHocSelectExpertRowStart)
//     {
//          [self handleAdHocSelectExpert];
//     }
	 
	 if (indexPath.section == SettingsSectionAdHocExtendedUserProfile && indexPath.row == AdHocExtendedUserProfileRowStart)
	 {
		  [self handleAdHocEditUserProfileExtended];
	 }
	 
	 if (indexPath.section == SettingsSectionAdHocAPIConfig && indexPath.row == AdHocAPIConfigRowStart)
	 {
		  [self handleAdHocAPIConfigEditor];
	 }
	 
	 if (indexPath.section == SettingsSectionAdHocSubmitForm && indexPath.row == AdHocSubmitFormRowStart)
	 {
		  [self handleAdHocSubmitForm];
	 }
	 
//	 if (indexPath.section == SettingsSectionAdHocDatePicker && indexPath.row == AdHocDatePickerRowStart)
//	 {
//		  [self handleAdHocShowCalendar];
//	 }
//	 
//	 if (indexPath.section == SettingsSectionAdHocWYSIWYGEditor && indexPath.row == AdHocWYSIWYGEditorRowStart)
//	 {
//		  [self handleAdHocShowTextEditor];
//	 }
	 
	 if (indexPath.section == SettingsSectionSeventeen && indexPath.row == SettingsSectionSeventeenRowStart)
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
              title = [NSString stringWithFormat:@"User: %@", [EXPERTconnect shared].userName];
			   //title = ECDLocalizedString(ECDLocalizedStartChatHeader, @"Ad-Hoc SDK Tests");
			   /*if (chatEstimatedWait>-1 && chatAgentsLoggedOn > -1) {
					title = [NSString stringWithFormat:@"%@ - %@: %d %@. %@: %d",
							 title,
							 ECDLocalizedString(ECDLocalizedWaitString, @"Wait"),
							 (chatEstimatedWait/60),
							 ECDLocalizedString(ECDLocalizedMinuteString, @"minutes"),
							 ECDLocalizedString(ECDLocalizedAgentString, @"Agents"),
							 chatAgentsLoggedOn];
			   } else if(chatAgentsLoggedOn == -1){
                   title = [NSString stringWithFormat:@"%@ - %@", title, @"Loading data..."];
               } else {
					title = [NSString stringWithFormat:@"%@ - %@", title, ECDLocalizedString(ECDLocalizedNoAgents, @"No Agents Available.")];
			   }*/
		  }
			   break;
//          case SettingsSectionAdHocVideoChat:
//          {
//               title = ECDLocalizedString(ECDLocalizedStartVideoChatHeader, @"AdHoc Video Chat");
//               if (videoChatEstimatedWait>-1 && videoChatAgentsLoggedOn > -1) {
//                    title = [NSString stringWithFormat:@"%@ - %@: %d %@. %@: %d",
//                             title,
//                             ECDLocalizedString(ECDLocalizedWaitString, @"Wait"),
//                             (videoChatEstimatedWait/60),
//                             ECDLocalizedString(ECDLocalizedMinuteString, @"minutes"),
//                             ECDLocalizedString(ECDLocalizedAgentString, @"Agents"),
//                             videoChatAgentsLoggedOn];
//               } else if(videoChatAgentsLoggedOn == -1){
//                   title = [NSString stringWithFormat:@"%@ - %@", title, @"Loading data..."];
//               } else {
//                    title = [NSString stringWithFormat:@"%@ - %@", title, ECDLocalizedString(ECDLocalizedNoAgents, @"No Agents Available.")];
//               }
//          }
//               break;
			   
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
			   if (callbackEstimatedWait>-1 && callbackAgentsLoggedOn > -1) {
					title = [NSString stringWithFormat:@"%@ - %@: %d %@. %@: %d",
							 title,
							 ECDLocalizedString(ECDLocalizedWaitString, @"Wait"),
							 (callbackEstimatedWait/60),
							 ECDLocalizedString(ECDLocalizedMinuteString, @"minutes"),
							 ECDLocalizedString(ECDLocalizedAgentString, @"Agents"),
							 callbackAgentsLoggedOn];
               } else if(callbackAgentsLoggedOn == -1){
                   title = [NSString stringWithFormat:@"%@ - %@", title, @"Loading data..."];
			   } else {
					title = [NSString stringWithFormat:@"%@ - %@", title, ECDLocalizedString(ECDLocalizedNoAgents, @"No Agents Available.")];
			   }

		  }
			   break;
			   
			   
//		  case SettingsSectionAdHocEmailMessage:
//		  {
//			   title = ECDLocalizedString(ECDLocalizedStartEmailMessageHeader, @"AdHoc Email Messsage");
//		  }
//			   break;
//			   
//		  case SettingsSectionAdHocSMSMessage:
//		  {
//			   title = ECDLocalizedString(ECDLocalizedStartSMSMessageHeader, @"AdHoc SMS Message");
//		  }
//			   break;
//			   
			   
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
			   
			   
//          case SettingsSectionAdHocSelectExpert:
//          {
//               title = ECDLocalizedString(ECDLocalizedStartSelectExpertHeader, @"AdHoc Select Expert Dialog");
//          }
//               break;
			   
			   
		  case SettingsSectionAdHocExtendedUserProfile:
		  {
			   title = ECDLocalizedString(ECDLocalizedStartExtendedUserProfileHeader, @"Ad Hoc Extended User Profile");
		  }
			   break;
			   
			   
		  case SettingsSectionAdHocAPIConfig:
		  {
			   title = ECDLocalizedString(ECDLocalizedStartAPIConfigHeader, @"Ad Hoc Extended User Profile");
		  }
			   break;
			   
			   
//          case SettingsSectionAdHocSubmitForm:
//          {
//               title = ECDLocalizedString(ECDLocalizedStartSubmitFormHeader, @"Ad Hoc Submit Form");
//          }
//               break;
			   
			   
//		  case SettingsSectionAdHocDatePicker:
//		  {
//			   title = ECDLocalizedString(ECDLocalizedStartDatePickerHeader, @"Ad Hoc Date Picker");
//		  }
//			   break;
//			   
//		  case SettingsSectionAdHocWYSIWYGEditor:
//		  {
//			   title = ECDLocalizedString(ECDLocalizedStartWYSIWYGEditorHeader, @"Ad Hoc WYSIWYG Editor");
//		  }
//			   break;
//			   
		  case SettingsSectionSeventeen:
		  {
			   title = ECDLocalizedString(@"Localized Section Seventeen Header", @"Seventeen Header");
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

#pragma mark Notification Functions

- (void)chatInfoUpdated:(NSNotification *)notification
{
    
    ECSSkillDetail *skill = notification.object;
    
    if(skill) {
        chatAgentsLoggedOn = skill.chatReady;
        chatAgentAvailable = (skill.active && skill.chatReady>0 && skill.queueOpen);
        chatEstimatedWait = skill.estWait;
    }
    [self.tableView reloadData];
}

- (void)videoChatInfoUpdated:(NSNotification *)notification
{
	 ECSSkillDetail *skill = notification.object;
    
	 if (skill) {
		  videoChatAgentsLoggedOn = skill.chatReady;
		  videoChatAgentAvailable = (skill.active && skill.chatReady>0 && skill.queueOpen);
		  videoChatEstimatedWait = skill.estWait;
	 }
	 [self.tableView reloadData];
}

- (void)callbackInfoUpdated:(NSNotification *)notification
{
	 ECSSkillDetail *skill = notification.object;
    
	 if (skill) {
		  callbackAgentsLoggedOn = skill.voiceReady;
		  callbackAgentAvailable = (skill.active && skill.voiceReady>0 && skill.queueOpen);
		  callbackEstimatedWait = skill.estWait;
	 }
	 [self.tableView reloadData];
}

- (void)callbackEnded:(NSNotification *)notification
{
	 if (![notification.userInfo[@"reason"] isEqualToString:@"UserCancelled"]) {
		  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Callback Completed"
																				   message:@"Thank you for contacting us!"
																			preferredStyle:UIAlertControllerStyleAlert];
		  
		  UIAlertAction *alertActionStop = [UIAlertAction actionWithTitle:@"Ok"
																	style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action)
											{
												 [alertController dismissViewControllerAnimated:YES completion:nil];
												 //[self dismissviewAndNotify:YES];
												 //[self.workflowDelegate voiceCallBackEnded];
											}];
		  
		  
		  [alertController addAction:alertActionStop];
		  [self presentViewController:alertController animated:YES completion:nil];
	 }
	 else
	 {
		  NSLog(@"Callback ended. Reason? %@", notification.userInfo[@"reason"]);
	 }
	 
}

#pragma mark - Ad-Hoc SDK Functions

-(void)localBreadCrumb:(NSString *)action
           description:(NSString *)desc
{
    ECSBreadcrumb *myBreadcrumb = [[ECSBreadcrumb alloc] initWithAction:action
                                                            description:desc
                                                                 source:@"AdHoc"
                                                            destination:@"Humanify"];
    myBreadcrumb.geoLocation = currentLocation;
    
    [[EXPERTconnect shared] breadcrumbSendOne:myBreadcrumb
                               withCompletion:^(ECSBreadcrumbResponse *response, NSError *error) {
        NSLog(@"Breadcrumb sent. Response=%@", response);
    }];
}

-(void)handleAdHocStartChat
{
	 /*NSLog(@"Starting an ad-hoc Chat Session");
	 
	 NSString *chatSkill = [self.selectAdHocChatPicker currentSelection];
    
    [self localBreadCrumb:@"Chat Started" description:[NSString stringWithFormat:@"Starting chat with skill %@", chatSkill]];
	 
	 // MAS - Oct-2015 - For demo app, do not show survey after chat. Workflows not implemented yet.
	 NSString *languageLocale = [NSString stringWithFormat:@"%@_%@",
								 [[NSLocale preferredLanguages] objectAtIndex:0],
								 [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]];
	 
    // Create the chat view
    if( !self.chatController || !_chatActive )
    {
        self.chatController = [[EXPERTconnect shared] startChat:chatSkill
                                                withDisplayName:@"Chat"
                                                     withSurvey:NO
                                             withChannelOptions:@{@"language": languageLocale, @"department": @"rental"}];
        
        // Add our custom left bar button
        self.chatController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                                           style:UIBarButtonItemStylePlain
                                                                                          target:self
                                                                                          action:@selector(backPushed:)];
        
        // Add our custom right bar button.
        self.chatController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"End Chat"
                                                                                            style:UIBarButtonItemStylePlain
                                                                                           target:self
                                                                                           action:@selector(endchatPushed:)];
        
        _chatActive = YES;
        [self.tableView reloadData]; // make it show continue chat
    }
    
    // Push it onto our navigation stack (so back buttons will work)
    [self.navigationController pushViewController:self.chatController animated:YES];*/
    
    ECDChatConfigVC *chatconfig = [[ECDChatConfigVC alloc] init];
    [self.navigationController pushViewController:chatconfig animated:YES]; 
	 
}

-(void)handleBreadcrumbConfig
{
    ECDBreadcrumbConfigVC *bcConfig = [[ECDBreadcrumbConfigVC alloc] init];
    [self.navigationController pushViewController:bcConfig animated:YES];
}

-(void)handleJourneyConfig
{
    ECDJourneyConfigVC *journeyConfig = [[ECDJourneyConfigVC alloc] init];
    [self.navigationController pushViewController:journeyConfig animated:YES];
}

-(void)handleDecisionConfig
{
     ECDDecisionConfigVC *decisionConfig = [ECDDecisionConfigVC new];
     [self.navigationController pushViewController:decisionConfig animated:YES];
}

-(void)handleSDKDebugConfig
{
    ECDReportBugViewController *decisionConfig = [ECDReportBugViewController new];
    [self.navigationController pushViewController:decisionConfig animated:YES];
}

-(void)handleAdHocVoiceCallback
{
	 NSLog(@"Starting an ad-hoc Voice Callback Session");
	 
	 NSString *callSkill = [self.selectAdHocVoiceCallbackPicker currentSelection];
	 
	 [self localBreadCrumb:@"Voice callback started"
			   description:[NSString stringWithFormat:@"Voice callback with skill=%@", callSkill]];
	 
	 UIViewController *chatController = [[EXPERTconnect shared] startVoiceCallback:callSkill
																   withDisplayName:@"Voice Callback"];
	 
	 [self.navigationController pushViewController:chatController animated:YES];
}

-(void)handleAdHocStartAnswerEngine
{
	 NSLog(@"Starting an ad-hoc Answer Engine Session");
	 
    [self checkAndUpdateLocaleOverride];
    
	 NSString *aeContext = [self.selectAdHocAnswerEngineContextPicker currentSelection];
	 
	 [self localBreadCrumb:@"Answer Engine started"
			   description:[NSString stringWithFormat:@"Answer engine with context=%@", aeContext]];
	 
	 UIViewController *answerEngineController = [[EXPERTconnect shared] startAnswerEngine:aeContext
																		  withDisplayName:@""
																			showSearchBar:YES];
	 
	 [self.navigationController pushViewController:answerEngineController animated:YES];
}

//-(void)handleAdHocStartVideoChat
//{
//     NSLog(@"Starting an ad-hoc Video Chat Session");
//
//    [self checkAndUpdateLocaleOverride];
//
//     NSString *chatSkill = [self.selectAdHocVideoChatPicker currentSelection];
//
//     [self localBreadCrumb:@"Video chat started"
//               description:[NSString stringWithFormat:@"Video chat with skill=%@", chatSkill]];
//
//     UIViewController *chatController = [[EXPERTconnect shared] startVideoChat:chatSkill withDisplayName:@"Video Chat"];
//     [self.navigationController pushViewController:chatController animated:YES];
//}

-(void)handleAdHocRenderForm
{
    NSLog(@"Rendering an ad-hoc Form");
    
    NSString *formName = [self.selectAdHocFormsPicker currentSelection];
    
    [self localBreadCrumb:@"Survey started"
              description:[NSString stringWithFormat:@"Survey with name=%@", formName]];
    
    _formsController = (ECSFormViewController *)[[EXPERTconnect shared] startSurvey:formName];
    _formsController.delegate = self;
    //_formsController.showFormSubmittedView = NO;
    [self.navigationController pushViewController:_formsController animated:YES];
}

-(void)handleAdHocEditUserProfile
{
	 NSLog(@"Rendering an ad-hoc User Profile Form");
	 
	 [self localBreadCrumb:@"User profile displayed"
			   description:@"Editing user profile"];
	 
	 UIViewController *profileController = [[EXPERTconnect shared] startUserProfile];
	 [self.navigationController pushViewController:profileController animated:YES];
}

-(void)handleAdHocBeaconDemo
{
	 NSLog(@"Showing iBeacon Demo View Controller");
	 
	 ECDBeaconViewController *beaconController = [[ECDBeaconViewController alloc] initWithNibName:nil bundle:nil];
	 [self.navigationController pushViewController:beaconController animated:YES];
}

//-(void)handleAdHocEmailMessage
//{
//     NSLog(@"Rendering an ad-hoc Email Form");
//
//     UIViewController *emailController = [[EXPERTconnect shared] startEmailMessage];
//     [self.navigationController pushViewController:emailController animated:YES];
//}
//
//-(void)handleAdHocSMSMessage
//{
//     NSLog(@"Rendering an ad-hoc SMS Messaging Form");
//
//     UIViewController *smsController = [[EXPERTconnect shared] startSMSMessage];
//     [self.navigationController pushViewController:smsController animated:YES];
//}

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
	 
	 UIViewController *selectExpertController = [[EXPERTconnect shared] startSelectExpertChat];
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

-(void)handleAdHocSubmitForm
{
	 NSLog(@"Rendering an ad-hoc Form");
	 
	 ECDAdHocFormsController *formsController = [[ECDAdHocFormsController alloc] initWithNibName:nil bundle:nil];
	 [self.navigationController pushViewController:formsController animated:YES];
}

//-(void)handleAdHocShowCalendar
//{
//	 NSLog(@"Showing the ad-hoc Calendar");
//	 
//	 ECDCalendarViewController *calendar = [[ECDCalendarViewController alloc] initWithNibName:nil bundle:nil];
//	 [self.navigationController pushViewController:calendar animated:YES];
//}
//
//-(void)handleAdHocShowTextEditor
//{
//	 NSLog(@"Showing the ad-hoc TextEditor");
//	 
//	 ECDTextEditorViewController *textEditor = [[ECDTextEditorViewController alloc] initWithNibName:nil bundle:nil];
//	 [self.navigationController pushViewController:textEditor animated:YES];
//}

-(void)handleAdHocShowLicense
{
	 NSLog(@"Showing the ad-hoc License");
	 
	 ECDLicenseViewController *license = [[ECDLicenseViewController alloc] initWithNibName:nil bundle:nil];
	 [self.navigationController pushViewController:license animated:YES];
}

#pragma mark Helper Functions

-(void)checkAndUpdateLocaleOverride
{
    // Do a locale override if the settings have been modified.
    NSString *localeOverride = [[NSUserDefaults standardUserDefaults] objectForKey:@"localeOverride"];
    if( localeOverride )
    {
        [[EXPERTconnect shared] overrideDeviceLocale:localeOverride];
    }
}

#pragma mark ECSFormViewDelegate functions

- (void)ECSFormViewController:(ECSFormViewController *)formVC
                submittedForm:(ECSForm *)form
                     withName:(NSString *)name
                        error:(NSError *)error {
    
    NSLog(@"AdHoc View: User submitted form %@. Error? %@", name, error);
    
}

- (void) ECSFormViewController:(ECSFormViewController *)formVC
              answeredFormItem:(ECSFormItem *)item
                       atIndex:(int)index {

    NSLog(@"AdHoc View: User answered question %d with answer: %@", index, item.formValue);
    
}

- (bool) ECSFormViewController:(ECSFormViewController *)formVC
                closedWithForm:(ECSForm *)form {
    
    NSLog(@"AdHoc View: User pushed close button. Closing manually from AdHoc (no animation)");
    
    [formVC.navigationController popToRootViewControllerAnimated:NO];
    
    return NO; // We override SDK behavior so we do not want it to perform it's own.
}

@end
