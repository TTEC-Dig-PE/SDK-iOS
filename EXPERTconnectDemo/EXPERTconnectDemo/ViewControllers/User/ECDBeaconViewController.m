//
//  iBeaconDemoViewController.m
//  HumanifyDemo
//
//  Created by Michael Schmoyer on 2/8/16.
//  Copyright © 2016 Michael Schmoyer. All rights reserved.
//

#import "ECDBeaconViewController.h"

@interface ECDBeaconViewController () {
    CLLocation *currentLocation;
    CLBeaconRegion *_region;
    
    NSString *_BeaconIdentifier;
    NSUUID *_uuid;
    
    iBeaconViewController *_beaconViewController;
    
    BOOL _monitoringStarted;
}

@end

@implementation ECDBeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _BeaconIdentifier = @"com.example.apple-samplecode.AirLocate";
    
    NSString *uuidString = [[[NSUserDefaults standardUserDefaults] valueForKey:@"com.humanifydemo.beaconuuid"] stringValue];
    if (uuidString) {
        _uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
    } else {
        _uuid = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
    }
    
    [self.textBeaconUUID setText:[_uuid UUIDString]];
    
    _monitoringStarted = NO;
    self.textBeaconUUID.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated {
    [self initializeGeoLocation];
}

- (IBAction)btnBeacon_Touch:(id)sender {
    if (_monitoringStarted) {
        [self.btnBeacon setTitle:@"Start Monitoring iBeacon" forState:UIControlStateNormal];
        [self stopMonitoringRegion];
    } else {
        [self.btnBeacon setTitle:@"Stop Monitoring iBeacon" forState:UIControlStateNormal];
        [self startMonitoringRegion];
        _beaconViewController = nil;
    }
    _monitoringStarted = !_monitoringStarted;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:@"com.humanifydemo.beaconuuid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}

#pragma mark GeoLocation Functions

- (void)initializeGeoLocation {
    self.locationManager = [[CLLocationManager alloc] init];
    
    // In our demo app, we will only use GPS while the app is in the foreground
    [self.locationManager requestAlwaysAuthorization];
    
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 5; // meters
        
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark iBeacon Functions

//E2C56DB5-DFFB-48D2-B060-D0F5A71096E0
- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state
              forRegion:(CLRegion *)region {
    
    /*
     A user can transition in or out of a region while the application is not running. When this happens CoreLocation will launch the application momentarily, call this delegate method and we will let the user know via a local notification.
     */
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    if(state == CLRegionStateInside) {
        
        notification.alertBody = NSLocalizedString(@"You're inside the region", @"");
        self.textResponse.text = @"You are inside the region.";
        
    } else if(state == CLRegionStateOutside) {
        
        notification.alertBody = NSLocalizedString(@"You're outside the region", @"");
        self.textResponse.text = @"You are outside the region.";
        
    }else{
        return;
    }
    
    /*
     If the application is in the foreground, it will get a callback to application:didReceiveLocalNotification:.
     If it's not, iOS will display the notification to the user.
     */
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region {
    
    /*
     CoreLocation will call this delegate method at 1 Hz with updated range information.
     Beacons will be categorized and displayed by proximity.  A beacon can belong to multiple
     regions.  It will be displayed multiple times if that is the case.  If that is not desired,
     use a set instead of an array.
     */
    bool beaconWindowActive = NO;
    
    for (UIView *subview in [self.view subviews]) {
        
        if (subview.tag == 1001) {
            beaconWindowActive = YES;
        }
    }
    
    for (CLBeacon *beacon in beacons) {
        
        if(beaconWindowActive) {
            
            [_beaconViewController setBeaconRange:beacon.proximity];
            if (beacon.proximity == CLProximityFar || beacon.proximity == CLProximityUnknown) {
                [self hideBeaconScreen];
            }
            
        } else {
            
            if (beacon.proximity == CLProximityNear || beacon.proximity == CLProximityImmediate) {
                [self showBeaconScreen];
            }
        }
    }
}

-(void)showBeaconScreen {
    
    if (!_beaconViewController) {
        _beaconViewController = [[iBeaconViewController alloc] init];
    }
    if ([_beaconViewController closeButtonPushed]) {
        return; // Don't display if we've closed it once.
    }
    
    _beaconViewController.view.tag = 1001;
    _beaconViewController.view.layer.cornerRadius = 6.0f;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_beaconViewController.view.bounds];
    _beaconViewController.view.layer.masksToBounds = NO;
    _beaconViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    _beaconViewController.view.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    _beaconViewController.view.layer.shadowOpacity = 0.5f;
    _beaconViewController.view.layer.shadowPath = shadowPath.CGPath;
    
    [self addChildViewController:_beaconViewController];
    _beaconViewController.view.center = CGPointMake( self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    [self.view addSubview:_beaconViewController.view];
    
    [_beaconViewController didMoveToParentViewController:self];
    
    [_beaconViewController.view setAlpha:0.0f];
    [UIView animateWithDuration:0.5f animations:^{
        [_beaconViewController.view setAlpha:1.0f];
    }];
}

-(void)hideBeaconScreen {
    
    [_beaconViewController.view setAlpha:0.0f];
    
    [UIView animateWithDuration:0.5f animations:^{
        [_beaconViewController.view setAlpha:1.0f];
        
    } completion:^(BOOL finished) {
        for (UIView *subview in [self.view subviews]) {
            if (subview.tag == 1001) {
                [subview removeFromSuperview];
            }
        }
        _beaconViewController = nil;
    }];
}

-(void)stopMonitoringRegion {
    
    if(_region != nil) {
        [self.locationManager stopMonitoringForRegion:_region];
        [self.locationManager stopRangingBeaconsInRegion:_region];
    }
}

- (void)startMonitoringRegion {
    
    _uuid = [[NSUUID alloc] initWithUUIDString:self.textBeaconUUID.text];
    
    // if region monitoring is enabled, update the region being monitored
    _region = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid
                                                 identifier:_BeaconIdentifier];
    
    if(_region) {
        
        _region.notifyOnEntry = YES;
        _region.notifyOnExit = YES;
        _region.notifyEntryStateOnDisplay = YES;
        
        [self.locationManager startMonitoringForRegion:_region];
        [self.locationManager startRangingBeaconsInRegion:_region];
    }
    NSLog(@"Started monitoring for default iBeacon...");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
