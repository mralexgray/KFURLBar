
#import "KFWebKitProgressController.h"
#import <WebKit/WebView.h>

@interface KFWebKitProgressController () @property (nonatomic) NSInteger resourceCount, resourceFailedCount, resourceCompletedCount; @end

@implementation KFWebKitProgressController

- (void) updateResourceStatus {

   _delegate &&
  [_delegate respondsToSelector:@selector(webKitProgressDidChangeFinishedCount:ofTotalCount:)]
  ? [_delegate webKitProgressDidChangeFinishedCount:(_resourceCompletedCount + _resourceFailedCount) ofTotalCount:_resourceCount]
  : NSLog(@"WARNING: unresponsive delegate...%@... progress: %lu of %lu",_delegate, (_resourceCompletedCount + _resourceFailedCount), _resourceCount);
}

- (void)webView:(WebView*)s didReceiveTitle:(NSString *)t forFrame:(WebFrame *)f { f != s.mainFrame ?: [s.window setTitle:t]; }

- (id)webView:(WebView*)s identifierForInitialRequest:(NSURLRequest*)r fromDataSource:(WebDataSource*)d { return @(_resourceCount++); }

- (NSURLRequest*) webView:(WebView*)s resource:(id)r            willSendRequest:(NSURLRequest*)q
                              redirectResponse:(NSURLResponse*)e fromDataSource:(WebDataSource*)d {
  ![_delegate respondsToSelector:NSSelectorFromString(@"setAddressString:")] ?:
   [_delegate setValue:q.URL.absoluteString forKey:@"addressString"];
   NSLog(@"%@",q.URL.absoluteString);
  [self updateResourceStatus]; return q;
}
- (void) webView:(WebView*)s resource:(id)r didFailLoadingWithError:(NSError*)e fromDataSource:(WebDataSource *)d {

    _resourceFailedCount++; [self updateResourceStatus];
}
- (void) webView:(WebView*)s resource:(id)i didFinishLoadingFromDataSource:(WebDataSource *)d
{
    self.resourceCompletedCount++;  [self updateResourceStatus];
}
- (void) webView:(WebView*)s didStartProvisionalLoadForFrame:(WebFrame*)frame {

}
@end
