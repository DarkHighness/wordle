# 用以从新华字典的成语 JSON 中生成成语表及映射关系表

import ujson
import hashlib

words = []
ch_2_words = {}
hash_set = set()

with open("./assets/idiom.json", "r", encoding="utf-8") as f, \
        open("./assets/words.json", "w", encoding="utf-8") as wf, \
        open("./assets/map.json", "w", encoding="utf-8") as mf:
    doc = ujson.load(f)

    for idiom in doc:
        word = idiom["word"]

        if len(word) != 4:
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
            "derivation": idiom["derivation"]
        })

        for ch in word:
            if ch not in ch_2_words:
                ch_2_words[ch] = []

            ch_2_words[ch].append(word)

    ujson.dump(words, wf, ensure_ascii=False)
    ujson.dump(ch_2_words, mf, ensure_ascii=False, sort_keys=True)
