//
//  A_LGV_DigitalPanel.h
//  A_LGV_DigitalPanel
/// \version 1.0.3
//
//  Created by Chris Marshall on 7/4/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A_LGV_DigitUIView.h"

/*********************************************************/
/**
 \class A_LGV_DigitalPanel
 \brief This is an abstract base class that handles the arrangement
        and display of a group of digital panes. Each pane displays
        one digit of a large integer number. If the number is negative,
        then the most significant digital value will be a minus sign.
        It will scale the contained views to completely fill the panel,
        so this should be kept in mind while laying out the panel.
 */
@interface A_LGV_DigitalPanel : UIView
@property (nonatomic, readwrite)    NSInteger       gap;            ///< This is the gap (in pixels) between each digit.
@property (nonatomic, readwrite)    NSInteger       base;           ///< The numerical base for the display (2 - 16, default is 10).
@property (nonatomic, readwrite)    NSInteger       value;          ///< The numerical value to be displayed. This will be converted to the base for display.
@property (nonatomic, readwrite)    NSInteger       numberOfDigits; ///< The number of digits represented by this panel.
@property (nonatomic, readwrite)    BOOL            negativeOnly;   ///< Set to YES, if the display is a simple minus sign.

- (void)setDigitValues;                     ///< Sets the digit values.
- (A_LGV_DigitUIView *)makeANewDigitViewWithFrame:(CGRect)inFrame;   ///< Factory method for a new subview.
- (int)maxValue;                            ///< Returns the maximum possible value of the panel.
- (int)minValue;                            ///< Returns the minimum possible value of the panel.
- (void)displayNegativeOnly;                ///< If this is called, the display will blank out all the displays, except the rightmost one, which will be a minus sign.
@end
