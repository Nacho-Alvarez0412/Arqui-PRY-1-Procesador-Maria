;------------------------------------------------------------------------;
; Ignacio Alvarez Barrantes                  Arquitectura de Computadores;
; 2019039643                                            Esteban Arias    ;
; Sebastian Gamboa Bolaños                                               ;
; 2019044679                     Proyecto #1                             ;  
;                               Ensamblador                              ;  
;------------------------------------------------------------------------;

%include "io.mac"


len EQU			1024 	;Macro textual

.DATA
	inputMessage	db	"Digite el nombre del archivo que desea correr: ",0
	PCPrint		db	"PC: ",0
	IRPrint		db	"IR: ",0
	error		db	"Error de syntax",0
	waitMessage	db	"Digite cualquier tecla para continuar el proceso",0
	invalidMessage	db	"El archivo ingresado no es reconocido por el programa",0	
	printA		db	"A: ",0
	printB		db	"B: ",0
	printC		db	"C: ",0
	printD		db	"D: ",0
	printE		db	"E: ",0
	flags		db	"Flags: ",0
	printSF		db	"SF: ",0
	printZF		db	"ZF: ",0 
	printAF		db	"AF: ",0
	printPF		db	"PF: ",0
	printCF		db	"CF: ",0


.UDATA
	trash			resb	1
	file			resb	50
	content			resb	1024
	IR			resb	5
	PC			resb	1
	FA			resb	4
	FB			resb	4
	FC			resb	4
	FD			resb	4
	FE			resb	4
	SF			resb	1
	ZF			resb	1
	CF			resb	1
	PF			resb	1

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
	cmp		byte[EAX],"&" ;El programa termino
	je		END
	
	cmp		byte[EAX],"*" ;Determina si es instruccion
	je		InstructionSet
	inc		EAX
	jmp		ReadInstruction
	
	
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
	mov		EDX,[PC]
	inc		EDX
	mov		[PC],EDX
	;Realiza ejecucion paso por paso

	;--------------------------------
	PutStr		waitMessage
	GetStr		trash
	nwln
	;--------------------------------

	mov		EDX,EAX
	call		PrintInstructionSet

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
	mov	EAX,EBX

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
	mov	EAX,EBX
	
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
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con sum -> add

	cmp	byte[EAX],"s"
	jne	InstructionSet8
	inc	EAX
	cmp	byte[EAX],"u"
	jne	InstructionSet8 
	inc	EAX
	cmp	byte[EAX],"m"
	jne	InstructionSet8
	call	Sumar
	add	EAX,2
	jmp	ReadInstruction


InstructionSet8:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con res -> sub

	cmp	byte[EAX],"r"
	jne	InstructionSet9
	inc	EAX
	cmp	byte[EAX],"e"
	jne	InstructionSet9 
	inc	EAX
	cmp	byte[EAX],"s"
	jne	InstructionSet9
	call	Restar

	add	EAX,2
	jmp	ReadInstruction

InstructionSet9:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con slt -> jmp

	cmp	byte[EAX],"s"
	jne	InstructionSet10
	inc	EAX
	cmp	byte[EAX],"l"
	jne	InstructionSet10 
	inc	EAX
	cmp	byte[EAX],"t"
	jne	InstructionSet10
	add	EAX,2
	call	Saltar
	jmp	ReadInstruction

InstructionSet10:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con itr -> loop

	cmp	byte[EAX],"i"
	jne	InstructionSet11
	inc	EAX
	cmp	byte[EAX],"t"
	jne	InstructionSet11 
	inc	EAX
	cmp	byte[EAX],"r"
	jne	InstructionSet11
	call	Iterar
	jmp	ReadInstruction


InstructionSet11:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con rod -> ror

	cmp	byte[EAX],"r"
	jne	InstructionSet12
	inc	EAX
	cmp	byte[EAX],"o"
	jne	InstructionSet12
	inc	EAX
	cmp	byte[EAX],"d"
	jne	InstructionSet12
	call	rotarDerecha
	jmp	ReadInstruction


