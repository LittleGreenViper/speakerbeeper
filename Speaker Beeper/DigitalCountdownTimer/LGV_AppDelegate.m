//
//  LGV_AppDelegate.m
//  DigitalCountdownTimer
//
//  Created by Chris Marshall on 7/10/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC All rights reserved.
//
/*********************************************************/
/**
 \file LGV_AppDelegate.m
 \brief The main application delegate for the timer.
 
        This file contains the application delegate, which is
        responsible for setting up the tab bar controller,
        initializing each of the timer view controllers (which
        are instantiated using a prototype in the storyboard),
        and for setting the textured background image in the window
        view.
 */

#import "LGV_AppDelegate.h"
#import "LGV_TimerSettingsViewController.h"
#import "LGV_PrefsViewController.h"
#import "A_LGV_TimerBaseViewController.h"
#import <AudioToolbox/AudioToolbox.h>

// These are accessible by all objects.
NSString    *s_LGV_CommanderAppID               = @"SpeakerBeeper";     ///< This will be used to identify our app in communications.
NSString    *s_LGV_CommanderAppVersion          = @"2.0";               ///< This will be used to identify our app version in communications.
NSString    *s_LGV_CommanderAdvertiserService   = @"spkr-bpr";          ///< The string used to advertise the commander service

static  NSString    *s_testFlightTeamToken                          = @"cd01c647-deca-4534-a28f-867b00e68aa5";   ///< The team key for the TestFlight App SDK.
static  NSString    *s_LGV_AppDelegate_main_prefs_key               = @"global_prefs";      ///< The key for the main prefs dictionary.
static  NSString    *s_LGV_AppDelegate_sound_on_prefs_key           = @"sound_on";          ///< The sound on prefs.
static  NSString    *s_LGV_AppDelegate_countdown_sound_prefs_key    = @"countdown_sounds";  ///< This sets whether or not the last ten seconds are counted down.
static  NSString    *s_LGV_AppDelegate_visual_feedback_prefs_key    = @"visual_feedback";   ///< This sets whether or not the visual feedback is displayed when setting the time.
static  NSString    *s_LGV_AppDelegate_commander_mode_prefs_key     = @"commander_mode";    ///< This sets whether or not the commander mode is on or off.
static  NSString    *s_LGV_AppDelegate_scroll_speed_prefs_key       = @"scroll_speed";      ///< This sets the scrolling responsiveness coefficient.

static  NSString    *s_LGV_AppDelegate_timer_1_prefs_key            = @"t1-pref";           ///< The prefs key for timer 1
static  NSString    *s_LGV_AppDelegate_timer_2_prefs_key            = @"t2-pref";           ///< The prefs key for timer 2
static  NSString    *s_LGV_AppDelegate_timer_3_prefs_key            = @"t3-pref";           ///< The prefs key for timer 3

static  LGV_AppDelegate *s_LGV_AppDelegate_AppDelegate_Singleton    = nil;  ///< This is the app delegate SINGLETON
extern  NSString    *s_ServiceType_Server;                                  ///< The service type for a commander node.

/**
 \typedef This is a set of tag values that can be assigned to Nodes, in order to classify them.
 */
typedef enum
{
    LGV_NodeStatusTagEnum_Unchecked = 0,    ///< This Node has yet to be checked.
    LGV_NodeStatusTagEnum_Commander,        ///< This Node is a commander.
    LGV_NodeStatusTagEnum_Slave             ///< This Node is a slave.
} LGV_NodeStatusTagEnum;

/*********************************************************/
/**
 \class LGV_AppDelegate (Private)
 \brief The main application delegate class
 */
@interface LGV_AppDelegate ()

@property (nonatomic, strong)   NSMutableDictionary     *_main_prefs;       ///< This will hold the main preferences.
@property (strong, readwrite)   NSArray                 *_colorChoices;     ///< Contains the colors to be used for the colors.

