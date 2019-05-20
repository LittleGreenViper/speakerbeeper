//
//  LGV_SimplePrefs.m
//  LGV_SimplePrefs
/// \version 1.0
//
//
/**************************************************************/
/**
 \file  LGV_SimplePrefs.m
 \brief This file declares a simple, generic persistent state
        storage. It simply allows a dictionary to be declared
        and written out, then read back in.
        It enforces a true SINGLETON. This allows the state to
        be used pretty much anywhere in the app.
        This is a very, very simple, low-fi class. It is not a
        replacement for Core Data. It simply makes having a
        persistent state extremely easy.
 */

#import "LGV_SimplePrefs.h"

static  LGV_SimplePrefs     *s_LGV_SimplePrefs_ThePrefs = nil;      ///< The SINGLETON instance.
static  NSString            *s_LGV_SimplePrefs_DocName = @"Prefs";  ///< The default name for the document

#pragma mark - Private Instance Declarations -
/**************************************************************/
/**
 \class LGV_SimplePrefs
 \brief We want most of the instance-specific stuff hidden away.
 */
@interface LGV_SimplePrefs ()
@property (nonatomic, readwrite)    NSMutableDictionary *myData;    ///< The settings data will be kept in a dictionary.
+ (NSString *)docPath:(NSString *)inFileName;                       ///< Returns the path to the data file.
- (BOOL)saveChanges;
- (void)loadPrefs;
@end

#pragma mark - Implementation -
/**************************************************************/
/**
 \class LGV_SimplePrefs
 \brief This class is a global SINGLETON instance with all of the
        prefs.
 */
@implementation LGV_SimplePrefs
@synthesize myData;

#pragma mark - Public Instance Methods -
/**************************************************************/
/**
 \brief Initializer.
 \returns self
 */
- (id)init
{
    self = [super init];
    
    if ( self )   // First time, we'll need to initialize it.
        {
        [self loadPrefs];
        }
    
    return self;   
}

#pragma mark - Private Class Methods -
/**************************************************************/
/**
 \brief 
 \returns a string, containing the doc path with the file name.
 */
+ (NSString *)docPath:(NSString *)inFileName    ///< The name of the file to be saved.
{
    if ( !inFileName )  // No given name, we use the default.
        {
        inFileName = s_LGV_SimplePrefs_DocName;
        }
    
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSAutosavedInformationDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    return [docsPath stringByAppendingFormat:@"%@.data", inFileName];
}

#pragma mark - Private Instance Methods -
/**************************************************************/
/**
 \brief
 */
- (BOOL)saveChanges
{
    return [NSKeyedArchiver archiveRootObject:[self myData] toFile:[[self class] docPath:s_LGV_SimplePrefs_DocName]];
}

/**************************************************************/
/**
 \brief
 */
- (void)loadPrefs
{
    [self setMyData:[NSKeyedUnarchiver unarchiveObjectWithFile:[[self class] docPath:s_LGV_SimplePrefs_DocName]]];
    
    if ( ![self myData] )
        {
        [self setMyData:[[NSMutableDictionary alloc] init]];
        }
}

#pragma mark - Public Class Methods -
/**************************************************************/
/**
 \brief This gets the SINGLETON instance, and creates one, if necessary.
 \returns a reference to a BMLT_Prefs object, whic is the SINGLETON.
 */
+ (LGV_SimplePrefs *)simplePrefs
{
    // This whackiness just makes sure the prefs singleton is thread-safe.
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{ s_LGV_SimplePrefs_ThePrefs = [[LGV_SimplePrefs alloc] init]; });
    
    return s_LGV_SimplePrefs_ThePrefs;
}

/**************************************************************/
/**
 \brief Stores an object into the prefs.
 */
+ (void)setObject:(NSObject *)value ///< An object to be stored.
            atKey:(NSString *)key   ///< The key at which to store it.
{
    if ( ![[[self class] simplePrefs] myData] )   // First time, we'll need to initialize it.
        {
        [[[self class] simplePrefs] setMyData:[[NSMutableDictionary alloc] init]];
        }
    
    [[[[self class] simplePrefs] myData] setObject:value forKey:key];
    // We always immediately write out our saved data.
    [[[self class] simplePrefs] saveChanges];
}

/**************************************************************/
/**
 \brief Get the object for a key.
 \returns the fetched object. Nil if none.
 */
+ (NSObject *)getObjectAtKey:(NSString *)key    ///< The key for the object.
{
    // We always load in our saved data first.
    [[[self class] simplePrefs] loadPrefs];
    return [[[[self class] simplePrefs] myData] objectForKey:key];
}

@end
