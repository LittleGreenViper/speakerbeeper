//
//  A_LGV_DigitalTimeDisplay.m
//  A_LGV_DigitalTimeDisplay
/// \version 1.0.6
//
//  Created by Chris Marshall on 7/7/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import "A_LGV_DigitalTimeDisplay.h"

static int  s_LGV_DigitalTimeDisplay_DefaultSeparatorWidth = 30;    ///< A divisor for the separator width.

/*********************************************************/
/**
 \class A_LGV_DigitalTimeDisplay
 \brief This class presents a self-contained digital time
        display in a single UIView object.
        This is an abstract base class. It is meant to be
        subclassed to present specific display types.
        The class will display the hours, minutes and seconds
        from a supplied NSDate object, and will update
        immediately upon receiving the latest date.
*/
@implementation A_LGV_DigitalTimeDisplay
@synthesize hours, hours_minutes_separator, minutes, minutes_seconds_separator, seconds, separatorWidth, secondsValue = _secondsValue, minutesValue = _minutesValue, hoursValue = _hoursValue;

/*********************************************************/
/**
 \brief This allows subclasses to return a custom UIView to separate the groups of numbers.
 \returns A new UIView, containing the separator.
 */
- (UIView *)makeNewSeparatorView:(CGRect)inRect ///< The recommended rect. The command can ignore it.
{
    return nil;
}

/*********************************************************/
/**
 \brief This actually instantiates and sets up the various
        subviews that make up the display.
 */
- (void)layoutSubviews
{
        // We first clear out any previous instances.
    [[self hours] removeFromSuperview];
    [[self minutes] removeFromSuperview];
    [[self seconds] removeFromSuperview];
    [[self minutes_seconds_separator] removeFromSuperview];
    [[self hours_minutes_separator] removeFromSuperview];
    
    [self setHours:nil];
    [self setMinutes:nil];
    [self setSeconds:nil];
    [self setMinutes_seconds_separator:nil];
    [self setHours_minutes_separator:nil];
    
    // We dynamically size the components to fit in our rect.
    CGRect  subRect = [self bounds];
    
    CGRect  sRect = subRect;
    
    [self setSeparatorWidth:[self bounds].size.width / s_LGV_DigitalTimeDisplay_DefaultSeparatorWidth];
    
    sRect.size.width = [self separatorWidth];
    
    [self setHours_minutes_separator:[self makeNewSeparatorView:sRect]];
    [self setMinutes_seconds_separator:nil];
    
    if ( [self hours_minutes_separator] )
        {
        [self setSeparatorWidth:[[self hours_minutes_separator] bounds].size.width];
        [self setMinutes_seconds_separator:[self makeNewSeparatorView:sRect]];
        }
    else
        {
        // If we don't have a separator width, we use the default.
        if ( [self separatorWidth] <= 0 )
            {
            [self setSeparatorWidth:[self bounds].size.width / s_LGV_DigitalTimeDisplay_DefaultSeparatorWidth];
            }
        }
    
    // Account for the separators.
    int subWidth = subRect.size.width - ([self separatorWidth] * 2);
    
    subWidth /= 3;  // We have 3 separate panels.
    
    subRect.size.width = subWidth;
    
    // Set the three submodule instances.
    [self setHours:[self makePanelInstanceWithFrame:subRect]];
    
    // Increment to the next panel
    subRect.origin.x += subWidth;
    
    sRect.origin.x = subRect.origin.x;
    
    [[self hours_minutes_separator] setFrame:sRect];
    
    // Increment to the next panel
    subRect.origin.x += [self separatorWidth];
    
    [self setMinutes:[self makePanelInstanceWithFrame:subRect]];
    
    // Increment to the next panel
    subRect.origin.x += subWidth;
    
    sRect.origin.x = subRect.origin.x;
    
    [[self minutes_seconds_separator] setFrame:sRect];

    subRect.origin.x += [self separatorWidth];
    
    [self setSeconds:[self makePanelInstanceWithFrame:subRect]];
    
    // Add the views as our new panels.
    [self addSubview:[self hours]];
    if ( [self hours_minutes_separator] )
        {
        [self addSubview:[self hours_minutes_separator]];
        }
    [self addSubview:[self minutes]];
    if ( [self minutes_seconds_separator] )
        {
        [self addSubview:[self minutes_seconds_separator]];
        }
    [self addSubview:[self seconds]];

    [self setDisplayedTime];
}

/*********************************************************/
/**
 \brief This sets up the displayed time from the property.
 */
- (void)setDisplayedTime
{
    [[self seconds] setValue:[self secondsValue]];
    [[self minutes] setValue:[self minutesValue]];
    [[self hours] setValue:[self hoursValue]];
}

/*********************************************************/
/**
 \brief This sets a time to be displayed. It forces an update.
 */
- (void)setTime:(NSDate *)time  ///< The date for the displayed time.
{
    if ( time ) // If we don't have a date, then we can't set the time.
        {
        NSCalendar          *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents    *timeComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:time];
        
#ifdef DEBUG
        NSLog ( @"setTime Hours: %ld, Minutes: %ld, Seconds: %ld.", (long)[timeComponents hour], (long)[timeComponents minute], (long)[timeComponents second] );
#endif
        
        [self setSecondsValue:[timeComponents second]];
        [self setMinutesValue:[timeComponents minute]];
        [self setHoursValue:[timeComponents hour]];
        }
    else
        {
        [self setSecondsValue:0];
        [self setMinutesValue:0];
        [self setHoursValue:0];
        }
}

/*********************************************************/
/**
 \brief This sets the direct value for the seconds panel display.
 */
- (void)setSecondsValue:(NSInteger)inputVal   ///< The value to be set.
{
    _secondsValue = inputVal;
    [[self seconds] setValue:inputVal];
}

/*********************************************************/
/**
 \brief This sets the direct value for the minutes panel display.
 */
- (void)setMinutesValue:(NSInteger)inputVal   ///< The value to be set.
{
    _minutesValue = inputVal;
    [[self minutes] setValue:inputVal];
}

/*********************************************************/
/**
 \brief This sets the direct value for the hours panel display.
 */
- (void)setHoursValue:(NSInteger)inputVal   ///< The value to be set.
{
    _hoursValue = inputVal;
    [[self hours] setValue:inputVal];
}

/*********************************************************/
/**
 \brief This is a routine that needs to be overridden by subclasses.
        The subclass uses this to return a new instance of the
        conrete panel to be used.
        The base class returns nil.
 */
- (A_LGV_DigitalPanel *)makePanelInstanceWithFrame:(CGRect)frame    ///< The frame to use.
{
    return nil;
}

@end
