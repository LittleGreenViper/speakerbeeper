//
//  LGV_TimerSettingsViewController.h
//  DigitalCountdownTimer
//
//  Created by Chris Marshall on 7/10/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGV_LEDDigitalTimeDisplay.h"
#import "LGV_PrizeWheelScroller.h"
#import "A_LGV_TimerBaseViewController.h"
#import "LGV_SimpleRoundedRectButton.h"
#import "LGV_RoundedBackgroundPanel.h"

/// This class does most of the timer view control.
@interface LGV_TimerSettingsViewController : A_LGV_TimerBaseViewController <LGV_PrizeWheelScrollerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic)     IBOutlet    LGV_SimpleRoundedRectButton *startButton;               ///< This is the start button object.
@property (weak, nonatomic)     IBOutlet    LGV_LEDDigitalTimeDisplay   *timeDisplay;               ///< This is the actual timer display.
@property (weak, nonatomic)     IBOutlet    LGV_SimpleRoundedRectButton *resetStandaloneButton;     ///< This is a button that is displayed if there is no navbar
@property (weak, nonatomic)     IBOutlet    LGV_SimpleRoundedRectButton *clearStandaloneButton;     ///< Same here.
@property (weak, nonatomic)     IBOutlet    LGV_SimpleRoundedRectButton *prefsStandaloneButton;     ///< Same here.
@property (weak, nonatomic)     IBOutlet    UIView                      *standaloneButtons;         ///< The view that holds the standalone buttons.
@property (weak, nonatomic)     IBOutlet    LGV_SimpleRoundedRectButton *warningThresholdButton;    ///< This button sets the warning (yellow) threshold.
@property (weak, nonatomic)     IBOutlet    LGV_SimpleRoundedRectButton *finalThresholdButton;      ///< This button sets the final (red) threshold.
@property (weak, nonatomic)     IBOutlet    UIView                      *mainItemsView;             ///< This contains the main display items.
@property (weak, nonatomic)     IBOutlet    UIView                      *thresholdButtons;          ///< This contains the two threshold items.
@property (weak, nonatomic)     IBOutlet    UIView                      *startBarView;              ///< This is the container for the Start and Reset buttons.
@property (weak, nonatomic)     IBOutlet    LGV_RoundedBackgroundPanel  *backgroundPanel;           ///< This is the background panel for the main screen.

#pragma mark - Instance Method Declarations -
- (IBAction)prefsButtonHit:(id)sender;      ///< Bring up the prefs dialog.
- (IBAction)startTimer:(id)sender;          ///< Start the timer going.
- (IBAction)clearButtonHit:(id)sender;      ///< Clear the timer to 00:00:00
- (IBAction)resetButtonHit:(id)sender;      ///< Reset the timer to the set time.
- (IBAction)yellowButtonHit:(id)sender;     ///< Set the warning threshold.
- (IBAction)redButtonHit:(id)sender;        ///< Set the final threshold.
@end
