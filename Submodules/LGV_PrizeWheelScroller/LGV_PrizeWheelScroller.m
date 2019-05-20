//
//  LGV_PrizeWheelScroller.m
//  LGV_PrizeWheelScroller
/// \version 1.0.2
//
//  Created by Chris Marshall on 7/21/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC All rights reserved.
//

#import "LGV_PrizeWheelScroller.h"
#import <QuartzCore/QuartzCore.h>

static const    float   s_LGV_PrizeWheelScroller_AnimationBaseDuration  = 0.1;              ///< The duration for the feedback animation.
static const    float   s_LGV_PrizeWheelScroller_SpeedCoefficient       = 30.0;             ///< A speed denominator to be used to calculate clicks.
static const    int     s_LGV_PrizeWheelScroller_MaxClick               = 10;               ///< The maximum number of clicks that can be spanned.
static const    float   s_LGV_PrizeWheelScroller_DefaultOpacity         = 0.5;              ///< The default opacity of the momentary highlight.
static const    float   s_LGV_PrizeWheelScroller_DefaultIncrementValue  = 1.0;              ///< The default increment value that affects the scroller sensitivity.
static          NSString    *s_LGV_PrizeWheelScroller_clickFileName     = @"RatchetClick";  ///< The name of the sound file for each segment click.
#define k_LGV_PrizeWheelScroller_DefaultHighlightColor  [UIColor yellowColor]   ///< The defaul color of the momentary highlight.

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
@interface LGV_PrizeWheelScroller ()
{
    BOOL    _firstGo;                           ///< This is set to indicate that this is the first callback in a new touch.
    CAShapeLayer    *_animationLayerDown;       ///< This will be used for an internal animation layer (down direction).
    CAShapeLayer    *_animationLayerUp;         ///< This will be used for an internal animation layer (up direction).
    float           cumulativeValue;            ///< This allows us to slow down the value setting, so that we can set it a bit more accurately.
}
@property (nonatomic, readwrite)        NSTimeInterval  lastTime;           ///< Used to track the time between calls, so we can determine the rate.
@property (nonatomic, readwrite)        SystemSoundID   click_sound;        ///< This will contain the click sound.
@property (nonatomic, readwrite)        NSURL           *click_sound_url;   ///< This points to the sound file.

- (void)createVisualFeedback:(NSInteger)strength;            ///< Displays a "glow" animation for the given layer.
- (void)initializeObject;                                       ///< Private instance method to set up object defaults.
- (void)displayFeedbackForThisManyClicks:(int)clicks;           ///< Displays visual feedback for the number of given clicks.
@end

@implementation LGV_PrizeWheelScroller
@synthesize delegate;           ///< The scroller delegate.
@synthesize horizontal = _horizontal;         ///< If YES, the control looks for horizontal gestures. Otherwise, it is vertical. Default is NO.
@synthesize lastTime;           ///< Used to track the time between calls, so we can determine the rate.
@synthesize visualFeedback;     ///< If YES, then the control will flash a translucent gradient to indicate that something is happening. Default is NO.
@synthesize audibleFeedback;    ///< If YES, then the control will make "tick" sound to indicate that an action is being performed. Default is NO.
@synthesize tactileFeedback;    ///< If YES, then the control will vibrate the device to indicate that an action is being performed. Default is NO.
@synthesize highlightColor;     ///< The color of the momentary highlight.
@synthesize highlightOpacity;   ///< The opacity of the momentary highlight.
@synthesize incrementValue;     ///< This allows us to regulate the speed of the setting.   Default is 1.0.
@synthesize click_sound = _click_sound; ///< This will contain the click sound.
@synthesize click_sound_url;            ///< This points to the sound file.
@synthesize reverseSingleClicks;        ///< If YES, the single-clicks will get a different direction assigned (useful for "scroll wheel" UI. Default is NO.

#pragma mark - Initializers -

/*********************************************************/
/**
 \brief Initializer with no parameters.
 \returns self
 */
- (id)init
{
    self = [super init];
    
    if ( self )
        {
        [self initializeObject];
        }
    
    return self;
}

/*********************************************************/
/**
 \brief Initializer with a decoder.
 \returns self
 */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if ( self )
        {
        [self initializeObject];
        }
    
    return self;
}

/*********************************************************/
/**
 \brief Initializer with a frame.
 \returns self
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if ( self )
        {
        [self initializeObject];
        }
    
    return self;
}

/*********************************************************/
/**
 \brief Just make sure the animation layer is gone.
 */
- (void)dealloc
{
    _animationLayerDown = nil;
    _animationLayerUp = nil;
    AudioServicesDisposeSystemSoundID ([self click_sound]);
}

