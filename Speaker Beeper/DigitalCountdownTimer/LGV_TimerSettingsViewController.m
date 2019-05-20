//
//  LGV_TimerSettingsViewController.m
//  DigitalCountdownTimer
//
//  Created by Chris Marshall on 7/10/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC All rights reserved.
//
/*********************************************************/
/**
 \file LGV_TimerSettingsViewController.m
 \brief This file implements the timer setting view controller.
 
        This is the more complicated view. It allows the user
        to set and control the timer. It will always display
        the timer as digits, which can be "swiped" by the user
        to set (swipe or tap up and down on the hours, minutes
        and seconds displays).
 
        It allows access to the timer prefs. If the Podium Mode
        (also called "quiet mode") is selected, then two additional
        controls appear over the numbers. These allow the Podium
        Mode thresholds to be set.
 
        The timer can be cleared (set to 0), or reset to the set
        number (the displayed time can be changed by running the
        timer in non-Podium Mode).
 
        Starting the timer will engage a modal view that will have
        its state set via our settings. If Podium Mode is selected,
        the operational timer will show only the three "lights."
*/

#import "LGV_TimerSettingsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "LGV_OperationalTimerViewController.h"
#import "LGV_PrefsViewController.h"

static const NSInteger      s_Reset_Start_Separator         = 4;    ///< This is the gap between the Reset and Start Button (When Reset Is Displayed).

#pragma mark - LGV_TimerSettingsViewController Class Private Interface -
/*********************************************************/
/**
 \class LGV_TimerSettingsViewController
 \brief This class controls one view of the basic timer display.
        These are the private properties and functions.
 */
@interface LGV_TimerSettingsViewController ()
{
    NSDate                  *trackingTime;  ///< This will be used to make sure that we are always on time. The callbacks have an unreliable period.
    UIPopoverController     *prefsPopover;  ///< This holds the popover (for iPad) for the prefs.
    LGV_PrefsViewController *prefsViewController;   ///< This holds the prefs view controller.
}
#pragma mark - Private Property Declarations -

@property (retain, atomic)              LGV_PrizeWheelScroller      *secondsScroller;       ///< The "prize wheel" scroller for the seconds display.
@property (retain, atomic)              LGV_PrizeWheelScroller      *minutesScroller;       ///< The "prize wheel" scroller for the minutes display.
@property (retain, atomic)              LGV_PrizeWheelScroller      *hoursScroller;         ///< The "prize wheel" scroller for the hours display.

#pragma mark - Private Method Declarations -

- (void)_establishGestureRecognizers;                                                       ///< Sets up our gesture recognizers.
- (void)_setUpUI;                                                                           ///< This sets up the various buttons, according to the timer state.
- (void)_setSetTime:(NSDate *)time;                                                         ///< The time to save as the official "root" time.
- (void)_setResetButtonState;                                                               ///< Sets up our reset button (if necessary).
- (void)_setAutoState;                                                                      ///< Sets any auto thresholds.
- (void)_setWarningThresholdButtonState;                                                    ///< Sets the state of the warning threshold button.
- (void)_setFinalThresholdButtonState;                                                      ///< Sets the state of the final threshold button.
- (void)_adjustSeconds:(NSNumber *)clicks;                                                  ///< Adjusts the seconds display by the number of steps provided.
- (void)_adjustMinutes:(NSNumber *)clicks;                                                  ///< Adjusts the minutes display by the number of steps provided.
- (void)_adjustHours:(NSNumber *)clicks;                                                    ///< Adjusts the hours display by the number of steps provided.

@end

#pragma mark - LGV_TimerSettingsViewController Class Implementation -
/*********************************************************/
/**
 \class LGV_TimerSettingsViewController
 \brief This class controls one view of the basic timer display.
 */
@implementation LGV_TimerSettingsViewController

#pragma mark - Superclass Overrides -

/*********************************************************/
/**
 \brief Make sure the timer is turned off.
 */
- (void)dealloc
{
    [self saveMySettings];
}

