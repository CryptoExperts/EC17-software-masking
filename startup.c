#include <stdint.h>
#include <stdio.h>

extern int main(void);
extern uint32_t _stack_top;
extern uint32_t _sdata, _edata;
extern uint32_t _sbss,  _ebss;
extern uint32_t _sidata;

extern void initialise_monitor_handles(void);  /* rdimon */

void Reset_Handler(void) {
    /* Copier .data de FLASH vers RAM */
    uint32_t *src = &_sidata;
    uint32_t *dst = &_sdata;
    while (dst < &_edata) *dst++ = *src++;

    dst = &_sbss;
    while (dst < &_ebss) *dst++ = 0;


    initialise_monitor_handles();

    main();
    while(1);
}

void Default_Handler(void) {
    printf("Default handler ...\r\n");
    while(1);
}

/* Vector Table */
__attribute__((section(".isr_vector")))
uint32_t vector_table[] = {
    (uint32_t)&_stack_top,           /* Stack pointer initial */
    (uint32_t)&Reset_Handler,        /* Reset                 */
    (uint32_t)&Default_Handler,      /* NMI                   */
    (uint32_t)&Default_Handler,      /* HardFault             */
    (uint32_t)&Default_Handler,      /* MemManage             */
    (uint32_t)&Default_Handler,      /* BusFault              */
    (uint32_t)&Default_Handler,      /* UsageFault            */
};
