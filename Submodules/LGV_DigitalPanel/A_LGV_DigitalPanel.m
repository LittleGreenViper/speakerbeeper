//
//  LGV_DigitalPanel.m
//  LGV_DigitalPanel
/// \version 1.0.3
//
//  Created by Chris Marshall on 7/4/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import "A_LGV_DigitalPanel.h"

static int s_A_LGV_DigitalPanelGap = 8;         ///< The default gap between digits, in pixels.
static int s_A_LGV_DigitalPanelBase = 10;       ///< The default base for this pane.
static int s_A_LGV_DigitalPanelNumDigits = 2;   ///< The default number of digits.

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
@implementation A_LGV_DigitalPanel
@synthesize base = _base, value = _value, numberOfDigits = _numberOfDigits, gap = _gap, negativeOnly = _negativeOnly;

/*********************************************************/
/**
 \brief This is the gap (in pixels) between digits in the panel.
 */
- (void)setGap:(NSInteger)inGap     ///< The new gap.
{
    _gap = inGap;
    [self setNeedsLayout];
}

/*********************************************************/
/**
 \brief Sets the base of the panel, and triggers a redraw.
 */
- (void)setBase:(NSInteger)inBase   ///< The new base. 2 - 16.
{
    _base = inBase;
    [self setNeedsLayout];
}

/*********************************************************/
/**
 \brief Sets the mumber of digits for the panel, and triggers a redraw.
 */
- (void)setNumberOfDigits:(NSInteger)inNumDigits    ///< How many digits to use.
{
    _numberOfDigits = inNumDigits;
    
    if ( [[self subviews] count] )
        {
        for ( UIView *theSubView in [self subviews] )
            {
            [theSubView removeFromSuperview];
            }
        }

    [self setNeedsLayout];
}

/*********************************************************/
/**
 \brief Sets the value of the panel, and triggers a redraw.
 */
- (void)setValue:(NSInteger)inValue ///< The new value of the panel.
{
    _value = MAX ( [self minValue], MIN ( [self maxValue], inValue ) );
    [self setDigitValues];  // Set the values of the digits.
}

/*********************************************************/
/**
 \brief If this is called, the display will blank out all
        the displays, except the rightmost one, which will be a minus sign.
 */
- (void)displayNegativeOnly
{
#ifdef DEBUG
    NSLog(@"A_LGV_DigitUIView::displayNegativeOnly There are %lu subviews in this object.", (unsigned long)[[self subviews] count] );
#endif
    [self setNegativeOnly:YES];
    [self setDigitValues];  // Set the values of the digits.
}

/*********************************************************/
/**
 \brief This is where most of the action occurs. The subviews
        are instantiated and added to this view at this time,
        replacing any previous ones.
        We track the digits in the subviews of this view.
 */
- (void)layoutSubviews
{
    // We only need to do this once.
    if ( [[self subviews] count] == 0 )
        {
        // If we don't have a gap set, we set the default, here.
        if ( [self gap] <= 0 )
            {
            _gap = s_A_LGV_DigitalPanelGap;
            }
        
        // Same with the base
        if ( ([self base] < 2) || ([self base] > 16) )
            {
            _base = s_A_LGV_DigitalPanelBase;
            }
        
        // And the number of digits
        if ( ![self numberOfDigits] )
            {
            _numberOfDigits = s_A_LGV_DigitalPanelNumDigits;
            }
        
        // We divide the size of this control by the number of digits, in order to fit them.
        CGRect  subBounds = [self bounds];
        subBounds.size.width += [self gap]; // This allows us to avoid a gap at the end of the row.
        subBounds.size.width /= [self numberOfDigits];  // We divide into enough room for each digit.
        subBounds.size.width -= [self gap]; // The inside of the row is separated by gaps.
        
        // Add the new digits. The first view will be the most significant digit (or minus sign), and the last will be the least significant digit.
        for ( int c = 0; c < [self numberOfDigits]; c++ )
            {
            // We walk the digits across the container view, scaling them to fit.
            [self addSubview:[self makeANewDigitViewWithFrame:subBounds]];
            subBounds.origin.x += subBounds.size.width + [self gap];
            }
        }

    [self setDigitValues];  // Set the values of the digits.
}

