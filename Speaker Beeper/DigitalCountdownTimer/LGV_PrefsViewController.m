//
//  LGV_PrefsViewController.m
//  DigitalCountdownTimer
//
//  Created by Chris Marshall on 7/28/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import "LGV_PrefsViewController.h"
#import "A_LGV_MCNetworkManager.h"

static const    CGFloat s_PopoverInset      = 4.0;  ///< How many pixels to inset the popover.

/*********************************************************/
/**
 \brief We extend this class, so we can store our activity indicator.
 */
@implementation LGV_TableViewCell
@synthesize activityIndicator = _activityIndicator;
@end

/*********************************************************/
/**
 \class LGV_PrefsViewController (Private Interface)
 \brief This controls the individual settings tab view.
        It works by directly manipulating the prefs.
 */
@interface LGV_PrefsViewController ()
- (void)_loadPrefs;                  ///< Loads the prefs, and sets up the screen.
- (void)_setVibrateOnlyLabelText;    ///< Set the proper text for the "Vibrate Only" label.
@end

/*********************************************************/
/**
 \class LGV_PrefsViewController
 \brief This controls the individual settings tab view.
        It works by directly manipulating the prefs.
 */
@implementation LGV_PrefsViewController

#pragma mark - Superclass Overrides -

/*********************************************************/
/**
 \brief Set up the window.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ( ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) )
        {
        CGRect  myBounds = [[self mainContainerView] frame];
        [self setPreferredContentSize:myBounds.size];    // Make sure our popover isn't too big.
        myBounds = CGRectInset ( myBounds, s_PopoverInset, s_PopoverInset );
        [[self mainContainerView] setFrame:myBounds];
        [[self soundSelectionSegmentedControl] removeSegmentAtIndex:1 animated:NO];
        }
    
    // Set the titles for the two segments.
    [[self modeSelectionSwitch] setTitle:NSLocalizedString([[self modeSelectionSwitch] titleForSegmentAtIndex:0], nil) forSegmentAtIndex:0];
    [[self modeSelectionSwitch] setTitle:NSLocalizedString([[self modeSelectionSwitch] titleForSegmentAtIndex:1], nil) forSegmentAtIndex:1];
    if ( [[self modeSelectionSwitch] numberOfSegments] > 2 )
        {
        [[self modeSelectionSwitch] setTitle:NSLocalizedString([[self modeSelectionSwitch] titleForSegmentAtIndex:2], nil) forSegmentAtIndex:2];
        }
    
    // Set the localized strings for the labels.
    [[self autoThresholdLabel] setText:NSLocalizedString([[self autoThresholdLabel] text], nil)];
    [[self soundLabel] setText:NSLocalizedString([[self soundLabel] text], nil)];
    
    // Make sure the callbacks are initialized to nil.
    [[self autoThresholdSwitch] removeTarget:self action:@selector(autoThresholdChanged:) forControlEvents:UIControlEventValueChanged];
    [[self modeSelectionSwitch] removeTarget:self action:@selector(modeSelectionChanged:) forControlEvents:UIControlEventValueChanged];
    
    [[self navigationItem] setTitle:NSLocalizedString([[self navigationItem] title], nil)];
    
    if ( [[LGV_AppDelegate appDelegate] isCommanderModeOn] )
        {
        [[self modeSelectionSwitch] removeSegmentAtIndex:2 animated:NO];
        }
    
    // In iOS 7, we set the controls to the same color as the LEDs for the timer associated with the prefs screen.
    UIColor *tint = nil;
    
    if ( [[[[self myController] navigationController] navigationBar] respondsToSelector:@selector ( setBarTintColor: )] )
        {
        tint = [[[[self myController] navigationController] navigationBar] tintColor];
        }
    
    if ( tint )
        {
        [[self modeSelectionSwitch] setTintColor:tint];
        [[self autoThresholdSwitch] setTintColor:tint];
        [[self autoThresholdSwitch] setThumbTintColor:tint];
        [[self soundSelectionSegmentedControl] setTintColor:tint];
        }
}

/*********************************************************/
/**
 \brief Before we appear, we'll make sure that the prefs are loaded.
 */
- (void)viewWillAppear:(BOOL)animated   ///< YES, if the appearance is animated (ignored).
{
    [self _loadPrefs];
    
    if ( [self isInPopover] )
        {
        CGRect  myBounds = [[self mainContainerView] frame];
        myBounds.origin.y = s_PopoverInset;
        [[self mainContainerView] setFrame:myBounds];
        }
}

