#include "main.h"
#include "helper.h"
#include "add.h"
#include <stdio.h>

int main(void) {

    int a = helper_return_two();
    a = add1(a);

    printf("a: %d\n", a);

    return 0;
}