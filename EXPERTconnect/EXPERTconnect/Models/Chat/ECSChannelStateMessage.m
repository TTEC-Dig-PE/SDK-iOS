//
//  ECSChannelStateMessage.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSChannelStateMessage.h"

@implementation ECSChannelStateMessage

- (NSDictionary *)ECSJSONMapping
{
    NSMutableDictionary *jsonMapping = [[super ECSJSONMapping] mutableCopy];
    
    [jsonMapping addEntriesFromDictionary:@{
                                            @"conversationId": @"conversationId",
                                            @"channelId": @"channelId",
                                            @"state": @"state",
                                            @"estimatedWait": @"estimatedWait",
                                            @"version": @"version",
                                            @"disconnectReason": @"disconnectReasonString",
                                            @"terminatedBy": @"terminatedByString"
                                            }];
    return jsonMapping;
}


- (ECSTerminatedBy)terminatedBy {
    
    if ([self.terminatedByString isEqualToString:@"associate"]) {
        return ECSTerminatedByAssociate;
        
    } else if([self.terminatedByString isEqualToString:@"client"]) {
        return ECSTerminatedByClient;
        
    } else if([self.terminatedByString isEqualToString:@"system"]) {
        return ECSTerminatedBySystem;
        
    }else if([self.terminatedByString isEqualToString:@"admin"]) {
        return ECSTerminatedByAdmin;
        
    }else if([self.terminatedByString isEqualToString:@"error"]) {
        return ECSTerminatedByError;
        
    }else if([self.terminatedByString isEqualToString:@"queue"]) {
        return ECSTerminatedByQueue;
        
    } else {
        return ECSTerminatedByUnknown;
    }
}

- (NSString *) getTerminatedByString {
    
    switch (self.terminatedBy) {
        case ECSTerminatedByError:
            return @"error";
            break;
        case ECSTerminatedByQueue:
            return @"queue";
            break;
        case ECSTerminatedByAdmin:
            return @"admin";
            break;
        case ECSTerminatedByClient:
            return @"client";
            break;
        case ECSTerminatedBySystem:
            return @"system";
            break;
        case ECSTerminatedByUnknown:
            return @"unknown";
            break;
        case ECSTerminatedByAssociate:
            return @"associate";
            break;
            
        default:
            break;
    }
}

-(ECSDisconnectReason) disconnectReason {
    
    if([self.disconnectReasonString isEqualToString:@"disconnectByParticipant"]) {
        return ECSDisconnectReasonDisconnectByParticipant;
        
    } else if ([self.disconnectReasonString isEqualToString:@"idleTimeout"]) {
        return ECSDisconnectReasonIdleTimeout;
        
    } else {
        return ECSDisconnectReasonUnknown;
    }
}

-(NSString *)getDisconnectReasonString {
    
    switch (self.disconnectReason) {
        case ECSDisconnectReasonError:
            return @"error";
            break;
        case ECSDisconnectReasonUnknown:
            return @"unknown";
            break;
        case ECSDisconnectReasonIdleTimeout:
            return @"idleTimeout";
            break;
        case ECSDisconnectReasonDisconnectByParticipant:
            return @"disconnectByParticipant";
            break;
            
        default:
            break;
    }
}

- (ECSChannelState)channelState {
    
    if ([self.state isEqualToString:@"answered"]) {
        return ECSChannelStateConnected;
        
    } else if([self.state isEqualToString:@"notify"]) {
        return ECSChannelStateNotify;
        
    } else if([self.state isEqualToString:@"disconnected"]) {
        return ECSChannelStateDisconnected;
        
    } else {
        return ECSChannelStateUnknown;
    }
}

@end
