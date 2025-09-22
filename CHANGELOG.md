# Changelog

## \[0.0.1] - 2025-08-06

### Added

* Initial release of `otp_plus` package.
* `OtpPlusInputs` widget supporting:

    * Customizable OTP length and field shapes (`square`, `underline`, `circle`).
    * Paste detection with automatic digit distribution.
    * Obscured input with configurable obscuring character.
    * Custom styling options for text, cursor, spacing, and decoration.
    * Keyboard navigation with backspace focus handling.
    * Callback triggered on OTP completion.
    * Support for LTR and RTL text directions.
    * Custom context menu with paste functionality (excluding web platform).

## \[0.0.2] - 2025-08-07

* Update README.md

## \[0.0.3] - 2025-08-07

* Changed `pubspec.yaml` description.

## \[0.0.4] - 2025-08-09

* Fixed font-related issues.

## \[0.0.5] - 2025-08-09

* Added `onSubmit` and `onChanged` callback functions.
* Added `Directionality` widget to OTP inputs for text direction support.

## \[0.0.6] - 2025-08-09

* Adjusted width of demo picture.

## \[0.0.7] - 2025-08-09

* Removed embedded fonts.

## \[0.0.8] - 2025-08-09

* Fixed border color rendering issues.

## \[0.0.9] - 2025-08-09

* Fixed issue in `onComplete` callback handling.

## \[1.0.0] - 2025-08-10

* Add onError, onSuccess functions
* Handle error/success built in
* Remove onSubmit function when user paste code
* Change some functions name
* Fix some bug

## \[1.0.1] - 2025-08-10

* Removed `FilteringTextInputFormatter.digitsOnly` from input formatters.

## \[1.0.2] - 2025-08-11

* Removed `_handleOnComplete` call from the paste function to prevent premature completion triggers.

## \[1.0.3] - 2025-08-12

* Fixed issues in the paste function for correct multi-digit input handling.
* Added `_lastEmptyTextController` method for better focus management.
* Improved `_onTextChanged` to handle multi-character input and fill input gaps properly.
* Updated backspace key handling logic for natural navigation without clearing previous field's text.
* Added `maxLength` to text fields (2 for all but last, 1 for last) and hid counter text.
* Reordered internal `onChanged` callback calls to maintain correct event flow.
* 
## \[1.0.4] - 2025-08-12

* Fixed problems related to onError and onSuccess callback handling (details unspecified).

## \[1.0.5] - 2025-08-12

* Applied fixes for reported issues affecting input behavior and UI responsiveness.

## \[1.0.6] - 2025-08-13

### 1. Added `_lastEmptyTextController(int index)` Method
- Finds the last empty text controller before a specified index.
- Enables improved focus management to fill input gaps in OTP fields.

### 2. Enhanced `_onTextChanged` Logic
- Redirects input to last empty controller before current index.
- Supports multiple character input (pasting or fast typing) by splitting input across fields.
- Automatically moves focus forward or backward based on input or deletion.
- Calls `_handleOnComplete()` to detect when OTP input is complete.

### 3. Updated `_onBackButtonClick` Behavior
- Checks if current input text is empty with trimming.
- Removes clearing previous field’s text on backspace; now only shifts focus backward.
- Improves natural keyboard navigation and input correction.

### 4. `TextField` Configuration Changes
- Added `maxLength`:
  - Set to 2 for all fields except last.
  - Set to 1 for the last field.
- Added `counterText: ''` to hide character counter.
- Changed order of `onChanged` callback calls to run internal logic before user callback.

### 5. Documentation and Code Clarity
- Added detailed doc-comments for new and updated methods.
- Improved error handling and comments in keyboard event logic.

### 6. Other Notes
- No changes in public API or constructor parameters.
- Paste handling logic remains functionally the same.

## \[1.0.7] - 2025-08-16
* Remove context from library
* Change description of project

## \[1.0.8] - 2025-09-22
* Implement clean controller inputs field data

## \[1.0.9] - 2025-09-22
* Add supported device