

@import WebKit;
@import QuartzCore;
#import "KFURLBar.h"
#import "KFURLFormatter.h"
#import "KFWebKitProgressController.h"

#define LAYOUTRELATIVE(A,B,C,D,E,F,G) [self addConstraints:@[[NSLayoutConstraint constraintWithItem:A attribute:B relatedBy:C toItem:D attribute:E multiplier:F constant:G]]]

#define kKFURLBarGradientColorTop     [NSColor colorWithCalibratedRed:.9 green:.9 blue:.9f alpha:1.]
#define kKFURLBarGradientColorBottom  [NSColor colorWithCalibratedRed:.7 green:.7 blue:.7 alpha:1.]
#define kKFURLBarBorderColorTop       [NSColor   colorWithDeviceWhite:.6 alpha:1.]
#define kKFURLBarBorderColorBottom    [NSColor   colorWithDeviceWhite:.2 alpha:1.]

@interface KFURLBar (Main)
- (void) initializeDefaults;
@end

@interface KFURLBar (ViewFromArray)

- (NSDictionary*)        viewsFromArray:(NSArray*)v withBaseName:(NSString*)b;
-     (NSString*) visualFormatFromArray:(NSArray*)v withBaseName:(NSString*)b;
@end

