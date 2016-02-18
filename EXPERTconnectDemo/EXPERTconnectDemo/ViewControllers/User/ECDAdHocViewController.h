//
//  ECDAdHocViewController.h
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 8/3/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <EXPERTconnect/ECSRootViewController.h>
#import <EXPERTconnect/EXPERTconnect.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreLocation/CoreLocation.h>

@interface ECDAdHocViewController : ECSRootViewController

@property (nonatomic) CLLocationManager *locationManager;

@end
