//
//  LGV_OperationalTimerViewController.m
//  DigitalCountdownTimer
//
//  Created by Chris Marshall on 8/5/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//
/*********************************************************/
/**
 \file LGV_OperationalTimerViewController.m
 \brief This file implements the timer operational view controller.
 
        This is the running timer display. It uses a 1-second callback
        to change the displayed time (but uses actual times to determine
        the time to be displayed). If Podium Mode is shown, then the
        timer will only show the three "lights."
 
        This communicates with the settings view controller via the settings,
        which hold a constant state.

        If in Podium Mode, stopping the timer will always reset it to the
        set time. In non-Podium Mode, the current time will be saved and
        returned to the settings (the timer will be paused).
 
        This displays an extremely simple view. Either it is the digits
        (for non-Podium Mode), or the three Podium Mode "lights," and a
        STOP or PAUSE button.
 
        This is designed to be a modal view. It communicates with the presenting
        view via the state settings (except for dismissing the view, which requires
        direct communication with the presenting view -Yecch).
 */

#import "LGV_OperationalTimerViewController.h"
#import "LGV_TimerSettingsViewController.h"

static const float  s_flashingInterval      = 0.25; ///< The interval between flashes of the digits when done.
static const float  s_beepingInterval       = 0.25; ///< The interval between beeps when done.

/*********************************************************/
/**
 \class LGV_OperationalTimerViewController (Private Interface)
 \brief This class controls the view for the operating clock.
 */
@interface LGV_OperationalTimerViewController ()
{
    int     beepCount;  ///< This is used to count the beeps, so that they come in bursts of two per second.
    UIColor *oldColor;  ///< Used to restore the original color while blinking the done numbers.
}

@property (nonatomic, readwrite)    BOOL            timerOn;            ///< This flag tells whether the timer is currently running.
@property (atomic, readwrite)       BOOL            gameOverCalled;     ///< This is set when the timer is complete.
@property (atomic, readwrite)       SystemSoundID   beep_sound;         ///< This will contain the beep sound.
@property (atomic, readwrite)       NSURL           *beep_sound_url;    ///< This points to the sound file.

- (NSInteger)_currentSetTimeInSeconds;
- (NSInteger)_currentDisplayedTimeInSeconds;
- (void)_decrementTimer;
- (NSInteger)_setCorrectTime;
- (void)_gimmeASec;
- (void)_setThresholdDisplayState;
- (void)_offState;
- (void)_greenState;
- (void)_yellowState;
- (void)_redState;
- (void)_gameOverMan;
- (void)_playAlertSound;
- (void)_playBeepAndAgain;
- (void)_setBeepSoundByName:(NSString *)inFileName;
- (void)_flashRedOFF;
- (void)_flashRedON;
- (void)_setUpWindow;
@end

/*********************************************************/
/**
 \class LGV_OperationalTimerViewController
 \brief This class controls the view for the operating clock.
 */
@implementation LGV_OperationalTimerViewController
@synthesize timerOn     = _timerOn;     ///< We do this, because we override the setter.
@synthesize beep_sound  = _beep_sound;  ///< We do this, because we directly access the memory for the sound.

#pragma mark - Public Superclass Override Methods -
/*********************************************************/
/**
 \brief Initializer with the prefs ID added.
 \returns self
 */
- (id)initWithNibName:(NSString *)nibNameOrNil      ///< The XIB file name
               bundle:(NSBundle *)nibBundleOrNil    ///< The bundle name
          andPrefsKey:(NSString *)prefsKey          ///< Our prefs key (the prefs are the semaphore for communicating with this class).
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
        {
        [self setMyPrefsKey:prefsKey];
        }
    
    return self;
}

/*********************************************************/
/**
 \brief Just make sure the sound is gone.
 */
- (void)dealloc
{
    AudioServicesDisposeSystemSoundID ( [self beep_sound] );
    [[[LGV_AppDelegate appDelegate] application] setIdleTimerDisabled:NO];  // Make sure this is turned off.
}

/*********************************************************/
/**
 \brief Called just before the view appears. We make sure
        that the settings are loaded, and set up the display.
        We also hide the status bar, here.
 */
