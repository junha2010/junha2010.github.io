import json
import requests

path = 'data/verses.json'

# Load existing data
with open(path, 'r', encoding='utf-8') as f:
    data = json.load(f)

# Fetch Genesis 2
print("Fetching Genesis 2 from bible-api.com...")
url = 'https://bible-api.com/genesis+2?translation=niv'
r = requests.get(url)

if r.status_code != 200:
    print(f'Error: API returned status {r.status_code}')
    exit(1)

response_data = r.json()
verses = [v['text'].strip() for v in response_data.get('verses', [])]

print(f'Fetched {len(verses)} verses for Genesis 2')

# Add Genesis 2 to data
data['Genesis']['2'] = verses

# Save updated data
with open(path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print('Genesis 2 successfully added to verses.json')
print(f'First verse: {verses[0][:60]}...')
print(f'Last verse: {verses[-1][:60]}...')