InstructionSet12:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con roi -> rol

	cmp	byte[EAX],"r"
	jne	InstructionSet13
	inc	EAX
	cmp	byte[EAX],"o"
	jne	InstructionSet13
	inc	EAX
	cmp	byte[EAX],"i"
	jne	InstructionSet3
	call	rotarIzquierda
	jmp	ReadInstruction



InstructionSet13:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con prb -> test

	cmp	byte[EAX],"p"
	jne	InstructionSet14
	inc	EAX
	cmp	byte[EAX],"r"
	jne	InstructionSet14 
	inc	EAX
	cmp	byte[EAX],"b"
	jne	InstructionSet14
	call	Probar
	jmp	ReadInstruction




InstructionSet14:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con gem -> and

	cmp	byte[EAX],"g"
	jne	InstructionSet15
	inc	EAX
	cmp	byte[EAX],"e"
	jne	InstructionSet15 
	inc	EAX
	cmp	byte[EAX],"m"
	jne	InstructionSet15
	call	Gemelitos
	jmp	ReadInstruction

InstructionSet15:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con sgm -> je

	cmp	byte[EAX],"s"
	jne	InstructionSet16
	inc	EAX
	cmp	byte[EAX],"g"
	jne	InstructionSet16
	inc	EAX
	cmp	byte[EAX],"m"
	jne	InstructionSet16
	call	saltarGemelos
	jmp	ReadInstruction

InstructionSet16:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con sng -> jne

	cmp	byte[EAX],"s"
	jne	InstructionSet17
	inc	EAX
	cmp	byte[EAX],"n"
	jne	InstructionSet17 
	inc	EAX
	cmp	byte[EAX],"g"
	jne	InstructionSet17
	call	saltarNoGemelos
	jmp	ReadInstruction


InstructionSet17:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con sco -> jz

	cmp	byte[EAX],"s"
	jne	InstructionSet18
	inc	EAX
	cmp	byte[EAX],"c"
	jne	InstructionSet18
	inc	EAX
	cmp	byte[EAX],"o"
	jne	InstructionSet18
	call	Gemelitos
	jmp	ReadInstruction


InstructionSet18:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con snc -> jnz

	cmp	byte[EAX],"s"
	jne	InstructionSet19
	inc	EAX
	cmp	byte[EAX],"n"
	jne	InstructionSet19 
	inc	EAX
	cmp	byte[EAX],"c"
	jne	InstructionSet19
	call	saltarNoCero
	jmp	ReadInstruction


InstructionSet19:
	mov	EAX,EBX       ;Guarda la posicion actual en caso de no ser
	
	;Compara con mud

	cmp	byte[EAX],"m"
	jne	InstructionSet20
	inc	EAX
	cmp	byte[EAX],"u"
	jne	InstructionSet20 
	inc	EAX
	cmp	byte[EAX],"d"
	jne	InstructionSet20
	call	multiplicar
	jmp	ReadInstruction

InstructionSet20:
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
; 				 Check
;------------------------------------------------------------------------------
;E: 2 strings
;S: revisa si dos valores son iguales
;D: revisa el contenido de dos valores, y enciende flags si son iguales


Check:

	add			EAX,2
	mov			EDX,0
	mov			ECX,0
	call		CMPFirst
	inc 			EAX
	cmp			byte[EAX],","
	jne			ERROR
	inc			EAX
	call 	CMPFirst2
	cmp		DX,CX
	je		Set0Flag
	mov		byte[ZF],0
	mov		byte[SF],1
	ret

Set0Flag:
	mov	byte[ZF],1
	mov	byte[SF],0
	ret


CMPFirst:

	cmp	byte[EAX],"A"
	je	ARegister
	cmp byte[EAX],"B"
	je BRegister
	cmp	byte[EAX],"C"
	je	CRegister
	cmp byte[EAX],"D"
	je DRegister
	cmp byte[EAX],"E"
	je ERegister


