const { Router } = require('express');
const { helloRoute } = require('./hello/index');

const routes = Router();
routes.use(helloRoute);
module.exports = { routes };