/*********************************************************/
/**
 \brief Once things are loaded, we can set up the display.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Clear the set time.
    [self _setSetTime:[[self class] createDateFromHours:0 andMinutes:0 andSeconds:0]];
    
    // Localize the titles of these buttons.
    [[self resetStandaloneButton] setTitle:NSLocalizedString([[self resetStandaloneButton] titleForState:UIControlStateNormal], nil) forState:UIControlStateNormal];
    [[self clearStandaloneButton] setTitle:NSLocalizedString([[self clearStandaloneButton] titleForState:UIControlStateNormal], nil) forState:UIControlStateNormal];
    [[self prefsStandaloneButton] setTitle:NSLocalizedString([[self prefsStandaloneButton] titleForState:UIControlStateNormal], nil) forState:UIControlStateNormal];
    
    // We want tighter corners on our buttons than the default.
    [[self resetStandaloneButton] setCornerRadius:4];
    [[self clearStandaloneButton] setCornerRadius:4];
    [[self prefsStandaloneButton] setCornerRadius:4];
    [[self warningThresholdButton] setCornerRadius:4];
    [[self finalThresholdButton] setCornerRadius:4];
    [[self startButton] setCornerRadius:4];
    
    // Set the font used for the buttons, according to whether or not we are on an iPad.
    UIFont  *buttonFont = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? k_LGV_StandardTextSize_iPad : k_LGV_StandardTextSize_iPhone;

    [[[self clearStandaloneButton] titleLabel] setFont:buttonFont];
    [[[self warningThresholdButton] titleLabel] setFont:buttonFont];
    [[[self finalThresholdButton] titleLabel] setFont:buttonFont];
    [[[self prefsStandaloneButton] titleLabel] setFont:buttonFont];
    [[[self resetStandaloneButton] titleLabel] setFont:buttonFont];
    
    [[self resetStandaloneButton] setBackgroundColor:k_LGV_Prefs_Button_Color];
    [[self resetStandaloneButton] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
   
    [[self prefsStandaloneButton] setBackgroundColor:k_LGV_Prefs_Button_Color];
    [[self prefsStandaloneButton] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [[self clearStandaloneButton] setBackgroundColor:k_LGV_Prefs_Button_Color];
    [[self clearStandaloneButton] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [[self backgroundPanel] setLowColor:[UIColor blackColor]];
    [[self backgroundPanel] setHighColor:k_LGV_TopBarColor];
    
    [self loadMySettings];
}

/*********************************************************/
/**
 \brief Make sure these are unloaded at unload time.
 */
- (void)viewDidUnload
{
    [self setStartButton:nil];
    [self setResetStandaloneButton:nil];
    [self setClearStandaloneButton:nil];
    [self setPrefsStandaloneButton:nil];
    [self setStandaloneButtons:nil];
    [self setWarningThresholdButton:nil];
    [self setFinalThresholdButton:nil];
    [self setMainItemsView:nil];
    [self setThresholdButtons:nil];
    [self setStartBarView:nil];
    [super viewDidUnload];
}

/*********************************************************/
/**
 \brief Hide the navbar for this view.
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self _setUpUI];
    if ( [self quietMode] ) // Quiet mode can't do with odd times.
        {
        [self resetButtonHit:nil];
        }
    [self _setResetButtonState];
}

/*********************************************************/
/**
 \brief We load the gesture recognizers at this time,
 because the panels aren't created until late.
 */
- (void)viewDidAppear:(BOOL)animated    ///< Yes, if the appearance is to be animated.
{
    [super viewDidAppear:animated];
    [self _establishGestureRecognizers];
    [self _setUpUI];
}
/*********************************************************/
/**
 \brief Resrict or allow rotation. Portrait and upside-down iPhone are disallowed.
 \returns YES, if the rotation is approved.
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation ///< The proposed orientation.
{
    BOOL    ret = [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    
    if ( ret )
        {
        [prefsPopover dismissPopoverAnimated:NO];   // Make sure the popover dismisses if it is up when we rotate.
        }
    [[self view] setNeedsLayout];
    [[self backgroundPanel] setNeedsLayout];   // In some cases, the background rounded rect will not respond to a re-layout. This ensures that it gets the memo.
    
    return ret;
}

/*********************************************************/
/**
 \brief 
 */
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self _establishGestureRecognizers];
    [self _setUpUI];
}

#pragma mark - Private Instance Methods -

/*********************************************************/
/**
 \brief Sets up all the gesture recognizers.
 */
