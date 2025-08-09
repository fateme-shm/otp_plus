import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import 'package:otp_plus/utils/snack_bar.dart';
import 'package:otp_plus/utils/enum/otp_field_shape.dart';
import 'package:otp_plus/utils/enum/snack_bar_type.dart';

/// otp_plus: A Flutter package providing customizable OTP input widgets.
///
/// This widget (`OtpPlusInputs`) supports multiple OTP input fields with features such as:
/// - Paste detection and distribution across fields
/// - Obscured input for sensitive codes
/// - Flexible styling and layout options…
/// - RTL and LTR support with customizable text direction
///
/// Usage example:
/// ```dart
/// OtpPlusInputs(
///   length: 6,
///   shape: OtpFieldShape.square,
///   onComplete: (code) {
///     print('OTP Entered: $code');
///   },
/// )
/// ```
class OtpPlusInputs extends StatefulWidget {
  /// The parent [BuildContext] to use for showing UI elements such as snack bars.
  /// If `null`, the widget will use its own context.
  final BuildContext? parentContext;

  /// The error message text to display when OTP validation fails.
  /// If `null`, default error message will be shown.
  final String? errorText;

  /// The text for contextMenuBuilder
  final String? pasteText;

  /// The success message text to display when OTP validation passes.
  /// If `null`, default success message will be shown.
  final String? successText;

  /// Callback triggered when OTP validation fails.
  /// if use this default error validation not work
  final void Function()? onError;

  /// Callback triggered when OTP validation succeeds.
  /// if use this default success validation not work
  final void Function()? onSuccess;

  /// Defines the shape of the OTP input fields (e.g., box, circle).
  final OtpFieldShape shape;

  /// Total number of digits in the OTP
  final int length;

  /// Custom text style for each digit
  final TextStyle? textStyle;

  /// Whether to obscure the text (e.g., for passwords)
  final bool obscureText;

  /// Character used when obscuring text
  final String obscuringCharacter;

  /// Horizontal spacing between each digit field
  final double horizontalSpacing;

  /// Width & height of each input box
  final double size;

  /// Vertical spacing when inputs wrap to the next line
  final double verticalSpacing;

  /// Text direction of hole widget(LTR or RTL)
  final TextDirection textDirection;

  /// Cursor color
  final Color cursorColor;

  /// Enable/disable input fields
  final bool? enabled;

  /// Ignore input events
  final bool? ignorePointers;

  /// Cursor width
  final double cursorWidth;

  /// Cursor height
  final double? cursorHeight;

  /// Cursor border radius
  final Radius? cursorRadius;

  /// Animate cursor opacity
  final bool? cursorOpacityAnimates;

  /// Undo history controller
  final UndoHistoryController? undoController;

  /// Action button on keyboard (next/done)
  final TextInputAction? textInputAction;

  /// Capitalization behavior
  final TextCapitalization textCapitalization;

  /// Optional text style override
  final TextStyle? style;

  /// Optional strut style override
  final StrutStyle? strutStyle;

  /// Text alignment in each field
  final TextAlign textAlign;

  /// Vertical alignment of the text
  final TextAlignVertical textAlignVertical;

  /// Inner padding of each input field
  final EdgeInsets? contentPadding;

  /// Called when all OTP digits are completed
  final void Function(String code)? onComplete;

  /// Called whenever the OTP input changes.
  final void Function(String code)? onChanged;

  /// Provides the final combined code as a [String].
  final void Function(String code)? onSubmit;

  /// Border color for the input field in its default state.
  final Color? borderColor;

  /// Border color when the input field is focused.
  final Color? focusedBorderColor;

  /// Border color when the input field has an error.
  final Color? errorBorderColor;

