const Book = require('../models/bookModel');
const mongoose = require('mongoose');
const fs = require('fs');
const path = require('path');

// Create Book
const createBook = async (req, res) => {
  try {
    const { title, author, genre, publishedYear } = req.body;
    const image = req.file ? req.file.filename : null;

    const book = await Book.create({
      title,
      author,
      genre,
      publishedYear,
      image,
    });

    res.status(201).json(book);
  } catch (error) {
    console.error('Error creating book:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get All Books
const getBooks = async (req, res) => {
  try {
    const books = await Book.find().sort({ createdAt: -1 });
    res.status(200).json(books);
  } catch (error) {
    console.error('Error fetching books:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Delete Book
const deleteBook = async (req, res) => {
  const { id } = req.params;

  if (!mongoose.Types.ObjectId.isValid(id)) {
    return res.status(404).json({ error: 'Invalid Book ID' });
  }

  try {
    const book = await Book.findByIdAndDelete(id);

    if (!book) {
      return res.status(404).json({ error: 'Book not found' });
    }

    res.status(200).json({ message: 'Book deleted successfully' });
  } catch (error) {
    console.error('Delete book error:', error);
    res.status(500).json({ error: 'Server error deleting book' });
  }
};

module.exports = {
  createBook,
  getBooks,
  deleteBook,
};
