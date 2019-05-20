//
//  LGV_LEDDigitalTimeDisplay.m
//  LGV_LEDDigitalTimeDisplay
/// \version 1.0.6
//
//  Created by Chris Marshall on 7/7/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import "LGV_LEDDigitalTimeDisplay.h"
#import "LGV_LEDDigitalPanel.h"
#import <QuartzCore/QuartzCore.h>

static const float  s_blinkFrequencyInSeconds = 0.25;    ///< The blinking frequency.

/*********************************************************/
/**
 \class LGV_LEDDigitalTimeDisplay (Private Declarations)
 */
@interface LGV_LEDDigitalTimeDisplay ()
{
    BOOL            blinkOff;   ///< If this is ON, then the "off" state color is used for the blinking.
    NSMutableArray  *blinkers;  ///< These are the separators. We keep them on hand to allow us to access them at blink time.
}
- (void)blinkCallBack;  ///< Used to set the color for the blinking.
@end

/*********************************************************/
/**
 \class LGV_LEDDigitalPanelSeparator
 \brief This view will represent a "colon" separator for the
        clock display. Its main purpose for existence is
        to make sure the path doesn't leak.
 */
@implementation LGV_LEDDigitalPanelSeparator
@synthesize myShapes;

/*********************************************************/
/**
 \brief Initializer with rect and color.
 \returns self
 */
- (id)initWithFrame:(CGRect)inRect          ///< This is the rectangle that is expected for the whole separator.
         andOnColor:(UIColor *)inColorOn    ///< If the separator is blinking, then this is its "on" color.
{
    self = [super initWithFrame:inRect];
    
    if ( self )
        {
        myShapes = [CAShapeLayer layer];
        
        CGMutablePathRef    thePath = CGPathCreateMutable ();
        
        CGRect  rect1 = inRect;
        rect1.origin = CGPointZero;
        rect1.size.height = rect1.size.width;
        rect1.origin.x = (rect1.size.width / 2);
        
        CGRect  rect2 = rect1;
        
        inRect.size.width *= 2;
        
        rect1.origin.y = (inRect.size.height / 3) - (rect1.size.height / 2);
        rect2.origin.y = ((inRect.size.height * 2) / 3) - (rect2.size.height / 2);
        
        CGPathAddRect(thePath, nil, rect1);
        CGPathAddRect(thePath, nil, rect2);
        
        [myShapes setPath:thePath];
        
        CGPathRelease ( thePath );
        
        [myShapes setFillColor:[inColorOn CGColor]];
        
        [self setFrame:inRect];
        
        [[self layer] addSublayer:myShapes];
        }
    
    return self;
}

@end

/*********************************************************/
/**
 \class LGV_LEDDigitalTimeDisplay
 \brief This is a concrete class that creates a dynamically
        drawn "LED" display for the time display.
        This class uses the Quartz Core framework.
 */
@implementation LGV_LEDDigitalTimeDisplay
@synthesize elementColorOn = _elementColorOn, elementColorOff = _elementColorOff, blinkSeparators;

/*********************************************************/
/**
 \brief This creates a view that has a colon (2 dots) in it.
 \returns A new UIView, containing the separator.
 */
- (UIView *)makeNewSeparatorView:(CGRect)inRect ///< The recommended rect. The command can ignore it.
{
    LGV_LEDDigitalPanelSeparator    *theView = [[LGV_LEDDigitalPanelSeparator alloc] initWithFrame:inRect andOnColor:[self elementColorOn]];
    
    if ( !blinkers )
        {
        blinkers = [[NSMutableArray alloc] initWithObjects:theView, nil];
        }
    else
        {
        [blinkers addObject:theView];
        }
    
    return theView;
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
    LGV_LEDDigitalPanel     *ret = [[LGV_LEDDigitalPanel alloc] initWithFrame:frame];
    
    [ret setElementColorOn:[self elementColorOn]];
    [ret setElementColorOff:[self elementColorOff]];
    
    return ret;
}

/*********************************************************/
/**
 \brief Set the "on" color for the element.
 */
- (void)setElementColorOn:(UIColor *)inColor    ///< The color to be set.
{
    _elementColorOn = inColor;
    [self setNeedsLayout];
}

/*********************************************************/
/**
 \brief Set the "off" color for the element.
 */
- (void)setElementColorOff:(UIColor *)inColor   ///< The color to be set.
{
    _elementColorOff = inColor;
    [self setNeedsLayout];
}

/*********************************************************/
/**
 \brief Blinks the separators.
 */
- (void)setBlinkSeparators:(BOOL)isBlinking ///< If YES, then start blinking. If NO, stop, and set the state to "on".
{
    for ( LGV_LEDDigitalPanelSeparator *theSeparator in blinkers )
        {
        [[theSeparator myShapes] setFillColor:[[self elementColorOn] CGColor]];
        }
    
    if ( isBlinking )
        {
        [self performSelector:@selector(blinkCallBack) withObject:nil afterDelay:s_blinkFrequencyInSeconds];
        blinkOff = NO;
        }
    else
        {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        blinkOff = YES;
        }
}

/*********************************************************/
/**
 \brief Blinks the separators.
 */
- (void)blinkCallBack
{
    for ( LGV_LEDDigitalPanelSeparator *theSeparator in blinkers )
        {
        if ( blinkOff )
            {
            [[theSeparator myShapes] performSelectorOnMainThread:@selector(setFillColor:) withObject:(id)[[self elementColorOn] CGColor] waitUntilDone:NO];
            }
        else
            {
            [[theSeparator myShapes] performSelectorOnMainThread:@selector(setFillColor:) withObject:(id)[[self elementColorOff] CGColor] waitUntilDone:NO];
            }
        }
    
    blinkOff = !blinkOff;
    [self performSelector:@selector(blinkCallBack) withObject:nil afterDelay:s_blinkFrequencyInSeconds];
}

@end
