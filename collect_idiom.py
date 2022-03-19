# 用以从新华字典的成语 JSON 中生成成语表

import ujson
import hashlib

words = []
hash_set = set()

with open("./assets/THUOCL_chengyu.txt", "r", encoding="utf-8") as ffp,\
        open("./assets/idiom.json", "r", encoding="utf-8") as ifp, \
        open("./assets/idioms.json", "w", encoding="utf-8") as ofp:

    key = set([key.split()[0].strip() for key in ffp])

    doc = ujson.load(ifp)

    for idiom in doc:
        word = idiom["word"]

        if len(word) != 4:
            continue

        if word not in key:
            continue

        word_hash = hashlib.sha1(word.encode()).hexdigest()[0:8]

        if word_hash in hash_set:
            raise RuntimeError("duplicate hash")
        else:
            hash_set.add(word_hash)

        words.append({
            "hash": word_hash,
            "word": word,
            "explanation": idiom["explanation"],
            "pinyin": idiom["pinyin"],
            "derivation": idiom["derivation"],
            "type": "idiom"
        })

    ujson.dump(words, ofp, ensure_ascii=False)
