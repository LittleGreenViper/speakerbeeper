//
//  LGV_AppDelegate_Prefs.h
//  DigitalCountdownTimer
//
//  Created by Chris Marshall on 8/1/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

/// Since these are colors, they must be specified as macros.
#define k_LGV_AppDelegate_timer_off_color   [UIColor colorWithWhite:1.0 alpha:0.1]                                      /**< The color displayed by "off" LED elements */

///< The color of the Start button gradients.
#define k_LGV_Start_Button_Low              [UIColor colorWithRed:0.0 green:0.3 blue:0.0 alpha:1.0]
#define k_LGV_Start_Button_High             [UIColor colorWithRed:0.0 green:0.7 blue:0.0 alpha:1.0]

/// These define the colors of the "Podium Mode" "lights."
#define k_LGV_Quiet_Mode_Green_Dark_Low     [UIColor colorWithRed:0.0 green:0.4 blue:0.0 alpha:0.1]
#define k_LGV_Quiet_Mode_Green_Dark_High    [UIColor colorWithRed:0.0 green:0.4 blue:0.0 alpha:1.0]

#define k_LGV_Quiet_Mode_Green_Light_Low    [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.1]
#define k_LGV_Quiet_Mode_Green_Light_High   [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0]

#define k_LGV_Quiet_Mode_Yellow_Dark_Low    [UIColor colorWithRed:0.4 green:0.4 blue:0.0 alpha:0.1]
#define k_LGV_Quiet_Mode_Yellow_Dark_High   [UIColor colorWithRed:0.4 green:0.4 blue:0.0 alpha:1.0]

#define k_LGV_Quiet_Mode_Yellow_Light_Low   [UIColor colorWithRed:0.9294117647 green:0.8392156863 blue:0.1490196078 alpha:0.1]
#define k_LGV_Quiet_Mode_Yellow_Light_High  [UIColor colorWithRed:0.9294117647 green:0.8392156863 blue:0.1490196078 alpha:1.0]

#define k_LGV_Quiet_Mode_Red_Dark_Low       [UIColor colorWithRed:0.4 green:0.0 blue:0.0 alpha:0.1]
#define k_LGV_Quiet_Mode_Red_Dark_High      [UIColor colorWithRed:0.4 green:0.0 blue:0.0 alpha:1.0]

#define k_LGV_Quiet_Mode_Red_Light_Low      [UIColor colorWithRed:0.9333333333 green:0.1764705882 blue:0.2078431373 alpha:0.1]
#define k_LGV_Quiet_Mode_Red_Light_High     [UIColor colorWithRed:0.9333333333 green:0.1764705882 blue:0.2078431373 alpha:1.0]

/// These define the colors of the standard settings buttons and font sizes.
#define k_LGV_Prefs_Button_Color            [UIColor blackColor]

#define k_LGV_TopBarColor                   [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]

#define k_LGV_StandardTextSize_iPhone       [UIFont systemFontOfSize :14]
#define k_LGV_StandardTextSize_iPad         [UIFont systemFontOfSize:24]

#define k_LGV_StandardTextSizeBold_iPhone   [UIFont boldSystemFontOfSize:14]
#define k_LGV_StandardTextSizeBold_iPad     [UIFont boldSystemFontOfSize:24]

#define k_LGV_ItalicTextSize_Prompt         [UIFont italicSystemFontOfSize:24]

static const    NSInteger   s_default_timer_1_color_index           = 0;            ///< The index of timer 1 color.
static const    NSInteger   s_default_timer_2_color_index           = 1;            ///< The index of timer 2 color.
static const    NSInteger   s_default_timer_3_color_index           = 2;            ///< The index of timer 3 color.

/// These are the default values for an "auto-threshold."
static const    float       s_default_warning_threshold_for_auto    = 1.0 / 6.0;    ///< The warning threshold
static const    float       s_default_final_threshold_for_auto      = 5.0 / 60.0;   ///< The final countdown threshold.

// This is used for the prefs.
static const NSString    *s_selected_color_key      = @"selected_color";        ///< This is an index for the selected color.
static const NSString    *s_quiet_mode_key          = @"quiet_mode";            ///< The "quiet mode" key.
static const NSString    *s_slave_mode_key          = @"slave_mode";            ///< The "slave mode" key.
static const NSString    *s_selected_commander_key  = @"selected_commander";    ///< The "selected slave commander" key.
static const NSString    *s_auto_threshold_key      = @"auto_threshold";        ///< The auto threshold key.

static const int        k_LGV_SpeakerBeeper_CommanderLinkCellHeight = 40;       ///< The row height for the Bonjour list in the timer prefs.

