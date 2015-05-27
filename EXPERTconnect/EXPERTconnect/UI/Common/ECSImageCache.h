//
//  ECSImageCache.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Notification sent when an image is retrieved from the network
FOUNDATION_EXPORT NSString *const ECSImageCacheImageDownloadedNotification;

// Key for the user-info dictionary object containing the URL of a downloaded image.
FOUNDATION_EXPORT NSString *const ECSImageCacheImageUrlKey;

/**
 ECSImageCache provides methods for retrieving and caching images from the network.
 */
@interface ECSImageCache : NSCache

/**
 Returns a cached image for the specified image path or nil if the image is unavailable.
 
 @param path the url or local path to download the image from

 @return the cached image at the specified path or nil if the image is not in cache.
 */
- (UIImage*)imageForPath:(NSString*)path;

/**
 Downloads and caches the image at the specified path.  When the image is downloaded successfully a
 ECSImageCacheImageDownloadedNotification notifcation is sent.
 
 @param path the url or local path to download the image from
 */
- (void)downloadImageForPath:(NSString*)path;

- (void)downloadImageWithRequest:(NSURLRequest*)request;

@end
