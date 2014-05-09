
#import "KFURLBar_Private.h"

@interface                             KFURLBar () <KFWebKitProgressDelegate>
@property                                  BOOL   drawBackground;
@property                           NSTextField * urlTextField;
@property                               NSArray * fieldConstraints,
* leftItems,
* rightItems;
@property                              NSButton * loadButton;
@property (readonly) KFWebKitProgressController * controller;
@property                               NSColor * currentBarColorTop,
* currentBarColorBottom;
@end

@implementation KFURLBar

- (void) viewWillMoveToSuperview:(NSView*)newS  {

  //  self.drawBackground = ![newS.className isEqualToString:@"NSToolbarFullScreenContentView"];
}
- (void) initializeDefaults     {
  _progress       = .0f;
  _cornerRadius   = 2.5f;
  _progressPhase  = KFProgNone;
  _addressString  = @"http://";
  _drawBackground = YES;
  _gradientColorTop     = kKFURLBarGradientColorTop;
  _gradientColorBottom  = kKFURLBarGradientColorBottom;
  _borderColorTop       = kKFURLBarBorderColorTop;
  _borderColorBottom    = kKFURLBarBorderColorBottom;

  [self addSubview:_urlTextField = NSTextField.new];
  [@[@"translatesAutoresizingMaskIntoConstraints", @"drawsBackground",@"bezeled"]
   enumerateObjectsUsingBlock:^(id k, NSUInteger x, BOOL *s){ [_urlTextField setValue:@NO forKey:k]; }];
  _urlTextField.focusRingType = NSFocusRingTypeNone;
  _urlTextField.font          = [NSFont fontWithName:@"UbuntuMono-Bold" size:14];
  _urlTextField.textColor     = NSColor.blackColor;
  _urlTextField.formatter     = KFURLFormatter.new;

  [_urlTextField.cell setLineBreakMode:NSLineBreakByTruncatingTail];

  [self addSubview:_loadButton = NSButton.new];
  _loadButton.translatesAutoresizingMaskIntoConstraints = NO;
  _loadButton.bezelStyle      = NSRoundedBezelStyle;
  _urlTextField.target        = _loadButton.target = self;
  _urlTextField.action        = _loadButton.action = @selector(didPressEnter:);
  _loadButton.title  = @"GO!";

  LAYOUTRELATIVE(_urlTextField, NSLayoutAttributeCenterY, NSLayoutRelationEqual, self, NSLayoutAttributeCenterY, 1, 0);
  LAYOUTRELATIVE(_loadButton,   NSLayoutAttributeCenterY, NSLayoutRelationEqual, self, NSLayoutAttributeCenterY, 1, 0);

  _controller = [KFWebKitProgressController new];
  _controller.delegate = self;

  [_urlTextField bind:@"stringValue" toObject:self withKeyPath:@"addressString" options:nil];

  [self updateFieldConstraints];

}
- (void) updateFieldConstraints {

  NSMutableDictionary *views = NSDictionaryOfVariableBindings(_urlTextField, _loadButton).mutableCopy;

  [views addEntriesFromDictionary: _leftItems.count ? [self viewsFromArray:_leftItems  withBaseName: @"leftItem"] : @{}];
  [views addEntriesFromDictionary:_rightItems.count ? [self viewsFromArray:_rightItems withBaseName:@"rightItem"] : @{}];

  !_fieldConstraints ?: [self removeConstraints:_fieldConstraints];

  NSString *vS = [NSString stringWithFormat:@"|-(12)%@[_urlTextField]%@(20)-[_loadButton]-(8)-|",
                  [self visualFormatFromArray:_leftItems withBaseName:@"leftItem"],
                  [self visualFormatFromArray:_rightItems withBaseName:@"rightItem"]];
  NSLog(@"%@", vS);
  [self addConstraints:_fieldConstraints = [NSLayoutConstraint constraintsWithVisualFormat:vS options:0 metrics:nil views:views]];
  [self setNeedsDisplay:YES];
}


