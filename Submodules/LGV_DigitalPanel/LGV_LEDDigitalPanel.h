//
//  LGV_LEDDigitalPanel.h
//  LGV_DigitalPanel
/// \version 1.0.3
//
//  Created by Chris Marshall on 7/5/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A_LGV_DigitalPanel.h"

@interface LGV_LEDDigitalPanel : A_LGV_DigitalPanel
@property (nonatomic, readwrite) UIColor    *elementColorOn;
@property (nonatomic, readwrite) UIColor    *elementColorOff;

- (void)setElementColorOn:(UIColor *)inColor;      ///< Sets the color to be used for the "On" state.
- (void)setElementColorOff:(UIColor *)inColor;     ///< Sets the color to be used for the O"Off" state
@end
