//
//  SessionTaskQueue.m
//  EXPERTconnect
//
//  Created by Michael Schmoyer on 8/7/17.
//  Copyright © 2017 Humanify, Inc. All rights reserved.
//

#import "SessionTaskQueue.h"

@implementation SessionTaskQueue

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.sessionTasks = [[NSMutableArray alloc] initWithCapacity:15];
        
    }
    return self;
    
}

- (void)addSessionTask:(NSURLSessionTask *)sessionTask {
    
    [self.sessionTasks addObject:sessionTask];
    NSLog(@"STQ: Queuing task. %lu tasks in queue.", self.sessionTasks.count);
    [self resume];
    
}

// call in the completion block of the sessionTask
- (void)sessionTaskFinished {
    
    self.currentTask = nil;
    NSLog(@"STQ: Task finished. %lu tasks in queue.", self.sessionTasks.count);
    [self resume];
    
}

- (void)resume {
    
    if (self.currentTask) {
        NSLog(@"STQ: Task already in progress. Waiting.... %lu tasks in queue.", self.sessionTasks.count);
        return;
    }
    
    self.currentTask = [self.sessionTasks firstObject];
    if (self.currentTask) {
        [self.sessionTasks removeObjectAtIndex:0];
        NSLog(@"STQ: Nothing in progress. Starting first task in queue. %lu tasks in queue", self.sessionTasks.count);
        [self.currentTask resume];
    }
    
}

@end
