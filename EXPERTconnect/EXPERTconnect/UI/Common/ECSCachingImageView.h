//
//  ECSCachingImageView.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 ECSCachingImageDelegate gets notifified if the attempt to download the image fails
 */
@protocol ECSCachingImageDelegate <NSObject>

@required

- (void) errorOccurred:(NSString *)errorMessage;

@end

/**
 ECSCachingImageView provides an image view that will use a cached image or pull the requested
 image from the network if it is not in the cache.
 */
@interface ECSCachingImageView : UIImageView

@property (nonatomic, weak) id<ECSCachingImageDelegate> delegate;

/**
 Instantiate the image view with the specified image path.
 */
- (instancetype)initWithImagePath:(NSString*)imagePath;

/**
 Sets the image to the image with the specified path.
 
 @param path the path of the image
 */
- (void)setImageWithPath:(NSString*)path;

- (void)setImageWithRequest:(NSURLRequest*)request;
@end
