//
//  TrbaoModConfig.h
//  TrbaoMod VIP - Liên Quân Mobile
//  Tác giả: by trbaomod (thay thế hoàn toàn ttsmod)
//

#ifndef TrbaoModConfig_h
#define TrbaoModConfig_h

#import <UIKit/UIKit.h>

// Phiên bản và thương hiệu
#define TRBAO_MOD_NAME          @"TRBAO MOD VIP"
#define TRBAO_MOD_SUBTITLE      @"by trbaomod"
#define TRBAO_MOD_VERSION       @"v3.8.0"

// Link web share map đã deploy chính thức
#define TRBAO_SHARE_MAP_URL     @"https://nvhnvh08-maker.github.io/Hacklq"
#define TRBAO_SHARE_MAP_BACKEND @"https://map.yong38.com"
#define TRBAO_SHARE_MAP_WS_HOST @"map.yong38.com"

// Kiểu giao diện Theme
typedef NS_ENUM(NSInteger, TrbaoThemeMode) {
    TrbaoThemeModeOLEDBlack = 0,     // Nền đen sâu (OLED Black)
    TrbaoThemeModeMonochrome = 1     // Đen trắng (Monochrome Grayscale)
};

// Khóa lưu cấu hình NSUserDefaults
#define K_THEME_MODE            @"trbaomod_theme_mode"
#define K_SHARE_MAP_ENABLED     @"trbaomod_share_map_enabled"
#define K_CURRENT_SESSION_CODE  @"trbaomod_current_session_code"
#define K_MAP_HACK_ENABLED      @"trbaomod_map_hack_enabled"
#define K_SHOW_ULTI_ENABLED     @"trbaomod_show_ulti_enabled"
#define K_SHOW_JUNGLE_ENABLED   @"trbaomod_show_jungle_enabled"
#define K_CAM_XA_LEVEL          @"trbaomod_cam_xa_level"

#endif /* TrbaoModConfig_h */
