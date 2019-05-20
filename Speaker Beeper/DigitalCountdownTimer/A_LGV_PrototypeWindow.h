//
//  A_LGV_PrototypeWindow.h
//  DigitalCountdownTimer
//
//  Created by Chris Marshall on 7/29/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LGV_MCNetworkManagerClient;  ///< Forward declaration for the class.

/*********************************************************/
/**
 \class A_LGV_PrototypeWindow
 \brief This class simply provides a universal gradient layer for all of the various views of the timer.
        It also takes care of the rotation.
 */
@interface A_LGV_PrototypeWindow : UIViewController
@property (weak, atomic, readwrite)     LGV_MCNetworkManagerClient  *browserManager;    ///< This is the network manager that is presenting our commander browser.

- (void)presentCommanderBrowser:(LGV_MCNetworkManagerClient*)inNetworkManager;      ///< Tell the view to present a commander browser.
- (void)dismissCommanderBrowser;                                                    ///< Remove the commander browser.
@end
