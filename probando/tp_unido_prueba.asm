; Colocar nombre y padron de los integrantes del grupo
%macro mPrintf 2
    mov     rdi, %1
    mov     rsi, %2
    call    printf
%endmacro

global	main
	extern	printf

section	.data
	secuenciaBinariaA   db 0xC4, 0x94, 0x37, 0x95, 0x63, 0xA2, 0x1D, 0x3C
					    db 0x86, 0xFC, 0x22, 0xA9, 0x3D, 0x7C, 0xA4, 0x51
					    db 0x63, 0x7C, 0x29, 0x04, 0x93, 0xBB, 0x65, 0x18
	largoSecuenciaA 	db 0x18 ; Largo de la secuencia (24 bytes)
	imprimirBinario 	db "binario: %s", 10, 0 ; Mensaje para imprimir el binario
    imprimir db "Grupo: %c", 10, 0           ; Mensaje para imprimir los grupos
    asciiTable db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", 0
section	.bss
	binariosGuardados 		resb	193 ; Espacio para 192 bits + terminador nulo
    groupo resb 6          ; Espacio para cada grupo de 6 bits

section	.text

main:
    mov     rsi, binariosGuardados  	; Apuntamos al espacio reservado para binarios
    mov     rdi, secuenciaBinariaA      ; Apuntamos a la secuencia binaria
    movzx   rcx, byte [largoSecuenciaA] ; Largo de la secuencia
    xor     rbx, rbx                    ; Índice global de bits

procesar_byte:
    cmp     rcx, 0                 ; ¿Quedan bytes por procesar?
    jz      fin_conversion         ; Si no, salimos
    movzx   rax, byte [rdi]        ; Cargar el siguiente byte en RAX
    mov     rdx, 8                 ; Procesar 8 bits por byte

convertir_bit:
    test    rax, 0x80              ; ¿Es el bit más significativo un 1?
    jz      es_cero                ; Si no, es un 0
    mov     byte [rsi + rbx], '1'  ; Si es 1, guardamos '1'
    jmp     siguiente_bit

es_cero:
    mov     byte [rsi + rbx], '0'  ; Si es 0, guardamos '0'

siguiente_bit:
    shl     rax, 1                 ; Desplazar a la izquierda para probar el siguiente bit
    inc     rbx                    ; Incrementar el índice global de bits
    dec     rdx                    ; Decrementar los bits restantes
    jnz     convertir_bit          ; Repetir hasta completar los 8 bits

    inc     rdi                    ; Avanzar al siguiente byte
    dec     rcx                    ; Decrementar el contador de bytes
    jmp     procesar_byte          ; Repetir para el siguiente byte

fin_conversion:
    mov     byte [rsi + rbx], 0                ; Agregar terminador nulo a la cadena
    mPrintf imprimirBinario, binariosGuardados ; Imprimir la secuencia binaria
    xor     ebx, ebx                     ; Inicializar el acumulador de 24 bits
    mov     ecx, binariosGuardados                      ; Procesar 24 bits
    xor     rdx, rdx                     ; Índice en la cadena
convertir_a_193bits:
    mov     rcx, 193                  ; Número de bits a procesar
    xor     rdx, rdx                  ; Inicializa el índice del buffer

convertir_a_193bits_loop:
    cmp     rdx, 192                  ; Verifica que el índice no exceda el límite
    jae     toASCII                   ; Sal del bucle si rdx es mayor o igual al tamaño del buffer

    mov     al, byte [rsi + rdx]      ; Leer un carácter ('0' o '1') del buffer
    cmp     al, '1'                   ; Verifica si es '1'
    jne     es_cero_bin               ; Si no es '1', salta a manejar '0'

    or      ebx, 1                    ; Es '1', establece el bit menos significativo

es_cero_bin:
    shl     ebx, 1                    ; Desplaza el acumulador a la izquierda
    inc     rdx                       ; Avanza al siguiente bit en el buffer
    dec     rcx                       ; Decrementa el contador de bits restantes
    jnz     convertir_a_193bits_loop  ; Si no se han procesado todos los bits, repite el bucle

    shr     ebx, 1                    ; Corrige el desplazamiento extra al final
    ret

toASCII:
    ; Procesamiento de los 192 bits acumulados en 'ebx'
    mov     ecx, 24                   ; Número de bits totales (24 * 6 = 192 bits)
    xor     rdx, rdx                  ; Restablece el índice del grupo

procesar_grupo:
    ; Extraer un grupo de 6 bits de 'ebx'
    mov     edx, ebx                  ; Restaura los 24 bits
    shr     edx, cl                   ; Desplazamos para extraer los primeros 6 bits
    and     edx, 0x3F                 ; Asegúrate de que solo los 6 bits menos significativos están activos

    movzx   esi, dl                   ; Guarda los 6 bits en 'esi'
    mov     dl, [asciiTable + rsi]    ; Mapea a carácter Base64
    mov     [groupo], dl              ; Guarda el carácter en el buffer

    lea     rdi, [imprimir]           ; Preparar el formato para imprimir
    movzx   rdx, byte [groupo]        ; Pasa el carácter a imprimir
    push    rax
    mPrintf imprimir, rdx             ; Imprimir el carácter

    pop     rax                       ; Restaurar el valor original de RAX
    pop     rdx                       ; Restaurar el valor original de RDX
    pop     rcx                       ; Restaurar el valor original de ECX

    sub     ecx, 6                    ; Reducir el contador en 6 bits
    cmp     ecx, 0                    ; Verifica si hay más grupos
    jg      procesar_grupo            ; Continuar si hay más grupos
    ret
