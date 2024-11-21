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
    valorHexadecimal        db  0x6B  ; El buinario es 11000100
    resultadoBinario        db "binario: %s", 10, 0 ; Cadena de formato para imprimir el resultado
section	.bss
    cadenaBinario           resb  9  ; Cadena para el binario, y el '\0'

section	.text

main:
    mov     al, [valorHexadecimal]    ; Cargar el valor en el registro al (al es 8 bits)
    mov     rsi, cadenaBinario       ; Apuntar a la cadena donde guardaremos la cadena
    mov     rcx, 0                   ; Inicializamos rcx en 0 para contabilizar la cantidad de bits

convertir_a_binario:
    cmp     rcx, 8                   ; Comparar si hemos procesado los 8 bits
    jge     fin_conversion           ; Si ya procesamos los 8 bits, saltar al final
    test    al, 80h                  ; Testear si el bit más significativo es 1 (0x80 = 10000000 en binario)
    jz      bit_cero                 ; Si el bit es 0, saltar
    mov     byte [rsi + rcx], '1'    ; Si el bit es 1, almacenar '1' en la cadena
    jmp     siguiente_bit

bit_cero:
    mov     byte [rsi + rcx], '0'    ; Si el bit es 0, almacenar '0' en la cadena

siguiente_bit:
    inc     rcx                      ; Incrementar el índice de la cadena binaria
    shl     al, 1                    ; Desplazar el valor a la izquierda (procesamos el siguiente bit)
    jmp     convertir_a_binario      ; Continuar el ciclo de conversión

fin_conversion:
    mov     byte [rsi + rcx], 0      ; Terminar la cadena con un terminador nulo

    ; Imprimir el resultado binario
    mPrintf resultadoBinario, cadenaBinario

    ret                              ; Terminar el programa
