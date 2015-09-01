//
//  ECSVoiceItNetHelper.h
//  voiceitapidemo
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ECSVoiceItNetHelper : NSObject {
    NSString *jsonPath;
    NSString *host;
    
    
}
@property (nonatomic,retain)NSString *jsonPath;
@property (nonatomic,retain) NSString *host;

-(NSDictionary *)postRequestAndResponse:(NSString *)action headerParams:(NSMutableDictionary *)headerParams;
-(NSDictionary *)getRequestAndResponseDic:(NSString *)action headerParams: (NSMutableDictionary *) headerParams;
-(NSDictionary *)putRequestAndResponse:(NSString *)action headerParams: (NSMutableDictionary *) headerParams;
-(NSDictionary *)deleteRequestAndResponse:(NSString *)action headerParams: (NSMutableDictionary *) headerParams;
-(NSDictionary *)getRequestAndResponseString:(NSString *)action headerParams: (NSMutableDictionary *) headerParams;
-(NSDictionary *)postWavRequestAndResponseDic:(NSString *)action headerParams:(NSMutableDictionary *)headerParams wavData:(NSData *) wavData;
@end


