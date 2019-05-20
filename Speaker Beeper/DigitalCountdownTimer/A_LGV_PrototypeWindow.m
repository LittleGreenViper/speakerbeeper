//
//  A_LGV_PrototypeWindow.m
//  DigitalCountdownTimer
//
//  Created by Chris Marshall on 7/29/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//
/*********************************************************/
/**
 \file A_LGV_PrototypeWindow.m
 \brief This is a very simple base file for all the timer displays.
 
        The purpose of this file is to provide an abstract base that
        will display the gradient over the textured background (which
        is displayed by the window).
 
        It also makes sure that the iPhone only operates in landscape mode.
 
        This is the base class for all displayed views in the timer.
 */

#import "A_LGV_PrototypeWindow.h"
#import <QuartzCore/QuartzCore.h>
#import "A_LGV_MCNetworkManager.h"

/*********************************************************/
/**
 \class A_LGV_PrototypeWindow
 \brief This class simply provides a universal gradient layer for all of the various views of the timer.
        It also takes care of the rotation.
 */
@implementation A_LGV_PrototypeWindow

/*********************************************************/
/**
 \brief Instructs the window to present a commander browser.
 */
- (void)presentCommanderBrowser:(LGV_MCNetworkManagerClient*)inNetworkManager
{
    [self setBrowserManager:inNetworkManager];
    [inNetworkManager presentCommanderBrowser:self];
}

/*********************************************************/
/**
 \brief Removes any commander browser.
 */
- (void)dismissCommanderBrowser
{
    if ( [self browserManager] )
        {
        [[self browserManager] dismissCommanderBrowser];
        [self setBrowserManager:nil];
        }
}

/*********************************************************/
/**
 \brief Resrict or allow rotation. Portrait and upside-down iPhone are disallowed.
 \returns YES, if the rotation is approved.
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation ///< The proposed orientation.
{
    BOOL    ret = ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone)
    || !((interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) || (interfaceOrientation == UIInterfaceOrientationPortrait));
    
    return ret;
}
@end
