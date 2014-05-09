
#import "KFURLBar_Private.h"


@implementation KFURLBar (Convenience) 

+ (instancetype)instanceWithRequestBlock:(StringBlock)blk {

  KFURLBar *b = self.new; [b initializeDefaults];  b.didRequestURL = blk; return b;
}

-   (id) initWithFrame:(NSRect)f                {

  return self = [super initWithFrame:f] ? [self initializeDefaults], self : nil;
}
-   (id) initWithCoder:(NSCoder*)c              {

	return self = [super initWithCoder:c] ? [self initializeDefaults], self : nil;
}

@end
@implementation KFURLBar (ViewFromArray)

- (NSDictionary*)        viewsFromArray:(NSArray*)views withBaseName:(NSString*)baseName {

  return ({ NSMutableDictionary *result = NSMutableDictionary.new;
  for (NSView *view in views) result[[NSString stringWithFormat:@"%@%lu", baseName, [views indexOfObject:view]]] = view; result; });

}
-     (NSString*) visualFormatFromArray:(NSArray*)vs withBaseName:(NSString*)baseN {  NSMutableArray *x = NSMutableArray.new;

  for (NSUInteger ct = 0; ct < vs.count; ct++)  [x addObject:[NSString stringWithFormat:@"[%@%lu]", baseN, ct]];

  return x.count ? [NSString stringWithFormat:@"-%@-", [x componentsJoinedByString:@"-"]] : @"-";
}
@end



