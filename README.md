# TRBAO MOD VIP - LIÊN QUÂN MOBILE
**Bản quyền:** by trbaomod (Thay thế hoàn toàn ttsmod)  
**Phiên bản:** v3.8.0

## Tính Năng Nổi Bật:
- **Giao diện đẳng cấp:** Hỗ trợ 2 chế độ **Nền Đen OLED** và **Đen Trắng (Monochrome)**.
- **Công cụ Tools (Tab 2) - Chia Sẻ Map:** Tự động tạo mã phòng 6 ký tự, kết nối WebSocket và phát sóng trực tiếp vị trí minimap tới trang xem [https://map.yong38.com](https://map.yong38.com).
- **Cục nút tròn nổi (Floating Button):** Chạm xuyên thấu, kéo thả tự do, tự động hút vào mép màn hình và báo trạng thái LIVE.
- **Tự động build CI/CD:** Sử dụng GitHub Actions để tự động biên dịch `TrbaoModVIP.dylib` và `Runtimeqau` (ARM64 iOS) hoàn toàn tự động.

## Cấu trúc thư mục:
- `trbao_mod_src/`: Toàn bộ mã nguồn Tweak Objective-C.
- `.github/workflows/build_dylib.yml`: Workflow GitHub Actions tự build dylib trên macOS-14 runner.
- `server_sharemap/`: Trọn bộ mã nguồn Server Share Map riêng bằng Node.js WebSocket.
- `inject_and_repack.py`: Script đóng gói vào `lq.ipa`.
- `HUONG_DAN_SU_DUNG.md`: Hướng dẫn cài đặt chi tiết cho ESign, TrollStore, Scarlet.
