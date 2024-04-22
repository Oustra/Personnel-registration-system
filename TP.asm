section .data
message db '-------------------------------------------------',10,'Choisir une operation :',10, '1-Enregistrer du personnel',10, '2-Lister des personnes enregistrées',10,'3-Afficher des personnes spécifiques',10,'4-Afficher la personne la plus jeune',10,'5-Quitter le programme :', 10 ,'-> '
longueur equ $-message

;Les Messages a afficher----------------------------------------------------------------------
message1 db '-------------------------------------------------',10,'Enregistrement des personnes:',10,'=> '
longueur1 equ $-message1
message2 db '-------------------------------------------------',10,'List des personnes :',10
longueur2 equ $-message2
message3 db '-------------------------------------------------',10,'Cherche la personne :',10,'=> ID: '
longueur3 equ $-message3
message4 db '-------------------------------------------------',10,'Le plus jeune :',10
longueur4 equ $-message4
message5 db '-------------------------------------------------',10
longueur5 equ $-message5
message6 db 'Ajouter un autre personnel ? (y/n)',10
longueur6 equ $-message6

ExeptionMsg1 db 'Erreur', 10
LenExpMsg1 equ $-ExeptionMsg1
ExeptionMsg2 db 'ID Introuvable !', 10
LenExpMsg2 equ $-ExeptionMsg2
ExeptionMsg3 db 'Tableau des Personnels est Vide !', 10
LenExpMsg3 equ $-ExeptionMsg3

;Message d'erreur-----------------------------------------------------------------------------
msgErr db '-------------------------------------------------',10,'Veuillez entrer un nombre entier entre 1 et 5',10
lonErr equ $-msgErr
InputErr db '-------------------------------------------------',10,'Invalid Input !',10
LenInErr equ $-InputErr

;Les variables Operation----------------------------------------------------------------------
OperationNum dd 0
op1 db 1
op2 db 2
op3 db 3
op4 db 4
op5 db 5

;Les tableaux---------------------------------------------------------------------------------
TabTaille equ 1000
TabName db TabTaille dup(0)     ; Tableau des Noms
TabId dd TabTaille dup(0)		; Tableau des Ids
TabAge dd TabTaille dup(0)      ; Tableau des Ages 
NameSize dd 50
String db 0
;Autre Variables------------------------------------------------------------------------------
PersonCount dd 0                ; Compteur de personnels enregistrées
indice dd 1						; indice de boucle 
int_string db 0					; int -> string
string_int dd 0					; string -> int
PersonID db 0
PlusJeuneAge dd 0               ; Id du personnel
PlusJeuneID dd 0

;text section---------------------------------------------------------------------------------
section .text
global _start

_start:
	; Print message--------------------------------------------
	mov eax, 4
	mov ebx, 1
	mov ecx, message
	mov edx, longueur
	int 80h

	; Read input into number-----------------------------------
	mov eax, 3
	mov ebx, 0
	mov ecx, OperationNum
	;mov edx ,1
	int 80h

	mov al , [OperationNum]
	sub al , '0'
	mov [OperationNum] , al

	; Print message-------------------------------------------
	mov eax, 4
	mov ebx, 1

	; Message afficher pour chaque operation------------------
	mov dl, [OperationNum]

	cmp dl, [op1]
	je Enregistrer
	cmp dl, [op2]
	je ListPerson
	cmp dl, [op3]
	je DisplayPerson
	cmp dl, [op4]
	je PlusJeune
	cmp dl, [op5]
	je Quitter

	mov ecx, msgErr
	mov edx, lonErr
	int 80h

	jmp _start

Enregistrer:
	; Print message1
	mov ecx, message1
	mov edx, longueur1
	int 80h

	;Read Input ----------------------------------------------
	call _ReadInput
	
	jmp _start

