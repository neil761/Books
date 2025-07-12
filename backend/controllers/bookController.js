const Book = require('../models/bookModel');

// GET all books
exports.getBooks = async (req, res) => {
  const books = await Book.find().sort({ createdAt: -1 });
  res.status(200).json(books);
};

// GET single book
exports.getBook = async (req, res) => {
  const book = await Book.findById(req.params.id);
  res.status(200).json(book);
};

// CREATE book
exports.createBook = async (req, res) => {
  const newBook = await Book.create(req.body);
  res.status(201).json(newBook);
};

// UPDATE book
exports.updateBook = async (req, res) => {
  const updatedBook = await Book.findByIdAndUpdate(req.params.id, req.body, { new: true });
  res.status(200).json(updatedBook);
};

// DELETE book
exports.deleteBook = async (req, res) => {
  await Book.findByIdAndDelete(req.params.id);
  res.status(204).end();
};
