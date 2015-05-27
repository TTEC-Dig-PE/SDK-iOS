//
//  ECSMediaInfoHelpers.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ECSMediaInfoHelpers : NSObject

+ (UIImage *)thumbnailForMedia:(NSDictionary *)mediaInfo;

+ (NSString *)fileTypeForMedia:(NSDictionary *)mediaInfo;

+ (NSString *)filePathForMedia:(NSDictionary *)mediaInfo;

+ (NSString *)uploadNameForMedia:(NSDictionary *)mediaInfo;

+ (NSData*)uploadDataForMedia:(NSDictionary *)mediaInfo;
@end
