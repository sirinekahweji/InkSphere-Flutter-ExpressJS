const express = require('express');
const router = express.Router();
const {  createBook,
    getAllBooks,
    getBookById,
    updateBook,getBooksByUserId,
    deleteBook,getBorrowedBooks} = require('../controllers/bookController')

const upload = require('../middleware/upload');



//router.post('/', createBook);
router.post('/', upload.single('image'), createBook);
router.get('/', getAllBooks);
router.get('/user/:userId', getBooksByUserId);
router.get('/dispo', getBorrowedBooks);
router.get('/:id', getBookById);
router.put('/:id', updateBook);
router.delete('/:id', deleteBook);

module.exports = router;