- (void)_establishGestureRecognizers
{
    // Get rid of any current ones, first.
    [[self secondsScroller] removeFromSuperview];
    [self setSecondsScroller:nil];
    [[self minutesScroller] removeFromSuperview];
    [self setMinutesScroller:nil];
    [[self hoursScroller] removeFromSuperview];
    [self setHoursScroller:nil];
    
    if ( ![self slaveMode] )
        {
        // We offset the frames, so they exactly match the numbers.
        CGRect  containerFrame = [[self timeDisplay] frame];
        CGRect  secondsFrame = CGRectOffset ( [[[self timeDisplay] seconds] frame], containerFrame.origin.x, containerFrame.origin.y );
        CGRect  minutesFrame = CGRectOffset ( [[[self timeDisplay] minutes] frame], containerFrame.origin.x, containerFrame.origin.y );
        CGRect  hoursFrame = CGRectOffset ( [[[self timeDisplay] hours] frame], containerFrame.origin.x, containerFrame.origin.y );
        
        // We need to create views, because the underlying views are constantly being replaced. It's the way the classes work.
        [self setSecondsScroller:[[LGV_PrizeWheelScroller alloc] initWithFrame:secondsFrame]];
        [self setMinutesScroller:[[LGV_PrizeWheelScroller alloc] initWithFrame:minutesFrame]];
        [self setHoursScroller:[[LGV_PrizeWheelScroller alloc] initWithFrame:hoursFrame]];
        
        // Make sure that the scrollers are transparent.
        [[self secondsScroller] setBackgroundColor:[UIColor clearColor]];
        [[self minutesScroller] setBackgroundColor:[UIColor clearColor]];
        [[self hoursScroller] setBackgroundColor:[UIColor clearColor]];
        
        // Make sure they will resize properly.    
        [[self secondsScroller] setAutoresizingMask:[[[self timeDisplay] seconds] autoresizingMask]];
        [[self minutesScroller] setAutoresizingMask:[[[self timeDisplay] minutes] autoresizingMask]];
        [[self hoursScroller] setAutoresizingMask:[[[self timeDisplay] hours] autoresizingMask]];
            
        // They should write often.
        [[self secondsScroller] setDelegate:self];
        [[self minutesScroller] setDelegate:self];
        [[self hoursScroller] setDelegate:self];
        
        // Add our new gesture recognizers.
        [[self mainItemsView] addSubview:[self secondsScroller]];
        [[self mainItemsView] addSubview:[self minutesScroller]];
        [[self mainItemsView] addSubview:[self hoursScroller]];
        }
}

/*********************************************************/
/**
 \brief Sets up the display for the threshold lights.
 */
- (void)_setThresholdDisplayState
{
    if ( [self quietMode] )
        {
        [[self thresholdButtons] setAlpha:1.0];
        }
    else
        {
        [[self thresholdButtons] setAlpha:0.1];
        }
    
    [self _setAutoState];
}

/*********************************************************/
/**
 \brief Sets up the Warning State button.
 */
- (void)_setWarningThresholdButtonState
{
    if ( [self quietMode] )
        {
        NSTimeInterval      currentTimeInterval = [self currentDisplayedTimeInSeconds];
        NSDateComponents    *comp = [[self class] createComponentsFromDate:[self warningTime]];
        NSTimeInterval      warningThreshold = ([comp hour] * 60 * 60) + ([comp minute] * 60) + [comp second];
        NSString            *newTitle = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)[comp hour], (long)[comp minute], (long)[comp second]];
        
        [[self warningThresholdButton] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[self warningThresholdButton] setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [[self warningThresholdButton] setBorderWidth:0];
        
        if ( ![self autoThresholds] && ((int)currentTimeInterval != (int)warningThreshold) )
            {
            [[self warningThresholdButton] setLowColor:k_LGV_Quiet_Mode_Yellow_Light_Low];
            [[self warningThresholdButton] setHighColor:k_LGV_Quiet_Mode_Yellow_Light_High];
            [[self warningThresholdButton] setEnabled:YES];
            }
        else
            {
            [[self warningThresholdButton] setBackgroundColor:k_LGV_Quiet_Mode_Yellow_Dark_High];
            [[self warningThresholdButton] setEnabled:NO];
            }
        
        [[self warningThresholdButton] setTitle:newTitle forState:UIControlStateNormal];
        [[self warningThresholdButton] setTitle:newTitle forState:UIControlStateDisabled];
        [[[self warningThresholdButton] titleLabel] setText:newTitle];
        }
    else
        {
        [[self warningThresholdButton] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[self warningThresholdButton] setBackgroundColor:k_LGV_Quiet_Mode_Yellow_Dark_High];
        [[self warningThresholdButton] setEnabled:NO];
        [[self warningThresholdButton] setTitle:nil forState:UIControlStateNormal];
        [[[self warningThresholdButton] titleLabel] setText:nil];
        }
}

