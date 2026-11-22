# HƯỚNG DẪN CHI TIẾT TRBAO MOD VIP - LIÊN QUÂN MOBILE
**Thương hiệu:** by trbaomod (Đã thay thế hoàn toàn ttsmod)  
**Phiên bản:** v3.8.0

---

## I. CÁC TÍNH NĂNG MỚI ĐÃ ĐƯỢC CODE HOÀN CHỈNH

### 1. Thương hiệu & Giao diện mới
- **Đổi bản quyền:** Toàn bộ menu, tiêu đề, nhãn phụ đã được đổi từ `by ttsmod` thành **`by trbaomod`**.
- **Chế độ Nền Đen OLED (Deep Black):** Nền đen sâu `#000000`, card xám đậm `#121212`, viền xám tro `#262626`, tôn nét sang trọng và tiết kiệm pin tối đa cho màn hình OLED của iPhone.
- **Chế độ Nền Đen Trắng (Monochrome / Grayscale):** Phong cách tối giản tương phản cao tuyệt mỹ: nền đen, viền trắng sắc sảo `#f0f0f0`, các nút bấm và nhãn chữ phân cấp trắng - xám bạc, không màu mè rườm rà.
- Hỗ trợ lưu theme vào bộ nhớ máy, tự động áp dụng khi mở lại game.

### 2. Chức năng Chia Sẻ Map (Share Map) trong Tools (Tab 2)
- Được đặt trang trọng tại **Tab 2 (Tools)** trong menu.
- **Cơ chế hoạt động:**
  1. Khi người dùng bật công tắc **"Chia Sẻ Map Trực Tiếp"**, hệ thống sẽ tự động sinh một **mã phòng gồm 6 ký tự** ngẫu nhiên (ví dụ: `TB98K2`).
  2. Mã phòng hiển thị to, rõ nét trong khung Badge chuyên dụng.
  3. Có nút **"📋 Sao Chép Mã"** để người dùng copy nhanh gửi cho đồng đội.
  4. Có nút **"🌐 Mở Web: map.yong38.com"** để mở trực tiếp trang xem trên Safari.
  5. Có nút **"🔄 Đổi Mã Khác"** nếu muốn reset tạo phòng mới.
  6. **Engine Telemetry Realtime:** Tự động đóng gói vị trí các tướng (`worldX`, `worldZ`), máu (`hp`, `maxHp`), phe (`team`: 1 xanh, 2 đỏ), trụ (`towers`) theo chuẩn JSON của web `https://map.yong38.com`:
     ```json
     {
       "version": 1,
       "state": "battle",
       "sessionId": "TB98K2",
       "players": [
         {
           "heroId": 105,
           "team": 1,
           "worldX": -18.8965,
           "worldZ": 22.81228,
           "hp": 4500,
           "maxHp": 5000
         }
       ],
       "towers": [
         { "team": 1, "worldX": -25.79463, "worldZ": 1.95444 }
       ]
     }
     ```
  7. Dữ liệu được phát sóng song song qua **WebSocket** (`wss://`) và **REST Snapshot API** (`/api/sessions/{code}/snapshot`). Người xem trên web chỉ cần nhập mã 6 ký tự là thấy ngay minimap chạy mượt mà theo thời gian thực!

### 3. Cục nút tròn Floating Button
- Chạm xuyên thấu (passthrough touch), không cản trở thao tác chơi game.
- Kéo thả tự do, tự động hút vào mép màn hình (snap to edge).
- Tự động hiện nhãn đỏ **"LIVE"** trên đầu nút tròn khi đang bật Share Map!

---

## II. CẤU TRÚC THƯ MỤC DỰ ÁN

```text
c:\Users\Administrator\Downloads\hacklq\
├── trbao_mod_src\                  <-- Mã nguồn Tweak Objective-C
│   ├── TrbaoModConfig.h            <-- Cấu hình, branding "by trbaomod", enum theme
│   ├── TrbaoShareMapManager.h      <-- Header quản lý Share Map
│   ├── TrbaoShareMapManager.m      <-- Logic WebSocket / HTTP publisher & telemetry
│   ├── TrbaoFloatingButton.h       <-- Header cục nút tròn nổi
│   ├── TrbaoFloatingButton.m       <-- Nút tròn kéo thả, chạm xuyên thấu, badge LIVE
│   ├── TrbaoModViewController.h    <-- Header Menu VIP
│   ├── TrbaoModViewController.m    <-- Giao diện 3 tab, theme đen & đen trắng
│   ├── TrbaoModHooks.m             <-- Auto Injection khi Liên Quân khởi động
│   └── Makefile                    <-- File build Theos
│
├── .github\workflows\
│   └── build_dylib.yml             <-- CI/CD GitHub Actions tự build dylib ARM64
│
├── server_sharemap\                <-- Trọn bộ Server Share Map riêng (nếu tự host)
│   ├── server.js                   <-- Backend WebSocket + REST API
│   ├── package.json
│   └── public\                     <-- Web viewer, minimap, app.min.js
│       ├── index.html              <-- Trang nhập mã 6 ký tự
│       ├── viewer.html             <-- Trang xem bản đồ trực tiếp
│       ├── home.js / home.css
│       ├── dist\app.min.js
│       └── assets\minimap.png
│
├── inject_and_repack.py            <-- Tool tự động tiêm dylib vào lq.ipa
└── lq.ipa                          <-- File IPA Liên Quân Mobile gốc
```

---

## III. HƯỚNG DẪN BIÊN DỊCH VÀ ĐÓNG GÓI IPA

### Cách 1: Biên dịch tự động qua GitHub Actions (Khuyên dùng - Nhanh nhất)
1. Đẩy thư mục `hacklq` lên một kho lưu trữ GitHub (public hoặc private).
2. Vào mục **Actions** trên GitHub, chạy workflow **"Build TrbaoMod ARM64 Dylib"**.
3. Sau khoảng 1 phút, tải file Artifact **`TrbaoModVIP_ARM64.zip`** về.
4. Bên trong sẽ có sẵn 2 file:
   - `Runtimeqau` (đã cấu hình sẵn install_name chuẩn).
   - `TrbaoModVIP.dylib`.
5. Đặt file `Runtimeqau` vào cùng thư mục `hacklq`, sau đó chạy lệnh:
   ```powershell
   python inject_and_repack.py Runtimeqau lq_trbaomod_vip.ipa
   ```
6. Kết quả sẽ tạo ra file `lq_trbaomod_vip.ipa` hoàn chỉnh! Sếp có thể dùng ESign, TrollStore hoặc Scarlet để cài ngay vào máy.

### Cách 2: Tự chạy Server Share Map riêng (Tùy chọn)
Nếu sếp muốn chạy server web map riêng thay vì dùng `map.yong38.com`:
```powershell
cd server_sharemap
npm install
node server.js
```
Server sẽ chạy tại `http://localhost:3000` (hoặc mở port trên VPS để người khác truy cập qua tên miền riêng của sếp).
