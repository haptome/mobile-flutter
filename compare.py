import re

def parse_keys(filepath):
    keys = {}
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Simple regex to find keys and values like 'key': 'value',
    matches = re.findall(r"'([^']+)':\s*'([^']*)',", content)
    for k, v in matches:
        keys[k] = v
        
    matches2 = re.findall(r'"([^"]+)":\s*"([^"]*)",', content)
    for k, v in matches2:
        keys[k] = v
        
    return keys

en_keys = parse_keys('lib/translations/en_us.dart')
am_keys = parse_keys('lib/translations/am_et.dart')

missing = []
empty = []

for k in en_keys:
    if k not in am_keys:
        missing.append(k)
    elif am_keys[k].strip() == '':
        empty.append(k)

print(f"Total English keys: {len(en_keys)}")
print(f"Total Amharic keys: {len(am_keys)}")
print(f"Missing keys: {len(missing)}")
print(f"Empty keys: {len(empty)}")

if len(missing) > 0 or len(empty) > 0:
    print("\nMissing/Empty Keys and their English values:")
    for k in missing:
        print(f"MISSING - '{k}': '{en_keys[k]}'")
    for k in empty:
        print(f"EMPTY   - '{k}': '{en_keys[k]}'")

