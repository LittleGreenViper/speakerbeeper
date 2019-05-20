//
//  LGV_DynLEDDigitUIView.m
//  LGV_DynLEDDigitUIView
/// \version 1.0.2
//
//  Created by Chris Marshall on 6/26/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import "LGV_DynLEDDigitUIView.h"
#import <QuartzCore/QuartzCore.h>

// This is an array of points that maps out the standard element shape.
static const CGPoint s_shapePoints[] = {
    { 0, 4 },
    { 4, 0 },
    { 230, 0 },
    { 234, 4 },
    { 180, 58 },
    { 54, 58 },
    { 0, 4 }
};

// This maps out the center element, which is a slightly different shape.
static const CGPoint s_centerShapePoints[] = {
    { 0, 34 },
    { 34, 0 },
    { 200, 0 },
    { 234, 34 },
    { 200, 68 },
    { 34, 68 },
    { 0, 34 }
};

// These are indexes, used to make it a bit more apparent what segment is being sought.
enum e_segmentIndices 
{
    kTopSegment = 0,        ///< top segment
    kTopLeftSegment,        ///< top left segment
    kTopRightSegment,       ///< top right segment
    kBottomLeftSegment,     ///< bottom left segment
    kBottomRightSegment,    ///< bottom right segment
    kBottomSegment,         ///< bottom Segment
    kCenterSegment,         ///< center segment
    kTotalRect              ///< Entire drawing area
};

// This array of rects is the layout of the display.
static const CGRect s_viewRects[] = {
    { {8, 0}, {234, 58} },      ///< top segment
    { {0, 8}, {58, 234} },      ///< top left segment
    { {192, 8}, {58, 234} },    ///< top right segment
    { {0, 250}, {58, 234} },    ///< bottom left segment
    { {192, 250}, {58, 234} },  ///< bottom right segment
    { {8, 434}, {234, 58} },    ///< bottom Segment
    { {8, 212}, {234, 68} },    ///< center segment
    { {0, 0}, {250, 492} }      ///< Entire drawing area
};

/// These map out which segments get "lit" for any given digit value. If the digit value is one of these, then the corresponding segment is turned on. The first number is the array length (This is a simple C array).
static const int s_top_element_mask[] = { 12, 0, 2, 3, 5, 6, 7, 8, 9, 10, 12, 14, 15 };
static const int s_top_left_element_mask[] = { 11, 0, 4, 5, 6, 8, 9, 10, 11, 12, 14, 15 };
static const int s_top_right_element_mask[] = { 10, 0, 1, 2, 3, 4, 7, 8, 9, 10, 13 };
static const int s_bottom_left_element_mask[] = { 10, 0, 2, 6, 8, 10, 11, 12, 13, 14, 15 };
static const int s_bottom_right_element_mask[] = { 12, 0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 13 };
static const int s_bottom_element_mask[] = { 11, 0, 2, 3, 5, 6, 8, 9, 11, 12, 13, 14 };
static const int s_center_element_mask[] = { 13, -1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 13, 14, 15 };

/*********************************************************/
/**
 \class LGV_DynLEDDigitUIView (Private interface)
 \brief This supplies one single digit of an "LED" display.
        Think of it as a single-digit LED module.
        The minimum value is 0. The maximum value is 16.
        Negative values result in the display of only the center bar (a minus sign). 16 turns the number off completely.
        This is an ARC class.
 */
@interface LGV_DynLEDDigitUIView ()
+ (BOOL)isThisNumber:(const int)theValue inThisArray:(const int *)theArray; ///< This function tests to see if a number is in an array.
@end

/*********************************************************/
/**
 \class LGV_DynLEDDigitUIView
 \brief This supplies one single digit of an "LED" display.
        Think of it as a single-digit LED module.
        The minimum value is 0. The maximum value is 16.
        Negative values result in the display of only the center bar (a minus sign). 16 turns the number off completely.
        This is an ARC class.
 */
@implementation LGV_DynLEDDigitUIView

@synthesize elementColorOn = _elementColorOn, elementColorOff = _elementColorOff;

/*********************************************************/
/**
 \brief This function simply looks through an array of int,
 and will report if a given test value is one of the
 values in the array.
 \returns YES, if so.
 */
+ (BOOL)isThisNumber:(const int)theValue    ///< The value we are testing (needle).
         inThisArray:(const int *)theArray  ///< The array that we are searching (haystack).
{
    BOOL    ret = NO;
    
    for ( int c = 0; c < theArray[0]; )
        {
        if ( theValue == theArray[++c] )
            {
            ret = YES;
            break;
            }
        }
    return ret;
}

/*********************************************************/
/**
 \brief Simply makes sure that all the paths and layers are deleted.
 */
- (void)dealloc
{
    [self clearElements];
}

