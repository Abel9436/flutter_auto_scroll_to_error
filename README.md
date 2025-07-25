# auto_scroll_to_error

A Flutter widget that improves form UX by automatically scrolling a scrollable form to the first invalid field when validation fails.

## Features
- Scrolls smoothly to the first invalid form field after validation.
- Works with any scrollable (e.g., SingleChildScrollView, ListView).
- Supports nested scroll views and multiple fields.
- Easy integration with existing forms.
- Null safety and robust error handling.

## Installation
Add to your `pubspec.yaml`:
```yaml
dependencies:
  auto_scroll_to_error: ^1.0.0
```
Then run:
```
flutter pub get
```

## Usage
Wrap your scrollable form with `AutoScrollToError` and use `AutoScrollFormField` for each field you want to auto-scroll to on error.

```dart
import 'package:flutter/material.dart';
import 'package:auto_scroll_to_error/auto_scroll_to_error.dart';

class MyForm extends StatefulWidget {
  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final _autoScrollKey = GlobalKey<AutoScrollToErrorState>();
  final _scrollController = ScrollController();

  final _nameKey = GlobalKey<FormFieldState<String>>();
  final _emailKey = GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    return AutoScrollToError(
      key: _autoScrollKey,
      formKey: _formKey,
      scrollController: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AutoScrollFormField<String>(
                key: _nameKey,
                validator: (value) => (value == null || value.isEmpty) ? 'Name required' : null,
                builder: (field) => TextField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    errorText: field.errorText,
                  ),
                  onChanged: field.didChange,
                ),
              ),
              AutoScrollFormField<String>(
                key: _emailKey,
                validator: (value) => (value == null || !value.contains('@')) ? 'Valid email required' : null,
                builder: (field) => TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    errorText: field.errorText,
                  ),
                  onChanged: field.didChange,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final valid = _formKey.currentState?.validate() ?? false;
                  if (!valid) {
                    await _autoScrollKey.currentState?.scrollToFirstError();
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## API Reference

### `AutoScrollToError`
- **formKey**: The `GlobalKey<FormState>` for your form.
- **scrollController**: The `ScrollController` for your scrollable widget.
- **child**: The widget subtree containing your scrollable form.
- **scrollOffset**: (optional) Extra space above the field after scrolling (default: 24.0).
- **scrollToFirstError()**: Call this after validation to scroll to the first error field.

### `AutoScrollFormField<T>`
- Use instead of `TextFormField` or `FormField` for fields you want to auto-scroll to on error.
- Accepts all standard `FormField` parameters.

## Example
See the [`example/`](example) directory for a complete app.

## Contributing
Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## Publishing
1. Update `author`, `homepage`, and `repository` in `pubspec.yaml`.
2. Run `flutter pub publish --dry-run` to check for issues.
3. Run `flutter pub publish` to publish to pub.dev.

## License
[MIT](LICENSE)
