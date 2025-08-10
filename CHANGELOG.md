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

* Change pubspec.yaml description

## \[0.0.4] - 2025-08-09

* Fix problem in fonts

## \[0.0.5] - 2025-08-09

* Add onSubmit - onChanged functions
* Add Directionality to otp inputs

## \[0.0.6] - 2025-08-09

* Change width of demo picture

## \[0.0.7] - 2025-08-09

* Remove fonts

## \[0.0.8] - 2025-08-09

* Fix problem in border color

## \[0.0.9] - 2025-08-09

* Fix problem in on Completed function

## \[1.0.0] - 2025-08-10

* Add onError, onSuccess functions
* Handle error/success built in
* Remove onSubmit function when user paste code
* Change some functions name
* Fix some bug

## \[1.0.1] - 2025-08-10

* remove FilteringTextInputFormatter.digitsOnly

## \[1.0.1] - 2025-08-11

* remove _handleOnComplete in paste function