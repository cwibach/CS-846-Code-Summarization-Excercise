# Week 5 Evaluation: Code Summarization / Comprehension (Matlab)

**Authors:** Basit Ali, Yiran Hu, Carter Ibach

---


For each page, provide a detailed explanation of the functions it contains and how those functions are invoked. The interfaces should be categorized, and a dependency list should be produced.


### Task 1 ###
Criteria:
- Organize the file summaries in a systematic and coherent manner rather than listing each file’s functionality in isolation.
- Describe the inputs and outputs, and provide an overall summary of the module’s functionality.

Good Example (with guidelines):

- The plm_retrieval package implements a PLM-based retrieval pipeline: data loading & batching, a pretrained-language-model wrapper for scoring, utilities for training/checkpointing, a distributed training entrypoint, and evaluation/inference scripts. Inputs are dataset files (text, query-document pairs, labels) and PLM checkpoints; outputs are trained model checkpoints, retrieval scores, and evaluation metrics.
- Core utilities
  - utils.py
Inputs: runtime args, model objects, optimizer, dataloaders, file paths, random seeds.
Outputs: saved checkpoints, log messages, helper return values (metrics, paths).
Responsibility: generic helpers (logging, checkpoint save/load, seed setting, small I/O and metric wrappers) used across training and evaluation.
  - Basic.py
Inputs: configuration values/constants, possibly simple objects passed by other modules.
Outputs: shared constants, small helper classes/structs.
Responsibility: lightweight shared abstractions and constants to avoid duplication.
- Data & preprocessing
  - MuserDataset.py
Inputs: dataset files (json/csv/txt), tokenizer or tokenization config, dataset split flags.
Outputs: items for indexing by PyTorch DataLoader (raw/tokenized examples, labels, metadata).
Responsibility: read/parse raw data, convert to example objects, handle indexing and dataset-level preprocessing.
  - MuserFormatter.py
Inputs: batch of raw/tokenized examples from MuserDataset, tokenizer/pad settings.
Outputs: batched tensors (input ids, attention masks, token type ids, label tensors) and any required masks/indices.
Responsibility: collate function / batch formatting, padding, packing multiple inputs into model-ready tensors.
Model
  - MuserPLM.py
Inputs: pretrained model id/path (e.g., HuggingFace name), tokenized input tensors from formatter, training/eval flags.
Outputs: logits/scores, loss tensor (during training), pooled embeddings (if used), model state for saving.
Responsibility: load PLM backbone, implement forward pass, compute losses and scoring logic specific to retrieval task (pairwise/listwise/scoring head), expose save/load hooks.
- Training & distributed runtime
  - distributed.py
Inputs: CLI args (model path, batch size, learning rate, epochs, GPU list, main_rank, workers, output path), environment for torch.distributed.
Outputs: trained model checkpoints in output_path, training logs, optional progress/metrics per epoch.
Responsibility: parse args, initialize distributed process group, build model/dataset/dataloaders/optimizer/scheduler, run training loop with gradient sync, evaluate and checkpoint.
  - train.sh
Inputs: environment variables / hard-coded settings inside script (WORKING_DIR, GPUS_PER_NODE, MODEL_PATH, BATCH_SIZE, LR, EPOCHS, OUTPUT_PATH).
Outputs: launches distributed.py via python -m torch.distributed.launch which produces checkpoints and logs.
Responsibility: example launcher that composes CLI options and starts multi-GPU distributed training.
Evaluation & inference
  - test.py
Inputs: trained checkpoint path, test/validation data files, tokenizer/model config, evaluation options.
Outputs: retrieval scores for queries, evaluation metrics (MAP, nDCG, precision/recall), and result files (ranked lists).
Responsibility: load checkpoint, run model in inference mode over dataset, compute and export metrics and ranked results.
- How the pieces interact (high level flow)
Data files -> MuserDataset -> batches via MuserFormatter -> fed to MuserPLM.
distributed.py wires dataset + model + optimizer, runs training, uses utils/Basic for checkpointing/logging.
After training, test.py loads checkpoints and produces retrieval output and metrics.
train.sh is a convenience script to launch the distributed training flow.

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
