;------------------------------------------------------------------------;
; Ignacio Alvarez Barrantes                  Arquitectura de Computadores;
; 2019039643                                            Esteban Arias    ;
; Sebastian Gamboa Bolaños                                               ;
; 2019044679                     Proyecto #1                              ;  
;                               Ensamblador                              ;  
;------------------------------------------------------------------------;

%include "io.mac"


len EQU			1024 		;Macro textual

.DATA
	inputMessage	db	"Digite el nombre del archivo que desea correr: ",0
	pcTitle		db	"PC: ",0
	irTitle		db	"IR: ",0
	error		db	"Error de syntax",0
	

	invalidMessage	db	"El archivo ingresado no es reconocido por el programa",0	


.UDATA
	file			resb	50
	content			resb	1024
	IR			resb	5
	PC			resb	1
	FA			resb	4
	FB			resb	4
	FC			resb	4
	FD			resb	4
	FE			resb	4

section .bss
	descriptor		resb	8
	buffer			resb	1024	

.CODE
	.STARTUP
	mov			EAX,0
	mov			[PC],EAX

	;Intro message	

	PutStr		inputMessage	;Imprime la solicitud del input
	GetStr		file		;Guarda el nombre del archivo
	nwln

	;Carga el programa al EAX	

	call		openFile

	;Identifica instruccion

ReadInstruction:
	mov		EDX,[PC]
	inc		EDX
	mov		[PC],EDX
	call		PrintPC
	cmp		byte[EAX],"&" ;El programa termino
	je		END	
	cmp		byte[EAX],"*" ;Determina si es instruccion
	je		InstructionSet
	; que pasa aqui si no hay un *, deberiamos poner como un syntax error
	
	
	
END:

	mov			EAX,6			;Cierra el file
	mov			EBX,[descriptor]
	int			80h			;Cierra el file

	mov			EAX,1		;exits the system call
	mov			EBX,0
	int			80h

	nwln
	.EXIT

InstructionSet:
	inc	EAX
	mov	EBX,EAX

	;Compara con cam -> mov
	
	cmp	byte[EAX],"c"
	jne	InstructionSet2
	inc	EAX
	cmp	byte[EAX],"a"
	jne	InstructionSet2
	inc	EAX
	cmp	byte[EAX],"m"
	jne	InstructionSet2
	call	Cambiar
	jmp	ReadInstruction

InstructionSet2:
	mov	EAX,EBX
	
	;Compara con met -> push

	cmp	byte[EAX],"m"
	jne	InstructionSet3
	inc	EAX
	cmp	byte[EAX],"e"
	jne	InstructionSet3
	inc	EAX
	cmp	byte[EAX],"t"
	jne	InstructionSet3
	call	Meter	
	push	ECX
	add	EAX,3
	jmp	ReadInstruction

InstructionSet3:
	mov	EAX,EBX
	
	;Compara con sac -> pop

	cmp	byte[EAX],"s"
	jne	InstructionSet4
	inc	EAX
	cmp	byte[EAX],"a"
	jne	InstructionSet4
	inc	EAX
	cmp	byte[EAX],"c"
	jne	InstructionSet4
	pop	ECX
	call	Sacar
	jmp	ReadInstruction

InstructionSet4:
	mov	EBX,EAX

	;Compara con chk -> cmp
	
	cmp	byte[EAX],"c"
	jne	InstructionSet5
	inc	EAX
	cmp	byte[EAX],"h"
	jne	InstructionSet5
	inc	EAX
	cmp	byte[EAX],"k"
	jne	InstructionSet5
	call	Check
	jmp	ReadInstruction

InstructionSet5:
	mov	EBX,EAX
	
	;Compara con cod -> shr

	cmp	byte[EAX],"c"
	jne	InstructionSet6
	inc	EAX
	cmp	byte[EAX],"o"
	jne	InstructionSet6
	inc	EAX
	cmp	byte[EAX],"d"
	jne	InstructionSet6
	call	CorrerDerecha	
	jmp	ReadInstruction

InstructionSet6:
	mov	EAX,EBX
	
	;Compara con coi -> shl

	cmp	byte[EAX],"c"
	jne	InstructionSet7
	inc	EAX
	cmp	byte[EAX],"o"
	jne	InstructionSet7
	inc	EAX
	cmp	byte[EAX],"i"
	jne	InstructionSet7
	call	CorrerIzquierda
	jmp	ReadInstruction
	

InstructionSet7:
	jmp	END

;------------------------------------------------------------------------------
; 							File Opener
;------------------------------------------------------------------------------
;E: 1 string
;S: Contenido de un archivo dado
;D: Abre un archivo y lo retorna en el registro EAX