ListPerson:
	; Print message2
	mov ecx, message2
	mov edx, longueur2
	int 80h

	mov dword [indice], 1
	mov esi, 0
	; verifier si la table est vide
	mov eax, [PersonCount]
	mov ebx, 0
	cmp eax, ebx
	jle exeption31

	loop_Display:
			
		mov eax, 4
    	mov ebx, 1
		mov edi, TabId
		add edi, esi
		mov ecx, edi    					; Adresse du début du tableau	
		mov edx, [NameSize]					; Taille maximale de la saisie  
    	int 80h
		
		mov eax, 4
    	mov ebx, 1
		mov edi, TabName
		add edi, esi
		mov ecx, edi   					 	; Adresse du début du tableau	
		mov edx, [NameSize] 			 	; Taille maximale de la saisie  
    	int 80h
		
		mov ebx, [PersonCount]
		cmp ebx, [indice]
		je _start

		inc dword [indice]
		add esi, [NameSize]
		jmp loop_Display

	jmp _start

DisplayPerson:
	; Print message3
	mov ecx, message3
	mov edx, longueur3
	int 80h
	
	mov eax, [PersonCount]
	mov ebx, 0
	cmp eax, ebx
	jle exeption31

	; Read input into number-----------------------------------
	mov eax, 3
	mov ebx, 0
	mov ecx, PersonID
	;mov edx ,3
	int 80h

	call _Convert_To_int
	call _Display_String
	jmp _start	
	
	exeption31:
		mov eax, 4
		mov ebx, 1
		mov ecx, ExeptionMsg3
		mov edx, LenExpMsg3
		int 80h
		jmp _start	
	
	exeption32:
		mov eax, 4
		mov ebx, 1
		mov ecx, ExeptionMsg2
		mov edx, LenExpMsg2
		int 80h
		jmp _start	

PlusJeune:
	; Print message4
	mov ecx, message4
	mov edx, longueur4
	int 80h

	mov eax, [PersonCount]				
	mov ebx, 0
	cmp eax, ebx							; Verifier si le tableau est vide
	jle exeption31
	mov ebx, 1
	cmp eax, ebx
	je Cas1									; Verifier si le tableau contient un seul element


	mov esi, 0
	call _CheckMin
	mov eax, [PlusJeuneID]
	mov [PersonID], eax
	call _Display_String

	
	jmp _start

	Cas1:									; Le cas ou le tableau contient un seul element
		mov eax, 0	
		mov [PersonID], eax
		call _Display_String
	jmp _start



Quitter:
	mov ecx, message5
	mov edx, longueur5
	int 80h

	mov eax, 1
	mov ebx, 0
	int 80h									; Quitter le programme

_ReadInput:
	xor edx, edx 
	mov esi, [PersonCount]
	mov edi, [PersonCount]
	; Lire le nom de la personne
	mov eax, 3								; syscall write
	mov ebx, 0								; syscall .....
	mov ecx, TabName						; pointer sur la premiere case du tableau
	imul esi, [NameSize]					; Multiplier le compteur par la taille de case
	add ecx, esi							; Deplacer vers la case libre du tableau
	mov edx, [NameSize] 					; Taille maximale de la saisie           
	int 80h									; interuption
	mov edx, esi 							; pointer sur la case actuelle
	
	xor ecx, ecx							; vider "ecx"
	xor eax, eax							; vider "eax"

	loop: 
		mov cl, [TabName + edx]				; stocker le premier caractere du nom dans "cl"
		inc edx	  							; incrementer edx
		cmp ecx, " "						; comparer avec le separateur espace (32)
		jne loop							; continuer boocle "loop"
		xor eax, eax						; vider "al"
		xor ecx, ecx

	loop_continue:
		mov cl, [TabName + edx]				; stocker le premier caracter de l'age dans "cl" 
		cmp cl, 10							; Cmp le caractere par 10 (newLine)
		je fin_loop							; Si Vrai fin du boucle
		call _Input_checker
		sub cl, 48							; Converter du Ascii vers entier
		add al, cl							; Ajouter la valeur presedent au valeur actuelle
		mov cl, 10							; Preparer à la mutiplication
		imul cl								; Multiplier l'age actuelle par 10
		inc edx								; Incrementer "edx"
		jmp loop_continue					; Continuer boucle "loop_continue"
	
	fin_loop:
		xor edx,edx							; Vider edx
		mov cl, 10							; Preprer à la division
		div cl		
		mov edx, edi
		mov ecx, 8
		imul edx, ecx						; Diviser l'age (int) par 10 
		mov [TabAge + edx], eax				; Ajouter l'age (int) dans la table TabAge
		
		call _ClearRegs						; Vider tous les registre
	
		mov eax, [PersonCount]				; stocker PersonCount dans "eax"
		mov edi, 10							; Donner la valeur 10 à "edi"
		call _int_to_string					; Appelle fonction int->string
		mov ecx, [int_string]				; stocker le resultat de int->string sur "ecx"
		mov [TabId + esi], ecx				; stocker 
	
		mov ebx, 0							; Vider edx 
		mov [int_string], ebx				; Vider in_string
		inc dword [PersonCount]				; Incrémente le compteur de personnes enregistrées
		ret

