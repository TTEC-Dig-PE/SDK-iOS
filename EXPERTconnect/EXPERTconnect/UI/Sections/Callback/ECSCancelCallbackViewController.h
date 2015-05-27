//
//  ECSCancelCallbackViewController.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECSCancelCallbackViewController : UIViewController

@property (assign, nonatomic) BOOL displaySMSOption;
@property (strong, nonatomic) NSNumber *waitTime;
@property (strong, nonatomic) NSString *phoneNumber;
@property (strong, nonatomic) NSString *callID;
@property (strong, nonatomic) NSString *closeChannelURL;
@property (strong, nonatomic) NSString *actionId;
@end
