//
//  ECSLog.h
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Log level is set with ECSLogLevel and can be overriden with the
 ECSLogLevelKey environment variable.
 */
typedef NS_ENUM(NSInteger, ECSLogLevel)
{
    ECSLogLevelNone = 0,
    ECSLogLevelError,
    ECSLogLevelWarning,
    ECSLogLevelDebug,
    ECSLogLevelVerbose,
};

extern ECSLogLevel ECSCurrentLogLevel;

/**
 Logs a message at the specified log level.
 */
void ECSLog(ECSLogLevel logLevel, NSString *format, ...);

/**
 Sets the current debug level. 
 */
void ECSLogSetLogLevel(ECSLogLevel logLevel);

/**
 Logs if log level is set to Error or higher
 */
#define ECSLogError(format, ...) ECSLog(ECSLogLevelError, format, ##__VA_ARGS__)

/**
 Logs if log level is set to Warning or higher
 */
#define ECSLogWarn(format, ...) ECSLog(ECSLogLevelWarning, format, ##__VA_ARGS__)


/**
 Logs if log level is set to Debug or higher
 */
#define ECSLogDebug(format, ...) ECSLog(ECSLogLevelDebug, format, ##__VA_ARGS__)

/**
 Logs if log level is set to Verbose
 */
#define ECSLogVerbose(format, ...) ECSLog(ECSLogLevelVerbose, format, ##__VA_ARGS__)
