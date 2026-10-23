// GitHub Pages 最小示例脚本：验证 JS 能正常加载并可交互。
(function () {
  "use strict";

  var pathEl = document.getElementById("fact-path");
  var statusEl = document.getElementById("fact-status");
  var timeEl = document.getElementById("fact-time");

  function pad(n) {
    return String(n).padStart(2, "0");
  }

  function now() {
    var d = new Date();
    return d.getFullYear() + "-" + pad(d.getMonth() + 1) + "-" + pad(d.getDate()) +
      " " + pad(d.getHours()) + ":" + pad(d.getMinutes()) + ":" + pad(d.getSeconds());
  }

  if (pathEl) {
    pathEl.textContent = window.location.pathname;
  }

  if (statusEl) {
    // 只要这段代码执行到，说明 ./app.js 被成功加载（路径正确、无 404）。
    statusEl.textContent = "app.js 已加载并执行 ✓";
  }

  if (timeEl) {
    timeEl.textContent = now();
  }

  var button = document.getElementById("ping");
  var result = document.getElementById("ping-result");
  var clicks = 0;

  if (button && result) {
    button.addEventListener("click", function () {
      clicks += 1;
      result.textContent = "交互正常：这是第 " + clicks + " 次点击，时间 " + now() + "。";
    });
  }
})();
