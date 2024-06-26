-- Create payments database if does not exist
CREATE DATABASE payments;
\c payments;

-- Enable pgvector extension
CREATE EXTENSION vector;

-- Create table to store the processing date, the date in this table will be used to download files from S3
CREATE TABLE IF NOT EXISTS processing_date (
    processing_date DATE NOT NULL
);

-- Insert a record in table processing_date using the current date
INSERT INTO processing_date (processing_date) VALUES (CURRENT_DATE);

-- Create table to store the file names
CREATE TABLE IF NOT EXISTS file_names (
    file_name VARCHAR(255) NOT NULL
);

-- Create table to store payment data and vectors
CREATE TABLE IF NOT EXISTS payment_data (
    id BIGSERIAL PRIMARY KEY,
    embedding vector(848)
);
