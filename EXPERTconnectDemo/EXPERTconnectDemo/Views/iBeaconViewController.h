//
//  iBeaconViewController.h
//  HumanifyDemo
//
//  Created by Michael Schmoyer on 2/1/16.
//  Copyright © 2016 Michael Schmoyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <EXPERTconnect/EXPERTconnect.h>

@interface iBeaconViewController : UIViewController

- (IBAction)btnClose_Touch:(id)sender;

- (IBAction)btnStartChat_Touch:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblBeaconRange;

- (void)setBeaconRange:(CLProximity)proximity;

- (BOOL)closeButtonPushed; 

@end
