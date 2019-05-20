//
//  A_LGV_TimerBaseViewController.m
//  DigitalCountdownTimer
//
//  Created by Chris Marshall on 8/5/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//
/*********************************************************/
/**
 \file A_LGV_TimerBaseViewController.m
 \brief This file implements an abstract base for timer display.
 
        The timer has four different times:
            1) The current time (what the timer says now).
            2) The set time (what the timer starts from).
            3) The warning threshold (Only used for Podium Mode)
            4) The final threshold (Only used for Podium Mode).
 
        The communications between views is done via the static
        settings. The settings are updated from one view, and
        then read back into the other view. This maximizes
        decoupling, and is just generally good programming
        practice.
        It also has the advantage of allowing the timer to have
        a constant state.
 */
#import "A_LGV_TimerBaseViewController.h"
#import "LGV_LEDDigitalTimeDisplay.h"

NSString    *s_time_current_key            = @"time_current";          ///< The current timer time.
NSString    *s_element_color_off_key       = @"element_color_off";     ///< The "off" color for the LED elements.
NSString    *s_time_set_key                = @"time_set";              ///< The timer set time.
NSString    *s_time_warn_key               = @"time_warn";             ///< The "warning time" threshold.
NSString    *s_time_final_key              = @"time_final";            ///< The "final stretch time" threshold.
NSString    *s_time_completion_sound_key   = @"completion_sound";      ///< The digital countown completion sound key.
NSString    *s_original_commander_key      = @"original_commander";    ///< The original commander peer ID key.

/*********************************************************/
/**
 \class A_LGV_TimerBaseViewController (Private Interface)
 \brief This is a base class for view controllers that display
        a digital timer display (the settings and the operational
        view controllers).
        It consolidates a lot of the issues with manaing the
        display in one abstract base class.
 */
@interface A_LGV_TimerBaseViewController ()
- (void)_initializeTimeDisplayColors;        ///< Initializes the colors of the time display.
@end

/*********************************************************/
/**
 \class A_LGV_TimerBaseViewController
 \brief This is a base class for view controllers that display
        a digital timer display (the settings and the operational
        view controllers).
        It consolidates a lot of the issues with manaing the
        display in one abstract base class.
 */
@implementation A_LGV_TimerBaseViewController

#pragma mark - Public Class Methods -
/*********************************************************/
/**
 \brief Creates a new NSDate from components
 \returns a new NSDate object, set to the absolute time given.
 */
+ (NSDate *)createDateFromHours:(int)hours      ///< The number of hours
                     andMinutes:(int)minutes    ///< The number of minutes
                     andSeconds:(int)seconds    ///< The number of seconds
{
    NSCalendar       *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    [comps setHour:hours];
    [comps setMinute:minutes];
    [comps setSecond:seconds];
    NSDate *date = [gregorian dateFromComponents:comps];
    
    return date;
}

/*********************************************************/
/**
 \brief Creates a set of components from a given date.
 \returns a new NSDateComponents object. Only Hours, Minutes and Seconds are set.
 */
+ (NSDateComponents *)createComponentsFromDate:(NSDate *)inDate   ///< The date to componentize.
{
    NSCalendar       *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:inDate];
}

#pragma mark - Public Superclass Override Instance Methods -
/*********************************************************/
/**
 \brief This sets the digital display to the proper aspect, and loads the settings.
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadMySettings];
}

/*********************************************************/
/**
 \brief This is called just after the view appears. We just make sure the network is adjusted.
 */
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[LGV_AppDelegate appDelegate] updateNetworkData:self];
}

/*********************************************************/
/**
 \brief This tells the app delegate to stop advertising/disconnect a slave.
 */
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

/*********************************************************/
/**
 \brief This sets the digital display to the proper aspect, and loads the settings.
 */
- (void)viewDidLayoutSubviews
{
    [self setTimerDisplayToAspectWindow];
}

#pragma mark - Public Instance Methods -
/*********************************************************/
/**
 \brief Save the settings dictionary to persistent storage.
 */
