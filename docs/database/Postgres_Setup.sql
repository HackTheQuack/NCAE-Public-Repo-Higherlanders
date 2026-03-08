ALTER USER postgres WITH PASSWORD '<password>';
CREATE USER <username> WITH PASSWORD '<password>';
GRANT CONNECT ON DATABASE <database> TO <username>;
GRANT USAGE, CREATE ON SCHEMA public TO <username>;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO <username>;
