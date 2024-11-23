


## Con Makefile

Por convención el archivo Makefile ejecutará el ensamblador sobre `tp.asm`. Si desea ejecutar otro, modifique la constante `NAME` en el Makefile, asignándole la ruta correspondiente al archivo deseado (sin extensión).

``` bash
make          # Ejecuta el ensamblador en tp.asm por defecto
make clean    # Limpia los archivos .o y .out generados
``` 

## Sin Makefile

``` bash
nasm hex_a_bin.asm -f elf64

gcc hex_a_bin.o -o hex.out -no-pie

./hex.out
```

``` bash
# En realidad sería:
nasm "nombre¨.asm -f elf64

gcc "nombre".o -o "nuevo nombre".out -no-pie

./"nuevo nombre".out
```