ARegister:
	mov DX,[FA]
	ret
BRegister:
	mov DX,[FB]
	ret
CRegister:
	mov DX,[FC]
	ret
DRegister:
	mov DX,[FD]
	ret
ERegister:
	mov DX,[FE]
	ret


CMPFirst2:

	cmp	byte[EAX],"A"
	je	ARegister2
	cmp byte[EAX],"B"
	je BRegister2
	cmp	byte[EAX],"C"
	je	CRegister2
	cmp byte[EAX],"D"
	je DRegister2
	cmp byte[EAX],"E"
	je ERegister2

ARegister2:
	mov CX,[FA]
	ret
BRegister2:
	mov CX,[FB]
	ret
CRegister2:
	mov CX,[FC]
	ret
DRegister2:
	mov CX,[FD]
	ret
ERegister2:
	mov CX,[FE]
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
	
	add			EAX,2
	ret

IsB:
	mov			EDX,0
	mov			EDX,EAX
	shr			EDX,1
	mov			[FB],DX
	
	add			EAX,2
	ret

IsC:
	mov			EDX,0
	mov			EDX,EAX
	shr			EDX,1
	mov			[FC],DX
	
	add			EAX,2
	ret

IsD:
	mov			EDX,0
	mov			EDX,EAX
	shr			EDX,1
	mov			[FD],DX
	
	add			EAX,2
	ret

IsE:
	mov			EDX,0
	mov			EDX,EAX
	shr			EDX,1
	mov			[FE],DX
	
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
	
	add			EAX,2
	ret

IsB2:
	mov			EDX,0
	mov			EDX,EAX
	shl			EDX,1
	mov			[FB],DX
	
	add			EAX,2
	ret

IsC2:
	mov			EDX,0
	mov			EDX,EAX
	shl			EDX,1
	mov			[FC],DX
	
	add			EAX,2
	ret

IsD2:
	mov			EDX,0
	mov			EDX,EAX
	shl			EDX,1
	mov			[FD],DX
	
	add			EAX,2
	ret

IsE2:
	mov			EDX,0
	mov			EDX,EAX
	shl			EDX,1
	mov			[FE],DX
	
	add			EAX,2
	ret


;------------------------------------------------------------------------------
; 				 Sumar
;------------------------------------------------------------------------------
;E: 2 datos
;S: void
;D: suma 2 registros un valor a un registro

Sumar:

	add			EAX,2
	cmp			byte[EAX],"A"
	je			AddA
	cmp			byte[EAX],"B"
	je			AddB
	cmp			byte[EAX],"C"
	je			AddC
	cmp			byte[EAX],"D"
	je			AddD
	cmp			byte[EAX],"E"
	je			AddE
	PutStr			error
	jmp			END


AddA:
	mov			EBX,[FA]
	push			EBX
	add			EAX,2
	
	cmp			byte[EAX],"A"
	je			AddRA

	cmp			byte[EAX],"B"
	je			AddRB

	cmp			byte[EAX],"C"
	je			AddRC

	cmp			byte[EAX],"D"
	je			AddRD
	
	cmp			byte[EAX],"E"
	je			AddRE

	jmp			AddNumberA

AddB:
	mov			EBX,[FB]
	push			EBX	
	
	add			EAX,2
	
	cmp			byte[EAX],"A"
	je			AddRA

	cmp			byte[EAX],"B"
	je			AddRB

	cmp			byte[EAX],"C"
	je			AddRC

	cmp			byte[EAX],"D"
	je			AddRD
	
	cmp			byte[EAX],"E"
	je			AddRE
	
	jmp			AddNumberB

AddC:
	mov			EBX,[FC]
	push			EBX
	add			EAX,2
	
	cmp			byte[EAX],"A"
	je			AddRA

	cmp			byte[EAX],"B"
	je			AddRB

	cmp			byte[EAX],"C"
	je			AddRC

	cmp			byte[EAX],"D"
	je			AddRD
	
	cmp			byte[EAX],"E"
	je			AddRE

	jmp			AddNumberC