/*********************************************************/
/**
 \brief Sets up the Warning State button.
 */
- (void)_setFinalThresholdButtonState
{
    if ( [self quietMode] )
        {
        NSTimeInterval      currentTimeInterval = [self currentDisplayedTimeInSeconds];
        NSDateComponents    *comp = [[self class] createComponentsFromDate:[self finalTime]];
        NSTimeInterval      finalThreshold = ([comp hour] * 60 * 60) + ([comp minute] * 60) + [comp second];
        NSString            *newTitle = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)[comp hour], (long)[comp minute], (long)[comp second]];
        
        [[self finalThresholdButton] setBorderWidth:0];
        
        [[self finalThresholdButton] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        if ( ![self autoThresholds] && ((int)currentTimeInterval != (int)finalThreshold) )
            {
            [[self finalThresholdButton] setTitleColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
            [[self finalThresholdButton] setLowColor:k_LGV_Quiet_Mode_Red_Light_Low];
            [[self finalThresholdButton] setHighColor:k_LGV_Quiet_Mode_Red_Light_High];
            [[self finalThresholdButton] setEnabled:YES];
            }
        else
            {
            [[self finalThresholdButton] setBackgroundColor:k_LGV_Quiet_Mode_Red_Dark_High];
            [[self finalThresholdButton] setEnabled:NO];
            }
        [[self finalThresholdButton] setTitle:newTitle forState:UIControlStateNormal];
        [[self finalThresholdButton] setTitle:newTitle forState:UIControlStateDisabled];
        [[[self finalThresholdButton] titleLabel] setText:newTitle];
        }
    else
        {
        [[self finalThresholdButton] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[self finalThresholdButton] setBackgroundColor:k_LGV_Quiet_Mode_Red_Dark_High];
        [[self finalThresholdButton] setEnabled:NO];
        [[self finalThresholdButton] setTitle:nil forState:UIControlStateNormal];
        [[[self finalThresholdButton] titleLabel] setText:nil];
        }

}

/*********************************************************/
/**
 \brief This sets up the various buttons, according to the timer state.
 */
