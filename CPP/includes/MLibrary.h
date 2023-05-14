//
// Created by merhab on 2023/5/14.
//

#pragma once
#include <stdlib.h>
#include <assert.h>

void mnassert(void *ptr) {
    assert(ptr);
}

void *mnalloc(size_t size) {
    void *ret = malloc(size);
    mnassert(ret);
    return ret;
}

void mnfree(void *ptr) {
    free(ptr);
}

size_t cstring_count(const char *str) {
    if (!str) {
        return 0;
    }
    size_t j;
    j = 0;
    for (;;) {
        if (str[j] == '\0') {
            break;
        }
        j++;
    }
    return j;
}

size_t cstring_size(const char *str) {
    return cstring_count(str) + 1;
}

char cstring_is_equal(const char *str1, const char *str2)
{
    size_t count1= cstring_count(str1);
    size_t count2= cstring_count(str2);
    if (count1!=count2){
        return 0;
    }
    for (int i=0;i<count1 ;i++ ) {
        if(str1[i]!=str2[i]){
            return 0;
        }
    }
    return 1;
}
char *cstring_new_clone(const char *str) {
    if (!str) {
        return 0;
    }
    size_t size = cstring_size(str);
    char *str2 = (char *) malloc(sizeof(char) * size);
    assert(str2);
    for (int i = 0; str[i] != 0; i++) {
        str2[i] = str[i];

    }
    str2[size - 1] = 0;
    return str2;
}