openFile:
	mov			ECX,0			;Read Only
	mov			EBX,file		;Nombre del archivo por abrir
	mov			EAX,5			;Abre el archivo
	int			80h				;Realiza el system call de read only

	mov			[descriptor],EAX;Guarda el descriptor

	mov			EAX,3			;Que lea desde el archivo
	mov			EBX,[descriptor];El descriptor del archivo
	mov			ECX,buffer		;Leer al buffer
	mov			EDX,len			;Lee 1024 bytes
	int			80h				;lee 1024 bytes al buffer desde file

	mov			EAX,buffer	;Mueve el contenido al EAX
	ret


;------------------------------------------------------------------------------
; 				 Cambiar
;------------------------------------------------------------------------------
;E: 2 string
;S: Mueve los valores de una variables
;D: Mueve valores en memoria

Cambiar:
	add			EAX,2
	cmp			byte[EAX],"A"
	je			IsRegisterA
	cmp			byte[EAX],"B"
	je			IsRegisterB
	cmp			byte[EAX],"C"
	je			IsRegisterC
	cmp			byte[EAX],"D"
	je			IsRegisterD
	cmp			byte[EAX],"E"
	je			IsRegisterE
	jmp			ERROR			
	ret


IsRegisterA:
	inc			EAX
	cmp			byte[EAX],","
	jne			ERROR
	inc			EAX
	mov			EDX,0
	mov			ECX,0
	call			GetNumber
	mov			[FA],CX
	PutInt			[FA]
	PutCh			"	"
	add			EAX,2		
	jmp			ReadInstruction

IsRegisterB:
	inc			EAX
	cmp			byte[EAX],","
	jne			ERROR
	inc			EAX
	mov			EDX,0
	mov			ECX,0
	call			GetNumber
	mov			[FB],CX
	PutInt			[FB]
	PutCh			"	"
	add			EAX,2
	jmp			ReadInstruction

IsRegisterC:
	inc			EAX
	cmp			byte[EAX],","
	jne			ERROR
	inc			EAX
	mov			EDX,0
	mov			ECX,0
	call			GetNumber
	mov			[FC],CX
	PutInt			[FC]
	PutCh			"	"
	add			EAX,2
	jmp			ReadInstruction

IsRegisterD:
	inc			EAX
	cmp			byte[EAX],","
	jne			ERROR
	inc			EAX
	mov			EDX,0
	mov			ECX,0
	call			GetNumber
	mov			[FD],CX
	PutInt			[FD]
	PutCh			"	"
	add			EAX,2
	jmp			ReadInstruction

IsRegisterE:
	inc			EAX
	cmp			byte[EAX],","
	jne			ERROR
	inc			EAX
	mov			EDX,0
	mov			ECX,0
	call			GetNumber
	mov			[FE],CX
	PutInt			[FE]
	PutCh			"	"
	add			EAX,2
	jmp			ReadInstruction






;------------------------------------------------------------------------------
; 				 GetNumber
;------------------------------------------------------------------------------
;E: 1 string
;S: 1 int
;D: Dado un numero de tipo String lo retorna de tipo int

GetNumber:
	cmp			byte[EAX],"A"
	je			ObtainA
	cmp			byte[EAX],"B"
	je			ObtainB
	cmp			byte[EAX],"C"
	je			ObtainC
	cmp			byte[EAX],"D"
	je			ObtainD
	cmp			byte[EAX],"E"
	je			ObtainE
	cmp			byte[EAX],";"
	je			DoneNumber
	add			CX,CX
	mov			BX,CX
	add			CX,CX
	add			CX,CX
	add			CX,BX
	mov			DL,byte[EAX]
	sub			DL,48
	add			CX,DX
	inc			EAX
	jmp			GetNumber

DoneNumber:
	ret

ObtainA:
	mov			ECX,[FA]
	inc			EAX
	jmp			GetNumber

ObtainB:
	mov			ECX,[FB]
	inc			EAX
	jmp			GetNumber

ObtainC:
	mov			ECX,[FC]
	inc			EAX
	jmp			GetNumber

ObtainD:
	mov			ECX,[FD]
	inc			EAX
	jmp			GetNumber

ObtainE:
	mov			ECX,[FE]
	inc			EAX
	jmp			GetNumber


ERROR:
	PutStr			error
	jmp			END

;------------------------------------------------------------------------------
; 				 Meter
;------------------------------------------------------------------------------
;E: un dato
;S: void
;D: inserta el valor en la pila

Meter:
	
	add	EAX,2
	cmp	byte[EAX],"A"
	je	meterA
	cmp	byte[EAX],"B"
	je	meterB
	cmp	byte[EAX],"C"
	je	meterC
	cmp	byte[EAX],"D"
	je	meterD
	cmp	byte[EAX],"E"
	je	meterE
	jmp	ERROR

meterA:
	mov	ECX,[FA]
	ret

meterB:
	mov	ECX,[FB]
	ret

meterC:
	mov	ECX,[FC]
	ret

meterD:
	mov	ECX,[FD]
	ret
	
meterE:
	mov	ECX,[FE]
	ret


;------------------------------------------------------------------------------
; 				 Sacar
;------------------------------------------------------------------------------
;E: void
;S: un dato
;D: inserta el valor en la pila

