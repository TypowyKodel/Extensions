//
//  UIApplication+OpenURL.h
//
//
//  Created by Grzegorz Maciak on 20.02.2017.
//  Copyright © 2017 Grzegorz Maciak. All rights reserved.
//

/*
 This code is distributed under the terms and conditions of the MIT license:
 
 Copyright (c) 2017 Grzegorz Maciak
 
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
 */

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
 
 // folowing two are for Opera Mini but they do not work anymore
 ohttp
 ohttps
 */
+ (void)openWebURLInBrowser:(NSURL *)url completion:(void (^)(BOOL success))completion;
+ (NSURL *)urlForBrowser:(WebBrowser)browser withURL:(NSURL *)url;

@end
