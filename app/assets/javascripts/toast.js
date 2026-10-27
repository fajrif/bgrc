// Toasts for public flash messages. Server-rendered ones sit in #bbcc-toasts;
// bbccToast(type, message) adds more (type: success | error | warning | info).
(function () {
  var DURATION = 6000;

  function region() {
    var el = document.getElementById("bbcc-toasts");
    if (!el) {
      el = document.createElement("div");
      el.id = "bbcc-toasts";
      el.className = "bbcc-toasts";
      el.setAttribute("aria-live", "polite");
      document.body.appendChild(el);
    }
    return el;
  }

  function dismiss(toast) {
    if (toast.dataset.closing) return;
    toast.dataset.closing = "1";
    clearTimeout(toast._timer);
    toast.classList.add("bbcc-toast-out");
    setTimeout(function () { toast.remove(); }, 250);
  }

  function arm(toast) {
    var bar = toast.querySelector(".bbcc-toast-bar");
    var remaining = DURATION, started;

    function start() {
      started = Date.now();
      if (bar) { bar.style.transition = "transform " + remaining + "ms linear"; bar.style.transform = "scaleX(0)"; }
      toast._timer = setTimeout(function () { dismiss(toast); }, remaining);
    }
    function pause() {
      clearTimeout(toast._timer);
      remaining -= Date.now() - started;
      if (bar) { bar.style.transition = "none"; bar.style.transform = "scaleX(" + Math.max(remaining / DURATION, 0) + ")"; }
    }

    toast.addEventListener("mouseenter", pause);
    toast.addEventListener("mouseleave", start);
    toast.addEventListener("focusin", pause);
    toast.addEventListener("focusout", start);
    toast.querySelector(".bbcc-toast-close").addEventListener("click", function () { dismiss(toast); });
    requestAnimationFrame(function () { requestAnimationFrame(start); });
  }

  window.bbccToast = function (type, message) {
    var toast = document.createElement("div");
    toast.className = "bbcc-toast bbcc-toast-" + (type || "info");
    toast.setAttribute("role", type === "error" ? "alert" : "status");
    var msg = document.createElement("span");
    msg.className = "bbcc-toast-msg";
    msg.textContent = message; // plain text: JS callers never pass markup
    var close = document.createElement("button");
    close.type = "button"; close.className = "bbcc-toast-close"; close.setAttribute("aria-label", "Close"); close.innerHTML = "&times;";
    var bar = document.createElement("span");
    bar.className = "bbcc-toast-bar"; bar.setAttribute("aria-hidden", "true");
    toast.appendChild(msg); toast.appendChild(close); toast.appendChild(bar);
    region().appendChild(toast);
    arm(toast);
  };

  function init() {
    document.querySelectorAll("#bbcc-toasts .bbcc-toast").forEach(arm);
  }
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", init); else init();
})();
