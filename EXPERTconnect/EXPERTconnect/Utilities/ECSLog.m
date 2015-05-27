//
//  ECSLog.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSLog.h"

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

void ECSLog(ECSLogLevel logLevel, NSString *format, ...)
{
    if (currentLogLevel() >= logLevel)
    {
        va_list args;
        va_start(args, format);
        NSLogv(format, args);
        va_end(args);
    }
}
