//
//  PMTheme.h
//  PMCalendar
//
//  Created by Pavel Mazurin on 7/19/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import "ECSCalendarHelpers.h"
#import "ECSThemeEngine.h"

#define kPMThemeHeaderHeight [ECSThemeEngine sharedInstance].headerHeight
#define kPMThemeDefaultFont [ECSThemeEngine sharedInstance].defaultFont
#define kPMThemeInnerPadding [ECSThemeEngine sharedInstance].innerPadding
#define kPMThemeShadowPadding [ECSThemeEngine sharedInstance].shadowInsets
#define kPMThemeShadowBlurRadius [ECSThemeEngine sharedInstance].shadowBlurRadius
#define kPMThemeDayTitlesInHeader [ECSThemeEngine sharedInstance].dayTitlesInHeader
#define kPMThemeDayTitlesInHeaderIntOffset ((kPMThemeDayTitlesInHeader)?0:1)
#define kPMThemeCornerRadius [ECSThemeEngine sharedInstance].cornerRadius
#define kPMThemeArrowSize [ECSThemeEngine sharedInstance].arrowSize
#define kPMThemeOuterPadding [ECSThemeEngine sharedInstance].outerPadding
