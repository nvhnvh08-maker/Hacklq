//
//  TrbaoFloatingButton.m
//  TrbaoMod VIP - Cục Menu Nổi Kéo Thả (Floating Button)
//  Tác giả: by trbaomod
//

#import "TrbaoFloatingButton.h"
#import "TrbaoModConfig.h"

@interface TrbaoFloatingButton ()

@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) BOOL isDragging;

@end

@implementation TrbaoFloatingButton

+ (instancetype)sharedInstance {
    static TrbaoFloatingButton *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TrbaoFloatingButton alloc] initWithFrame:CGRectMake(20, 140, 56, 56)];
    });
    return instance;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.zPosition = 9999;
        
        // 1. Nút tròn chính
        self.circleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.circleButton.frame = self.bounds;
        self.circleButton.layer.cornerRadius = 28;
        self.circleButton.clipsToBounds = YES;
        self.circleButton.backgroundColor = [UIColor colorWithRed:12/255.0 green:12/255.0 blue:14/255.0 alpha:0.92];
        self.circleButton.layer.borderWidth = 1.5;
        self.circleButton.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.25].CGColor;
        
        // Đổ bóng (Shadow)
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 4);
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 8;
        
        // Chữ logo trên nút
        self.titleLabel = [[UILabel alloc] initWithFrame:self.circleButton.bounds];
        self.titleLabel.text = @"TRB";
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.userInteractionEnabled = NO;
        [self.circleButton addSubview:self.titleLabel];
        
        [self.circleButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.circleButton];
        
        // 2. Badge "LIVE" khi bật Share Map
        self.badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, -4, 32, 16)];
        self.badgeLabel.backgroundColor = [UIColor colorWithRed:239/255.0 green:68/255.0 blue:68/255.0 alpha:0.95];
        self.badgeLabel.textColor = [UIColor whiteColor];
        self.badgeLabel.font = [UIFont systemFontOfSize:9 weight:UIFontWeightBlack];
        self.badgeLabel.textAlignment = NSTextAlignmentCenter;
        self.badgeLabel.text = @"LIVE";
        self.badgeLabel.layer.cornerRadius = 8;
        self.badgeLabel.clipsToBounds = YES;
        self.badgeLabel.layer.borderWidth = 1.0;
        self.badgeLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        self.badgeLabel.hidden = YES;
        [self addSubview:self.badgeLabel];
        
        // 3. Kéo thả (Pan Gesture)
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
        
        // Đọc theme đã lưu
        NSInteger savedTheme = [[NSUserDefaults standardUserDefaults] integerForKey:K_THEME_MODE];
        [self applyThemeBlack:(savedTheme == TrbaoThemeModeMonochrome)];
    }
    return self;
}

- (void)buttonTapped:(UIButton *)sender {
    if (self.isDragging) return;
    
    // Hiệu ứng nhún nút khi bấm
    [UIView animateWithDuration:0.1 animations:^{
        self.transform = CGAffineTransformMakeScale(0.88, 0.88);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            self.transform = CGAffineTransformIdentity;
        }];
    }];
    
    if ([self.delegate respondsToSelector:@selector(floatingButtonDidTap:)]) {
        [self.delegate floatingButtonDidTap:self];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    UIView *superview = self.superview;
    if (!superview) return;
    
    CGPoint translation = [pan translationInView:superview];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.panStartPoint = self.center;
        self.isDragging = YES;
        [UIView animateWithDuration:0.1 animations:^{
            self.transform = CGAffineTransformMakeScale(1.1, 1.1);
        }];
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        self.center = CGPointMake(self.panStartPoint.x + translation.x, self.panStartPoint.y + translation.y);
    } else if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        self.isDragging = NO;
        
        // Tự động hít vào mép màn hình (Snap to Edge)
        CGRect bounds = superview.bounds;
        CGFloat screenWidth = bounds.size.width;
        CGFloat screenHeight = bounds.size.height;
        
        CGFloat midX = self.center.x;
        CGFloat targetX = (midX < screenWidth / 2.0) ? (self.frame.size.width / 2.0 + 10) : (screenWidth - self.frame.size.width / 2.0 - 10);
        
        // Giới hạn y không trôi ra ngoài notch / status bar / home indicator
        CGFloat targetY = self.center.y;
        CGFloat minY = 80;
        CGFloat maxY = screenHeight - 80;
        if (targetY < minY) targetY = minY;
        if (targetY > maxY) targetY = maxY;
        
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.center = CGPointMake(targetX, targetY);
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}

- (void)setLiveBadge:(BOOL)isLive {
    self.isLiveSharing = isLive;
    self.badgeLabel.hidden = !isLive;
    
    if (isLive) {
        self.circleButton.layer.borderColor = [UIColor colorWithRed:239/255.0 green:68/255.0 blue:68/255.0 alpha:0.9].CGColor;
    } else {
        self.circleButton.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.25].CGColor;
    }
}

- (void)applyThemeBlack:(BOOL)isMonochrome {
    if (isMonochrome) {
        // Đen trắng: Viền trắng tinh khôi, chữ trắng tuyết
        self.circleButton.backgroundColor = [UIColor colorWithWhite:0.06 alpha:0.95];
        self.circleButton.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:0.8].CGColor;
        self.titleLabel.textColor = [UIColor whiteColor];
    } else {
        // Nền đen OLED: Viền xám ánh kim cao cấp
        self.circleButton.backgroundColor = [UIColor colorWithRed:10/255.0 green:10/255.0 blue:12/255.0 alpha:0.95];
        self.circleButton.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.3].CGColor;
        self.titleLabel.textColor = [UIColor whiteColor];
    }
}

- (void)show {
    self.hidden = NO;
    self.alpha = 0.0;
    self.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1.0;
        self.transform = CGAffineTransformIdentity;
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

@end
