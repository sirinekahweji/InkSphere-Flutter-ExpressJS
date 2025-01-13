const express = require('express');
const multer = require('multer');
const router = express.Router();
const {
  createBook,
  getAllBooks,
  getBookById,
  updateBook,
  getBooksByUserId,
  deleteBook,
  getBorrowedBooks
} = require('../controllers/bookController');

const upload = multer(); 

router.post('/', upload.single('image'), createBook); 
router.get('/', getAllBooks);
router.get('/user/:userId', getBooksByUserId);
router.get('/dispo', getBorrowedBooks);
router.get('/:id', getBookById);
router.put('/:id',upload.single('image'), updateBook);
router.delete('/:id', deleteBook);

module.exports = router;
