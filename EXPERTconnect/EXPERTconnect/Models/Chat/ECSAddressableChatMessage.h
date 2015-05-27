//
//  ECSAddressableChatMessage.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ECSAddressableChatMessage <NSObject>

@required

@property (nonatomic, strong) NSString *from;

@optional
@property (nonatomic, strong) NSString *to;

@end
