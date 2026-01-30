## PYTHON ##

For each page, provide a detailed explanation of the functions it contains and how those functions are invoked. The interfaces should be categorized, and a dependency list should be produced.


### Task 1 ###
Criteria:
- Organize the file summaries in a systematic and coherent manner rather than listing each file’s functionality in isolation.
- Describe the inputs and outputs, and provide an overall summary of the module’s functionality.

Good Example (with guidelines):

- Purpose: implementations and experiments for document retrieval using classical IR baselines and pretrained language models (PLMs), plus tools for dataset generation, labeling and evaluation.

Bad Example (without guidelines):

    % Basic.py — core utilities and small abstractions used across the PLM code (common constants, simple helper classes, possibly a base Trainer or config loader).

    % distributed.py — distributed training entrypoint. Parses CLI options, initializes torch.distributed, builds model/dataset/dataloaders, runs the training loop and checkpointing across multiple GPUs/nodes.

    % MuserDataset.py — dataset loader: reads input files, preprocesses examples, tokenizes texts, implements __len__ / __getitem__ for PyTorch DataLoader.

    % MuserFormatter.py — batching and collation logic: converts raw dataset items into model-ready tensors (attention masks, token ids, labels), handles padding and any special input formatting used by the PLM.

    % MuserPLM.py — model wrapper around a pretrained language model: loads the backbone (via transformers), defines forward pass, scoring/loss computation, and any task-specific heads or pooling.

    % test.py — evaluation / inference script: loads a checkpoint, runs model inference on validation/test splits, produces retrieval scores and invokes metric computations (e.g., MAP, nDCG) or exports results.

    % train.sh — example shell launcher that prepares options and calls python -m torch.distributed.launch to run distributed.py with multi-GPU settings and output/checkpoint path.

    % utils.py — misc utilities: logging, seed setting, checkpoint save/load, metric helpers, and small I/O helpers used by training and evaluation.





### Task 2 ###
Criteria:
- Specify the entry file and explain its role in the system.
- Classify all files appropriately and clearly identify their inputs and outputs.
- Provide a dependency list. 


Good Example (with guidelines):

- Purpose: implementations and experiments for document retrieval using classical IR baselines and pretrained language models (PLMs), plus tools for dataset generation, labeling and evaluation.

- Classic baselines:
  - solve_tfidf.py — TF–IDF retrieval pipeline.
  - solve_bm25.py — BM25 retrieval pipeline.
  - lmir.py / solve_lmir.py — language-model-based IR (LMIR) implementation and solver.

- Data preparation & labels:
  - gen_corpus.py — corpus generation / preprocessing.
  - solve_labels.py — create or apply relevance labels for training/eval.

- Evaluation:
  - metrics.py — retrieval metrics (e.g., precision/recall, MAP, nDCG).

- PLM-based retrieval:
  - plm_retrieval contains dataset, model and training utilities:
    - `MuserDataset.py`, `MuserFormatter.py` — dataset loading and batching/formatting for PLMs.
    - `MuserPLM.py` — model wrapper / forward logic for the PLM retrieval model.
    - `Basic.py`, `utils.py` — helper utilities.
    - `distributed.py` — distributed training entry point using PyTorch.
    - `test.py` — evaluation/inference for the PLM model.
    - `train.sh` — example shell launcher that runs `distributed.py` with `torch.distributed.launch` and writes checkpoints to an output path.

- Outputs: retrieval results, evaluation reports, and model checkpoints (e.g., `checkpoints_more/` in the training script).
- Brief dependency list (recommended)
Python: 3.8+
Core numeric / utils: numpy, pandas, scipy, tqdm
ML / DL:
torch (PyTorch) — required for model training and torch.distributed
transformers — PLM models & tokenizers
tokenizers (optional, if used separately)
Retrieval / IR:
scikit-learn (TF–IDF, metrics helpers)
gensim or rank_bm25 (BM25 / classical IR utilities) — at least one
faiss (optional, for ANN indexing / large-scale retrieval)
Text processing / NLP: nltk or jieba (depending on language), sentencepiece (if model requires)
Evaluation / tooling:
pytrec_eval (optional, for standard IR metrics)
Dev / distributed extras (optional but common):
accelerate or apex (optional optimization/FP16)
NCCL, CUDA drivers (for multi-GPU training)



Bad Example (without guidelines):

    % Implementations and experiments for document retrieval using classical IR baselines and pretrained language models (PLMs), plus tools for dataset generation, labeling and evaluation.
