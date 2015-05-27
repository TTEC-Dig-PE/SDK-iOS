//
//  ECSLocalization.m
//  EXPERTconnect
//
//  Copyright (c) 2015 Humanify, Inc. All rights reserved.
//

#import "ECSLocalization.h"

NSString* ECSLocalizedString(NSString *key, NSString *comment)
{
    NSString *string = [[NSBundle mainBundle] localizedStringForKey:key value:nil table:nil];
    
    if (!string || [string isEqualToString:key])
    {
        string = [[NSBundle bundleWithIdentifier:@"com.humanify.EXPERTconnect"] localizedStringForKey:key
                                                                                                value:nil
                                                                                                table:nil];

    }
    
    return string;
}
