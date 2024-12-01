const Book = require('../models/bookModel');

const createBook = async (req, res) => {
  try {
    const book = new Book(req.body);
    const savedBook = await book.save();
    res.status(201).json(savedBook);
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors de la création du livre', error });
  }
};

const getAllBooks = async (req, res) => {
  try {
    const books = await Book.find();
    res.status(200).json(books);
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors de la récupération des livres', error });
  }
};

const getBookById = async (req, res) => {
  try {
    const book = await Book.findById(req.params.id);
    if (!book) return res.status(404).json({ message: 'Livre non trouvé' });
    res.status(200).json(book);
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors de la récupération du livre', error });
  }
};

const updateBook = async (req, res) => {
  try {
    const updatedBook = await Book.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updatedBook) return res.status(404).json({ message: 'Livre non trouvé' });
    res.status(200).json(updatedBook);
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors de la mise à jour du livre', error });
  }
};

const deleteBook = async (req, res) => {
  try {
    const deletedBook = await Book.findByIdAndDelete(req.params.id);
    if (!deletedBook) return res.status(404).json({ message: 'Livre non trouvé' });
    res.status(200).json({ message: 'Livre supprimé avec succès' });
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors de la suppression du livre', error });
  }
};

module.exports = {
  createBook,
  getAllBooks,
  getBookById,
  updateBook,
  deleteBook
};