- (void)_loadMyPrefs;           ///< Load or initialize the main prefs.
- (void)_saveMyPrefs;           ///< Save out the current prefs.
- (void)_getColorChoices;       ///< This loads our initial color choices.
@end

/*********************************************************/
/**
 \class LGV_AppDelegate
 \brief The main application delegate class
 */
@implementation LGV_AppDelegate

@synthesize window = _window, application = _application;

#pragma mark - Class Methods -

/*********************************************************/
/**
 \brief We use a SINGLETON to allow access to the app delegate
 \returns the app delegate object SINGLETON.
 */
+ (LGV_AppDelegate *)appDelegate
{
#ifdef DEBUG
    if ( !s_LGV_AppDelegate_AppDelegate_Singleton )
        {
        NSLog(@"BAD BUG: No App Delegate SINGLETON!");
        }
#endif
    return s_LGV_AppDelegate_AppDelegate_Singleton;
}

#pragma mark - Private Methods -

/*********************************************************/
/**
 \brief Load or initialize the main prefs.
 */
- (void)_loadMyPrefs
{
    if ( [LGV_SimplePrefs getObjectAtKey:s_LGV_AppDelegate_main_prefs_key] )
        {
        [self set_main_prefs:[NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[LGV_SimplePrefs getObjectAtKey:s_LGV_AppDelegate_main_prefs_key]]];
        }
    
    if ( ![self _main_prefs] ) // If we don't have saved prefs, we create a new set.
        {
        [self set_main_prefs:[[NSMutableDictionary alloc] init]];
        [[self _main_prefs] setObject:[NSNumber numberWithBool:NO] forKey:s_LGV_AppDelegate_sound_on_prefs_key];         // Default for sound on is NO.
        [[self _main_prefs] setObject:[NSNumber numberWithBool:NO] forKey:s_LGV_AppDelegate_countdown_sound_prefs_key];  // Default for countdown sound on is NO.
        [[self _main_prefs] setObject:[NSNumber numberWithBool:NO] forKey:s_LGV_AppDelegate_visual_feedback_prefs_key];  // Default for visual feedback on is NO.
        [[self _main_prefs] setObject:[NSNumber numberWithBool:NO] forKey:s_LGV_AppDelegate_commander_mode_prefs_key];   // Default for commander mode on is NO.
        [[self _main_prefs] setObject:[NSNumber numberWithInt:3] forKey:s_LGV_AppDelegate_scroll_speed_prefs_key];       // Default for scroll speed is 3 (1.0).
        }
}

/*********************************************************/
/**
 \brief Save out the current prefs.
 */
- (void)_saveMyPrefs
{
    [LGV_SimplePrefs setObject:[self _main_prefs] atKey:s_LGV_AppDelegate_main_prefs_key];
}

/*********************************************************/
/**
 \brief Loads our internal array with our predefined color choices.
 */
- (void)_getColorChoices
{
    UITabBarController      *tabController = (UITabBarController *)[[self window] rootViewController];
    UINavigationController  *timer1Controller = [[tabController viewControllers] objectAtIndex:1];
    UINavigationController  *timer2Controller = [[tabController viewControllers] objectAtIndex:2];
    UINavigationController  *timer3Controller = [[tabController viewControllers] objectAtIndex:3];
    
    [self set_colorChoices:[NSArray arrayWithObjects:[[timer1Controller navigationBar] tintColor], [[timer2Controller navigationBar] tintColor], [[timer3Controller navigationBar] tintColor], nil]];
}

#pragma mark - AppDelegate Methods -

/*********************************************************/
/**
 \brief We save the SINGLETON at init time.
 \returns self
 */
- (id) init
{
    if ( self )
        {
        s_LGV_AppDelegate_AppDelegate_Singleton = self;
        }
    
    return self;
}

/*********************************************************/
/**
 \brief Application has finished its basic launch setup.
 \returns YES, if it's OK for the app to complete startup.
 */
