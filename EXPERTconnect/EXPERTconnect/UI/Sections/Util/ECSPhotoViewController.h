//
//  ECSPhotoViewController.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECSPhotoViewController : UIViewController

@property (strong, nonatomic) NSString *mediaPath;
@property (strong, nonatomic) NSString *imagePath;
@property (strong, nonatomic) UIImage *image;

@property (strong, nonatomic) NSURLRequest *imageURLRequest;

@end
