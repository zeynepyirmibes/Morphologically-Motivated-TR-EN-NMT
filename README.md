# Morphologically Motivated Input Variations and Data Augmentation in Turkish-English Neural Machine Translation

This repository contains scripts to segment Turkish text into morphologically motivated subwords and training scripts for Turkish-English neural machine translation with the Marian toolkit. 

For the installation of the Marian toolkit, visit [their website](https://marian-nmt.github.io). For evaluation and pre-processing (truecasing, cleaning, etc.) Moses scripts have been used. 

## Morphologically motivated input variations

- Morphemes
- Allomorphs
- Morphological tags
- Multi-source

## NMT scripts: 

Training set is a combination of the SETimes corpus, and augmented monolingual data (WMT News Crawl). The WMT 16 test set has been used as validation, and WMT17 and WMT18 test sets have been used for testing. 

- [Deep transition](train/deep_transition.sh)
- [Bideep](train/bideep.sh)
- [Transformer](train/transformer.sh)