  const OtpPlusInputs({
    super.key,

    // Required parameters
    required this.shape,
    required this.length,

    // Context and input behavior
    this.parentContext,
    this.enabled,
    this.undoController,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.textDirection = TextDirection.ltr,

    // Styling and layout
    this.textStyle,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.center,
    this.textAlignVertical = TextAlignVertical.center,
    this.size = 50,
    this.horizontalSpacing = 12,
    this.verticalSpacing = 12,
    this.contentPadding,

    // Cursor customization
    this.cursorColor = Colors.black,
    this.cursorWidth = 1.5,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorOpacityAnimates,

    // Obscuring text
    this.obscureText = false,
    this.obscuringCharacter = '*',

    // Border colors
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,

    // Callbacks
    this.onComplete,
    this.onChanged,
    this.onSubmit,
    this.onError,
    this.onSuccess,

    // Messages
    this.errorText,
    this.successText,

    // Other
    this.ignorePointers,
    this.pasteText,
  });

  @override
  State<OtpPlusInputs> createState() => OtpPlusInputsState();
}

class OtpPlusInputsState extends State<OtpPlusInputs> {
  /// List of [FocusNode]s managing focus for each OTP input field.
  /// Used to control and track focus state individually.
  late final List<FocusNode> _focusNodes;

  /// Separate [FocusNode]s specifically for keyboard focus management,
  /// allowing fine-grained control over keyboard interactions.
  late final List<FocusNode> _keyboardFocusNodes;

  /// List of [TextEditingController]s for each OTP input field,
  /// used to manage and listen to text input changes individually.
  late final List<TextEditingController> _controllers;

  /// Initializes the OTP input fields with the specified length
  /// before the widget builds for the first time.
  /// Calls super.initState() after initialization to complete setup.
  @override
  void initState() {
    _initializeOtpFields(widget.length);
    super.initState();
  }

