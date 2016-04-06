//
//  EXPERTconnectTests.m
//  EXPERTconnectTests
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <EXPERTconnect/EXPERTconnect.h>
#import "ECSConversationCreateResponse.h"

@class ECSConversationCreateResponse;

@interface EXPERTconnectTests : XCTestCase <ECSAuthenticationTokenDelegate>

@end

@implementation EXPERTconnectTests

NSURL *_testAuthURL;

- (void)setUp {
    [super setUp];
}

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
    
    // A GOOD auth URL
    _testAuthURL = [[NSURL alloc] initWithString:
                    [NSString stringWithFormat:@"https://api.dce1.humanify.com/authServerProxy/v1/tokens/ust?username=%@&client_id=%@",
                     @"expertconnect_unit_test",
                     @"mktwebextc"]];
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
             NSLog(@"Successfully fetched authToken: %@", returnToken);
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

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}




// ***** START OF TEST CASES ***** //




/**
 Test: startJourney()
 
 Step1: Test missing auth delegate.
 Step2: Test bogus URL (simulating that we cannot fetch a token). Should test retry & delays.
 Step3: Test with a good auth token fetch.
 */
- (void)testAuthentication {
    
    ECSConfiguration *configuration = [ECSConfiguration new];
    configuration.appName       = @"EXPERTconnect UnitTester";
    configuration.appVersion    = @"1.0";
    configuration.appId         = @"12345";
    configuration.host          = @"https://api.dce1.humanify.com";
    [[EXPERTconnect shared] initializeWithConfiguration:configuration];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAuthentication"];
    
    // Test 1: No identity delegate function populated. Should fail with a 1001 error.
    [[EXPERTconnect shared] startJourneyWithCompletion:^(NSString *journeyId, NSError *error)
    {
        XCTAssert(error.code==1001, @"Missing token delegate function error not working properly.");
        
        // A bad auth URL
        _testAuthURL = [[NSURL alloc] initWithString:
                        [NSString stringWithFormat:@"https://api.dce1.humanify.com/authServerProxy/v1/tokens/xxxust?username=%@&client_id=%@",
                         @"expertconnect_unit_test",
                         @"mktwebextc"]];
        
        // Now let's set the auth delegate so it will pass that test. However, the URL is bogus, so it should go into retry mode.
        [[EXPERTconnect shared] setAuthenticationTokenDelegate:self];
        
        // Test 2: Should throw an error after 3 auth attempts.
        [[EXPERTconnect shared] startJourneyWithCompletion:^(NSString *journeyId, NSError *error)
        {
            XCTAssert(error.code==404, @"Should return a 404 error code for URL not found.");
            
            // A GOOD auth URL
            _testAuthURL = [[NSURL alloc] initWithString:
                            [NSString stringWithFormat:@"https://api.dce1.humanify.com/authServerProxy/v1/tokens/ust?username=%@&client_id=%@",
                             @"expertconnect_unit_test",
                             @"mktwebextc"]];
            
            // Test 3: Now that we have plugged in a good URL, everything should work correctly.
            [[EXPERTconnect shared] startJourneyWithCompletion:^(NSString *journeyId, NSError *error)
            {
                XCTAssert((journeyId.length>0 && error == nil), @"Should have a good journeyID after a successful authentication attempt.");
                XCTAssert([journeyId containsString:@"journey"] && [journeyId containsString:@"_mktwebextc"], @"JourneyId does not contain required pieces.");
                [expectation fulfill];
            }];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:30.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (30 seconds). Error=%@", error);
        }
    }];
}

/**
 Test: startJourney()
 
 Step1: Start 1st journey. Verify journey creation.
 Step2: Start a 2nd journey. Verify journey overwrites older journey.
 Step3: Start a chat. Verify chat uses startJourney() value.
 Step4: Start a 2nd chat. Verify numerous operations still use same journeyID.
 Step5: Start a 3rd journey. Setup to verify overwrite with chat.
 Step6: Start a 3rd chat. Verify new chat uses a new journey when one is created.
 
 */
- (void)testStartJourney {
    
    [self initSDK];
    // Test startJourney returning a journeyID.
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"journeyid"];
    
    // Start the first journey
    [[EXPERTconnect shared] startJourneyWithCompletion:^(NSString *journeyID, NSError *err) {
        NSLog(@"Test journeyID 1 is %@", journeyID);
        XCTAssert(journeyID.length > 0, @"JourneyID string length was 0.");
        XCTAssert([journeyID containsString:@"mktwebextc"], @"JourneyID did not contain organization.");
        XCTAssert([journeyID containsString:@"journey"], @"JourneyID did not contain the word journey");
        XCTAssertNotNil([EXPERTconnect shared].journeyID, @"JourneyID was not populated in ExpertConnect object");
        
        // Start a second journey
        [[EXPERTconnect shared] startJourneyWithCompletion:^(NSString *journeyID2, NSError *err2) {
            NSLog(@"Test journeyID 2 is %@", journeyID2);
            XCTAssert(journeyID2.length > 0, @"JourneyID string length was 0.");
            XCTAssert([journeyID2 containsString:@"mktwebextc"], @"JourneyID did not contain organization.");
            XCTAssert([journeyID2 containsString:@"journey"], @"JourneyID did not contain the word journey");
            XCTAssertFalse([journeyID2 isEqualToString:journeyID]);
            
            XCTAssertNotNil([EXPERTconnect shared].journeyID, @"JourneyID was not populated in ExpertConnect object");
            
            // Attempt to start a chat using the second journeyID.
            ECSURLSessionManager *session = [[EXPERTconnect shared] urlSession];
            [session setupConversationWithLocation:@"home"
                                        completion:^(ECSConversationCreateResponse *createResponse, NSError *error)
             {
                 NSLog(@"Chat 1 started with journey 2: %@.", createResponse.journeyID);
                 
                 // The journey returned should be the same journey we sent to the server.
                 XCTAssertEqualObjects(journeyID2, createResponse.journeyID, @"setupConversation did not return same journeyID it sent.");
                 
                 // Attempt to start a second chat still using the second journeyID.
                 ECSURLSessionManager *session = [[EXPERTconnect shared] urlSession];
                 [session setupConversationWithLocation:@"home"
                                             completion:^(ECSConversationCreateResponse *createResponse, NSError *error)
                  {
                      NSLog(@"Chat 2 started with journey 2: %@.", createResponse.journeyID);
                      
                      // The journey returned should be the same journey we sent to the server.
                      XCTAssertEqualObjects(journeyID2, createResponse.journeyID, @"setupConversation did not return same journeyID it sent.");
                      
                      // Start a third journey
                      [[EXPERTconnect shared] startJourneyWithCompletion:^(NSString *journeyID3, NSError *err3) {
                          NSLog(@"Test journeyID 3 is %@", journeyID3);
                          XCTAssert(journeyID3.length > 0, @"JourneyID string length was 0.");
                          XCTAssert([journeyID3 containsString:@"mktwebextc"], @"JourneyID did not contain organization.");
                          XCTAssert([journeyID3 containsString:@"journey"], @"JourneyID did not contain the word journey");
                          XCTAssertFalse([journeyID3 isEqualToString:journeyID2]);
                          
                          XCTAssertNotNil([EXPERTconnect shared].journeyID, @"JourneyID was not populated in ExpertConnect object");
                          
                          // Attempt to start a third chat using the THIRD journeyID.
                          ECSURLSessionManager *session = [[EXPERTconnect shared] urlSession];
                          [session setupConversationWithLocation:@"home"
                                                      completion:^(ECSConversationCreateResponse *createResponse, NSError *error)
                           {
                               NSLog(@"Chat 3 started with journey 3: %@.", createResponse.journeyID);
                               
                               // The journey returned should be the same journey we sent to the server.
                               XCTAssertEqualObjects(journeyID3, createResponse.journeyID, @"setupConversation did not return same journeyID it sent.");
                               
                               [expectation fulfill];
                               
                           }];
                          
                      }];
                  }];
             }];
            
            
        }];
    }];
    
    [self waitForExpectationsWithTimeout:30.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (30 seconds). Error=%@", error);
        }
    }];
}

