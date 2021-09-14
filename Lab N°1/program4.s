add $t6, $zero, 2 # a
add $t7, $zero, 10 # b
add $t0, $zero, 0 # m
j While #Se salta al ciclo

While:
	ble $t6,0, Salida #Se verifica la condicion para romper el ciclo a>0 en caso de romper el ciclo se salta a otra etiqueta
	add $t0, $t0, $t7
	add $t6, $t6, -1
	j While #Se vuelve a repetir el ciclo
Salida:
