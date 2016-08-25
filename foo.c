#include "foo.h"

#include <stdio.h>

#define str(x) #x

#define str_prescan(x) str(x)

void FOO_FUNC()
{
	printf("I was created in directory %s\n",str_prescan(CURDIR));
}
