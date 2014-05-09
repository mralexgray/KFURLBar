#import <Cocoa/Cocoa.h>

typedef NS_ENUM(int, KFProgPhase) { KFProgNone,  KFProgPending,  KFProgDownloading};

typedef void (^StringBlock)     (NSString*req);
typedef BOOL (^URLValidator) (NSString*isV);

@interface KFURLBar : NSView

@property (copy)        StringBlock   didRequestURL;
@property (copy)       URLValidator   urlValidator;
@property (nonatomic)        double   progress;
@property (nonatomic)   KFProgPhase   progressPhase;
@property (nonatomic)       CGFloat   cornerRadius;
//@property (nonatomic,weak) NSString * addressString;
@property (nonatomic)       NSColor * gradientColorTop,
                                    * gradientColorBottom,
                                    * borderColorTop,
                                    * borderColorBottom,
                                    * barColorPendingTop,
                                    * barColorPendingBottom,
                                    * barColorDownloadingTop,
                                    * barColorDownloadingBottom,
                                    * addressString;

@property (nonatomic) NSArray *leftItems, *rightItems;

+ (instancetype)instanceWithRequestBlock:(StringBlock)b;

- (void) setDidRequestURL:(StringBlock)b;
- (void)  setUrlValidator:(URLValidator)b;

@end


//Delegate:(id<KFURLBarDelegate>)delegate;
//@class KFURLBar; @protocol KFURLBarDelegate <NSObject>
//- (void)urlBar:(KFURLBar *)urlBar didRequestURL:(NSURL *)url;
//@optional
//- (void)urlBarColorConfig;
//- (BOOL)urlBar:(KFURLBar *)urlBar isValidRequestStringValue:(NSString *)requestString;
//@end
//@property (nonatomic, weak) id<KFURLBarDelegate> delegate;

//
//  KFURLBarView.h
//  KFURLBar
//
//  Copyright (c) 2013 Rico Becker, KF Interactive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


