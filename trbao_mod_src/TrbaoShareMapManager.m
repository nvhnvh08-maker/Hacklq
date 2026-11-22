//
//  TrbaoShareMapManager.m
//  TrbaoMod VIP - Quản lý tính năng Chia Sẻ Map (Share Map)
//  Tác giả: by trbaomod
//

#import "TrbaoShareMapManager.h"
#import "TrbaoModConfig.h"

@interface TrbaoShareMapManager () <NSURLSessionWebSocketDelegate>

@property (nonatomic, assign, readwrite) BOOL isSharing;
@property (nonatomic, copy, readwrite) NSString *currentSessionCode;
@property (nonatomic, copy, readwrite) NSString *statusMessage;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionWebSocketTask *webSocketTask API_AVAILABLE(ios(13.0));
@property (nonatomic, strong) NSTimer *heartbeatTimer;
@property (nonatomic, strong) NSTimer *telemetrySyncTimer;

@end

@implementation TrbaoShareMapManager

+ (instancetype)sharedManager {
    static TrbaoShareMapManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TrbaoShareMapManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isSharing = NO;
        _statusMessage = @"Chưa bật chia sẻ";
        
        // Khôi phục mã cũ hoặc tạo mã mới nếu chưa có
        NSString *savedCode = [[NSUserDefaults standardUserDefaults] stringForKey:K_CURRENT_SESSION_CODE];
        if (savedCode && savedCode.length == 6) {
            _currentSessionCode = savedCode;
        } else {
            _currentSessionCode = [self generateNewSessionCode];
        }
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.timeoutIntervalForRequest = 10.0;
        config.timeoutIntervalForResource = 30.0;
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return self;
}

#pragma mark - Sinh mã 6 ký tự chuẩn A-Z 0-9

- (NSString *)generateNewSessionCode {
    static NSString *letters = @"ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // Bỏ O, 0, 1, I để tránh nhầm lẫn
    NSMutableString *randomString = [NSMutableString stringWithCapacity:6];
    for (int i = 0; i < 6; i++) {
        uint32_t index = arc4random_uniform((uint32_t)[letters length]);
        [randomString appendFormat:@"%C", [letters characterAtIndex:index]];
    }
    
    self.currentSessionCode = [randomString copy];
    [[NSUserDefaults standardUserDefaults] setObject:self.currentSessionCode forKey:K_CURRENT_SESSION_CODE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([self.delegate respondsToSelector:@selector(shareMapCodeDidGenerate:)]) {
        [self.delegate shareMapCodeDidGenerate:self.currentSessionCode];
    }
    
    return self.currentSessionCode;
}

#pragma mark - Bật / Tắt Phát Sóng

- (void)startSharing {
    if (self.isSharing) return;
    
    self.isSharing = YES;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:K_SHARE_MAP_ENABLED];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.statusMessage = [NSString stringWithFormat:@"Đang kết nối tới %@", TRBAO_SHARE_MAP_URL];
    [self updateStatus:self.statusMessage isLive:NO];
    
    [self connectPublisherWebSocket];
    [self startHeartbeat];
    [self startMockTelemetry];
}

- (void)stopSharing {
    if (!self.isSharing) return;
    
    self.isSharing = NO;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:K_SHARE_MAP_ENABLED];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self stopHeartbeat];
    [self stopMockTelemetry];
    [self disconnectWebSocket];
    
    self.statusMessage = @"Đã tắt chia sẻ map";
    [self updateStatus:self.statusMessage isLive:NO];
}

- (void)toggleSharing {
    if (self.isSharing) {
        [self stopSharing];
    } else {
        [self startSharing];
    }
}

- (void)updateStatus:(NSString *)msg isLive:(BOOL)live {
    self.statusMessage = msg;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(shareMapStatusDidChange:isLive:)]) {
            [self.delegate shareMapStatusDidChange:msg isLive:live];
        }
    });
}

#pragma mark - Mở Web & Copy Mã

