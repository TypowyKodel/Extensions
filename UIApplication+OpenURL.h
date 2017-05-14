//
//  UIApplication+OpenURL.h
//
//
//  Created by Grzegorz Em on 20.02.2017.
//  Copyright © 2017 Grzegorz Em. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WebBrowser) {
    WebBrowserSafari,
    WebBrowserChrome,
    WebBrowserFirefox,
    WebBrowserOpera, // opera seems to be not supported any more and and also its schemes don't work, i couldn't find new ones
};

@interface UIApplication (OpenURL)

+ (void)openURLWithString:(NSString *)urlString;
+ (void)openURLWithString:(NSString *)urlString completion:(void (^)(BOOL success))completion;
+ (void)openURL:(NSURL *)url;
+ (void)openURL:(NSURL *)url completion:(void (^)(BOOL success))completion;

/** Usefull in case when safari may be restricted (disabled)
 
 To use other browsers you need to add their schemes to the LSApplicationQueriesSchemes (array)
 in the info.plist file of your app.
 Add following schemes to support other browsers or case when safari is restricted (disabled):
 
 googlechrome
 googlechromes
 firefox
 
 // folowing two are fro Opera Mini but they do not work anymore
 ohttp
 ohttps
 */
+ (void)openWebURLInBrowser:(NSURL *)url completion:(void (^)(BOOL success))completion;
+ (NSURL *)urlForBrowser:(WebBrowser)browser withURL:(NSURL *)url;

@end
