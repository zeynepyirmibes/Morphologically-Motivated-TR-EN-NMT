# Morphologically Motivated Input Variations and Data Augmentation in Turkish-English Neural Machine Translation

This repository contains scripts to segment Turkish text into morphologically motivated subwords and training scripts for Turkish-English neural machine translation with the Marian toolkit. 

For the installation of the Marian toolkit, visit [their website](https://marian-nmt.github.io). For evaluation and pre-processing (truecasing, cleaning, etc.) Moses scripts have been used. 

See the article [Morphologically Motivated Input Variations and Data Augmentation in Turkish-English Neural Machine Translation](https://dl.acm.org/doi/10.1145/3571073) for details. 

## Morphologically motivated input variations

- [Morphemes](segmentation/morphemes)
- Allomorphs
- Morphological tags
- Multi-source

## NMT scripts: 

Training set is a combination of the SETimes corpus, and augmented monolingual data (WMT News Crawl). The WMT 16 test set has been used as validation, and WMT17 and WMT18 test sets have been used for testing. 

- [Deep transition](train/deep_transition.sh)
- [Bideep](train/bideep.sh)
- [Transformer](train/transformer.sh)

## Citation: 

If you use the segmentation or training scripts, please cite the paper: 

```
@article{10.1145/3571073,
author = {Yirmibe\c{s}o\u{g}lu, Zeynep and G\"{u}ng\"{o}r, Tunga},
title = {Morphologically Motivated Input Variations and Data Augmentation in Turkish-English Neural Machine Translation},
year = {2022},
publisher = {Association for Computing Machinery},
address = {New York, NY, USA},
issn = {2375-4699},
url = {https://doi.org/10.1145/3571073},
doi = {10.1145/3571073},
note = {Just Accepted},
journal = {ACM Trans. Asian Low-Resour. Lang. Inf. Process.},
month = {nov},
keywords = {attention, low-resource, neural machine translation, transformer, data augmentation, encoder-decoder, morphology, word segmentation}
}
```
