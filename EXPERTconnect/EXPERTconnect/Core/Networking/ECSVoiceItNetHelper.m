//
//  NetHelper.m
//  voiceitapidemo
//

#import "ECSVoiceItNetHelper.h"
#import <Foundation/Foundation.h>
@implementation ECSVoiceItNetHelper

@synthesize jsonPath,host;

-(id) init{
    
    self.host=@"https://siv.voiceprintportal.com/";
    self.jsonPath=[self.host stringByAppendingString:@"sivservice/api/"];
    
    return self;
}

-(NSDictionary *)postWavRequestAndResponseDic:(NSString *)action headerParams:(NSMutableDictionary *)headerParams wavData:(NSData *) wavData {
    
    NSURL *url=[[NSURL alloc]initWithString:[jsonPath stringByAppendingString:action]];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSURLResponse* response;
    
    [request setAllHTTPHeaderFields:[NSDictionary dictionaryWithObjectsAndKeys:@"audio/wav",@"Content-type",nil]];
    for (NSString * key in headerParams) {
        
        [request addValue:[headerParams objectForKey:key] forHTTPHeaderField:key];
    }
    [request setHTTPBody:wavData];
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response error:nil];
    NSError *error;
    NSDictionary * dic = nil;
    if (data != nil) {
        dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    //    NSLog(@"~~~~~~Error=%@",error);
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    
    return dic;
}
-(NSInteger)requestAndResponse:(NSString *)action headerParams:(NSMutableDictionary *)headerParams httpMethod:(NSString *)httpMethod {
    NSURL *url=[[NSURL alloc]initWithString:[jsonPath stringByAppendingString:action]];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:httpMethod];
    NSURLResponse* response;
    
    [request setAllHTTPHeaderFields:[NSDictionary dictionaryWithObjectsAndKeys:@"application/json",@"Accept",@"application/json",@"Content-type",nil]];
    for (NSString * key in headerParams) {
        
        [request addValue:[headerParams objectForKey:key] forHTTPHeaderField:key];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response error:nil];
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
    NSInteger responseStatusCode = [httpResponse statusCode];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    
    return responseStatusCode;
}

-(NSDictionary *)postRequestAndResponse:(NSString *)action headerParams:(NSMutableDictionary *)headerParams {
    NSURL *url=[[NSURL alloc]initWithString:[jsonPath stringByAppendingString:action]];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:[NSDictionary dictionaryWithObjectsAndKeys:@"application/json",@"Accept",@"application/json",@"Content-type",nil]];
    for (NSString * key in headerParams) {
        
        [request addValue:[headerParams objectForKey:key] forHTTPHeaderField:key];
    }
    NSURLResponse* response;
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response error:nil];
    NSError *error;
    NSDictionary * dic = nil;
    if (data != nil) {
        dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    //    NSLog(@"~~~~~~Error=%@",error);
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    
    return dic;
    //    return [self requestAndResponse:action headerParams:headerParams httpMethod:@"POST"];
}

-(NSDictionary *)getRequestAndResponseDic:(NSString *)action headerParams: (NSMutableDictionary *) headerParams {
    NSURL *url=[[NSURL alloc]initWithString:[jsonPath stringByAppendingString:action]];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:[NSDictionary dictionaryWithObjectsAndKeys:@"application/json",@"Accept",@"application/json",@"Content-type",nil]];
    for (NSString * key in headerParams) {
        
        [request addValue:[headerParams objectForKey:key] forHTTPHeaderField:key];
    }
    NSURLResponse* response;
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response error:nil];
    NSError *error;
    NSDictionary * dic = nil;
    
    if (data != nil) {
        dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    //    NSLog(@"~~~~~~Error=%@",error);
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    
    return dic;
}

-(NSDictionary *)getRequestAndResponseString:(NSString *)action headerParams: (NSMutableDictionary *) headerParams {
    NSURL *url=[[NSURL alloc]initWithString:[jsonPath stringByAppendingString:action]];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setAllHTTPHeaderFields:[NSDictionary dictionaryWithObjectsAndKeys:@"application/json",@"Accept",@"application/json",@"Content-type",nil]];
    for (NSString * key in headerParams) {
        
        [request addValue:[headerParams objectForKey:key] forHTTPHeaderField:key];
    }
    NSURLResponse* response;
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response error:nil];
    
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
    NSInteger responseStatusCode = [httpResponse statusCode];
    
    NSError *error;
    NSDictionary * result = nil;
    
    if (data != nil) {
        result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    
    if (data !=nil && responseStatusCode == 200) {
        // mas - 29-oct-2015 - Commented line throws warning (putting string into dictionary).
        // This is untested as this function is not called anywhere in our source.
        result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        //result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    
    return result;
}

-(NSDictionary *)putRequestAndResponse:(NSString *)action headerParams: (NSMutableDictionary *) headerParams {
    NSURL *url=[[NSURL alloc]initWithString:[jsonPath stringByAppendingString:action]];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"PUT"];
    [request setAllHTTPHeaderFields:[NSDictionary dictionaryWithObjectsAndKeys:@"application/json",@"Accept",@"application/json",@"Content-type",nil]];
    for (NSString * key in headerParams) {
        
        [request addValue:[headerParams objectForKey:key] forHTTPHeaderField:key];
    }
    NSURLResponse* response;
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response error:nil];
    NSError *error;
    NSDictionary * dic = nil;
    if (data != nil) {
        dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    //    NSLog(@"~~~~~~Error=%@",error);
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    
    return dic;
    //    return [self requestAndResponse:action headerParams:headerParams httpMethod:@"PUT"];
}

-(NSDictionary *)deleteRequestAndResponse:(NSString *)action headerParams: (NSMutableDictionary *) headerParams {
    NSURL *url=[[NSURL alloc]initWithString:[jsonPath stringByAppendingString:action]];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod:@"DELETE"];
    [request setAllHTTPHeaderFields:[NSDictionary dictionaryWithObjectsAndKeys:@"application/json",@"Accept",@"application/json",@"Content-type",nil]];
    for (NSString * key in headerParams) {
        
        [request addValue:[headerParams objectForKey:key] forHTTPHeaderField:key];
    }
    NSURLResponse* response;
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response error:nil];
    NSError *error;
    NSDictionary * dic = nil;
    if (data != nil) {
        dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    //    NSLog(@"~~~~~~Error=%@",error);
    [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
    
    return dic;
    ///    return [self requestAndResponse:action headerParams:headerParams httpMethod:@"DELETE"];
}
@end
