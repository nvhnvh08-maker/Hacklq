//
//  TrbaoModViewController.m
//  TrbaoMod VIP - Menu Điều Khiển Tính Năng
//  Tác giả: by trbaomod (thay thế ttsmod)
//

#import "TrbaoModViewController.h"
#import "TrbaoShareMapManager.h"
#import "TrbaoFloatingButton.h"

@interface TrbaoModViewController () <TrbaoShareMapDelegate>

// Container chính
@property (nonatomic, strong) UIView *dimBackgroundView;
@property (nonatomic, strong) UIView *menuCardView;
@property (nonatomic, strong) UIScrollView *contentScrollView;

// Header
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIButton *closeButton;

// Tab Bar (Segmented Control)
@property (nonatomic, strong) UISegmentedControl *tabSegmentedControl;

// Các view của từng tab
@property (nonatomic, strong) UIView *tab1View; // Chức năng Hack/Mod
@property (nonatomic, strong) UIView *tab2View; // Tools (Share Map)
@property (nonatomic, strong) UIView *tab3View; // Giao diện (Nền đen / Đen trắng)

// Components Tab 2 (Tools / Share Map)
@property (nonatomic, strong) UISwitch *shareMapSwitch;
@property (nonatomic, strong) UIView *shareMapBoxView;
@property (nonatomic, strong) UILabel *codeTitleLabel;
@property (nonatomic, strong) UILabel *codeDisplayLabel;
@property (nonatomic, strong) UILabel *statusBadgeLabel;
@property (nonatomic, strong) UIButton *copyCodeButton;
@property (nonatomic, strong) UIButton *openWebButton;
@property (nonatomic, strong) UIButton *refreshCodeButton;

// Components Tab 3 (Theme)
@property (nonatomic, strong) UISegmentedControl *themeSegmentedControl;
@property (nonatomic, strong) UISlider *opacitySlider;
@property (nonatomic, strong) UILabel *opacityValueLabel;

// State
@property (nonatomic, assign) TrbaoThemeMode currentTheme;

@end

@implementation TrbaoModViewController

+ (instancetype)sharedInstance {
    static TrbaoModViewController *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TrbaoModViewController alloc] init];
    });
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Đọc theme đã lưu
    self.currentTheme = (TrbaoThemeMode)[[NSUserDefaults standardUserDefaults] integerForKey:K_THEME_MODE];
    
    [TrbaoShareMapManager sharedManager].delegate = self;
    
    [self setupBaseLayout];
    [self setupHeader];
    [self setupTabBar];
    [self setupTab1Content]; // Mod Hack
    [self setupTab2Content]; // Tools - Share Map
    [self setupTab3Content]; // Giao diện - Nền đen / Đen trắng
    
    [self applyTheme:self.currentTheme];
    [self switchTabToIndex:0]; // Mặc định mở Tab 1
}

#pragma mark - Khởi tạo Giao diện Cơ bản

- (void)setupBaseLayout {
    self.view.backgroundColor = [UIColor clearColor];
    
    // Nền tối mờ phía sau
    self.dimBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.dimBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.dimBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    UITapGestureRecognizer *tapDim = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMenu)];
    [self.dimBackgroundView addGestureRecognizer:tapDim];
    [self.view addSubview:self.dimBackgroundView];
    
    // Khung Menu Card trung tâm (kích thước tối ưu cho cả iPhone và iPad ngang dọc)
    CGFloat menuWidth = 360;
    CGFloat menuHeight = 490;
    CGFloat x = (self.view.bounds.size.width - menuWidth) / 2.0;
    CGFloat y = (self.view.bounds.size.height - menuHeight) / 2.0;
    
    self.menuCardView = [[UIView alloc] initWithFrame:CGRectMake(x, y, menuWidth, menuHeight)];
    self.menuCardView.layer.cornerRadius = 20;
    self.menuCardView.clipsToBounds = YES;
    self.menuCardView.layer.borderWidth = 1.2;
    
    // Shadow
    self.menuCardView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.menuCardView.layer.shadowOffset = CGSizeMake(0, 10);
    self.menuCardView.layer.shadowOpacity = 0.6;
    self.menuCardView.layer.shadowRadius = 16;
    
    [self.view addSubview:self.menuCardView];
}

