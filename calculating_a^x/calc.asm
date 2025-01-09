section .data
e_value dd 2.718281828
; a^x = e^(xlna)
section .text
global _potega
	
_potega:
	push ebp
	mov ebp, esp
	
	finit
	
	fld dword [ebp + 8]  ;  a
  fld dword [ebp + 12] ;  x

  fld1                
	fld dword [e_value] ; ST(0) = e st(1) = 1
	
  fyl2x               ; ST(0) = log2(e)
	
	fld1 
	fld st3 ; ST(0) = a ST(1) = 1 ST(2) = log2(e) ST(3) = x ST(4) = a
  fyl2x
	; ST(0) = log2(a) ST(1) = log2(e) ST(2) = x 

	fdiv st1 ; ST(0) = (log2(a) / log2(e)) = ln(a) 
	; ST(1) =log2(e) ST(2) = x ST(3) = a
	fld st2
	; ST(0) = x ST(1) = ln(a)
	fmul st1 ; ST(0) = x * ln(a)

	fstp dword [ebp + 8]
	
	call taylor_series
	
	fld st2
	
	leave
	ret
	
taylor_series:
	
	finit
	
	fld dword [ebp+8]

	fld1
	fld1
	fld1
	fld1
	mov ecx, 60
	; taylor e^y=1+y+(y^2)/2!+(y^3)/3!+…. (y = xlna)
	my_loop:
		fmul st4 ; calculating (xlna)^n
		fdiv st1 ; dividing by n! 
		fld st1
		fadd st4 ; increasing n+1 
		fstp st2
		fld st2
		fadd st1 ; adding to the taylor series
		fstp st3 ; saving the result
	
		dec ecx
		cmp ecx, 0
		jne my_loop
	ret
	

