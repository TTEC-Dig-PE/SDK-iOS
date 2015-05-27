//
//  ECSChannelConfiguration.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ECSJSONObject.h"
#import "ECSJSONSerializing.h"

/**
 Configuration used when creating a channel for chat.
 */
@interface ECSChannelConfiguration : ECSJSONObject <ECSJSONSerializing>

// Specifies the end user connection for the chat
@property (strong, nonatomic) NSString *to;

// Specifies the name of sender of the connection
@property (strong, nonatomic) NSString *from;

// Specifies the subject for the connection
@property (strong, nonatomic) NSString *subject;

// Specifies the type of connection (chat/voice)
@property (strong, nonatomic) NSString *mediaType;

// Specifies the priority of the chat
@property (strong, nonatomic) NSNumber *priority;

// The source of the chat.
@property (strong, nonatomic) NSString *sourceType;

// The source address for voice calls
@property (strong, nonatomic) NSString *sourceAddress;

// Device ID for the chat
@property (strong, nonatomic) NSString *deviceId;

// Location for the chat
@property (strong, nonatomic) NSString *location;

// Organization
@property (strong, nonatomic) NSString *organization;

@end
