//
//  LGV_SimpleRoundedRectButton.m
//  LGV_SimpleRoundedRectButton
/// \version 1.0.3
//
//  Created by Chris Marshall on 8/9/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//
/*********************************************************/
/**
 \file LGV_SimpleRoundedRectButton.m
 \brief Implements a simple, rounded-rect gradient shape.
 */

#import "LGV_SimpleRoundedRectButton.h"
#import <QuartzCore/QuartzCore.h>

/*********************************************************/
/**
 \class LGV_SimpleRoundedRectButton (Private Interface)
 \brief Implements a simple, rounded-rect gradient shape.
 */
@interface LGV_SimpleRoundedRectButton ()
{
    CAGradientLayer *gradientLayer;
    CAGradientLayer *glassEffectLayer;
}
@end

/*********************************************************/
/**
 \class LGV_SimpleRoundedRectButton
 \brief Implements a simple, rounded-rect gradient button.
 */
@implementation LGV_SimpleRoundedRectButton

@synthesize cornerRadius = _cornerRadius;
@synthesize borderWidth = _borderWidth;
@synthesize highColor = _highColor;
@synthesize lowColor = _lowColor;
@synthesize glassEffect = _glassEffect;

/*********************************************************/
/**
 \brief Sets up the control.
 */
- (void)awakeFromNib
{
    [self setHighColor:[UIColor whiteColor]];
    [self setLowColor:[UIColor darkGrayColor]];
    
    [self setBorderWidth:s_LGV_SimpleRoundedRectButton_DefaultBorderWidth];
    [self setCornerRadius:s_LGV_SimpleRoundedRectButton_DefaultCornerRadius];
    
    [[self layer] setMasksToBounds:YES];
    
    gradientLayer = [[CAGradientLayer alloc] init];
    
    [[self layer] insertSublayer:gradientLayer atIndex:0];
}

/*********************************************************/
/**
 \brief We need to redisplay, if we are relaying the subviews.
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsDisplay];
}

/*********************************************************/
/**
 \brief Set a background color, which wipes out the previous gradient,
        and sets the color as a flat color.
 */
- (void)setBackgroundColor:(UIColor *)color ///< The color that will be set as a flat color.
{
    [super setBackgroundColor:color];
    [self setHighColor:[self backgroundColor]];
    [self setLowColor:[self backgroundColor]];
}

/*********************************************************/
/**
 \brief Draw the control.
 */
- (void)drawRect:(CGRect)rect   ///< The rect to be updated (ignored)
{
    [gradientLayer setBounds:[self bounds]];
    
    if ( [self glassEffect] )
        {
        if ( !glassEffectLayer )
            {
            glassEffectLayer = [[CAGradientLayer alloc] init];
            [gradientLayer addSublayer:glassEffectLayer];
            }
        
        [glassEffectLayer setFrame:[gradientLayer bounds]];
        [glassEffectLayer setBorderWidth:0];
        [glassEffectLayer setColors: [NSArray arrayWithObjects: (id)[[UIColor clearColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil]];
        
        [glassEffectLayer setPosition: CGPointMake([gradientLayer bounds].size.width / 2, 0 )];

        [glassEffectLayer setOpacity:0.25];
        }
    else
        {
        [glassEffectLayer removeFromSuperlayer];
        glassEffectLayer = nil; // We delete this, no matter what.
        }
    
    [gradientLayer setPosition: CGPointMake([self bounds].size.width/2, [self bounds].size.height/2)];
    
    [[self layer] setCornerRadius:[self cornerRadius]];
    [[self layer] setBorderWidth:[self borderWidth]];
        
    [gradientLayer setColors:
     [NSArray arrayWithObjects:
      (id)[[self highColor] CGColor],
      (id)[[self lowColor] CGColor], nil]];
    
    [gradientLayer setColors: [NSArray arrayWithObjects: (id)[[self highColor] CGColor], (id)[[self lowColor] CGColor], nil]];

    [super drawRect:rect];
}

/*********************************************************/
/**
 \brief Simply reverses the gradient while the control is touched.
 \returns YES
 */
- (BOOL)beginTrackingWithTouch:(UITouch *)touch ///< The touch object (ignored)
                     withEvent:(UIEvent *)event ///< The event object (ignored)
{
    [gradientLayer setColors: [NSArray arrayWithObjects: (id)[[self lowColor] CGColor], (id)[[self highColor] CGColor], nil]];
    
    return YES;
}

/*********************************************************/
/**
 \brief Returns the gradient to its previous state.
 */
- (void)endTrackingWithTouch:(UITouch *)touch   ///< The touch object (ignored)
                   withEvent:(UIEvent *)event   ///< The event object (ignored)
{
    [gradientLayer setColors: [NSArray arrayWithObjects: (id)[[self highColor] CGColor], (id)[[self lowColor] CGColor], nil]];
}

/*********************************************************/
/**
 \brief Set the color that is used for the top of the gradient.
 */
- (void)setHighColor:(UIColor*)color    ///< The color to use.
{
    _highColor = color;
    [[self layer] setNeedsDisplay];
}

/*********************************************************/
/**
 \brief Set the color that begins the gradient on the bottom.
 */
- (void)setLowColor:(UIColor*)color ///< The color to use.
{
    _lowColor = color;
    [[self layer] setNeedsDisplay];
}

/*********************************************************/
/**
 \brief Set the width of the border surrounding the button.
 */
- (void)setBorderWidth:(float)width ///< The width, in pixels.
{
    _borderWidth = width;
    [[self layer] setNeedsDisplay];
}

/*********************************************************/
/**
 \brief Set the radius of the corners.
 */
- (void)setCornerRadius:(float)radius   ///< The corner radius, in pixels.
{
    _cornerRadius = radius;
    [[self layer] setNeedsDisplay];
}

/*********************************************************/
/**
 \brief Set the "glass appearance" layer flag.
 */
- (void)setGlassEffect:(BOOL)isOn   ///< YES, if we want a "glass" effect on the button.
{
    _glassEffect = isOn;
    [[self layer] setNeedsDisplay];
}

@end