- (void)viewWillAppear:(BOOL)animated   ///< YES, if the appearance is animated (we ignore it).
{
    [super viewWillAppear:animated];
    [[[LGV_AppDelegate appDelegate] application] setStatusBarHidden:YES];
    [self _setUpWindow];
    [self _setCorrectTime];
}

/*********************************************************/
/**
 \brief Called just before the view disappears. We take
        the opportunity to restore the status bar.
 */
- (void)viewWillDisappear:(BOOL)animated
{
    [[[LGV_AppDelegate appDelegate] application] setStatusBarHidden:NO];
}

/*********************************************************/
/**
 \brief Called after the view appears. We start the timer now.
 */
- (void)viewDidAppear:(BOOL)animated    ///< YES, if the appearance is animated (we ignore it).
{
    [super viewDidAppear:animated];
    [self startTimer];
}

/*********************************************************/
/**
 \brief Just let go...
 */
- (void)viewDidUnload
{
    [self setPodiumTimerView:nil];
    [self setGreenPodiumLight:nil];
    [self setYellowPodiumLight:nil];
    [self setRedPodiumLight:nil];
    [super viewDidUnload];
}

/*********************************************************/
/**
 \brief We overload this, because we will center the timer.
 */
- (void)setTimerDisplayToAspectWindow
{
    [super setTimerDisplayToAspectWindow];
    
    CGRect  displayRect = [[self timeDisplay] frame];
    CGRect  winFrame = [[self view] bounds];
    
    displayRect.origin.y = (winFrame.size.height - displayRect.size.height) / 2.0;
    
    [[self timeDisplay] setFrame:displayRect];
}

#pragma mark - Public Instance Methods -

/*********************************************************/
/**
 \brief Starts the timer going.
 */
- (void)startTimer
{
    [self setTimerOn:YES];
    [self _gimmeASec];
}

/*********************************************************/
/**
 \brief This is called by tapping on the screen.
 */
- (IBAction)tappedOut:(id)sender ///< The sender object
{
    if ( [self quietMode] || [self gameOverCalled] ) // In quiet mode, or if the timer has passed GO, we always stop (reset) it.
        {
        [self stopTimer];
        }
    else
        {
        [self pauseTimer];  // Otherwise, we just pause it.
        }
}

/*********************************************************/
/**
 \brief This pauses the timer. It saves the current time,
        and dismisses the view.
 */
- (void)pauseTimer
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [self setTimerOn:NO];
    [self saveMySettings];
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];  // Fugly, but necessary. This forces the container to close the dialog.
}

/*********************************************************/
/**
 \brief This stops the timer. It resets the timer to the set
        time, and dismisses the view.
 */
- (void)stopTimer
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [self setTimerOn:NO];
    [self setCurrentTime:[self setTime]];
    [self setTimerDisplayToSetTime];
    [self saveMySettings];
    [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];  // Fugly, but necessary. This forces the container to close the dialog.
}

#pragma mark - Private Instance Methods -

/*********************************************************/
/**
 \brief Returns the currently set time, in seconds.
 \returns an integer, with the number of seconds in the displayed time.
 */
- (NSInteger)_currentSetTimeInSeconds
{
    NSDateComponents    *comp = [LGV_TimerSettingsViewController createComponentsFromDate:[self setTime]];
    
    return  ([comp hour] * 3600) + ([comp minute] * 60) + [comp second];
}

/*********************************************************/
/**
 \brief Returns the currently displayed time, in seconds.
 \returns an integer, with the number of seconds in the displayed time.
 */
- (NSInteger)_currentDisplayedTimeInSeconds
{
    NSInteger   time = ([[self timeDisplay] hoursValue] * 3600) + ([[self timeDisplay] minutesValue] * 60) + [[self timeDisplay] secondsValue];
    
    if ( [self gameOverCalled] )   // If we have crossed the rubicon, we are bizarro.
        {
        time = -time;
        }
    
    return time;
}

/*********************************************************/
/**
 \brief This sets the timer on flag. It will also trigger
 or cancel any timer functionality.
 */