#pragma mark - Header (Branding by trbaomod)

- (void)setupHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.menuCardView.bounds.size.width, 68)];
    [self.menuCardView addSubview:header];
    
    // Tên menu chính
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 14, 260, 24)];
    self.titleLabel.text = TRBAO_MOD_NAME;
    self.titleLabel.font = [UIFont systemFontOfSize:19 weight:UIFontWeightHeavy];
    [header addSubview:self.titleLabel];
    
    // Chữ "by trbaomod" (thay thế ttsmod theo lệnh sếp)
    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 39, 260, 18)];
    self.subtitleLabel.text = [NSString stringWithFormat:@"%@ • %@", TRBAO_MOD_SUBTITLE, TRBAO_MOD_VERSION];
    self.subtitleLabel.font = [UIFont systemFontOfSize:12.5 weight:UIFontWeightMedium];
    [header addSubview:self.subtitleLabel];
    
    // Nút Đóng (X)
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.frame = CGRectMake(self.menuCardView.bounds.size.width - 48, 16, 34, 34);
    [self.closeButton setTitle:@"✕" forState:UIControlStateNormal];
    self.closeButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    self.closeButton.layer.cornerRadius = 17;
    [self.closeButton addTarget:self action:@selector(dismissMenu) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:self.closeButton];
    
    // Đường kẻ phân cách
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(16, 67, self.menuCardView.bounds.size.width - 32, 0.8)];
    divider.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.12];
    [header addSubview:divider];
}

#pragma mark - Segmented Tab Bar

- (void)setupTabBar {
    NSArray *items = @[@"Chức Năng", @"Tools (Map)", @"Giao Diện"];
    self.tabSegmentedControl = [[UISegmentedControl alloc] initWithItems:items];
    self.tabSegmentedControl.frame = CGRectMake(16, 78, self.menuCardView.bounds.size.width - 32, 34);
    self.tabSegmentedControl.selectedSegmentIndex = 0;
    [self.tabSegmentedControl addTarget:self action:@selector(tabChanged:) forControlEvents:UIControlEventValueChanged];
    [self.menuCardView addSubview:self.tabSegmentedControl];
    
    // Scroll container cho nội dung tab
    CGFloat contentY = 120;
    CGFloat contentH = self.menuCardView.bounds.size.height - contentY - 10;
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, contentY, self.menuCardView.bounds.size.width, contentH)];
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    [self.menuCardView addSubview:self.contentScrollView];
}

#pragma mark - Tab 1: Chức Năng Hack / Mod

- (void)setupTab1Content {
    self.tab1View = [[UIView alloc] initWithFrame:self.contentScrollView.bounds];
    
    CGFloat y = 8;
    // 1. Map Sáng
    [self.tab1View addSubview:[self createToggleRowWithTitle:@"Bản Đồ Sáng (Map Hack)" subtitle:@"Hiển thị toàn bộ tướng địch trong sương" key:K_MAP_HACK_ENABLED y:&y]];
    
    // 2. Hiện Ultimate & Bổ Trợ
    [self.tab1View addSubview:[self createToggleRowWithTitle:@"Hiện Hồi Chiêu & Ulti" subtitle:@"Xem thời gian hồi chiêu và phép bổ trợ địch" key:K_SHOW_ULTI_ENABLED y:&y]];
    
    // 3. Hiện Vị Trí Rừng & Timer Quái
    [self.tab1View addSubview:[self createToggleRowWithTitle:@"Hiện Vị Trí Rừng / Timer" subtitle:@"Thông báo quái rừng và hướng di chuyển địch" key:K_SHOW_JUNGLE_ENABLED y:&y]];
    
    // 4. Slider Cam Xa
    UILabel *camTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 200, 20)];
    camTitle.text = @"Khoảng Cách Camera (Cam Xa)";
    camTitle.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    camTitle.textColor = [UIColor whiteColor];
    [self.tab1View addSubview:camTitle];
    y += 24;
    
    UISlider *camSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, y, self.menuCardView.bounds.size.width - 40, 30)];
    camSlider.minimumValue = 1.0;
    camSlider.maximumValue = 2.5;
    camSlider.value = [[NSUserDefaults standardUserDefaults] floatForKey:K_CAM_XA_LEVEL] ?: 1.3;
    [camSlider addTarget:self action:@selector(camSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.tab1View addSubview:camSlider];
    y += 40;
    
    self.tab1View.frame = CGRectMake(0, 0, self.menuCardView.bounds.size.width, y + 20);
    [self.contentScrollView addSubview:self.tab1View];
}

