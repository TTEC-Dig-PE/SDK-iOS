//
//  ECSActionType.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSActionType.h"

#import "ECSJSONSerializer.h"
#import "ECSPreSurvey.h"
#import "ECSUtilities.h"

NSString *const ECSActionTypeNavigationString = @"navigation";
NSString *const ECSActionTypeAnswerEngineString = @"answerengine";
NSString *const ECSActionTypeMessageString = @"message";
NSString *const ECSActionTypeCallbackString = @"voice";
NSString *const ECSActionTypeChatString = @"chat";
NSString *const ECSActionTypeSMSString = @"sms";
NSString *const ECSActionTypeWebString = @"web";
NSString *const ECSActionTypeFormString = @"form";
NSString *const ECSActionTypeAnswerHistory = @"answerhistory";
NSString *const ECSActionTypeChatHistory = @"chathistory";
NSString *const ECSActionTypeProfile = @"profile";

@implementation ECSActionType

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.type = @"";
        self.autoRoute = @NO;
        self.displayName = @"Action";
        self.enabled = @YES;
    }
    
    return self;
}

- (NSDictionary *)ECSJSONMapping
{
    return @{
             @"type": @"type",
             @"action_id": @"actionId",
             @"autoRoute": @"autoRoute",
             @"displayName": @"displayName",
             @"icon": @"icon",
             @"enabled": @"enabled",
             @"presurvey": @"presurvey",
             @"journeybegin": @"journeybegin",
             @"configuration": @"configuration",
             };
}

- (NSDictionary *)ECSJSONTransformMapping
{
    return @{
             @"presurvey": [ECSPreSurvey class]
             };
}

- (id)copyWithZone:(NSZone *)zone
{
    ECSActionType *actionType = [[[self class] allocWithZone:zone] init];
    actionType.type = [self.type copyWithZone:zone];
    actionType.actionId = [self.actionId copyWithZone:zone];
    actionType.autoRoute = [self.autoRoute copyWithZone:zone];
    actionType.displayName = [self.displayName copyWithZone:zone];
    actionType.icon = [self.displayName copyWithZone:zone];
    actionType.enabled = [self.enabled copyWithZone:zone];
    actionType.configuration = [[NSDictionary alloc] initWithDictionary:self.configuration copyItems:YES];
    actionType.journeybegin = [self.journeybegin copyWithZone:zone];
    actionType.presurvey = [self.configuration copyWithZone:zone];
    
    return actionType;
}

@end