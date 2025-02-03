import pandas as pd
import json
from datetime import datetime

# opening the file and loading all lines
with open("data/users.json","r") as user_file:
    users = [json.loads(line) for line in user_file] # list of rows (each item is a dictionary for each line in users.json)

# making pandas dataframe object
df_users = pd.DataFrame(users)

# there were nested json fields, which all contain one single field
# "$oid" for _"id"
# "$date" for "createdDate"
# "$date" for "lastLogin"
def extract_value(field, key):
    if isinstance(field, dict) and key in field: # making sure this is a nested dict
        return field[key]
    # print(field) # checking where we don't have nested dict - happens when null values
    return None

# calling extract_value function for each of these cols to fetch value from internal dict
df_users["_id"] = [extract_value(x, "$oid") for x in df_users["_id"]]
df_users["createdDate"] = [int(extract_value(x, "$date")) for x in df_users["createdDate"]]
df_users["lastLogin"] = [extract_value(x, "$date") if x is not None else None for x in df_users["lastLogin"]] # few none vals

# converting dates to mySQL friendly datetime format
def mysql_timesformat(date):
    if pd.notna(date):  # check if value is not NaN
        return datetime.utcfromtimestamp(date / 1000).strftime('%Y-%m-%d %H:%M:%S')
    return None  # keeping None for missing values

df_users["createdDate"] = df_users["createdDate"].apply(mysql_timesformat)
df_users["lastLogin"] = df_users["lastLogin"].apply(mysql_timesformat)

# removing all the duplicate rows and making None values mySQL friendly
users_unique = df_users.drop_duplicates()
users_unique.fillna("NULL", inplace=True)

# saving in csv file
users_unique.to_csv('users.csv', index=False)

# print lengths
print('users:', len(df_users),'rows saved')