#pragma mark - Tab 2: TOOLS (CHIA SẺ MAP - SHARE MAP)

- (void)setupTab2Content {
    self.tab2View = [[UIView alloc] initWithFrame:self.contentScrollView.bounds];
    self.tab2View.hidden = YES;
    
    CGFloat y = 8;
    
    // Hộp tính năng Chia Sẻ Map
    self.shareMapBoxView = [[UIView alloc] initWithFrame:CGRectMake(16, y, self.menuCardView.bounds.size.width - 32, 330)];
    self.shareMapBoxView.layer.cornerRadius = 16;
    self.shareMapBoxView.layer.borderWidth = 1.0;
    [self.tab2View addSubview:self.shareMapBoxView];
    
    // Tiêu đề chức năng + Switch
    UILabel *boxTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, 200, 22)];
    boxTitle.text = @"Chia Sẻ Map Trực Tiếp";
    boxTitle.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    boxTitle.textColor = [UIColor whiteColor];
    [self.shareMapBoxView addSubview:boxTitle];
    
    UILabel *boxDesc = [[UILabel alloc] initWithFrame:CGRectMake(16, 38, 200, 16)];
    boxDesc.text = @"Phát sóng minimap qua web";
    boxDesc.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    boxDesc.textColor = [UIColor colorWithWhite:0.65 alpha:1.0];
    [self.shareMapBoxView addSubview:boxDesc];
    
    self.shareMapSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.shareMapBoxView.bounds.size.width - 66, 20, 50, 30)];
    self.shareMapSwitch.on = [TrbaoShareMapManager sharedManager].isSharing;
    [self.shareMapSwitch addTarget:self action:@selector(shareMapSwitchToggled:) forControlEvents:UIControlEventValueChanged];
    [self.shareMapBoxView addSubview:self.shareMapSwitch];
    
    // Đường ngăn cách
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16, 68, self.shareMapBoxView.bounds.size.width - 32, 0.8)];
    line.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    [self.shareMapBoxView addSubview:line];
    
    // Khung hiển thị Mã Phòng
    self.codeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 80, self.shareMapBoxView.bounds.size.width - 32, 18)];
    self.codeTitleLabel.text = @"MÃ PHÒNG XEM TRỰC TIẾP";
    self.codeTitleLabel.font = [UIFont systemFontOfSize:11.5 weight:UIFontWeightBold];
    self.codeTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.codeTitleLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    [self.shareMapBoxView addSubview:self.codeTitleLabel];
    
    // Badge hiển thị mã to rõ nét
    UIView *codeContainer = [[UIView alloc] initWithFrame:CGRectMake((self.shareMapBoxView.bounds.size.width - 200)/2.0, 102, 200, 48)];
    codeContainer.layer.cornerRadius = 12;
    codeContainer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.08];
    codeContainer.layer.borderWidth = 1.0;
    codeContainer.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.25].CGColor;
    [self.shareMapBoxView addSubview:codeContainer];
    
    self.codeDisplayLabel = [[UILabel alloc] initWithFrame:codeContainer.bounds];
    self.codeDisplayLabel.text = [TrbaoShareMapManager sharedManager].currentSessionCode;
    self.codeDisplayLabel.font = [UIFont fontWithName:@"Courier-Bold" size:24] ?: [UIFont monospacedDigitSystemFontOfSize:24 weight:UIFontWeightBlack];
    self.codeDisplayLabel.textAlignment = NSTextAlignmentCenter;
    self.codeDisplayLabel.textColor = [UIColor whiteColor];
    [codeContainer addSubview:self.codeDisplayLabel];
    
    // Nút "Sao Chép Mã"
    self.copyCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.copyCodeButton.frame = CGRectMake(20, 162, 136, 38);
    [self.copyCodeButton setTitle:@"📋 Sao Chép Mã" forState:UIControlStateNormal];
    self.copyCodeButton.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
    self.copyCodeButton.layer.cornerRadius = 10;
    self.copyCodeButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.15];
    [self.copyCodeButton addTarget:self action:@selector(copyCodeTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.shareMapBoxView addSubview:self.copyCodeButton];
    
    // Nút "Đổi Mã Khác"
    self.refreshCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.refreshCodeButton.frame = CGRectMake(self.shareMapBoxView.bounds.size.width - 156, 162, 136, 38);
    [self.refreshCodeButton setTitle:@"🔄 Đổi Mã Khác" forState:UIControlStateNormal];
    self.refreshCodeButton.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
    self.refreshCodeButton.layer.cornerRadius = 10;
    self.refreshCodeButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.12];
    [self.refreshCodeButton addTarget:self action:@selector(refreshCodeTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.shareMapBoxView addSubview:self.refreshCodeButton];
    
    // Nút "Mở Web Map (map.yong38.com)"
    self.openWebButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.openWebButton.frame = CGRectMake(20, 212, self.shareMapBoxView.bounds.size.width - 40, 42);
    [self.openWebButton setTitle:@"🌐 Mở Web: map.yong38.com" forState:UIControlStateNormal];
    self.openWebButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightHeavy];
    self.openWebButton.layer.cornerRadius = 12;
    self.openWebButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.92];
    [self.openWebButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.openWebButton addTarget:self action:@selector(openWebTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.shareMapBoxView addSubview:self.openWebButton];
    
    // Nhãn trạng thái phát sóng
    self.statusBadgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 264, self.shareMapBoxView.bounds.size.width - 40, 48)];
    self.statusBadgeLabel.numberOfLines = 2;
    self.statusBadgeLabel.textAlignment = NSTextAlignmentCenter;
    self.statusBadgeLabel.font = [UIFont systemFontOfSize:11.5 weight:UIFontWeightMedium];
    self.statusBadgeLabel.textColor = [UIColor colorWithWhite:0.75 alpha:1.0];
    [self.shareMapBoxView addSubview:self.statusBadgeLabel];
    
    [self updateShareMapUIState];
    
    self.tab2View.frame = CGRectMake(0, 0, self.menuCardView.bounds.size.width, y + 350);
    [self.contentScrollView addSubview:self.tab2View];
}