AddD:
	mov			EBX,[FD]
	push			EBX
	add			EAX,2
	
	cmp			byte[EAX],"A"
	je			AddRA

	cmp			byte[EAX],"B"
	je			AddRB

	cmp			byte[EAX],"C"
	je			AddRC

	cmp			byte[EAX],"D"
	je			AddRD
	
	cmp			byte[EAX],"E"
	je			AddRE

	jmp			AddNumberD

AddE:
	mov			EBX,[FE]
	push			EBX
	add			EAX,2
	
	cmp			byte[EAX],"A"
	je			AddRA

	cmp			byte[EAX],"B"
	je			AddRB

	cmp			byte[EAX],"C"
	je			AddRC

	cmp			byte[EAX],"D"
	je			AddRD
	
	cmp			byte[EAX],"E"
	je			AddRE

	jmp			AddNumberE

AddRA:
	add			EBX,[FA]
	mov			[FA],EBX
	jmp			SumaEnd

AddRB:
	add			EBX,[FB]
	mov			[FB],EBX
	jmp			SumaEnd

AddRC:
	add			EBX,[FC]
	mov			[FC],EBX
	jmp			SumaEnd


AddRD:
	add			EBX,[FD]
	mov			[FD],EBX
	jmp			SumaEnd


AddRE:
	add			EBX,[FE]
	mov			[FE],EBX
	jmp			SumaEnd

AddNumberA:
	mov			ECX,0
	call			GetNumber
	pop			EBX
	add			EBX,ECX
	mov			[FA],EBX
	jmp			SumaEnd

AddNumberB:
	mov			ECX,0
	call			GetNumber
	pop			EBX

	add			EBX,ECX
	mov			[FB],EBX

	jmp			SumaEnd

AddNumberC:
	mov			ECX,0
	call			GetNumber
	pop			EBX

	add			EBX,ECX
	mov			[FC],EBX
	jmp			SumaEnd

AddNumberD:
	mov			ECX,0
	call			GetNumber
	pop			EBX

	add			EBX,ECX
	mov			[FD],EBX
	jmp			SumaEnd

AddNumberE:
	mov			ECX,0
	call			GetNumber
	pop			EBX

	add			EBX,ECX
	mov			[FE],EBX
	jmp			SumaEnd

SumaEnd:
	ret



;------------------------------------------------------------------------------
; 				 Restar
;------------------------------------------------------------------------------
;E: 2 datos
;S: void
;D: suma 2 registros un valor a un registro

Restar:

	add			EAX,2
	cmp			byte[EAX],"A"
	je			RestarA
	cmp			byte[EAX],"B"
	je			RestarB
	cmp			byte[EAX],"C"
	je			RestarC
	cmp			byte[EAX],"D"
	je			RestarD
	cmp			byte[EAX],"E"
	je			RestarE
	PutStr			error
	jmp			END


RestarA:
	mov			EBX,[FA]
	push			EBX
	add			EAX,2
	
	cmp			byte[EAX],"A"
	je			RestarRA

	cmp			byte[EAX],"B"
	je			RestarRB

	cmp			byte[EAX],"C"
	je			RestarRC

	cmp			byte[EAX],"D"
	je			RestarRD
	
	cmp			byte[EAX],"E"
	je			RestarRE

	jmp			RestarNumberA

RestarB:
	mov			EBX,[FB]
	push			EBX	
	
	add			EAX,2
	
	cmp			byte[EAX],"A"
	je			RestarRA

	cmp			byte[EAX],"B"
	je			RestarRB

	cmp			byte[EAX],"C"
	je			RestarRC

	cmp			byte[EAX],"D"
	je			RestarRD
	
	cmp			byte[EAX],"E"
	je			RestarRE
	
	jmp			RestarNumberB