/*********************************************************/
/**
 \brief Making the navbar visible here, keeps it from
        appearing while the original view is still up.
 */
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[[self navigationController] navigationBar] setHidden:NO];
}

#pragma mark - Private Instance Methods -

/*********************************************************/
/**
 \brief Load the prefs.
 */
- (void)_loadPrefs
{
    // We only need to know about the controller enough to get its prefs ID. After that, we use the prefs for everything.
    NSString                *prefsKey = [[self myController] myPrefsKey];
    
    // We will get the settings from the static prefs file.
    NSMutableDictionary     *timerSet = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[LGV_SimplePrefs getObjectAtKey:prefsKey]];
    BOOL                    quietMode = NO;
    BOOL                    slaveMode = NO;
    BOOL                    autoThreshold = NO;
    int                     completionVolume = 0;
    
    // We do it this way, because we want the maximum possible decoupling from the controller.
    // It would be easier just to ask the controller, but I'd rather use the static prefs as our semaphore.
    // Just good coding practice.
    if ( [timerSet objectForKey:s_quiet_mode_key] )
        {
        quietMode = [(NSNumber *)[timerSet objectForKey:s_quiet_mode_key] boolValue];
        }
    
    if ( [timerSet objectForKey:s_slave_mode_key] )
        {
        slaveMode = ([(NSNumber *)[timerSet objectForKey:s_slave_mode_key] boolValue] != 0) && ![[LGV_AppDelegate appDelegate] isCommanderModeOn];
        }
    
    if ( [timerSet objectForKey:s_auto_threshold_key] )
        {
        autoThreshold = [(NSNumber *)[timerSet objectForKey:s_auto_threshold_key] boolValue];
        }
    
    if ( [timerSet objectForKey:s_time_completion_sound_key] )
        {
        completionVolume = [(NSNumber *)[timerSet objectForKey:s_time_completion_sound_key] intValue];
        
        completionVolume = MAX ( 0, MIN ( 2, completionVolume ));
        
        if ( ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) )
            {
            completionVolume = (0 == completionVolume) ? 0 : 1;
            }
        }
    
    [[self soundSelectionSegmentedControl] setSelectedSegmentIndex:completionVolume];
    [[self modeSelectionSwitch] setSelectedSegmentIndex:(slaveMode ? 2 : (quietMode ? 1 : 0))];
    [self modeSelectionChanged:[self modeSelectionSwitch]];

    // Set our values, then set our callbacks. This prevents unwanted callbacks.
    [[self autoThresholdSwitch] setOn:autoThreshold];
    [[self autoThresholdSwitch] addTarget:self action:@selector(autoThresholdChanged:) forControlEvents:UIControlEventValueChanged];
    [[self modeSelectionSwitch] addTarget:self action:@selector(modeSelectionChanged:) forControlEvents:UIControlEventValueChanged];
    [self _setVibrateOnlyLabelText];
}

/*********************************************************/
/**
 \brief Sets the proper text for the "Vibrate Only" label.
 */
- (void)_setVibrateOnlyLabelText
{
//    NSMutableDictionary             *timerSet = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[LGV_SimplePrefs getObjectAtKey:[[self myController] myPrefsKey]]];
}

#pragma mark - Superclass Overload Methods -

/*********************************************************/
/**
 \brief Removes any commander browser.
 */
- (void)dismissCommanderBrowser
{
    NSMutableDictionary *timerSet = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[LGV_SimplePrefs getObjectAtKey:[[self myController] myPrefsKey]]];
    BOOL                quietMode = [(NSNumber *)[timerSet objectForKey:s_quiet_mode_key] boolValue];

    if ( [[[self myController] networkManager] isKindOfClass:[LGV_MCNetworkManagerClient class]] )
        {
        LGV_MCNetworkManagerClient  *networkManager = (LGV_MCNetworkManagerClient*)[[self myController] networkManager];
        
        if ( ![networkManager selectedCommander] )  // If no commander was selected, we return to the last mode.
            {
            [[self myController] takeDownNetworkManager];
            [[self modeSelectionSwitch] setSelectedSegmentIndex:quietMode ? 1 : 0];
            [timerSet removeObjectForKey:s_selected_commander_key];
            [self modeSelectionChanged:[self modeSelectionSwitch]];
            }
        else
            {
            [timerSet setObject:[networkManager selectedCommander] forKey:s_selected_commander_key];
            }
        }
    else
        {
        [[self modeSelectionSwitch] setSelectedSegmentIndex:quietMode ? 1 : 0];
        [self modeSelectionChanged:[self modeSelectionSwitch]];
        }
    
    // We may deselect slave mode.
    [timerSet setObject:[NSNumber numberWithBool:[[self modeSelectionSwitch] selectedSegmentIndex] == 2] forKey:s_slave_mode_key];
    [self updateSlaveDisplay];
}

