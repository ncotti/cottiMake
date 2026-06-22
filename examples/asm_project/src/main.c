#include "main.h"

int main(void) {
    int a = 10;
    a++;
    a++;
    a = a;  // This line is used for reference in the gdb script
    return 0;
}
