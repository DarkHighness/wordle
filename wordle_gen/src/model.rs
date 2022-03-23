use std::cmp::min;

use counter::Counter;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};

#[derive(Serialize, Deserialize, Debug)]
pub struct Idiom {
    pub derivation: String,
    pub example: String,
    pub explanation: String,
    pub pinyin: String,
    pub word: String,
    pub abbreviation: String,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Problem {
    pub derivation: String,
    pub explanation: String,
    pub pinyin: String,
    pub word: String,
    pub hash: String,
    pub difficulty: String,
    #[serde(skip_serializing, skip_deserializing)]
    pub freq: i32,
    #[serde(skip_serializing, skip_deserializing)]
    pub prop: Counter<char>,
    pub similar: Vec<String>,
    pub r#type: String,
}

impl Problem {
    pub fn new(
        word: String,
        pinyin: String,
        explanation: String,
        derivation: String,
        difficulty: String,
        freq: i32,
        r#type: String,
    ) -> Self {
        let mut sha256 = Sha256::new();

        sha256.update(word.as_bytes());

        let result = format!("{:X}", sha256.finalize());

        let hash = String::from_iter(result.chars().skip(8).take(8));
        let counter = word.chars().collect::<Counter<_>>();

        Problem {
            derivation,
            explanation,
            pinyin,
            word,
            hash,
            difficulty,
            freq,
            prop: counter,
            similar: Vec::new(),
            r#type
        }
    }

    pub fn similarity(&self, other: &Self) -> f64 {
        let mut h = 0;

        self.prop.iter().for_each(|e| {
            let p = other.prop.get(e.0).map_or_else(|| 0, |e| *e);

            h += min(p, *e.1);
        });

        let h = h as f64;
        let len = self.word.chars().count() as f64;

        return h / len;
    }
}