-(BOOL)application:(UIApplication *)application             ///< The app object
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions ///< The launch options.
{
    _application = application; // We save the app for later.
    
    // This preps the TestFlight API.
    [TestFlight takeOff:s_testFlightTeamToken];
    
    // Load our app-level prefs (or initialize new ones).
    [self _loadMyPrefs];
    
    // What we do here, is use the storyboard controllers as "placeholders."
    // The only one that we use is the settings one. The timer ones are replaced by dynamically-generated ones.
    UITabBarController      *tabController = (UITabBarController *)[[self window] rootViewController];
    
    [tabController setDelegate:self];   // We will react to the tab bar switching.
    
    UIStoryboard            *myStoryboard = [tabController storyboard];
    UIViewController        *infoController = [[tabController viewControllers] objectAtIndex:0];
    UINavigationController  *timer1Controller = [[tabController viewControllers] objectAtIndex:1];
    UINavigationController  *timer2Controller = [[tabController viewControllers] objectAtIndex:2];
    UINavigationController  *timer3Controller = [[tabController viewControllers] objectAtIndex:3];
    UIViewController        *settingsController = [[tabController viewControllers] objectAtIndex:4];
    UIViewController        *teamController = nil;
    
    [self _getColorChoices];    // Set up the choices that we'll be offering for colors.
    
    // What we do here, is instantiate the template timer view for each of our built-in timers, and set the color for that timer in its prefs.
    // We then have that timer load its prefs to establish our color.
    UIViewController        *newTimer1ViewController = [myStoryboard instantiateViewControllerWithIdentifier:@"prototype-timer"];
    UINavigationController  *newNavController1 = [[UINavigationController alloc] initWithRootViewController:newTimer1ViewController];
    [[newNavController1 navigationBar] setTintColor:[UIColor blackColor]];
    [newNavController1 setTabBarItem:[timer1Controller tabBarItem]];
    [(LGV_TimerSettingsViewController *)newTimer1ViewController setMyPrefsKey:s_LGV_AppDelegate_timer_1_prefs_key];
    [[newNavController1 tabBarItem] setTitle:NSLocalizedString([[timer1Controller tabBarItem] title], nil)];
    [[newTimer1ViewController navigationItem] setTitle:NSLocalizedString([[timer1Controller tabBarItem] title], nil)];
    
    UIViewController        *newTimer2ViewController = [myStoryboard instantiateViewControllerWithIdentifier:@"prototype-timer"];
    UINavigationController  *newNavController2 = [[UINavigationController alloc] initWithRootViewController:newTimer2ViewController];
    [[newNavController2 navigationBar] setTintColor:[UIColor blackColor]];
    [newNavController2 setTabBarItem:[timer2Controller tabBarItem]];
    [(LGV_TimerSettingsViewController *)newTimer2ViewController setMyPrefsKey:s_LGV_AppDelegate_timer_2_prefs_key];
    
    [[newNavController2 tabBarItem] setTitle:NSLocalizedString([[timer2Controller tabBarItem] title], nil)];
    [[newTimer2ViewController navigationItem] setTitle:NSLocalizedString([[timer2Controller tabBarItem] title], nil)];
    
    UIViewController        *newTimer3ViewController = [myStoryboard instantiateViewControllerWithIdentifier:@"prototype-timer"];
    UINavigationController  *newNavController3 = [[UINavigationController alloc] initWithRootViewController:newTimer3ViewController];
    [[newNavController3 navigationBar] setTintColor:[UIColor blackColor]];
    [newNavController3 setTabBarItem:[timer3Controller tabBarItem]];
    [(LGV_TimerSettingsViewController *)newTimer3ViewController setMyPrefsKey:s_LGV_AppDelegate_timer_3_prefs_key];
    
    [[newNavController3 tabBarItem] setTitle:NSLocalizedString([[timer3Controller tabBarItem] title], nil)];
    [[newTimer3ViewController navigationItem] setTitle:NSLocalizedString([[timer3Controller tabBarItem] title], nil)];
    
    [[settingsController tabBarItem] setTitle:NSLocalizedString([[settingsController tabBarItem] title], nil)];
    [[infoController tabBarItem] setTitle:NSLocalizedString([[infoController tabBarItem] title], nil)];
    
    // We set up the order of our tabs.
    [tabController setViewControllers:[NSArray arrayWithObjects:infoController, newNavController1, newNavController2, newNavController3, settingsController, teamController, nil]];
    
    // We select the second one (Timer 1), as the first is our Info screen.
    [tabController setSelectedIndex:1];
    
    NSMutableDictionary     *timerSet = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[LGV_SimplePrefs getObjectAtKey:s_LGV_AppDelegate_timer_1_prefs_key]];
    [timerSet setObject:[NSNumber numberWithInt:s_default_timer_1_color_index] forKey:s_selected_color_key];
    [LGV_SimplePrefs setObject:timerSet atKey:s_LGV_AppDelegate_timer_1_prefs_key];
    
    timerSet = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[LGV_SimplePrefs getObjectAtKey:s_LGV_AppDelegate_timer_2_prefs_key]];
    [timerSet setObject:[NSNumber numberWithInt:s_default_timer_2_color_index] forKey:s_selected_color_key];
    [LGV_SimplePrefs setObject:timerSet atKey:s_LGV_AppDelegate_timer_2_prefs_key];
    
    timerSet = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[LGV_SimplePrefs getObjectAtKey:s_LGV_AppDelegate_timer_3_prefs_key]];
    [timerSet setObject:[NSNumber numberWithInt:s_default_timer_3_color_index] forKey:s_selected_color_key];
    [LGV_SimplePrefs setObject:timerSet atKey:s_LGV_AppDelegate_timer_3_prefs_key];
    
    [self tabBarController:tabController didSelectViewController:[tabController selectedViewController]];
    
    [self updateNetworkData:nil];
    return YES;
}

