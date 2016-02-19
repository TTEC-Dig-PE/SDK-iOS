//
//  iBeaconViewController.m
//  HumanifyDemo
//
//  Created by Michael Schmoyer on 2/1/16.
//  Copyright © 2016 Michael Schmoyer. All rights reserved.
//

#import "iBeaconViewController.h"

@interface iBeaconViewController () {
    CLProximity _proximity;
    BOOL _closeButtonPushed;
}

@end

@implementation iBeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _closeButtonPushed = NO;
}

-(BOOL)closeButtonPushed {
    return _closeButtonPushed;
}

- (IBAction)btnClose_Touch:(id)sender {
    _closeButtonPushed = YES; 
    [self.view removeFromSuperview]; 
}

- (IBAction)btnStartChat_Touch:(id)sender {
    _closeButtonPushed = YES;
    NSLog(@"Starting new chat.");
    UIViewController *chatViewController = [[EXPERTconnect shared] startChat:@"CE_Mobile_Chat"
                                            withDisplayName:@"John Beacon Smith"
                                                 withSurvey:NO];
    
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (void)setBeaconRange:(CLProximity)proximity {
    _proximity = proximity;
    NSString *beaconRangeString;
    switch ((long)_proximity) {
        case 1:
            beaconRangeString = @"Very close";
            break; 
        case 2:
            beaconRangeString = @"Near";
            break;
        case 3:
            beaconRangeString = @"Far";
        default:
            beaconRangeString = @"Unknown";
            break;
    }
    [self.lblBeaconRange setText:[NSString stringWithFormat:@"Beacon range: (%@) - %ld", beaconRangeString, (long)_proximity]];
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