/*********************************************************/
/**
 \brief This will create a CALayer for one segment of the LED display.
 \returns a CAShapeLayer, with the drawn object in it.
 */
- (CALayer *)getSegment
{
    CAShapeLayer    *ret = [CAShapeLayer layer];
    
    [ret setFrame:CGRectMake ( 0, 0, s_viewRects[kCenterSegment].size.width, s_viewRects[kCenterSegment].size.height )];
    
    CGMutablePathRef    thePath = CGPathCreateMutable ();
    
    CGPathAddLines ( thePath, nil, s_shapePoints, 7 );
    
    [ret setPath:thePath];
    
    CFRelease ( thePath );
    
    return ret;
}

/*********************************************************/
/**
 \brief Returns the center segment as a CALayer.
 \returns a CAShapeLayer, with the drawn object in it.
 */
- (CALayer *)getCenterSegment
{
    CAShapeLayer    *ret = [CAShapeLayer layer];
    
    [ret setFrame:CGRectMake ( 0, 0, s_viewRects[kCenterSegment].size.width, s_viewRects[kCenterSegment].size.height )];
    
    CGMutablePathRef    thePath = CGPathCreateMutable ();
    
    CGPathAddLines ( thePath, nil, s_centerShapePoints, 7 );
    
    [ret setPath:thePath];
    
    CFRelease ( thePath );
    
    return ret;
}

/*********************************************************/
/**
 \brief Sets the color that the element shows as when it is on.
 */
- (void)setElementColorOn:(UIColor *)inColor  ///< The color to be used.
{
    _elementColorOn = inColor;
    [self setNeedsLayout];  // We use a layout event to set up the number.
}

/*********************************************************/
/**
 \brief Sets the color the element shows as when it is off.
 */
- (void)setElementColorOff:(UIColor *)inColor ///< The color to be used.
{
    _elementColorOff = inColor;
    [self setNeedsLayout];  // We use a layout event to set up the number.
}

/*********************************************************/
/**
 \brief Looks up and returns a scaled rect for the given element.
 \returns a CGRect that has the proper display-coordinate rect for the given object.
 */
- (CGRect)calculateRectForElement:(CALayer *)element  ///< This is the object that we're looking at.
{
    CGRect  ret;
    
    if ( element == _top_element )  // If we are the top element, then we use that rect.
        {
        ret = s_viewRects[kTopSegment];
        }
    else if ( element == _top_left_element )  // ...and so on.
        {
        ret = s_viewRects[kTopLeftSegment];
        }
    else if ( element == _top_right_element )
        {
        ret = s_viewRects[kTopRightSegment];
        }
    else if ( element == _bottom_left_element )
        {
        ret = s_viewRects[kBottomLeftSegment];
        }
    else if ( element == _bottom_right_element )
        {
        ret = s_viewRects[kBottomRightSegment];
        }
    else if ( element == _bottom_element )
        {
        ret = s_viewRects[kBottomSegment];
        }
    else if ( element == _center_element )
        {
        ret = s_viewRects[kCenterSegment];
        }
    
    return ret;
}

/*********************************************************/
/**
 \brief This deletes all the paths and layers.
 */
- (void)clearElements
{
    // First, we make sure that we actually remove the layers.
    [_top_element removeFromSuperlayer];
    [_top_left_element removeFromSuperlayer];
    [_top_right_element removeFromSuperlayer];
    [_bottom_left_element removeFromSuperlayer];
    [_bottom_right_element removeFromSuperlayer];
    [_bottom_element removeFromSuperlayer];
    [_center_element removeFromSuperlayer];
    [_main_element removeFromSuperlayer];
    
    // This is a "belt and suspenders" measure. I make sure that everything is removed from the container.
    [(CAShapeLayer *)_top_element setPath:nil];
    [(CAShapeLayer *)_top_left_element setPath:nil];
    [(CAShapeLayer *)_top_right_element setPath:nil];
    [(CAShapeLayer *)_bottom_left_element setPath:nil];
    [(CAShapeLayer *)_bottom_right_element setPath:nil];
    [(CAShapeLayer *)_bottom_element setPath:nil];
    [(CAShapeLayer *)_center_element setPath:nil];
    
    // Just make sure we renounce all claim.
    _top_element = nil;
    _top_left_element = nil;
    _top_right_element = nil;
    _bottom_left_element = nil;
    _bottom_right_element = nil;
    _bottom_element = nil;
    _center_element = nil;
    _main_element = nil;
}

/*********************************************************/
/**
 \brief This function actually instantiates and lays out
 the various CALayers that make up the display.
 */
