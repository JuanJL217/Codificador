%macro mPrintf 2
    mov     rdi, %1
    mov     rsi, %2
    call    printf
%endmacro

global	main
    extern printf

section .data
    valorHexadecimal db 0xAA, 0xD4, 0x00     ; Valores en hexadecimal
    resultadoBinario db "binario: %s", 10, 0 ; Mensaje para imprimir binario
    cantidadBytes db 0x03                    ; Cantidad de bytes a procesar
    imprimir db "Grupo: %c", 10, 0           ; Mensaje para imprimir los grupos
    asciiTable db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", 0
section .bss
    cadenaBinario resb 25  ; Espacio para la representación binaria (24 bits + terminador nulo)
    groupo resb 6          ; Espacio para cada grupo de 6 bits
section .text

main:
    ; Convertir los valores hexadecimales a binarios
    mov     rdi, valorHexadecimal  ; Apuntamos al primer byte hexadecimal
    mov     rsi, cadenaBinario    ; Apuntamos a la cadena donde guardaremos el binario

    mov     rbx, 0                ; Inicializamos el contador de bytes procesados

procesar_valores:
    movzx   rcx, byte [cantidadBytes]  ; Cantidad de bytes a procesar
    cmp     rbx, rcx                    ; Verificar si hemos procesado los 3 bytes
    jge     fin_binario                 ; Si ya hemos procesado los 3, saltamos al final

    mov     al, [rdi]                   ; Cargar el valor hexadecimal actual en AL
    mov     rcx, 0                       ; Inicializamos el índice de los bits

convertir_a_binario:
    cmp     rcx, 8                       ; Comparar si hemos procesado los 8 bits
    jge     siguiente_byte               ; Si ya procesamos los 8 bits, saltamos al siguiente byte
    test    al, 0x80                     ; Testear si el bit más significativo es 1 (0x80 = 10000000 en binario)
    jz      bit_cero                     ; Si el bit es 0, saltar
    mov     byte [rsi], '1'              ; Si el bit es 1, almacenar '1' en la cadena
    jmp     siguiente_bit

bit_cero:
    mov     byte [rsi], '0'              ; Si el bit es 0, almacenar '0' en la cadena

siguiente_bit:
    inc     rcx                          ; Incrementar el índice de la cadena binaria
    inc     rsi                          ; Avanzar a la siguiente posición de la cadena
    shl     al, 1                        ; Desplazar el valor a la izquierda (procesamos el siguiente bit)
    jmp     convertir_a_binario          ; Continuar el ciclo de conversión

siguiente_byte:
    inc     rbx                          ; Incrementar el contador de bytes procesados
    inc     rdi                          ; Avanzar al siguiente byte
    jmp     procesar_valores             ; Continuar procesando los valores

fin_binario:
    mov     byte [rsi], 0                ; Terminar la cadena con un terminador nulo
    mPrintf resultadoBinario, cadenaBinario   ; Imprimir el resultado binario

    ; Convertir la cadena binaria a un entero de 24 bits
    lea     rsi, [cadenaBinario]         ; Apuntar a la cadena binaria
    xor     ebx, ebx                     ; Inicializar el acumulador de 24 bits
    mov     ecx, 24                      ; Procesar 24 bits
    xor     rdx, rdx                     ; Índice en la cadena

convertir_a_24bits:
    mov     al, byte [rsi + rdx]         ; Leer un carácter ('0' o '1'), RDX: INDICE, AL: CARACTER
    cmp     al, '1'                      ; Verificar si es '1'
    jne     es_cero                      ; Si no es '1', debe ser '0', salto a 'es_cero'
    or      ebx, 1                       ; Es '1', establecer el bit menos significativo

es_cero:
    shl     ebx, 1                       ; Desplazar acumulador a la izquierda
    inc     rdx                          ; Avanzar al siguiente bit
    loop    convertir_a_24bits           ; Repetir hasta completar los 24 bits

    shr     ebx, 1                       ; Corregir el desplazamiento extra del último loop
    call    cuatroOfSix                  ; Llamar a la función para dividir en grupos

    mov     rax, 60                      
    xor     rdi, rdi                     
    syscall

cuatroOfSix:
    mov     ecx, 18                   ; Iniciar en 18 (primer grupo de 6 bits)

procesar_grupo:
    ; Preservar los registros antes de llamar a mPrintf
    push    rcx                       ; Guardar el valor de ECX
    push    rdx                       ; Guardar el valor de RDX

    mov     edx, ebx                  ; Restaurar los 24 bits originales
    shr     edx, cl                   ; Desplazar los bits más significativos al final
    and     edx, 0x3F                 ; Extraer los últimos 6 bits
    movzx   esi, dl                   ; Guardar los 6 bits en RSI
    mov     dl, [asciiTable + rsi]    ; Mapear a carácter ASCII Base64
    mov     [groupo], dl              ; Guardar el carácter en el buffer

    lea     rdi, [imprimir]           ; Preparar el formato para impresión
    movzx   rdx, byte [groupo]        ; Pasar el carácter a imprimir
    mPrintf imprimir, rdx             ; Imprimir el carácter

    ; Restaurar los registros después de mPrintf
    pop     rdx                       ; Restaurar el valor original de RDX
    pop     rcx                       ; Restaurar el valor original de ECX

    sub     ecx, 6                    ; Reducir el contador en 6 bits
    cmp     ecx, -6                   ; Verificar si hay más grupos
    jg      procesar_grupo            ; Continuar si hay más grupos
    ret

