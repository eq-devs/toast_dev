## 1.1.2

* **Fix:** `CurvedAnimation` created in `build()` without disposal — `ToastWidget` converted to `StatefulWidget` to manage animation lifecycle correctly.
* **Fix:** Custom `animationBuilder` received a stale `percent` snapshot; now wrapped in `AnimatedBuilder` so it animates reactively.
* **Fix:** Programmatic `dismissToast()` did not reposition remaining toasts or update their opacity after removal.
* **Fix:** Swipe-to-dismiss left the auto-dismiss timer running; timer is now cancelled via `ToastFuture.cancel()` on swipe.
* **Fix:** Always-true assert in `ToastWidget` — never caught empty `message` + no `child`.
* **Fix:** `registerContext` was called as a side effect inside `build()`; deferred to `addPostFrameCallback` and guarded to run once.
* **Cleanup:** Removed unused `controller` field and `_NoTickerProvider` from `ToastFuture`; `isTop` and `controller` on `ToastWidget` are now non-nullable.

## 1.1.1

* **Fix:** Resolved a layout crash where `ToastDev`'s `Overlay` lacked a `Material` widget ancestor, causing missing layout constraints for text selection toolbars (e.g. `TextField` copy/paste).

## 1.1.0* **Feature:** Pause auto-close timer on hover (web/desktop) or hold (mobile).
* **Feature:** Expand toast duration by 2 seconds when tapped/expanded.
* **Feature:** `DismissDirection` dynamically defaults to `up` or `down` depending on `ToastPosition`.
* **Refactor:** Removed `_toggleExpand` behavior and parameters `leading`, `iconColor`, `isClosable`, and `onClose` to streamline and simplify the API.

## 1.0.4

* Updates.
