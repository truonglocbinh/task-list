## Quick Start

Install docker before start.

1. **Build and start the containers:**
   ```bash
   docker-compose up --build
   ```

2. **Create and setup the database** (in a new terminal):
   ```bash
   docker-compose exec web bundle exec rails db:create db:migrate db:seed
   ```

3. **Access the application:**
   - Open your browser to http://localhost:3000

Can test with account user@example.com/password