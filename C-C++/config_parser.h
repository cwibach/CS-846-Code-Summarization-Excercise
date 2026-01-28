// config_parser.h
#ifndef CONFIG_PARSER_H
#define CONFIG_PARSER_H

#include <stdbool.h>

typedef struct Config Config;

typedef enum {
    CONFIG_OK = 0,
    CONFIG_ERR_FILE_NOT_FOUND,
    CONFIG_ERR_PARSE_ERROR,
    CONFIG_ERR_OUT_OF_MEMORY,
    CONFIG_ERR_KEY_NOT_FOUND,
    CONFIG_ERR_INVALID_TYPE
} ConfigError;

// TODO: Document this function
Config* config_load(const char* filepath, ConfigError* err);

// TODO: Document this function
Config* config_load_string(const char* content, ConfigError* err);

// TODO: Document this function
void config_free(Config* cfg);

// TODO: Document this function
const char* config_get_string(const Config* cfg, const char* section,
                              const char* key, const char* default_val);

// TODO: Document this function
int config_get_int(const Config* cfg, const char* section,
                   const char* key, int default_val);

// TODO: Document this function
double config_get_double(const Config* cfg, const char* section,
                         const char* key, double default_val);

// TODO: Document this function
bool config_get_bool(const Config* cfg, const char* section,
                     const char* key, bool default_val);

// TODO: Document this function
bool config_has_key(const Config* cfg, const char* section, const char* key);

// TODO: Document this function
bool config_has_section(const Config* cfg, const char* section);

// TODO: Document this function
const char* config_error_string(ConfigError err);

#endif
