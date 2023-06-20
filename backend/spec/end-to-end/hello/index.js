/* eslint-disable no-undef */
const chai = require('chai');
const request = require('supertest');
const { url } = require('../../utils/constant');

const { expect } = chai;

describe('While getting Helloworld message', async () => {
  it('- should successfully get Helloworld message', async () => {
    const response = await request(url).get('/hello').expect(200);
    expect(response.body.message).to.be.eql('Helloworld');
  });
});
