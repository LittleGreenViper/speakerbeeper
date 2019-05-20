//
//  LGV_PrizeWheelScroller.h
//  LGV_PrizeWheelScroller
/// \version 1.0.2
//
//  Created by Chris Marshall on 7/21/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@class LGV_PrizeWheelScroller;  ///< Forward declaration for the delegate.

/*********************************************************/
/**
 \class LGV_PrizeWheelScrollerDelegate
 \brief An optional delegate for actions specific to this class.
        Direction is positive for incrementing values (down), and
        negative for decrementing values (up).
 */
@protocol LGV_PrizeWheelScrollerDelegate <NSObject>
@required
/// This is called periodically during the scroll. The number of clicks between calls is set in the scroller class.
- (void)prizeWheelScrollerMoved:(LGV_PrizeWheelScroller *)scroller      ///< The prize wheel scroller object.
               byThisManyClicks:(NSInteger)numberOfMoves;               ///< The number of moves since the last call. If negative, then the scroll has gone up since the last call.
@optional
/// This is called when the scroll begins, and a direction is established. -1 is up (or left). +1 is down (as in "physically" down), or right.
- (void)prizeWheelScrollerStarted:(LGV_PrizeWheelScroller *)scroller    ///< The prize wheel scroller object.
                  inThisDirection:(NSInteger)direction;                 ///< The direction of the scroll. -1 is up/left, and +1 is down/right.
@end

/*********************************************************/
/**
 \class LGV_PrizeWheelScroller
 \brief A special transparent control that establishes a
        "prize wheel" scroll.
        The class has a min and max value, and can either be
        set to stop, or roll over, when these limits are
        reached. Since it is a UIControl, it has a value.
        All values are integer.
        This class is not meant to display anything. It simply
        provides a gesture recognizer, and feedback to another
        object that interprets the values into a display.
        We will call each unit a "click."
 */
@interface LGV_PrizeWheelScroller : UIControl
@property (weak, nonatomic, readwrite)  NSObject <LGV_PrizeWheelScrollerDelegate>   *delegate;          ///< The special delegate for this instance.
@property (nonatomic, readwrite)        BOOL                                        horizontal;         ///< If YES, the control looks for horizontal gestures. Otherwise, it is vertical. Default is NO.
@property (nonatomic, readwrite)        BOOL                                        visualFeedback;     ///< If YES, then the control will flash a translucent gradient to indicate that an action is being performed. Default is NO.
@property (nonatomic, readwrite)        BOOL                                        audibleFeedback;    ///< If YES, then the control will make "tick" sound to indicate that an action is being performed. Default is NO.
@property (nonatomic, readwrite)        BOOL                                        tactileFeedback;    ///< If YES, then the control will vibrate the device to indicate that an action is being performed. Default is NO.
@property (nonatomic, readwrite)        UIColor                                     *highlightColor;    ///< The color of the momentary highlight.
@property (nonatomic, readwrite)        float                                       highlightOpacity;   ///< The opacity of the momentary highlight.
@property (nonatomic, readwrite)        float                                       incrementValue;     ///< We can reduce the increment value, so we can slow down the value setting. Default is 1.0.
@property (nonatomic, readwrite)        BOOL                                        reverseSingleClicks;    ///< If YES, the single-clicks will get a different direction assigned (useful for "scroll wheel" UI. Default is NO.

- (void)setClickSoundByName:(NSString *)inFileName;                                                     ///< This allows us to specify different WAV files to be played.
@end
