//
//  LGV_PickerScroller.m
//  LGV_PickerScroller
/// \version 1.0.2
//
//  Created by Chris Marshall on 7/30/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import "LGV_PickerScroller.h"

static const    NSInteger   s_LGV_PickerScroller_Padding            = 2.0;  ///< This is the padding around each item displayed.
static const    float       s_LGV_PickerScroller_Default_Increment  = 0.25; ///< This is the default scroller sensitivity value.

@interface LGV_PickerScrollerArrayItem ()
@property (weak, nonatomic, readwrite)  UIView  *cachedView;
@end

/*********************************************************/
/**
 \class LGV_PickerScrollerArrayItem
 \brief This class contains items for use by the scroller.
        This will form each array item.
 */
@implementation LGV_PickerScrollerArrayItem
@synthesize title = _title;     ///< The name of the object.
@synthesize image = _image;     ///< A picture that represents the object.
@synthesize refCon = _refCon;   ///< Any additional data that we want to associate with the object.
@synthesize cachedView;         ///< This stores a cached view, so we don't need to keep recreating them.

/*********************************************************/
/**
 \brief Initialize the object with a title and item image.
 \returns self
 */
- (id)initWithTitle:(NSString *)title   ///< The displayed title of the item.
           andImage:(UIImage *)image    ///< An image to be displayed, representing the item.
          andRefCon:(id)refCon          ///< Any additional data to be associated with the object.
{
    self = [super init];
    
    if ( self )
        {
        [self setTitle:title];
        [self setImage:image];
        [self setRefCon:refCon];
        }
    
    return self;
}
@end

/*********************************************************/
/**
 \class LGV_PickerScroller (Private Interfaces)
 \brief This class allows you to specify a view that can
        let a user scroll through a list of choices, presented
        by an array.
 */
@interface LGV_PickerScroller ()
@property (strong, nonatomic)       LGV_PrizeWheelScroller  *scroller;          ///< This is the scrolling surface for the view.

- (void)setUpScroller;                                                          ///< This instantiates the scroller object.
- (void)setCurrentItem;                                                     ///< This will display the current item.
- (UIView *)createItemViewForItem:(LGV_PickerScrollerArrayItem *)item;          ///< This returns a UIView, loaded with the image and title.
@end

/*********************************************************/
/**
 \class LGV_PickerScroller
 \brief This class allows you to specify a view that can
        let a user scroll through a list of choices, presented
        by an array.
 */
@implementation LGV_PickerScroller
@synthesize scroller;           ///< (Private) This is the scrolling surface for the view.

@synthesize scrollingItems;     ///< This array of LGV_PickerScrollerArrayItem objects contains the items to be scrolled.
@synthesize horizontal = _horizontal;   ///< YES, if the scroller is horizontal, as opposed to vertical. This is NO by default.
@synthesize textColor;          ///< The color of the text to be displayed. If left alone, the text will be black.
@synthesize font;               ///< The font to be used. If left alone, then System Bold will be used (size autoadjusted).
@synthesize value = _value;     ///< The selected item index (0-based).
@synthesize scroll_sensitivity = _scroll_sensitivity; ///< The sensitivity of the scroller.

#pragma mark - Public Superclass Overridden Methods -
/*********************************************************/
/**
 \brief Lays out the subviews necessary for display.
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setUpScroller];
    [self setCurrentItem];
}

#pragma mark - Private Instance Methods -
/*********************************************************/
/**
 \brief Sets up the scroller.
 */
- (void)setUpScroller
{
    if ( ![self scroller] ) // We only do this once.
        {
        [self setScroller:[[LGV_PrizeWheelScroller alloc] initWithFrame:[self bounds]]];

        // Make sure that the scroller is transparent.
        [[self scroller] setBackgroundColor:[UIColor clearColor]];
        
        // Make sure it will resize properly.
        [[self scroller] setAutoresizingMask:[self autoresizingMask]];
        
        // It should write often.
        [[self scroller] setDelegate:self];
        
        // Add our new gesture recognizer.
        [self addSubview:[self scroller]];
        
        [self setScroll_sensitivity:s_LGV_PickerScroller_Default_Increment];
        
        [[self scroller] setReverseSingleClicks:YES];
        }
    
    [[self scroller] setHorizontal:[self horizontal]];
}

/*********************************************************/
/**
 \brief Displays the current item from the list.
        This displays 3 views: One above, the selected item,
        and one below. The above and below are faded.
 */
