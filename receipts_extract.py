import pandas as pd
import json
from datetime import datetime

# loading json file into a dataFrame and getting all fields present in rewardsReceiptItemList
fields = set()
with open("data/raw/receipts.json", "r") as f:
    receipts = [json.loads(line) for line in f]

for receipt in receipts:
    if "rewardsReceiptItemList" in receipt and isinstance(receipt["rewardsReceiptItemList"], list):
        for item in receipt["rewardsReceiptItemList"]:  # iterate through list elements
            for key in item.keys():
                fields.add(key)

# function to extract values from nested dictionaries, only works for 1 level
def extract_value(field, key):
    if isinstance(field, dict) and key in field:
        return field[key]
    return None

rewards_item_fields = list(fields)

# getting entries for receipts and receipt items tables
receipts_list = []
items_list = []

for receipt in receipts:
    receipt_id = extract_value(receipt["_id"], "$oid")  # extracting receipt ID, will be used in items list as well

    # extracting receipt-level fields
    cur_receipt = {
        "_id": receipt_id,
        "createDate": extract_value(receipt.get("createDate"), "$date"),
        "dateScanned": extract_value(receipt.get("dateScanned"), "$date"),
        "finishedDate": extract_value(receipt.get("finishedDate"), "$date"),
        "modifyDate": extract_value(receipt.get("modifyDate"), "$date"),
        "pointsAwardedDate": extract_value(receipt.get("pointsAwardedDate"), "$date"),
        "purchaseDate": extract_value(receipt.get("purchaseDate"), "$date"),
        "bonusPointsEarned":receipt.get("bonusPointsEarned", None),
        "bonusPointsEarnedReason":receipt.get("bonusPointsEarnedReason", None),
        "pointsEarned":receipt.get("pointsEarned", None),
        "purchasedItemCount":receipt.get("purchasedItemCount", None),
        "rewardsReceiptStatus":receipt.get("rewardsReceiptStatus", None),
        "totalSpent":receipt.get("totalSpent", None),
        "userId":receipt.get("userId", None),
    }
    receipts_list.append(cur_receipt)

    # processing rewardsReceiptItemList field to get values for receipt items table
    if "rewardsReceiptItemList" in receipt:
        for item in receipt["rewardsReceiptItemList"]:
            item_data = {"receipt_id": receipt_id}  # making foreign key to link items to receipts
            
            # filling all keys, defaulting to None if missing
            for key in rewards_item_fields:
                item_data[key] = item.get(key, None)

            items_list.append(item_data)

# print(len(items_list))

# converting lists to DataFrames
df_receipts = pd.DataFrame(receipts_list)
df_items = pd.DataFrame(items_list)

# converting dates to mySQL friendly datetime format
def mysql_timesformat(date):
    if pd.notna(date):  # check if value is not NaN
        return datetime.utcfromtimestamp(date / 1000).strftime('%Y-%m-%d %H:%M:%S')
    return None  # keeping None for missing values

df_receipts["createDate"] = df_receipts["createDate"].apply(mysql_timesformat)
df_receipts["dateScanned"] = df_receipts["dateScanned"].apply(mysql_timesformat)
df_receipts["finishedDate"] = df_receipts["finishedDate"].apply(mysql_timesformat)
df_receipts["modifyDate"] = df_receipts["modifyDate"].apply(mysql_timesformat)
df_receipts["pointsAwardedDate"] = df_receipts["pointsAwardedDate"].apply(mysql_timesformat)
df_receipts["purchaseDate"] = df_receipts["purchaseDate"].apply(mysql_timesformat)

print(df_receipts.head(5))

# replacing empty strings or NaN with 'NULL' to help with mySQL insertions
df_receipts.fillna("NULL", inplace=True)
df_items.fillna("NULL", inplace=True)

# saving tables as CSV
df_receipts.to_csv("receipts.csv", index=False)
df_items.to_csv("receipt_items.csv", index=False)

# print lengths
print('Receipts:', len(df_receipts), 'rows saved')
print('Rewards Items:', len(df_items), 'rows saved')