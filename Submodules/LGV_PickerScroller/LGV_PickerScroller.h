//
//  LGV_PickerScroller.h
//  LGV_PickerScroller
/// \version 1.0.2
//
//  Created by Chris Marshall on 7/30/12.
//  Copyright (c) 2012 Little Green Viper Software Development LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGV_PrizeWheelScroller.h"

/*********************************************************/
/**
 \class LGV_PickerScrollerArrayItem
 \brief This class contains items for use by the scroller.
        This will form each array item.
 */
@interface LGV_PickerScrollerArrayItem : NSObject
@property (nonatomic, readwrite)   NSString     *title;     ///< The name of the object.
@property (nonatomic, readwrite)   NSObject     *image;     ///< A picture that represents the object. This can be a UIImage or a UIColor.
@property (nonatomic, readwrite)   id           refCon;     ///< Any additional data that we want to associate with the object.

- (id)initWithTitle:(NSString *)title andImage:(NSObject *)image andRefCon:(id)refCon;    ///< Initializer
@end

/*********************************************************/
/**
 \class LGV_PickerScroller
 \brief This class allows you to specify a view that can
        let a user scroll through a list of choices, presented
        by an array.
 */
@interface LGV_PickerScroller : UIControl <LGV_PrizeWheelScrollerDelegate>
@property (nonatomic, readwrite)    NSArray         *scrollingItems;        ///< This array of LGV_PickerScrollerArrayItem objects contains the items to be scrolled.
@property (nonatomic, readwrite)    BOOL            horizontal;             ///< YES, if the scroller is horizontal, as opposed to vertical. This is NO by default.
@property (nonatomic, readwrite)    BOOL            image_only;             ///< YES, if the only thing to display is the image.
@property (nonatomic, readwrite)    BOOL            audible_feedback;       ///< If YES, then the scroller will use the default sounds to produce audible scrolling feedback. Defauly is NO.
@property (readwrite, nonatomic)    UIColor         *textColor;             ///< The color of the text to be displayed. If left alone, the text will be black.
@property (readwrite, nonatomic)    UIFont          *font;                  ///< The font to be used. If left alone, then System Bold will be used (size autoadjusted).
@property (readwrite, nonatomic)    NSInteger       value;                  ///< The selected item index (0-based).
@property (readwrite, nonatomic)    float           scroll_sensitivity;     ///< The sensitivity of the scroller. Default is 0.25.

- (LGV_PickerScrollerArrayItem *)currentItem;                               ///< Returns the currently selected item.
- (NSInteger)maxValue;                                                      ///< Return the maximum possible value.
- (CGSize)imageSize;                                                        ///< This returns the size of the display area for images. Images will be scaled to fit, but this is good for the aspect.
@end