_ClearRegs:
	xor eax, eax							; Vider les registre
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	ret

_int_to_string:
	idiv edi                                ; Transformer un entier en chaine de character
	add edx, "0"
	push edx
	xor edx, edx
	inc ebx
	cmp eax, 0
	jne _int_to_string
	
	store_string:
		pop edx
		mov [int_string + ecx], edx
		inc ecx
		cmp ecx, ebx
		jne store_string
	add ecx, 1
	mov ebx, 32
	mov [int_string + ecx], ebx
	ret

_string_to_int:
	mov dl, [PersonID + ebx]				; Transformer une chaine de charactere en entier
	inc ebx
	cmp edx, 10
	jne _string_to_int

	mov ecx, ebx
	mov eax, 2
	sub ecx, eax
	dec ebx
	xor edx, edx
	
	Stackloop:
		mov dl, [PersonID + ecx]
		sub edx, "0"
		push edx
		xor edx, edx
		dec ecx
		cmp ecx, 0
		jge Stackloop
	
	xor ecx, ecx
	store_int:
		cmp ecx, ebx
		je store_fin
		pop edx
		add edx,[string_int]
		imul edx, 10
		mov [string_int], edx
		inc ecx
		jmp store_int

	store_fin:
		xor edx, edx
		mov ecx, 10
		mov eax, [string_int]
		div ecx
		mov [string_int], eax
	ret
	

_Convert_To_int:
	call _ClearRegs
	call _string_to_int						
	mov ebx, [string_int]
	mov [PersonID], ebx
	mov eax, 0
	mov [string_int], eax
	ret

_Display_String:
	mov eax, [PersonID] 
	cmp eax, [PersonCount]					; verifier si l'ID est valable
	jge exeption32

	imul eax, [NameSize]
	mov esi, eax

	mov eax, 4
	mov ebx, 1
	mov edi, TabId
	add edi, esi
	mov ecx, edi    						; Adresse du début du tableau	
	mov edx, [NameSize]						; Taille maximale de la saisie  
    int 80h
	
	mov eax, 4
    mov ebx, 1
	mov edi, TabName
	add edi, esi
	mov ecx, edi   					 		; Adresse du début du tableau	
	mov edx, [NameSize] 			 		; Taille maximale de la saisie  
    int 80h
	ret

_CheckMin:
	mov eax, esi							; Trouver l'Age min dans TabAge
	mov ebx, 8
	imul eax, ebx
	mov edx, dword [TabAge + eax]
	push edx
	xor edx, edx
	inc esi
	cmp esi, [PersonCount]
	jne _CheckMin

	pop edx
	mov [PlusJeuneAge],edx
	dec esi
	mov [PlusJeuneID], esi

	FinMin:
		cmp esi, 0
		je finMin
		dec esi
		mov eax, [PlusJeuneAge]
		pop edx
		cmp eax, edx
		jle FinMin
		mov [PlusJeuneAge], edx
		mov [PlusJeuneID], esi
		jmp FinMin
		finMin:
	ret

_Input_checker:
	cmp ecx, 48								; Verifier l'input de l'utilisateur
	jl NotSafe
	cmp ecx, 57
	jg NotSafe
	jmp Safe

	NotSafe:
		mov eax, 4
		mov ebx, 1
		mov ecx, InputErr
		mov edx, LenInErr
		int 80h
		mov eax, 0
		mov [TabName + esi], eax	
		call _ClearRegs
		jmp _start
	Safe:
		ret