#pragma mark - Private Instance Methods -

/*********************************************************/
/**
 \brief Displays a "glow" animation for the given layer.
 */
- (void)createVisualFeedback:(NSInteger)strength         ///< The strength of the animation.
{
    CGPoint shapePoints[3] = {  // This is used to draw the triangles in the shape layers.
        { 0, 0 },
        { 0, 0 },
        { 0, 0 }
    };
    
    // If we have not already created our animation layers, we do so now.
    if ( !_animationLayerDown )
        {
        CGRect  bounds = [self bounds];
        _animationLayerDown = [[CAShapeLayer alloc] init];
        _animationLayerDown.opacity = 0.0;
        
        if ( [self horizontal] )
            {
            bounds.size.width /= 2.0;
            [_animationLayerDown setFrame:bounds];
            shapePoints[0] = CGPointMake ( (bounds.size.width * 5) / 100, bounds.size.height / 2.0 );
            shapePoints[1] = CGPointMake ( (bounds.size.width * 95) / 100, (bounds.size.height * 5) / 100 );
            shapePoints[2] = CGPointMake ( (bounds.size.width * 95) / 100, (bounds.size.height * 95) / 100 );
            }
        else
            {
            bounds.size.height /= 2.0;
            [_animationLayerDown setFrame:bounds];
            shapePoints[0] = CGPointMake ( bounds.size.width / 2.0, (bounds.size.height * 5) / 100 );
            shapePoints[1] = CGPointMake ( (bounds.size.width * 95) / 100, (bounds.size.height * 95) / 100 );
            shapePoints[2] = CGPointMake ( (bounds.size.width * 5) / 100, (bounds.size.height * 95) / 100 );
            }
        
        CGMutablePathRef    thePath = CGPathCreateMutable ();
        
        CGPathAddLines ( thePath, nil, shapePoints, 3 );
        
        [_animationLayerDown setFillColor:[[self highlightColor] CGColor]];
        [_animationLayerDown setPath:thePath];
        
        CGPathRelease ( thePath );
        
        [[self layer] addSublayer:_animationLayerDown]; // This layer will be a direct sublayer of our main layer.
        }
    
    if ( !_animationLayerUp )
        {
        CGRect  bounds = [self bounds];
        
        _animationLayerUp = [[CAShapeLayer alloc] init];
        _animationLayerUp.opacity = 0.0;
        
        if ( [self horizontal] )
            {
            bounds.size.width /= 2.0;
            bounds.origin.x += bounds.size.width;
            [_animationLayerUp setFrame:bounds];
            shapePoints[0] = CGPointMake ( (bounds.size.width * 95) / 100, bounds.size.height / 2.0 );
            shapePoints[1] = CGPointMake ( (bounds.size.width * 5) / 100, (bounds.size.height * 95) / 100 );
            shapePoints[2] = CGPointMake ( (bounds.size.width * 5) / 100, (bounds.size.height * 5) / 100 );
            }
        else
            {
            bounds.size.height /= 2.0;
            bounds.origin.y += bounds.size.height;
            [_animationLayerUp setFrame:bounds];
            shapePoints[0] = CGPointMake ( bounds.size.width / 2.0, (bounds.size.height * 95) / 100 );
            shapePoints[1] = CGPointMake ( (bounds.size.width * 5) / 100, (bounds.size.height * 5) / 100 );
            shapePoints[2] = CGPointMake ( (bounds.size.width * 95) / 100, (bounds.size.height * 5) / 100 );
            }
        
        CGMutablePathRef    thePath = CGPathCreateMutable ();
        
        CGPathAddLines ( thePath, nil, shapePoints, 3 );
        
        [_animationLayerUp setFillColor:[[self highlightColor] CGColor]];
        [_animationLayerUp setPath:thePath];
        
        CGPathRelease ( thePath );
        
        [[self layer] addSublayer:_animationLayerUp]; // This layer will be a direct sublayer of our main layer.
        }
    
    CALayer *animationLayer = (strength < 0) ? _animationLayerDown : _animationLayerUp;
    
    CABasicAnimation    *tempAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    tempAnimation.fromValue = [NSNumber numberWithFloat:[self highlightOpacity]];
    tempAnimation.toValue = [NSNumber numberWithFloat:0.0];
    [CATransaction begin];
    [CATransaction setAnimationDuration:s_LGV_PrizeWheelScroller_AnimationBaseDuration];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [CATransaction setCompletionBlock:^(void){[animationLayer removeAllAnimations];}];
    [animationLayer addAnimation:tempAnimation forKey:@"opacity"];
    [CATransaction commit];
}

