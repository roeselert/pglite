-- sql/create_users.sql (PostgreSQL) -- Creates a basic users table, inserts 20 test records, and shows example queries to fetch top 3 records.

DROP TABLE IF EXISTS users;

CREATE TABLE users ( 
  id bigserial PRIMARY KEY,
  username varchar(50) NOT NULL UNIQUE,
  email varchar(255) NOT NULL UNIQUE,
  password_hash varchar(64) NOT NULL,
  full_name varchar(100),
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO users (username, email, password_hash, full_name, is_active, created_at)
VALUES 
  ('user1', 'user1@example.com', md5('password1'), 'User One', true, now() - interval '20 days'),
  ('user2', 'user2@example.com', md5('password2'), 'User Two', true, now() - interval '19 days'),
  ('user3', 'user3@example.com', md5('password3'), 'User Three', true, now() - interval '18 days'),
  ('user4', 'user4@example.com', md5('password4'), 'User Four', true, now() - interval '17 days'),
  ('user5', 'user5@example.com', md5('password5'), 'User Five', true, now() - interval '16 days'),
  ('user6', 'user6@example.com', md5('password6'), 'User Six', true, now() - interval '15 days'),
  ('user7', 'user7@example.com', md5('password7'), 'User Seven', true, now() - interval '14 days'),
  ('user8', 'user8@example.com', md5('password8'), 'User Eight', true, now() - interval '13 days'),
  ('user9', 'user9@example.com', md5('password9'), 'User Nine', true, now() - interval '12 days'),
  ('user10', 'user10@example.com', md5('password10'),'User Ten', true, now() - interval '11 days'),
  ('user11', 'user11@example.com', md5('password11'),'User Eleven', false, now() - interval '10 days'),
  ('user12', 'user12@example.com', md5('password12'),'User Twelve', false, now() - interval '9 days'),
  ('user13', 'user13@example.com', md5('password13'),'User Thirteen', true, now() - interval '8 days'),
  ('user14', 'user14@example.com', md5('password14'),'User Fourteen', true, now() - interval '7 days'),
  ('user15', 'user15@example.com', md5('password15'),'User Fifteen', true, now() - interval '6 days'),
  ('user16', 'user16@example.com', md5('password16'),'User Sixteen', true, now() - interval '5 days'),
  ('user17', 'user17@example.com', md5('password17'),'User Seventeen', true, now() - interval '4 days'),
  ('user18', 'user18@example.com', md5('password18'),'User Eighteen', true, now() - interval '3 days'),
  ('user19', 'user19@example.com', md5('password19'),'User Nineteen', true, now() - interval '2 days'),
  ('user20', 'user20@example.com', md5('password20'),'User Twenty', true, now() - interval '1 days');

-- Example: first 3 inserted (by id) 
SELECT id, username, email, full_name, is_active, created_at FROM users ORDER BY id LIMIT 3;

-- Example: top 3 most recent (by created_at) 
SELECT id, username, email, full_name, is_active, created_at FROM users ORDER BY created_at DESC LIMIT 3;
