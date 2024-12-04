
const {updateUser
    ,signupUser, loginUser, forgotPassword ,getUserById,changePassword,getUsers,deleteUser} = require('../controllers/userContoller')
const express = require('express');
const router = express.Router();
const requireAuth = require('../middleware/requireAuth');

//signin route
router.post('/', loginUser);

//signup route
router.post('/signup', signupUser);
router.get('/', getUsers);
router.get('/:id', getUserById);
router.delete('/delete/:id', deleteUser);
router.put('/update/:id', updateUser);
router.post('/forgot-password', forgotPassword);
router.post('/change-password', changePassword);



module.exports = router;