#pragma mark - Tab 3: Giao Diện (Nền Đen & Đen Trắng)

- (void)setupTab3Content {
    self.tab3View = [[UIView alloc] initWithFrame:self.contentScrollView.bounds];
    self.tab3View.hidden = YES;
    
    CGFloat y = 8;
    
    // Label Chọn Theme
    UILabel *themeTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 200, 20)];
    themeTitle.text = @"Chế Độ Giao Diện";
    themeTitle.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    themeTitle.textColor = [UIColor whiteColor];
    [self.tab3View addSubview:themeTitle];
    y += 28;
    
    // Segmented Control: Nền đen vs Đen trắng
    NSArray *themes = @[@"Nền Đen (OLED)", @"Đen Trắng (Monochrome)"];
    self.themeSegmentedControl = [[UISegmentedControl alloc] initWithItems:themes];
    self.themeSegmentedControl.frame = CGRectMake(20, y, self.menuCardView.bounds.size.width - 40, 36);
    self.themeSegmentedControl.selectedSegmentIndex = self.currentTheme;
    [self.themeSegmentedControl addTarget:self action:@selector(themeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.tab3View addSubview:self.themeSegmentedControl];
    y += 50;
    
    // Độ mờ Menu
    UILabel *opTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 200, 20)];
    opTitle.text = @"Độ Trong Suốt Menu";
    opTitle.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    opTitle.textColor = [UIColor whiteColor];
    [self.tab3View addSubview:opTitle];
    y += 24;
    
    self.opacitySlider = [[UISlider alloc] initWithFrame:CGRectMake(20, y, self.menuCardView.bounds.size.width - 40, 30)];
    self.opacitySlider.minimumValue = 0.5;
    self.opacitySlider.maximumValue = 1.0;
    self.opacitySlider.value = 0.95;
    [self.opacitySlider addTarget:self action:@selector(opacitySliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.tab3View addSubview:self.opacitySlider];
    y += 45;
    
    // Nút Đưa Nút Tròn Về Vị Trí Mặc Định
    UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    resetBtn.frame = CGRectMake(20, y, self.menuCardView.bounds.size.width - 40, 38);
    [resetBtn setTitle:@"Đặt Lại Vị Trí Nút Menu" forState:UIControlStateNormal];
    resetBtn.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
    resetBtn.layer.cornerRadius = 10;
    resetBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    [resetBtn addTarget:self action:@selector(resetFloatingButtonPosition) forControlEvents:UIControlEventTouchUpInside];
    [self.tab3View addSubview:resetBtn];
    y += 55;
    
    // Card Giới Thiệu
    UIView *infoBox = [[UIView alloc] initWithFrame:CGRectMake(20, y, self.menuCardView.bounds.size.width - 40, 70)];
    infoBox.layer.cornerRadius = 12;
    infoBox.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.06];
    
    UILabel *infoText = [[UILabel alloc] initWithFrame:infoBox.bounds];
    infoText.numberOfLines = 2;
    infoText.textAlignment = NSTextAlignmentCenter;
    infoText.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    infoText.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    infoText.text = [NSString stringWithFormat:@"%@\nBản quyền phát triển: %@", TRBAO_MOD_NAME, TRBAO_MOD_SUBTITLE];
    [infoBox addSubview:infoText];
    [self.tab3View addSubview:infoBox];
    y += 85;
    
    self.tab3View.frame = CGRectMake(0, 0, self.menuCardView.bounds.size.width, y);
    [self.contentScrollView addSubview:self.tab3View];
}