- (void)_setUpUI
{
    [[[self navigationController] navigationBar] setHidden:YES];
    
    CGRect startRect = [[self startBarView] bounds];
    
    // The reset button is only enabled when we have a set time, and the timer is not on that time.
    if ( ([[self setTime] compare:[self currentTime]] == NSOrderedSame) )
        {
        [[self resetStandaloneButton] setHidden:YES];
        }
    else
        {
        [[self resetStandaloneButton] setHidden:NO];
        
        float   offTheSides = [[self resetStandaloneButton] frame].size.width + s_Reset_Start_Separator;
        
        startRect.size.width -= offTheSides;
        startRect.origin.x += offTheSides;
        }
    
    [[self startButton] setFrame:startRect];
    [[self startButton] setBorderWidth:0];
        
    if ( [self slaveMode] || [self timerIsZero] )
        {
        [[self clearStandaloneButton] setEnabled:NO];
        [[self clearStandaloneButton] setAlpha:0.25];  // The clear button is enabled whenever the timer is nonzero, or we have a set time.
        }
    else
        {
        [[self clearStandaloneButton] setEnabled:YES];
        [[self clearStandaloneButton] setAlpha:1.0];  // The clear button is enabled whenever the timer is nonzero, or we have a set time.
        }
    
    // We disable the scrollers if the timer is going.
    [[self secondsScroller] setEnabled:YES];
    [[self minutesScroller] setEnabled:YES];
    [[self hoursScroller] setEnabled:YES];
    
    // We set up our timer defaults here, in case they are changed elsewhere.
    [[self secondsScroller] setHighlightColor:[[self timeDisplay] elementColorOn]];
    [[self minutesScroller] setHighlightColor:[[self timeDisplay] elementColorOn]];
    [[self hoursScroller] setHighlightColor:[[self timeDisplay] elementColorOn]];
    
    // This is the speed of the scroller.
    float   timerSpeed = [[LGV_AppDelegate appDelegate] scrollSpeed] / 8.0;
    [[self secondsScroller] setIncrementValue:timerSpeed];
    [[self minutesScroller] setIncrementValue:timerSpeed];
    [[self hoursScroller] setIncrementValue:timerSpeed];
    
    // Set the various global prefs.
    BOOL    audibleFeedbackOn = [[LGV_AppDelegate appDelegate] soundOn];
    [[self secondsScroller] setAudibleFeedback:audibleFeedbackOn];
    [[self minutesScroller] setAudibleFeedback:audibleFeedbackOn];
    [[self hoursScroller] setAudibleFeedback:audibleFeedbackOn];
    
    BOOL    visualFeedbackOn = [[LGV_AppDelegate appDelegate] visualFeedbackOn];
    [[self secondsScroller] setVisualFeedback:visualFeedbackOn];
    [[self minutesScroller] setVisualFeedback:visualFeedbackOn];
    [[self hoursScroller] setVisualFeedback:visualFeedbackOn];
    [[self startButton] setHidden:NO];
    
    if ( [self currentDisplayedTimeInSeconds] != [self currentSetTimeInSeconds] )
        {
        [[self startButton] setTitle:NSLocalizedString(@"CONTINUE", nil) forState:UIControlStateNormal];
        }
    else if ( [self timerIsZero] )
        {
        [[self startButton] setTitle:NSLocalizedString(@"DISABLED", nil) forState:UIControlStateNormal];
        }
    else
        {
        [[self startButton] setTitle:NSLocalizedString(@"START", nil) forState:UIControlStateNormal];
        }
    
    UIFont  *buttonFont = nil;
    
    // Set the START button to a large font, if we are enabled, and a smaller italic font, if not.
    if ( ![self timerIsZero] )
        {
        [[self startButton] setLowColor:k_LGV_Start_Button_Low];
        [[self startButton] setHighColor:k_LGV_Start_Button_High];
        [[self startButton] setEnabled:YES];
        buttonFont = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? k_LGV_StandardTextSizeBold_iPad : k_LGV_StandardTextSizeBold_iPhone;
        }
    else
        {
        [[self startButton] setBackgroundColor:[UIColor clearColor]];
        [[self startButton] setEnabled:NO];
        buttonFont = k_LGV_ItalicTextSize_Prompt;
        }
    
    [[[self startButton] titleLabel] setAdjustsFontSizeToFitWidth:YES];
    [self _setThresholdDisplayState];    ///< Set up our threshold display.
    [[[self startButton] titleLabel] setFont:buttonFont];
    
    if ( [self slaveMode] )
        {
        [[self startButton] setHidden:YES];
        [[self resetStandaloneButton] setHidden:YES];
        [[self warningThresholdButton] setEnabled:NO];
        [[self finalThresholdButton] setEnabled:NO];
        }
    
    [[LGV_AppDelegate appDelegate] updateNetworkData:self];
}

/*********************************************************/
/**
 \brief Overload of our setter, so we can update the
 reset button time.
 */
- (void)_setSetTime:(NSDate *)time   ///< The time to save as the official "root" time.
{
    [self _setResetButtonState];
    [super setSetTime:time];
    [self _setAutoState];
}

/*********************************************************/
/**
 \brief This sets up our reset button, in digital mode.
 */
- (void)_setResetButtonState
{
    NSString    *resetTitle = nil;

    if ( [self setTime] )
        {
        NSDateComponents    *timeComponents = [[self class] createComponentsFromDate:[self setTime]];
        
        NSInteger   seconds = [timeComponents second];
        NSInteger   minutes = [timeComponents minute];
        NSInteger   hours = [timeComponents hour];
    
        resetTitle = [NSString stringWithFormat:@"%@ %02ld:%02ld:%02ld", NSLocalizedString(@"RESET TO", nil), (long)hours, (long)minutes, (long)seconds];
        }
    
    [[self resetStandaloneButton] setTitle:resetTitle forState:UIControlStateNormal];
    [[self resetStandaloneButton] setTitle:resetTitle forState:UIControlStateDisabled];
    [[[self resetStandaloneButton] titleLabel] setText:resetTitle];
}

