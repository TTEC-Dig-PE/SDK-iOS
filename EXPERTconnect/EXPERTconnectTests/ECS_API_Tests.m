//
//  ECS_API_Tests.m
//  EXPERTconnect
//
//  Created by Michael Schmoyer on 6/1/16.
//  Copyright © 2016 Humanify, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <EXPERTconnect/EXPERTconnect.h>

@interface ECS_API_Tests : XCTestCase <ECSAuthenticationTokenDelegate>

@end

@implementation ECS_API_Tests

NSURL *_testAuthURL;
NSString *_testTenant;

- (void)initSDK {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    ECSConfiguration *configuration = [ECSConfiguration new];
    
    configuration.appName       = @"EXPERTconnect UnitTester";
    configuration.appVersion    = @"1.0";
    configuration.appId         = @"12345";
    
    configuration.host          = @"https://api.dce1.humanify.com";
    //configuration.clientID      = @"mktwebextc";
    //configuration.clientSecret  = @"secret123";
    
    [[EXPERTconnect shared] initializeWithConfiguration:configuration];
    //[[EXPERTconnect shared] initializeVideoComponents]; // CafeX initialization.
    
    if(!_testTenant) _testTenant = @"mktwebextc";
    // A GOOD auth URL
    _testAuthURL = [[NSURL alloc] initWithString:
                    [NSString stringWithFormat:@"https://api.dce1.humanify.com/authServerProxy/v1/tokens/ust?username=%@&client_id=%@",
                     @"expertconnect_unit_test",
                     _testTenant]];
    [[EXPERTconnect shared] setAuthenticationTokenDelegate:self];
    
    [[EXPERTconnect shared] setDebugLevel:5];
}

-(void) fetchAuthenticationToken:(void (^)(NSString *, NSError *))completion {
    // add /ust for new method
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:_testAuthURL]
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         
         long statusCode = (long)((NSHTTPURLResponse*)response).statusCode;
         NSString *returnToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         
         if(!error && (statusCode == 200 || statusCode == 201))
         {
             //NSLog(@"Successfully fetched authToken: %@", returnToken);
             completion([NSString stringWithFormat:@"%@", returnToken], nil);
         }
         else
         {
             NSError *myError = [NSError errorWithDomain:@"com.humanify"
                                                    code:statusCode
                                                userInfo:[NSDictionary dictionaryWithObject:returnToken forKey:@"errorJson"]];
             completion(nil, myError);
         }
     }];
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMakeDecision {
    
    [self setUp];
    [self initSDK];
    
    ECSURLSessionManager *session = [[EXPERTconnect shared] urlSession];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testMakeDecision"]; // Define a new expectation
    
    [session makeDecision:[NSDictionary dictionaryWithObject:@"test" forKey:@"test"]
               completion:^(NSDictionary *response, NSError *error)
    {
        XCTAssert(!error,@"API call had an error.");
        
        NSLog(@"Response JSON = %@", response);
        
        XCTAssert(response[@"tenant"], @"Missing tenant field.");
        
        [expectation fulfill]; // Tell the loop to stop waiting - test is finished.
    }];
    
    // Goes at bottom of test function
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testGetDetailsForSkill {
    
    [self setUp];   // Test setup
    [self initSDK]; // SDK setup
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"getDetailsForSkill"];
    
    NSString *skillName = @"CE_Mobile_Chat";
    
    // Should throw a deprecation warning but still work against 5.3 and later (until officially deprecated).
    [[EXPERTconnect shared] getDetailsForSkill:skillName
                                    completion:^(NSDictionary *details, NSError *error)
     {
         
         NSLog(@"Details: %@", details);
         
         if(error)
         {
             XCTFail(@"Error reported: %@", error.description);
         }
         else
         {
             // Check each of the JSON response fields to make sure they are there.
             XCTAssert(details[@"chatEnabledAgentsLoggedOn"],@"Missing chatEnabledAgentsLoggedOn field.");
             XCTAssert(details[@"estimatedWait"],@"Missing estimatedWait field.");
             XCTAssert(details[@"inQueue"],@"Missing inQueue field.");
             XCTAssert(details[@"escalationVoiceAvailability"],@"Missing escalationVoiceAvailability field.");
             XCTAssert(details[@"escalationChatAvailability"],@"Missing escalationChatAvailability field.");
             XCTAssert(details[@"voiceAvailability"],@"Missing voiceAvailability field.");
             XCTAssert(details[@"chatAvailability"],@"Missing chatAvailability field.");
             XCTAssert(details[@"escalationSkill"],@"Missing escalationSkill field.");
             XCTAssert(details[@"escalationAgentsLoggedOn"],@"Missing escalationAgentsLoggedOn field.");
             XCTAssert(details[@"connectedToAgent"],@"Missing connectedToAgent field.");
             XCTAssert(details[@"escalationSkillOpen"],@"Missing escalationSkillOpen field.");
             XCTAssert(details[@"escalationChatEnabledAgentsLoggedOn"],@"Missing escalationChatEnabledAgentsLoggedOn field.");
             XCTAssert(details[@"tenant"],@"Missing tenant field.");
             XCTAssert(details[@"skillName"],@"Missing skillName field.");
             XCTAssert(details[@"agentsLoggedOn"],@"Missing agentsLoggedOn field.");
             XCTAssert(details[@"open"],@"Missing open field.");
             XCTAssert(details[@"_links"],@"Missing _links field.");
             
             XCTAssert([details[@"skillName"] isEqualToString:skillName], @"skillName does not match.");
         }
         [expectation fulfill];
     }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

-(void)testNetworkReachable {
    ECSURLSessionManager *session = [[EXPERTconnect shared] urlSession];
    
    BOOL retVal = [session networkReachable];
    
    XCTAssert(retVal, @"Network not reachable.");
}

@end
