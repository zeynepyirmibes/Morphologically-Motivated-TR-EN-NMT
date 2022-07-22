# Training the bideep model (Turkish-English) with 2 left-to-right, 2 right-to-left models

# Left-to-right:

WORKSPACE=9500
N=2
B=12
EPOCHS=8

for i in $(seq 1 $N)
do
  mkdir -p bideep_model/ens$i
  ./marian/build/marian \
          --model bideep_model/ens$i/model.npz --type s2s \
          --train-sets data/corpus.mdnn.bpe.tr data/corpus.mdnn.bpe.en \
          --vocabs bideep_model/vocab.tren.yml bideep_model/vocab.tren.yml \
          --max-length 100 \
          --mini-batch-fit -w $WORKSPACE --mini-batch 1000 --maxi-batch 1000 \
          --valid-freq 5000 --save-freq 5000 --disp-freq 500 \
          --valid-metrics bleu perplexity \
          --valid-sets data/newstest2016.zb.final.mdnn.bpe.tr data/newstest2016.tc.zb.final.mdnn.bpe.en \
          --quiet-translation \
          --beam-size 12 --normalize=1 \
          --valid-mini-batch 64 \
          --overwrite --keep-best \
          --early-stopping 5 --after-epochs $EPOCHS --cost-type=ce-mean-words \
          --log bideep_model/ens$i/train.log --valid-log bideep_model/ens$i/valid.log \
          --enc-type alternating --enc-cell-depth 2 --enc-depth 4 \
          --dec-cell-base-depth 4 --dec-cell-high-depth 2 --dec-depth 4 \
          --layer-normalization --tied-embeddings-all --skip \
          --dropout-rnn 0.1 --label-smoothing 0.1 \
          --learn-rate 0.0003 --lr-decay-inv-sqrt 16000 --lr-report \
          --optimizer-params 0.9 0.98 1e-09 --clip-norm 5 \
          --devices 0 1 --sync-sgd --seed $i$i$i$i  \
          --exponential-smoothing
done 

# Right-to-left:

WORKSPACE=9500
N=2
B=12
EPOCHS=8

for i in $(seq 1 $N)
do
  mkdir -p bideep_model/ens-rtl$i
  ./marian/build/marian \
          --model bideep_model/ens-rtl$i/model.npz --type s2s \
          --train-sets data/corpus.mdnn.bpe.tr data/corpus.mdnn.bpe.en \
          --vocabs bideep_model/vocab.tren.yml bideep_model/vocab.tren.yml \
          --max-length 100 \
          --mini-batch-fit -w $WORKSPACE --mini-batch 1000 --maxi-batch 1000 \
          --valid-freq 5000 --save-freq 5000 --disp-freq 500 \
          --valid-metrics bleu perplexity \
          --valid-sets data/newstest2016.zb.final.mdnn.bpe.tr data/newstest2016.tc.zb.final.mdnn.bpe.en \
          --quiet-translation \
          --beam-size 12 --normalize=1 \
          --valid-mini-batch 64 \
          --overwrite --keep-best \
          --early-stopping 5 --after-epochs $EPOCHS --cost-type=ce-mean-words \
          --log bideep_model/ens-rtl$i/train.log --valid-log bideep_model/ens-rtl$i/valid.log \
          --enc-type alternating --enc-cell-depth 2 --enc-depth 4 \
          --dec-cell-base-depth 4 --dec-cell-high-depth 2 --dec-depth 4 \
          --layer-normalization --tied-embeddings-all --skip \
          --dropout-rnn 0.1 --label-smoothing 0.1 \
          --learn-rate 0.0003 --lr-decay-inv-sqrt 16000 --lr-report \
          --optimizer-params 0.9 0.98 1e-09 --clip-norm 5 \
          --devices 0 1 --sync-sgd --seed $i$i$i$i  \
          --exponential-smoothing --right-left
done 

# Ensemble translation:

WORKSPACE=9500
N=2
B=12
EPOCHS=8

for prefix in newstest2017 newstest2018
do
    cat data/$prefix.zb.final.mdnn.bpe.tr \
        | ./marian/build/marian-decoder -c bideep_model/ens1/model.npz.best-bleu.npz.decoder.yml \
          -m bideep_model/ens?/model.npz.best-bleu.npz --quiet-translation \
          --mini-batch 16 --maxi-batch 100 --maxi-batch-sort src -w 5000 --n-best --beam-size $B \
        > data/$prefix.zb.mdnn.bpe.en.output.nbest.0

    for i in $(seq 1 $N)
    do
      ./marian/build/marian-scorer -m bideep_model/ens-rtl$i/model.npz.best-bleu.npz \
        -v bideep_model/vocab.tren.yml bideep_model/vocab.tren.yml \
        --mini-batch 16 --maxi-batch 100 --maxi-batch-sort trg --n-best --n-best-feature R2L$(expr $i - 1) \
        -t data/$prefix.zb.final.mdnn.bpe.tr data/$prefix.zb.mdnn.bpe.en.output.nbest.$(expr $i - 1) > data/$prefix.zb.mdnn.bpe.en.output.nbest.$i
    done

    cat data/$prefix.zb.mdnn.bpe.en.output.nbest.$N \
      | python scripts/rescore.py \
      | perl -pe 's/@@ //g' \
      | moses-scripts/scripts/recaser/detruecase.perl \
      | moses-scripts/scripts/tokenizer/detokenizer.perl > data/$prefix.en.output
done

B=50

