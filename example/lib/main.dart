import 'package:flutter/material.dart';
import 'package:auto_scroll_to_error/auto_scroll_to_error.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Scroll To Error Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Auto Scroll To Error Example')),
        body: const Padding(
          padding: EdgeInsets.all(16.0),
          child: MyForm(),
        ),
      ),
    );
  }
}

class MyForm extends StatefulWidget {
  const MyForm({super.key});

  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final _autoScrollKey = GlobalKey<AutoScrollToErrorState>();
  final _scrollController = ScrollController();

  // Generate a list of field keys for 12 fields
  final List<GlobalKey<FormFieldState<String>>> _fieldKeys =
      List.generate(12, (i) => GlobalKey<FormFieldState<String>>());

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < _fieldKeys.length; i++) ...[
                AutoScrollFormField<String>(
                  key: _fieldKeys[i],
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Field ${i + 1} required'
                      : null,
                  builder: (field) => TextField(
                    decoration: InputDecoration(
                      labelText: 'Field ${i + 1}',
                      errorText: field.errorText,
                    ),
                    onChanged: field.didChange,
                  ),
                ),
                const SizedBox(height: 40),
              ],
              ElevatedButton(
                onPressed: () async {
                  // Validate the form
                  final valid = _formKey.currentState?.validate() ?? false;
                  if (!valid) {
                    // Scroll to the first error field
                    await _autoScrollKey.currentState?.scrollToFirstError();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Form is valid!')),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
