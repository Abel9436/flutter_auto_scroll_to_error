import 'package:flutter/material.dart';

/// A widget that automatically scrolls to the first invalid form field when validation fails.
///
/// Usage:
///   - Wrap your scrollable form with [AutoScrollToError].
///   - Pass the [formKey], [scrollController], and your child widget.
///   - Call [scrollToFirstError] after form validation to scroll to the first error field.
class AutoScrollToError extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final ScrollController scrollController;
  final Widget child;
  final double scrollOffset;

  /// [scrollOffset] is the extra space above the field after scrolling (default: 24).
  const AutoScrollToError({
    Key? key,
    required this.formKey,
    required this.scrollController,
    required this.child,
    this.scrollOffset = 24.0,
  }) : super(key: key);

  /// Call this method after form validation to scroll to the first error field.
  /// Example:
  ///   if (!formKey.currentState!.validate()) {
  ///     autoScrollKey.currentState?.scrollToFirstError();
  ///   }
  static AutoScrollToErrorState? of(BuildContext context) {
    return context.findAncestorStateOfType<AutoScrollToErrorState>();
  }

  @override
  AutoScrollToErrorState createState() => AutoScrollToErrorState();
}

class AutoScrollToErrorState extends State<AutoScrollToError> {
  /// Stores the registered field keys.
  final List<GlobalKey<FormFieldState>> _fieldKeys = [];

  /// Registers a field key for error scrolling.
  void registerFieldKey(GlobalKey<FormFieldState> key) {
    if (!_fieldKeys.contains(key)) {
      _fieldKeys.add(key);
    }
  }

  /// Unregisters a field key.
  void unregisterFieldKey(GlobalKey<FormFieldState> key) {
    _fieldKeys.remove(key);
  }

  /// Call this after form validation to scroll to the first error field.
  Future<void> scrollToFirstError() async {
    // Find the first field with an error
    for (final key in _fieldKeys) {
      final state = key.currentState;
      if (state != null && state.hasError) {
        final context = key.currentContext;
        if (context != null) {
          await _scrollToContext(context);
        }
        break;
      }
    }
  }

  /// Scrolls the scroll view to bring the widget associated with [context] into view.
  Future<void> _scrollToContext(BuildContext fieldContext) async {
    // Get the RenderBox of the field
    final RenderObject? object = fieldContext.findRenderObject();
    if (object is! RenderBox) return;

    // Get the position of the field relative to the scrollable
    final scrollBox = widget.scrollController.position.context.storageContext
        .findRenderObject();
    if (scrollBox is! RenderBox) return;

    final fieldOffset = object.localToGlobal(Offset.zero, ancestor: scrollBox);
    final scrollOffset =
        widget.scrollController.offset + fieldOffset.dy - widget.scrollOffset;

    // Clamp the offset to the scrollable's range
    final minScroll = widget.scrollController.position.minScrollExtent;
    final maxScroll = widget.scrollController.position.maxScrollExtent;
    final target = scrollOffset.clamp(minScroll, maxScroll);

    await widget.scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _AutoScrollToErrorScope(
      state: this,
      child: widget.child,
    );
  }
}

/// Inherited widget to provide access to the AutoScrollToErrorState for field registration.
class _AutoScrollToErrorScope extends InheritedWidget {
  final AutoScrollToErrorState state;
  const _AutoScrollToErrorScope({required this.state, required Widget child})
      : super(child: child);

  static AutoScrollToErrorState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_AutoScrollToErrorScope>()
        ?.state;
  }

  @override
  bool updateShouldNotify(_AutoScrollToErrorScope oldWidget) => false;
}

/// A FormField wrapper that registers itself for error scrolling.
/// Use this instead of [TextFormField] or [FormField] directly.
class AutoScrollFormField<T> extends FormField<T> {
  AutoScrollFormField({
    Key? key,
    required FormFieldBuilder<T> builder,
    FormFieldSetter<T>? onSaved,
    FormFieldValidator<T>? validator,
    T? initialValue,
    bool autovalidate = false,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
  }) : super(
          key: key,
          builder: builder,
          onSaved: onSaved,
          validator: validator,
          initialValue: initialValue,
          enabled: enabled,
          autovalidateMode: autovalidateMode ??
              (autovalidate
                  ? AutovalidateMode.always
                  : AutovalidateMode.disabled),
        );

  @override
  FormFieldState<T> createState() => _AutoScrollFormFieldState<T>();
}

class _AutoScrollFormFieldState<T> extends FormFieldState<T> {
  @override
  void didChange(T? value) {
    super.didChange(value);
    // Optionally, you could trigger scroll here if desired on change.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = _AutoScrollToErrorScope.of(context);
    if (state != null && widget.key is GlobalKey<FormFieldState>) {
      state.registerFieldKey(widget.key as GlobalKey<FormFieldState>);
    }
  }

  @override
  void dispose() {
    final state = _AutoScrollToErrorScope.of(context);
    if (state != null && widget.key is GlobalKey<FormFieldState>) {
      state.unregisterFieldKey(widget.key as GlobalKey<FormFieldState>);
    }
    super.dispose();
  }
}
