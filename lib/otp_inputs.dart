import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A customizable OTP (One-Time Password) input widget that supports:
/// - Multiple input fields
/// - Paste detection with automatic field distribution
/// - Obscured input
/// - Custom styling
///
/// Part of the `otp_plus` package.
class OtpPlusInputs extends StatefulWidget {
  /// Defines the shape of the OTP input fields (e.g., box, circle).
  final OtpFieldShape shape;

  /// Total number of digits in the OTP
  final int length;

  /// Custom text style for each digit
  final TextStyle? textStyle;

  /// Custom decoration for the input fields
  final InputDecoration? decoration;

  /// Whether to obscure the text (e.g., for passwords)
  final bool obscureText;

  /// Character used when obscuring text
  final String obscuringCharacter;

  /// Horizontal spacing between each digit field
  final double spacing;

  /// Width & height of each input box
  final double size;

  /// Vertical spacing when inputs wrap to the next line
  final double runSpacing;

  /// Text direction (LTR or RTL)
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
  final void Function(String code)? onCompleted;

  /// Border color for the input field in its default state.
  final Color? borderColor;

  /// Border color when the input field is focused.
  final Color? focusedBorderColor;

  /// Border color when the input field has an error.
  final Color? errorBorderColor;

  const OtpPlusInputs({
    super.key,
    required this.shape,
    required this.length,
    this.textStyle,
    this.decoration,
    this.onCompleted,
    this.obscureText = false,
    this.enabled,
    this.spacing = 12,
    this.runSpacing = 12,
    this.cursorColor = Colors.black,
    this.textDirection = TextDirection.ltr,
    this.undoController,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.strutStyle,
    this.textAlign = TextAlign.center,
    this.textAlignVertical = TextAlignVertical.center,
    this.obscuringCharacter = '*',
    this.size = 50,
    this.cursorWidth = 1.5,
    this.contentPadding,
    this.ignorePointers,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorOpacityAnimates,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
  });

  @override
  State<OtpPlusInputs> createState() => _OtpPlusInputsState();
}

class _OtpPlusInputsState extends State<OtpPlusInputs> {
  late final List<FocusNode> _focusNodes;
  late final List<FocusNode> _keyboardFocusNodes;
  late final List<TextEditingController> _controllers;

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
  /// - Calls [onCompleted] if the total input matches the expected OTP length.
  void _onChanged(String value, int index) {
    // If one character is entered, move to the next field
    if (value.length == 1) {
      if (index < widget.length - 1) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus(); // All fields filled
      }
    }
    // If field is cleared, move focus back to the previous one
    else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }

    // Trigger the onCompleted callback with the pasted value
    _handleOnCompleted(value);
  }

  /// Handles the event when the OTP input process is completed.
  ///
  /// This method aggregates the current text values from all individual
  /// TextEditingControllers representing each OTP input field into a single
  /// concatenated string (`fullCode`). It then checks if the combined length
  /// of the entered code matches the expected OTP length (`widget.length`).
  ///
  /// If the input is complete (all fields filled), it triggers the
  /// `onCompleted` callback, passing the full OTP code as an argument.
  /// This allows the parent widget or consumer to respond appropriately,
  /// for example, by validating the OTP or proceeding with authentication.
  ///
  /// Note:
  /// - This method ensures that the callback is only called once the entire
  ///   OTP has been entered, preventing premature triggers.
  /// - It relies on the list `_controllers` maintaining one controller per
  ///   OTP digit input field.
  void _handleOnCompleted(String value) {
    // Build full OTP from all controllers
    String fullCode = _controllers
        .map((TextEditingController c) => c.text)
        .join();

    // Only trigger callback if all fields are filled
    if (fullCode.length == widget.length) {
      widget.onCompleted?.call(fullCode);
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
  void _onBackPressClick(KeyEvent event, int index) {
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
  /// It also manages focus movement and triggers the `onCompleted` callback if the OTP is complete.
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

      // Trigger the onCompleted callback with the pasted value
      _handleOnCompleted('');
    }
  }

  @override
  Widget build(BuildContext context) {
    BorderRadius borderRadius = BorderRadius.circular(
      widget.shape == OtpFieldShape.circle ? 100 : 4,
    );

    return Center(
      child: Wrap(
        spacing: widget.spacing,
        runSpacing: widget.runSpacing,
        children: List.generate(widget.length, (int index) {
          return KeyboardListener(
            focusNode: _keyboardFocusNodes[index],
            onKeyEvent: (event) => _onBackPressClick(event, index),
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
                            label: 'Paste',
                          ),
                        ],
                      );
                    },
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textDirection: widget.textDirection,
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
                decoration:
                    widget.decoration ??
                    InputDecoration(
                      contentPadding:
                          widget.contentPadding ??
                          const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                      border: widget.shape == OtpFieldShape.underline
                          ? UnderlineInputBorder(
                              borderSide: BorderSide(
                                color:
                                    widget.borderColor ??
                                    Colors.grey.withValues(alpha: 0.5),
                              ),
                            )
                          : OutlineInputBorder(
                              borderRadius: borderRadius,
                              borderSide: BorderSide(
                                color:
                                    widget.borderColor ??
                                    Colors.grey.withValues(alpha: 0.5),
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
                                color:
                                    widget.focusedBorderColor ?? Colors.black,
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
                onChanged: (value) => _onChanged(value, index),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Defines the visual shape style of the OTP input fields.
///
/// - `square`: Square boxes around each input.
/// - `underline`: Underline style below each input.
/// - `circle`: Circular borders around each input.
enum OtpFieldShape { square, underline, circle }
