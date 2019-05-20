//
//  LGV_InfoWindowViewController.h
//  DigitalCountdownTimer
//
//  Created by Chris Marshall on 8/6/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A_LGV_PrototypeWindow.h"
#import "LGV_RoundedBackgroundPanel.h"

/*********************************************************/
/**
 \class LGV_InfoWindowViewController
 \brief Ensures that the localized strings are applied to the info screen.
 */
@interface LGV_InfoWindowViewController : A_LGV_PrototypeWindow
/// These all correspond to the items in the storyboard.
@property (weak, nonatomic) IBOutlet UIButton                   *adamLabel;
@property (weak, nonatomic) IBOutlet UILabel                    *adamFunctionLabel;
@property (weak, nonatomic) IBOutlet UIButton                   *chrisLabel;
@property (weak, nonatomic) IBOutlet UILabel                    *chrisFunctionLabel;
@property (weak, nonatomic) IBOutlet UILabel                    *appTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton                   *lgvByLineLabel;
@property (weak, nonatomic) IBOutlet UIButton                   *lgvPicture;
@property (weak, nonatomic) IBOutlet UILabel                    *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel                    *instructionsLabel;
@property (weak, nonatomic) IBOutlet UITextView                 *instructionsText;
@property (weak, nonatomic) IBOutlet LGV_RoundedBackgroundPanel *scrollerBackground;
@property (weak, nonatomic) IBOutlet LGV_RoundedBackgroundPanel *lgvInfoView;

- (IBAction)resolveLGVLink:(id)sender;
- (IBAction)resolveAdamLink:(id)sender;
- (IBAction)resolveChrisLink:(id)sender;

@end
