import json
with open('data/verses.json', 'r', encoding='utf-8') as f:
    d = json.load(f)
chapters = sorted(d['Genesis'].keys(), key=int)
print('Genesis chapters', chapters[0], '...', chapters[-1], 'count', len(chapters))