- (void)setCurrentItem
{
    // Remove the previous items
    for ( UIView *sub in [self subviews] )
        {
        if ( sub != [self scroller] )   // Don't delete the scroller.
            {
            [sub removeFromSuperview];
            }
        }
    
    // These are the three views that we'll be displaying.
    LGV_PickerScrollerArrayItem *aboveItem = [self value] > 0 ? [[self scrollingItems] objectAtIndex:[self value] - 1] : nil;
    LGV_PickerScrollerArrayItem *selectedItem = [[self scrollingItems] objectAtIndex:[self value]];
    LGV_PickerScrollerArrayItem *belowItem = [self value] < [self maxValue] ? [[self scrollingItems] objectAtIndex:[self value] + 1] : 0;
    
    // Create the three display views.
    UIView  *aboveView = ([aboveItem cachedView] != nil) ? [aboveItem cachedView] : [self createItemViewForItem:aboveItem];
    UIView  *selectedView = ([selectedItem cachedView] != nil) ? [selectedItem cachedView] : [self createItemViewForItem:selectedItem];
    UIView  *belowView = ([belowItem cachedView] != nil) ? [belowItem cachedView] : [self createItemViewForItem:belowItem];
    
    [aboveItem setCachedView:aboveView];
    [selectedItem setCachedView:selectedView];
    [belowItem setCachedView:belowView];
    
    // The above and below are translucent.
    [aboveView setAlpha:0.25];
    [selectedView setAlpha:1.0];
    [belowView setAlpha:0.25];
    
    // Offset the two views that will be bumped.
    CGRect  aboveViewRect = [aboveView bounds];
    CGRect  selectedViewRect = [selectedView bounds];
    CGRect  belowViewRect = [belowView bounds];
    
    aboveViewRect.origin = CGPointZero;
    
    if ( [self horizontal] )
        {
        selectedViewRect.origin.x = aboveViewRect.origin.x + aboveViewRect.size.width + s_LGV_PickerScroller_Padding;
        belowViewRect.origin.x = selectedViewRect.origin.x + selectedViewRect.size.width + s_LGV_PickerScroller_Padding;
        }
    else
        {
        selectedViewRect.origin.y = aboveViewRect.origin.y + aboveViewRect.size.height + s_LGV_PickerScroller_Padding;
        belowViewRect.origin.y = selectedViewRect.origin.y + selectedViewRect.size.height + s_LGV_PickerScroller_Padding;
        }
    
    [aboveView setFrame:aboveViewRect];
    [selectedView setFrame:selectedViewRect];
    [belowView setFrame:belowViewRect];
    
    [aboveView setUserInteractionEnabled:NO];
    [selectedView setUserInteractionEnabled:NO];
    [belowView setUserInteractionEnabled:NO];
    
    // We now have three views to be displayed. If we are at a limit, then one of the views will be blank.
    
    [self insertSubview:aboveView belowSubview:[self scroller]];
    [self insertSubview:selectedView belowSubview:[self scroller]];
    [self insertSubview:belowView belowSubview:[self scroller]];
}

/*********************************************************/
/**
 \brief Creates a view that has the item image and title set
        appropriately for the orientation of the control.
 \returns a new UIView, set up and ready to go.
 */
- (UIView *)createItemViewForItem:(LGV_PickerScrollerArrayItem *)item   ///< The item to display.
{
    // We now shrink the frame, the direction is depending on whether we are horizontal or vertical.
    CGRect  newBounds = [self bounds];
    CGRect  imageRect = { CGPointZero, [self imageSize] };
    CGRect  titleRect = { CGPointZero, CGSizeMake (imageRect.size.height, imageRect.size.height) };
    
    if ( [self horizontal] )    // The view will be 1/3 the current container view.
        {
        newBounds.size.width = (newBounds.size.width - (s_LGV_PickerScroller_Padding * 2)) / 3.0;
        titleRect.origin.y = imageRect.size.height + s_LGV_PickerScroller_Padding;
        titleRect.size.height = [self bounds].size.height - (imageRect.size.height + s_LGV_PickerScroller_Padding);
        }
    else
        {
        newBounds.size.height = (newBounds.size.height - (s_LGV_PickerScroller_Padding * 2)) / 3.0;
        titleRect.origin.x = imageRect.size.width + s_LGV_PickerScroller_Padding;
        titleRect.size.width = [self bounds].size.width - (imageRect.size.width + s_LGV_PickerScroller_Padding);
        }
    
    // Create a new empty view with this frame.
    UIView *ret = [[UIView alloc] initWithFrame:newBounds];
    
    [ret setBackgroundColor:[UIColor clearColor]];  // The view needs to be transparent.
    
    if ( item != nil )   // If we have an item, then we create the view filler. Otherwise, it is left empty.
        {
        if ( [item title] && ![self image_only] )
            {
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleRect];
            
            [titleLabel setBackgroundColor:[UIColor clearColor]];
            
            [titleLabel setText:[item title]];
            
            if ( [self horizontal] )
                {
                [titleLabel setTextAlignment:NSTextAlignmentCenter];
                }
            
            [ret addSubview:titleLabel];
            }
        
        if ( [item image] )
            {
            if ( [[[item image] class] isSubclassOfClass:[UIImage class]] ) // If the image is an actual image, we set up an image view for it.
                {
                UIImageView *displayedImage = [[UIImageView alloc] initWithFrame:imageRect];
                
                [displayedImage setContentMode:UIViewContentModeScaleAspectFill];
                
                [displayedImage setImage:(UIImage *)[item image]];
                
                [ret addSubview:displayedImage];
                }
            else if ( [[[item image] class] isSubclassOfClass:[UIColor class]] )
                {
                UIView *displayedColor = [[UIView alloc] initWithFrame:imageRect];
                [displayedColor setBackgroundColor:(UIColor *)[item image]];   // Otherwise, we simply set the background of the view
                
                [ret addSubview:displayedColor];
                }
            
            }
        }
    
    return ret;
}