- (void)saveMySettings
{
    [[self timerSet] setObject:[NSNumber numberWithInteger:[self selectedColor]] forKey:s_selected_color_key];
    
    if ( nil != [self setTime] )
        {
        [[self timerSet] setObject:[self setTime] forKey:s_time_set_key];
        }
    else
        {
        if ( [[self timerSet] objectForKey:s_time_set_key] )
            {
            [[self timerSet] removeObjectForKey:s_time_set_key];
            }
        }
    
    if ( nil != [self currentTime] )
        {
        [[self timerSet] setObject:[self currentTime] forKey:s_time_current_key];
        }
    else
        {
        if ( [[self timerSet] objectForKey:s_time_current_key] )
            {
            [[self timerSet] removeObjectForKey:s_time_current_key];
            }
        }
    
    if ( nil != [self elementColorOff] )
        {
        [[self timerSet] setObject:[self elementColorOff] forKey:s_element_color_off_key];
        }
    else
        {
        if ( [[self timerSet] objectForKey:s_element_color_off_key] )
            {
            [[self timerSet] removeObjectForKey:s_element_color_off_key];
            }
        }
    
    if ( nil != [self warningTime] )
        {
        [[self timerSet] setObject:[self warningTime] forKey:s_time_warn_key];
        }
    else
        {
        if ( [[self timerSet] objectForKey:s_time_warn_key] )
            {
            [[self timerSet] removeObjectForKey:s_time_warn_key];
            }
        }
    
    if ( nil != [self finalTime] )
        {
        [[self timerSet] setObject:[self finalTime] forKey:s_time_final_key];
        }
    else
        {
        if ( [[self timerSet] objectForKey:s_time_final_key] )
            {
            [[self timerSet] removeObjectForKey:s_time_final_key];
            }
        }

    if ( [self commanderPeerID] )
        {
        [[self timerSet] setObject:[self commanderPeerID] forKey:s_original_commander_key];
        }
    else
        {
        if ( [[self timerSet] objectForKey:s_original_commander_key] )
            {
            [[self timerSet] removeObjectForKey:s_original_commander_key];
            }
        }
    
    [[self timerSet] setObject:[NSNumber numberWithBool:[self autoThresholds]] forKey:s_auto_threshold_key];
    [[self timerSet] setObject:[NSNumber numberWithInt:MAX ( 0, MIN ( 2, [self completionVolume]) )] forKey:s_time_completion_sound_key];
    
    // This saves the prefs to the persistent storage file.
    [LGV_SimplePrefs setObject:[self timerSet] atKey:[self myPrefsKey]];
}

/*********************************************************/
/**
 \brief Load the settings dictionary from persistent storage.
        This will create a new, empty dictionary, if none is loaded.
 */