// Can't do too much with this -- it just sends off to server and allows for no feedback.
- (void)testBreadcrumbBulk {
    
    [self initSDK];

    [[EXPERTconnect shared] breadcrumbWithAction:@"BC Unit Test 1"
                                     description:@"Missing journey/clientid/secret/etc"
                                          source:@"ExpertConnect"
                                     destination:@"na"
                                     geolocation:nil];
    
    // TBD: This is not a very good test!

}

- (void)testBreadcrumbSendOne {
    
    [self initSDK];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testBreadcrumbSendOne"];
    
    ECSBreadcrumb *myBc = [[ECSBreadcrumb alloc] initWithAction:@"click"
                                                    description:@"Mobile Phone"
                                                         source:@"Phones"
                                                    destination:@"Product Page"];
    
    [[EXPERTconnect shared] breadcrumbSendOne:myBc withCompletion:^(NSDictionary *jsonDic, NSError *error)
    {
        [expectation fulfill];
    }];
    
    // Wait for the above code to finish (15 second timeout)...
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testBreadcrumbObject {
    
    [self initSDK];
    ECSBreadcrumb *myBc = [[ECSBreadcrumb alloc] init];
    
    // Test the getters and setters for fields in the BC object. 
    myBc.actionId = @"testActionId";
    XCTAssert([myBc.actionId isEqualToString:@"testActionId"],@"ActionId getter or setter failed");
    NSString *actionFromProperties = [[myBc getProperties] objectForKey:@"id"];
    XCTAssert([actionFromProperties isEqualToString:@"testActionId"],@"Properties array not built correctly.");
    
    myBc.journeyId = @"testJourneyId";
    XCTAssert([myBc.journeyId isEqualToString:@"testJourneyId"],@"journeyId getter or setter failed");
    NSString *journeyFromProperties = [[myBc getProperties] objectForKey:@"journeyId"];
    XCTAssert([journeyFromProperties isEqualToString:@"testJourneyId"],@"Properties array not built correctly.");
}

- (void)testGetDetailsForSkill {
    
    [self initSDK];
    XCTestExpectation *expectation = [self expectationWithDescription:@"getDetailsForSkill"];
    
    NSString *skillName = @"CE_Mobile_Chat";
    
    [[EXPERTconnect shared] getDetailsForSkill:skillName
                                    completion:^(ECSSkillDetail *details, NSError *error)
    {
        NSLog(@"Details: %@", details);
        
        XCTAssert(details.description.length>0, @"Missing description text.");
        XCTAssert(details.active == 1 || details.active == 0, @"Active must be 1 or 0");
        XCTAssert([details.skillName containsString:skillName], @"Missing skill name");
        XCTAssertGreaterThanOrEqual(details.estWait, -1, @"Bad estimated wait value");
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

// Test the select experts endpoint.
- (void)testSelectExperts {
    
    [self initSDK];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"getExperts"];
    
    ECSURLSessionManager *session = [[EXPERTconnect shared] urlSession];
    
    [session getExpertsWithInteractionItems:nil
                                 completion:^(NSArray *experts, NSError *error)
    {
        NSLog(@"Experts Array: %@", experts);
        XCTAssert(experts.count>0,@"No experts returned.");
        NSArray *expertsArray = [ECSJSONSerializer arrayFromJSONArray:experts withClass:[ECSExpertDetail class]];
        ECSExpertDetail *expert1 = expertsArray[0];
        XCTAssert(expert1.status.length>0,@"No status found.");
        XCTAssert(expert1.chatsToRejectVoice == YES || expert1.chatsToRejectVoice == NO,@"chatToRejectVoice invalid value.");
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testStartupTiming {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        [self initSDK];
    }];
}

@end
