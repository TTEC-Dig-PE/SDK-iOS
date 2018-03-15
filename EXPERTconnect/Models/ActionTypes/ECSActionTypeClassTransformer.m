//
//  ECSActionTypeClassTransformer.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSActionTypeClassTransformer.h"

#import "ECSActionType.h"
#import "ECSAnswerEngineActionType.h"
#import "ECSCallbackActionType.h"
#import "ECSChatActionType.h"
#import "ECSVideoChatActionType.h"
#import "ECSFormActionType.h"
#import "ECSMessageActionType.h"
#import "ECSNavigationActionType.h"
#import "ECSSMSActionType.h"
#import "ECSWebActionType.h"



@implementation ECSActionTypeClassTransformer

- (Class)defaultTransformClass
{
    return [ECSActionType class];
}

- (Class)classForJSONObject:(NSDictionary *)jsonDictionary
{
    NSString *type = jsonDictionary[@"type"];
    
    if ([type isEqualToString:ECSActionTypeNavigationString])
    {
        return [ECSNavigationActionType class];
    }
    else if ([type isEqualToString:ECSActionTypeAnswerEngineString])
    {
        return [ECSAnswerEngineActionType class];
    }
    else if ([type isEqualToString:ECSActionTypeWebString])
    {
        return [ECSWebActionType class];
    }
    else if ([type isEqualToString:ECSActionTypeFormString])
    {
        return [ECSFormActionType class];
    }
    else if ([type isEqualToString:ECSActionTypeChatString])
    {
        return [ECSChatActionType class];
    }
    else if ([type isEqualToString:ECSActionTypeVideoChatString])
    {
        return [ECSVideoChatActionType class];
    }
    else if ([type isEqualToString:ECSActionTypeCallbackString])
    {
        return [ECSCallbackActionType class];
    }
    else if ([type isEqualToString:ECSActionTypeMessageString])
    {
        return [ECSMessageActionType class];
    }
    else if ([type isEqualToString:ECSActionTypeSMSString])
    {
        return [ECSSMSActionType class];
    }

    
    return [self defaultTransformClass];
}
@end
