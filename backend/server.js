require('dotenv').config();
const cors = require('cors');
const express = require('express');
const mongoose = require('mongoose');

const userRoutes = require('./routes/user');
const bookRoutes = require('./routes/book');
const orderRoutes = require('./routes/order');



const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors()); 

// Middleware
app.use(express.json());


app.use((req, res, next) => {
    console.log(req.path, req.method);
    next();
});
app.use('/api/user', userRoutes);
app.use('/api/book', bookRoutes);
app.use('/api/order', orderRoutes);

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI).then(() => {
    console.log('Connected to MongoDB');
    app.listen(PORT, () => {
        console.log(`Server is running on port ${PORT}`);
    });
}).catch((err) => {
    console.error(err);
});


