## Quick Start

Install docker before start.

1. **Build and start the containers:**
   ```bash
   docker-compose up --build
   ```

2. **Create and setup the database** (in a new terminal):
   ```bash
   # First time setup
   docker-compose exec web bundle exec rails db:setup
   
   # Or if database already exists
   docker-compose exec web bundle exec rails db:reset
   ```

3. **Access the application:**
   - Open your browser to http://localhost:3000

Can test with account user@example.com/password

**To completely reset (removes all data):**
```bash
docker-compose down -v  # Remove volumes
docker-compose up -d
docker-compose exec web bundle exec rails db:setup
```