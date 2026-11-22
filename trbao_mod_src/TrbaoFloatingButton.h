//
//  TrbaoFloatingButton.h
//  TrbaoMod VIP - Cục Menu Nổi Kéo Thả (Floating Button)
//  Tác giả: by trbaomod
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TrbaoFloatingButtonDelegate <NSObject>
- (void)floatingButtonDidTap:(id)sender;
@end

@interface TrbaoFloatingButton : UIView

@property (nonatomic, weak) id<TrbaoFloatingButtonDelegate> delegate;
@property (nonatomic, strong) UIButton *circleButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *badgeLabel;
@property (nonatomic, assign) BOOL isMenuOpen;
@property (nonatomic, assign) BOOL isLiveSharing;

+ (instancetype)sharedInstance;

- (void)show;
- (void)hide;
- (void)setLiveBadge:(BOOL)isLive;
- (void)applyThemeBlack:(BOOL)isMonochrome;

@end

NS_ASSUME_NONNULL_END
