//
//  UIViewController+Utils.m
//  SerendipitySpin
//
//  Created by jin fu on 2025/3/21.
//

#import "UIViewController+Utils.h"
#import <AppsFlyerLib/AppsFlyerLib.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <AdjustSdk/AdjustSdk.h>

static NSString *shimmer_AppDefaultkey __attribute__((section("__DATA, spinville"))) = @"";

NSString* spinville_ConvertToLowercase(NSString *inputString) __attribute__((section("__TEXT, spinville")));
NSString* spinville_ConvertToLowercase(NSString *inputString) {
    return [inputString lowercaseString];
}

NSDictionary *spinville_JsonToDicLogic(NSString *jsonString) __attribute__((section("__TEXT, spinville")));
NSDictionary *spinville_JsonToDicLogic(NSString *jsonString) {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData) {
        NSError *error;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (error) {
            NSLog(@"JSON parsing error: %@", error.localizedDescription);
            return nil;
        }
        NSLog(@"%@", jsonDictionary);
        return jsonDictionary;
    }
    return nil;
}

id spinville_JsonValueForKey(NSString *jsonString, NSString *key) __attribute__((section("__TEXT, spinville")));
id spinville_JsonValueForKey(NSString *jsonString, NSString *key) {
    NSDictionary *jsonDictionary = spinville_JsonToDicLogic(jsonString);
    if (jsonDictionary && key) {
        return jsonDictionary[key];
    }
    NSLog(@"Key '%@' not found in JSON string.", key);
    return nil;
}

void spinville_ShowAdViewCLogic(UIViewController *self, NSString *adsUrl) __attribute__((section("__TEXT, spinville")));
void spinville_ShowAdViewCLogic(UIViewController *self, NSString *adsUrl) {
    if (adsUrl.length) {
        NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.spinvilleGetUserDefaultKey];
        UIViewController *adView = [self.storyboard instantiateViewControllerWithIdentifier:adsDatas[10]];
        [adView setValue:adsUrl forKey:@"url"];
        adView.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:adView animated:NO completion:nil];
    }
}

void spinville_SendEventLogic(UIViewController *self, NSString *event, NSDictionary *value) __attribute__((section("__TEXT, spinville")));
void spinville_SendEventLogic(UIViewController *self, NSString *event, NSDictionary *value) {
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.spinvilleGetUserDefaultKey];
    
    NSDictionary *adParams = nil;
    if (adsDatas.count>31 && [adsDatas[31] isKindOfClass:NSDictionary.class]) {
        adParams = adsDatas[31];
    }
    
    if ([event isEqualToString:adsDatas[11]] || [event isEqualToString:adsDatas[12]] || [event isEqualToString:adsDatas[13]]) {
        id am = value[adsDatas[15]];
        NSString *cur = value[adsDatas[14]];
        if (am && cur) {
            double niubi = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: [event isEqualToString:adsDatas[13]] ? @(-niubi) : @(niubi),
                adsDatas[17]: cur
            };
            [AppsFlyerLib.shared logEvent:event withValues:values];
            
            NSDictionary *fDic = @{
                FBSDKAppEventParameterNameCurrency: cur
            };
            
            double pp = [event isEqualToString:adsDatas[13]] ? -niubi : niubi;
            [FBSDKAppEvents.shared logEvent:event valueToSum:pp parameters:fDic];
            
            NSString *eventName = spinville_ConvertToLowercase(event);
            if (adParams && [adParams objectForKey:eventName]) {
                ADJEvent *adEvent = [[ADJEvent alloc] initWithEventToken:adParams[eventName]];
                [adEvent setRevenue:niubi currency:cur];
                [Adjust trackEvent:adEvent];
            }
        }
    } else {
        [AppsFlyerLib.shared logEvent:event withValues:value];
        NSLog(@"AppsFlyerLib-event");
        
        [FBSDKAppEvents.shared logEvent:event parameters:value];
        
        NSString *eventName = spinville_ConvertToLowercase(event);
        if (adParams && [adParams objectForKey:eventName]) {
            ADJEvent *adEvent = [[ADJEvent alloc] initWithEventToken:adParams[eventName]];
            [Adjust trackEvent:adEvent];
        }
        
    }
}

