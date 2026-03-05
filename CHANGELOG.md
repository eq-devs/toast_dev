## 1.1.1

* **Fix:** Resolved a layout crash where `ToastDev`'s `Overlay` lacked a `Material` widget ancestor, causing missing layout constraints for text selection toolbars (e.g. `TextField` copy/paste).

## 1.1.0* **Feature:** Pause auto-close timer on hover (web/desktop) or hold (mobile).
* **Feature:** Expand toast duration by 2 seconds when tapped/expanded.
* **Feature:** `DismissDirection` dynamically defaults to `up` or `down` depending on `ToastPosition`.
* **Refactor:** Removed `_toggleExpand` behavior and parameters `leading`, `iconColor`, `isClosable`, and `onClose` to streamline and simplify the API.

## 1.0.4

* Updates.
