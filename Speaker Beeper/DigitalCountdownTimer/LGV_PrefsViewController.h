//
//  LGV_PrefsViewController.h
//  DigitalCountdownTimer
//
//  Created by Chris Marshall on 7/28/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A_LGV_PrototypeWindow.h"
#import "LGV_PickerScroller.h"
#import "LGV_TimerSettingsViewController.h"

/*********************************************************/
/**
 \brief We extend the table cell class, so we can store our activity indicator.
 */
@interface LGV_TableViewCell : UITableViewCell
@property   (readwrite) UIActivityIndicatorView *activityIndicator;
@end

/*********************************************************/
/**
 \class LGV_PrefsViewController
 \brief This controls the individual settings tab view.
        It works by directly manipulating the prefs.
 */
@interface LGV_PrefsViewController : A_LGV_PrototypeWindow
@property (weak, nonatomic) IBOutlet UISegmentedControl     *soundSelectionSegmentedControl;    ///< This is the segmented control that turns on the timer completion sound.
@property (weak, nonatomic) IBOutlet UISwitch               *autoThresholdSwitch;               ///< This is the switch for selecting the automatic threshold setting.
@property (weak, nonatomic) IBOutlet UILabel                *autoThresholdLabel;                ///< This is its label.
@property (weak, nonatomic) IBOutlet UISegmentedControl     *modeSelectionSwitch;               ///< The mode selection bar at the top.
@property (weak, nonatomic) IBOutlet UIView                 *autoThresholdGroup;                ///< The group containing the auto threshold switch.
@property (weak, nonatomic) IBOutlet UIView                 *soundSelectionGroup;               ///< The group containing the sound selection.
@property (weak, nonatomic) IBOutlet UIView                 *peerReportContainer;               ///< The container view for the Bonjour listings.
@property (weak, nonatomic) IBOutlet UILabel                *peerReportLabel;                   ///< The main label for the commander listing.
@property (weak, nonatomic) IBOutlet UILabel                *soundLabel;                        ///< This is the label over the sound selection switch.
@property (weak, nonatomic) IBOutlet UIView                 *mainContainerView;                 ///< This view contains all the various controls.
@property (weak, nonatomic) LGV_TimerSettingsViewController *myController;                      ///< Yuck. We need to know about our controller to work in popover mode.
@property (nonatomic, readwrite)     BOOL                   isInPopover;                        ///< Double-yuck. The only way to be sure...

- (IBAction)modeSelectionChanged:(UISegmentedControl *)sender;  ///< Reacts to changes in the display mode selector.
- (IBAction)autoThresholdChanged:(UISwitch *)sender;            ///< Reacts to changes in the auto threshold switch.
- (IBAction)soundModeChanged:(UISegmentedControl *)sender;      ///< Reacts to the sound switch changing.

- (void)updateSlaveDisplay;                                     ///< Called to update the display for slave mode.
@end