#pragma mark - Áp Dụng Theme: Nền Đen và Đen Trắng

- (void)applyTheme:(TrbaoThemeMode)mode {
    self.currentTheme = mode;
    [[NSUserDefaults standardUserDefaults] setInteger:mode forKey:K_THEME_MODE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (mode == TrbaoThemeModeOLEDBlack) {
        // 1. Chế độ Nền Đen OLED (Deep Black)
        self.menuCardView.backgroundColor = [UIColor colorWithRed:8/255.0 green:8/255.0 blue:10/255.0 alpha:0.96];
        self.menuCardView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.18].CGColor;
        
        self.titleLabel.textColor = [UIColor whiteColor];
        self.subtitleLabel.textColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:210/255.0 alpha:0.8];
        
        self.closeButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.12];
        [self.closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        self.tabSegmentedControl.selectedSegmentTintColor = [UIColor colorWithWhite:1.0 alpha:0.25];
        
        self.shareMapBoxView.backgroundColor = [UIColor colorWithRed:14/255.0 green:14/255.0 blue:18/255.0 alpha:0.9];
        self.shareMapBoxView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.15].CGColor;
        
    } else {
        // 2. Chế độ Đen Trắng (Monochrome / Grayscale) - Tương phản cao
        self.menuCardView.backgroundColor = [UIColor colorWithWhite:0.04 alpha:0.98];
        self.menuCardView.layer.borderColor = [UIColor colorWithWhite:0.9 alpha:0.85].CGColor;
        
        self.titleLabel.textColor = [UIColor whiteColor];
        self.subtitleLabel.textColor = [UIColor colorWithWhite:0.85 alpha:0.9];
        
        self.closeButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
        [self.closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        self.tabSegmentedControl.selectedSegmentTintColor = [UIColor colorWithWhite:1.0 alpha:0.35];
        
        self.shareMapBoxView.backgroundColor = [UIColor colorWithWhite:0.08 alpha:0.95];
        self.shareMapBoxView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:0.5].CGColor;
    }
    
    // Cập nhật giao diện nút floating button
    [[TrbaoFloatingButton sharedInstance] applyThemeBlack:(mode == TrbaoThemeModeMonochrome)];
    
    if ([self.delegate respondsToSelector:@selector(modMenuThemeDidChange:)]) {
        [self.delegate modMenuThemeDidChange:mode];
    }
}

