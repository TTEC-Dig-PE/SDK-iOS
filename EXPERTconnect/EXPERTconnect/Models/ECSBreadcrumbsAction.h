//
//  ECSBreadcrumbsAction.h
//  EXPERTconnect
//
//  Created by Ran on 10/14/15.
//  Copyright © 2015 Humanify, Inc. All rights reserved.
//

#ifndef ECSBreadcrumbsAction_h
#define ECSBreadcrumbsAction_h




@interface ECSBreadcrumbsAction: NSObject

@property (nonatomic) NSMutableDictionary *properties;


- (id)initWithDic : (NSDictionary *)dic;


- (NSMutableDictionary *)getProperties;

- (void)setId: (NSString *)actionId;
- (NSString *)getId;

- (void)setTenantId: (NSString *)tenantId;
- (NSString *)getTenantId;

- (void)setJourneyId: (NSString *)journeyId;
- (NSString *)getJourneyId;


- (void)setSessionId: (NSString *)sessionId;
- (NSString *)getSessionId;

- (void)setActionType: (NSString *)actionType;
- (NSString *)getActionType;

- (void)setActionDescription: (NSString *)actionDescription;
- (NSString *)getActionDescription;

- (void)setActionSource: (NSString *)actionSource;
- (NSString *)getActionSource;

- (void)setActionDestination: (NSString *)actionDestination;
- (NSString *)getActionDestination;

- (void)setCreationTime: (NSString *)creationTime;
- (NSString *)getCreationTime;

@end





#endif /* ECSBreadcrumbsAction_h */
