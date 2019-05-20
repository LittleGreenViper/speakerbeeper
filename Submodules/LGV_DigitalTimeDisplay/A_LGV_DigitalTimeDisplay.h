//
//  A_LGV_DigitalTimeDisplay.h
//  A_LGV_DigitalTimeDisplay
/// \version 1.0.6
//
//  Created by Chris Marshall on 7/7/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A_LGV_DigitalPanel.h"

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
@interface A_LGV_DigitalTimeDisplay : UIView
@property (retain, nonatomic, readwrite) A_LGV_DigitalPanel *hours;                         ///< This will display the hours. It will always be 2 digits.
@property (retain, nonatomic, readwrite) UIView             *hours_minutes_separator;       ///< This separates the hours from the minutes.
@property (retain, nonatomic, readwrite) A_LGV_DigitalPanel *minutes;                       ///< This will display the minutes. It will always be 2 digits.
@property (retain, nonatomic, readwrite) UIView             *minutes_seconds_separator;     ///< This separates the minutes from the hours.
@property (retain, nonatomic, readwrite) A_LGV_DigitalPanel *seconds;                       ///< This will display the seconds. It will always be 2 digits.
@property (nonatomic, readwrite)         NSInteger          separatorWidth;                 ///< The width of the separator views.
@property (nonatomic, readwrite)         NSInteger          secondsValue;                   ///< The seconds Display value (can be directly set)
@property (nonatomic, readwrite)         NSInteger          minutesValue;                   ///< The minutes Display value (can be directly set)
@property (nonatomic, readwrite)         NSInteger          hoursValue;                     ///< The hours Display value (can be directly set)

- (A_LGV_DigitalPanel *)makePanelInstanceWithFrame:(CGRect)frame;   ///< This is a routine that needs to be overridden by subclasses.
- (UIView *)makeNewSeparatorView:(CGRect)inRect;                    ///< This allows the subclass to generate a view with the separator.
- (void)setDisplayedTime;                                           ///< This sets up the displayed time from the property.
- (void)setTime:(NSDate *)time;                                     ///< This sets the display to the hours, minutes and seconds of the given time date.
@end
