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

@interface EXPERTconnectTests : XCTestCase <ECSAuthenticationTokenDelegate>{
    NSURL *_testAuthURL;
    NSString *_testTenant;
    NSString *_username;
    NSString *_fullname;
    NSString *_firstname;
}

@end

@implementation EXPERTconnectTests

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
                        @"gwen@email.com",
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
                //XCTAssert([journeyId containsString:@"journey"] && [journeyId containsString:@"_mktwebextc"], @"JourneyId does not contain required pieces.");
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
     XCTestExpectation *expectation = [self expectationWithDescription:@"getDetailsForExpertSkill"];
     
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
            
            // NOTE: This could be server config!
            XCTAssertFalse([journeyID2 isEqualToString:journeyID], @"Second journey call returned same journey as first.");
            
            XCTAssertNotNil([EXPERTconnect shared].journeyID, @"JourneyID was not populated in ExpertConnect object");
            
            [expectation fulfill];
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
    
    ECSBreadcrumb *bc1 = [[ECSBreadcrumb alloc] init];
    XCTAssert(!bc1.actionType,@"Should be an empty breadcrumb object.");
    bc1.actionType = @"bc1action";
    bc1.actionDescription = @"bc1desc";
    bc1.actionSource = @"bc1source";
    bc1.actionDestination = @"bc1dest";
    XCTAssert([bc1.actionType isEqualToString:@"bc1action"] &&
              [bc1.actionDescription isEqualToString:@"bc1desc"] &&
              [bc1.actionSource isEqualToString:@"bc1source"] &&
              [bc1.actionDestination isEqualToString:@"bc1dest"], @"initWithAction did not populate fields correctly.");
    
    ECSBreadcrumb *bc2 = [[ECSBreadcrumb alloc] initWithAction:@"bc2action" description:@"bc2desc" source:@"bc2source" destination:@"bc2dest"];
    XCTAssert([bc2.actionType isEqualToString:@"bc2action"] &&
              [bc2.actionDescription isEqualToString:@"bc2desc"] &&
              [bc2.actionSource isEqualToString:@"bc2source"] &&
              [bc2.actionDestination isEqualToString:@"bc2dest"], @"initWithAction did not populate fields correctly.");
    
    NSArray *keys = @[@"actionType",@"actionDescription",@"actionSource",@"actionDestination"];
    NSArray *objects = @[@"bc3action", @"bc3desc", @"bc3source", @"bc3dest"];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    ECSBreadcrumb *bc3 = [[ECSBreadcrumb alloc] initWithDic:dict];
    XCTAssert([bc3.actionType isEqualToString:@"bc3action"] &&
              [bc3.actionDescription isEqualToString:@"bc3desc"] &&
              [bc3.actionSource isEqualToString:@"bc3source"] &&
              [bc3.actionDestination isEqualToString:@"bc3dest"], @"initWithDic did not populate fields correctly.");
    
    bc3.tenantId = @"mktwebextc";
    bc3.journeyId = [EXPERTconnect shared].journeyID;
    bc3.sessionId = [EXPERTconnect shared].sessionID;
    bc3.userId = [EXPERTconnect shared].userName;
    bc3.actionId = @"abc123";
    bc3.pushNotificationId = @"unit_test_push_UUID";
    [bc3 setPushNotificationId:@"unit_test_push_UUID"];
    bc3.creationTime = [NSString stringWithFormat:@"%lld",[@(floor(NSDate.date.timeIntervalSince1970 * 1000)) longLongValue]];
    
    XCTAssert([bc3.pushNotificationId isEqualToString:@"unit_test_push_UUID"]&&[bc3.actionId isEqualToString:@"abc123"]&&[bc3.tenantId isEqualToString:@"mktwebextc"],@"Problem with getter/setter fields."); 
    
    CLLocation *testLocation = [[CLLocation alloc] initWithLatitude:31.34034 longitude:93.340340];
    bc3.geoLocation = testLocation; 
    
    NSLog(@"BC1=%@, BC2=%@, BC3=%@", bc1.description,bc2.description,bc3.description);
    
    ECSBreadcrumb *bc4 = [bc3 copy];
    XCTAssert([bc4.actionType isEqualToString:@"bc3action"] &&
              [bc4.actionDescription isEqualToString:@"bc3desc"] &&
              [bc4.actionSource isEqualToString:@"bc3source"] &&
              [bc4.actionDestination isEqualToString:@"bc3dest"], @"initWithDic did not populate fields correctly.");
    
    NSDictionary *properties = [bc4 getProperties];
    XCTAssert([properties[@"actionType"] isEqualToString:@"bc3action"] &&
              [properties[@"actionDescription"] isEqualToString:@"bc3desc"] &&
              [properties[@"actionSource"] isEqualToString:@"bc3source"] &&
              [properties[@"actionDestination"] isEqualToString:@"bc3dest"], @"initWithDic did not populate fields correctly.");
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
    
     [[EXPERTconnect shared] login:emailID
                    withCompletion:^(ECSForm *form, NSError *error)
    {
          NSLog(@"Details: %@", form);\
          if(error) XCTFail(@"Error: %@", error.description);
          
          // Specific tests
          XCTAssert(form.formData.count>0,@"Expected some form items");
          XCTAssert([form isKindOfClass:[ECSForm class]],@"Expected a form class for response.");
          XCTAssert(form.isInline == 1 || form.isInline == 0, @"Expected a 1 or 0 for isInline");
          XCTAssert([form.name isEqualToString:inputFormName],@"Expected name field to be same as input form name.");
          
          //XCTAssert(form.submitCompleteText.length>0,@"Expected submitCompleteText");
          //XCTAssert(form.submitCompleteHeaderText.length>0,@"Expected submitCompleteHeaderText");
          //XCTAssert(form.submitText.length>0,@"Expected submitText");
          
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

- (void)testProperties
{
     [self initSDK];
    
    [EXPERTconnect shared].userName = @"gwen@email.com";
    
     //Here sdk initialization properties are tested.
     BOOL authentiacation = [[EXPERTconnect shared] authenticationRequired];
     XCTAssert(authentiacation == 1 || authentiacation == 0, @"Expected a 1 or 0 for authentiaction");
     
     NSString *displayName = [[EXPERTconnect shared] userDisplayName];
     XCTAssert(displayName.length>0,@"Expected display name");
     
     NSString *userName = [[EXPERTconnect shared] userName];
     XCTAssert(userName.length>0,@"Expected user name");

     NSString *EXPERTconnectVersion = [[EXPERTconnect shared] EXPERTconnectVersion];
     XCTAssert(EXPERTconnectVersion.length>0,@"Expected EXPERTconnect Version");

     NSString *EXPERTconnectBuildVersion = [[EXPERTconnect shared] EXPERTconnectBuildVersion];
     XCTAssert(EXPERTconnectBuildVersion.length>0,@"Expected EXPERTconnect BuildVersion");
     
     [[EXPERTconnect shared] setUserIntent:@"testUserIntent"];
     NSString *userIntent = [[EXPERTconnect shared] userIntent];
     XCTAssert([userIntent isEqualToString:@"testUserIntent"],@"userIntent getter or setter failed");
     
     [[EXPERTconnect shared] setJourneyID:@"testJourneyId"];
     NSString *journeyID = [[EXPERTconnect shared] journeyID];
     XCTAssert([journeyID isEqualToString:@"testJourneyId"],@"journeyID getter or setter failed");
     
     [[EXPERTconnect shared] setJourneyManagerContext:@"testJourneyManagerContext"];
     NSString *journeyManagerContext = [[EXPERTconnect shared] journeyManagerContext];
     XCTAssert([journeyManagerContext isEqualToString:@"testJourneyManagerContext"],@"JourneyManagerContext getter or setter failed");
     
     [[EXPERTconnect shared] setPushNotificationID:@"testPushNotificationID"];
     NSString *pushNotificationID = [[EXPERTconnect shared] pushNotificationID];
     XCTAssert([pushNotificationID isEqualToString:@"testPushNotificationID"],@"PushNotificationID getter or setter failed");
     
     NSString *getTimeStamp = [[EXPERTconnect shared] getTimeStampMessage];
     XCTAssert(getTimeStamp.length>0,@"Expected TimeStamp Message");
     
     [[EXPERTconnect shared] overrideDeviceLocale:@"testOverrideDeviceLocale"];
     NSString *overrideDeviceLocale = [[EXPERTconnect shared] overrideDeviceLocale];
     XCTAssert([overrideDeviceLocale isEqualToString:@"testOverrideDeviceLocale"],@"OverrideDeviceLocale getter or setter failed");
}

- (void)testStartupTiming {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        [self initSDK];
    }];
}

- (void)testSDKDebug {
    
    [self initSDK];
    
    [[EXPERTconnect shared] setLoggingCallback:^(ECSLogLevel level, NSString *message) {
        NSString *levelString = ^NSString *() {
            switch (level)
            {
                case ECSLogLevelError:
                    return @"Error";
                case ECSLogLevelWarning:
                    return @"Warning";
                case ECSLogLevelDebug:
                    return @"Debug";
                case ECSLogLevelVerbose:
                    return @"Info";
                case ECSLogLevelNone:
                    return @"None";
            }
        }();
        
        XCTAssert(@"[iOS SDK]: ",@"(%@): %@", levelString, message);
        
    }];
}

@end