#pragma mark - Public Instance Methods -
/*********************************************************/
/**
 \brief This returns the size of the display area for images.
        Images will be scaled to fit, but this is good for the aspect.
 \returns the size of the view reserved for images.
 */
- (CGSize)imageSize
{
    // We now shrink the frame, the direction is depending on whether we are horizontal or vertical.
    CGSize  ret = [self bounds].size;
    
    if ( [self horizontal] )    // The view will be 1/3 the current container view.
        {
        ret.width = (ret.width - (s_LGV_PickerScroller_Padding * 2)) / 3.0;    // Horizontal will display 3 views, side-by-side.
        if ( ![self image_only] )   // Image only uses the entire rect.
            {
            ret.height = ret.width;
            }
        }
    else
        {
        ret.height = (ret.height - (s_LGV_PickerScroller_Padding * 2)) / 3.0;    // Horizontal will display 3 views, side-by-side.
        if ( ![self image_only] )   // Image only uses the entire rect.
            {
            ret.width = ret.height;
            }
        }
    
    return ret;
}

/*********************************************************/
/**
 \brief Returns the currently selected item.
 \returns a LGV_PickerScrollerArrayItem object that is the currently selected item.
 */
- (LGV_PickerScrollerArrayItem *)currentItem
{
    return [[self scrollingItems] objectAtIndex:[self value]];
}

/*********************************************************/
/**
 \brief Sets a new value. The range is is 0 -> [self maxValue].
 */
- (void)setValue:(NSInteger)value   ///< The new value to set.
{
    value = MIN( MAX(0, value), [self maxValue] );  // We can't be less than 0, or more than the number of items.
    
    _value = value;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [self setNeedsLayout];
}

/*********************************************************/
/**
 \brief When the view orientation changes, we need to start from scratch.
 */
- (void)setHorizontal:(BOOL)isHoriz
{
    _horizontal = isHoriz;
    for ( LGV_PickerScrollerArrayItem *item in [self scrollingItems] )
        {
        [item setCachedView:nil];   // Make sure we nuke all the caches.
        }
    [self setNeedsLayout];
}

/*********************************************************/
/**
 \brief Sets the scrolling audible feedback on or off.
 */
- (void)setAudible_feedback:(BOOL)isOn
{
    [[self scroller] setAudibleFeedback:isOn];  // Just straight through to the scroller.
}

/*********************************************************/
/**
 \brief Sets the scroller sensitivity.
 */
- (void)setScroll_sensitivity:(float)sensitivity    //< This is a positive, nonzero floating point number. The default value is 0.25. The higher the value, the faster and less accurate the scroll.
{
    _scroll_sensitivity = sensitivity;
    [[self scroller] setIncrementValue:[self scroll_sensitivity]];
}

/*********************************************************/
/**
 \brief Returns the highest possible value for the picker.
 \returns an integer. The range is is 0 -> [self maxValue].
 */
- (NSInteger)maxValue
{
    return MAX ( [[self scrollingItems] count] - 1, 0 );
}

#pragma mark - LGV_PrizeWheelScroller Delegate Funtions -
/*********************************************************/
/**
 \brief Called when one of the scrollers is moved.
 */
- (void)prizeWheelScrollerMoved:(LGV_PrizeWheelScroller *)scroller  ///< The Scroller object
               byThisManyClicks:(NSInteger)numberOfMoves            ///< The number of moves to be made in this call.
{
    [self setValue:[self value] - numberOfMoves];
#ifdef DEBUG
    NSLog(@"LGV_PickerScroller::prizeWheelScrollerMoved: with this many clicks %ld, and the current value is %ld", (long)numberOfMoves, (long)[self value]);
#endif
}

@end
