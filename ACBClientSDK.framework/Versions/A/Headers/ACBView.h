
#ifdef __APPLE__
#import "TargetConditionals.h"
#endif

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define ACBView UIView
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
#define ACBView NSView
#endif
