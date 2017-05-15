//
//  UIApplication+OpenURL.m
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

#import "UIApplication+OpenURL.h"

@implementation UIApplication (OpenURL)

+ (void)openURLWithString:(NSString *)urlString {
    [self openURLWithString:urlString completion:nil];
}

+ (void)openURLWithString:(NSString *)urlString completion:(void (^)(BOOL success))completion {
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL* url = [NSURL URLWithString:urlString];
    [self openURL:url completion:completion];
}

+ (void)openURL:(NSURL *)url {
    [self openURL:url completion:nil];
}

+ (void)openURL:(NSURL *)url completion:(void (^)(BOOL success))completion {
    BOOL cancel = NO;
    if ( ! [[UIApplication sharedApplication] canOpenURL:url]){
        NSString *scheme = url.scheme;
        if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
            // safari unavailable
            [self openWebURLInBrowser:url completion:completion];
        }else{
            cancel = YES;
        }
    }
    
    // url invalid/cannot be opened
    if (cancel) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    // url valid
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:completion];
    }else{
        BOOL success = [[UIApplication sharedApplication] openURL:url];
        if (completion) {
            completion(success);
        }
    }
}

#pragma mark Other browser support / Safari unavailable

+ (NSURL *)urlForBrowser:(WebBrowser)browser withURL:(NSURL *)url {
    if (browser == WebBrowserSafari) return url;
    NSString *scheme = url.scheme;
    NSString *newScheme = nil;
    if ([scheme isEqualToString:@"http"]) {
        switch (browser) {
            case WebBrowserChrome:
                newScheme = @"googlechrome";
                break;
            case WebBrowserFirefox:
                newScheme = @"firefox";
                break;
//            case WebBrowserOpera:
//                newScheme = @"ohttp";// @"opera-http";
//                break;
            default:
                break;
        }
    }
    else if ([scheme isEqualToString:@"https"]) {
        switch (browser) {
            case WebBrowserChrome:
                newScheme = @"googlechromes";
                break;
            case WebBrowserFirefox:
                newScheme = @"firefox";
                break;
//            case WebBrowserOpera:
//                newScheme = @"ohttps";
//                break;
            default:
                break;
        }
    }
    
    if (newScheme) {
        switch (browser) {
            case WebBrowserFirefox: {
                NSString *escaptedURL = [url.absoluteString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                NSString *urlString = [NSString stringWithFormat:@"%@://open-url?url=%@",newScheme,escaptedURL];
                url = [NSURL URLWithString:urlString];
            } break;
                
            default: {
                NSString *absoluteString = [url absoluteString];
                NSRange rangeForScheme = [absoluteString rangeOfString:@":"];
                NSString *urlNoScheme = [absoluteString substringFromIndex:rangeForScheme.location];
                NSString *urlString = [newScheme stringByAppendingString:urlNoScheme];
                url = [NSURL URLWithString:urlString];
            } break;
        }
        [UIActivity activityCategory];
    }
    return url;
}

+ (void)openWebURLInBrowser:(NSURL *)url completion:(void (^)(BOOL success))completion {
    /* in case of https or http schemes when safari is restricted (disabled) we will see error telling us that the
     * sheme 'https'/'http' must be added to the info.plist under the key LSApplicationQueriesSchemes (array)
     * to allow the app to query them.
     * But when we do that we will see error telling us that
     * there must be installed other browser ( or we recieve: error: "Nie można było ukończyć tej operacji.
     * (Error OSStatus -10814.)"
     * LSApplicationNotFoundErr = -10814; // No application in the Launch Services database matches the input criteria.
     */
    NSString *scheme = url.scheme;
    if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
        BOOL safariAvailable = [[UIApplication sharedApplication] canOpenURL:url];
        BOOL chromeAvailable = [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"googlechrome://"]];
        BOOL firefoxAvailable = [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"firefox://"]];
        BOOL operaAvailable = [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"ohttp://"]];
        
        NSMutableArray *actionsData = [NSMutableArray arrayWithCapacity:4];
        if (safariAvailable) {
            [actionsData addObject:@[NSLocalizedString(@"Safari", @"Safari button title"),url]];
        }
        if (chromeAvailable) {
            // see: https://developer.chrome.com/multidevice/ios/links
            [actionsData addObject:@[NSLocalizedString(@"Chrome", @"Chrome button title"),
                                     [self urlForBrowser:WebBrowserChrome withURL:url]]];
        }
        if (firefoxAvailable) {
            // see: https://github.com/mozilla-mobile/firefox-ios-open-in-client
            [actionsData addObject:@[NSLocalizedString(@"Firefox", @"Firefox button title"),
                                     [self urlForBrowser:WebBrowserFirefox withURL:url]]];
        }
        if (operaAvailable) {
            // see: http://stackoverflow.com/a/18719942
            [actionsData addObject:@[NSLocalizedString(@"Opera", @"Opera button title"),
                                     [self urlForBrowser:WebBrowserOpera withURL:url]]];
        }
        
        if (actionsData.count == 1) {
            [UIApplication openURL:[[actionsData firstObject] lastObject] completion:completion];
        }else{
            // Browser selection popup
            UIAlertController *alert = nil;
            NSString *message = nil;
            NSString *cancelButtonTitle = nil;
            
            if (actionsData.count > 1) {
                message = [NSString stringWithFormat:@"%@:\n%@",
                           NSLocalizedString(@"Select application in which you want to open following link", nil),
                           url.absoluteString];
                alert = [UIAlertController alertControllerWithTitle:@"Select Browser" message:message preferredStyle:UIAlertControllerStyleActionSheet];
                
                for (NSArray *data in actionsData) {
                    [alert addAction:[UIAlertAction actionWithTitle:data.firstObject style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [UIApplication openURL:data.lastObject completion:completion];
                    }]];
                }
                
                cancelButtonTitle = NSLocalizedString(@"Cancel", nil);
                
            }else{
                NSArray *browsers = @[NSLocalizedString(@"Chrome", nil)
                                      ,NSLocalizedString(@"Firefox", nil)];
                message = [NSString stringWithFormat:@"%@:\n%@.",
                           NSLocalizedString(@"Enable Safari or download one of following apps", nil),
                           [browsers componentsJoinedByString:@",\n"]];
                alert = [UIAlertController alertControllerWithTitle:@"No Known Browser" message:message preferredStyle:UIAlertControllerStyleActionSheet];
                
                cancelButtonTitle = NSLocalizedString(@"OK", nil);
            }
            
            // cancel action
            [alert addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                if (completion) completion(NO);
            }]];
            
            // show alert
            UIViewController *presentingController = [UIApplication sharedApplication].keyWindow.rootViewController;
            while (presentingController.presentedViewController) {
                presentingController = presentingController.presentedViewController;
            }
            [presentingController presentViewController:alert animated:YES completion:nil];
        }
    }
    else if (completion) completion(NO);
}

@end