/*********************************************************/
/**
 \brief Called as the application is about to be "put away."
 */
- (void)applicationWillResignActive:(UIApplication *)application    ///< The application that is being affected.
{
    _networkManager = nil;
}

#pragma mark - Public Functions That Control the Persistent Settings -

/*********************************************************/
/**
 \brief This will turn on or off the sound prefs.
 */
- (void)setSoundOn:(BOOL)soundOn    ///< YES, if scrolling sounds are to be played.
{
    [self _loadMyPrefs];
    [[self _main_prefs] setObject:[NSNumber numberWithBool:soundOn] forKey:s_LGV_AppDelegate_sound_on_prefs_key];
    [self _saveMyPrefs];
}

/*********************************************************/
/**
 \brief This will turn on or off the countdown sound prefs.
 */
- (void)setCountdownSoundOn:(BOOL)soundOn   ///< YES, if the timer will play the countdown sounds.
{
    [self _loadMyPrefs];
    [[self _main_prefs] setObject:[NSNumber numberWithBool:soundOn] forKey:s_LGV_AppDelegate_countdown_sound_prefs_key];
    [self _saveMyPrefs];
}

/*********************************************************/
/**
 \brief This will turn on or off the visual feedback prefs.
 */
- (void)setVisualFeedbackOn:(BOOL)isOn  ///< YES, if the visual feedback will be displayed.
{
    [self _loadMyPrefs];
    [[self _main_prefs] setObject:[NSNumber numberWithBool:isOn] forKey:s_LGV_AppDelegate_visual_feedback_prefs_key];
    [self _saveMyPrefs];
}

/*********************************************************/
/**
 \brief This will turn on or off the commander mode prefs.
 */
