//
//  LGV_SimplePrefs.h
//  LGV_SimplePrefs
/// \version 1.0
//
//

#import <Foundation/Foundation.h>

/**************************************************************//**
 \class LGV_SimplePrefs
 \brief This class is a global SINGLETON instance with all of the
        prefs.
 *****************************************************************/
@interface LGV_SimplePrefs : NSObject
+ (LGV_SimplePrefs *)simplePrefs;
+ (void)setObject:(NSObject *)value atKey:(NSString *)key;
+ (NSObject *)getObjectAtKey:(NSString *)key;
@end
