;------------------------------------------------------------------------;
; Ignacio Alvarez Barrantes                  Arquitectura de Computadores;
; 2019039643                                            Esteban Arias    ;
; Sebastian Gamboa Bolaños                                               ;
; 2019044679                     Proyecto #                              ;  
;                               Ensamblador                              ;  
;------------------------------------------------------------------------;
%include "io.mac"

section .bss

  descriptor resb 4 ;memory for storing descriptor
  buffer resb 1024
  len equ 1024
  content   resb    1024
  current_byte resd 1
  fileLen resd 1024
  file resb 24


.CODE

.STARTUP


Read:

  GetStr file       ; pide al usuario el nombre del archivo que se desea leer

  mov eax,5 ;abre el archivo
  mov ebx,file ;nombre del archivo
  mov ecx,0 ;modo leer solamente
  int 80h ;ejecuta la accion de abrir el archivo

  mov [descriptor],eax 

  mov eax,3 ;leer el archivo
  mov ebx,[descriptor] 
  mov ecx,buffer ;guarda el contenido a la variable 
  mov edx, len ;lee la cantidad de bytes de la variable
  int 80h ;ejecuta la accion

  mov edx,eax ;guarda la cantidad de datos leidos
  mov eax,4 ;escribe a la terminal
  mov ebx,1 
  mov ecx,buffer ;escribe lo que hay en la variable buffer
  int 80h ;ejecuta la accion

  mov eax,6 ;cierra el archivo
  mov ebx,[descriptor] 
  int 80h ;ejecuta la accion
  ret
