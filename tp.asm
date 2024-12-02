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

	secuenciaBinariaA	    db	0xC4, 0x94, 0x37, 0x95, 0x63, 0xA2, 0x1D, 0x3C 
						    db	0x86, 0xFC, 0x22, 0xA9, 0x3D, 0x7C, 0xA4, 0x51 
						    db	0x63, 0x7C, 0x29, 0x04, 0x93, 0xBB, 0x65, 0x18 
	largoSecuenciaA		    db	0x18 ; 24d
    TablaConversion		    db	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    resultadoCodificado     db  "Codificacion: %s", 10, 0

section	.bss
    secuenciaImprimibleA	resb  32
    cadenaBinario           resb  193    ; Espacio suficiente para almacenar los binarios (3*8 bits + terminador nulo)

section	.text

main:
    mov     rdi, secuenciaBinariaA   ; Apuntamos al primer número hexadecimal
    mov     rsi, cadenaBinario      ; Apuntamos a la cadena donde guardaremos el binario
    mov     rbx, 0                  ; Inicializamos el contador de bytes procesados (empezamos con 0)

procesar_valores:
    movzx   rcx, byte [largoSecuenciaA] ;
    cmp     rbx, rcx                 ; Verificar si hemos procesado la cantidad de bytes
    jge     binario_terminado            ; Si ya procesamos todos los bytes, saltamos a imprimir
    mov     al, [rdi]               ; Cargar el valor hexadecimal actual en al
    mov     rcx, 0                  ; Inicializamos rcx en 0 para contar los bits (de 0 a 7)

convertir_a_binario:
    cmp     rcx, 8                 ; Comparar si hemos procesado los 8 bits
    jge     siguiente_byte          ; Si ya procesamos los 8 bits, saltamos al siguiente byte
    test    al, 0x80                ; Comando AND, si el bit más significativo es 1 (0x80 = 10000000 en binario)
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
    inc     rbx                     ; Incrrementar el contador de bytes procesados
    inc     rdi                     ; Avanzar al siguiente byte
    jmp     procesar_valores        ; Continuar procesando los valores
    
binario_terminado:
    mov     byte [rsi], 0           ; Terminar la cadena con un terminador nulo

inicializar_informacion_para_convertir_bits:
    mov     rsi, secuenciaImprimibleA
    mov     rdi, 0
    mov     rdx, 0
    mov     rax, 0          
    mov     rcx, 0 

procesar_binario:
    cmp     rcx, 6                        ; Comprobar si hemos procesado todos los bits
    je      convertir_a_base_64       ; Si hemos procesado todos los bits, saltamos
    mov     bl, byte [cadenaBinario + rdx]  ; Cargar el carácter actual
    cmp     bl, '0'                   ; Verificar si es '1'
    je      es_cero                  ; Si no es '1', entonces es '0'
    or      rax, 1                   ; Poner el bit en el lugar adecuado

es_cero:
    cmp     rcx, 5
    je      avanzar_bit
    shl     rax, 1                   ; Desplazar a la izquierda para preparar el siguiente bit

avanzar_bit:
    inc     rcx                      ; Avanzar al siguiente bit
    inc     rdx
    jmp     procesar_binario         ; Repetir el proceso

ver_final:
    cmp     byte [cadenaBinario + rdx], 0
    je      fin_proceso

siguiente_6_bits:
    mov     rcx, 0
    mov     rax, 0
    jmp     procesar_binario

convertir_a_base_64:
    mov     cl, byte [TablaConversion + rax]
    mov     byte [rsi + rdi], cl
    inc     rdi
    jmp     ver_final

fin_proceso:
    mov     byte[rsi+rdi], 0
    mPrintf resultadoCodificado, secuenciaImprimibleA
    ret