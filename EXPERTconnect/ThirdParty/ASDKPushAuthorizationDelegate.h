#import "ASDKSharedDocument.h"

@protocol ASDKPushAuthorizationDelegate<NSObject>
@required
- (void)displaySharedDocumentRequested:(ASDKSharedDocument *)sharedDocument allow: (void (^)(void)) allow deny: (void (^)(void)) deny;
@end
