//
//  LGV_RoundedBackgroundPanel.m
//  DigitalCountdownTimer
//
//  Created by Chris Marshall on 8/11/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import "LGV_RoundedBackgroundPanel.h"
#import <QuartzCore/QuartzCore.h>

/*********************************************************/
/**
 \class LGV_RoundedBackgroundPanel (Private Interface)
 \brief Implements a simple, rounded-rect gradient shape.
 */
@interface LGV_RoundedBackgroundPanel ()
{
    CAGradientLayer *gradientLayer;
}
@end

/*********************************************************/
/**
 \class LGV_RoundedBackgroundPanel
 \brief Implements a simple, rounded-rect gradient view.
 */
@implementation LGV_RoundedBackgroundPanel

@synthesize cornerRadius = _cornerRadius;
@synthesize borderWidth = _borderWidth;
@synthesize highColor = _highColor;
@synthesize lowColor = _lowColor;

/*********************************************************/
/**
 \brief Sets up the control.
 */
- (void)awakeFromNib
{
    [self setHighColor:[UIColor whiteColor]];
    [self setLowColor:[UIColor darkGrayColor]];
    
    [self setBorderWidth:s_LGV_RoundedBackgroundPanel_DefaultBorderWidth];
    [self setCornerRadius:s_LGV_RoundedBackgroundPanel_DefaultCornerRadius];
    
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
    [[self layer] setNeedsDisplay];
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
        
    [gradientLayer setPosition: CGPointMake([self bounds].size.width/2, [self bounds].size.height/2)];
    
    [[self layer] setCornerRadius:[self cornerRadius]];
    [[self layer] setBorderWidth:[self borderWidth]];
    [[self layer] setMasksToBounds:YES];
    
    [gradientLayer setColors:[NSArray arrayWithObjects:(id)[[self highColor] CGColor], (id)[[self lowColor] CGColor], nil]];
    
    [super drawRect:rect];
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

@end