RestarC:
	mov			EBX,[FC]
	push			EBX
	add			EAX,2
	
	cmp			byte[EAX],"A"
	je			RestarRA

	cmp			byte[EAX],"B"
	je			RestarRB

	cmp			byte[EAX],"C"
	je			RestarRC

	cmp			byte[EAX],"D"
	je			RestarRD
	
	cmp			byte[EAX],"E"
	je			RestarRE

	jmp			RestarNumberC

RestarD:
	mov			EBX,[FD]
	push			EBX
	add			EAX,2
	
	cmp			byte[EAX],"A"
	je			RestarRA

	cmp			byte[EAX],"B"
	je			RestarRB

	cmp			byte[EAX],"C"
	je			RestarRC

	cmp			byte[EAX],"D"
	je			RestarRD
	
	cmp			byte[EAX],"E"
	je			RestarRE

	jmp			RestarNumberD

RestarE:
	mov			EBX,[FE]
	push			EBX
	add			EAX,2
	
	cmp			byte[EAX],"A"
	je			RestarRA

	cmp			byte[EAX],"B"
	je			RestarRB

	cmp			byte[EAX],"C"
	je			RestarRC

	cmp			byte[EAX],"D"
	je			RestarRD
	
	cmp			byte[EAX],"E"
	je			RestarRE

	jmp			RestarNumberE

RestarRA:
	sub			EBX,[FA]
	mov			[FA],EBX
	jmp			RestaEnd

RestarRB:
	sub			EBX,[FB]
	mov			[FB],EBX
	jmp			RestaEnd

RestarRC:
	add			EBX,[FC]
	mov			[FC],EBX
	jmp			RestaEnd


RestarRD:
	add			EBX,[FD]
	mov			[FD],EBX
	jmp			RestaEnd


RestarRE:
	add			EBX,[FE]
	mov			[FE],EBX
	jmp			RestaEnd

RestarNumberA:
	mov			ECX,0
	call			GetNumber
	pop			EBX
	sub			EBX,ECX
	mov			[FA],EBX
	jmp			RestaEnd

RestarNumberB:
	mov			ECX,0
	call			GetNumber
	pop			EBX

	sub			EBX,ECX
	mov			[FB],EBX

	jmp			RestaEnd

RestarNumberC:
	mov			ECX,0
	call			GetNumber
	pop			EBX

	sub			EBX,ECX
	mov			[FC],EBX
	jmp			RestaEnd

RestarNumberD:
	mov			ECX,0
	call			GetNumber
	pop			EBX

	sub			EBX,ECX
	mov			[FD],EBX
	jmp			RestaEnd

RestarNumberE:
	mov			ECX,0
	call			GetNumber
	pop			EBX

	sub			EBX,ECX
	mov			[FE],EBX
	jmp			RestaEnd

RestaEnd:
	ret


;------------------------------------------------------------------------------
; 					Saltar
;------------------------------------------------------------------------------
;E: void
;S: void
;D: Salta a una etiqueta 

Saltar:
	mov		EDX,buffer    ;Coloca un puntero al inicio del programa
	

FindLabel:
	cmp		byte[EDX],"!"
	je		IsLabel
	inc		EDX
	jmp		FindLabel

IsLabel:
	inc		EDX
	mov		BL,byte[EAX]
	cmp		byte[EDX],BL
	je		Match
	jmp		FindLabel

Match:
	mov		EAX,EDX

NextInstruction:
	cmp		byte[EAX],"*"
	je		LabelFound
	inc		EAX
	jmp		NextInstruction

LabelFound:
	ret


;------------------------------------------------------------------------------
; 					loop
;------------------------------------------------------------------------------
;E: void
;S: void
;D: Salta a una etiqueta mientras ECX sea diferente a 0


Iterar:
	mov		ECX,[FC]
	cmp		ECX,0		;Verifica si debe seguir repitiendo
	je		LoopDone
	sub		ECX,1
	mov		[FC],ECX
	add		EAX,2
	call	Saltar
	ret

LoopDone:
	ret


	
;------------------------------------------------------------------------------
; 					Rotate right
;------------------------------------------------------------------------------
;E: 1 valor
;S: void
;D: Rota un numero a la derecha
	

