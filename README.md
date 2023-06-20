## Fullstack Express.js, Next.js Monorepo

This comprehensive repository serves as a solid foundation for building powerful web applications using Express.js and Next.js frameworks. We have included a complete setup for end-to-end tests so you can get started with tests quickly. Additionally, the entire application is containerized with Docker for seamless deployment and scalability.

**If you find this repository helpful, don't forget to star it!**

## Forking the Repository

If you want to contribute to this project or make changes, you can fork the repository. Follow the steps below to fork and contribute:

1. Click on the "Fork" button on the top-right corner of this repository page. This will create a copy of the repository under your GitHub account.

2. Clone the forked repository to your local machine:

   ```shell
   git clone git@github.com:hironate/express-js-next-js-docker-monorepo.git
   ```

### Prerequisites

Make sure you have the following software installed on your machine:

- Docker
- Docker Compose
- Node.js

### Installation

1. Navigate to the `devops` directory:

   ```shell
   cd express-js-next-js-docker-monorepo/devops
   ```

2. Make the `init-database.sh` script executable:

   ```shell
   chmod +x init-database.sh
   ```

3. Build and start the containers using Docker Compose:

   ```shell
   docker compose up
   ```

   This command will spin up the backend and frontend services along with the PostgreSQL database. The backend will be accessible at `http://localhost:3000`, and the frontend will be accessible at `http://localhost:3001`. The PostgreSQL database will be running on `localhost` on port `5432`.

### Database Access

To access the PostgreSQL database, you can use tools like pgAdmin. Follow the steps below:

1. Open pgAdmin.
2. Set the following credentials:
   - Host: `localhost`
   - Database: `monorepodb`
   - User: `monorepo_user`
   - Password: `monorepo-password`
   - Port: `5432`

### Running Backend Tests

To run the backend tests in the "backend" directory, follow the steps below:

1. Open a terminal or command prompt.

2. Navigate to the "backend" directory of the monorepo:

   ```shell
   cd express-js-next-js-docker-monorepo/backend
   ```

3. Run the following command to execute the backend tests:

   ```shell
   npm run test:local
   ```

   This command will run the tests and display the test results in the terminal or command prompt.

## Contribution Guidelines

To contribute to this project, please follow these guidelines:

- Fork the repository and make your changes in a new branch.
- Ensure that your code is well-documented and follows the existing coding style.
- Write clear commit messages for your changes.
- Make sure all tests pass successfully.
- Open a pull request with a detailed description of your changes.

## Authors

- Hiren Kavad
  - This project is co-authored by Hiren Kavad. You can find more information about the author on their website: [hirenkavad.com](https://www.hirenkavad.com).
- Yatharth Andhariya

## Acknowledgments

- [Docker](https://www.docker.com/) for containerization.
- [Docker Compose](https://docs.docker.com/compose/) for multi-container application orchestration.

## License

This project is licensed under the MIT License.
