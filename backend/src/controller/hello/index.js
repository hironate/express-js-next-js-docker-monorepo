const helloController = (req, res) => {
  try {
    return res.status(200).json({ message: 'Helloworld' });
  } catch (error) {
    return res.status(500).json({ error });
  }
};
module.exports = { helloController };
