//
//  ECDBreadcrumbConfigVC.h
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 6/14/16.
//  Copyright © 2016 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EXPERTconnect/EXPERTconnect.h>
#import <CoreLocation/CoreLocation.h>

@interface ECDBreadcrumbConfigVC : UIViewController <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtActionType;
@property (weak, nonatomic) IBOutlet UITextField *txtActionDescription;
@property (weak, nonatomic) IBOutlet UITextField *txtActionSource;
@property (weak, nonatomic) IBOutlet UITextField *txtActionDestination;

@property (weak, nonatomic) IBOutlet UISwitch *optIncludeGeolocation;

@property (weak, nonatomic) IBOutlet UITextField *txtBulkSeconds;
@property (weak, nonatomic) IBOutlet UITextField *txtBulkCount;

@property (weak, nonatomic) IBOutlet UILabel *lblResponse;

@property (weak, nonatomic) IBOutlet UIButton *btnSendOne;
@property (weak, nonatomic) IBOutlet UIButton *btnQueueBulk;
- (IBAction)btnSendOne_Touch:(id)sender;
- (IBAction)btnQueueBulk_Touch:(id)sender;

@end