- (void) didPressEnter:(id)x                {

  //  [_i.animator setAlphaValue:1];  [_i startAnimation:nil];  [[(NSButton*)_i.superview animator] setBordered:NO];
  if (self.didRequestURL) _didRequestURL(_urlTextField.stringValue);
  //    if (self.delegate && [self validateUrl:self.urlTextField.stringValue])
  //    {
  //        [self.delegate urlBar:self didRequestURL:[NSURL URLWithString:self.urlTextField.stringValue]];
  else { self.progressPhase = KFProgPending;
    if (_webview) _webview.mainFrameURL = _urlTextField.stringValue;
  }
  double delayInSeconds = .0;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
  dispatch_after(popTime, dispatch_get_main_queue(),^{
    ((NSText*)[_urlTextField.window fieldEditor:YES forObject:_urlTextField]).selectedRange = NSMakeRange(0, 0); // fieldEditor
    [_urlTextField.window makeFirstResponder:nil];
  });

}
- (BOOL)   validateUrl:(NSString*)candidate {
  return YES;
}

- (CGFloat) barWidthForProtocol             { NSInteger prtclIdx;

  if ((prtclIdx = [self.urlTextField.stringValue rangeOfString:@"://"].location) == NSNotFound) return 0;

  return NSMinX(self.urlTextField.frame) + [[_urlTextField.stringValue substringToIndex:prtclIdx + 3] // measureStr
                                            sizeWithAttributes:@{NSFontAttributeName:_urlTextField.font}].width; // measured
}

