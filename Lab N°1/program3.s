addiu $t0, $zero, 0x10010000 #Se fija la direccion de memoria
add $t1, $zero, 3 #se carga el valor de 3 al registro t1
sw $t1, 0($t0) #Se fija el valor de la direccion de memoria como 3
lw $t2, 0($t0) #Se carga el valor de la primera posicion del arreglo al registro t2
addiu $t0, $t0, 12 #Se suma 12 para ir a la tercera posicion del arreglo
add $t2, $t2, -1 #Se hace la operacion a[0] - 1
sw $t2, 0($t0) #Se carga el valor a la posicion a[3] del arreglo