- (void)setTimerOn:(BOOL)timerOn    ///< YES, if the timer is to be turned on.
{
    if ( timerOn && !_timerOn )
        {
        [[[LGV_AppDelegate appDelegate] application] setIdleTimerDisabled:YES];  // Keep the phone awake for the dureation.
        NSTimeInterval  secondsDisplayed = [self _currentDisplayedTimeInSeconds];
        [self setStartTime:[NSDate dateWithTimeInterval:secondsDisplayed sinceDate:[NSDate date]]];  // Store the time we started. We'll be keying off of this to maintain accuracy. We decrement any currently displayed time.
        [[self timeDisplay] setBlinkSeparators:YES];    // The blinking separators indicate that the timer is running.
        [self _gimmeASec];
        }
    else if ( !timerOn && _timerOn )
        {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [[self timeDisplay] setBlinkSeparators:NO];
        [[[LGV_AppDelegate appDelegate] application] setIdleTimerDisabled:NO];  // Make sure this is turned off.
        }
    
    _timerOn = timerOn;
}

/*********************************************************/
/**
 \brief This is a callback that decrements the time by 1 second.
 */
- (void)_decrementTimer
{
    if ( [self startTime] )
        {
        NSInteger   secondsToGo = [self _setCorrectTime];
        
        if ( ![self gameOverCalled] && (secondsToGo <= 0) )  // Time's up if we haven't nuked the current time yet.
            {
            [self setGameOverCalled:YES];   // Set this quickly, just to stop any thread issues.
            // Call the handler in the main thread, as there will be UI.
            [self performSelectorOnMainThread:@selector(_gameOverMan) withObject:nil waitUntilDone:NO];
            }
        
        if ( !((secondsToGo <= 0) && [self quietMode]) )    // Quiet mode stops at 0.
            {
            [self _gimmeASec];   // Otherwise, we keep going, and going, and going...BAM BAM BAM....
            }
        
        // Set the stored current time to our displayed time.
        [self setCurrentTime:[[self class] createDateFromHours:(int)[[self timeDisplay] hoursValue] andMinutes:(int)[[self timeDisplay] minutesValue] andSeconds:(int)[[self timeDisplay] secondsValue]]];
        
        // Make sure that the threshold indicators are set properly.
        if ( [self quietMode] && ![self gameOverCalled] )
            {
            [self performSelectorOnMainThread:@selector(_setThresholdDisplayState) withObject:nil waitUntilDone:NO];
            }
        }
}

/*********************************************************/
/**
 \brief This sets the displayed time to the one calculated
        as a delta from the start time.
 \returns the number of seconds left in the timer.
 */
- (NSInteger)_setCorrectTime
{
    NSInteger   secondsToGo = 0;
    
    if ( [self startTime] )
        {
        NSDate      *myStartTime = [self startTime];
        secondsToGo = -round ( [[NSDate date] timeIntervalSinceDate:myStartTime] );
        
        secondsToGo = MAX ( -3599, secondsToGo );   // We can't go to an hour if we are counting backward.
        
        NSInteger   seconds = ABS (secondsToGo);
        
        NSInteger hours = seconds / 3600;
        
        seconds -= (hours * 3600);
        
        NSInteger minutes = seconds / 60;
        
        seconds -= (minutes * 60);
        
        [[self timeDisplay] setHoursValue:hours];
        [[self timeDisplay] setMinutesValue:minutes];
        [[self timeDisplay] setSecondsValue:seconds];
        
#ifdef DEBUG
        NSLog ( @"setCorrectTime: %ld seconds left.", (long)secondsToGo );
#endif
        }
    
    return secondsToGo;
}

/*********************************************************/
/**
 \brief This sets up a timer to call the decrementer in 1 second.
 */
- (void)_gimmeASec
{
    [self _setThresholdDisplayState];
    [self performSelector:@selector(_decrementTimer) withObject:nil afterDelay:1.0];    // Exactly 1 second.
    [[LGV_AppDelegate appDelegate] updateNetworkData:self];
}

/*********************************************************/
/**
 \brief Sets up the display for the threshold lights.
 */
