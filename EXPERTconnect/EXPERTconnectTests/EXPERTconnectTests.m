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

@interface EXPERTconnectTests : XCTestCase

@end

@implementation EXPERTconnectTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    ECSConfiguration *configuration = [ECSConfiguration new];
    
    configuration.appName       = @"EXPERTconnect UnitTester";
    configuration.appVersion    = @"1.0";
    configuration.appId         = @"12345";
    
    //configuration.cafeXHost     = @"dcapp01.ttechenabled.net";
    
    configuration.host          = @"http://api.humanify.com:8080"; // IntDev
    
    configuration.clientID      = @"mktwebextc";
    configuration.clientSecret  = @"secret123";
    
    [[EXPERTconnect shared] initializeWithConfiguration:configuration];
    //[[EXPERTconnect shared] initializeVideoComponents]; // CafeX initialization.
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
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
- (void)testBreadcrumbAction {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"breadcrumb"];
    [[EXPERTconnect shared] startJourneyWithCompletion:^(NSString *journeyID, NSError *err) {
        
        // Should use the journeyID gathered above.
        [[EXPERTconnect shared] breadcrumbsAction:@"unitTestBreadcrumbAction"
                                actionDescription:@"A developer is unit testing breadcrumbs"
                                     actionSource:@"Xcode"
                                actionDestination:@"Humanify"];
        
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
    
}

- (void)testExampleServerFetch {
    // Test startJourney returning a journeyID.
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"journeyid"];
    
    [[EXPERTconnect shared] startJourneyWithCompletion:^(NSString *journeyID, NSError *err) {
        NSLog(@"Test journeyID 1 is %@", journeyID);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Timeout error (15 seconds). Error=%@", error);
        }
    }];
}

/*- (void)testPerformanceExample {
 // This is an example of a performance test case.
 [self measureBlock:^{
 // Put the code you want to measure the time of here.
 }];
 }*/

@end
