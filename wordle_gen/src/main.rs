mod model;

use crate::model::{Idiom, Problem};
use std::{
    collections::HashMap,
    fs::{self, File},
    io::BufWriter,
};
fn main() {
    let idioms = fs::read_to_string("../assets/idiom.json").unwrap();
    let idioms: Vec<Idiom> = serde_json::from_str(&idioms).unwrap();

    let idiom_freq = fs::read_to_string("../assets/THUOCL_chengyu.txt").unwrap();
    let idiom_freq: HashMap<String, i32> = idiom_freq
        .lines()
        .map(|line| {
            let pair: Vec<&str> = line.split_whitespace().collect();
            let key = pair[0].to_string();
            let value = pair[1].parse::<i32>().unwrap();

            (key, value)
        })
        .collect();

    let poem_freq = fs::read_to_string("../assets/THUOCL_poem.txt").unwrap();
    let poem_freq: HashMap<String, i32> = poem_freq
        .lines()
        .map(|line| {
            let pair: Vec<&str> = line.split_whitespace().collect();
            let key = pair[0].to_string();
            let value = pair[1].parse::<i32>().unwrap();

            (key, value)
        })
        .collect();

    let idioms: Vec<Problem> = idioms
        .into_iter()
        .map(|e| {
            let freq = idiom_freq.get(e.word.as_str()).cloned().unwrap_or(0);

            let difficulty = if freq > 100 { "easy" } else { "hard" }.to_string();

            Problem::new(
                e.word,
                e.pinyin,
                e.explanation,
                e.derivation,
                difficulty,
                freq,
            )
        })
        .collect();

    let mut poems: Vec<Problem> = poem_freq
        .into_iter()
        .map(|e| {
            let difficulty = if e.1 > 100 { "easy" } else { "hard" }.to_string();

            Problem::new(
                e.0,
                "".to_string(),
                "".to_string(),
                "".to_string(),
                difficulty,
                e.1,
            )
        })
        .collect();

    poems.extend(idioms);

    let mut problems = poems;

    let mut problem_similar: HashMap<String, Vec<(String, f64, i32)>> = HashMap::new();

    for i in 0..problems.len() {
        let (pa, pb) = problems.split_at_mut(i + 1);

        for j in 0..pb.len() {
            let a = &mut pa[i];
            let b = &pb[j];
            let sim = a.similarity(b);

            if sim > 0.0 {
                let t = (b.hash.clone(), sim, b.freq);

                if !problem_similar.contains_key(&a.hash) {
                    problem_similar.insert(a.hash.clone(), vec![t]);
                } else {
                    problem_similar.get_mut(&a.hash).unwrap().push(t);
                }
            }
        }
    }

    problems.as_mut_slice().into_iter().for_each(|e| {
        if let Some(mut v) = problem_similar.remove(&e.hash) {
            v.sort_by(|a, b| {
                if a.1 != b.1 {
                    a.1.partial_cmp(&b.1).unwrap()
                } else {
                    a.2.partial_cmp(&b.2).unwrap()
                }
            });

            e.similar = v.into_iter().map(|e| e.0).collect();
        }
    });

    let file = File::create("problem.json").unwrap();
    let writer = BufWriter::new(file);

    serde_json::to_writer(writer, &problems).unwrap();
}