/*********************************************************/
/**
 \brief Sets the horizontal property, and also clears the animation layers.
 */
- (void) setHorizontal:(BOOL)horizontal
{
    _horizontal = horizontal;
    _animationLayerDown = nil;
    _animationLayerUp = nil;
}

/*********************************************************/
/**
 \brief Sets up the click sound.
        It takes the name of a WAV (.wav) file, with no extension.
        The file MUST be a .wav file.
 */
- (void)setClickSoundByName:(NSString *)inFileName  ///< The non-extension name of a .wav (WAV) file.
{
    // We need to a bridged retain and release, here.
    
    // We get rid of any previous resources, first.
    if ( [self click_sound_url] )
        {
        [self setClick_sound_url:nil];
        }
    
    if ( [self click_sound] )
        {
        AudioServicesDisposeSystemSoundID ([self click_sound]);
        [self setClick_sound:0];
        }
    
    // We set up the new sound ID and resource, by loading our file.
    [self setClick_sound_url:[[NSBundle mainBundle] URLForResource: inFileName
                                                     withExtension: @"wav"]];
    AudioServicesCreateSystemSoundID ( (__bridge CFURLRef)[self click_sound_url ], &_click_sound );
}

/*********************************************************/
/**
 \brief Set up the object defaults.
 */
- (void)initializeObject
{
    [self setHorizontal:NO];
    [self setVisualFeedback:NO];
    [self setAudibleFeedback:NO];
    [self setTactileFeedback:NO];
    [self setBackgroundColor:[UIColor clearColor]];
    [self setLastTime:0];
    [self setHighlightColor:k_LGV_PrizeWheelScroller_DefaultHighlightColor];
    [self setHighlightOpacity:s_LGV_PrizeWheelScroller_DefaultOpacity];
    [self setClickSoundByName:s_LGV_PrizeWheelScroller_clickFileName];
    [self setIncrementValue:s_LGV_PrizeWheelScroller_DefaultIncrementValue];
}

/*********************************************************/
/**
 \brief Displays visual feedback.
 */
- (void)displayFeedbackForThisManyClicks:(int)clicks    ///< The number of clicks, which affects the depth of the feedback.
{
    if ( [self visualFeedback] )    // Only valid if the setting is YES.
        {
        CGRect  gradientFrame = [self bounds];
        
        if ( [self horizontal] )
            {
            if ( clicks < 0 )
                {
                gradientFrame.size.width /= 2.0;
                }
            else
                {
                gradientFrame.size.width /= 2.0;
                gradientFrame.origin.x += gradientFrame.size.width;
                }
            }
        else
            {
            if ( clicks < 0 )
                {
                gradientFrame.size.height /= 2.0;
                }
            else
                {
                gradientFrame.size.height /= 2.0;
                gradientFrame.origin.y += gradientFrame.size.height;
                }
            }
        
        [self createVisualFeedback:clicks];
        }
    
    if ( [self audibleFeedback] )
        {
        AudioServicesPlaySystemSound ( [self click_sound] );
        }
    
    if ( [self tactileFeedback] )
        {
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
        }
}

#pragma mark - Public Instance Superclass Override Methods -

/*********************************************************/
/**
 \brief Called when the touch event begins.
 \returns YES
 */
- (BOOL)beginTrackingWithTouch:(UITouch *)touch         ///< The UITouch object for this event.
                     withEvent:(UIEvent *)event         ///< The event for this touch.
{
    [self setLastTime:[event timestamp]];
    
    _firstGo = YES;
    cumulativeValue = 0.0;  // We will build on this.
    
#ifdef DEBUG
    NSLog(@"LGV_PrizeWheelScroller::beginTrackingWithTouch, timestamp: %f", [self lastTime]);
#endif

    return YES;
}

/*********************************************************/
/**
 \brief This allows "one-tap" increments and decrements.
 */
