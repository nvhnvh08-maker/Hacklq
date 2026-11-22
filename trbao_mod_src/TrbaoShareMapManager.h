//
//  TrbaoShareMapManager.h
//  TrbaoMod VIP - Quản lý tính năng Chia Sẻ Map (Share Map)
//  Tác giả: by trbaomod
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TrbaoShareMapDelegate <NSObject>
@optional
- (void)shareMapStatusDidChange:(NSString *)statusText isLive:(BOOL)isLive;
- (void)shareMapCodeDidGenerate:(NSString *)sessionCode;
@end

@interface TrbaoShareMapManager : NSObject

@property (nonatomic, weak) id<TrbaoShareMapDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isSharing;
@property (nonatomic, copy, readonly) NSString *currentSessionCode;
@property (nonatomic, copy, readonly) NSString *statusMessage;

+ (instancetype)sharedManager;

// Bật / tắt chức năng share map
- (void)startSharing;
- (void)stopSharing;
- (void)toggleSharing;

// Tạo mã mới ngẫu nhiên 6 ký tự
- (NSString *)generateNewSessionCode;

// Mở trang web xem map trên Safari
- (void)openWebMap;

// Sao chép mã phòng vào Clipboard
- (void)copySessionCodeToClipboard;

// Cập nhật và gửi dữ liệu telemetry trận đấu (vị trí hero, quái, trụ, máu...)
- (void)broadcastTelemetryPlayers:(NSArray<NSDictionary *> *)players towers:(NSArray<NSDictionary *> *)towers state:(NSString *)state;

@end

NS_ASSUME_NONNULL_END
