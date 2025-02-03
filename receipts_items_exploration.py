import json
from collections import defaultdict

# extract unique keys from rewardsReceiptItemList
def extract_unique_keys(file_path):
    freq_counter = defaultdict(int)
    unique_counter = {}
    counter = 0
    with open(file_path, 'r', encoding='utf-8') as f:
        for line in f:
            try:
                receipt = json.loads(line.strip())  # parsing each line as JSON
                if 'rewardsReceiptItemList' in receipt and isinstance(receipt['rewardsReceiptItemList'], list):
                    for item in receipt['rewardsReceiptItemList']:  # iterate through list items
                        counter += 1
                        for key in item.keys():
                            
                            if key in unique_counter:
                                unique_counter[key].add(item[key])
                            else:
                                unique_counter[key] = set()
                                unique_counter[key].add(item[key])

                            freq_counter[key]+=1

            except json.JSONDecodeError as e:
                print(f'Skipping invalid JSON line: {e}')

    return counter,freq_counter,unique_counter

# get internal fields for rewards receipt items
file_path = 'data/receipts.json'
counter,freq_counter,unique_counter = extract_unique_keys(file_path)

# Print results
print('Total items',counter)
print('Field | Unique | Total')
for i in freq_counter:
    print(i,len(unique_counter[i]),freq_counter[i])