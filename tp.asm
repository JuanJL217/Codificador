; Colocar nombre y padron de los integrantes del grupo

global	main

section	.data
	secuenciaBinariaA   db 0xC4, 0x94, 0x37, 0x95, 0x63, 0xA2, 0x1D, 0x3C
					    db 0x86, 0xFC, 0x22, 0xA9, 0x3D, 0x7C, 0xA4, 0x51
					    db 0x63, 0x7C, 0x29, 0x04, 0x93, 0xBB, 0x65, 0x18
	largoSecuenciaA 	db 0x18 ; Largo de la secuencia (24 bytes)

section	.bss
	secuenciaImprimibleA	resb	32
	binariosGuardados 		resb 	192 ; Reservamos espacio para 192 bits (24 bytes * 8 bits por byte)

section	.text

main:
	mov  	rdi, secuenciaBinariaA  ;Apuntamos al array de hexadecimales
	mov 	rsi, binariosGuardados  ;Apuntamos al espacio reservado para los binarios convertidos
	mov 	rax, [largoSecuenciaA]  ;Largo de la secuencia (24 bytes) en rax
	mov 	rbx, 0                  ;Contador de bytes (índice de secuenciaBinariaA)

obtener_byte:
	cmp 	rbx, rax               ;Comparamos el contador con el largo de la secuencia
	jge 	fin_conversion         ;Si rbx >= rax, terminamos la conversión
	mov 	cl, [rdi+rbx]          ;Cargamos el byte actual de la secuencia en cl
	mov		dl, 8                  ;Necesitamos 8 iteraciones para cada byte (8 bits)

convertir_bit:
	test 	cl, 0x80               ;Probamos el primer bit (más significativo)
	jz 		bit_cero               ;Si es 0, lo almacenamos como bit 0
	mov 	byte [rsi+rbx], 1      ;Si es 1, lo almacenamos como bit 1
	jmp 	siguiente_bit

bit_cero:
	mov 	byte [rsi+rbx], 0       ;Si el bit es 0, lo almacenamos como bit 0

siguiente_bit:
	shl 	cl, 1                   ;Desplazamos cl a la izquierda para probar el siguiente bit
	inc 	rbx                     ;Incrementamos el contador de bytes
	dec 	dl                      ;Decrementamos el contador de bits restantes
	jnz 	convertir_bit           ;Si quedan bits por procesar, repetimos el ciclo
	jmp 	obtener_byte            ;Repetimos el ciclo para el siguiente byte

fin_conversion:
	ret
