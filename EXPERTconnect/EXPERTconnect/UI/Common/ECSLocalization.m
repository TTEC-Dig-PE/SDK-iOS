//
//  ECSLocalization.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSLocalization.h"
#import "EXPERTconnect.h"

NSString* ECSLocalizedString(NSString *key, NSString *comment) {
    
    NSString *string = [[NSBundle mainBundle] localizedStringForKey:key value:nil table:nil];
    
    if (!string || [string isEqualToString:key]) {
        
        string = [[NSBundle bundleWithIdentifier:@"com.humanify.EXPERTconnect"] localizedStringForKey:key
                                                                                                value:nil
                                                                                                table:nil];
    }
    
    // CocoaPods
    if( !string || [string isEqualToString:key]) {
        
        //NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"EXPERTconnect" ofType:@"bundle"];
        NSBundle *ecBundle = [NSBundle bundleForClass:[EXPERTconnect class]];
        string = [ecBundle localizedStringForKey:key value:nil table:nil];
    }
    
    
    if( !string ) {
        
        NSLog(@"EXPERTconnect: ERROR: SDK localization files not loaded properly.");
        string = key; // Critical Failure. localizaiton files not working.
    }
    
    return string;
}
