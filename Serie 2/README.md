# Parcial2_DiegoSolis
Ejercicios de parcial 2 Micros

Mi ALU realiza operaciones de suma, resta, AND, OR, desplazamiento a la izquierda y desplazamiento a la derecha.

Se compone de los siguientes módulos:
	•	add: un full adder de 1 bit.
	•	Circ_add: un ripple-carry adder de 4/6 bits construido con varios full adders en cascada.
	•	cir_add: bloque que permite elegir entre suma y resta usando complemento a dos.
	•	Circ_and: realiza la operación lógica AND.
	•	Circ_or: realiza la operación lógica OR.
	•	Shift izquierdo y derecho: módulos que desplazan los bits una posición.
	•	cir_alu: módulo principal que integra todos los anteriores y selecciona la operación según el código de control.

	Video Vivado
	https://youtu.be/rbKlkw0pUJ8
	Video Logisim
	https://youtu.be/adPci3xcmYY


	La Alu opera en complemento 2