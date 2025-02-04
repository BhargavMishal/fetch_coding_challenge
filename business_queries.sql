/* 1st question
top 5 brands by receipts scanned for most recent month
first finding max month with a nested select query, alternatively if db is up to date, can use current date's month and year
approach is to join tables brand, receipts and receipt_items to form an indirect connection between brands and receipts
once joined, we can simply either manually enter our desired month or as done in this case, pick max out of date scanned which will give us most recent
then, we only pick receipts where their date scanned is same as our recent month and now group by the brand names in accordance to its occurences
here I am taking the occurence of brands in an receipt as absolute rather than count per receipt
also, I am initially joining the receipts and receipt items into a cte to ensure that I get some result */
WITH CTE AS 
(SELECT DATE_FORMAT(MAX(dateScanned), '%Y-%m') as available_date FROM receipts r INNER JOIN receipt_items ri ON r._id = ri.receipt_id)
SELECT b.name, COUNT(r._id) AS receipts_scanned
    FROM receipts r
    JOIN receipt_items ri ON r._id = ri.receipt_id
    JOIN brands b ON ri.barcode = b.barcode OR ri.brandCode = b.brandCode
    WHERE DATE_FORMAT(r.dateScanned, '%Y-%m') = (SELECT available_date FROM CTE)
    GROUP BY b.name
    ORDER BY receipts_scanned DESC
    LIMIT 5;



/* 2nd question
how does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month
the query below picks top 5 brands for 1 month before max month
the approach is exactly like the previous query, only difference being that we want previous to recent month and which can
be found using the DATE_SUB wth interval 1 Month method as max will be edge and there is only 1 month in interval of 1 to it 
this query was not giving me any results as I was getting nothing from the brands join part (barcode or brandcode did not exist
in brands.json) If we want the answer anyway, we can get the barcode or brandcode from receipt items itself This eliminates the
brands joining part this is not possible to group as we can have either barcode or brandcode as the representative of brand */

-- query to get top 5 brands for previous recent month using date subtract function, this is returning an empty result for me
WITH CTE AS 
(SELECT DATE_FORMAT(DATE_SUB(MAX(dateScanned), INTERVAL 1 MONTH), '%Y-%m') as available_date 
    FROM receipts r 
    INNER JOIN receipt_items ri ON r._id = ri.receipt_id)
SELECT b.name, COUNT(r._id) AS receipts_scanned
    FROM receipts r
    JOIN receipt_items ri ON r._id = ri.receipt_id
    JOIN brands b ON ri.barcode = b.barcode OR ri.brandCode = b.brandCode
    WHERE DATE_FORMAT(r.dateScanned, '%Y-%m') = (SELECT available_date FROM CTE)
    GROUP BY b.name
    ORDER BY receipts_scanned DESC
    LIMIT 5;

/*here is how we can get 2 cols for top 5 brands for recent and prev months by using nested queries and then compare them
using row number function */
WITH RECENT_MONTH AS (
    SELECT b.name, COUNT(r._id) AS receipts_scanned,
           ROW_NUMBER() OVER () AS row_num
    FROM receipts r
    JOIN receipt_items ri ON r._id = ri.receipt_id
    JOIN brands b ON ri.barcode = b.barcode OR ri.brandCode = b.brandCode
    WHERE DATE_FORMAT(r.dateScanned, '%Y-%m') = (
        SELECT DATE_FORMAT(MAX(dateScanned), '%Y-%m') 
        FROM receipts r INNER JOIN receipt_items ri ON r._id = ri.receipt_id
    )
    GROUP BY b.name
    ORDER BY receipts_scanned DESC
    LIMIT 5
),
PREVIOUS_MONTH AS (
    SELECT b.name, COUNT(r._id) AS receipts_scanned,
           ROW_NUMBER() OVER () AS row_num
    FROM receipts r
    JOIN receipt_items ri ON r._id = ri.receipt_id
    JOIN brands b ON ri.barcode = b.barcode OR ri.brandCode = b.brandCode
    WHERE DATE_FORMAT(r.dateScanned, '%Y-%m') = (
        SELECT DATE_FORMAT(DATE_SUB(MAX(dateScanned), INTERVAL 1 MONTH), '%Y-%m') 
        FROM receipts r INNER JOIN receipt_items ri ON r._id = ri.receipt_id
    )
    GROUP BY b.name
    ORDER BY receipts_scanned DESC
    LIMIT 5
)
SELECT RECENT_MONTH.name AS  recent_month_brands, PREVIOUS_MONTH.name AS previous_month_brands
    FROM RECENT_MONTH
    JOIN PREVIOUS_MONTH ON RECENT_MONTH.row_num = PREVIOUS_MONTH.row_num;

