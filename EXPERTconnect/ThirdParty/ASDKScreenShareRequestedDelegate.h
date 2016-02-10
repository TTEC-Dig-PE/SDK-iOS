@protocol ASDKScreenShareRequestedDelegate <NSObject>

@required
- (void) assistSDKScreenShareRequested:(void (^)(void))allow deny:(void (^)(void))deny;
@end
