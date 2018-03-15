//
//  ECSJSONSerializerTests.m
//  
//
//  Created by Erik LaManna on 1/8/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "ECSNavigationContext.h"
#import "ECSNavigationSection.h"
#import "ECSJSONSerializer.h"
@interface ECSJSONSerializerTests : XCTestCase

@end

@implementation ECSJSONSerializerTests

- (void)setUp {
    [super setUp];
    NSLog(@"HERE");
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    
    NSDictionary *navigationContext = @{@"title": @"Test",
                                        @"sections": @[
                                                @{
                                                    @"sectionTitle": @"Section 1",
                                                    @"sectionType": @"featured",
                                                    },
                                                @{
                                                    @"sectionTitle": @"Section 1",
                                                    @"sectionType": @"featured",
                                                    }
                                                ]
                                        };
    
    ECSNavigationContext *context = [ECSJSONSerializer importObjectFromClass:[ECSNavigationContext class]
                                                                fromDictionary:navigationContext];
    // This is an example of a functional test case.
    XCTAssert([context.title isEqualToString:@"Test"], @"Import of string type failed.");
    XCTAssert([context.sections count] == 2, @"Import of array of objects count not equal.");
    XCTAssert([[context.sections firstObject] isKindOfClass:[ECSNavigationSection class]], @"Import of model type is not correct.");
    XCTAssert([[[context.sections firstObject] sectionTitle] isEqualToString:@"Section 1"], @"Import of model type not complete.");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
