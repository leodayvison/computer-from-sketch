.section .text
.global _start


_start:
   ldr sp, =0x9000
   mov r0, #1          
   ldr r1, =msg        
   mov r2, #11
   mov r7, #4          
   svc #0

   mov r0, #0          
   mov r7, #1          
   svc #0

.data
msg:
    .ascii "Bem-vindo!\n"
