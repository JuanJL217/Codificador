; Rocio Belen Kraska - 111340
; Juan Ernesto Juarez Lezama - 110418

%macro mPrintf 2
    mov     rdi, %1  ; Movemos la cadena que queremos mosrar del .data
    mov     rsi, %2  ; Movemos la cadena que creamos con la lógica al rsi
    sub     rsp, 8   ; Quita 8 para reservar espacio para printear
    call    printf   ; Printeamos
    add     rsp, 8   ; Le volvemos a agregar 8 para restaurar la pila
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
    cadenaBinario           resb  193    ; Espacio para los 192 bits

section	.text

main:
    mov     rdi, secuenciaBinariaA  ; Apuntamos a la cadena de hexadecimales
    mov     rsi, cadenaBinario      ; Apuntamos a la cadena donde guardaremos la cadena de binarios
    mov     rbx, 0                  ; Inicializamos el contador de la cantidad de bytes procesados

procesar_byte:
    movzx   rcx, byte [largoSecuenciaA]  ; Toma el byte, 8 bits, y rellena de 0 para hacerlo de 64 bits
    cmp     rbx, rcx                     ; Verificar si hemos procesado la cantidad de bytes de largoSecuanciaA
    jge     binario_terminado            ; Si ya procesamos todos los bytes, bifucarmos
    mov     al, [rdi]                    ; Cargar el valor hexadecimal actual en registo al (8 bits)
    mov     rcx, 0                       ; Inicializamos rcx en 0 para contar los bits que vayamos posicionandonos

convertir_a_binario:
    cmp     rcx, 8           ; Comparamos si hemos procesado los 8 bits
    jge     siguiente_byte   ; Si ya procesamos los 8 bits, saltamos al siguiente byte
    test    al, 0x80         ; Comando AND, si el bit más significativo es 1 (0x80 = 10000000 en binario)
    jz      bit_cero         ; Si el bit es 0, bifurco
    mov     byte [rsi], '1'  ; Si el bit es 1, almacenar '1' en la cadena
    jmp     siguiente_bit    ; Bifucar a la lógica para avanzar al siguiente bit

bit_cero:
    mov     byte [rsi], '0'  ; Almacenar '0' en la cadena

siguiente_bit:
    inc     rcx                  ; Incrementar el contador de bits
    inc     rsi                  ; Avanzar a la siguiente posición de la cadena de binarios
    shl     al, 1                ; Desplazar el valor a la izquierda (procesamos el siguiente bit)
    jmp     convertir_a_binario  ; Continuao el ciclo de procesar y convertir los bits

siguiente_byte:
    inc     rbx            ; Incrrementar el contador de bytes procesados
    inc     rdi            ; Avanzo una posicion de la cadena de hexadecimales
    jmp     procesar_byte  ; Continuo con el ciclo inicial de procesar el byte
    
binario_terminado:
    mov     byte [rsi], 0  ; Terminamos la cadena con un terminador nulo

inicializar_informacion_para_convertir_bits:
    mov     rsi, secuenciaImprimibleA  ; Apuntamos a la cadena donde coloraremos la codificación
    mov     rdx, 0                     ; Inicialzamos el iterador de la cadena de binarios
    mov     rax, 0                     ; Inicializamos en 0, ya que en rax guardaremos el valor decimal de los 6 bits
                                       ; porque a memdida que vayamos, iremos multiplicando por 2 (binario a decimal)
    mov     rcx, 0                     ; Inicializamos el contador de bits

procesar_binario:
    cmp     rcx, 6                          ; Comparamos si ya contamos 6 bits
    je      convertir_a_base_64             ; Si son iguales, entonces bifurcamos a convertir a base 64, caso contrario
                                            ; seguirá de largo
    mov     bl, byte [cadenaBinario + rdx]  ; Cargar el carácter actual ('0' o '1')
    cmp     bl, '0'                         ; El codigo Ascii de '0' es 48, entonces comparamos
    je      es_cero                         ; Si resula ser que bl almacena '0' (numero 48 en ascii), bifuca
    inc     rax                             ; Si bl almacena '1´, incrementa en 1 el valor en rax

es_cero:
    cmp     rcx, 5       ; Compara si llegamos a la posicion del último bit (0 1 2 3 4 5) -> 6 bits
    je      avanzar_bit  ; Si son iguales, entonces bifucar a la lógica de avanzar al siguiente bit
    imul    rax, 2       ; Multiplico por 2 el valor de rax y se guarda en rax

avanzar_bit:
    inc     rcx               ; Avanzar al siguiente bit
    inc     rdx               ; Incremento el iterador de posiciones para la cadena de binarios
    jmp     procesar_binario  ; Repetir el proceso

ver_final:
    cmp     byte [cadenaBinario + rdx], 0  ; Comparo si llegamos al final de la cadena
    je      fin_proceso                    ; Si es igual al final de la cadena, finalizo el proceso
                                           ; caso contrario, sigo de largo

siguiente_6_bits:
    mov     rcx, 0            ; Para procesar otros nuevos 6 bits, inicializo nuevamente rcx en 0
    mov     rax, 0            ; Vuelvo a inicializar el rax para almacenar los decimales
    jmp     procesar_binario  ; Bifurco a la logica de procesar los bits

convertir_a_base_64:
    mov     cl, byte [TablaConversion + rax]  ; Guardamos en cl el caracter obtenido de la tabla dado el  
                                              ; valor de rax (rax es la posicion en la tabla)
    mov     byte [rsi], cl                    ; Guardamos el caracter en la direccion de memoria de la cadena
                                              ; se secuanciaImprimibleA
    inc     rsi                               ; Incrementamos la dirección de memoria de rsi, que viene a ser la
                                              ; la siguiente posicion para el nuevo caracter
    jmp     ver_final                         ; Bifucarmos a la lógica de ver si estamos en el final de la cadenade binarios

fin_proceso:
    mov     byte [rsi], 0                              ; Agregamos el 0 final a la cadena de la codificación (secuenciaImprimibleA)
    mPrintf resultadoCodificado, secuenciaImprimibleA  ; Printeamos el resultado de la codificación
    mov     rax,0                                      ; Le damos al acumulador el valor de 0 (return 0)
    ret 