# Setup

Toolchain: Ruby 3.4, Rails 8, MariaDB 10.11+, Node.js.
```bash
mise install
bundle install
bin/importmap install
bin/rails tailwindcss:install
bin/rails db:create db:schema:load db:seed
bin/dev
```