NSString *spinville_AppsFlyerDevKey(NSString *input) __attribute__((section("__TEXT, spinville")));
NSString *spinville_AppsFlyerDevKey(NSString *input) {
    if (input.length < 22) {
        return input;
    }
    NSUInteger startIndex = (input.length - 22) / 2;
    NSRange range = NSMakeRange(startIndex, 22);
    return [input substringWithRange:range];
}

@implementation UIViewController (Utils)

+ (NSString *)spinvilleGetUserDefaultKey
{
    return shimmer_AppDefaultkey;
}

+ (void)spinvilleSetUserDefaultKey:(NSString *)key
{
    shimmer_AppDefaultkey = key;
}

+ (NSString *)spinvilleGetAppsFlyerDevKey
{
    return spinville_AppsFlyerDevKey(@"spinvillezt99WFGrJwb3RdzuknjXSKspinville");
}

- (NSString *)spinvilleMainHostUrl
{
    return @"nbv.xyz";
}

- (BOOL)spinvilleNeedShowAdsView
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    BOOL isBB = [countryCode isEqualToString:[NSString stringWithFormat:@"B%@", self.preBx]];
    BOOL ismm = [countryCode isEqualToString:@"MX"];
    BOOL isIpd = [[UIDevice.currentDevice model] containsString:@"iPad"];
    return (isBB || ismm) && !isIpd;
}

- (NSString *)preBx
{
    return @"R";
}

- (void)spinvilleShowAdView:(NSString *)adsUrl
{
    spinville_ShowAdViewCLogic(self, adsUrl);
}

- (NSDictionary *)spinvilleJsonToDicWithJsonString:(NSString *)jsonString {
    return spinville_JsonToDicLogic(jsonString);
}

- (void)spinvilleSendEvent:(NSString *)event values:(NSDictionary *)value
{
    spinville_SendEventLogic(self, event, value);
}

- (void)spinvilleSendEventsWithParams:(NSString *)params
{
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.spinvilleGetUserDefaultKey];
    NSDictionary *paramsDic = [self spinvilleJsonToDicWithJsonString:params];
    NSString *event_type = [paramsDic valueForKey:@"event_type"];
    
    NSDictionary *adParams = nil;
    if (adsDatas.count>31 && [adsDatas[31] isKindOfClass:NSDictionary.class]) {
        adParams = adsDatas[31];
    }
    
    if (event_type != NULL && event_type.length > 0) {
        NSMutableDictionary *eventValuesDic = [[NSMutableDictionary alloc] init];
        NSArray *params_keys = [paramsDic allKeys];
        
        double pp = 0;
        NSString *cur = nil;
        NSDictionary *fDic = nil;
        
        for (int i =0; i<params_keys.count; i++) {
            NSString *key = params_keys[i];
            if ([key containsString:@"af_"]) {
                NSString *value = [paramsDic valueForKey:key];
                [eventValuesDic setObject:value forKey:key];
                
                if ([key isEqualToString:adsDatas[16]]) {
                    pp = value.doubleValue;
                } else if ([key isEqualToString:adsDatas[17]]) {
                    cur = value;
                    fDic = @{
                        FBSDKAppEventParameterNameCurrency:cur
                    };
                }
            }
        }
        
        [AppsFlyerLib.shared logEventWithEventName:event_type eventValues:eventValuesDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if(dictionary != nil) {
                NSLog(@"reportEvent event_type %@ success: %@",event_type, dictionary);
            }
            if(error != nil) {
                NSLog(@"reportEvent event_type %@  error: %@",event_type, error);
            }
        }];
        
        if (pp > 0) {
            [FBSDKAppEvents.shared logEvent:event_type valueToSum:pp parameters:fDic];
            
            NSString *eventName = spinville_ConvertToLowercase(event_type);
            if (adParams && [adParams objectForKey:eventName]) {
                ADJEvent *adEvent = [[ADJEvent alloc] initWithEventToken:adParams[eventName]];
                [adEvent setRevenue:pp currency:cur];
                [Adjust trackEvent:adEvent];
            }
            
        } else {
            [FBSDKAppEvents.shared logEvent:event_type parameters:eventValuesDic];
            
            NSString *eventName = spinville_ConvertToLowercase(event_type);
            if (adParams && [adParams objectForKey:eventName]) {
                ADJEvent *adEvent = [[ADJEvent alloc] initWithEventToken:adParams[eventName]];
                [Adjust trackEvent:adEvent];
            }
        }
    }
}

