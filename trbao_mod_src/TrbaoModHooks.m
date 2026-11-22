//
//  TrbaoModHooks.m
//  TrbaoMod VIP - Runtime Method Swizzling & Tweak Injection
//  Tác giả: by trbaomod (thay thế ttsmod)
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "TrbaoFloatingButton.h"
#import "TrbaoModViewController.h"
#import "TrbaoShareMapManager.h"

// =========================================================================
// 1. FLOATING WINDOW CHẠM XUYÊN THẤU (PASSTHROUGH TOUCH WINDOW)
// =========================================================================
@interface TrbaoFloatingWindow : UIWindow
@end

@implementation TrbaoFloatingWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self || hitView == self.rootViewController.view) {
        return nil; // Chạm xuyên thấu xuống màn hình game Liên Quân Mobile!
    }
    return hitView; // Nút tròn hoặc menu nhận cảm ứng bình thường!
}
@end

static TrbaoFloatingWindow *gTrbaoWindow = nil;

// =========================================================================
// 2. MANAGER ĐIỀU KHIỂN FLOATING BUTTON & MENU
// =========================================================================
@interface TrbaoModManager : NSObject <TrbaoFloatingButtonDelegate, TrbaoModViewControllerDelegate>
+ (instancetype)sharedManager;
- (void)setupFloatingButton;
@end

@implementation TrbaoModManager

+ (instancetype)sharedManager {
    static TrbaoModManager *mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[TrbaoModManager alloc] init];
    });
    return mgr;
}

- (void)setupFloatingButton {
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            if (gTrbaoWindow) return; // Đã khởi tạo rồi
            
            UIWindowScene *activeScene = nil;
            if (@available(iOS 13.0, *)) {
                for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                    if ([scene isKindOfClass:[UIWindowScene class]] && scene.activationState == UISceneActivationStateForegroundActive) {
                        activeScene = (UIWindowScene *)scene;
                        break;
                    }
                }
                if (!activeScene) {
                    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                        if ([scene isKindOfClass:[UIWindowScene class]]) {
                            activeScene = (UIWindowScene *)scene;
                            break;
                        }
                    }
                }
            }
            
            if (@available(iOS 13.0, *)) {
                if (activeScene) {
                    gTrbaoWindow = [[TrbaoFloatingWindow alloc] initWithWindowScene:activeScene];
                } else {
                    gTrbaoWindow = [[TrbaoFloatingWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                }
            } else {
                gTrbaoWindow = [[TrbaoFloatingWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            }
            
            gTrbaoWindow.backgroundColor = [UIColor clearColor];
            gTrbaoWindow.windowLevel = UIWindowLevelAlert + 1000;
            gTrbaoWindow.hidden = NO;
            
            UIViewController *rootVC = [[UIViewController alloc] init];
            rootVC.view.backgroundColor = [UIColor clearColor];
            rootVC.view.userInteractionEnabled = YES;
            gTrbaoWindow.rootViewController = rootVC;
            
            TrbaoFloatingButton *button = [TrbaoFloatingButton sharedInstance];
            button.delegate = self;
            [rootVC.view addSubview:button];
            [button show];
            
            NSLog(@"[TrbaoMod] Khởi tạo TrbaoFloatingButton thành công!");
        } @catch (NSException *exception) {
            NSLog(@"[TrbaoMod] Lỗi khởi tạo Floating Button: %@", exception);
        }
    });
}

#pragma mark - TrbaoFloatingButtonDelegate

- (void)floatingButtonDidTap:(id)sender {
    UIViewController *rootVC = gTrbaoWindow.rootViewController;
    if (rootVC) {
        [[TrbaoModViewController sharedInstance] showMenuFromViewController:rootVC];
    }
}

#pragma mark - TrbaoModViewControllerDelegate

- (void)modMenuDidDismiss {
    // Menu đóng lại
}

- (void)modMenuThemeDidChange:(TrbaoThemeMode)themeMode {
    [[TrbaoFloatingButton sharedInstance] applyThemeBlack:(themeMode == TrbaoThemeModeMonochrome)];
}

@end

// =========================================================================
// 3. AUTO INJECTION KHI APP KHỞI ĐỘNG (CONSTRUCTOR INJECTION)
// =========================================================================
__attribute__((constructor)) static void initTrbaoMod(void) {
    NSLog(@"[TrbaoMod] Loading TrbaoMod VIP - by trbaomod...");
    
    // Đăng ký nhận thông báo khi app đã active hoặc finish launching
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        [[TrbaoModManager sharedManager] setupFloatingButton];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[TrbaoModManager sharedManager] setupFloatingButton];
    });
}
