.text
	li $a1, 524
	li $a2, 247
	
	#Convierto a1
	mtc1.d $a1, $f0
	cvt.d.w $f0, $f0
	
	#Convierto a2
	mtc1.d $a2, $f2
	cvt.d.w $f2, $f2
	
	div.d $f4, $f0, $f2
	
	li $v0, 3 #Codigo 3 printea doubles del registro f12
	mov.d $f12, $f4 #Se carga el numero a printear en f12
	syscall
	