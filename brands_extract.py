import pandas as pd
import json

# loading JSON file into a dataFrame
with open("data/brands.json", "r") as f:
    brands = [json.loads(line) for line in f]

# extract values from nested dictionaries
def extract_value(field, key):
    if isinstance(field, dict) and key in field:
        return field[key]
    return None  # return None if key doesn't exist

# extract "$oid" from "cpg" > "$id" (2 depth - cpg>id)
def extract_cpg_oid(cpg_field):
    if isinstance(cpg_field, dict):
        cpg_id = cpg_field.get("$id", {})
        if isinstance(cpg_id, dict):
            return cpg_id.get("$oid", None)
    return None  # return None if not a valid dictionary

# extract "$ref" from "cpg"
def extract_cpg_ref(cpg_field):
    if isinstance(cpg_field, dict):
        return cpg_field.get("$ref", None)
    return None  # return None if not a valid dictionary

# converting JSON to dataFrame
df_brands = pd.DataFrame(brands)

# extracting values from nested dictionaries
df_brands["_id"] = df_brands["_id"].apply(extract_value, args=("$oid",)) # extracting $oid from _id
df_brands["cpg_id"] = df_brands["cpg"].apply(extract_cpg_oid)  # extracting $oid from cpg>$id
df_brands["cpg_ref"] = df_brands["cpg"].apply(extract_cpg_ref)  # extracting $ref from cpg
df_brands.drop("cpg", axis=1, inplace=True) # dropping the original CPG col

# droping duplicate rows
df_brands = df_brands.drop_duplicates()

# saveing the data to CSV
df_brands.to_csv("brands.csv", index=False)

# print lengths
print('brands:', len(df_brands),'rows saved')