- (void)setCommanderModeOn:(BOOL)isOn  ///< YES, if the commander mode is on.
{
    [self _loadMyPrefs];
    [[self _main_prefs] setObject:[NSNumber numberWithBool:isOn] forKey:s_LGV_AppDelegate_commander_mode_prefs_key];
    [self _saveMyPrefs];
    [self updateNetworkData:nil];
}

/*********************************************************/
/**
 \brief This sets the scroll speed coefficient.
 */
- (void)setScrollSpeed:(int)speed   ///< The speed coefficient to save.
{
    [self _loadMyPrefs];
    [[self _main_prefs] setObject:[NSNumber numberWithInt:speed] forKey:s_LGV_AppDelegate_scroll_speed_prefs_key];
    [self _saveMyPrefs];
}

/*********************************************************/
/**
 \brief Returns the state of the sound on prefs.
 \returns YES, if the adible feedback is to be played.
 */
- (BOOL)soundOn
{
    [self _loadMyPrefs];
    return ([(NSNumber *)[[self _main_prefs] objectForKey:s_LGV_AppDelegate_sound_on_prefs_key] integerValue] != 0);
}

/*********************************************************/
/**
 \brief Returns the state of the sound on prefs.
 \returns YES, if the last ten seconds are to be "beeped."
 */
- (BOOL)countdownSoundOn
{
    [self _loadMyPrefs];
    return ([(NSNumber *)[[self _main_prefs] objectForKey:s_LGV_AppDelegate_countdown_sound_prefs_key] integerValue] != 0);
}

/*********************************************************/
/**
 \brief Returns the state of the visual feedback on prefs.
 \returns YES, if the visual feedback is to be shown.
 */
- (BOOL)visualFeedbackOn
{
    [self _loadMyPrefs];
    return ([(NSNumber *)[[self _main_prefs] objectForKey:s_LGV_AppDelegate_visual_feedback_prefs_key] integerValue] != 0);
}

/*********************************************************/
/**
 \brief Returns the state of the commander mode on prefs.
 \returns YES, if the app is in commander mode.
 */
- (BOOL)isCommanderModeOn
{
    [self _loadMyPrefs];
    return ([(NSNumber *)[[self _main_prefs] objectForKey:s_LGV_AppDelegate_commander_mode_prefs_key] integerValue] != 0);
}

/*********************************************************/
/**
 \brief See if the front timer is in slave mode.
 \returns YES, if the front timer is in slave mode.
 */
- (BOOL)isSlaveModeOn
{
    BOOL    ret = NO;
    
    UIViewController    *selectedController = [(UITabBarController *)[[self window] rootViewController] selectedViewController];
    
    // We have to have one of the timers on top.
    if ( [selectedController isKindOfClass:[UINavigationController class]] && [[(UINavigationController*)selectedController topViewController] isKindOfClass:[A_LGV_TimerBaseViewController class]] )
        {
        A_LGV_TimerBaseViewController   *selectedTimer = (A_LGV_TimerBaseViewController*)[(UINavigationController*)selectedController topViewController];
        
        ret = [selectedTimer slaveMode];
        }
    
    return ret;
}
/*********************************************************/
/**
 \brief Returns the scroll speed index.
 \returns 1 - 6, with 3 being normative (1.0).
 */
- (int)scrollSpeed
{
    [self _loadMyPrefs];
    return [(NSNumber *)[[self _main_prefs] objectForKey:s_LGV_AppDelegate_scroll_speed_prefs_key] intValue];
}

/*********************************************************/
/**
 \brief Loads an array with our predefined color choices.
 \returns an array of UIColor objects.
 */
- (NSArray *)getColorChoices
{
    return [self _colorChoices];
}

/*********************************************************/
/**
 \brief This asks the application delegate to update its
        commander mode data to reflect the given view controller
 */
