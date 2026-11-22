// TRBAO MOD - home.js v3.0 (Dựa trên bản gốc yong38)
(function () {
  "use strict";
  var form = document.querySelector(".code-form");
  var input = document.getElementById("codeInput") || document.querySelector(".code-input");
  var btn = document.getElementById("submitBtn") || document.querySelector(".code-btn");
  var demoBtn = document.getElementById("demoBtn");
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

  if (input) {
    input.addEventListener("input", function () {
      var c = clean(input.value);
      if (input.value !== c) input.value = c;
      clearErr();
    });
  }

  if (demoBtn && input) {
    demoBtn.addEventListener("click", function () {
      input.value = "TEST88";
      clearErr();
      if (btn) {
        btn.disabled = true;
        btn.textContent = "Đang mở trận mẫu...";
      }
      setTimeout(function () {
        window.location.href = "./viewer.html?code=TEST88";
      }, 150);
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
        btn.textContent = "Đang mở trận...";
      }
      window.location.href = "./viewer.html?code=" + encodeURIComponent(code);
    });
  }
})();
