//
//  LGV_InfoWindowViewController.m
//  DigitalCountdownTimer
//
//  Created by Chris Marshall on 8/6/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//
/*********************************************************/
/**
 \file LGV_InfoWindowViewController.m
 \brief The view controller for the info screen.
 
        This will ensure that localized versions of all of the
        text items are presented.
 */

#import "LGV_InfoWindowViewController.h"

/*********************************************************/
/**
 \class LGV_InfoWindowViewController
 \brief Ensures that the localized strings are applied to the info screen.
 */
@implementation LGV_InfoWindowViewController
@synthesize adamLabel;
@synthesize adamFunctionLabel;
@synthesize chrisLabel;
@synthesize chrisFunctionLabel;
@synthesize appTitleLabel;
@synthesize lgvByLineLabel;
@synthesize lgvPicture;
@synthesize versionLabel;
@synthesize instructionsLabel;
@synthesize instructionsText;
@synthesize scrollerBackground;

/*********************************************************/
/**
 \brief Simply set up the localized strings.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // These are all simple. The text contains the lookup key.
    [[self adamFunctionLabel] setText:NSLocalizedString([[self adamFunctionLabel] text], nil)];
    [[self chrisFunctionLabel] setText:NSLocalizedString([[self chrisFunctionLabel] text], nil)];
    [[self instructionsLabel] setText:NSLocalizedString([[self instructionsLabel] text], nil)];
    [[self instructionsText] setText:NSLocalizedString([[self instructionsText] text], nil)];
    
    // The byline can have a couple of lines (It's long-winded).
    [[[self lgvByLineLabel] titleLabel] setNumberOfLines:2];
    
    // The scrolling container is black.
    [[self scrollerBackground] setBackgroundColor:[UIColor blackColor]];
    
    // These are actually buttons.
    [[self lgvByLineLabel] setTitle:NSLocalizedString([[self lgvByLineLabel] titleForState:UIControlStateNormal], nil) forState:UIControlStateNormal];
    [[self adamLabel] setTitle:NSLocalizedString([[self adamLabel] titleForState:UIControlStateNormal], nil) forState:UIControlStateNormal];
    [[self chrisLabel] setTitle:NSLocalizedString([[self chrisLabel] titleForState:UIControlStateNormal], nil) forState:UIControlStateNormal];

    // We fetch the app name from the bundle.
    [[self appTitleLabel] setText:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
    
    // We fetch the version from the info plist, and we use a localized format to display it.
    NSString    *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSString    *appInfo = [[NSDictionary dictionaryWithContentsOfFile:plistPath] valueForKey:@"CFBundleVersion"];
    [[self versionLabel] setText:[NSString stringWithFormat:NSLocalizedString([[self versionLabel] text], nil), appInfo]];
    [[[LGV_AppDelegate appDelegate] application] setStatusBarHidden:YES];
    [[self lgvInfoView] setBorderWidth:0];
    [[self lgvInfoView] setHighColor:[UIColor whiteColor]];
    [[self lgvInfoView] setLowColor:[UIColor colorWithWhite:0.75 alpha:1.0]];
}

/*********************************************************/
/**
 \brief unload any previously loaded items.
 */
- (void)viewDidUnload
{
    [self setAdamLabel:nil];
    [self setAdamFunctionLabel:nil];
    [self setChrisLabel:nil];
    [self setChrisFunctionLabel:nil];
    [self setAppTitleLabel:nil];
    [self setLgvByLineLabel:nil];
    [self setLgvPicture:nil];
    [self setVersionLabel:nil];
    [self setInstructionsLabel:nil];
    [self setInstructionsText:nil];
    [self setScrollerBackground:nil];
    [super viewDidUnload];
}

/*********************************************************/
/**
 \brief unload any previously loaded items.
 */
- (IBAction)resolveLGVLink:(id)sender    ///< The button we use for this URI.
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"LGV-URI", nil)]];
}

/*********************************************************/
/**
 \brief unload any previously loaded items.
 */
- (IBAction)resolveAdamLink:(id)sender    ///< The button we use for this URI.
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"ADAM-URI", nil)]];
}

/*********************************************************/
/**
 \brief unload any previously loaded items.
 */
- (IBAction)resolveChrisLink:(id)sender    ///< The button we use for this URI.
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"CHRIS-URI", nil)]];
}

@end
