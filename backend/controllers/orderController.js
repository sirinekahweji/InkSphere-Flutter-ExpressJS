const Order = require('../models/orderModel');

const createOrder = async (req, res) => {
  try {
    const order = new Order(req.body);
    const savedOrder = await order.save();
    res.status(201).json(savedOrder);
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors de la création de la commande', error: error.message });
  }
};

const getAllOrders = async (req, res) => {
  try {
    const orders = await Order.find().populate('userId').populate('books.bookId');
    res.status(200).json(orders);
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors de la récupération des commandes', error: error.message });
  }
};

const getOrderById = async (req, res) => {
  const { id } = req.params;
  try {
    const order = await Order.findById(id).populate('userId').populate('books.bookId');
    if (!order) return res.status(404).json({ message: 'Commande non trouvée' });
    res.status(200).json(order);
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors de la récupération de la commande', error: error.message });
  }
};

const updateOrder = async (req, res) => {
  const { id } = req.params;
  try {
    const updatedOrder = await Order.findByIdAndUpdate(id, req.body, { new: true });
    if (!updatedOrder) return res.status(404).json({ message: 'Commande non trouvée' });
    res.status(200).json(updatedOrder);
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors de la mise à jour de la commande', error: error.message });
  }
};

const deleteOrder = async (req, res) => {
  const { id } = req.params;
  try {
    const deletedOrder = await Order.findByIdAndDelete(id);
    if (!deletedOrder) return res.status(404).json({ message: 'Commande non trouvée' });
    res.status(200).json({ message: 'Commande supprimée avec succès' });
  } catch (error) {
    res.status(500).json({ message: 'Erreur lors de la suppression de la commande', error: error.message });
  }
};

module.exports = {
  createOrder,
  getAllOrders,
  getOrderById,
  updateOrder,
  deleteOrder
};