- (void)openWebMap {
    // Định dạng link xem trực tiếp: https://map.yong38.com/m/CODE
    NSString *urlString = [NSString stringWithFormat:@"%@/m/%@", TRBAO_SHARE_MAP_URL, self.currentSessionCode];
    NSURL *url = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void)copySessionCodeToClipboard {
    if (self.currentSessionCode) {
        [UIPasteboard generalPasteboard].string = self.currentSessionCode;
        
        // Haptic feedback
        if (@available(iOS 10.0, *)) {
            UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
            [generator notificationOccurred:UINotificationFeedbackTypeSuccess];
        }
    }
}

#pragma mark - WebSocket Connection & Publisher

- (void)connectPublisherWebSocket {
    if (@available(iOS 13.0, *)) {
        [self disconnectWebSocket];
        
        // WebSocket endpoint: wss://map.yong38.com/ws/publish/{code} hoặc wss://map.yong38.com/ws/view/{code}
        NSString *wsUrlStr = [NSString stringWithFormat:@"wss://%@/ws/publish/%@", TRBAO_SHARE_MAP_WS_HOST, self.currentSessionCode];
        NSURL *wsUrl = [NSURL URLWithString:wsUrlStr];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:wsUrl];
        [request setValue:@"https://map.yong38.com" forHTTPHeaderField:@"Origin"];
        [request setValue:@"trbaomod-client" forHTTPHeaderField:@"User-Agent"];
        
        self.webSocketTask = [self.session webSocketTaskWithRequest:request];
        [self.webSocketTask resume];
        
        [self receiveWebSocketMessage];
        
        [self updateStatus:[NSString stringWithFormat:@"🟢 Đang phát sóng mã: %@", self.currentSessionCode] isLive:YES];
    } else {
        [self updateStatus:[NSString stringWithFormat:@"🟢 Đang phát sóng qua REST API (Mã: %@)", self.currentSessionCode] isLive:YES];
    }
}

- (void)disconnectWebSocket {
    if (@available(iOS 13.0, *)) {
        if (self.webSocketTask) {
            [self.webSocketTask cancelWithCloseCode:NSURLSessionWebSocketCloseCodeNormalClosure reason:nil];
            self.webSocketTask = nil;
        }
    }
}

- (void)receiveWebSocketMessage API_AVAILABLE(ios(13.0)) {
    __weak typeof(self) weakSelf = self;
    [self.webSocketTask receiveMessageWithCompletionHandler:^(NSURLSessionWebSocketMessage * _Nullable message, NSError * _Nullable error) {
        if (error) {
            if (weakSelf.isSharing) {
                // Thử kết nối lại sau 3 giây
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if (weakSelf.isSharing) {
                        [weakSelf connectPublisherWebSocket];
                    }
                });
            }
            return;
        }
        
        // Tiếp tục lắng nghe tin nhắn tiếp theo
        [weakSelf receiveWebSocketMessage];
    }];
}

#pragma mark - Heartbeat & Telemetry Synchronization

- (void)startHeartbeat {
    [self stopHeartbeat];
    self.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(sendHeartbeat) userInfo:nil repeats:YES];
}

- (void)stopHeartbeat {
    if (self.heartbeatTimer) {
        [self.heartbeatTimer invalidate];
        self.heartbeatTimer = nil;
    }
}

- (void)sendHeartbeat {
    if (!self.isSharing) return;
    
    if (@available(iOS 13.0, *)) {
        if (self.webSocketTask && self.webSocketTask.state == NSURLSessionTaskStateRunning) {
            [self.webSocketTask sendPingWithPongReceiveHandler:^(NSError * _Nullable error) {
                // Heartbeat OK
            }];
        }
    }
}

#pragma mark - Telemetry Broadcast (Gửi dữ liệu tọa độ hero, máu, trụ theo format web)

