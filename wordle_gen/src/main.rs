#![feature(slice_group_by)]

use counter::Counter;
use std::{
    collections::{HashMap, HashSet},
    fs::{self, File},
    io::BufWriter,
};

use crate::model::{Idiom, Problem};

mod model;

fn main() {
    let mut idioms = {
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

        idioms
            .into_iter()
            .map(|e| {
                let freq = idiom_freq.get(e.word.as_str()).cloned().unwrap_or(0);

                let difficulty = if freq > 50 { "easy" } else { "hard" }.to_string();

                Problem::new(
                    e.word,
                    e.pinyin,
                    e.explanation,
                    e.derivation,
                    difficulty,
                    freq,
                    "idiom".to_string(),
                )
            })
            .filter(|e| e.word.chars().count() == 4)
            .collect()
    };

    let mut poems: Vec<Problem> = {
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

        poem_freq
            .into_iter()
            .map(|e| {
                let difficulty = if e.1 > 10 { "easy" } else { "hard" }.to_string();

                Problem::new(
                    e.0,
                    "".to_string(),
                    "".to_string(),
                    "".to_string(),
                    difficulty,
                    e.1,
                    "poem".to_string(),
                )
            })
            .collect()
    };

    {
        let map = calculate_similarity(&mut idioms);
        fill_similarity(&mut idioms, map);
    }

    {
        let map = calculate_similarity(&mut poems);

        fill_similarity(&mut poems, map);
    }

    let file = File::create("problems.json").unwrap();
    let writer = BufWriter::new(file);

    idioms.extend(poems);

    let problems: Vec<Problem> = {
        // let problems: Vec<Problem> = idioms.into_iter().filter(|e| e.similar.len() > 0).collect();

        let problems = idioms;

        let problem_set: HashSet<String> = problems
            .as_slice()
            .into_iter()
            .map(|e| e.hash.to_string())
            .collect();

        problems
            .into_iter()
            .map(|mut e| {
                e.similar = e
                    .similar
                    .into_iter()
                    .filter(|s| problem_set.contains(s.as_str()))
                    .collect();

                e
            })
            .collect()
    };

    {
        let count = problems
            .as_slice()
            .into_iter()
            .map(|e| (e.r#type.as_str(), e.difficulty.as_str()));
        let counter: Counter<(_, _), usize> = Counter::from_iter(count);

        println!("{:?}", counter);
    }

    serde_json::to_writer(writer, &problems).unwrap();
}

fn fill_similarity(
    problems: &mut Vec<Problem>,
    mut problem_similar: HashMap<String, Vec<(String, f64, i32)>>,
) {
    problems.as_mut_slice().into_iter().for_each(|e| {
        if let Some(mut v) = problem_similar.remove(&e.hash) {
            v.sort_by(|a, b| {
                if a.1 != b.1 {
                    a.1.partial_cmp(&b.1).unwrap().reverse()
                } else {
                    a.2.partial_cmp(&b.2).unwrap().reverse()
                }
            });

            e.similar = v.into_iter().map(|e| e.0).collect();
        }
    });
}

fn calculate_similarity(problems: &mut Vec<Problem>) -> HashMap<String, Vec<(String, f64, i32)>> {
    let mut problem_similar: HashMap<String, Vec<(String, f64, i32)>> = HashMap::new();

    for i in 0..problems.len() {
        let (pa, pb) = problems.split_at_mut(i + 1);

        for j in 0..pb.len() {
            let a = &mut pa[i];
            let b = &pb[j];
            let sim = a.similarity(b);

            if sim > 0.25 {
                let t = (b.hash.clone(), sim, b.freq);

                if !problem_similar.contains_key(&a.hash) {
                    problem_similar.insert(a.hash.clone(), vec![t]);
                } else {
                    problem_similar.get_mut(&a.hash).unwrap().push(t);
                }
            }
        }
    }
    problem_similar
}
