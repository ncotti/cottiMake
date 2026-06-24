#include "ext1.h"
#include "ext2.h"
#include <stdio.h>

int main(void) {
    int a = 0;
    a = ext1_add3(a);
    a = ext1_add4(a);
    a = ext1_add7(a);
    a = ext2_add5(a);

    // Expected value is 19
    printf("Running consumer project. Value is: %d\n", a);
    return 0;
}