/*********************************************************/
/**
 \brief Sets the value of each digit.
        This is done by repeatedly diving the value by the
        base, and extracting each digit.
 */
- (void)setDigitValues
{
#ifdef DEBUG
    NSLog(@"A_LGV_DigitUIView::setDigitValues There are %lu subviews in this object.", (unsigned long)[[self subviews] count] );
#endif
    if ( [self negativeOnly] )
        {
        for ( int c = ([self value] < 0) ? 1 : 0; c < [[self subviews] count]; c++ )    // Walk through each of the digits.
            {
            if ( c == ([[self subviews] count] - 1) )   // If we are at the last place...
                {
                [(A_LGV_DigitUIView *)[[self subviews] objectAtIndex:c] setValue:-1];   // This makes the digit display a minus sign.
                }
            else
                {
                [(A_LGV_DigitUIView *)[[self subviews] objectAtIndex:c] setValue:16];   // This blanks the display.
                }
            }
        }
    else
        {
        NSInteger   digNum = [self numberOfDigits] - ([self value] < 0 ? 1 : 0);    // We may need to use the first digit as a minus sign.
        
        // We determine the digit values by walking backwards through the base.
        float   baseDivider = powf( [self base], digNum - 1 );
        
        NSInteger currentValue = ABS([self value]);    // We will start with the full value (absolute).
        
        // If we are negative, then the first digit will be a minus sign.
        if ( [self value] < 0 )
            {
            [(A_LGV_DigitUIView *)[[self subviews] objectAtIndex:0] setValue:-1];
            }
        
        // Walk through the digits, accounting for the one that may be used for a minus sign.
        for ( int c = ([self value] < 0) ? 1 : 0; c < [[self subviews] count]; c++ )
            {
            NSInteger digitValue = (int)(currentValue / baseDivider); // Get the digit value as an int.
            digitValue = MIN(digitValue, [self base] - 1);
            currentValue -= (digitValue * baseDivider); // Reduce the total by that value, multipled by the base multiplier.
            baseDivider /= [self base];  // Reduce the base multiplier for the next digit.
            [(A_LGV_DigitUIView *)[[self subviews] objectAtIndex:c] setValue:digitValue];
#ifdef DEBUG
            NSLog(@"A_LGV_DigitUIView::setDigitValues Setting the subview at %d with the value %ld.", c, (long)digitValue );
#endif
            }
        }
}

/*********************************************************/
/**
 \brief Returns the maximum possible value of the panel,
        based on the base, and the number of digits.
 \returns the maximum possible value (always positive).
 */
- (int)maxValue
{
    // If we don't yet have a base, we set the default.
    if ( ([self base] < 2) || ([self base] > 16) )
        {
        _base = s_A_LGV_DigitalPanelBase;
        }
    
    // And the number of digits
    if ( ![self numberOfDigits] )
        {
        _numberOfDigits = s_A_LGV_DigitalPanelNumDigits;
        }
    
    // The maximum value is one less than too much.
    return (powf( [self base], [self numberOfDigits] )) - 1;
}

/*********************************************************/
/**
 \brief Returns the minimum possible value of the panel,
        based on the base, and the number of digits.
        Remember that a negative number uses the most
        significant digit, so the range will be lower
        for the minimum than for the maximum.
 \returns the minimum possible value (will usually be negative).
 */
- (int)minValue
{
    int ret = [self maxValue];  // Start with our maximum value.
    
    ret /= [self base]; // Decrement one base factor for the negative sign.
    
    // We simply return the negative of the number. If we only have 1 digit, then that number is zero.
    return -ret;
}

/*********************************************************/
/**
 \brief Returns a new digit view. Requires subclassing.
        This method must be overridden by concrete subclasses.
 \returns a subclass of A_LGV_DigitUIView. The base class (this one) returns nil.
*/
- (A_LGV_DigitUIView *)makeANewDigitViewWithFrame:(CGRect)inFrame    ///< The frame of the new object.
{
    return nil; // The base class returns nada.
}
@end