- (void)updateNetworkData:(A_LGV_TimerBaseViewController*)inController   ///< The view controller with the new state.
{
    if ( [self isCommanderModeOn] )   // We only send out data if we are a commander.
        {
        // We always start from scratch.
        _outputCommanderData = [NSMutableDictionary dictionary];
        
        // These identify the app and the app version. We send these every time.
        [[self outputCommanderData] setObject:s_LGV_CommanderAppID forKey:@"appID"];
        [[self outputCommanderData] setObject:s_LGV_CommanderAppVersion forKey:@"appVersion"];
        
        if ( ![self networkManager] )   // See if we need to set up a network manager
            {
            _networkManager = [[LGV_MCNetworkManagerServer alloc] initWithDelegate:self];
            }
        
        if ( [[[[self networkManager] session] connectedPeers] count] )
            {
            if ( inController ) // We only send the rest of the data if we have an active controller.
                {
                UITabBarController      *tabController = (UITabBarController *)[[self window] rootViewController];
                UINavigationController  *pController = [inController navigationController];
                NSArray                 *controllers = [tabController viewControllers];
                // We do this, so we can tell the exchange which controller we are using. Not valuable for now, but probably useful in the future.
                NSInteger               controllerIndex = (pController == [controllers objectAtIndex:1]) ? 1 : ((pController == [controllers objectAtIndex:2]) ? 2 : ((pController == [controllers objectAtIndex:3]) ? 3 : 0));

                // This says which controller is being sent out (usually of no interest to clients).
                [[self outputCommanderData] setObject:[NSNumber numberWithInteger:controllerIndex] forKey:@"controllerIndex"];

                // These are the state flags
                [[self outputCommanderData] setObject:[NSNumber numberWithBool:[inController timerOn]] forKey:@"clockRunning"];
                [[self outputCommanderData] setObject:[NSNumber numberWithBool:[inController quietMode]] forKey:@"quietMode"];
                [[self outputCommanderData] setObject:[NSNumber numberWithInt:[inController completionVolume]] forKey:@"completionVolume"];    // This is only looked at if quietMode is NO.

                // These are the actual times in the controller.
                [[self outputCommanderData] setObject:[inController warningTime] forKey:@"warningTime"];   // This is only looked at if quietMode is YES
                [[self outputCommanderData] setObject:[inController finalTime] forKey:@"finalTime"];       // This is only looked at if quietMode is YES
                [[self outputCommanderData] setObject:[inController setTime] forKey:@"setTime"];
                [[self outputCommanderData] setObject:[inController currentTime] forKey:@"currentTime"];
                }
            
            [[self networkManager] sendData:[NSKeyedArchiver archivedDataWithRootObject:[self outputCommanderData]]];
            }
        }
}

#pragma mark - UITabBarControllerDelegate Methods -

/*********************************************************/
/**
 \brief This is called after the tab bar switches in a new controller.
        This sets the color of the tab icon to match that assigned to the timer.
 */