/* another possible issue here could be that there is no data present for date scanned - interval 1 month, a possible solution 
to this is to use the dense_rank function and pick dates of ranks 1 as recent and 2 as previous (this code is very inefficient) */
WITH AVAILABLE_RECEIPTS AS
(
SELECT r.dateScanned, date_format(r.dateScanned, '%Y-%m') as yearMonth, 
        DENSE_RANK() OVER (ORDER BY date_format(r.dateScanned, '%Y-%m') DESC) as rankOfDate, 
        ri.barcode, ri.brandCode
	FROM receipts r inner join receipt_items ri ON r._id = ri.receipt_id
	WHERE ri.barcode IS not NULL OR ri.brandCode IS NOT NULL
),
RECENT_MONTH AS
( 
	SELECT b.name, date_format(r.dateScanned, '%Y-%m'), r.barcode, r.brandCode
		FROM AVAILABLE_RECEIPTS r 
        INNER JOIN brands b ON r.barcode = b.barcode OR r.brandCode = b.brandCode
        WHERE rankOfDate=1
),
PREVIOUS_MONTH AS
(
	SELECT b.name, date_format(r.dateScanned, '%Y-%m'), r.barcode, r.brandCode
		FROM AVAILABLE_RECEIPTS r 
        INNER JOIN brands b ON r.barcode = b.barcode OR r.brandCode = b.brandCode
        WHERE rankOfDate=2
),
TOP_5_RECENT_MONTH AS
(
	SELECT b.name, count(CASE WHEN l.barcode IS NOT NULL THEN 1
						WHEN l.brandCode IS NOT NULL THEN 1
                        ELSE 0 END) as counts,
                        ROW_NUMBER() OVER () AS row_num
    FROM RECENT_MONTH l
    INNER JOIN brands b ON b.barcode = l.barcode OR b.brandCode = l.brandCode
    GROUP BY b.name
    ORDER BY b.name DESC
    LIMIT 5
),
TOP_5_PREVIOUS_MONTH AS
(
	SELECT b.name, count(CASE WHEN p.barcode IS NOT NULL THEN 1
						WHEN p.brandCode IS NOT NULL THEN 1
                        ELSE 0 END) as counts,
                        ROW_NUMBER() OVER () AS row_num
    FROM PREVIOUS_MONTH p
    INNER JOIN brands b ON b.barcode = p.barcode OR b.brandCode = p.brandCode
    GROUP BY b.name
    ORDER BY b.name DESC
    LIMIT 5
)
SELECT TOP_5_RECENT_MONTH.name AS  recent_month_brands, TOP_5_PREVIOUS_MONTH.name AS previous_month_brands
    FROM TOP_5_RECENT_MONTH
    JOIN TOP_5_PREVIOUS_MONTH ON TOP_5_RECENT_MONTH.row_num = TOP_5_PREVIOUS_MONTH.row_num;



/* 3rd question
when considering average spend from receipts with 'rewardsReceiptStatus' of 'Accepted' or 'Rejected', which is greater?
there was no category ‘Accepted’ in field 'rewardsReceiptStatus', hence here I am reporting the the 'finished' status in 
its place */
SELECT r.rewardsReceiptStatus AS receipt_status, AVG(r.totalSpent) as avg_total_spent
FROM receipts r
WHERE r.rewardsReceiptStatus IN ('FINISHED', 'REJECTED')
GROUP BY r.rewardsReceiptStatus
ORDER BY AVG(r.totalSpent) DESC;



/* 4th question
when considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, 
which is greater? the approach is similar to 3rd query, using categories 'FINISHED' and 'REJECTED' */
SELECT r.rewardsReceiptStatus AS receipt_status, SUM(r.purchasedItemCount) as total_items_purchased 
FROM receipts r
WHERE r.rewardsReceiptStatus IN ('FINISHED', 'REJECTED')
GROUP BY r.rewardsReceiptStatus
ORDER BY SUM(r.purchasedItemCount) DESC;


/* 5th question
which brand has the most spend among users who were created within the past 6 months?
I am assuming that the final price in receipt items is the amount that a user spent for that item
with this in mind, the approach is to join all 4 tables is to first get userIDs from users for 
past 6 months which can be done with the help of the DATE SUBTRACT with INTERVAL 6 like done in earlier queries, 
join it to receipts using userID, join this to receipt items using receiptID and then to brands using barcode
or brandcode, then pick top brand using sum(final price) by grouping by brand name */
SELECT b.name AS brand_name, SUM(ri.finalPrice) AS total_spent
FROM receipt_items ri
JOIN receipts r ON r._id = ri.receipt_id
JOIN users u ON r.userId = u._id
JOIN brands b ON ri.brandCode = b.brandCode OR ri.barcode = b.barcode
WHERE u.createdDate >= (SELECT DATE_SUB(MAX(u.createdDate), INTERVAL 6 MONTH) FROM users u)
GROUP BY b.name
ORDER BY total_spent DESC
LIMIT 1;


/* 6th question
which brand has the most transactions among users who were created within the past 6 months?
I am assuming that 1 receipt is 1 transaction with this in mind the approach is, similar to 5th query for joining 
and similar to 1st query for picking top brand by receipts where we can count using receipt id */
SELECT b.name AS brand_name, COUNT(r._id) AS total_transactions
FROM receipt_items ri
JOIN receipts r ON r._id = ri.receipt_id
JOIN users u ON r.userId = u._id
JOIN brands b ON ri.brandCode = b.brandCode OR ri.barcode = b.barcode
WHERE u.createdDate >= (SELECT DATE_SUB(MAX(u.createdDate), INTERVAL 6 MONTH) FROM users u)
GROUP BY b.name
ORDER BY total_transactions DESC
LIMIT 1;