- (void)_setThresholdDisplayState
{
    NSTimeInterval      currentTimeSec = [self _currentDisplayedTimeInSeconds];
    
    NSDateComponents    *comp = [LGV_TimerSettingsViewController createComponentsFromDate:[self warningTime]];
    NSTimeInterval      warningThresholdSec = ([comp hour] * 60 * 60) + ([comp minute] * 60) + [comp second];
    
    comp = [LGV_TimerSettingsViewController createComponentsFromDate:[self finalTime]];
    NSTimeInterval      finalThresholdSec = ([comp hour] * 60 * 60) + ([comp minute] * 60) + [comp second];
    
    if ( [self timerOn] && (currentTimeSec <= finalThresholdSec) )
        {
        [self _redState];
        }
    else if ( [self timerOn] && (currentTimeSec <= warningThresholdSec) )
        {
        [self _yellowState];
        }
    else
        {
        [self _greenState];
        }
}

/*********************************************************/
/**
 \brief Turn everything off.
 */
- (void)_offState
{
    [[self greenPodiumLight] setLowColor:k_LGV_Quiet_Mode_Green_Dark_Low];
    [[self greenPodiumLight] setHighColor:k_LGV_Quiet_Mode_Green_Dark_High];
    
    [[self yellowPodiumLight] setLowColor:k_LGV_Quiet_Mode_Yellow_Dark_Low];
    [[self yellowPodiumLight] setHighColor:k_LGV_Quiet_Mode_Yellow_Dark_High];
    
    [[self redPodiumLight] setLowColor:k_LGV_Quiet_Mode_Red_Dark_Low];
    [[self redPodiumLight] setHighColor:k_LGV_Quiet_Mode_Red_Dark_High];
    
    [[self greenPodiumLight] setAlpha:0.4];
    [[self yellowPodiumLight] setAlpha:0.4];
    [[self redPodiumLight] setAlpha:0.4];
    
    [[self greenPodiumLight] setEnabled:NO];
    [[self yellowPodiumLight] setEnabled:NO];
    [[self redPodiumLight] setEnabled:NO];
    
    [[self greenPodiumLight] setCornerRadius:([[self greenPodiumLight] bounds].size.width / 20)];
    [[self yellowPodiumLight] setCornerRadius:([[self yellowPodiumLight] bounds].size.width / 20)];
    [[self redPodiumLight] setCornerRadius:([[self redPodiumLight] bounds].size.width / 20)];
}

/*********************************************************/
/**
 \brief Do whatever needs doing when the normal state is in session.
 */
- (void)_greenState
{
    [self _offState];
    [[self greenPodiumLight] setLowColor:k_LGV_Quiet_Mode_Green_Light_Low];
    [[self greenPodiumLight] setHighColor:k_LGV_Quiet_Mode_Green_Light_High];
    [[self greenPodiumLight] setAlpha:1.0];
}

/*********************************************************/
/**
 \brief Do whatever needs doing when the warning threshold has been crossed.
 */
- (void)_yellowState
{
    [self _offState];
    [[self yellowPodiumLight] setLowColor:k_LGV_Quiet_Mode_Yellow_Light_Low];
    [[self yellowPodiumLight] setHighColor:k_LGV_Quiet_Mode_Yellow_Light_High];
    [[self yellowPodiumLight] setAlpha:1.0];
}

/*********************************************************/
/**
 \brief Do whatever needs doing when the final rubicon has been crossed.
 */
- (void)_redState
{
    [self _offState];
    [[self redPodiumLight] setLowColor:k_LGV_Quiet_Mode_Red_Light_Low];
    [[self redPodiumLight] setHighColor:k_LGV_Quiet_Mode_Red_Light_High];
    [[self redPodiumLight] setAlpha:1.0];
}

/*********************************************************/
/**
 \brief Called when the timer is complete.
 */
- (void)_gameOverMan
{
    if ( [self quietMode] )
        {
        [[self class] cancelPreviousPerformRequestsWithTarget:self];
        [self _flashRedOFF];
        }
    else
        {
        [self _playAlertSound];
        }
}

/*********************************************************/
/**
 \brief Called when the timer is complete in digital mode.
 */
