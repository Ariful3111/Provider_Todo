import 'package:flutter/material.dart';

class TodoForm extends StatefulWidget {
  final String title;
  final String description;
  final String buttonLabel;
  final void Function(String title, String description) onSubmit;

  const TodoForm({
    super.key,
    required this.title,
    required this.description,
    required this.onSubmit,
    this.buttonLabel = 'Add Todo',
  });

  @override
  State<TodoForm> createState() => _TodoFormState();
}

class _TodoFormState extends State<TodoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _descriptionController = TextEditingController(text: widget.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _titleController,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Title cannot be empty' : null,
            maxLines: 1,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: UnderlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Description cannot be empty' : null,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: UnderlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _submit,
              child: Text(widget.buttonLabel,
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}