/*********************************************************/
/**
 \brief Sets the warning and final threshold times if auto.
        Sets the two buttons to reflect whatever state is proper.
 */
- (void)_setAutoState
{
    if ( [self autoThresholds] )
        {
        NSDate         *zeroHour = [[self class] createDateFromHours:0 andMinutes:0 andSeconds:0];
        
        NSTimeInterval baseTime = [[self setTime] timeIntervalSinceDate:zeroHour];
        NSTimeInterval warningTimeInterval = baseTime * s_default_warning_threshold_for_auto;
        NSTimeInterval finalTimeInterval = baseTime * s_default_final_threshold_for_auto;
        
        [self setWarningTime:[NSDate dateWithTimeInterval:warningTimeInterval sinceDate:zeroHour]];
        [self setFinalTime:[NSDate dateWithTimeInterval:finalTimeInterval sinceDate:zeroHour]];
        }
    
    [self _setWarningThresholdButtonState];
    [self _setFinalThresholdButtonState];
}

/*********************************************************/
/**
 \brief Reacts to someone panning over the seconds pane.
 */
- (void)_adjustSeconds:(NSNumber *)clicks    ///< This is how many units to add/subtract from the current total.
{
    [[self timeDisplay] setSecondsValue:MIN ( 59, MAX ( 0, [[self timeDisplay] secondsValue] + [clicks intValue] ) )];
    [self _setSetTime:[[self class] createDateFromHours:(int)[[self timeDisplay] hoursValue] andMinutes:(int)[[self timeDisplay] minutesValue] andSeconds:(int)[[self timeDisplay] secondsValue]]];
}

/*********************************************************/
/**
 \brief Reacts to someone panning over the minutes pane.
 */
- (void)_adjustMinutes:(NSNumber *)clicks    ///< This is how many units to add/subtract from the current total.
{
    [[self timeDisplay] setMinutesValue:MIN ( 59, MAX ( 0, [[self timeDisplay] minutesValue] + [clicks intValue] ) )];
    [self _setSetTime:[[self class] createDateFromHours:(int)[[self timeDisplay] hoursValue] andMinutes:(int)[[self timeDisplay] minutesValue] andSeconds:(int)[[self timeDisplay] secondsValue]]];
}

/*********************************************************/
/**
 \brief Reacts to someone panning over the hours pane.
 */
- (void)_adjustHours:(NSNumber *)clicks      ///< This is how many units to add/subtract from the current total.
{
    [[self timeDisplay] setHoursValue:MIN ( 23, MAX ( 0, [[self timeDisplay] hoursValue] + [clicks intValue] ) )];
    [self _setSetTime:[[self class] createDateFromHours:(int)[[self timeDisplay] hoursValue] andMinutes:(int)[[self timeDisplay] minutesValue] andSeconds:(int)[[self timeDisplay] secondsValue]]];
}

#pragma mark - UIPopoverControllerDelegate Routines -

/*********************************************************/
/**
 \brief Reacts to someone panning over the hours pane.
 */
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController ///< The popover controller for this instance.
{
    prefsPopover = nil;
    [self loadMySettings];
    [self _setUpUI];
    if ( [self quietMode] ) // Quiet mode can't do with odd times.
        {
        [self resetButtonHit:nil];
        }
}

#pragma mark - UI Callbacks -

/*********************************************************/
/**
 \brief This brings up the prefs screen.
 */
- (IBAction)prefsButtonHit:(id)sender   ///< The PREFS UIButton
{
    // Instantiate a new prefs controller from the prototype.
    prefsViewController = (LGV_PrefsViewController *)[[self storyboard] instantiateViewControllerWithIdentifier:@"timer-settings-prototype"];
    
    if ( prefsViewController )
        {
        [prefsViewController setMyController:self];
        
        // iPad uses a popover for this.
        if ( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad )
            {
            UIView  *myContext = [(UIButton *)sender superview];
            prefsPopover = [[UIPopoverController alloc] initWithContentViewController:prefsViewController];

            [prefsViewController setIsInPopover:YES];
            [prefsPopover setDelegate:self];
            
            [prefsPopover presentPopoverFromRect:[(UIButton *)sender frame]
                                          inView:myContext
                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                        animated:YES];
            }
        else    // iPhone pushes in a nav controller.
            {
            [prefsViewController setIsInPopover:NO];
            [[self navigationController] pushViewController:prefsViewController animated:YES];
            }
        }
}

