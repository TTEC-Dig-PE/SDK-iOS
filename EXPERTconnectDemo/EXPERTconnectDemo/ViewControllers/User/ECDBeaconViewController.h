//
//  ECDBeaconViewController.h
//  HumanifyDemo
//
//  Created by Michael Schmoyer on 2/8/16.
//  Copyright © 2016 Michael Schmoyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "iBeaconViewController.h"
#import <EXPERTconnect/EXPERTconnect.h>

@interface ECDBeaconViewController : UIViewController  <CLLocationManagerDelegate, UITextFieldDelegate>

@property (nonatomic) CLLocationManager *locationManager;


@property (weak, nonatomic) IBOutlet UITextField *textBeaconUUID;
@property (weak, nonatomic) IBOutlet UIButton *btnBeacon;
- (IBAction)btnBeacon_Touch:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textResponse;

@end