- (void)    drawRect:(NSRect)r  {

  //// Color Declarations
  static NSColor * fillColor,  * strokeColor, *color, *color4, *color5, * color6;

  fillColor = fillColor ?: ({
    strokeColor = [NSColor colorWithCalibratedRed: 0 green: 0 blue: 0 alpha: 0.2];
    color = [NSColor colorWithCalibratedRed: 0.57 green: 0.57 blue: 0.57 alpha: 1];
    [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 1];
  });

  color4 = _progressPhase == KFProgPending      ? [NSColor colorWithCalibratedWhite:.8 alpha:.8] :
  _progressPhase == KFProgDownloading  ? [NSColor colorForControlTint:NSColor.currentControlTint]
  : color4;
  color5 = _progressPhase == KFProgPending      ? [NSColor colorWithCalibratedWhite:.8 alpha:.4] :
  _progressPhase == KFProgDownloading  ? [[NSColor colorForControlTint:NSColor.currentControlTint] colorWithAlphaComponent:.6]
  : color5;
  color = _progressPhase != KFProgDownloading ? color : [NSColor colorWithCalibratedRed:.45 green:.45 blue: .45 alpha:1];


  color6 = color6 ?: [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 0];

  NSGradient* progressGradient = [NSGradient.alloc initWithStartingColor: color5 endingColor: color4];

  //// Shadow Declarations
  static NSShadow* shadow;
  shadow                  = shadow ?: NSShadow.new;
  shadow.shadowColor      = strokeColor;
  shadow.shadowOffset     = NSMakeSize(0.1, -1.1);
  shadow.shadowBlurRadius = 3;

  //// Frames
  NSRect frame   = self.bounds;
  CGFloat barEnd = !self.rightItems.count ? NSMaxX(self.urlTextField.frame)
  : NSMaxX([self.rightItems.lastObject frame]) - 4;

  if (_drawBackground)
  {
    //// Background Drawing
    if (_gradientColorTop && self.gradientColorBottom)
      [[NSGradient.alloc initWithStartingColor:self.gradientColorTop endingColor:self.gradientColorBottom] drawInRect:self.bounds angle:-90.0];

    [NSBezierPath setDefaultLineWidth:0.0f];
    if (self.borderColorTop)
    {
      [self.borderColorTop setStroke];
      [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds))
                                toPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds))];
    }
  }
  if (_borderColorBottom)
  {
    [_borderColorBottom setStroke];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(self.bounds), NSMinY(self.bounds))
                              toPoint:NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds))];
  }


  //// AddressBar Background Drawing
  NSRect barRect = NSMakeRect(NSMinX(frame) + 8.5, NSMinY(frame) + 5.5, barEnd, NSHeight(frame) - 10);
  NSBezierPath* addressBarBackgroundPath = [NSBezierPath bezierPathWithRoundedRect:barRect
                                                                           xRadius:_cornerRadius
                                                                           yRadius:_cornerRadius];
  [fillColor setFill];
  [addressBarBackgroundPath fill];
  [color setStroke];
  [addressBarBackgroundPath setLineWidth: 1];
  [addressBarBackgroundPath stroke];


  //// AddressBar Progress Drawing

  CGFloat barWidth = _progressPhase == KFProgNone       ? 0 :
  _progressPhase == KFProgPending    ? self.barWidthForProtocol :

  MAX(barEnd * self.progress, self.barWidthForProtocol);

  NSLog(@"barWidth:%@", @(barWidth));
  if (barWidth)
  {
    NSRect addrsBarProgR        = NSMakeRect(NSMinX(frame) + 8.5, NSMinY(frame) + 5.5, barWidth, NSHeight(frame) - 10);
    NSRect addrsBarProgInnerR   = NSInsetRect(addrsBarProgR, _cornerRadius, _cornerRadius);
    NSBezierPath* addrsBarProgP = NSBezierPath.new;
    [addrsBarProgP appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(addrsBarProgInnerR), NSMinY(addrsBarProgInnerR))
                                              radius:_cornerRadius startAngle: 180 endAngle: 270];
    [addrsBarProgP lineToPoint:NSMakePoint(NSMaxX(addrsBarProgR), NSMinY(addrsBarProgR))];
    [addrsBarProgP lineToPoint:NSMakePoint(NSMaxX(addrsBarProgR), NSMaxY(addrsBarProgR))];
    [addrsBarProgP appendBezierPathWithArcWithCenter: NSMakePoint(NSMinX(addrsBarProgInnerR), NSMaxY(addrsBarProgInnerR))
                                              radius:_cornerRadius startAngle: 90 endAngle: 180];
    [addrsBarProgP closePath]; [progressGradient drawInBezierPath:addrsBarProgP angle: -90];
  }

  //// AddressBar Drawing
  NSBezierPath* addressBarPath = [NSBezierPath bezierPathWithRoundedRect: NSMakeRect(NSMinX(frame) + 8.5, NSMinY(frame) + 5.5, barEnd, NSHeight(frame) - 10) xRadius: _cornerRadius yRadius: _cornerRadius];
  [color6 setFill];
  [addressBarPath fill];

  if (!addressBarPath.isEmpty)
  {
    ////// AddressBar Inner Shadow
    NSRect addressBarBorderRect = NSInsetRect(addressBarPath.bounds, -shadow.shadowBlurRadius,  -shadow.shadowBlurRadius);
    addressBarBorderRect        = NSOffsetRect(addressBarBorderRect, -shadow.shadowOffset.width, -shadow.shadowOffset.height);
    addressBarBorderRect        = NSInsetRect(NSUnionRect(addressBarBorderRect, [addressBarPath bounds]), -1, -3);

    NSBezierPath* addressBarNegativePath = [NSBezierPath bezierPathWithRect: addressBarBorderRect];
    [addressBarNegativePath appendBezierPath: addressBarPath];
    [addressBarNegativePath setWindingRule: NSEvenOddWindingRule];

    [NSGraphicsContext saveGraphicsState];
    {
      NSShadow* shadowWithOffset = shadow.copy;
      CGFloat xOffset = shadowWithOffset.shadowOffset.width + round(addressBarBorderRect.size.width),
      yOffset = shadowWithOffset.shadowOffset.height;
      shadowWithOffset.shadowOffset = NSMakeSize(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset));
      [shadowWithOffset set];
      [NSColor.lightGrayColor setFill]; [addressBarPath addClip];
      NSAffineTransform* transform = NSAffineTransform.new;
      [transform translateXBy: -round(addressBarBorderRect.size.width) yBy: 0];
      [[transform transformBezierPath:addressBarNegativePath] fill];
    }
    [NSGraphicsContext restoreGraphicsState];
  }

  [color setStroke]; [addressBarPath setLineWidth: .5];  [addressBarPath stroke];
}

