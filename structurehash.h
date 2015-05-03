#ifndef HASHTBL_H_INCLUDE_GUARD
#define HASHTBL_H_INCLUDE_GUARD

#include<stdlib.h>
typedef size_t hash_size;
struct hashnode_s {
    char *key;
    void *type;
    void *declaration;
    struct hashnode_s *next;
};

typedef struct hashtbl {
    hash_size size;
    struct hashnode_s **nodes;
    hash_size (*hashfunc)(const char *);
} HASHTBL;


#endif