for prefix in newstest2017 newstest2018
do
    cat data/$prefix.zb.final.mdnn.bpe.tr \
        | ./marian/build/marian-decoder -c bideep_model/ens1/model.npz.best-bleu.npz.decoder.yml \
          -m bideep_model/ens?/model.npz.best-bleu.npz --quiet-translation \
          --mini-batch 16 --maxi-batch 100 --maxi-batch-sort src -w 5000 --n-best --beam-size $B \
        > data/$prefix.zb.mdnn.bpe.en.b50.output.nbest.0

    for i in $(seq 1 $N)
    do
      ./marian/build/marian-scorer -m bideep_model/ens-rtl$i/model.npz.best-bleu.npz \
        -v bideep_model/vocab.tren.yml bideep_model/vocab.tren.yml \
        --mini-batch 16 --maxi-batch 100 --maxi-batch-sort trg --n-best --n-best-feature R2L$(expr $i - 1) \
        -t data/$prefix.zb.final.mdnn.bpe.tr data/$prefix.zb.mdnn.bpe.en.b50.output.nbest.$(expr $i - 1) > data/$prefix.zb.mdnn.bpe.en.b50.output.nbest.$i
    done

    cat data/$prefix.zb.mdnn.bpe.en.b50.output.nbest.$N \
      | python scripts/rescore.py \
      | perl -pe 's/@@ //g' \
      | moses-scripts/scripts/recaser/detruecase.perl \
      | moses-scripts/scripts/tokenizer/detokenizer.perl > data/$prefix.en.b50.output
done


# Translate ensemble models separately: 

WORKSPACE=9500
N=2
B=12
EPOCHS=8

# translate test sets
for prefix in newstest2017 newstest2018
do

    for i in $(seq 1 $N)
    do
        cat data/$prefix.zb.final.mdnn.bpe.tr \
          | ./marian/build/marian-decoder -c bideep_model/ens$i/model.npz.best-bleu.npz.decoder.yml \
            -m bideep_model/ens$i/model.npz.best-bleu.npz --quiet-translation \
            --mini-batch 16 --maxi-batch 100 --maxi-batch-sort src -w 5000 --beam-size $B \
          | sed 's/\@\@ //g' \
          | moses-scripts/scripts/recaser/detruecase.perl \
          | moses-scripts/scripts/tokenizer/detokenizer.perl -l en \
          > data/$prefix.en.ens$i.output
    done
    
    for i in $(seq 1 $N)
    do
        cat data/$prefix.zb.final.mdnn.bpe.tr \
          | ./marian/build/marian-decoder -c bideep_model/ens-rtl$i/model.npz.best-bleu.npz.decoder.yml \
            -m bideep_model/ens-rtl$i/model.npz.best-bleu.npz --quiet-translation \
            --mini-batch 16 --maxi-batch 100 --maxi-batch-sort src -w 5000 --beam-size $B \
          | sed 's/\@\@ //g' \
          | moses-scripts/scripts/recaser/detruecase.perl \
          | moses-scripts/scripts/tokenizer/detokenizer.perl -l en \
          > data/$prefix.en.ens-rtl$i.output
    done
done

for i in $(seq 1 $N)
do

  echo "newstest2018.en.ens$i.output 2018 evaluating....."

  perl moses-scripts/wrap-xml.perl en data/test/newstest2018-tren-src.tr.sgm Zep < data/newstest2018.en.ens$i.output > data/newstest2018.en.ens$i.output.sgm
  perl moses-scripts/scripts/generic/mteval-v14.pl -r data/test/newstest2018-tren-ref.en.sgm -s data/test/newstest2018-tren-src.tr.sgm -t data/newstest2018.en.ens$i.output.sgm

  moses-scripts/scripts/generic/multi-bleu-detok.perl data/test/newstest2018.en < data/newstest2018.en.ens$i.output
    
done

for i in $(seq 1 $N)
do

  echo "newstest2018.en.ens-rtl$i.output 2018 evaluating....."

  perl moses-scripts/wrap-xml.perl en data/test/newstest2018-tren-src.tr.sgm Zep < data/newstest2018.en.ens-rtl$i.output > data/newstest2018.en.ens-rtl$i.output.sgm
  perl moses-scripts/scripts/generic/mteval-v14.pl -r data/test/newstest2018-tren-ref.en.sgm -s data/test/newstest2018-tren-src.tr.sgm -t data/newstest2018.en.ens-rtl$i.output.sgm

  moses-scripts/scripts/generic/multi-bleu-detok.perl data/test/newstest2018.en < data/newstest2018.en.ens-rtl$i.output
    
done

for i in $(seq 1 $N)
do

  echo "newstest2017.en.ens$i.output 2017 evaluating....."

  perl moses-scripts/wrap-xml.perl en data/test/newstest2017-tren-src.tr.sgm Zep < data/newstest2017.en.ens$i.output > data/newstest2017.en.ens$i.output.sgm
  perl moses-scripts/scripts/generic/mteval-v14.pl -r data/test/newstest2017-tren-ref.en.sgm -s data/test/newstest2017-tren-src.tr.sgm -t data/newstest2017.en.ens$i.output.sgm

  moses-scripts/scripts/generic/multi-bleu-detok.perl data/test/newstest2017.en < data/newstest2017.en.ens$i.output
    
done

for i in $(seq 1 $N)
do

  echo "newstest2017.en.ens-rtl$i.output 2017 evaluating....."

  perl moses-scripts/wrap-xml.perl en data/test/newstest2017-tren-src.tr.sgm Zep < data/newstest2017.en.ens-rtl$i.output > data/newstest2017.en.ens-rtl$i.output.sgm
  perl moses-scripts/scripts/generic/mteval-v14.pl -r data/test/newstest2017-tren-ref.en.sgm -s data/test/newstest2017-tren-src.tr.sgm -t data/newstest2017.en.ens-rtl$i.output.sgm

  moses-scripts/scripts/generic/multi-bleu-detok.perl data/test/newstest2017.en < data/newstest2017.en.ens-rtl$i.output
  
done