rotarDerecha:

	cmp			byte[EAX],"A"
	je			IsA3
	cmp			byte[EAX],"B"
	je			IsB3
	cmp			byte[EAX],"C"
	je			IsC3
	cmp			byte[EAX],"D"
	je			IsD3
	cmp			byte[EAX],"E"
	je			IsE3
	jmp			ERROR			
	ret


IsA3:
	mov			EDX,0
	mov			EDX,EAX
	ror			EDX,1
	mov			[FA],DX
	
	add			EAX,2
	ret

IsB3:
	mov			EDX,0
	mov			EDX,EAX
	ror			EDX,1
	mov			[FB],DX
	
	add			EAX,2
	ret

IsC3:
	mov			EDX,0
	mov			EDX,EAX
	ror			EDX,1
	mov			[FC],DX
	
	add			EAX,2
	ret

IsD3:
	mov			EDX,0
	mov			EDX,EAX
	ror			EDX,1
	mov			[FD],DX
	
	add			EAX,2
	ret

IsE3:
	mov			EDX,0
	mov			EDX,EAX
	ror			EDX,1
	mov			[FE],DX
	
	add			EAX,2
	ret



;------------------------------------------------------------------------------
; 					Rotate left
;------------------------------------------------------------------------------
;E: 1 valor
;S: void
;D: Rota un numero a la izquierda
	

rotarIzquierda:

	cmp			byte[EAX],"A"
	je			IsA4
	cmp			byte[EAX],"B"
	je			IsB4
	cmp			byte[EAX],"C"
	je			IsC4
	cmp			byte[EAX],"D"
	je			IsD4
	cmp			byte[EAX],"E"
	je			IsE4
	jmp			ERROR			
	ret


IsA4:
	mov			EDX,0
	mov			EDX,EAX
	rol			EDX,1
	mov			[FA],DX
	
	add			EAX,2
	ret

IsB4:
	mov			EDX,0
	mov			EDX,EAX
	rol			EDX,1
	mov			[FB],DX
	
	add			EAX,2
	ret

IsC4:
	mov			EDX,0
	mov			EDX,EAX
	rol			EDX,1
	mov			[FC],DX
	
	add			EAX,2
	ret

IsD4:
	mov			EDX,0
	mov			EDX,EAX
	rol			EDX,1
	mov			[FD],DX
	
	add			EAX,2
	ret

IsE4:
	mov			EDX,0
	mov			EDX,EAX
	rol			EDX,1
	mov			[FE],DX
	
	add			EAX,2
	ret

			

;------------------------------------------------------------------------------
; 				 Test
;------------------------------------------------------------------------------
;E: 2 strings
;S: revisa si ciertos bits son iguales
;D: revisa el contenido de dos valores, y enciende flags si son los bits iguales


Probar:

	add			EAX,2
	mov			EDX,0
	mov			ECX,0
	call		CMPFirst3
	inc 			EAX
	cmp			byte[EAX],","
	jne			ERROR
	inc			EAX
	call 	CMPFirst4
	cmp		DX,CX
	je		Set0FlagTest
	mov		byte[ZF],0
	mov		byte[SF],1
	ret

Set0FlagTest:
	mov	byte[ZF],1
	mov	byte[SF],0
	ret


CMPFirst3:

	cmp	byte[EAX],"A"
	je	ARegister3
	cmp byte[EAX],"B"
	je BRegister3
	cmp	byte[EAX],"C"
	je	CRegister3
	cmp byte[EAX],"D"
	je DRegister3
	cmp byte[EAX],"E"
	je ERegister3


ARegister3:
	mov DX,[FA]
	ret
BRegister3:
	mov DX,[FB]
	ret
CRegister3:
	mov DX,[FC]
	ret
DRegister3:
	mov DX,[FD]
	ret
ERegister3:
	mov DX,[FE]
	ret