- (void)loadMySettings
{
    [self setTimerSet:[NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)[LGV_SimplePrefs getObjectAtKey:[self myPrefsKey]]]];
    [self setQuietMode:NO];
    [self setSlaveMode:NO];
    [self setAutoThresholds:NO];
    
    if ( ![self timerSet] ) // If we don't have saved prefs, we create a new set.
        {
        [self setTimerSet:[[NSMutableDictionary alloc] init]];
        [self setSetTime:[[self class] createDateFromHours:0 andMinutes:0 andSeconds:0]];
        [self setWarningTime:[[self class] createDateFromHours:0 andMinutes:1 andSeconds:0]];
        [self setFinalTime:[[self class] createDateFromHours:0 andMinutes:0 andSeconds:10]];
        [self setCommanderPeerID:nil];
        [self setCurrentTime:[self setTime]];
        [self setCompletionVolume:0];
        [self setElementColorOff:k_LGV_AppDelegate_timer_off_color];
        }
    else    // Otherwise, we establish the timer state from the saved prefs.
        {
        // The warning and final times...
        [self setSelectedColor:[(NSNumber *)[[self timerSet] objectForKey:s_selected_color_key] integerValue]];
        [self setWarningTime:[[self timerSet] objectForKey:s_time_warn_key]];
        [self setFinalTime:[[self timerSet] objectForKey:s_time_final_key]];
        
        if ( [[self timerSet] objectForKey:s_quiet_mode_key] )
            {
            [self setQuietMode:[(NSNumber *)[[self timerSet] objectForKey:s_quiet_mode_key] boolValue]];
            }
        
        if ( [[self timerSet] objectForKey:s_slave_mode_key] )
            {
            [self setSlaveMode:[(NSNumber *)[[self timerSet] objectForKey:s_slave_mode_key] boolValue] && ![[LGV_AppDelegate appDelegate] isCommanderModeOn]];
            }
        
        if ( [[self timerSet] objectForKey:s_auto_threshold_key] )
            {
            [self setAutoThresholds:[(NSNumber *)[[self timerSet] objectForKey:s_auto_threshold_key] boolValue]];
            }
        
        [self setSetTime:[[self timerSet] objectForKey:s_time_set_key]];
        [self setCompletionVolume:MAX ( 0, MIN ( 2, [(NSNumber *)[[self timerSet] objectForKey:s_time_completion_sound_key] intValue]) )];
        [self setCurrentTime:[[self timerSet] objectForKey:s_time_current_key]];
        [self setElementColorOff:[[self timerSet] objectForKey:s_element_color_off_key]];
        [self setCommanderPeerID:[[self timerSet] objectForKey:s_original_commander_key]];
        }
    
    [self saveMySettings];  // We make sure that the new settings are saved, so they will load next time.
    
    // Belt and suspenders: These all need to be set.
    if ( ![self setTime] )
        {
        [self setSetTime:[[self class] createDateFromHours:0 andMinutes:[self autoThresholds] ? 0 : 10 andSeconds:0]];
        }
    
    if ( ![self warningTime] )
        {
        [self setWarningTime:[[self class] createDateFromHours:0 andMinutes:[self autoThresholds] ? 0 : 10 andSeconds:0]];
        }
    
    if ( ![self finalTime ] )
        {
        [self setFinalTime:[[self class] createDateFromHours:0 andMinutes:[self autoThresholds] ? 0 : 5 andSeconds:0]];
        }
    
    if ( ![self currentTime] )
        {
        [self setCurrentTime:[self setTime]];
        }
   
    if ( ![self elementColorOff] )
        {
        [self setElementColorOff:k_LGV_AppDelegate_timer_off_color];
        }
    
    [self setUpNetworkManager:[self slaveMode]];
    
    [self setTimerDisplayToCurrentTime];
}

/*********************************************************/
/**
 \brief Returns the currently set time, in seconds.
 \returns an integer, with the number of seconds in the displayed time.
 */
- (NSInteger)currentSetTimeInSeconds
{
    NSDateComponents    *comp = [[self class] createComponentsFromDate:[self setTime]];
    
    return  ([comp hour] * 3600) + ([comp minute] * 60) + [comp second];
}

/*********************************************************/
/**
 \brief Returns the currently displayed time, in seconds.
 \returns an integer, with the number of seconds in the displayed time.
 */
- (NSInteger)currentDisplayedTimeInSeconds
{
    return ([[self timeDisplay] hoursValue] * 3600) + ([[self timeDisplay] minutesValue] * 60) + [[self timeDisplay] secondsValue];
}

/*********************************************************/
/**
 \brief Tells when the timer is done.
 \returns YES, if the timer is at 00:00:00.
 */
- (BOOL)timerIsZero
{
    return [self currentDisplayedTimeInSeconds] == 0;
}

/*********************************************************/
/**
 \brief Reports on whether or not the timer's set time is zero..
 \returns YES, if the set time for the timer is at 00:00:00.
 */
- (BOOL)setTimeIsZero
{
    return [self currentSetTimeInSeconds] == 0;
}

/*********************************************************/
/**
 \brief Sets the timer display to reflect the set time.
 */
- (void)setTimerDisplayToSetTime
{
    NSDateComponents *comp = [[self class] createComponentsFromDate:[self setTime]];
    
    NSInteger   seconds = [comp second];
    NSInteger   minutes = [comp minute];
    NSInteger   hours = [comp hour];
    [[self timeDisplay] setSecondsValue:seconds];
    [[self timeDisplay] setMinutesValue:minutes];
    [[self timeDisplay] setHoursValue:hours];
    [self _initializeTimeDisplayColors];
    [[self timeDisplay] setNeedsLayout];
    [[LGV_AppDelegate appDelegate] updateNetworkData:self];
}