Sacar:
	
	add	EAX,2
	cmp	byte[EAX],"A"
	je	sacarA
	cmp	byte[EAX],"B"
	je	sacarB
	cmp	byte[EAX],"C"
	je	sacarC
	cmp	byte[EAX],"D"
	je	sacarD
	cmp	byte[EAX],"E"
	je	sacarE
	jmp	ERROR

sacarA:
	mov	EDX,[PC]
	mov	[FA],ECX
	mov	[PC],EDX
	ret

sacarB:
	mov	EDX,[PC]
	mov	[FB],ECX
	mov	[PC],EDX
	ret

sacarC:
	mov	EDX,[PC]
	mov	[FC],ECX
	mov	[PC],EDX
	ret

sacarD:
	mov	EDX,[PC]
	mov	[FD],ECX
	mov	[PC],EDX
	ret
	
sacarE:
	mov	EDX,[PC]
	mov	[FE],ECX
	mov	[PC],EDX
	ret



;------------------------------------------------------------------------------
; 				 Print PC
;------------------------------------------------------------------------------
;E: void
;S: void
;D: imprime el pc

PrintPC:
	PutStr			pcTitle
	PutLInt			[PC]
	nwln
	ret



;------------------------------------------------------------------------------
; 				 Check
;------------------------------------------------------------------------------
;E: 2 strings
;S: revisa si dos valores son iguales
;D: revisa el contenido de dos valores, y enciende flags si son iguales


Check:

	add			EAX,2
	mov			EDX,0
	mov			DL,byte[EAX]
	inc 		EAX
	cmp			byte[EAX],","
	jne			ERROR
	inc			EAX
	cmp 		DL,byte[EAX]		
	ret

	
;------------------------------------------------------------------------------
; 				 Correr Derecha
;------------------------------------------------------------------------------
;E: 1 valor
;S: Realiza un shift right del valor
;D: Realiza un shift right, y enciende o no banderas


CorrerDerecha:

	cmp			byte[EAX],"A"
	je			IsA
	cmp			byte[EAX],"B"
	je			IsB
	cmp			byte[EAX],"C"
	je			IsC
	cmp			byte[EAX],"D"
	je			IsD
	cmp			byte[EAX],"E"
	je			IsE
	jmp			ERROR			
	ret


IsA:
	mov			EDX,0
	mov			EDX,EAX
	shr			EDX,1
	mov			[FA],DX
	PutInt			[FA]
	PutCh			"	"
	add			EAX,2
	ret

IsB:
	mov			EDX,0
	mov			EDX,EAX
	shr			EDX,1
	mov			[FB],DX
	PutInt			[FB]
	PutCh			"	"
	add			EAX,2
	ret

IsC:
	mov			EDX,0
	mov			EDX,EAX
	shr			EDX,1
	mov			[FC],DX
	PutInt			[FC]
	PutCh			"	"
	add			EAX,2
	ret

IsD:
	mov			EDX,0
	mov			EDX,EAX
	shr			EDX,1
	mov			[FD],DX
	PutInt			[FD]
	PutCh			"	"
	add			EAX,2
	ret

IsE:
	mov			EDX,0
	mov			EDX,EAX
	shr			EDX,1
	mov			[FE],DX
	PutInt			[FE]
	PutCh			"	"
	add			EAX,2
	ret


;------------------------------------------------------------------------------
; 				 Correr Izquierda
;------------------------------------------------------------------------------
;E: 1 valor
;S: Realiza un shift left del valor
;D: Realiza un shift left, y enciende o no banderas


CorrerIzquierda:

	cmp			byte[EAX],"A"
	je			IsA2
	cmp			byte[EAX],"B"
	je			IsB2
	cmp			byte[EAX],"C"
	je			IsC2
	cmp			byte[EAX],"D"
	je			IsD2
	cmp			byte[EAX],"E"
	je			IsE2
	jmp			ERROR			
	ret


IsA2:
	mov			EDX,0
	mov			EDX,EAX
	shl			EDX,1
	mov			[FA],DX
	PutInt			[FA]
	PutCh			"	"
	add			EAX,2
	ret

IsB2:
	mov			EDX,0
	mov			EDX,EAX
	shl			EDX,1
	mov			[FB],DX
	PutInt			[FB]
	PutCh			"	"
	add			EAX,2
	ret

IsC2:
	mov			EDX,0
	mov			EDX,EAX
	shl			EDX,1
	mov			[FC],DX
	PutInt			[FC]
	PutCh			"	"
	add			EAX,2
	ret

IsD2:
	mov			EDX,0
	mov			EDX,EAX
	shl			EDX,1
	mov			[FD],DX
	PutInt			[FD]
	PutCh			"	"
	add			EAX,2
	ret

IsE2:
	mov			EDX,0
	mov			EDX,EAX
	shl			EDX,1
	mov			[FE],DX
	PutInt			[FE]
	PutCh			"	"
	add			EAX,2
	ret

