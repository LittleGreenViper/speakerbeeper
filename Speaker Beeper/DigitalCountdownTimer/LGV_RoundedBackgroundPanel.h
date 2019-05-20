//
//  LGV_RoundedBackgroundPanel.h
//  DigitalCountdownTimer
//
//  Created by Chris Marshall on 8/11/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

static  const   float       s_LGV_RoundedBackgroundPanel_DefaultCornerRadius = 8.0;    ///< This is the default corner radius for the button.
static  const   float       s_LGV_RoundedBackgroundPanel_DefaultBorderWidth = 1.0;     ///< This is the default border width for the button.

@interface LGV_RoundedBackgroundPanel : UIView
@property (nonatomic, readwrite)    float           cornerRadius;   ///< This is the corner radius for the rounded rect. If none is supplied, the default (above) is used.
@property (nonatomic, readwrite)    float           borderWidth;    ///< The width (in pixels) of the border. 0 is no border. If none is supplied, the default (above) is used.
@property (nonatomic, readwrite)    UIColor         *highColor;     ///< This is the base color for the light. If none is supplied, white is used.
@property (nonatomic, readwrite)    UIColor         *lowColor;      ///< This is the base color for the light. If none is supplied, dark gray is used.
@property (nonatomic, readwrite)    UIColor         *borderColor;   ///< This is the base color for the border. If none is supplied, black is used.
@end
