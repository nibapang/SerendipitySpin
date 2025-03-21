//
//  UIViewController+Utils.h
//  SerendipitySpin
//
//  Created by jin fu on 2025/3/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Utils)

+ (NSString *)spinvilleGetUserDefaultKey;

+ (void)spinvilleSetUserDefaultKey:(NSString *)key;

- (void)spinvilleSendEvent:(NSString *)event values:(NSDictionary *)value;

+ (NSString *)spinvilleGetAppsFlyerDevKey;

- (NSString *)spinvilleMainHostUrl;

- (BOOL)spinvilleNeedShowAdsView;

- (void)spinvilleShowAdView:(NSString *)adsUrl;

- (void)spinvilleSendEventsWithParams:(NSString *)params;

- (NSDictionary *)spinvilleJsonToDicWithJsonString:(NSString *)jsonString;

- (void)spinvilleLogSendEvents:(NSString *)name paramsStr:(NSString *)paramsStr;

- (void)spinvilleSendEventWithName:(NSString *)name value:(NSString *)valueStr;

@end

NS_ASSUME_NONNULL_END
