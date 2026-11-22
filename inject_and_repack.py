#
#  inject_and_repack.py
#  Công cụ tự động đóng gói TrbaoMod VIP vào Liên Quân Mobile IPA
#  Tác giả: by trbaomod
#

import os
import sys
import zipfile
import shutil
import hashlib

def get_file_md5(filepath):
    md5 = hashlib.md5()
    with open(filepath, 'rb') as f:
        while chunk := f.read(8192 * 1024):
            md5.update(chunk)
    return md5.hexdigest()

def inject_and_repack(input_ipa, dylib_path, output_ipa):
    print("=" * 60)
    print("🚀 TRBAO MOD VIP - IPA INJECTION & REPACK TOOL")
    print("   Thương hiệu: by trbaomod")
    print("=" * 60)
    
    if not os.path.exists(input_ipa):
        print(f"❌ Không tìm thấy file IPA gốc: {input_ipa}")
        return False
        
    if not os.path.exists(dylib_path):
        print(f"❌ Không tìm thấy file dylib: {dylib_path}")
        return False
        
    print(f"[*] File IPA gốc: {input_ipa} ({os.path.getsize(input_ipa) / (1024*1024):.2f} MB)")
    print(f"[*] File Dylib:   {dylib_path} ({os.path.getsize(dylib_path) / 1024:.2f} KB)")
    print(f"[*] File xuất:    {output_ipa}")
    
    target_rel_path = "Payload/kgvn.app/Frameworks/Runtimeqau.framework/Runtimeqau"
    
    # Mở file IPA gốc và tạo IPA mới
    temp_output = output_ipa + ".tmp"
    if os.path.exists(temp_output):
        os.remove(temp_output)
    if os.path.exists(output_ipa):
        os.remove(output_ipa)
        
    print(f"[*] Đang đọc và thay thế module Runtimeqau trong IPA...")
    with zipfile.ZipFile(input_ipa, 'r') as zin, zipfile.ZipFile(temp_output, 'w', compression=zipfile.ZIP_DEFLATED) as zout:
        injected = False
        for item in zin.infolist():
            if item.filename == target_rel_path:
                print(f"    -> Đã tìm thấy điểm tiêm: {item.filename}")
                print(f"    -> Thay thế bằng dylib TrbaoMod VIP mới...")
                with open(dylib_path, 'rb') as f_dylib:
                    zout.writestr(item, f_dylib.read())
                injected = True
            else:
                data = zin.read(item.filename)
                zout.writestr(item, data)
                
        if not injected:
            print(f"    -> Không tìm thấy path {target_rel_path}, đang chèn thêm vào framework...")
            with open(dylib_path, 'rb') as f_dylib:
                zout.writestr(target_rel_path, f_dylib.read())
                
    os.rename(temp_output, output_ipa)
    
    print("=" * 60)
    print("✅ ĐÓNG GÓI HOÀN TẤT THÀNH CÔNG!")
    print(f"📦 File IPA mới: {output_ipa}")
    print(f"📏 Dung lượng:   {os.path.getsize(output_ipa) / (1024*1024):.2f} MB")
    print(f"🔑 MD5 Checksum: {get_file_md5(output_ipa)}")
    print("👉 Sếp có thể dùng ESign, TrollStore hoặc Scarlet để cài trực tiếp vào iPhone/iPad!")
    print("=" * 60)
    return True

if __name__ == "__main__":
    ipa_in = "lq.ipa"
    dylib_in = sys.argv[1] if len(sys.argv) > 1 else "Runtimeqau"
    ipa_out = sys.argv[2] if len(sys.argv) > 2 else "lq_trbaomod_vip.ipa"
    
    inject_and_repack(ipa_in, dylib_in, ipa_out)
