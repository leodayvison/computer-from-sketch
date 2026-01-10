.section .text
.global _start


_start:
   ldr sp, =0x8000 @ inicializa stack


   ldr r0, =kernel_addr @ endereço onde o kernel será carregado
   bx r0 @ transfere execução


hang:
   b hang


kernel_addr:
   .word 0x10000 @ endereço fixo do kernel
