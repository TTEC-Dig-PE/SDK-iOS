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

typedef void(^ECSInternalLogHandler)(ECSLogLevel level, NSString * _Nonnull message);

@interface ECSLog : NSObject

@property (nonatomic, copy) ECSInternalLogHandler _Nullable handler;

@end

extern ECSLogLevel ECSCurrentLogLevel;

/**
 Logs a message at the specified log level.
 */
void ECSLogging(ECSLog * _Nonnull logger,ECSLogLevel logLevel, NSString * _Nonnull format, ...);

/**
 Sets the current debug level. 
 */
void ECSLogSetLogLevel(ECSLogLevel logLevel);

/**
 Logs if log level is set to Error or higher
 */
#define ECSLogError(logger,format, ...) ECSLogging(logger, ECSLogLevelError, @"%s: "format, __PRETTY_FUNCTION__, ##__VA_ARGS__)

/**
 Logs if log level is set to Warning or higher
 */
#define ECSLogWarn(logger,format, ...) ECSLogging(logger, ECSLogLevelWarning, @"%s: "format, __PRETTY_FUNCTION__, ##__VA_ARGS__)


/**
 Logs if log level is set to Debug or higher
 */
#define ECSLogDebug(logger,format, ...) ECSLogging(logger, ECSLogLevelDebug, @"%s: "format, __PRETTY_FUNCTION__, ##__VA_ARGS__)

/**
 Logs if log level is set to Verbose
 */
#define ECSLogVerbose(logger,format, ...) ECSLogging(logger, ECSLogLevelVerbose, @"%s: "format, __PRETTY_FUNCTION__, ##__VA_ARGS__)
