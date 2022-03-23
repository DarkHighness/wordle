import functools

import ujson
import hashlib
import collections

idiom_freq = {}
poem_freq = {}

idiom_map = {}
poem_map = {}

hash_list = set()


with open("./assets/THUOCL_poem.txt", "r", encoding="utf-8") as f:
    for line in f:
        line = line.strip().split()
        key = line[0].strip()
        freq = int(line[1].strip())

        poem_freq[key] = freq

        word_hash = hashlib.sha1(key.encode()).hexdigest()[0:8]

        if word_hash in hash_list:
            raise RuntimeError(f"duplicate hash {word_hash}")

        hash_list.add(word_hash)

        poem_map[key] = {
            "hash": word_hash,
            "word": key,
            "explanation": "",
            "pinyin": "",
            "derivation": "",
            "type": "poem",
            "difficulty": "easy" if freq > 10 else "hard",
            "freq": freq,
            "similar": []
        }

with open("./assets/THUOCL_chengyu.txt", "r", encoding="utf-8") as f:
    for line in f:
        line = line.strip().split()
        key = line[0].strip()
        freq = line[1].strip()

        idiom_freq[key] = int(freq)

with open("./assets/idiom.json", "r", encoding="utf-8") as f:
    doc = ujson.load(f)

    for entry in doc:
        word = entry["word"].strip()

        if len(word) != 4:
            continue

        freq = 0 if word not in idiom_freq else idiom_freq[word]

        word_hash = hashlib.sha1(word.encode()).hexdigest()[0:8]

        idiom_map[word] = {
            "hash": word_hash,
            "word": word,
            "explanation": entry["explanation"],
            "pinyin": entry["pinyin"],
            "derivation": entry["derivation"],
            "type": "idiom",
            "difficulty": "easy" if freq > 100 else "hard",
            "freq": freq,
            "similar": [],
            "counter": collections.Counter(word)
        }

idioms = [key for key in idiom_map.keys()]

for a in idioms:
    for b in idioms:
        sim = (len(a) - sum((idiom_map[a]["counter"] - idiom_map[b]["counter"]).values())) / len(a)

        if sim > 0.0:
            idiom_map[a]["similar"].append((b, sim))


def sort_similar_items(a: (str, float), b: (str, float)):
    if a[1] != b[1]:
        return a[1] - b[1]
    else:
        return idiom_freq[a[0]] - idiom_freq[b[1]]


for idiom in idioms:
    similar = sorted(idiom_map[idiom]["similar"], key=functools.cmp_to_key(sort_similar_items),
                     reverse=True)

    idiom_map[idiom]["similar"] = [item[0] for item in similar]
