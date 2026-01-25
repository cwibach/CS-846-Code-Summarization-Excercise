# README #

This java code belonged to a Search Engine program that used (primarily) the BM25 algorithm to retrieve documents for the user through a command line interface

The program first required the dataset to read in so it could construct necessary back end data structures (IndexEngine.java), then it could be used with queries from the user

It was built in stages, so began with only the data structures, then the algorithm, then evaluation metrics, then the command line interface, then doc snippets in search

Some files removed for Parameter sweeping, measuring memory usage based on data structures, and PorterStemmer as was official code, not creator's own.