- (void)      setProgress:(double)p       { if (p == _progress)      return; _progress = p; [self setNeedsDisplay:YES]; }
- (void) setProgressPhase:(KFProgPhase)p  { if (p == _progressPhase) return;

  if (_progressPhase == KFProgDownloading && p == KFProgNone)
  {
    _progress = 1.0f;
    [self setNeedsDisplay:YES];
    double delayInSeconds = .2f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                     _progress = 0;
                     _progressPhase = p;
                     [self setNeedsDisplay:YES];
                   });
  }
  else
  {
    _progressPhase = p;
    [self setNeedsDisplay:YES];
  }
  //  p == KFProgNone ? ({ [_i.animator setAlphaValue:0]; [_i stopAnimation:nil]; [(NSButton*)_i.superview setBordered:YES]; }) : nil;
}


//- (void)     setLeftItems:(NSArray*)l {

//  for (NSView *view in _leftItems)
//    if ([view.superview isEqualTo:self]) [view removeFromSuperview];

//  for (NSView *view in _leftItems = l.mutableCopy)
//  {
- (void) addItem:(id)b edge:(CGRectEdge)e  {  NSString *k = e == NSMinXEdge ? @"leftItems" : @"rightItems";

  id x = [self valueForKey:k] ?: @[];
  for (NSView *view in x)
    if ([view.superview isEqualTo:self]) [view removeFromSuperview];

  [self setValue:[x arrayByAddingObject:b] forKey:k];

  for (NSView *view in [self valueForKey:k]) {
    [self addSubview:view];
    LAYOUTRELATIVE(view, NSLayoutAttributeCenterY, NSLayoutRelationEqual, self, NSLayoutAttributeCenterY,1,0);
  }
  //  }
  [self updateFieldConstraints];
}
- (void) setWebview:(WebView *)webview { if (_webview == webview) return;

  [self bind:@"addressString" toObject:_webview = webview withKeyPath:@"mainFrameURL" options:nil];
}

//- (void)    setRightItems:(NSArray*)r {
//
//  if (_rightItems) for (NSView *view in _rightItems) if ([view.superview isEqualTo:self]) [view removeFromSuperview];
//  for (NSView *view in _rightItems = r.mutableCopy)
//  {
//    [self addSubview:view];
//    LAYOUTRELATIVE(view,NSLayoutAttributeCenterY,NSLayoutRelationEqual,self,NSLayoutAttributeCenterY,1,0);
//  }
//  [self updateFieldConstraints];
//}

#pragma mark WebKitProgressDelegate Methods

- (void) webKitProgressDidChangeFinishedCount:(NSInteger)finCt ofTotalCount:(NSInteger)totCt
{
  if (_progressUpdated) { _progressUpdated(finCt, totCt); return; }

	self.progressPhase = KFProgDownloading;
	self.progress      = (CGFloat)finCt / (CGFloat)totCt;	if (totCt != finCt) return;

  //  double delayInSeconds = 1.0;  __block KFURLBar *abar = self;
  //  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
  //  dispatch_after(popTime, dispatch_get_main_queue(), ^{ self.progressPhase = KFProgNone; });
}


