#include "types.h"

void (*__KERNEL__CTOR__LIST__)(void);
void (*__KERNEL__CTOR__END__)(void);
void (*__KERNEL__DTOR__LIST__)(void);
void (*__KERNEL__DTOR__END__)(void);
extern "C" int kernelEntry(MULTIBOOT *pmultiboot);
extern "C" void init();
extern "C" void fini();
extern "C" void stop();
void *__dso_handle = 0;

extern "C" void _start(MULTIBOOT *pmultiboot) {
    init();
    kernelEntry(pmultiboot);
    fini();
    return;
}

extern "C" void init() {
    int **pf;
    pf = (int**)&__KERNEL__CTOR__LIST__;
    for (int i = 0; (int**)&pf[i] != (int**)&__KERNEL__CTOR__END__; i++) {
        ((void(*)(void))&pf[i])();
    }
    return;
}

extern "C" void fini() {
    int **pf;
    pf = (int**)&__KERNEL__DTOR__LIST__;
    for (int i = 0; (int**)&pf[i] != (int**)&__KERNEL__DTOR__END__; i++) {
        ((void(*)(void))pf[i])();
    }
    return;
}

extern "C" void __cxa_pure_virtual() {
    stop();
}

extern "C" void _ZdlPvm() {
    return;
}

extern "C" void _ZdlPvj() {
    return;
}
