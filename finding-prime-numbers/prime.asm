section .data
    first_q db "Wprowadz minimalna wartosc przedzialu ('#' konczy program): $"
    second_q db "Wprowadz maksymalna wartosc przedzialu('#' konczy program): $"
    newline db 10, 13, 36
    prime_msg db "Liczby pierwsze w przedziale: $"
    not_a_number db "Prosze wprowadzic tylko cyfry.$"
	too_big db "Prosze wprowadzic liczbe 16-bitowa.$"
	range_error db "MInimalna wartosc musi byc mniejsza niz maksymalna.$"
    num1 dw 0            ; Przechowuje pierwsza liczbe
    num2 dw 0            ; Przechowuje druga liczbe
    input db 100         ; Bufor do przechowywania wprowadzonego tekstu
         db 0            

section .text
    org 100h
start:
	call get_input1
	call get_input2
	call prime_finder

exit_program:
    mov ax, 4C00h
    int 21h

;-------------procedury-------------

get_input1:
; dolny kres przedziału
    mov ah, 9
    mov dx, first_q
    int 21h
    call read_input
    mov [num1], ax   ; zapis dolnego zakresu
	ret
get_input2:
; górny kres przedziału
    mov ah, 9
    mov dx, second_q
    int 21h
    call read_input
    mov [num2], ax   ; zapis górnego zakresu
	
	xor bx, bx
	mov ax, [num1]
    mov bx, [num2]
	
	cmp ax, bx
    jae invalid_range  ; jeśli dolny zakres >= górny, to blad
	ret

; wczytywanie liczby
read_input:
    mov si, input ; wskaźnik do bufora
	xor cx, cx ; przygotowanie rejestrow
	xor ax, ax
	xor dx, dx
read_loop:
    mov ah, 1
    int 21h
	
    cmp al, '#'
    je exit_program

    cmp al, 13 ; Enter
    je process_input
	
	cmp al, 8         ; Backspace 
    je handle_backspace

    cmp al, '0'
    jb invalid_input

    cmp al, '9'
    ja invalid_input

    mov [si], al

    inc si
	inc cx
    jmp read_loop

handle_backspace:
    cmp cx, 0         ; sprawdza czy są jakieś znaki do usuniecia
    je read_loop      ; Jeśli nie, ignoruj Backspace

    dec si            ; cofanie wskaźnika w buforze
    dec cx            ; zmniejszenie zapisanej liczby znaków

    jmp read_loop    

process_input:
	cmp cx, 0
	je invalid_input

    mov byte [si], 0  ; koniec stringa w buforze

    mov si, input ; wskaźnik na poczatek bufora 

    mov bx, 10

    xor ax, ax

process_loop:
; tu nastepuje zamiana ciagu znakow na liczbe w systemie dziesietnym
	xor cx, cx
    mov cl, [si] ; zaladowanie znaku z bufora

    cmp cl, 0
    je end_processing

    mul bx  ; dx:ax = ax * bx
	cmp dx, 0 ; jesli dx > 0 to przepelnienie
	jne input_too_big

    sub cl, '0' ; zamiana z ascii na cyfre 0-9
	
	cmp ax, 65530
	je near_limit
	
continue_process_loop:
    add ax, cx ; ax = ax + cx

    inc si ; przesuniecie wskaźnika na kolejny znak

    jmp process_loop

end_processing:
	xor bx,bx
	xor dx, dx
	xor cx,cx
    ret ;zwracany wynik w ax

near_limit:
	cmp cl, 5 ; 65535 najwieksza liczba 16-bitowa
	jg input_too_big

    jmp continue_process_loop

invalid_input:
    mov ah, 9
    mov dx, newline
    int 21h

    mov ah, 9
    mov dx, not_a_number 
    int 21h

    mov ah, 9
    mov dx, newline
    int 21h

    jmp start
	
input_too_big:
	mov ah, 9
    mov dx, newline
    int 21h

	mov ah, 9
	mov dx, too_big
	int 21h
	
	mov ah, 9
    mov dx, newline
    int 21h
	
	jmp start

invalid_range:
	mov ah, 9
	mov dx, range_error
	int 21h
	
	mov ah, 9
    mov dx, newline
    int 21h
	
	jmp start



;------ wyszukiwanie liczb pierwszych ----------

; ax - num1 , bx - num2
prime_finder:
	push ax ; zapisanie wartosci ax na stosie

    mov ah, 9
    mov dx, prime_msg
    int 21h
	
	mov ah, 9
    mov dx, newline
    int 21h
	
	pop ax
	xor dx, dx
	
find_primes:
	mov cx, 2 ; przygotowanie dzielnika
	
	cmp ax, 1
	jbe next_number
	
	push ax
	
prime_loop:
	xor dx, dx
	
	cmp cx, ax ;sprawdzenie czy dzielnik nie jest rowny sprawdzanej liczbie
	je is_prime

	div cx ; ax = ax/cx  reszta w dx
	
	inc cx
	
	pop ax ; przywracanie pierwotnej wartosci ax
	push ax ; zapisanie wartosci ax na stosie
	
	cmp dx, 0 ;jesli podzielnia przez liczbe to nie jest liczba pierwsza
	jne prime_loop
	
next_number:
	cmp ax, 65535
	je start
	
	inc ax ; nastepna liczba z przedzialu
	
	cmp ax, bx ; sprawdzamy czy miesci sie w przedziale
	ja start
	
	jmp find_primes

is_prime:
	push ax

	call display_number

	mov ah, 9
    mov dx, newline
    int 21h
	
	pop ax

	jmp next_number



;--------- wypisywanie liczb ------------

; na wejsciu ax - liczba do wydrukowania
display_number:

	push ax
    push bx
    push cx
    push dx
	
	xor dx, dx
    mov bx, 10 
	xor cx, cx
convert:
; wrzucanie cyfr z liczby na stos
	div bx  ; ax = ax / 10, dx - reszta 
	
	push dx
	inc cx ; liczba cyfr
	xor dx, dx
	
	cmp ax, 0
	jne convert
	
	xor dx, dx
	
print_digits:
; zmiana zapisanych na stosie cyfr na kod ascii i wypisanie ich
	pop dx
	xor ax, ax

	add dl, '0'
	mov al, dl
	mov ah, 2
	int 21h
	
	loop print_digits
	
	pop dx
    pop cx
    pop bx
    pop ax

  	ret
	
