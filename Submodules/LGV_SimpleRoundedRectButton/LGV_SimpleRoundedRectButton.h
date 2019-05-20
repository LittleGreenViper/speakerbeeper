//
//  LGV_SimpleRoundedRectButton.h
//  LGV_SimpleRoundedRectButton
/// \version 1.0.3
//
//  Created by Chris Marshall on 8/9/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

static  const   float       s_LGV_SimpleRoundedRectButton_DefaultCornerRadius = 8.0;    ///< This is the default corner radius for the button.
static  const   float       s_LGV_SimpleRoundedRectButton_DefaultBorderWidth = 1.0;     ///< This is the default border width for the button.

/*********************************************************/
/**
 \class LGV_SimpleRoundedRectButton
 \brief Implements a simple rounded-corner gradient button.
 */
@interface LGV_SimpleRoundedRectButton : UIButton
@property (nonatomic, readwrite)    float           cornerRadius;   ///< This is the corner radius for the rounded rect. If none is supplied, the default (above) is used.
@property (nonatomic, readwrite)    float           borderWidth;    ///< The width (in pixels) of the border. 0 is no border. If none is supplied, the default (above) is used.
@property (nonatomic, readwrite)    UIColor         *highColor;     ///< This is the base color for the light. If none is supplied, white is used.
@property (nonatomic, readwrite)    UIColor         *lowColor;      ///< This is the base color for the light. If none is supplied, dark gray is used.
@property (nonatomic, readwrite)    UIColor         *borderColor;   ///< This is the base color for the border. If none is supplied, black is used.
@property (nonatomic, readwrite)    BOOL            glassEffect;    ///< I YES, then a "Glass Effect" layer will be displayed over the item. Default is NO.
@end
