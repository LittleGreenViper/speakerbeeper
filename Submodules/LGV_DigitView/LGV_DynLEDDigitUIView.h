//
//  LGV_DynLEDDigitUIView.h
//  LGV_DynLEDDigitUIView
/// \version 1.0.2
//
//  Created by Chris Marshall on 6/26/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A_LGV_DigitUIView.h"

/*********************************************************/
/**
 \class LGV_DynLEDDigitUIView
 \brief This supplies one single digit of an "LED" display.
        Think of it as a single-digit LED module.
        The minimum value is 0. The maximum value is 16.
        Negative values result in the display of only the center bar (a minus sign). 16 turns the number off completely.
        This is an ARC class.
 */
@interface LGV_DynLEDDigitUIView : A_LGV_DigitUIView
{
    CALayer     *_main_element;             ///< This is a container CALayer for the entire LED digit. It allows the layer to be scaled and treated as one object.
    CALayer     *_top_element;              ///< The CAShapeLayer of the top element
    CALayer     *_top_left_element;         ///< The CAShapeLayer of the top, left element
    CALayer     *_top_right_element;        ///< The CAShapeLayer of the top, right element
    CALayer     *_bottom_left_element;      ///< The CAShapeLayer of the bottom, left element
    CALayer     *_bottom_right_element;     ///< The CAShapeLayer of the bottom, right element
    CALayer     *_bottom_element;           ///< The CAShapeLayer of the bottom element
    CALayer     *_center_element;           ///< The CAShapeLayer of the center element
}
@property (nonatomic, readwrite) UIColor    *elementColorOn;
@property (nonatomic, readwrite) UIColor    *elementColorOff;

- (CALayer *)getSegment;
- (CALayer *)getCenterSegment;
- (CGRect)calculateRectForElement:(CALayer *)element;
- (void)clearElements;
- (void)setElementColors;
@end
