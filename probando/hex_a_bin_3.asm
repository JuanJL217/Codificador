%macro mPrintf 2
    mov     rdi, %1
    mov     rsi, %2
    call    printf
%endmacro

global	main
    extern printf

section .data
    valorHexadecimal db 0xFA, 0x17, 0x6B     ; Valores en hexadecimal
    resultadoBinario db "binario: %s", 10, 0 ; Mensaje para imprimir binario
    cantidadBytes db 0x03                    ; Cantidad de bytes a procesar
    imprimir db "Grupo: %d", 10, 0           ; Mensaje para imprimir los grupos
section .bss
    cadenaBinario resb 25  ; Espacio para la representación binaria (24 bits + terminador nulo)
    group1 resb 1          ; Espacio para cada grupo de 6 bits
    group2 resb 1
    group3 resb 1
    group4 resb 1
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
    mov     eax, ebx                     ; Pasar el valor de 24 bits a eax para 'cuatroOfSix'

    call    cuatroOfSix                  ; Llamar a la función para dividir en grupos

    mov     rax, 60                      
    xor     rdi, rdi                     
    syscall


cuatroOfSix:
    mov     edx, eax   
    shr     edx, 18                 ; Shifts right 18
    and     edx, 0x3F               ; Masks with 00111111 to get only 6 bits
    mov     [group1], dl            ; Guardar el primer grupo en group1. dl es el byte inferior de edx

    ; Grupo 2: Bits 17-12
    mov     edx, eax
    shr     edx, 12
    and     edx, 0x3F
    mov     [group2], dl

    ; Grupo 3: Bits 11-6
    mov     edx, eax
    shr     edx, 6
    and     edx, 0x3F
    mov     [group3], dl

    ; Grupo 4: Bits 5-0
    mov     edx, eax
    shr     edx, 0
    and     edx, 0x3F
    mov     [group4], dl

    ; Imprimir los grupos
    lea     rdi, [imprimir]
    
    ; Grupo 1
    movzx   rdx, byte [group1]   ; Acceder al valor almacenado en group1
    mPrintf imprimir, rdx        ; Pasar el valor de group1
    
    ; Grupo 2
    movzx   rdx, byte [group2]   ; Acceder al valor almacenado en group2
    mPrintf imprimir, rdx        ; Pasar el valor de group2

    ; Grupo 3
    movzx   rdx, byte [group3]   ; Acceder al valor almacenado en group3
    mPrintf imprimir, rdx        ; Pasar el valor de group3

    ; Grupo 4
    movzx   rdx, byte [group4]   ; Acceder al valor almacenado en group4
    mPrintf imprimir, rdx        ; Pasar el valor de group4

    ret