- (void)tabBarController:(UITabBarController *)tabBarController ///< The controller for this tab bar
 didSelectViewController:(UIViewController *)viewController     ///< The selected view controller
{
    UINavigationController  *timer1Controller = [[tabBarController viewControllers] objectAtIndex:1];
    UINavigationController  *timer2Controller = [[tabBarController viewControllers] objectAtIndex:2];
    UINavigationController  *timer3Controller = [[tabBarController viewControllers] objectAtIndex:3];
    UINavigationController  *theController = nil;
    
    if ( (viewController == timer1Controller) || (viewController == timer2Controller) || (viewController == timer3Controller) )
        {
        theController = (UINavigationController*)viewController;
        if ( [[theController navigationBar] respondsToSelector:@selector ( setBarTintColor: )] )
            {
            [[theController navigationBar] setBarTintColor:[UIColor blackColor]];
            }
        else
            {
            [[UINavigationBar appearance] setBackgroundColor:[UIColor blackColor]];
            }
        }
    
    // We desaturate the selection color.
    if ( [[tabBarController tabBar] respondsToSelector:@selector ( setTranslucent:)] )
        {
        [[tabBarController tabBar] setTranslucent:NO];
        }
    else
        {
        [[tabBarController tabBar] setOpaque:YES];
        }
    
    if ( [[tabBarController tabBar] respondsToSelector:@selector ( setBarTintColor:)] )
        {
        [[tabBarController tabBar] setBarTintColor:[UIColor blackColor]];
        }
    else
        {
        [[tabBarController tabBar] setTintColor:[UIColor blackColor]];
        }
    
    UIColor *tint = [UIColor whiteColor];
    
    // Figure out which color we'll use.
    if ( viewController == timer1Controller )
        {
        tint = [[self getColorChoices] objectAtIndex:0];
        }
    else if ( viewController == timer2Controller )
        {
        tint = [[self getColorChoices] objectAtIndex:1];
        }
    else if ( viewController == timer3Controller )
        {
        tint = [[self getColorChoices] objectAtIndex:2];
        }

    if ( [[tabBarController tabBar] respondsToSelector:@selector ( setBarTintColor:)] )
        {
        [[tabBarController tabBar] setTintColor:tint];
        }
    else
        {
        [[tabBarController tabBar] setSelectedImageTintColor:tint];
        }
    
    // This sets the navigation back button to the color of the timer (iOS7 only).
    if ( theController )
        {
        if ( [[theController navigationBar] respondsToSelector:@selector ( setBarTintColor: )] )
            {
            [[theController navigationBar] setTintColor:tint];
            }
        }
    
    if ( [self isSlaveModeOn] && theController )
        {
        // We have to have one of the timers on top.
        if ( [theController isKindOfClass:[UINavigationController class]] && [[(UINavigationController*)theController topViewController] isKindOfClass:[A_LGV_TimerBaseViewController class]] )
            {
            [[(A_LGV_TimerBaseViewController*)[(UINavigationController*)theController topViewController] networkManager] findCommanders:YES];
            }
        }
}

#pragma mark - LGV_MCNetworkManagerDelegate Methods -

/*********************************************************/
/**
 \brief Returns the peer ID to be used by the network manager.
 */
- (MCPeerID*)getPeerID
{
    if ( ![self myPeerID] ) // Create one, if it does not yet exist.
        {
        _myPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
        }
    
    return [self myPeerID];
}

/*********************************************************/
/**
 \brief This is called to let the delegate know that they should re-scan the connection list.
 */
- (void)connectionListChanged:(A_LGV_MCNetworkManager*)inConnectionManager      ///< The connection manager that is managing our Node browser.
{
#ifdef DEBUG
    NSLog ( @"LGV_AppDelegate::LGV_MCNetworkManagerDelegate::connectionListChanged:%@", inConnectionManager );
#endif
}

/*********************************************************/
/**
 \brief This is called to let the delegate know that they
        have receieved a request for a connection from a Node.
 */
- (void)receivedConnectionRequest:(A_LGV_MCNetworkManager*)inConnectionManager  ///< The connection manager that is managing this.
                         fromNode:(MCPeerID*)inNode                           ///< The Node requesting the connection.
{
#ifdef DEBUG
    NSLog ( @"LGV_AppDelegate::LGV_MCNetworkManagerDelegate::receivedConnectionRequest:%@ fromNode:%@", inConnectionManager, inNode );
#endif
}

/*********************************************************/
/**
 \brief This is called to report a successful Node connection.
 */
- (void)connectionSuccessful:(A_LGV_MCNetworkManager*)inConnectionManager       ///< The connection manager that is managing this.
                      toNode:(MCPeerID*)inNode                                ///< The Node to whom we are now connected.
{
#ifdef DEBUG
    NSLog ( @"LGV_AppDelegate::LGV_MCNetworkManagerDelegate::connectionSuccessful:%@ toNode:%@", inConnectionManager, inNode );
#endif
}

/*********************************************************/
/**
 \brief Called when data is received from a Node.
 */
