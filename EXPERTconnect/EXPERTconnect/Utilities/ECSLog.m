//
//  ECSLog.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSLog.h"

@implementation ECSLog
@end

#ifdef DEBUG
ECSLogLevel ECSCurrentLogLevel = ECSLogLevelVerbose;
#else
ECSLogLevel ECSCurrentLogLevel = ECSLogLevelError;
#endif

ECSLogLevel currentLogLevel()
{
    ECSLogLevel logLevel = ECSCurrentLogLevel;
    

    return logLevel;
}

void ECSLogSetLogLevel(ECSLogLevel logLevel) {
    ECSCurrentLogLevel = logLevel;
}

void ECSLogging(ECSLog * _Nonnull logger,ECSLogLevel logLevel, NSString * _Nonnull format, ...)
{
    if( logger && logger.handler && ECSCurrentLogLevel >= logLevel )
    {
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        logger.handler(logLevel, message);
        
    }
}