- (void)endTrackingWithTouch:(UITouch *)touch
                   withEvent:(UIEvent *)event
{
    if ( _firstGo )  // If this was simply a tap, then we will increment or decrement by 1, depending on the location of the tap.
        {
#ifdef DEBUG
        NSLog(@"LGV_PrizeWheelScroller::endTrackingWithTouch, timestamp: %f", [self lastTime]);
#endif
        CGRect  downClick = [self bounds];
        CGRect  upClick = downClick;
        
        if ( [self horizontal] )
            {
            downClick.size.width /= 2.0;
            upClick.size.width /= 2.0;
            upClick.origin.x += upClick.size.width;
            }
        else
            {
            downClick.size.height /= 2.0;
            upClick.size.height /= 2.0;
            upClick.origin.y += upClick.size.height;
            }
        
        int dir = ( CGRectContainsPoint(downClick, [touch locationInView:self]) ) ? -1 : 1;
        
        dir = [self reverseSingleClicks] ? -dir : dir;
        
        if ( [self delegate] && _firstGo && [[self delegate] respondsToSelector:@selector(prizeWheelScrollerStarted:inThisDirection:)] )
            {
            [[self delegate] prizeWheelScrollerStarted:self inThisDirection:dir];
            }
        
        if ( [self delegate] && [[self delegate] respondsToSelector:@selector(prizeWheelScrollerMoved:byThisManyClicks:)] )
            {
            [[self delegate] prizeWheelScrollerMoved:self byThisManyClicks:dir];
            }
        
        [self displayFeedbackForThisManyClicks:dir];
        _firstGo = NO;
        }
}

/*********************************************************/
/**
 \brief Called as the touch event continues.
 \returns YES
 */
- (BOOL)continueTrackingWithTouch:(UITouch *)touch      ///< The UITouch object for this event.
                        withEvent:(UIEvent *)event      ///< The event for this touch.
{
    NSTimeInterval  difference = [event timestamp] - [self lastTime];
    
    if ( difference )   // We must have a time difference.
        {
        cumulativeValue += [self incrementValue];
#ifdef DEBUG
        NSLog ( @"LGV_PrizeWheelScroller::continueTrackingWithTouch. cumulativeValue: %f, incrementValue: %f", cumulativeValue, [self incrementValue] );
#endif
        
        if ( cumulativeValue >= 1.0 )   // We only do all this if we go past one click.
            {
            float           diffX = ([touch locationInView:self].x - [touch previousLocationInView:self].x) / 2;
            float           diffY = ([touch locationInView:self].y - [touch previousLocationInView:self].y) / 2;
            float           speedX = (diffX / difference);
            float           speedY = (diffY / difference);
        
#ifdef DEBUG
            NSLog ( @"LGV_PrizeWheelScroller::continueTrackingWithTouch\n\ttimestamp:\n\tX-axis difference: %f\n\tY-axis difference: %f\n\tSpeed on the X-axis:%f\n\tSpeed on the Y-axis: %f", diffX, diffY, speedX, speedY );
#endif
            
            int clicks = 0;     // This will be set to whichever axis we are tracking.
            int dir = 0;        // This will be the direction we're going.
            
            // We decide which direction is the one we'll report (We don't report a direction to the client -it should already know).
            if ( [self horizontal] )        // See if we have a horizontal swipe, and we are looking for one.
                {
                clicks = MAX ( 1, MIN ( s_LGV_PrizeWheelScroller_MaxClick, (int)ABS ( speedX / s_LGV_PrizeWheelScroller_SpeedCoefficient ) ) );
                dir = (speedX < 0) ? -(int)cumulativeValue : (int)cumulativeValue;
                }
            else                            // See if we have a vertical swipe.
                {
                clicks = MAX ( 1, MIN ( s_LGV_PrizeWheelScroller_MaxClick, (int)ABS ( speedY / s_LGV_PrizeWheelScroller_SpeedCoefficient ) ) );
                dir = (speedY < 0) ? -(int)cumulativeValue : (int)cumulativeValue;
                }
            
            clicks *= dir;
        
#ifdef DEBUG
            NSLog(@"LGV_PrizeWheelScroller::continueTrackingWithTouch\n\ttimestamp: %f\n\ttime difference: %f\n\tX-axis difference: %f\n\tY-axis difference: %f\n\tSpeed on the X-axis:%f\n\tSpeed on the Y-axis: %f\n\tDirection: %d\n\tClicks: %d", [self lastTime], difference, diffX, diffY, speedX, speedY, dir, clicks);
#endif
            
            cumulativeValue = 0.0;
            
            if ( [self delegate] && _firstGo && [[self delegate] respondsToSelector:@selector(prizeWheelScrollerStarted:inThisDirection:)] )
                {
                [[self delegate] prizeWheelScrollerStarted:self inThisDirection:dir];
                }
            
            if ( clicks && [self delegate] && [[self delegate] respondsToSelector:@selector(prizeWheelScrollerMoved:byThisManyClicks:)] )
                {
                [[self delegate] prizeWheelScrollerMoved:self byThisManyClicks:clicks];
                }
            
            [self displayFeedbackForThisManyClicks:clicks];
            }
        
        _firstGo = NO;
        }
    
    return YES;
}

@end