/*********************************************************/
/**
 \brief This starts the timer without resetting it.
 */
- (IBAction)startTimer:(id)sender   ///< The START UIButton
{
    [self presentViewController:[[LGV_OperationalTimerViewController alloc] initWithNibName:nil bundle:nil andPrefsKey:[self myPrefsKey]] animated:NO completion:nil];
}

/*********************************************************/
/**
 \brief This is called when the clear button is hit.
 */
- (IBAction)clearButtonHit:(id)sender   ///< The CLEAR UIBarButtonItem
{
    if ( ![self slaveMode] )
        {
        [self _setSetTime:[[self class] createDateFromHours:0 andMinutes:0 andSeconds:0]];
        [self setCurrentTime:[self setTime]];
        [self saveMySettings];
        [self setTimerDisplayToCurrentTime];
        [self _setAutoState];
        [self _setUpUI];
        }
}

/*********************************************************/
/**
 \brief This is called when the reset button is hit.
 */
- (IBAction)resetButtonHit:(id)sender   ///< The RESET TO XX:XX:XX UIBarButtonItem
{
    if ( ![self slaveMode] )
        {
        [self setCurrentTime:[self setTime]];
        [[self timeDisplay] setTime:[self setTime]];
        [self saveMySettings];
        [self setTimerDisplayToCurrentTime];
        [self _setUpUI];
        }
}

/*********************************************************/
/**
 \brief This is called when the set warning threshold button is hit.
 */
- (IBAction)yellowButtonHit:(id)sender
{
    if ( ![self slaveMode] )
        {
        NSInteger   hours = [[self timeDisplay] hoursValue];
        NSInteger   minutes = [[self timeDisplay] minutesValue];
        NSInteger   seconds = [[self timeDisplay] secondsValue];

        [self setWarningTime:[[self class] createDateFromHours:(int)hours andMinutes:(int)minutes andSeconds:(int)seconds]];
        
        [self _setThresholdDisplayState];
        [self saveMySettings];
        }
}

/*********************************************************/
/**
 \brief This is called when the set final threshold button is hit.
 */
- (IBAction)redButtonHit:(id)sender
{
    if ( ![self slaveMode] )
        {
        NSInteger   hours = [[self timeDisplay] hoursValue];
        NSInteger   minutes = [[self timeDisplay] minutesValue];
        NSInteger   seconds = [[self timeDisplay] secondsValue];
        
        [self setFinalTime:[[self class] createDateFromHours:(int)hours andMinutes:(int)minutes andSeconds:(int)seconds]];
        
        [self _setThresholdDisplayState];
        [self saveMySettings];
        }
}

#pragma mark - LGV_PrizeWheelScroller Delegate Funtions -
/*********************************************************/
/**
 \brief Called when one of the scrollers is moved.
 */
- (void)prizeWheelScrollerMoved:(LGV_PrizeWheelScroller *)scroller  ///< The Scroller object
               byThisManyClicks:(NSInteger)numberOfMoves            ///< The number of moves to be made in this call.
{
#ifdef DEBUG
    NSLog(@"LGV_TimerSettingsViewController::prizeWheelScrollerMoved: with this many clicks %ld", (long)numberOfMoves);
#endif
    if ( ![self slaveMode] )
        {
        numberOfMoves = -numberOfMoves;
        
        NSNumber    *clicks = [NSNumber numberWithInteger:numberOfMoves];
        
        if ( scroller == [self secondsScroller] )
            {
            [self _adjustSeconds:clicks];
            }
        else if ( scroller == [self minutesScroller] )
            {
            [self _adjustMinutes:clicks];
            }
        else if ( scroller == [self hoursScroller] )
            {
            [self _adjustHours:clicks];
            }
        
        [self _setSetTime:[[self class] createDateFromHours:(int)[[self timeDisplay] hoursValue] andMinutes:(int)[[self timeDisplay] minutesValue] andSeconds:(int)[[self timeDisplay] secondsValue]]];
        [self setCurrentTime:[self setTime]];
        [self saveMySettings];  // We make sure that the new settings are saved, so they will load next time.
        [self _setUpUI];
        }
}

@end
