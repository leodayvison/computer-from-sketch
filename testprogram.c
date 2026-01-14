#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char* caesarEncryptAux(char* plain, int shift){
    size_t len = strlen(plain);
    char* out = malloc(len+1);
    int base = 32;
    int range = 95;

    for(int i=0; i<len; i++){
        unsigned char c = plain[i];
        
        if(c >= 32 && c <= 126){
            char temp = (base+(((c-base+shift)%range + range) % range));
            out[i] = temp;
        }
        else{
            out[i] = c;
        }
    }
    out[len] = '\0';
    return out;
}

int main(){
    char* str = "ab";
    char* res = caesarEncryptAux(str, 3);
    printf("%s", res);
    free(res);
}