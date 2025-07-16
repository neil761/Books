import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_book_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List books = [];
  List filteredBooks = [];
  final TextEditingController _searchController = TextEditingController();
  final String baseUrl = 'http://localhost:4000'; 

  @override
  void initState() {
    super.initState();
    fetchBooks();
    _searchController.addListener(_filterBooks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/api/books'));

    if (response.statusCode == 200) {
      setState(() {
        books = json.decode(response.body);
        filteredBooks = books;
      });
    } else {
      throw Exception('Failed to load books');
    }
  }

  void _filterBooks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredBooks = books.where((book) {
        final title = book['title'].toString().toLowerCase();
        return title.contains(query);
      }).toList();
    });
  }

  Future<void> deleteBook(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/books/$id'));

    if (response.statusCode == 200) {
      setState(() {
        books.removeWhere((book) => book['_id'] == id);
        _filterBooks(); // Reapply search filter
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete book')),
      );
    }
  }

  void _showBookDetails(Map<String, dynamic> book) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Book Image
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: book['image'] != null
                        ? Image.network(
                            '$baseUrl/uploads/${book['image']}',
                            fit: BoxFit.fill,
                          )
                        : Container(
                            color: Colors.grey,
                            child: Icon(Icons.book, size: 80, color: Colors.white),
                          ),
                  ),
                ),
                SizedBox(height: 20),
                
                // Book Title
                Text(
                  book['title'] ?? 'No Title',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                
                // Book Details
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Author', book['author'] ?? 'Unknown'),
                      SizedBox(height: 10),
                      _buildDetailRow('Genre', book['genre'] ?? 'Unknown'),
                      SizedBox(height: 10),
                      _buildDetailRow('Published Year', book['publishedYear']?.toString() ?? 'Unknown'),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                
                // Close Button
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Header
          Container(
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(20, 10, 5, 0),
                  child: Text(
                    'Book List',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search Book',
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[850],
                prefixIcon: Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.orange, width: 2),
                ),
              ),
            ),
          ),

          // Book Grid or Message
          Expanded(
            child: filteredBooks.isEmpty
                ? Center(
                    child: Text(
                      'No books found',
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: filteredBooks.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.65,
                    ),
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];
                      return GestureDetector(
                        onTap: () => _showBookDetails(book),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[900],
                          ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 3,
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                child: book['image'] != null
                                    ? Image.network(
                                        '$baseUrl/uploads/${book['image']}',
                                        fit: BoxFit.fill,
                                      )
                                    : Container(
                                        color: Colors.grey,
                                        child: Icon(Icons.book, size: 60, color: Colors.white),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                book['title'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              child: ElevatedButton.icon(
                                onPressed: () => deleteBook(book['_id']),
                                icon: Icon(Icons.delete, color: Colors.black),
                                label: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(Icons.add, color: Colors.black,),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddBookPage()),
          );
          if (result == true) {
            await fetchBooks();
          }
        },
      ),
    );
  }
}