#pragma mark - Xử Lý Sự Kiện & Tabs

- (void)tabChanged:(UISegmentedControl *)sender {
    [self switchTabToIndex:sender.selectedSegmentIndex];
}

- (void)switchTabToIndex:(NSInteger)index {
    self.tab1View.hidden = (index != 0);
    self.tab2View.hidden = (index != 1);
    self.tab3View.hidden = (index != 2);
    
    if (index == 0) {
        self.contentScrollView.contentSize = self.tab1View.frame.size;
    } else if (index == 1) {
        self.contentScrollView.contentSize = self.tab2View.frame.size;
    } else {
        self.contentScrollView.contentSize = self.tab3View.frame.size;
    }
}

- (void)themeChanged:(UISegmentedControl *)sender {
    [self applyTheme:(TrbaoThemeMode)sender.selectedSegmentIndex];
}

- (void)opacitySliderChanged:(UISlider *)sender {
    self.menuCardView.alpha = sender.value;
}

- (void)resetFloatingButtonPosition {
    TrbaoFloatingButton *btn = [TrbaoFloatingButton sharedInstance];
    [UIView animateWithDuration:0.3 animations:^{
        btn.frame = CGRectMake(20, 140, 56, 56);
    }];
}

#pragma mark - Xử Lý Share Map (Tab 2)

- (void)shareMapSwitchToggled:(UISwitch *)sender {
    if (sender.isOn) {
        [[TrbaoShareMapManager sharedManager] startSharing];
        [[TrbaoFloatingButton sharedInstance] setLiveBadge:YES];
    } else {
        [[TrbaoShareMapManager sharedManager] stopSharing];
        [[TrbaoFloatingButton sharedInstance] setLiveBadge:NO];
    }
    [self updateShareMapUIState];
}

- (void)copyCodeTapped {
    [[TrbaoShareMapManager sharedManager] copySessionCodeToClipboard];
    
    // Hiển thị alert thông báo đã copy
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Đã Sao Chép Mã!"
                                                                   message:[NSString stringWithFormat:@"Mã: %@\nVào web: %@ để xem trực tiếp.", [TrbaoShareMapManager sharedManager].currentSessionCode, TRBAO_SHARE_MAP_URL]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)refreshCodeTapped {
    NSString *newCode = [[TrbaoShareMapManager sharedManager] generateNewSessionCode];
    self.codeDisplayLabel.text = newCode;
    
    if (self.shareMapSwitch.isOn) {
        [[TrbaoShareMapManager sharedManager] stopSharing];
        [[TrbaoShareMapManager sharedManager] startSharing];
    }
    [self updateShareMapUIState];
}

- (void)openWebTapped {
    [[TrbaoShareMapManager sharedManager] openWebMap];
}

- (void)updateShareMapUIState {
    BOOL isSharing = [TrbaoShareMapManager sharedManager].isSharing;
    NSString *code = [TrbaoShareMapManager sharedManager].currentSessionCode;
    self.codeDisplayLabel.text = code ?: @"------";
    
    if (isSharing) {
        self.statusBadgeLabel.text = [NSString stringWithFormat:@"🟢 Đang phát trực tiếp mã %@\nĐồng đội vào %@ để xem map.", code, TRBAO_SHARE_MAP_URL];
        self.statusBadgeLabel.textColor = [UIColor colorWithRed:52/255.0 green:211/255.0 blue:153/255.0 alpha:1.0];
    } else {
        self.statusBadgeLabel.text = [NSString stringWithFormat:@"⚪ Đang tắt chia sẻ.\nBật công tắc phía trên để bắt đầu phát sóng map.", nil];
        self.statusBadgeLabel.textColor = [UIColor colorWithWhite:0.65 alpha:1.0];
    }
}

