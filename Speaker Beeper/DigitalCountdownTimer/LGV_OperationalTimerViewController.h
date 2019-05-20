//
//  LGV_OperationalTimerViewController.h
//  DigitalCountdownTimer
//
//  Created by Chris Marshall on 8/5/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A_LGV_PrototypeWindow.h"
#import "LGV_LEDDigitalTimeDisplay.h"
#import "A_LGV_TimerBaseViewController.h"
#import "LGV_SimpleRoundedRectButton.h"

/*********************************************************/
/**
 \class LGV_OperationalTimerViewController
 \brief This class controls the view for the operating clock.
 */
@interface LGV_OperationalTimerViewController : A_LGV_TimerBaseViewController
@property (weak, nonatomic)     IBOutlet    UIView                          *podiumTimerView;
@property (weak, nonatomic)     IBOutlet    LGV_SimpleRoundedRectButton     *greenPodiumLight;
@property (weak, nonatomic)     IBOutlet    LGV_SimpleRoundedRectButton     *yellowPodiumLight;
@property (weak, nonatomic)     IBOutlet    LGV_SimpleRoundedRectButton     *redPodiumLight;

- (IBAction)tappedOut:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andPrefsKey:(NSString *)prefsKey;
- (void)startTimer;
- (void)pauseTimer;
- (void)stopTimer;
@end
