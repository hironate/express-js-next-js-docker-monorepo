const { config } = require('dotenv');

const { app } = require('./app');
const { routes } = require('./routes/index');
const { configuration } = require('./config/index');

app.use(routes);

config();

// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  res.status(500).json({ message: 'Internal Server Error' });
});

app.listen(configuration.port, () => {
  // eslint-disable-next-line no-console
  console.log(`Server is running on port ${configuration.port}`);
});
