//
//  ECDLocalization.m
//  EXPERTconnectDemo
//
//  Created by Ken Washington on 7/20/15.
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECDLocalization.h"


NSString* ECDLocalizedString(NSString *key, NSString *comment)
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *string = [[NSBundle mainBundle] localizedStringForKey:key value:nil table:nil];
    
    if (!string || [string isEqualToString:key])
    {
        string = [[NSBundle bundleWithIdentifier:@"com.humanify.EXPERTconnectDemo"] localizedStringForKey:key
                                                                                                value:nil
                                                                                                table:nil];
        
        // Load from App Bundle did not work, so try getting the Bundle File based on Path
        //
        if (!string || [string isEqualToString:key])   {
            NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
            NSArray* languages = [defs objectForKey:@"AppleLanguages"];
            NSString *current = [languages objectAtIndex:0];
            unsigned long len = [current length];
            
            NSString *path = [[ NSBundle mainBundle ] pathForResource:current ofType:@"lproj" ];
            bundle = [NSBundle bundleWithPath:path];
            
            string = [bundle localizedStringForKey:key value:nil table:nil];
            
            // Load from file did not work at "current" language, so if length > 2 (i.e., fr-CA), try the base language
            //
            if ((!string || [string isEqualToString:key]) && len > 2)   {
                current = [current substringToIndex:2];
                NSString *path = [[ NSBundle mainBundle ] pathForResource:current ofType:@"lproj" ];
                bundle = [NSBundle bundleWithPath:path];
                
                string = [bundle localizedStringForKey:key value:nil table:nil];
                
                // Last ditch effort, set string to key at least. Comment might be better!
                //
                if(!string)  {
                    string = key;
                }
            }
        }
    }
    
    return string;
}