  /// Initializes the OTP input fields by creating focus nodes and text controllers.
  ///
  /// This function sets up three lists based on the given `length`:
  /// - `_focusNodes`: manages focus for each OTP input field.
  /// - `_keyboardFocusNodes`: manages keyboard-specific focus behavior for each field.
  /// - `_controllers`: handles the text input for each OTP field.
  ///
  /// After initialization, it schedules an auto-focus on the first input field
  /// once the current frame rendering completes, ensuring the user can start typing immediately.
  ///
  /// Parameters:
  /// - `length` (int): The number of OTP input fields to create.
  ///
  /// Usage:
  /// Call this function during widget initialization (e.g., in `initState`) to prepare
  /// the necessary resources for OTP input handling.
  void _initializeOtpFields(int length) {
    // Create focus nodes for each OTP input field
    _focusNodes = List.generate(length, (_) => FocusNode());

    // Create separate keyboard focus nodes if needed (e.g., for keyboard handling)
    _keyboardFocusNodes = List.generate(length, (_) => FocusNode());

    // Create text controllers for each OTP input field
    _controllers = List.generate(length, (_) => TextEditingController());

    // Auto-focus the first input field after the widget build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) {
        _focusNodes.first.requestFocus();
      }
    });
  }

  /// Handles user input changes for each OTP field.
  ///
  /// - Advances focus to the next field when one digit is entered.
  /// - Moves focus back to the previous field when cleared.
  /// - Calls [onComplete] if the total input matches the expected OTP length.
  void _onChanged(String value, int index) {
    // If one character is entered, move to the next field
    if (value.length == 1) {
      if (index < widget.length - 1) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        //If last fields do not unfocus
        if (_retrieveFullCode().length == widget.length) {
          _handleOnComplete();
          return;
        }

        FocusScope.of(context).unfocus(); // All fields filled
      }
    }
    // If field is cleared, move focus back to the previous one
    else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }

    // Trigger the onComplete callback with the pasted value
    _handleOnComplete();
  }

  /// Handles the event when the OTP input process is completed.
  ///
  /// This method aggregates the current text values from all individual
  /// TextEditingControllers representing each OTP input field into a single
  /// concatenated string (`fullCode`). It then checks if the combined length
  /// of the entered code matches the expected OTP length (`widget.length`).
  ///
  /// If the input is complete (all fields filled), it triggers the
  /// `onComplete` callback, passing the full OTP code as an argument.
  /// This allows the parent widget or consumer to respond appropriately,
  /// for example, by validating the OTP or proceeding with authentication.
  ///
  /// Note:
  /// - This method ensures that the callback is only called once the entire
  ///   OTP has been entered, preventing premature triggers.
  /// - It relies on the list `_controllers` maintaining one controller per
  ///   OTP digit input field.
  void _handleOnComplete() {
    // Only trigger callback if all fields are filled
    if (_retrieveFullCode().length == widget.length) {
      widget.onComplete?.call(_retrieveFullCode());
    }
  }

  /// Handles the backspace key press event for OTP input fields.
  ///
  /// When the user presses the backspace key on an empty input field (at the
  /// given `index`), this method moves the focus to the previous input field
  /// and clears its content. This behavior enables seamless deletion and
  /// correction across multiple OTP input boxes.
  ///
  /// Key points:
  /// - The method only responds to `KeyDownEvent` for the backspace key.
  /// - It acts only if the current field is empty and the index is greater
  ///   than zero (i.e., not the first field).
  /// - The previous field’s text is cleared to allow easy correction.
  /// - Focus is then shifted to the previous field to allow further input.
  ///
  /// This improves the user experience by mimicking natural keyboard
  /// navigation within segmented input fields like OTP codes.
  void _onBackButtonClick(KeyEvent event, int index) {
    // Check if the event is a key press (key down)
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      // Clear the text in the previous input field
      _controllers[index - 1].clear();

      // Move focus to the previous input field
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  /// Handles the paste action for OTP input fields.
  ///
  /// This method retrieves the plain text from the system clipboard, extracts only the digits,
  /// and distributes them into the OTP input fields represented by `_controllers`.
  /// It also manages focus movement and triggers the `onComplete` callback if the OTP is complete.
  ///
  /// [tappedIndex] - The index of the field that was tapped (optional, could be used for smarter focus handling).
  /// This function not work in Web platform [kIsWeb]
  Future<void> _handlePaste(int tappedIndex) async {
    // Get text data from the system clipboard
    ClipboardData? clipboard = await Clipboard.getData(Clipboard.kTextPlain);

    // Retrieve the text value from the clipboard (fallback to empty string if null)
    String text = clipboard?.text ?? '';

    // Remove all non-digit characters using a regular expression
    String value = text.replaceAll(RegExp(r'\D'), '');

    // Limit digits to max OTP length
    if (value.length > widget.length) {
      value = value.substring(0, widget.length);
    }

    // Proceed only if multiple digits are pasted
    if (value.isNotEmpty) {
      // Loop through each OTP field and assign the corresponding digit
      for (int i = 0; i < widget.length; i++) {
        if (i < value.length) {
          // Assign digit to the controller
          _controllers[i].text = value[i];
        } else {
          // Clear remaining fields if pasted value is shorter than total fields
          _controllers[i].clear();
        }
      }

      // Move focus to the field after the last pasted character,
      // or unfocus if all fields are filled
      if (value.length < widget.length) {
        _focusNodes[value.length].requestFocus();
      } else {
        _focusNodes.last.unfocus();
      }

      // Trigger the onComplete callback with the pasted value
      _handleOnComplete();

      // Trigger the `onChanged` callback whenever the OTP input changes.
      _handleOnChanges();
    }
  }

  /// Builds and returns the complete OTP value from all text controllers.
  String _retrieveFullCode() {
    // Concatenate the text values from each OTP field's controller
    // into a single string representing the full OTP.
    String fullCode = _controllers
        // Extract text from each controller
        .map((TextEditingController c) => c.text)
        .join(); // Combine into one string without separators

    return fullCode; // Return the concatenated OTP
  }

  /// Handles changes in any of the OTP fields by calling the `onChanged` callback.
  ///
  /// This is triggered whenever the user modifies any OTP input field.
  /// It sends the current full OTP value to the parent widget, if the
  /// `onChanged` callback is provided.
  void _handleOnChanges() {
    widget.onChanged?.call(_retrieveFullCode());
  }

  /// Handles OTP submission by calling the `onSubmit` callback.
  ///
  /// This should be triggered when the user finishes entering the OTP
  /// (e.g., after filling the last field or pressing a submit action).
  /// It sends the final OTP value to the parent widget, if the
  /// `onSubmit` callback is provided.
  void _handleOnSubmit() {
    bool isOtpValid = _retrieveFullCode().length == widget.length;

    widget.onSubmit?.call(_retrieveFullCode());

    // Check if the entered OTP code length matches the expected length.
    if (isOtpValid) {
      // If an `onError` callback is provided, execute it.
      if (widget.onError != null) {
        widget.onError?.call();
      } else {
        // Otherwise, show a success snack bar with the provided or default message.
        showSnackBar(
          type: SnackBarType.success,
          context: widget.parentContext ?? context,
          message: widget.errorText ?? 'OTP code sent successfully.',
        );
      }
    } else {
      // If the OTP length does not match, trigger the `onSuccess` callback if provided.
      if (widget.onSuccess != null) {
        widget.onSuccess?.call();
      } else {
        // Otherwise, show an error snack bar with the provided or default error message.
        showSnackBar(
          type: SnackBarType.error,
          context: widget.parentContext ?? context,
          message:
              widget.successText ??
              'OTP code must be ${widget.length} characters long.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius = BorderRadius.circular(
      widget.shape == OtpFieldShape.circle ? 100 : 4,
    );

    return Center(
      child: Directionality(
        textDirection: widget.textDirection,
        child: Wrap(
          spacing: widget.horizontalSpacing,
          runSpacing: widget.verticalSpacing,
          children: List.generate(widget.length, (int index) {
            return KeyboardListener(
              focusNode: _keyboardFocusNodes[index],
              onKeyEvent: (event) => _onBackButtonClick(event, index),
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: TextField(
                  contextMenuBuilder:
                      (
                        BuildContext context,
                        EditableTextState editableTextState,
                      ) {
                        return AdaptiveTextSelectionToolbar.buttonItems(
                          anchors: editableTextState.contextMenuAnchors,
                          buttonItems: [
                            ContextMenuButtonItem(
                              onPressed: () async {
                                // Close the context menu
                                Navigator.of(context).maybePop();

                                // Trigger your custom paste logic
                                _handlePaste(index);
                              },
                              label: widget.pasteText ?? 'Paste',
                            ),
                          ],
                        );
                      },
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: widget.textAlign,
                  textAlignVertical: widget.textAlignVertical,
                  keyboardType: TextInputType.number,
                  textCapitalization: widget.textCapitalization,
                  obscureText: widget.obscureText,
                  obscuringCharacter: widget.obscuringCharacter,
                  cursorColor: widget.cursorColor,
                  cursorWidth: widget.cursorWidth,
                  cursorHeight: widget.cursorHeight,
                  cursorRadius: widget.cursorRadius,
                  cursorOpacityAnimates: widget.cursorOpacityAnimates,
                  enabled: widget.enabled,
                  ignorePointers: widget.ignorePointers,
                  style:
                      widget.textStyle ??
                      TextStyle(
                        fontSize: widget.size * 0.4,
                        fontWeight: FontWeight.w400,
                      ),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(1),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    contentPadding:
                        widget.contentPadding ??
                        const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                    enabledBorder: widget.shape == OtpFieldShape.underline
                        ? UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.borderColor ?? Colors.grey,
                            ),
                          )
                        : OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide(
                              color: widget.borderColor ?? Colors.grey,
                            ),
                          ),
                    border: widget.shape == OtpFieldShape.underline
                        ? UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.borderColor ?? Colors.grey,
                            ),
                          )
                        : OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide(
                              color: widget.borderColor ?? Colors.grey,
                            ),
                          ),
                    focusedBorder: widget.shape == OtpFieldShape.underline
                        ? UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.borderColor ?? Colors.black,
                            ),
                          )
                        : OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide(
                              color: widget.focusedBorderColor ?? Colors.black,
                            ),
                          ),
                    errorBorder: widget.shape == OtpFieldShape.underline
                        ? UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.borderColor ?? Colors.red,
                            ),
                          )
                        : OutlineInputBorder(
                            borderRadius: borderRadius,
                            borderSide: BorderSide(
                              color: widget.errorBorderColor ?? Colors.red,
                            ),
                          ),
                  ),
                  onSubmitted: (String value) {
                    _handleOnSubmit();
                  },
                  onChanged: (String value) {
                    _handleOnChanges();

                    _onChanged(value, index);
                  },
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