#pragma mark - Control Callbacks -

/*********************************************************/
/**
 \brief Called when the mode selection switch is changed.
 */
- (IBAction)modeSelectionChanged:(UISegmentedControl *)inSender
{
    NSMutableDictionary *timerSet = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[LGV_SimplePrefs getObjectAtKey:[[self myController] myPrefsKey]]];
    
    if ( [inSender selectedSegmentIndex] == 0 )
        {
        [timerSet setObject:[NSNumber numberWithBool:NO] forKey:s_quiet_mode_key];
        }
    else if ( [inSender selectedSegmentIndex] == 1 )
        {
        [timerSet setObject:[NSNumber numberWithBool:YES] forKey:s_quiet_mode_key];
        }
         
    [timerSet setObject:[NSNumber numberWithBool:[inSender selectedSegmentIndex] == 2] forKey:s_slave_mode_key];
    
    [LGV_SimplePrefs setObject:timerSet atKey:[[self myController] myPrefsKey]];
   
    if ( [inSender selectedSegmentIndex] == 2 )
        {
        [[self myController] setUpNetworkManager:YES];
        [[[self myController] networkManager] findCommanders:NO];
        [[self peerReportContainer] setHidden:NO];
        [[self soundSelectionGroup] setHidden:YES];
        [[self autoThresholdGroup] setHidden:YES];
        }
    else
        {
        [[self peerReportContainer] setHidden:YES];
        [[self soundSelectionGroup] setHidden:[inSender selectedSegmentIndex] != 0];
        [[self autoThresholdGroup] setHidden:[inSender selectedSegmentIndex] != 1];
        }
}

/*********************************************************/
/**
 \brief Called when the auto threshold switch is thrown.
 */
- (IBAction)autoThresholdChanged:(UISwitch *)sender
{
    NSMutableDictionary *timerSet = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[LGV_SimplePrefs getObjectAtKey:[[self myController] myPrefsKey]]];
    [timerSet setObject:[NSNumber numberWithBool:[sender isOn]] forKey:s_auto_threshold_key];
    [LGV_SimplePrefs setObject:timerSet atKey:[[self myController] myPrefsKey]];
    [[[self myController] view] setNeedsLayout];
}

/*********************************************************/
/**
 \brief Called when the sound slider is changed.
 */
- (IBAction)soundModeChanged:(UISegmentedControl *)sender
{
    NSInteger   selection = [sender selectedSegmentIndex];
    
    if ( ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) )
        {
        selection = (0 == selection) ? 0 : 2;
        }
    
    NSMutableDictionary *timerSet = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[LGV_SimplePrefs getObjectAtKey:[[self myController] myPrefsKey]]];
    [timerSet setObject:[NSNumber numberWithInteger:selection] forKey:s_time_completion_sound_key];
    [LGV_SimplePrefs setObject:timerSet atKey:[[self myController] myPrefsKey]];
}

/*********************************************************/
/**
 \brief Called to force the slave mode display to update.
 */
- (void)updateSlaveDisplay
{
    // If we are a commander, we cannot be in slave mode.
    if ( [[LGV_AppDelegate appDelegate] isCommanderModeOn] )
        {
#ifdef DEBUG
        NSLog(@"LGV_PrefsViewController:updateSlaveDisplay We are in commander mode, so we can't go into Slave Mode." );
#endif
        }
    else
        {
        NSString    *labelString = @"ERROR-COMMANDER";
        if ( [[[self myController] browserManager] isKindOfClass:[LGV_MCNetworkManagerClient class]] )
            {
            LGV_MCNetworkManagerClient  *browser = (LGV_MCNetworkManagerClient*)[[self myController] browserManager];

            if ( [browser selectedCommander] )
                {
                labelString = [NSString stringWithFormat:NSLocalizedString ( @"CONNECTED-COMMANDERS-FORMAT", nil ), [(LGV_MCNetworkManagerClient*)[[self myController] browserManager] selectedCommander]];
                }
            }
        [[self peerReportLabel] setText:labelString];
        }
}
@end