- (void)_playAlertSound
{
    if ( 1 < [self completionVolume] )  // See if we are to play a sound. We blink the numbers, otherwise.
        {
        NSString    *soundFileName = @"Beep_01";  // Get the selected sound file name.
        [self _setBeepSoundByName:soundFileName];
        }
    else
        {
        AudioServicesDisposeSystemSoundID ( [self beep_sound] );    // We dispose of these, if we aren't using them.
        [self setBeep_sound:0];
        [self setBeep_sound_url:nil];
        }
    
    beepCount = 0;
    oldColor = [[self timeDisplay] elementColorOn];
    [self _playBeepAndAgain];
}

/*********************************************************/
/**
 \brief This function plays beeps in "bursts" of 2.
 */
- (void)_playBeepAndAgain
{
    float   delay = s_beepingInterval * 1.5;
    UIColor *setColor = [UIColor redColor];
    
    if ( 0 == (beepCount++ % 2) )
        {
        delay = s_beepingInterval;
        setColor = oldColor;
        
        if ( 0 < [self completionVolume] )  // See if we are to play a sound.
            {
            SystemSoundID soundID = [self beep_sound];
            
            if ( ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) && ([self completionVolume] == 1) )
                {
                soundID = kSystemSoundID_Vibrate;
                }
            
            AudioServicesPlayAlertSound ( soundID );
            }
        }
    
    [[self timeDisplay] performSelectorOnMainThread:@selector(setElementColorOn:) withObject:setColor waitUntilDone:NO];
    [self performSelector:@selector(_playBeepAndAgain) withObject:nil afterDelay:delay];
}

/*********************************************************/
/**
 \brief Sets up the beep sound.
        It takes the name of a WAV (.wav) file, with no extension.
        The file MUST be a .wav file.
 */
- (void)_setBeepSoundByName:(NSString *)inFileName  ///< The non-extension name of a .wav (WAV) file.
{
    // We need to a bridged retain and release, here.
    
    // We get rid of any previous resources, first.
    if ( [self beep_sound_url] )
        {
        [self setBeep_sound_url:nil];
        }
    
    if ( [self beep_sound] )
        {
        AudioServicesDisposeSystemSoundID ( [self beep_sound] );
        [self setBeep_sound:0];
        }
    
    // We set up the new sound ID and resource, by loading our file.
    [self setBeep_sound_url:[[NSBundle mainBundle] URLForResource: inFileName
                                                    withExtension: @"wav"]];
    AudioServicesCreateSystemSoundID ( (__bridge CFURLRef)[self beep_sound_url ], &_beep_sound );

    UInt32      value = 0;
    
    OSStatus    err = AudioServicesSetProperty ( kAudioServicesPropertyIsUISound, 0, nil, sizeof ( UInt32 ), (void*)&value );
    
    if ( err != kAudioServicesNoError )
        {
        }
}

/*********************************************************/
/**
 \brief This is one half of the "flashing done light" behavior.
        This function turns the "light" "off."
 */
- (void)_flashRedOFF
{
    [self _offState];
    [self performSelector:@selector(_flashRedON) withObject:nil afterDelay:s_flashingInterval];
}

/*********************************************************/
/**
 \brief This is the other half of the "flashing done light" behavior.
        This function turns the "light" "on."
 */
- (void)_flashRedON
{
    [self _redState];
    [self performSelector:@selector(_flashRedOFF) withObject:nil afterDelay:s_flashingInterval];
}

/*********************************************************/
/**
 \brief Sets up the window, according to the settings.
 */
- (void)_setUpWindow
{
    if ( [self quietMode] )
        {
        [[self greenPodiumLight] setLowColor:k_LGV_Quiet_Mode_Green_Dark_Low];
        [[self greenPodiumLight] setHighColor:k_LGV_Quiet_Mode_Green_Dark_High];
        
        [[self yellowPodiumLight] setLowColor:k_LGV_Quiet_Mode_Yellow_Dark_Low];
        [[self yellowPodiumLight] setHighColor:k_LGV_Quiet_Mode_Yellow_Dark_High];
        
        [[self redPodiumLight] setLowColor:k_LGV_Quiet_Mode_Red_Dark_Low];
        [[self redPodiumLight] setHighColor:k_LGV_Quiet_Mode_Red_Dark_High];
        }
    
    [[self timeDisplay] setHidden:[self quietMode]];
    [[self podiumTimerView] setHidden:![self quietMode]];
    [self setTimerDisplayToCurrentTime];
}

@end
