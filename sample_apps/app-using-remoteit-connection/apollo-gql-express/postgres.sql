CREATE TABLE priorities (
  id SERIAL,
  slug varchar(64) NOT NULL,
  name varchar(256) NOT NULL,
  PRIMARY KEY (id)
);

INSERT INTO priorities (id, slug, name) VALUES
(1,	'low',	'Low'),
(2,	'normal',	'Normal'),
(3,	'high',	'High');


CREATE TABLE status (
  id SERIAL,
  slug varchar(64) NOT NULL,
  name varchar(256) NOT NULL,
  PRIMARY KEY (id)
);

INSERT INTO status (id, slug, name) VALUES
(1,	'open',	'Open'),
(2,	'doing',	'Doing'),
(3,	'waiting',	'Waiting'),
(4,	'closed',	'Closed');


CREATE TABLE tickets (
  id SERIAL,
  subject varchar(256) NOT NULL,
  priority_id INT NOT NULL,
  status_id INT NOT NULL,
  user_id INT NOT NULL,
  assigned_to_user_id INT DEFAULT NULL,
  PRIMARY KEY (id)
);

INSERT INTO tickets (id,subject,priority_id,status_id,user_id,assigned_to_user_id) VALUES
(3,	'My computer is on fire',	3,	1,	2,	NULL),
(4,	'MS Word is not starting, can someone help?',	1,	2,	3,	2),
(5,	'There is a bug in the cart of the webshop, steps to reproduce are included',	3,	2,	4,	2),
(6,	'404 error: website not found - website down?',	3,	4,	4,	2);

CREATE TABLE users (
  id SERIAL,
  name varchar(256) NOT NULL,
  email varchar(256) NOT NULL,
  PRIMARY KEY (id)
);

INSERT INTO users (id, name, email) VALUES
(2,	'Dirk Wolthuis',	'hallo@ikbendirk.nl'),
(3,	'Chris Vogt',	'chris_vogt@ikbendirk.nl'),
(4,	'Andrew Clark',	'andrew_clark@ikbendirk.nl');
