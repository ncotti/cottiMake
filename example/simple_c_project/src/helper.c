#include "helper.h"
#include "add.h"
#include "sub.h"

int helper_return_two(void)
{
    int a = 0;
    a = add1(a);
    a = add1(a);
    a = add1(a);
    a = sub1(a);
    return a;
}