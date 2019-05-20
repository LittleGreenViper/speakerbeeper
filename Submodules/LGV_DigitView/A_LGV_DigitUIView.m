//
//  A_LGV_DigitUIView.m
//  A_LGV_DigitUIView
/// \version 1.0.2
//
//  Created by Chris Marshall on 6/26/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import "A_LGV_DigitUIView.h"

/*********************************************************/
/**
 \class A_LGV_DigitUIView
 \brief This is an abstract class for a displayed digit.
        The minimum value is 0. The maximum value is 16.
        Negative values result in the display of only a minus sign.
        16 turns the number off completely.
 */
@implementation A_LGV_DigitUIView
@synthesize value = _value;

/*********************************************************/
/**
 \brief sets the digit value. Also triggers a redraw.
        This class cannot have a displayed value more than 15, 16 means it is completely off, and -1 means a minus sign.
 */
- (void)setValue:(NSInteger)in_value
{
    _value = MAX( -1, MIN ( 16, in_value ) );
    
    [self setNeedsLayout];  // We use a layout event to set up the number.
}
@end