- (void)layoutSubviews
{
    // We should only need to do this once.
    if ( !_top_element || !_top_left_element || !_top_right_element || !_bottom_left_element || !_bottom_right_element || !_bottom_element || !_center_element || !_main_element )
        {
        // First, we get rid of the existing ones.
        [self clearElements];
        
        // This is the main "container" for the display. It is the "base" CALayer, and fills the UIView.
        _main_element = [CALayer layer];
        
        // We start off by making it exactly the size of the unscaled LED display.
        [_main_element setFrame:s_viewRects[kTotalRect]];
        
        // Now, we instantiate each of the elements. We re-use the top segment for most of them.
        _top_element = [self getSegment];
        [_top_element setFrame:[self calculateRectForElement:_top_element]];    // This gives us the containing rect for the element.
        [_main_element addSublayer:_top_element];
        
        // After the top segment, we rotate and reposition the other elements.
        _top_left_element = [self getSegment];
        [_top_left_element setTransform:CATransform3DRotate(CATransform3DIdentity, M_PI_2, 0.0, 0.0, -1.0 )];   // The transform is a 3D transform. M_PI_2 is 90 degrees. The -1 is CCW.
        [_top_left_element setFrame:[self calculateRectForElement:_top_left_element]];
        [_main_element addSublayer:_top_left_element];
        
        _top_right_element = [self getSegment];
        [_top_right_element setTransform:CATransform3DRotate(CATransform3DIdentity, M_PI_2, 0.0, 0.0, 1.0 )];
        [_top_right_element setFrame:[self calculateRectForElement:_top_right_element]];
        [_main_element addSublayer:_top_right_element];
        
        _bottom_left_element = [self getSegment];
        [_bottom_left_element setTransform:CATransform3DRotate(CATransform3DIdentity, M_PI_2, 0.0, 0.0, -1.0 )];
        [_bottom_left_element setFrame:[self calculateRectForElement:_bottom_left_element]];
        [_main_element addSublayer:_bottom_left_element];
        
        _bottom_right_element = [self getSegment];
        [_bottom_right_element setTransform:CATransform3DRotate(CATransform3DIdentity, M_PI_2, 0.0, 0.0, 1.0 )];
        [_bottom_right_element setFrame:[self calculateRectForElement:_bottom_right_element]];
        [_main_element addSublayer:_bottom_right_element];
        
        _bottom_element = [self getSegment];
        [_bottom_element setTransform:CATransform3DRotate(CATransform3DIdentity, M_PI, 0.0, 0.0, 1.0 )];    // This one does a complete 180.
        [_bottom_element setFrame:[self calculateRectForElement:_bottom_element]];
        [_main_element addSublayer:_bottom_element];
        
        // The center element is slightly differently-shaped, so it uses a different CAShapeLayer.
        _center_element = [self getCenterSegment];
        [_center_element setFrame:[self calculateRectForElement:_center_element]];
        [_main_element addSublayer:_center_element];
        
        // We now ask the main layer to scale to fit the UIView
        [_main_element setTransform:CATransform3DMakeScale([self bounds].size.width / [_main_element bounds].size.width, [self bounds].size.height / [_main_element bounds].size.height, 1.0)];
        [_main_element setFrame:[self bounds]];
        [[self layer] addSublayer:_main_element];
        }
    
    [self setElementColors];    // This routine will figure out which ones are on, and which ones are off.
}

/*********************************************************/
/**
 \brief Sets the correct colors for the elements
 */
- (void)setElementColors
{
    int value = (int)[self value];
    CGColorRef  onColor = [[self elementColorOn] CGColor];
    CGColorRef  offColor = [[self elementColorOff] CGColor];
    
    // We go through each segment, and see if it should be on for a particular value.
    [(CAShapeLayer *)_top_element setFillColor:[[self class] isThisNumber:value inThisArray:s_top_element_mask] ? onColor : offColor];
    [(CAShapeLayer *)_top_left_element setFillColor:[[self class] isThisNumber:value inThisArray:s_top_left_element_mask] ? onColor : offColor];
    [(CAShapeLayer *)_top_right_element setFillColor:[[self class] isThisNumber:value inThisArray:s_top_right_element_mask] ? onColor : offColor];
    [(CAShapeLayer *)_bottom_left_element setFillColor:[[self class] isThisNumber:value inThisArray:s_bottom_left_element_mask] ? onColor : offColor];
    [(CAShapeLayer *)_bottom_right_element setFillColor:[[self class] isThisNumber:value inThisArray:s_bottom_right_element_mask] ? onColor : offColor];
    [(CAShapeLayer *)_bottom_element setFillColor:[[self class] isThisNumber:value inThisArray:s_bottom_element_mask] ? onColor : offColor];
    [(CAShapeLayer *)_center_element setFillColor:[[self class] isThisNumber:value inThisArray:s_center_element_mask] ? onColor : offColor];
}
@end
