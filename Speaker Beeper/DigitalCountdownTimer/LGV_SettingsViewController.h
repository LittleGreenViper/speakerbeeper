//
//  LGV_SettingsViewController.h
//  DigitalCountdownTimer
//
//  Created by Chris Marshall on 7/28/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A_LGV_PrototypeWindow.h"

/*********************************************************/
/**
 \class LGV_SettingsViewController
 \brief This controls the global settings tab view.
 */
@interface LGV_SettingsViewController : A_LGV_PrototypeWindow
@property (weak, nonatomic) IBOutlet UILabel    *scroll_speed_label;
@property (weak, nonatomic) IBOutlet UILabel    *scroll_speed_slow_label;
@property (weak, nonatomic) IBOutlet UILabel    *scroll_speed_fast_label;
@property (weak, nonatomic) IBOutlet UISlider   *scroll_speed_slider;
@property (weak, nonatomic) IBOutlet UILabel    *scrolling_sounds_label;
@property (weak, nonatomic) IBOutlet UISwitch   *scrolling_sounds_switch;
@property (weak, nonatomic) IBOutlet UILabel    *visual_feedback_label;
@property (weak, nonatomic) IBOutlet UISwitch   *visual_feedback_switch;
@property (weak, nonatomic) IBOutlet UILabel    *commander_mode_label;
@property (weak, nonatomic) IBOutlet UISwitch   *commander_mode_switch;

- (IBAction)scrollSpeedChanged:(UISlider *)sender;
- (IBAction)scrollingSoundsChanged:(UISwitch *)sender;
- (IBAction)visualFeedbackChanged:(UISwitch *)sender;
- (IBAction)commanderModeChanged:(UISwitch *)sender;

@end