- (NSButton*) reloadButton {  static NSButton *reloadButton;

  if (reloadButton) return reloadButton;

  reloadButton = NSButton.new;
  [reloadButton setTranslatesAutoresizingMaskIntoConstraints:NO];
  [reloadButton setBordered:NO];
  CALayer * l = CALayer.new;
  l.contents = [NSImage imageNamed:NSImageNameQuickLookTemplate];
  //  l.shouldRasterize = YES;

  //  l.backgroundColor = NSColor.blackColor.CGColor;
  reloadButton.layer = l;
  reloadButton.wantsLayer = YES;
  reloadButton.layer.anchorPoint = (NSPoint){.5,.5};
  //  [reloadButton setImage:r];
  CABasicAnimation *anim2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
  //  anim2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
  anim2.fromValue = @(M_PI * 2);
  anim2.toValue = @(0);
  anim2.duration = 2;
  anim2.repeatCount  = 1000;
  //  anim2.removedOnCompletion = NO;
  //    anim2.fillMode = kCAFillModeBoth;
  //    anim2.delegate = self;
  [l addAnimation:anim2 forKey:@"transform"];
  l.contentsGravity = kCAGravityResizeAspect;
  [reloadButton setTarget:self];
  [reloadButton setAction:@selector(didPressEnter:)];
  //  _i = [NSProgressIndicator.alloc initWithFrame:reloadButton.frame];
  //  _i.autoresizingMask = NSViewWidthSizable| NSViewHeightSizable;
  //  _i.style = NSProgressIndicatorSpinningStyle;
  //  _i.hidden = YES;    _i.controlSize = NSSmallControlSize;
  //  [reloadButton addSubview:_i];
  //  reloadButton.
  return reloadButton;
}
-(void)pauseLayer:(CALayer*)layer
{
  CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
  layer.speed = 0.0;
  layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer
{
  CFTimeInterval pausedTime = [layer timeOffset];
  layer.speed = 1.0;
  layer.timeOffset = 0.0;
  layer.beginTime = 0.0;
  CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
  layer.beginTime = timeSincePause;
}

@end

@implementation KFURLBar (nonessential)

+ (instancetype)instanceWithRequestBlock:(StringBlock)blk {

  KFURLBar *b = self.new; [b initializeDefaults];  b.didRequestURL = blk; return b;
}

-   (id) initWithFrame:(NSRect)f                {

  return self = [super initWithFrame:f] ? [self initializeDefaults], self : nil;
}
-   (id) initWithCoder:(NSCoder*)c              {

	return self = [super initWithCoder:c] ? [self initializeDefaults], self : nil;
}


- (NSDictionary*)        viewsFromArray:(NSArray*)views withBaseName:(NSString*)baseName {

  return ({ NSMutableDictionary *result = NSMutableDictionary.new;
    for (NSView *view in views) result[[NSString stringWithFormat:@"%@%lu", baseName, [views indexOfObject:view]]] = view; result; });

}
-     (NSString*) visualFormatFromArray:(NSArray*)vs withBaseName:(NSString*)baseN {  NSMutableArray *x = NSMutableArray.new;

  for (NSUInteger ct = 0; ct < vs.count; ct++)  [x addObject:[NSString stringWithFormat:@"[%@%lu]", baseN, ct]];

  return x.count ? [NSString stringWithFormat:@"-%@-", [x componentsJoinedByString:@"-"]] : @"-";
}
@end

/*

 NSImage *r = [NSImage imageWithSize:(NSSize){24,24} flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
 NSImage *spin = [NSImage imageNamed:NSImageNameRefreshFreestandingTemplate];
 spin.size = dstRect.size;
 [spin drawInRect:dstRect fromRect:dstRect operation:NSCompositeSourceOver fraction:1];
 [NSColor.redColor set];
 NSRectFillUsingOperation(dstRect, NSCompositeSourceAtop);
 return YES;
 }];
 r.scalesWhenResized = YES;

 - (NSString*) addressString {
 return self.urlTextField.stringValue;
 }
 - (void)setAddressString:(NSString *)addressString {
 if (addressString) self.urlTextField.stringValue = addressString;b
 }

 KFURLBarView.m
 KFURLBar

 Copyright (c) 2013 Rico Becker, KF Interactive

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 @property NSProgressIndicator *i;

 */


