//
//  LGV_LEDDigitalPanel.m
//  LGV_DigitalPanel
/// \version 1.0.3
//
//  Created by Chris Marshall on 7/5/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import "LGV_LEDDigitalPanel.h"
#import "LGV_DynLEDDigitUIView.h"

@implementation LGV_LEDDigitalPanel
@synthesize elementColorOn = _elementColorOn, elementColorOff = _elementColorOff;

/*********************************************************/
/**
 \brief Returns a new digit view. Allows subclassing.
 This method must be overridden by concrete subclasses.
 \returns a subclass of A_LGV_DigitUIView. The base class (this one) returns nil.
 */
- (A_LGV_DigitUIView *)makeANewDigitViewWithFrame:(CGRect)inFrame
{
    LGV_DynLEDDigitUIView   *ret = [[LGV_DynLEDDigitUIView alloc] initWithFrame:inFrame];
    
    [ret setElementColorOn:[self elementColorOn]];
    [ret setElementColorOff:[self elementColorOff]];
    
    return ret;
}

- (void)setElementColorOn:(UIColor *)inColor
{
    _elementColorOn = inColor;
    [self setNeedsLayout];
}

- (void)setElementColorOff:(UIColor *)inColor
{
    _elementColorOff = inColor;
    [self setNeedsLayout];
}

@end
