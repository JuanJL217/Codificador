section .data
    byte1 db 0b11111010        ; 250 en decimal (mismo valor que 0xFA)
    byte2 db 0b00010111        ; 23 en decimal  (mismo valor que 0x17)
    byte3 db 0b01101011        ; 107 en decimal (mismo valor que 0x6B)
    imprimir db "Grupo %d: %d", 10, 0

section .bss
    group1 resb 1        ; 6 bits
    group2 resb 1        ; 6 bits
    group3 resb 1        ; 6 bits
    group4 resb 1        ; 6 bits

section .text
    global main
    extern printf

main:
    ; Cargar los 3 bytes en registros de 32 bits
    movzx eax, byte [byte1]    ; Cargar byte1 en EAX
    movzx ebx, byte [byte2]    ; Cargar byte2 en EBX
    movzx ecx, byte [byte3]    ; Cargar byte3 en ECX

    ; Combinar los 3 bytes en un solo valor de 24 bits
    shl eax, 16                ; Desplaza byte1 16 bits hacia la izquierda
    shl ebx, 8                 ; Desplaza byte2 8 bits hacia la izquierda
    or  eax, ebx               ; Combina byte1 y byte2
    or  eax, ecx               ; Combina con byte3, ahora EAX contiene los 24 bits

    ; Extraer los 4 grupos de 6 bits
    ; Grupo 1: Bits 23-18
    mov edx, eax              ; Copiar 24 bits a EDX
    shr edx, 18               ; Desplazar para obtener los bits 23-18
    and edx, 0x3F             ; Máscara para obtener solo 6 bits
    ; máscara: una operacion que se hace con un AND para obtener solo los bits que nos interesan
    mov [group1], dl          ; Guardar el primer grupo 
    ; 0x3F = 00111111 en binario, se usa para obtener los 6 bits menos significativos
    ; (dl es el byte inferior de edx)

    ; Grupo 2: Bits 17-12
    mov edx, eax             ; Copiar 24 bits a EDX
    shr edx, 12              ; Desplazar para obtener los bits 17-12
    and edx, 0x3F             ; Máscara para obtener solo 6 bits
    mov [group2], dl          ; Guardar el segundo grupo

    ; Grupo 3: Bits 11-6
    mov edx, eax             ; Copiar 24 bits a EDX
    shr edx, 6               ; Desplazar para obtener los bits 11-6
    and edx, 0x3F            ; Máscara para obtener solo 6 bits
    mov [group3], dl         ; Guardar el tercer grupo

    ; Grupo 4: Bits 5-0
    mov edx, eax             ; Copiar 24 bits a EDX
    and edx, 0x3F            ; Máscara para obtener los bits 5-0
    mov [group4], dl         ; Guardar el cuarto grupo

    ; Imprimir los grupos
    lea rdi, [imprimir]      ; Dirección de la cadena de formato
    xor eax, eax             ; Contador de argumentos flotantes

    sub rsp, 8               ; Alinear la pila

    ; Grupo 1
    mov rsi, 1               ; Número del grupo
    movzx rdx, byte [group1] ; Valor del grupo
    call printf

    ; Grupo 2
    lea rdi, [imprimir]      ; Dirección de la cadena de formato
    mov rsi, 2               ; Número del grupo
    movzx rdx, byte [group2] ; Valor del grupo
    call printf

    ; Grupo 3
    lea rdi, [imprimir]      ; Dirección de la cadena de formato
    mov rsi, 3               ; Número del grupo
    movzx rdx, byte [group3] ; Valor del grupo
    call printf

    ; Grupo 4
    lea rdi, [imprimir]      ; Dirección de la cadena de formato
    mov rsi, 4               ; Número del grupo
    movzx rdx, byte [group4] ; Valor del grupo
    call printf

    add rsp, 8               ; Restaurar la pila
    mov eax, 60
    xor edi, edi
    syscall
