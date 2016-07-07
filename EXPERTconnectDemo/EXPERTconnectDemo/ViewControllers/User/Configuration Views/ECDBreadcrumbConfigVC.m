//
//  ECDBreadcrumbConfigVC.m
//  EXPERTconnectDemo
//
//  Created by Michael Schmoyer on 6/14/16.
//  Copyright © 2016 Humanify, Inc. All rights reserved.
//

#import "ECDBreadcrumbConfigVC.h"
#import "ECDLocalization.h"

@interface ECDBreadcrumbConfigVC ()

@end

@implementation ECDBreadcrumbConfigVC

CLLocationManager *_locationManager;
CLLocation *_currentLocation;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"Breadcrumbs";
    
    [self.btnSendOne setBackgroundColor:[EXPERTconnect shared].theme.buttonColor];
    [self.btnQueueBulk setBackgroundColor:[EXPERTconnect shared].theme.buttonColor];
    [self.btnSendOne setTitleColor:[EXPERTconnect shared].theme.buttonTextColor forState:UIControlStateNormal];
    [self.btnQueueBulk setTitleColor:[EXPERTconnect shared].theme.buttonTextColor forState:UIControlStateNormal];
     
     self.typeLabel.text = ECDLocalizedString(ECDLocalizedTypeLabel, @"Type Label");
     self.describtionLabel.text = ECDLocalizedString(ECDLocalizedDescribtionLabel, @"Describtion Label");
     self.sourceLabel.text = ECDLocalizedString(ECDLocalizedSourceLabel, @"Source Label");
     self.destinationLabel.text = ECDLocalizedString(ECDLocalizedDestinationLabel, @"Destination Label");
     self.geolocationDataLabel.text = ECDLocalizedString(ECDLocalizedGeoLocationDataLabel, @"GeoLocation Data Label");
     self.bulkConfigLabel.text = ECDLocalizedString(ECDLocalizedBulkConfigLabel, @"Bulk Config Label");
     self.secondsLabel.text = ECDLocalizedString(ECDLocalizedSecondsLabel, @"Seconds Label");
     self.countLabel.text = ECDLocalizedString(ECDLocalizedCountLabel, @"Count Label");

     self.txtActionType.placeholder = ECDLocalizedString(ECDLocalizedTypePlaceholderLabel, @"Text Field PlaceHolder Label");
     self.txtActionDescription.placeholder = ECDLocalizedString(ECDLocalizedDescribtionPlaceholderLabel, @"Text Field PlaceHolder Label");
     self.txtActionSource.placeholder = ECDLocalizedString(ECDLocalizedSourcePlaceholderLabel, @"Text Field PlaceHolder Label");
     self.txtActionDestination.placeholder = ECDLocalizedString(ECDLocalizedDestinationPlaceholderLabel, @"Text Field PlaceHolder Label");
     
     [self.btnSendOne setTitle:ECDLocalizedString(ECDLocalizedSendOneButtonLabel, @"SendOne") forState:UIControlStateNormal];
     [self.btnQueueBulk setTitle:ECDLocalizedString(ECDLocalizedQueueBulkButtonLabel, @"QueueBulk") forState:UIControlStateNormal];

}

-(void)viewDidAppear:(BOOL)animated
{
    // In our demo app, we will only use GPS while the app is in the foreground
    [_locationManager requestWhenInUseAuthorization];
    
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 5; // meters
        [_locationManager startUpdatingLocation];
    }
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

#pragma mark Buttons

- (IBAction)btnSendOne_Touch:(id)sender
{
    [[EXPERTconnect shared] breadcrumbSendOne:[self buildBreadcrumb]
                               withCompletion:^(ECSBreadcrumbResponse *response, NSError *error)
    {
        if(error)self.lblResponse.text = error.description;
        if(response)self.lblResponse.text = response.description; 
    }];
}

- (IBAction)btnQueueBulk_Touch:(id)sender
{
    // Update the bulk count each time we click this. 
    ECSConfiguration *configuration = [[ECSInjector defaultInjector] objectForClass:[ECSConfiguration class]];
    configuration.breadcrumbCacheCount = [self.txtBulkCount.text intValue];
    configuration.breadcrumbCacheTime = [self.txtBulkSeconds.text intValue];
    
    [[EXPERTconnect shared] breadcrumbQueueBulk:[self buildBreadcrumb]];
    
    self.lblResponse.text = [NSString stringWithFormat:@"Bulk breadcrumb queued. %lu breadcrumb(s) in queue.", (unsigned long)[EXPERTconnect shared].storedBreadcrumbs.count];
}

#pragma mark Local Functions

- (ECSBreadcrumb *) buildBreadcrumb
{
    ECSBreadcrumb *newBreadcrumb = [[ECSBreadcrumb alloc] initWithAction:self.txtActionType.text
                                                             description:self.txtActionDescription.text
                                                                  source:self.txtActionSource.text
                                                             destination:self.txtActionDestination.text];
    
    if( self.optIncludeGeolocation.on && _currentLocation )
    {
        newBreadcrumb.geoLocation = _currentLocation;
    }
    return newBreadcrumb;
}

#pragma mark CLLocation Delegate

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (fabs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        _currentLocation = location;
        
        //[self getLocationAddress:currentLocation];
    }
}
@end
