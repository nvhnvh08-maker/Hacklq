// home.js — kiem tra ma truoc khi vao viewer. Ma khong ton tai -> bao loi, KHONG dieu huong.
(function () {
  "use strict";
  var form = document.querySelector(".code-form");
  var input = document.querySelector(".code-input");
  var btn = document.querySelector(".code-btn");
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
  function clean(v) {
    return (v || "").toUpperCase().replace(/[^A-Z0-9]/g, "").slice(0, 6);
  }

  // Neu bi /go dieu huong ve do ma sai (fallback khi JS tat) -> hien loi.
  try {
    if (new URLSearchParams(location.search).get("e")) {
      showErr("Mã không tồn tại hoặc trận đã kết thúc. Kiểm tra lại mã trong app.");
    }
  } catch (e) {}

  if (input) {
    input.addEventListener("input", function () {
      var c = clean(input.value);
      if (input.value !== c) input.value = c;
      clearErr();
    });
  }

  if (form) {
    form.addEventListener("submit", function (ev) {
      ev.preventDefault();
      var code = clean(input ? input.value : "");
      if (code.length !== 6) {
        showErr("Mã phải đủ 6 ký tự.");
        return;
      }
      clearErr();
      if (btn) {
        btn.disabled = true;
        btn.textContent = "Đang kiểm tra...";
      }
      // Session ton tai -> snapshot tra 200. Khong ton tai -> 404.
      fetch("/api/sessions/" + code + "/snapshot", { cache: "no-store" })
        .then(function (r) {
          if (r.ok) {
            location.href = "/m/" + code;
          } else {
            showErr("Mã không tồn tại hoặc trận đã kết thúc. Kiểm tra lại mã trong app.");
            resetBtn();
          }
        })
        .catch(function () {
          showErr("Lỗi mạng, thử lại.");
          resetBtn();
        });
    });
  }

  function resetBtn() {
    if (btn) {
      btn.disabled = false;
      btn.textContent = "Xem trận";
    }
  }
})();
