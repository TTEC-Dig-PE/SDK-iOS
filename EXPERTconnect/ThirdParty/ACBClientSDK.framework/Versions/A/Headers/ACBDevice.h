
#import "ACBClientPhone.h"

/**
 Represents the physical device the SDK is running on.
 */
@interface ACBDevice : NSObject

/**
 Returns an array of ACBVideoCaptureSetting objects that represent the recommended resolutions and
 frame-rates that the device is capable of. Settings are ordered from highest resolution to lowest
 resolution.
 
 This method returns the same information as ACBPhone recommendedCaptureSettings but does not
 require you to create ACBPhone and ACBUC instances.
 
 @return recommended resolutions and frame-rates.
 */
+ (NSArray*) recommendedCaptureSettings;

@end
