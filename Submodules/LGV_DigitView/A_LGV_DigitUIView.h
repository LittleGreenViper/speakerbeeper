//
//  A_LGV_DigitUIView.h
//  A_LGV_DigitUIView
/// \version 1.0.2
//
//  Created by Chris Marshall on 6/26/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/*********************************************************/
/**
 \class A_LGV_DigitUIView
 \brief This is an abstract class for a displayed digit.
        The minimum value is 0. The maximum value is 16.
        Negative values result in the display of only a minus sign.
        16 turns the number off completely.
 */
@interface A_LGV_DigitUIView : UIView
@property (nonatomic, readwrite) NSInteger  value;  ///< This will contain the object value (-1 -> 16). -1 is minus sign. 16 is all off.
- (void)setValue:(NSInteger)in_value;
@end