CMPFirst4:

	cmp	byte[EAX],"A"
	je	ARegister4
	cmp byte[EAX],"B"
	je BRegister4
	cmp	byte[EAX],"C"
	je	CRegister4
	cmp byte[EAX],"D"
	je DRegister4
	cmp byte[EAX],"E"
	je ERegister4

ARegister4:
	mov CX,[FA]
	ret
BRegister4:
	mov CX,[FB]
	ret
CRegister4:
	mov CX,[FC]
	ret
DRegister4:
	mov CX,[FD]
	ret
ERegister4:
	mov CX,[FE]
	ret




;------------------------------------------------------------------------------
; 				 And
;------------------------------------------------------------------------------
;E: 2 strings
;S: revisa si dos valores son iguales
;D: revisa el contenido de dos valores, y enciende flags si son iguales


Gemelitos:

	add			EAX,2
	mov			EDX,0
	mov			ECX,0
	call		CMPFirst5
	inc 			EAX
	cmp			byte[EAX],","
	jne			ERROR
	inc			EAX
	call 	CMPFirst6
	cmp		DX,CX
	je		Set0FlagAnd
	mov		byte[ZF],0
	mov		byte[SF],1
	ret

Set0FlagAnd:
	mov	byte[ZF],1
	mov	byte[SF],0
	ret


CMPFirst5:

	cmp	byte[EAX],"A"
	je	ARegister5
	cmp byte[EAX],"B"
	je BRegister5
	cmp	byte[EAX],"C"
	je	CRegister5
	cmp byte[EAX],"D"
	je DRegister5
	cmp byte[EAX],"E"
	je ERegister5


ARegister5:
	mov DX,[FA]
	ret
BRegister5:
	mov DX,[FB]
	ret
CRegister5:
	mov DX,[FC]
	ret
DRegister5:
	mov DX,[FD]
	ret
ERegister5:
	mov DX,[FE]
	ret


CMPFirst6:

	cmp	byte[EAX],"A"
	je	ARegister6
	cmp byte[EAX],"B"
	je BRegister6
	cmp	byte[EAX],"C"
	je	CRegister6
	cmp byte[EAX],"D"
	je DRegister6
	cmp byte[EAX],"E"
	je ERegister6

ARegister6:
	mov CX,[FA]
	ret
BRegister6:
	mov CX,[FB]
	ret
CRegister6:
	mov CX,[FC]
	ret
DRegister6:
	mov CX,[FD]
	ret
ERegister6:
	mov CX,[FE]
	ret




;------------------------------------------------------------------------------
; 				 Jump if Equal
;------------------------------------------------------------------------------
;E: 
;S: 
;D: salta si son iguales


saltarGemelos:
	je		CallSaltar	
	ret

CallSaltar:
	call		Saltar
	ret



;------------------------------------------------------------------------------
; 				 Jump if not Equal
;------------------------------------------------------------------------------
;E: 
;S: 
;D: salta si no son iguales


saltarNoGemelos:

	jne		CallNoSaltar	
	ret

CallNoSaltar:
	call		Saltar
	ret



;------------------------------------------------------------------------------
; 				 Jump if zero
;------------------------------------------------------------------------------
;E: 
;S: 
;D: salta si son iguales


saltarCero:

	
	jz		Call0Saltar	
	ret

Call0Saltar:
	call		Saltar
	ret



;------------------------------------------------------------------------------
; 				 Jump if not zero
;------------------------------------------------------------------------------
;E: 
;S: 
;D: salta si no son iguales


saltarNoCero:

	jnz		Call0NoSaltar	
	ret

Call0NoSaltar:
	call		Saltar
	ret

;------------------------------------------------------------------------------
; 				 Print InstructionSet
;------------------------------------------------------------------------------
;E: 
;S: 
;D: imprime los datos del Programa

PrintInstructionSet:
	
	PutStr		PCPrint
	PutLInt		[PC]
	PutCh		"	"
	PutStr		IRPrint
	inc		EDX
	PutCh		byte[EDX]
	inc		EDX
	PutCh		byte[EDX]
	inc		EDX
	PutCh		byte[EDX]
	add		EDX,2
	PutCh		"	"
	cmp		byte[EDX],"*"
	jne		Parametro1
	

	ret

