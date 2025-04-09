#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "pixel_icon" asset catalog image resource.
static NSString * const ACImageNamePixelIcon AC_SWIFT_PRIVATE = @"pixel_icon";

/// The "snake_icon" asset catalog image resource.
static NSString * const ACImageNameSnakeIcon AC_SWIFT_PRIVATE = @"snake_icon";

#undef AC_SWIFT_PRIVATE
