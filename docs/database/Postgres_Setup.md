## Configuration (Script)
##### Download the script
- Run `cd /etc/postgresql/*/main/`
- Copy [Postgres_Setup.sql](https://github.com/HackTheQuack/NCAE-Training/blob/main/docs/database/Postgres_Setup.sql) into a script
##### Accessing PostgreSQL 
```
sudo -iu postgres psql
```
##### Connect to a database
```
\c <database>
```
##### Check default schema
```
SHOW search_path;
```
##### Run Postgres_Setup.sql
```
\i /etc/postgresql/*/main/Postgres_Setup.sql
```
## Configuration (Manual)
##### Accessing PostgreSQL 
```
sudo -iu postgres psql
```
##### Changing the Postgres user password
```
ALTER USER postgres WITH PASSWORD '<password>';
```
##### Creating a user
```
CREATE USER <username> WITH PASSWORD '<password>';
```
##### Creating a database (Probably already created)
```
CREATE DATABASE <database>;
```
##### Connect to a database
```
\c <database>
```
##### Check default schema
```
SHOW search_path;
```
##### Giving permissions to a user
```
GRANT CONNECT ON DATABASE <database> TO <username>;
GRANT USAGE, CREATE ON SCHEMA public TO <username>;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO <username>;
```
## Configuration (Config Files)
##### Files
- `/etc/postgresql/*/main/pg_hba.conf`
- `/etc/postgresql/*/main/postgresql.conf`
##### postgres.conf
- Find `listen_addresses`
- Uncomment it if needed
- Set the listen address to the following
```
listen_addresses = '*'
```
##### pg_hba.conf
- Copy the [Postgres_Setup.sh](https://github.com/HackTheQuack/NCAE-Training/blob/main/docs/database/Postgres_Setup.sh)
- Run the command `sudo chmod +x Postgres_Setup.sh`
- Run the command `sudo ./Postgres_Setup.sh`
- Run the command `sudo rm Postgres_Setup.sh`
- To login as `postgres` add the line `local all postgres scram-sha-256`
##### File removal
```
sudo rm environment
sudo rm pg_ctl.conf
sudo rm pg_ident.conf
```
## Postgres Access
- Remember to add to the .env file for the http server
```
[
  {
    "host": "<IP address>",
    "port": 5432,
    "database": "<database>",
    "password": "<password>",
    "username": "<username>"
  }
]
```
## Permissions
##### Viewing permissions
```
# Database permissions
# Access privileges
# <user>=<privileges/<grantor>
# C = CREATE (schemas)
# T = TEMP (tables)
# c = CONNECT
\l [<database>]

# Table permissions
# Access privileges
# <user>=<privileges/<grantor>
# a = INSERT
# r = SELECT
# w = UPDATE
# d = DELETE
# D = TRUNCATE
# x = REFERENCES
# t = TRIGGER
 
\z [<table name>]
```
##### Altering permissions
```
# Database
REVOKE CREATE ON DATABASE <database> FROM <username>;
REVOKE TEMP ON DATABASE <database> FROM <username>;
REVOKE CONNECT ON DATABASE <database> FROM <username>;

# Table
REVOKE INSERT, UPDATE, DELETE ON TABLE <table name> FROM <username>;
REVOKE ALL PRIVILEGES ON TABLE <table name> FROM <username>;

# User
ALTER ROLE <username> WITH NOSUPERUSER;
ALTER ROLE <username> WITH NOCREATEDB;
ALTER ROLE <username> WITH NOCREATEROLE;
ALTER ROLE <username> WITH NOLOGIN;
ALTER ROLE <username> WITH NOBYPASSRLS;
```
## Security
##### List all users and their roles
```
\du [username]
```
##### List all functions
```
\df
```
##### List all databases
```
\l
```
##### Describe a table
```
\d <table name>
```
##### List all schemas
```
\dn
```
##### Delete a user
```
DROP USER <username>;
or
sudo -u postgres dropuser <username> -e
```
##### Delete a database
```
DROP DATABASE <database>;
```
##### Delete a function
```
DROP FUNCTION <function_name(datatype, datatype,...)>;
```
##### Delete a table
```
DROP TABLE <table name>;
```
## Miscellaneous
##### Create a table
```
CREATE TABLE <table name> (
<column name> INTEGER [PRIMARY KEY | UNIQUE | NOT NULL | DEFAULT <value>]
<column name> DECIMAL(p,2) [PRIMARY KEY | UNIQUE | NOT NULL | DEFAULT <value>]
<column name> VARCHAR(n) [PRIMARY KEY | UNIQUE | NOT NULL | DEFAULT <value>]
<column name> BOOLEAN [PRIMARY KEY | UNIQUE | NOT NULL | DEFAULT <value>]
<column name> DATE [PRIMARY KEY | UNIQUE | NOT NULL | DEFAULT <value>]
);
```
##### Substitute values using sed
```
sed -i 's/<old>/<new>/g' <filename>
```
