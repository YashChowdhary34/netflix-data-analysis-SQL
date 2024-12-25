CREATE DATABASE netflix_db;
USE netflix_db;

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix 
(
	show_id	VARCHAR(10),
    type VARCHAR(10),	
    title VARCHAR(150),
    director VARCHAR(250),
    cast VARCHAR(1000),
    country VARCHAR(150),
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(15),
    listed_in VARCHAR(25),
    description VARCHAR(250)
);

ALTER TABLE netflix MODIFY COLUMN listed_in VARCHAR(100);
ALTER TABLE netflix MODIFY COLUMN description VARCHAR(500);