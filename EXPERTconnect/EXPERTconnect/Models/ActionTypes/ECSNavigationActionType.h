//
//  ECSActionTypeNavigation.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSActionType.h"

/**
 ECSNavigationActionType is an action type defining a navigation action.
 */
@interface ECSNavigationActionType : ECSActionType <NSCopying>

// The navigation context for this action type
@property (nonatomic, strong) NSString *navigationContext;

@end