/*********************************************************/
/**
 \brief Sets the timer display to reflect the current time.
 */
- (void)setTimerDisplayToCurrentTime
{
    NSDateComponents *comp = [[self class] createComponentsFromDate:[self currentTime]];
    
    NSInteger   seconds = [comp second];
    NSInteger   minutes = [comp minute];
    NSInteger   hours = [comp hour];
    [[self timeDisplay] setSecondsValue:seconds];
    [[self timeDisplay] setMinutesValue:minutes];
    [[self timeDisplay] setHoursValue:hours];
    [self _initializeTimeDisplayColors];
    [[self timeDisplay] setNeedsLayout];
    [[LGV_AppDelegate appDelegate] updateNetworkData:self];
}

/*********************************************************/
/**
 \brief This is how commanders update slaves.
 */
- (void)applyCommanderSettings:(NSDictionary*)inSettings    ///< A dictionary of settings to apply.
{
#ifdef  DEBUG
    NSLog ( @"A_LGV_TimerBaseViewController::applyCommanderSettings:%@", inSettings );
#endif
}

/*********************************************************/
/**
 \brief Resizes the displayed timer digits to fit in the aspect window.
 */
- (void)setTimerDisplayToAspectWindow
{
    CGRect  displayFrame = [[self timeDisplay] frame];
    
    float   aspect = displayFrame.size.width / displayFrame.size.height;
    
#ifdef  DEBUG
    NSLog(@"A_LGV_TimerBaseViewController::setTimerDisplayToAspectWindow original aspect: %f, original origin: (%f, %f), original size: (%f, %f).", aspect, displayFrame.origin.x, displayFrame.origin.y, displayFrame.size.width, displayFrame.size.height);
#endif
    
    aspect = MIN ( s_min_aspect_ratio_for_digits, MAX ( s_max_aspect_ratio_for_digits, aspect ) );
    
    displayFrame.size.height = (displayFrame.size.width / aspect);
    
    CGRect  containerBounds = [[[self timeDisplay] superview] bounds];
    
    displayFrame.origin.y = (containerBounds.size.height - displayFrame.size.height) / 2.0;
    
#ifdef  DEBUG
    NSLog(@"A_LGV_TimerBaseViewController::setTimerDisplayToAspectWindow new aspect: %f, new origin: (%f, %f), new size: (%f, %f).", aspect, displayFrame.origin.x, displayFrame.origin.y, displayFrame.size.width, displayFrame.size.height );
#endif
    
    [[self timeDisplay] setFrame:displayFrame];
    [[self timeDisplay] setNeedsLayout];
}

/*********************************************************/
/**
 \brief Tells the timer to close down its network manager.
 */
- (void)takeDownNetworkManager
{
    _networkManager = nil;  // All we need to do is delete the manager.
}

/*********************************************************/
/**
 \brief Sets up any necessary network manager.
 */
- (void)setUpNetworkManager:(BOOL)inSlaveMode   ///< If YES, then this will be a slave mode timer.
{
    // If we are in slave mode, we make sure that we have a network manager, and we riff off of that.
    if ( inSlaveMode )
        {
        if ( ![self networkManager] )
            {
            _networkManager = [[LGV_MCNetworkManagerClient alloc] initWithDelegate:[LGV_AppDelegate appDelegate] andOriginalID:[self commanderPeerID]];
            }
        }
    else
        {
        [self takeDownNetworkManager];
        }
}

#pragma mark - Private Instance Methods -
/*********************************************************/
/**
 \brief Initializes the time display with our colors.
 */
- (void)_initializeTimeDisplayColors
{
#ifdef  DEBUG
    NSLog(@"A_LGV_TimerBaseViewController::_initializeTimeDisplayColors");
#endif
    [[self timeDisplay] setElementColorOff:[self elementColorOff]];
    [[self timeDisplay] setElementColorOn:(UIColor *)[[[LGV_AppDelegate appDelegate] getColorChoices] objectAtIndex:[self selectedColor]]];
    [[self timeDisplay] setNeedsLayout];
}
@end
