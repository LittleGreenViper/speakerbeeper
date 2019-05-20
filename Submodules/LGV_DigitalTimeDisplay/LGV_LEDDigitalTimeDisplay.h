//
//  LGV_LEDDigitalTimeDisplay.h
//  LGV_LEDDigitalTimeDisplay
/// \version 1.0.6  
//
//  Created by Chris Marshall on 7/7/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import "A_LGV_DigitalTimeDisplay.h"

@class CAShapeLayer;    ///< Forward reference, so we don't need to import the Quartz Core file.

/*********************************************************/
/**
 \class LGV_LEDDigitalPanelSeparator
 \brief This view will represent a "colon" separator for the
        clock display. Its main purpose for existence is
        to make sure the path doesn't leak.
 */
@interface LGV_LEDDigitalPanelSeparator : UIView
@property (nonatomic, readwrite)    CAShapeLayer    *myShapes;          ///< This is the CAShapeLayer for the separators.

- (id)initWithFrame:(CGRect)inRect andOnColor:(UIColor *)inColorOn; ///< Set up a new instance
@end

/*********************************************************/
/**
 \class LGV_LEDDigitalTimeDisplay
 \brief This is a concrete class that creates a dynamically
        drawn "LED" display for the time display.
        This class uses the Quartz Core framework.
 */
@interface LGV_LEDDigitalTimeDisplay : A_LGV_DigitalTimeDisplay
@property (nonatomic, readwrite) UIColor    *elementColorOn;    ///< The color/pattern used for the display when an element is "on."
@property (nonatomic, readwrite) UIColor    *elementColorOff;   ///< The same, but for "off."
@property (nonatomic, readwrite) BOOL       blinkSeparators;    ///< This controls whether or not the separators will blink.
@end
