#!/bin/sh

set -o errexit
set -o nounset

echo "Downloading corpus"
wget http://www.cl.ecei.tohoku.ac.jp/~shimaoka/corpus.zip
unzip corpus.zip
rm corpus.zip

echo "Downloading word embeddings..."
wget http://nlp.stanford.edu/data/glove.840B.300d.zip
unzip glove.840B.300d.zip
rm glove.840B.300d.zip
mv glove.840B.300d.txt resource/

echo "Preprocessing (creating ids for words, features, and labels)"

echo "OntoNotes convert to JSON..."
python converter.py corpus/OntoNotes/all.txt corpus/OntoNotes/all.json
python converter.py corpus/OntoNotes/train.txt corpus/OntoNotes/train.json
python converter.py corpus/OntoNotes/test.txt corpus/OntoNotes/test.json
python converter.py corpus/OntoNotes/dev.txt corpus/OntoNotes/dev.json

echo "Wiki convert to JSON..."
python converter.py corpus/Wiki/all.txt corpus/Wiki/all.json
python converter.py corpus/Wiki/train.txt corpus/Wiki/train.json
python converter.py corpus/Wiki/test.txt corpus/Wiki/test.json
python converter.py corpus/Wiki/dev.txt corpus/Wiki/dev.json

echo "OntoNotes"
mkdir ./resource/OntoNotes
python ./resource/create_X2id.py corpus/OntoNotes/all.json resource/OntoNotes/word2id_gillick.txt resource/OntoNotes/feature2id_gillick.txt resource/OntoNotes/label2id_gillick.txt

echo "Wiki"
mkdir ./resource/Wiki/
python ./resource/create_X2id.py corpus/Wiki/all.json resource/Wiki/word2id_figer.txt resource/Wiki/feature2id_figer.txt resource/Wiki/label2id_figer.txt

echo "Preprocessing (creating dictionaries)"
mkdir ./data

echo "OntoNotes"
mkdir ./data/OntoNotes
python create_dicts.py resource/OntoNotes/word2id_gillick.txt resource/OntoNotes/feature2id_gillick.txt  resource/OntoNotes/label2id_gillick.txt  resource/glove.840B.300d.txt data/OntoNotes/dicts_gillick.pkl

echo "Wiki"
mkdir ./data/Wiki
python create_dicts.py resource/Wiki/word2id_figer.txt resource/Wiki/feature2id_figer.txt resource/Wiki/label2id_figer.txt  resource/glove.840B.300d.txt data/Wiki/dicts_figer.pkl

echo "Preprocessing (creating datasets)"

echo "OntoNotes"
python create_dataset.py data/OntoNotes/dicts_gillick.pkl corpus/OntoNotes/train.json data/OntoNotes/train_gillick.pkl
python create_dataset.py data/OntoNotes/dicts_gillick.pkl corpus/OntoNotes/dev.json data/OntoNotes/dev_gillick.pkl
python create_dataset.py data/OntoNotes/dicts_gillick.pkl corpus/OntoNotes/test.json data/OntoNotes/test_gillick.pkl

echo "Wiki"
python create_dataset.py data/Wiki/dicts_figer.pkl corpus/Wiki/train.json data/Wiki/train_figer.pkl
python create_dataset.py data/Wiki/dicts_figer.pkl corpus/Wiki/dev.json data/Wiki/dev_figer.pkl
python create_dataset.py data/Wiki/dicts_figer.pkl corpus/Wiki/test.json data/Wiki/test_figer.pkl
