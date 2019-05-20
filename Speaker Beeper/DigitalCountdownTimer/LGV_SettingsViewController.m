//
//  LGV_SettingsViewController.m
//  DigitalCountdownTimer
//
//  Created by Chris Marshall on 7/28/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import "LGV_SettingsViewController.h"

/*********************************************************/
/**
 \class LGV_SettingsViewController (Private Interface)
 \brief This controls the global settings tab view.
 */
@interface LGV_SettingsViewController ()

@end

/*********************************************************/
/**
 \class LGV_SettingsViewController
 \brief This controls the global settings tab view.
 */
@implementation LGV_SettingsViewController

/*********************************************************/
/**
 \brief 
 */
@synthesize scroll_speed_label;
@synthesize scroll_speed_slow_label;
@synthesize scroll_speed_fast_label;
@synthesize scroll_speed_slider;
@synthesize scrolling_sounds_label;
@synthesize scrolling_sounds_switch;
@synthesize visual_feedback_label;
@synthesize visual_feedback_switch;
@synthesize commander_mode_label;
@synthesize commander_mode_switch;

/*********************************************************/
/**
 \brief
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[self scroll_speed_slider] setValue:[[LGV_AppDelegate appDelegate] scrollSpeed]];
    [[self scrolling_sounds_switch] setOn:[[LGV_AppDelegate appDelegate] soundOn]];
    [[self visual_feedback_switch] setOn:[[LGV_AppDelegate appDelegate] visualFeedbackOn]];
    [[self commander_mode_switch] setOn:[[LGV_AppDelegate appDelegate] isCommanderModeOn]];
    
    [[self scroll_speed_label] setText:NSLocalizedString([[self scroll_speed_label] text], nil)];
    [[self scroll_speed_slow_label] setText:NSLocalizedString([[self scroll_speed_slow_label] text], nil)];
    [[self scroll_speed_fast_label] setText:NSLocalizedString([[self scroll_speed_fast_label] text], nil)];
    [[self scrolling_sounds_label] setText:NSLocalizedString([[self scrolling_sounds_label] text], nil)];
    [[self visual_feedback_label] setText:NSLocalizedString([[self visual_feedback_label] text], nil)];
    [[self commander_mode_label] setText:NSLocalizedString([[self commander_mode_label] text], nil)];
}

/*********************************************************/
/**
 \brief
 */
- (void)viewDidUnload
{
    [self setScroll_speed_label:nil];
    [self setScroll_speed_slow_label:nil];
    [self setScroll_speed_fast_label:nil];
    [self setScroll_speed_slider:nil];
    [self setScrolling_sounds_label:nil];
    [self setScrolling_sounds_switch:nil];
    [self setVisual_feedback_switch:nil];
    [self setVisual_feedback_label:nil];
    [self setCommander_mode_label:nil];
    [self setCommander_mode_switch:nil];
    [super viewDidUnload];
}

/*********************************************************/
/**
 \brief
 */
- (IBAction)scrollSpeedChanged:(UISlider *)sender
{
    int newVal = round([sender value]);
    
    [sender setValue:newVal];
    
    [[LGV_AppDelegate appDelegate] setScrollSpeed:newVal];
}

/*********************************************************/
/**
 \brief
 */
- (IBAction)scrollingSoundsChanged:(UISwitch *)sender
{
    [[LGV_AppDelegate appDelegate] setSoundOn:[sender isOn]];
}

/*********************************************************/
/**
 \brief
 */
- (IBAction)visualFeedbackChanged:(UISwitch *)sender
{
    [[LGV_AppDelegate appDelegate] setVisualFeedbackOn:[sender isOn]];
}

/*********************************************************/
/**
 \brief
 */
- (IBAction)commanderModeChanged:(UISwitch *)sender
{
    [[LGV_AppDelegate appDelegate] setCommanderModeOn:[sender isOn]];
}
@end
