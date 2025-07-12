import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _author = TextEditingController();
  final TextEditingController _genre = TextEditingController();
  final TextEditingController _year = TextEditingController();

  Future<void> _submitBook() async {
    final book = {
      'title': _title.text,
      'author': _author.text,
      'genre': _genre.text,
      'publishedYear': int.parse(_year.text),
    };

    final response = await http.post(
      Uri.parse('http://localhost:5000/api/books'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(book),
    );

    if (response.statusCode == 201) {
      Navigator.pop(context);
    } else {
      throw Exception('Failed to add book');
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _genre.dispose();
    _year.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Book')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Enter title' : null,
              ),
              TextFormField(
                controller: _author,
                decoration: const InputDecoration(labelText: 'Author'),
                validator: (value) => value!.isEmpty ? 'Enter author' : null,
              ),
              TextFormField(
                controller: _genre,
                decoration: const InputDecoration(labelText: 'Genre'),
                validator: (value) => value!.isEmpty ? 'Enter genre' : null,
              ),
              TextFormField(
                controller: _year,
                decoration: const InputDecoration(labelText: 'Published Year'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter year' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitBook();
                  }
                },
                child: const Text('Add Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