Parametro1:
	PutCh		byte[EDX]
	inc		EDX
	cmp		byte[EDX],";"
	je		DonePrintingParameters
	cmp		byte[EDX],","
	jmp		Parametro1

DonePrintingParameters:
	jmp	PrintRegisters

PrintRegisters:
	PutCh	"	"
	PutStr	printA
	PutLInt	[FA]

	PutCh	"	"
	PutStr	printB
	PutLInt	[FB]

	PutCh	"	"
	PutStr	printC
	PutLInt	[FC]

	PutCh	"	"
	PutStr	printD
	PutLInt	[FD]

	PutCh	"	"
	PutStr	printE
	PutLInt	[FE]

	jmp	PrintFlags

PrintFlags:
	nwln
	PutStr	flags
	PutCh	"	"
	mov	EDX,EAX
	LAHF	
	call	getValues
	mov	EAX,EDX
	nwln
	nwln
	ret
	
;-----------------------------------------------------------------
;-----------------------------------------------------------------
;-----------------------------------------------------------------	
getValues:
	mov	CH,AH
	and	CH,80H
	PutStr	printSF
	PutInt	[SF]
	PutCh	"	"
	PutStr	printZF
	PutInt	[ZF]
	

	PutCh	"	"
	mov	CH,AH
	and	CH,50H
	cmp	CH,0
	jne	Put1AF
	PutStr	printAF
	PutCh	"0"
	jmp	PrintPF

Put1AF:
	PutStr	printAF
	PutCh	"1"
	
PrintPF:
	PutCh	"	"
	mov	CH,AH
	and	CH,30H
	cmp	CH,0
	jne	Put1PF
	PutStr	printPF
	PutCh	"0"
	jmp	PrintCF

Put1PF:
	PutStr	printPF
	PutCh	"1"
	
PrintCF:
	PutCh	"	"
	mov	CH,AH
	and	CH,10H
	cmp	CH,0
	jne	Put1CF
	PutStr	printCF
	PutCh	"0"
	jmp	DonePrintingFlags

Put1CF:
	PutStr	printCF
	PutCh	"1"

DonePrintingFlags:
	ret
	
		
	



; Multiplicar por 10


multiplicar:

	add			EAX,2
	cmp			byte[EAX],"A"
	je			IsRegisterA5
	cmp			byte[EAX],"B"
	je			IsRegisterB5
	cmp			byte[EAX],"C"
	je			IsRegisterC5
	cmp			byte[EAX],"D"
	je			IsRegisterD5
	cmp			byte[EAX],"E"
	je			IsRegisterE5
	jmp			ERROR			
	ret


IsRegisterA5:
	mov EDX,[FA]
	mov EBX,[FA]
	call multi
	call multi
	call multi
	call multi
	call multi
	call multi
	call multi
	call multi
	call multi
	mov  [FA],DX
	ret


IsRegisterB5:
	mov EDX,[FB]
	mov EBX,[FB]
	call multi
	call multi
	call multi
	call multi
	call multi
	call multi
	call multi
	call multi
	call multi
	mov  [FB],DX
	ret

IsRegisterC5:
	mov EDX,[FC]
	mov EBX,[FC]
	call multi
	call multi
	call multi
	call multi
	call multi
	call multi
	call multi
	call multi
	call multi
	mov [FC],DX
	ret

IsRegisterD5:
	mov EDX,[FD]
	mov EBX,[FD]
	call multi
	call multi
	call multi
	call multi
	call multi
	call multi
	call multi
	call multi
	call multi
	mov [FD],DX
	ret

IsRegisterE5:
	mov EDX,[FE]
	mov EBX,[FE]
	call multi
	call multi
	call multi
	call multi
	call multi
	call multi
	call multi
	call multi
	call multi
	mov [FE],DX
	ret

multi:
	add EDX,EBX
	ret

