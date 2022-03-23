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
    pub freq: i32,
    #[serde(skip_serializing, skip_deserializing)]
    pub prop: Counter<char>,
    pub similar: Vec<String>,
}

impl Problem {
    pub fn new(
        word: String,
        pinyin: String,
        explanation: String,
        derivation: String,
        difficulty: String,
        freq: i32,
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
        }
    }

    pub fn similarity(&self, other: &Self) -> f64 {
        let diff = self.prop.clone() - other.prop.clone();
        let len = self.word.len() as f64;
        let p = diff.iter().map(|e| e.1).sum::<usize>() as f64;

        return 1.0 - p / len;
    }
}
