const express = require('express');
const router = express.Router();
const multer = require('multer');
const {
  createBook,
  deleteBook,
  getBooks,
} = require('../controllers/bookController');

// GET all books
router.get('/', getBooks);

// POST new book
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, './uploads');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + '-' + file.originalname);
  }
});
const upload = multer({ storage });

router.post('/', upload.single('image'), createBook);

// DELETE book
router.delete('/:id', deleteBook);

module.exports = router;
