const { Router } = require('express');
const { helloController } = require('../../controller/hello/index');

const helloRoute = Router();

helloRoute.get('/hello', helloController);
module.exports = { helloRoute };
