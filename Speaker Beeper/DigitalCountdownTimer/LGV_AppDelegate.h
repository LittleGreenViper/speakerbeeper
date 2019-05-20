//
//  LGV_AppDelegate.h
//  DigitalCountdownTimer
//
//  Created by Chris Marshall on 7/10/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC All rights reserved.
//

#import "LGV_AppDelegate_Prefs.h"
#import "A_LGV_MCNetworkManager.h"

@class A_LGV_TimerBaseViewController;   ///< Forward declaration for function prototype.

extern  NSString    *s_LGV_CommanderAppID;      ///< This will be used to identify our app in communications.
extern  NSString    *s_LGV_CommanderAppVersion; ///< This will be used to identify our app version in communications.
extern  NSString    *s_LGV_CommanderAdvertiserService; ///< The string used to advertise the commander service

/*********************************************************/
/**
 \class LGV_AppDelegate
 \brief The main application delegate class
 */
@interface LGV_AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, UITabBarControllerDelegate, A_LGV_MCNetworkManagerDelegate>
@property (strong, nonatomic)           UIWindow                    *window;                ///< The app window.
@property (weak, nonatomic, readonly)   UIApplication               *application;           ///< My application object
@property (strong, atomic, readonly)    NSMutableDictionary         *outputCommanderData;   ///< This will contain the data that we will be sending if we are a commander. It is nil, if we are a slave.
@property (strong, atomic, readonly)    LGV_MCNetworkManagerServer  *networkManager;        ///< If the timer is in commander mode, this will contain the active network manager (the timers will have nil network managers).
@property (strong, atomic, readonly)    NSMutableArray              *availableCommanders;   ///< This will contain LGV_MCNode objects; each one representing an available commander.
@property (strong, atomic, readonly)    MCPeerID                    *myPeerID;              ///< The app's peer ID.

+ (LGV_AppDelegate *)appDelegate;           ///< Returns the SINGLETON instance of the app delegate.

- (void)setSoundOn:(BOOL)soundOn;           ///< This will turn on or off the sound prefs.
- (void)setCountdownSoundOn:(BOOL)soundOn;  ///< This will turn on or off the countdown sound prefs.
- (void)setVisualFeedbackOn:(BOOL)isOn;     ///< Set the visual feedback prefs.
- (void)setCommanderModeOn:(BOOL)isOn;      ///< Set the commander mode prefs.
- (void)setScrollSpeed:(int)speed;          ///< Sets the responsiveness of the scrollers.
- (BOOL)soundOn;                            ///< Returns YES if the sound on pref is enabled.
- (BOOL)countdownSoundOn;                   ///< Returns YES if the countdown sound on pref is enabled.
- (BOOL)visualFeedbackOn;                   ///< Returns YES, if the visual feedback pref is on.
- (BOOL)isCommanderModeOn;                    ///< Returns YES, if the app is in commander mode.
- (BOOL)isSlaveModeOn;                        ///< Returns YES, if the front timer is in slave mode.
- (int)scrollSpeed;                         ///< Returns the scroll speed.
- (NSArray *)getColorChoices;               ///< Returns an array of our various color choices.
- (void)updateNetworkData:(A_LGV_TimerBaseViewController*)inController;   ///< This asks the application delegate to update its network data to reflect the given view controller.
@end
