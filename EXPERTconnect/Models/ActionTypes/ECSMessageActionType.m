//
//  ECSMessageActionType.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSMessageActionType.h"

@implementation ECSMessageActionType

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.type = ECSActionTypeMessageString;
    }
    
    return self;
}

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *mapping = [[NSMutableDictionary alloc] initWithDictionary:[super ECSJSONMapping]];
    
    [mapping addEntriesFromDictionary:@{
                                        @"configuration.messageHeader": @"messageHeader",
                                        @"configuration.messageText": @"messageText",
                                        @"configuration.hoursText": @"hoursText",
                                        @"configuration.email": @"email",
                                        @"configuration.emailSubject": @"emailSubject",
                                        @"configuration.emailBody": @"emailBody",
                                        @"configuration.emailButtonText": @"emailButtonText",
                                        }];
    
    return mapping;
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSMessageActionType *actionType = [super copyWithZone:zone];
    
    actionType.messageHeader = [self.messageHeader copyWithZone:zone];
    actionType.messageText = [self.messageText copyWithZone:zone];
    actionType.hoursText = [self.hoursText copyWithZone:zone];
    actionType.email = [self.email copyWithZone:zone];
    actionType.emailSubject = [self.emailSubject copyWithZone:zone];
    actionType.emailBody = [self.emailBody copyWithZone:zone];
    actionType.emailButtonText = [self.emailButtonText copyWithZone:zone];
    
    return actionType;
}


@end
