//
//  TrbaoModViewController.h
//  TrbaoMod VIP - Menu Điều Khiển Tính Năng
//  Tác giả: by trbaomod
//

#import <UIKit/UIKit.h>
#import "TrbaoModConfig.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TrbaoModViewControllerDelegate <NSObject>
@optional
- (void)modMenuDidDismiss;
- (void)modMenuThemeDidChange:(TrbaoThemeMode)themeMode;
@end

@interface TrbaoModViewController : UIViewController

@property (nonatomic, weak) id<TrbaoModViewControllerDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)showMenuFromViewController:(UIViewController *)parentVC;
- (void)dismissMenu;

// Trạng thái các chức năng mod toàn cục
+ (BOOL)isMapHackEnabled;
+ (BOOL)isShowUltiEnabled;
+ (BOOL)isShowJungleEnabled;
+ (CGFloat)camXaLevel;
+ (TrbaoThemeMode)currentThemeMode;

@end

NS_ASSUME_NONNULL_END