- (void)connectionManager:(A_LGV_MCNetworkManager*)inConnectionManager  ///< The connection manager that is managing this.
             receivedData:(NSData*)inData                               ///< The data that was received
{
#ifdef DEBUG
    NSLog ( @"LGV_AppDelegate::LGV_MCNetworkManagerDelegate::connectionManager:%@ receivedData:%@", inConnectionManager, inData );
#endif
    id readData = [NSKeyedUnarchiver unarchiveObjectWithData:inData];
    
    if ( [readData isKindOfClass:[NSDictionary class]] )
        {
        NSDictionary    *inResponseData = (NSDictionary*)readData;
        
        if ( ![self isCommanderModeOn] )   // We only accept data if we are NOT in commander mode.
            {
            UIViewController    *selectedController = [(UITabBarController *)[[self window] rootViewController] selectedViewController];
            
            // We have to have one of the timers on top.
            if ( [selectedController isKindOfClass:[UINavigationController class]] && [[(UINavigationController*)selectedController topViewController] isKindOfClass:[A_LGV_TimerBaseViewController class]] )
                {
                A_LGV_TimerBaseViewController   *selectedTimer = (A_LGV_TimerBaseViewController*)[(UINavigationController*)selectedController topViewController];
                
                if ( [selectedTimer slaveMode] )    // Only slaves can receive data.
                    {
#ifdef DEBUG
                    NSLog ( @"   Slave is receiving data from controller" );
#endif
                    
                    [selectedTimer applyCommanderSettings:inResponseData];  // Apply the data to the timer.
                    }
                }
            }
        }
}

/*********************************************************/
/**
 \brief Called if a node disconnects.
 */
- (void)connection:(A_LGV_MCNetworkManager*)inConnectionManager ///< The connection manager that is managing our Node browser.
  nodeDisconnected:(MCPeerID*)inNode                          ///< The node that disconnected.
{
    
}

/*********************************************************/
/**
 \brief Called if the connection experiences an error.
 */
- (void)connection:(A_LGV_MCNetworkManager*)inConnectionManager ///< The connection manager that is managing our Node browser.
  experiencedError:(NSError*)inError                            ///< The error experienced by the connection.
{
    
}

/*********************************************************/
/**
 \brief Called to tell the delegate to call us back, and present the commander browser.
 */
- (void)presentCommanderBrowser:(LGV_MCNetworkManagerClient*)inConnectionManager    ///< The connection manager that is managing our Node browser.
{
    UIViewController    *selectedTab = [(UITabBarController *)[[self window] rootViewController] selectedViewController];
    
    // Only if the selected tab has the requisite method...
    if ( [selectedTab isKindOfClass:[UINavigationController class]] && [[(UINavigationController*)selectedTab topViewController] isKindOfClass:[A_LGV_PrototypeWindow class]] )
        {
        A_LGV_PrototypeWindow   *pWindow = (A_LGV_PrototypeWindow*)[(UINavigationController*)selectedTab topViewController];
        [pWindow presentCommanderBrowser:inConnectionManager];
        }
}

/*********************************************************/
/**
 \brief Called to tell the delegate to dismiss the commander browser.
 */
- (void)dismissCommanderBrowser:(A_LGV_MCNetworkManager*)inConnectionManager    ///< The connection manager that is managing our Node browser.
{
    UIViewController    *selectedTab = [(UITabBarController *)[[self window] rootViewController] selectedViewController];
    
    // Only if the selected tab has the requisite method...
    if ( [selectedTab isKindOfClass:[UINavigationController class]] && [[(UINavigationController*)selectedTab topViewController] isKindOfClass:[A_LGV_PrototypeWindow class]] )
        {
        A_LGV_PrototypeWindow   *pWindow = (A_LGV_PrototypeWindow*)[(UINavigationController*)selectedTab topViewController];
        [pWindow dismissCommanderBrowser];
        }
}
@end
