//
//  SessionTaskQueue.h
//  EXPERTconnect
//
//  Created by Michael Schmoyer on 8/7/17.
//  Copyright © 2017 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SessionTaskQueue : NSObject

@property (nonatomic, strong) NSMutableArray * sessionTasks;
@property (nonatomic, strong) NSURLSessionTask * currentTask;

- (void)addSessionTask:(NSURLSessionTask *)sessionTask;
- (void)sessionTaskFinished;

@end