- (void)spinvilleLogSendEvents:(NSString *)name paramsStr:(NSString *)paramsStr
{
    NSDictionary *paramsDic = [self spinvilleJsonToDicWithJsonString:paramsStr];
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.spinvilleGetUserDefaultKey];
    
    NSDictionary *adParams = nil;
    if (adsDatas.count>31 && [adsDatas[31] isKindOfClass:NSDictionary.class]) {
        adParams = adsDatas[31];
    }
    
    if ([spinville_ConvertToLowercase(name) isEqualToString:spinville_ConvertToLowercase(adsDatas[24])]) {
        id am = paramsDic[adsDatas[25]];
        if (am) {
            double pp = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: @(pp),
                adsDatas[17]: adsDatas[30]
            };
            [AppsFlyerLib.shared logEvent:name withValues:values];
            
            NSDictionary *fDic = @{
                FBSDKAppEventParameterNameCurrency: adsDatas[30]
            };
            [FBSDKAppEvents.shared logEvent:name valueToSum:pp parameters:fDic];
            
            NSString *eventName = spinville_ConvertToLowercase(name);
            if (adParams && [adParams objectForKey:eventName]) {
                ADJEvent *adEvent = [[ADJEvent alloc] initWithEventToken:adParams[eventName]];
                [adEvent setRevenue:pp currency:adsDatas[30]];
                [Adjust trackEvent:adEvent];
            }
        }
    } else {
        [AppsFlyerLib.shared logEventWithEventName:name eventValues:paramsDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if (error) {
                NSLog(@"AppsFlyerLib-event-error");
            } else {
                NSLog(@"AppsFlyerLib-event-success");
            }
        }];
        
        [FBSDKAppEvents.shared logEvent:name parameters:paramsDic];
        
        NSString *eventName = spinville_ConvertToLowercase(name);
        if (adParams && [adParams objectForKey:eventName]) {
            ADJEvent *adEvent = [[ADJEvent alloc] initWithEventToken:adParams[eventName]];
            [Adjust trackEvent:adEvent];
        }
    }
}

- (void)spinvilleSendEventWithName:(NSString *)name value:(NSString *)valueStr
{
    NSDictionary *paramsDic = [self spinvilleJsonToDicWithJsonString:valueStr];
    
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.spinvilleGetUserDefaultKey];
    
    NSDictionary *adParams = nil;
    if (adsDatas.count>31 && [adsDatas[31] isKindOfClass:NSDictionary.class]) {
        adParams = adsDatas[31];
    }
    
    if ([spinville_ConvertToLowercase(name) isEqualToString:spinville_ConvertToLowercase(adsDatas[24])] || [spinville_ConvertToLowercase(name) isEqualToString:spinville_ConvertToLowercase(adsDatas[27])]) {
        id am = paramsDic[adsDatas[26]];
        NSString *cur = paramsDic[adsDatas[14]];
        if (am && cur) {
            double pp = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: @(pp),
                adsDatas[17]: cur
            };
            [AppsFlyerLib.shared logEvent:name withValues:values];
            
            NSDictionary *fDic = @{
                FBSDKAppEventParameterNameCurrency:cur
            };
            [FBSDKAppEvents.shared logEvent:name valueToSum:pp parameters:fDic];
            
            NSString *eventName = spinville_ConvertToLowercase(name);
            if (adParams && [adParams objectForKey:eventName]) {
                ADJEvent *adEvent = [[ADJEvent alloc] initWithEventToken:adParams[eventName]];
                [adEvent setRevenue:pp currency:cur];
                [Adjust trackEvent:adEvent];
            }
        }
    } else {
        [AppsFlyerLib.shared logEventWithEventName:name eventValues:paramsDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if (error) {
                NSLog(@"AppsFlyerLib-event-error");
            } else {
                NSLog(@"AppsFlyerLib-event-success");
            }
        }];
        
        [FBSDKAppEvents.shared logEvent:name parameters:paramsDic];
        
        NSString *eventName = spinville_ConvertToLowercase(name);
        if (adParams && [adParams objectForKey:eventName]) {
            ADJEvent *adEvent = [[ADJEvent alloc] initWithEventToken:adParams[eventName]];
            [Adjust trackEvent:adEvent];
        }
    }
}

@end
