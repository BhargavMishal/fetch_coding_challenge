fetch_coding_challenge

References - 
I used stackoverflow, mysqltutorial.org and W3schools to answer syntax related, database importing, and mysql based issues
I used mySQL workbench to execute SQL queries. The data was imported into the database directly from CSV files

Question 1 - Simplified Data Warehouse Schema
I used dbdiagram.io to make the schema
The schema is represented by image in file diagram data_schema.png
This diagram is a very similified version of our data to ensure faster analytical query execution
The only changes made when compared to the original json data are that I have made a new table for receipt item
and unpacked various fields like dates, cpg and ids
An application side database will be much more complicated and can have tables like transaction, item, partner, user_flagged transactions and metabrite related table

Question 2 - SQL Queries to answer business questions
I used MySQL workbench to load into database and then execute all queries
All queries are present in the file business_queries.sql along with comments explaining my approach and details
The screenshots for its execution are also present in the query_results.pdf file

Question 3 - Data Quality Issues
Not necessarily a data quality issue, but all dates were transformed to human readable format
I used python and excel to identify and solve most of the issues
users.json : 
Over 250 duplicate rows. I removed these in python using pandas dataframe.drop_duplicates() function
brands.json :
The barcode was duplicated 7 times, this was found in one code block in brands_extracts.py 
The cpg>ref had only 2 entries namely cogs and cpgs, not sure why cpg was included in brands
receipts.json :
There were a lot of fields in the rewards receipts item list, it would have been much better
The rewards receipt status had no attribute as accepted, does finished indicate accepted
I explored the col values using the filter in csv files
There were a few brandcodes in receipt items which were missing in brands data (noticed this while
solving queries in 2nd part of the excercise)

Question 4 - Message to Stakeholder
This is included in the file email_to_stakeholders.txt