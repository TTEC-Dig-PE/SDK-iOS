//
//  ECSChatLocationViewController.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChatLocationViewController.h"

#import <CoreLocation/CLLocationManager.h>
#import <MapKit/MapKit.h>

#import "ECSDynamicLabel.h"
#import "ECSLocalization.h"
#import "ECSInjector.h"
#import "ECSTheme.h"

@interface ECSChatLocationViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation ECSChatLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.messageLabel.alpha = 0.0f;
    
    [self setupMessageLabelText];
    
    self.mapView.showsUserLocation = YES;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusNotDetermined)
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    else if (status == kCLAuthorizationStatusAuthorizedAlways ||
             status == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        [self.locationManager startUpdatingLocation];
    }
    
    [self updateViewForAuthorizationStatus:status];
}

- (void)setupMessageLabelText
{
    NSString *string = ECSLocalizedString(ECSLocalizeDirections, @"Localization Directions");
    
    NSString *appName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleDisplayName"];
    if (!appName)
    {
        appName = @"App Name";
    }
    
    string = [NSString stringWithFormat:string, appName];
    
    ECSTheme *theme = [[ECSInjector defaultInjector] objectForClass:[ECSTheme class]];
    string = [NSString stringWithFormat:@"<html><head><style>%@</style></head><body>%@</body></html>", theme.cssStyle, string];
    
    NSLog(@"HTML");
    NSLog(@"%@", string);
    NSAttributedString *stringWithHTMLAttributes = [[NSAttributedString alloc] initWithData:[string dataUsingEncoding:NSUTF8StringEncoding]                                                                                       options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType}
                                                                         documentAttributes:nil
                                                                                      error:nil];
    [self.messageLabel setAttributedText:stringWithHTMLAttributes];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways)
    {
        [self.locationManager startUpdatingLocation];
    }
    
    [self updateViewForAuthorizationStatus:status];
}

- (void)updateViewForAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            self.mapView.alpha = 1.0f;
            self.messageLabel.alpha = 0.0f;
            break;
        default:
            self.mapView.alpha = 0.0f;
            self.messageLabel.alpha = 1.0f;
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *newLocation = [locations lastObject];
    MKCoordinateSpan span = MKCoordinateSpanMake(0.04, 0.04);
    MKCoordinateRegion region = MKCoordinateRegionMake(newLocation.coordinate, span);
    
    [self.mapView setRegion:region animated:TRUE];
    [self.mapView regionThatFits:region];
}

//- (void)locationManager:(CLLocationManager *)manager
//    didUpdateToLocation:(CLLocation *)newLocation
//           fromLocation:(CLLocation *)oldLocation
//{
//    MKCoordinateSpan span = MKCoordinateSpanMake(0.04, 0.04);
//    MKCoordinateRegion region = MKCoordinateRegionMake(newLocation.coordinate, span);
//
//    [self.mapView setRegion:region animated:TRUE];
//    [self.mapView regionThatFits:region];
//}
// Do any additional setup after loading the view from its nib.

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
