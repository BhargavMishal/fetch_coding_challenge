# Highest level analysis

import pandas as pd
import json
from collections import defaultdict

# convert given file path to JSON
def json_to_df(json_path):
    with open (json_path, 'r', encoding='utf-8') as f: # opening file in read mode
        list = [json.loads(line) for line in f] # getting all dictionaries in a list
    return pd.DataFrame(list)

# get dataframe for each file
receipts_df = json_to_df("data/receipts.json")
users_df = json_to_df("data/users.json")
brands_df = json_to_df("data/brands.json")

# looking for highest level key presence in all entries
def outermost_keys(df,df_name):
    key_freq = defaultdict(int)
    row_counter = 0
    for row in df.to_dict(orient='records'): # getting individual dictionaries for each row
        for key in row.keys():
            key_freq[key] += 1
    
    print('Overall outermost keys for',df_name) 
    for key in key_freq: # printing vs overall len
        print(key,'found in',key_freq[key],'/',len(df))

# checking key presence
outermost_keys(receipts_df,'receipts')
outermost_keys(users_df,'users')
outermost_keys(brands_df,'brands')

# looking for unique and null values
def unique_null(df,df_name):
    print('Unique values for',df_name,'by columns')
    print('Total rows:',len(df))
    
    # print(df.dtypes) # looking for all datatypes
    
    for col in df.columns:
        if df[col].apply(lambda x: isinstance(x, (str,int,float,bool,type(None)))).all(): # checking if all values in col belong to one of these data types
            unique = df[col].nunique() # gives no. of unique vals in col
            print(col,'contains',unique,'unique values')
        else: # one or more entry in col has a data of type dict (nested json (was getting issue when directly running nunique))
            print(col,'contains nested json')
    print('Null values for',df_name,'by columns')
    print(df.isnull().sum())

# checking null and unique vals
unique_null(receipts_df,'receipts')
unique_null(users_df,'users')
unique_null(brands_df,'brands')