#pragma mark - TrbaoShareMapDelegate

- (void)shareMapStatusDidChange:(NSString *)statusText isLive:(BOOL)isLive {
    [self updateShareMapUIState];
}

- (void)shareMapCodeDidGenerate:(NSString *)sessionCode {
    self.codeDisplayLabel.text = sessionCode;
}

#pragma mark - Helper tạo dòng toggle

- (UIView *)createToggleRowWithTitle:(NSString *)title subtitle:(NSString *)sub key:(NSString *)key y:(CGFloat *)y {
    UIView *row = [[UIView alloc] initWithFrame:CGRectMake(16, *y, self.menuCardView.bounds.size.width - 32, 60)];
    row.layer.cornerRadius = 12;
    row.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.06];
    
    UILabel *tLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 10, row.bounds.size.width - 80, 20)];
    tLabel.text = title;
    tLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
    tLabel.textColor = [UIColor whiteColor];
    [row addSubview:tLabel];
    
    UILabel *sLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 32, row.bounds.size.width - 80, 16)];
    sLabel.text = sub;
    sLabel.font = [UIFont systemFontOfSize:11.5 weight:UIFontWeightRegular];
    sLabel.textColor = [UIColor colorWithWhite:0.65 alpha:1.0];
    [row addSubview:sLabel];
    
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectMake(row.bounds.size.width - 64, 14, 50, 30)];
    sw.on = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    sw.tag = [key hash];
    [sw addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
    [row addSubview:sw];
    
    *y += 68;
    return row;
}

- (void)toggleChanged:(UISwitch *)sender {
    // Lưu lại trạng thái
    for (NSString *key in @[K_MAP_HACK_ENABLED, K_SHOW_ULTI_ENABLED, K_SHOW_JUNGLE_ENABLED]) {
        if ([key hash] == sender.tag) {
            [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        }
    }
}

- (void)camSliderChanged:(UISlider *)sender {
    [[NSUserDefaults standardUserDefaults] setFloat:sender.value forKey:K_CAM_XA_LEVEL];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Hiển thị / Đóng Menu

- (void)showMenuFromViewController:(UIViewController *)parentVC {
    self.menuCardView.transform = CGAffineTransformMakeScale(0.85, 0.85);
    self.menuCardView.alpha = 0.0;
    self.dimBackgroundView.alpha = 0.0;
    
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [parentVC presentViewController:self animated:NO completion:^{
        [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.6 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.menuCardView.transform = CGAffineTransformIdentity;
            self.menuCardView.alpha = 1.0;
            self.dimBackgroundView.alpha = 1.0;
        } completion:nil];
    }];
}

- (void)dismissMenu {
    [UIView animateWithDuration:0.2 animations:^{
        self.menuCardView.transform = CGAffineTransformMakeScale(0.85, 0.85);
        self.menuCardView.alpha = 0.0;
        self.dimBackgroundView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:^{
            if ([self.delegate respondsToSelector:@selector(modMenuDidDismiss)]) {
                [self.delegate modMenuDidDismiss];
            }
        }];
    }];
}

#pragma mark - Getters toàn cục

+ (BOOL)isMapHackEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:K_MAP_HACK_ENABLED];
}

+ (BOOL)isShowUltiEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:K_SHOW_ULTI_ENABLED];
}

+ (BOOL)isShowJungleEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:K_SHOW_JUNGLE_ENABLED];
}

+ (CGFloat)camXaLevel {
    float v = [[NSUserDefaults standardUserDefaults] floatForKey:K_CAM_XA_LEVEL];
    return v > 0 ? v : 1.3f;
}

+ (TrbaoThemeMode)currentThemeMode {
    return (TrbaoThemeMode)[[NSUserDefaults standardUserDefaults] integerForKey:K_THEME_MODE];
}

@end
