# looking for fields in previously obtained nested dictionaries
import json

def extract_keys(file_path,outer_field):
    freq_counter = {}
    counter = 0
    with open(file_path, 'r', encoding='utf-8') as f:
        for line in f:
            try:
                row = json.loads(line.strip())  # parsing each line as JSON
                if outer_field in row: # looking for outer field
                    counter += 1
                    for key in row[outer_field]:  # iterate through the keyname field (for instance _id)
                        if key in freq_counter:
                            freq_counter[key]+=1
                        else:
                            freq_counter[key]=1

            except json.JSONDecodeError as e:
                print(f'Skipping invalid JSON line: {e}')

    return counter,freq_counter

# file path and field to explore
file_path = 'data/receipts.json'
outer_field = 'createDate'

counter,freq_counter = extract_keys(file_path,outer_field)
print('Fields in',outer_field)
print('Field | Occurences')
for i in freq_counter:
    print(i,freq_counter[i])