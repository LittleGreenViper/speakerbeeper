//
//  A_LGV_TimerBaseViewController.h
//  DigitalCountdownTimer
//
//  Created by Chris Marshall on 8/5/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import "A_LGV_PrototypeWindow.h"

@class LGV_LEDDigitalTimeDisplay;
@class A_LGV_MCNetworkManager;

/// These are keys, used to access the persistent prefs. They index into the dictionary that is saved into the prefs, and the values will be different for each timer.
extern NSString    *s_time_current_key;             ///< The current timer time.
extern NSString    *s_element_color_off_key;        ///< The "off" color for the LED elements.
extern NSString    *s_time_set_key;                 ///< The timer set time.
extern NSString    *s_time_warn_key;                ///< The "warning time" threshold.
extern NSString    *s_time_final_key;               ///< The "final stretch time" threshold.
extern NSString    *s_time_completion_sound_key;    ///< The digital countown completion sound key.
extern NSString    *s_original_commander_key;       ///< The original commander peer ID key.

/// These define the aspect ratio "window" for the timer display. They keep the digits from getting too distorted when they resize. The ratio is width / height.
static const float       s_min_aspect_ratio_for_digits  = 3.5;                      ///< The minimum aspect ratio (tall and thin).
static const float       s_max_aspect_ratio_for_digits  = 7;                        ///< The maximum aspect ratio (short and fat).

/*********************************************************/
/**
 \class A_LGV_TimerBaseViewController
 \brief This is a base class for view controllers that display
        a digital timer display (the settings and the operational
        view controllers).
        It consolidates a lot of the issues with manaing the
        display in one abstract base class.
 */
@interface A_LGV_TimerBaseViewController : A_LGV_PrototypeWindow

#pragma mark - Properties

@property (weak, nonatomic)     IBOutlet    LGV_LEDDigitalTimeDisplay   *timeDisplay;       ///< The main time display.
@property (nonatomic, readwrite)            BOOL                        timerOn;            ///< This is YES, if the timer is currently counting down.
@property (retain, nonatomic)               NSMutableDictionary         *timerSet;          ///< This will contain the settings for this timer.
@property (nonatomic, readwrite)            NSDate                      *startTime;         ///< This will contain the countdown start time.
@property (nonatomic, readwrite)            NSDate                      *setTime;           ///< This will contain the countdown set time.
@property (nonatomic, readwrite)            NSDate                      *warningTime;       ///< This will contain the countdown warning time.
@property (nonatomic, readwrite)            NSDate                      *finalTime;         ///< This will contain the countdown final stretch time.
@property (nonatomic, readwrite)            NSDate                      *currentTime;       ///< This will contain the countdown current time.
@property (retain, nonatomic)               UIColor                     *elementColorOff;   ///< The same, but for "off."
@property (nonatomic, readwrite)            BOOL                        quietMode;          ///< If YES, the numbers are hidden (only the three lights are shown). Default is NO.
@property (nonatomic, readwrite)            BOOL                        slaveMode;          ///< If YES, the timer will take its queue from a master timer.
@property (nonatomic, readwrite)            BOOL                        autoThresholds;     ///< If YES, the thresholds (warning and final) will be determined automatically.
@property (nonatomic, readwrite)            int                         completionVolume;   ///< The selected volume for digital timer completion. 0 is off. Default is 0.
@property (nonatomic, readwrite)            NSInteger                   selectedColor;      ///< The index of the selected color.
@property (nonatomic, readwrite)            NSString                    *myPrefsKey;        ///< This is the prefs ID for this instance.
@property (atomic, strong, readonly)        LGV_MCNetworkManagerClient  *networkManager;    ///< If this timer is in slave mode, this will contain its network manager (the App Delegate networkManager will be nil). Nil, otherwise.
@property (nonatomic, readwrite)            MCPeerID                    *commanderPeerID;   ///< This will contain the peer ID of the selected commander.

#pragma mark - Class Method Declarations -

+ (NSDate *)createDateFromHours:(int)hours andMinutes:(int)minutes andSeconds:(int)seconds; ///< Simple converter to give an NSDate from components.
+ (NSDateComponents *)createComponentsFromDate:(NSDate *)inDate;                            ///< Simple converter that goes the other way.

#pragma mark - Instance Method Declarations -

- (void)saveMySettings;                         ///< Saves the current settings in persistent storage.
- (void)loadMySettings;                         ///< Fetches the current settings from persistent storage.
- (void)setTimerDisplayToSetTime;               ///< Set the timer display to the set time.
- (void)setTimerDisplayToCurrentTime;           ///< Set the timer display to the current time.
- (NSInteger)currentSetTimeInSeconds;           ///< Returns the number of seconds in the currently set time.
- (NSInteger)currentDisplayedTimeInSeconds;     ///< Returns the number of seconds in the currently displayed time.
- (BOOL)timerIsZero;                            ///< Returns YES, if the timer is at 00:00:00.
- (BOOL)setTimeIsZero;                          ///< Returns YES, if the timer set time is zero.
- (void)applyCommanderSettings:(NSDictionary*)inSettings;   ///< This is how commanders update slaves. The slave is updated via this function.
- (void)setTimerDisplayToAspectWindow;          ///< This sets the digital display to fit the aspect window.
- (void)takeDownNetworkManager;                 ///< Tells the timer to close down its network manager.
- (void)setUpNetworkManager:(BOOL)inSlaveMode;  ///< Sets up a client network manager (if necessary).
@end
