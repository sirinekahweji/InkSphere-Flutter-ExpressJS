const jwt = require('jsonwebtoken');
const User = require('../models/userModel');
const nodemailer = require('nodemailer');
const bcrypt = require('bcrypt')
const crypto = require('crypto');

const createToken = (_id) => {
  return jwt.sign({ _id }, process.env.SECRET, { expiresIn: '3d' });
}
// login user
const loginUser = async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.signin(email, password);

    // create token
    const token = createToken(user._id);

    const response = { name: user.name,role: user.role, email, token };
    //console.log('Login Response:', response); 
    res.status(200).json(response);
  } catch (error) {

    console.log(error.message);
    res.status(400).json({ error: error.message });
  }
}

// signup user
const signupUser = async (req, res) => {
  const { name, email, password } = req.body;

  try {
    const user = await User.signup(name, email, password);

    // create token
    const token = createToken(user._id);

    const response = { name,role: user.role , email, token };
    res.status(200).json(response);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}

const forgotPassword = async (req, res) => {
  const { email } = req.body;
  console.log("email", email)

  try {
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const newPassword = crypto.randomBytes(6).toString('hex');
    const salt = await bcrypt.genSalt(10);
    const hash = await bcrypt.hash(newPassword, salt);

    user.password = hash;
    await user.save();

    var transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.USER,
        pass: process.env.PASS
      }
    });

    var mailOptions = {
      from: process.env.USER,
      to: user.email,
      subject: 'Password Reset',
      html: `
        <div style="width: 100%; background-color: white; padding: 20px; border-radius: 10px; color: white;">
          <div style="text-align: center;">
            <!-- Logo -->
            <img src="https://i.imgur.com/hNhZolG.png" alt="Logo TechBo" style="width: 150px; height: auto;" />
          </div>

          <h1 style="color: #000; text-align: center;">Password Reset</h1>
          <p style="font-size: 16px; color: #000;">
            Hello ${user.name},<br><br>
            Your password on TechBot (QuizBot) has been reset, the new password is:<br><br>
            New password: <strong>${newPassword}</strong><br><br>
            Please log in using this password and make sure to change it afterwards.
          </p>
          <p style="text-align: center; color: #000;">
For any questions please contact us by email at techbot600@gmail.com     </p>
        </div>
      `
    };

    transporter.sendMail(mailOptions, (error, info) => {
      if (error) {
        return res.status(500).json({ message: 'Failed to send email' });
      }

      res.status(200).json({ message: 'New password sent to your email' });
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};



const changePassword = async (req, res) => {
  const { email, oldPassword, newPassword } = req.body;

  try {
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const isMatch = await bcrypt.compare(oldPassword, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Incorrect old password' });
    }

    const salt = await bcrypt.genSalt(10);
    const hash = await bcrypt.hash(newPassword, salt);

    user.password = hash;
    await user.save();

    res.status(200).json({ message: 'Password updated successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

const getUsers = async (req, res) => {
  try {
    const users = await User.find({});
    //console.log(users)
    res.status(200).json(users);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
};

const deleteUser = async (req, res) => {
  const { id } = req.params;

  try {
    const user = await User.findById(id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    await User.findByIdAndDelete(id);
    console.log("User deleted successfully");
    res.status(200).json({ message: 'User deleted successfully' });
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({ error: 'Server error' });
  }
};


const updateUser = async (req, res) => {
  const { id } = req.params; 

  try {
    const user = await User.findById(id);

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    const updatedUser= await User.findByIdAndUpdate(req.params.id, req.body, { new: true });
    console.error(' updating user done:');
    res.status(200).json({ message: 'User updated successfully', updatedUser });
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({ error: 'Server error' });
  }
};




const getUserById = async (req, res) => {
  const { id } = req.params; 

  try {
    const user = await User.findById(id); 

    if (!user) {
      return res.status(404).json({ message: 'User not found' }); 
    }

    res.status(200).json(user); 
  } catch (error) {
    res.status(500).json({ message: 'Server error', error }); 
  }
};


module.exports = {updateUser ,signupUser,getUserById ,loginUser, forgotPassword ,changePassword,getUsers,deleteUser}