- (void)broadcastTelemetryPlayers:(NSArray<NSDictionary *> *)players towers:(NSArray<NSDictionary *> *)towers state:(NSString *)state {
    if (!self.isSharing) return;
    
    NSDictionary *frameDict = @{
        @"version": @(1),
        @"state": state ?: @"battle",
        @"sessionId": self.currentSessionCode ?: @"",
        @"players": players ?: @[],
        @"towers": towers ?: @[],
        @"timestamp": @((long long)([[NSDate date] timeIntervalSince1970] * 1000))
    };
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:frameDict options:0 error:&jsonError];
    if (jsonError || !jsonData) return;
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    // Gửi qua WebSocket
    if (@available(iOS 13.0, *)) {
        if (self.webSocketTask && self.webSocketTask.state == NSURLSessionTaskStateRunning) {
            NSURLSessionWebSocketMessage *msg = [[NSURLSessionWebSocketMessage alloc] initWithString:jsonString];
            [self.webSocketTask sendMessage:msg completionHandler:^(NSError * _Nullable error) {
                // Đã gửi xong frame
            }];
        }
    }
    
    // Đồng thời gửi snapshot qua HTTP REST POST để đảm bảo viewer fetch được ngay khi vừa vào trang
    [self publishSnapshotHttp:jsonData];
}

- (void)publishSnapshotHttp:(NSData *)jsonData {
    NSString *publishUrl = [NSString stringWithFormat:@"%@/api/sessions/%@/snapshot", TRBAO_SHARE_MAP_URL, self.currentSessionCode];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:publishUrl]];
    req.HTTPMethod = @"POST";
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    req.HTTPBody = jsonData;
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // Hoàn tất cập nhật snapshot
    }];
    [task resume];
}

#pragma mark - Mock Telemetry (Demo & Fallback khi chưa vào trận)

- (void)startMockTelemetry {
    [self stopMockTelemetry];
    
    // Chu kỳ gửi dữ liệu mô phỏng vị trí trận đấu mỗi 500ms
    __weak typeof(self) weakSelf = self;
    self.telemetrySyncTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weakSelf emitSampleBattleTelemetry];
    }];
}

- (void)stopMockTelemetry {
    if (self.telemetrySyncTimer) {
        [self.telemetrySyncTimer invalidate];
        self.telemetrySyncTimer = nil;
    }
}

- (void)emitSampleBattleTelemetry {
    if (!self.isSharing) return;
    
    // Tọa độ mẫu chuẩn theo bản đồ Liên Quân Mobile 5v5 (worldX, worldZ)
    NSTimeInterval t = [[NSDate date] timeIntervalSince1970];
    double offsetX = sin(t * 0.8) * 12.0;
    double offsetZ = cos(t * 0.8) * 12.0;
    
    NSArray *mockPlayers = @[
        @{ @"heroId": @(105), @"team": @(1), @"worldX": @(-25.5 + offsetX), @"worldZ": @(1.9 + offsetZ), @"hp": @(4500), @"maxHp": @(5000) },
        @{ @"heroId": @(112), @"team": @(1), @"worldX": @(-18.8), @"worldZ": @(22.8), @"hp": @(3800), @"maxHp": @(4000) },
        @{ @"heroId": @(120), @"team": @(2), @"worldX": @(15.2 - offsetX), @"worldZ": @(-10.4 - offsetZ), @"hp": @(3200), @"maxHp": @(4500) },
        @{ @"heroId": @(134), @"team": @(2), @"worldX": @(28.6), @"worldZ": @(-22.1), @"hp": @(5000), @"maxHp": @(5000) }
    ];
    
    NSArray *mockTowers = @[
        @{ @"team": @(1), @"worldX": @(-53.13), @"worldZ": @(3.53) },
        @{ @"team": @(1), @"worldX": @(-3.77), @"worldZ": @(30.99) },
        @{ @"team": @(2), @"worldX": @(53.86), @"worldZ": @(52.05) },
        @{ @"team": @(2), @"worldX": @(22.88), @"worldZ": @(-50.13) }
    ];
    
    [self broadcastTelemetryPlayers:mockPlayers towers:mockTowers state:@"battle"];
}

@end
