//
//  EXPERTconnectTests.m
//  EXPERTconnectTests
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <EXPERTconnect/EXPERTconnect.h>
//#import "ECSConversationCreateResponse.h"
//@class ECSConversationCreateResponse;

@interface EXPERTconnectTests : XCTestCase <ECSAuthenticationTokenDelegate>

@end

@implementation EXPERTconnectTests

NSURL *_testAuthURL;
NSString *_testTenant;

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
    
    if(!_testTenant) _testTenant = @"mktwebextc";
    // A GOOD auth URL
    _testAuthURL = [[NSURL alloc] initWithString:
                    [NSString stringWithFormat:@"%@/authServerProxy/v1/tokens/ust?username=%@&client_id=%@",
                        configuration.host,
                        @"expertconnect_unit_test",
                        _testTenant]];
    
    [[EXPERTconnect shared] initializeWithConfiguration:configuration];
    //[[EXPERTconnect shared] initializeVideoComponents]; // CafeX initialization.
    

    
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

- (void) testExpertConnectAsClass {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testExpertConnectAsClass"];
    EXPERTconnect *myEC = [[EXPERTconnect alloc] init];
    ECSConfiguration *configuration = [ECSConfiguration new];
    configuration.appName       = @"EXPERTconnect UnitTester";
    configuration.appVersion    = @"1.0";
    configuration.appId         = @"12345";
    configuration.host          = @"https://api.dce1.humanify.com";
    [myEC initializeWithConfiguration:configuration];
    
    _testAuthURL = [[NSURL alloc] initWithString:
                    [NSString stringWithFormat:@"https://api.dce1.humanify.com/authServerProxy/v1/tokens/ust?username=%@&client_id=%@",
                     @"expertconnect_unit_test",
                     @"mktwebextc"]];
    [myEC setAuthenticationTokenDelegate:self];
    
    [myEC startJourneyWithCompletion:^(NSString *journeyID, NSError *error) {
        NSLog(@"Journey created.");
        
        [myEC getDetailsForExpertSkill:@"CE_Mobile_Chat" completion:^(ECSSkillDetail *detail, NSError *error) {
            // was journeyID in the header?
            
            [expectation fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) { 
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testGetDetailsForExpertSkill {
     
     [self initSDK];
     XCTestExpectation *expectation = [self expectationWithDescription:@"getDetailsForSkill"];
     
     NSString *skillName = @"CE_Mobile_Chat";
     
     [[EXPERTconnect shared] getDetailsForExpertSkill:skillName
                                           completion:^(ECSSkillDetail *details, NSError *error)
      {
           NSLog(@"Details: %@", details);
           if(error) XCTFail(@"Error: %@", error.description);
           
           // Specific Tests
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
    
    // First let's double check the parameter getter/setters
    [EXPERTconnect shared].journeyID = @"MikeJourneyIDTest";
    XCTAssert([[EXPERTconnect shared].journeyID isEqualToString:@"MikeJourneyIDTest"], @"JourneyID is not what we set it to");
    XCTAssert([[EXPERTconnect shared].journeyID isEqualToString:[EXPERTconnect shared].urlSession.journeyID],@"JourneyID should match what URLSession has");
    [EXPERTconnect shared].journeyID = nil;
    
    [self initSDK];
    // Test startJourney returning a journeyID.
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"journeyid"];
    
    // Start the first journey
    [[EXPERTconnect shared] startJourneyWithCompletion:^(NSString *journeyID, NSError *err)
    {
        NSLog(@"Test journeyID 1 is %@", journeyID);
        XCTAssert(journeyID.length > 0, @"JourneyID string length was 0.");
        //XCTAssert([journeyID containsString:@"mktwebextc"], @"JourneyID did not contain organization.");
        XCTAssert([journeyID containsString:@"journey"], @"JourneyID did not contain the word journey");
        XCTAssertNotNil([EXPERTconnect shared].journeyID, @"JourneyID was not populated in ExpertConnect object");
        
        // Start a second journey
        [[EXPERTconnect shared] startJourneyWithCompletion:^(NSString *journeyID2, NSError *err2)
        {
            NSLog(@"Test journeyID 2 is %@", journeyID2);
            XCTAssert(journeyID2.length > 0, @"JourneyID string length was 0.");
            //XCTAssert([journeyID2 containsString:@"mktwebextc"], @"JourneyID did not contain organization.");
            XCTAssert([journeyID2 containsString:@"journey"], @"JourneyID did not contain the word journey");
            XCTAssertFalse([journeyID2 isEqualToString:journeyID], @"Second journey call returned same journey as first.");
            
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
                          //XCTAssert([journeyID3 containsString:@"mktwebextc"], @"JourneyID did not contain organization.");
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
    
    ECSBreadcrumb *myBc = [[ECSBreadcrumb alloc] initWithAction:@"test!@$_\'"
                                                    description:@"this is a very long description about sending one breadcrumb to the server. This unit test should successfully reflect my very long description."
                                                         source:@"-(unit test)"
                                                    destination:@"<script>alert('oh oh!')</script>"];
    
    [[EXPERTconnect shared] breadcrumbSendOne:myBc withCompletion:^(ECSBreadcrumbResponse *bcr, NSError *error)
    {
        XCTAssert([bcr.actionType isEqualToString:@"test!@$_\'"], @"type missing or not matching.");
        XCTAssert([bcr.actionDescription isEqualToString:@"this is a very long description about sending one breadcrumb to the server. This unit test should successfully reflect my very long description."], @"description missing or not matching.");
        XCTAssert([bcr.actionSource isEqualToString:@"-(unit test)"], @"source missing or not matching.");
        XCTAssert([bcr.actionDestination isEqualToString:@"<script>alert('oh oh!')</script>"], @"destination missing or not matching.");

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

- (void)testSetJourneyContext {
    
    [self initSDK];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testBreadcrumbSendOne"];
    
    // First, start a journey...
    [[EXPERTconnect shared] startJourneyWithCompletion:^(NSString *journeyId, NSError *error)
    {
        // Second, set the context...
        [[EXPERTconnect shared] setJourneyContext:@"SDK Baseline"
                                   withCompletion:^(ECSJourneyAttachResponse *response, NSError *error)
         {
             NSLog(@"Response=%@", response);
             XCTAssert(!error,@"Not expecting an error.");
             XCTAssert(response,@"Expecting response.");
             XCTAssert([response.tenantId isEqualToString:_testTenant], @"Expecting input tenant.");
             XCTAssert([response.deviceType isEqualToString:@"ios"], @"Expecting ios as devicetype.");
             //XCTAssert([response.pushNotificationId isEqualToString:@"aaaa-bbbb-cccc-dddd"],@"Expecting input pushID.");
             XCTAssert(response.contextId.length>0, @"Expecting populated contextID");
             XCTAssert(response.lastActivityTime, @"Expecting lastActivityTime");
             XCTAssert(response.creationTime, @"Expecting lastActivityTime");
             [expectation fulfill];
         }];
        
        
    }];
    // Wait for the above code to finish (15 second timeout)...
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

- (void)testLoginWithEmailID
{
     [self initSDK];
     
     __block int expectedResponses = 1;
     __block NSString *inputFormName = @"userprofile";
     XCTestExpectation *expectation = [self expectationWithDescription:@"testLoginWithEmailID"];
     NSString *emailID = @"yasar.arafath@agiliztech.com";
     [[EXPERTconnect shared] login:emailID withCompletion:^(ECSForm *form, NSError *error) {
          NSLog(@"Details: %@", form);\
          if(error) XCTFail(@"Error: %@", error.description);
          
          // Specific tests
          XCTAssert(form.formData.count>0,@"Expected some form items");
          XCTAssert([form isKindOfClass:[ECSForm class]],@"Expected a form class for response.");
          XCTAssert(form.isInline == 1 || form.isInline == 0, @"Expected a 1 or 0 for isInline");
          XCTAssert([form.name isEqualToString:inputFormName],@"Expected name field to be same as input form name.");
          
          XCTAssert(form.submitCompleteText.length>0,@"Expected submitCompleteText");
          XCTAssert(form.submitCompleteHeaderText.length>0,@"Expected submitCompleteHeaderText");
          XCTAssert(form.submitText.length>0,@"Expected submitText");
          
          expectedResponses--;
          if(expectedResponses <= 0)[expectation fulfill];
     }];
     // Wait for the above code to finish (15 second timeout)...
     [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
          if (error) {
               XCTFail(@"Timeout error (15 seconds). Error=%@", error);
          }
     }];
}

- (void)testBreadcrumbNewSession {
     
     [self initSDK];
     
     XCTestExpectation *expectation = [self expectationWithDescription:@"testBreadcrumbNewSession"];
     
     [[EXPERTconnect shared] breadcrumbNewSessionWithCompletion:^(NSString *SessionID, NSError *error) {
          
          XCTAssert(!error,@"API call returned error.");
          XCTAssert(SessionID.length>0,@"Expected SessionID");
          [expectation fulfill];
      }];
     
     // Wait for the above code to finish (15 second timeout)...
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
