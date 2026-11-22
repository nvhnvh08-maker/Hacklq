// TRBAO MOD - home.js v2.0
// Tối ưu trải nghiệm: nhập mã, dán mã từ clipboard, điều hướng an toàn vào viewer.
(function () {
  "use strict";

  var form = document.getElementById("codeForm");
  var input = document.getElementById("codeInput");
  var btn = document.getElementById("submitBtn");
  var pasteBtn = document.getElementById("pasteBtn");
  var err = document.getElementById("homeErr");

  function showErr(msg) {
    if (!err) return;
    err.textContent = msg;
    err.classList.add("show");
  }

  function clearErr() {
    if (!err) return;
    err.textContent = "";
    err.classList.remove("show");
  }

  function clean(val) {
    return (val || "").toUpperCase().replace(/[^A-Z0-9]/g, "").slice(0, 6);
  }

  // Hiển thị lỗi từ query parameter nếu có
  try {
    var params = new URLSearchParams(window.location.search);
    if (params.get("e")) {
      showErr("Mã không tồn tại hoặc trận đấu đã kết thúc. Vui lòng lấy mã mới trong app.");
    }
  } catch (e) {}

  if (input) {
    input.addEventListener("input", function () {
      var c = clean(input.value);
      if (input.value !== c) input.value = c;
      clearErr();
    });
  }

  // Xử lý nút "Dán" mã từ Clipboard
  if (pasteBtn && input) {
    pasteBtn.addEventListener("click", function () {
      if (navigator.clipboard && navigator.clipboard.readText) {
        navigator.clipboard.readText().then(function (text) {
          if (text) {
            input.value = clean(text);
            input.focus();
            clearErr();
          }
        }).catch(function () {
          input.focus();
        });
      } else {
        input.focus();
      }
    });
  }

  if (form) {
    form.addEventListener("submit", function (ev) {
      ev.preventDefault();
      var code = clean(input ? input.value : "");
      if (code.length !== 6) {
        showErr("Vui lòng nhập đủ 6 ký tự mã trận (Ví dụ: A3F9K2).");
        if (input) input.focus();
        return;
      }
      clearErr();

      if (btn) {
        btn.disabled = true;
        btn.innerHTML = '<span>ĐANG KẾT NỐI...</span>';
      }

      // Xác định đường dẫn viewer tương đối an toàn trên GitHub Pages & Web server
      var targetUrl = "./viewer.html?code=" + encodeURIComponent(code);

      // Nếu đang chạy trên Node server nội bộ (có endpoint /m/):
      if (window.location.pathname.indexOf("/m/") !== -1 || window.location.port === "3000") {
        targetUrl = "/m/" + encodeURIComponent(code);
      }

      // Điều hướng ngay lập tức vào viewer
      window.location.href = targetUrl;
    });
  }
})();
