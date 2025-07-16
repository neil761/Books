import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class AddBookPage extends StatefulWidget {
  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _genre = TextEditingController();
  final _year = TextEditingController();

  File? _imageFile;
  Uint8List? _webImage;
  String? _webImageName;

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _webImageName = pickedFile.name;
        });
      } else {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _submitBook() async {
  final uri = Uri.parse('http://localhost:4000/api/books'); 

  var request = http.MultipartRequest('POST', uri);

  request.fields['title'] = _title.text;
  request.fields['author'] = _author.text;
  request.fields['genre'] = _genre.text;
  request.fields['publishedYear'] = _year.text;

  if (kIsWeb && _webImage != null && _webImageName != null) {
    final mimeType = lookupMimeType(_webImageName!) ?? 'image/jpeg';
    request.files.add(http.MultipartFile.fromBytes(
      'image',
      _webImage!,
      filename: _webImageName!,
      contentType: MediaType.parse(mimeType),
    ));
  } else if (_imageFile != null) {
    final mimeType = lookupMimeType(_imageFile!.path) ?? 'image/jpeg';
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      _imageFile!.path,
      contentType: MediaType.parse(mimeType),
    ));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select an image")));
    return;
  }

  final response = await request.send();

  if (response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Book added successfully")));
    Navigator.pop(context, true); 
  } else {
    print('Error: ${response.statusCode}');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add book")));
  }
}



  @override
  Widget build(BuildContext context) {
    final isImagePicked = kIsWeb ? _webImage != null : _imageFile != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Text("Add Book",
        style: TextStyle(
          color: Colors.white
        ),)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _title,
              style: TextStyle(color: Colors.white), 
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            TextField(
              controller: _author,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Author',
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            TextField(
              controller: _genre,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Genre',
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            TextField(
              controller: _year,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Published Year',
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.image, color: Colors.black,),
              label: Text("Pick Cover Image",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
              ),),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange
            ),
            ),
            if (isImagePicked)
              kIsWeb
                  ? Image.memory(_webImage!, height: 150)
                  : Image.file(_imageFile!, height: 150),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitBook,
              child: Text("+ Add Book",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
              ),),
              style: ElevatedButton.styleFrom(
                backgroundColor:  Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
