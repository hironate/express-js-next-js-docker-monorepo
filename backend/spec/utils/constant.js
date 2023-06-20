const { config } = require('dotenv');

config();
const url = process.env.INTEGRATION_TEST_HOST_URL;

module.exports = { url };
