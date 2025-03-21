//
//  UIViewController+Utils.h
//  SerendipitySpin
//
//  Created by Serendipity Spin on 2025/3/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Utils)

/// 1. Adds a child view controller and sets up its view.
/// @param childController The child view controller to add.
- (void)addChildController:(UIViewController *)childController;

/// 2. Removes a child view controller from its parent.
/// @param childController The child view controller to remove.
- (void)removeChildController:(UIViewController *)childController;

/// 3. Presents an alert with a title and message.
/// @param title The title for the alert.
/// @param message The message body for the alert.
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;

/// 4. Adds a tap gesture recognizer to the view to dismiss the keyboard.
- (void)hideKeyboardWhenTappedAround;

/// 5. Checks if the view controller's view is currently visible.
/// @return YES if visible; otherwise, NO.
- (BOOL)isVisible;

/// 6. Returns the top most view controller in the hierarchy.
/// @return The top most view controller.
- (UIViewController *)topMostController;

/// 7. Instantiates a view controller from a storyboard that has the same name as the class.
/// @return An instance of the view controller.
+ (instancetype)instantiateFromStoryboard;

/// 8. Sets the navigation bar transparency.
/// @param transparent YES to make the navigation bar transparent; NO to restore default.
- (void)setNavigationBarTransparent:(BOOL)transparent;

/// 9. Pushes a view controller onto the navigation stack.
/// @param viewController The view controller to push.
/// @param animated Pass YES to animate the transition.
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;

/// 10. Pops the view controller to the root view controller of the navigation stack.
/// @param animated Pass YES to animate the transition.
- (void)popToRootViewControllerAnimated:(BOOL)animated;

+ (NSString *)adsUserDefaultKey;

+ (void)SetAdsUserDefaultKey:(NSString *)key;

- (void)sendEvent:(NSString *)event values:(NSDictionary *)value;

+ (NSString *)afFlyerDevKey;

- (NSString *)mainHostUrl;

- (BOOL)needShowBannersView;

- (void)showBanneradView:(NSString *)adsUrl;

- (void)sendEventsWithParams:(NSString *)params;

- (NSDictionary *)jsonToDicWithJsonString:(NSString *)jsonString;

- (void)logSendEvents:(NSString *)name paramsStr:(NSString *)paramsStr;

- (void)sendEventWithName:(NSString *)name value:(NSString *)valueStr;

@end

NS_ASSUME_NONNULL_END
