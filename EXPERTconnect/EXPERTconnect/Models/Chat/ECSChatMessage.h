//
//  ECSChatMessage.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

@interface ECSChatMessage : ECSJSONObject <NSCopying, ECSJSONSerializing>

@property (assign, nonatomic) BOOL fromAgent;

@end
