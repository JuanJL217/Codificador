
%macro mPrintf 2
    mov     rdi, %1
    mov     rsi, %2
    sub     rsp, 8
    call    printf
    add     rsp, 8
%endmacro

global	main
    extern printf

section	.data
    valorHexadecimal        db  0xFA, 0x17, 0x6B   
    resultadoBinario        db "binario: %s", 10, 0 
    cantidadBytes           db  0x03
section	.bss
    cadenaBinario           resb  25    ; Espacio suficiente para almacenar los binarios (3*8 bits + terminador nulo)

section	.text

main:
    mov     rdi, valorHexadecimal   ; Apuntamos al primer número hexadecimal
    mov     rsi, cadenaBinario      ; Apuntamos a la cadena donde guardaremos el binario
    mov     rbx, 0                  ; Inicializamos el contador de bytes procesados (empezamos con 0)

procesar_valores:
    movzx   rcx, byte [cantidadBytes] ;
    cmp     rbx, rcx                 ; Verificar si hemos procesado los 3 bytes
    jge     fin_binario            ; Si ya hemos procesado los 3, saltamos al final

    mov     al, [rdi]               ; Cargar el valor hexadecimal actual en al
    mov     rcx, 0                  ; Inicializamos rcx en 0 para contar los bits (de 0 a 7)

convertir_a_binario:
    cmp     rcx, 8                 ; Comparar si hemos procesado los 8 bits
    jge     siguiente_byte          ; Si ya procesamos los 8 bits, saltamos al siguiente byte
    test    al, 0x80                ; Testear si el bit más significativo es 1 (0x80 = 10000000 en binario)
    jz      bit_cero                ; Si el bit es 0, saltar
    mov     byte [rsi], '1'         ; Si el bit es 1, almacenar '1' en la cadena
    jmp     siguiente_bit

bit_cero:
    mov     byte [rsi], '0'         ; Si el bit es 0, almacenar '0' en la cadena

siguiente_bit:
    inc     rcx                     ; Incrementar el índice de la cadena binaria
    inc     rsi                     ; Avanzar a la siguiente posición de la cadena
    shl     al, 1                   ; Desplazar el valor a la izquierda (procesamos el siguiente bit)
    jmp     convertir_a_binario     ; Continuar el ciclo de conversión

siguiente_byte:
    inc     rbx                     ; Incrementar el contador de bytes procesados
    inc     rdi                     ; Avanzar al siguiente byte
    jmp     procesar_valores        ; Continuar procesando los valores

fin_binario:
    mov     byte [rsi], 0           ; Terminar la cadena con un terminador nulo
    mPrintf resultadoBinario, cadenaBinario   ; Imprimir el resultado binario
    mov     rax, 60
    mov     rdi, 0
    syscall