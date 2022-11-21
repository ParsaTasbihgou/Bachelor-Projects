%include "in_out.asm"
section .data
	input_format	db	"%s",	0
	output_format	db	"%s",	NL	0

	output_file_name	db	"dis_output.txt",	0

	test_command:	db	"mov rax rbx", 0
	test1:			db	"r12", 0

	debug_message:	db	"THIS is DEBUG message !!!!", 0

	sixty_seven		db	"67",	0
	sixty_six		db	"66", 	0
	sixty_four		db	"64",	0
	b_sixty_six		db	"01100110",	0
	b_sixty_seven	db	"01100111",	0
	eight			db	"08",	0
	sixteen			db	"16",	0
	thirty_two		db	"32",	0
	rex_pref		db	"0100",	0
	mod00			db	"00",	0
	mod01			db	"01",	0
	mod10			db	"10",	0
	mod11			db	"11",	0
	zero			db	"0",	0
	one				db	"1",	0
	two				db	"2",	0
	four			db	"4",	0
	eight8			db	"8",	0
	b_four			db	"100",	0
	b_five			db	"101",	0
	extended_opcode_prefix	db	"00001111",	0
	dollar_sign		db	"$",	0
	white_space		db	" ",	0
	comma			db	",",	0
	plus_sign		db	"+",	0
	mul_sign		db	"*",	0
	close_sign		db	"]",	0
	ptr_str			db	" ptr ",	0
	new_line		db	0xA,	0
	hex_num_sign	db	"0x",	0


	hex2bin_map	db "\
0:0000 \
1:0001 \
2:0010 \
3:0011 \
4:0100 \
5:0101 \
6:0110 \
7:0111 \
8:1000 \
9:1001 \
a:1010 \
b:1011 \
c:1100 \
d:1101 \
e:1110 \
f:1111 ", 0

	bin2hex_map	db "\
0000:0 \
0001:1 \
0010:2 \
0011:3 \
0100:4 \
0101:5 \
0110:6 \
0111:7 \
1000:8 \
1001:9 \
1010:a \
1011:b \
1100:c \
1101:d \
1110:e \
1111:f ", 0

	mem_data_size_map	db	"\
08:BYTE \
16:WORD \
32:DWORD \
64:QWORD ", 0

	bin2dec_map	db	"\
00:1 \
01:2 \
10:4 \
11:8 ", 0

	register_code_map	db	"\
08$000$0:al \
08$001$0:cl \
08$010$0:dl \
08$011$0:bl \
08$100$0:ah \
08$101$0:ch \
08$110$0:dh \
08$111$0:bh \
16$000$0:ax \
16$001$0:cx \
16$010$0:dx \
16$011$0:bx \
16$100$0:sp \
16$101$0:bp \
16$110$0:si \
16$111$0:di \
32$000$0:eax \
32$001$0:ecx \
32$010$0:edx \
32$011$0:ebx \
32$100$0:esp \
32$101$0:ebp \
32$110$0:esi \
32$111$0:edi \
64$000$0:rax \
64$001$0:rcx \
64$010$0:rdx \
64$011$0:rbx \
64$100$0:rsp \
64$101$0:rbp \
64$110$0:rsi \
64$111$0:rdi \
64$000$1:r8 \
64$001$1:r9 \
64$010$1:r10 \
64$011$1:r11 \
64$100$1:r12 \
64$101$1:r13 \
64$110$1:r14 \
64$111$1:r15 \
32$000$1:r8d \
32$001$1:r9d \
32$010$1:r10d \
32$011$1:r11d \
32$100$1:r12d \
32$101$1:r13d \
32$110$1:r14d \
32$111$1:r15d \
16$000$1:r8w \
16$001$1:r9w \
16$010$1:r10w \
16$011$1:r11w \
16$100$1:r12w \
16$101$1:r13w \
16$110$1:r14w \
16$111$1:r15w \
08$000$1:r8b \
08$001$1:r9b \
08$010$1:r10b \
08$011$1:r11b \
08$100$1:r12b \
08$101$1:r13b \
08$110$1:r14b \
08$111$1:r15b ", 0

	single_operand_opcode	db	"\
1111011: \
1111111: \
1000111: \
1111011: ", 0

    zero_operand_opcode	db "\
11111001:stc \
11111000:clc \
11111101:std \
11111100:cld \
0000111100000101:syscall \
11000011:ret ",0

	DW_in_opcode	db	"\
00001111101111 ", 0

	bp_registers	db	"\
rbp: \
ebp: \
bp: ",	0

	D_in_opcode	db	"\
100001 \
100001 ", 0

	shift_operand_opcode	db	"\
1101000:shr \
1101000:shl \
1100000:shr \
1100000:shl ",	0

	reverse_instruction_map	db	"\
00001111101011 \
0000111110111100 \
0000111110111101 ", 0

; 	single_operand_opcode_map	db	"\
; inc:1111111 \
; dec:1111111 \
; neg:1111011 \
; not:1111011 \
; idiv:1111011 \
; imul:1111011 \
; pop:01011 \
; push:01010 \
; shl:110100 \
; shr:110100 \
; call:11101000 ",0

	opcode_map	db	"\
100010:mov \
000000:add \
000100:adc \
00001111110000:xadd \
001010:sub \
000110:sbb \
001000:and \
000010:or \
001100:xor \
00001111101011:imul \
1000011:xchg \
1000010:test \
001110:cmp \
11111001:stc \
11111000:clc \
11111100:cld \
11111101:std \
11000011:ret \
0000111100000101:syscall \
1111011100:mul \
1111011111:idiv \
1111011101:imul \
1111011011:neg \
1111011010:not \
1111111000:inc \
1111111001:dec \
111101:imul \
1111111110:push \
1000111000:pop \
0000111110111100:bsf \
0000111110111101:bsr \
jmp8:11101011 \
jmp32:11101001 \
jcc8:0111 \
jcc32:000011111000 \
jmp:[11111111,100] \
call32:11101000 \
call:[11111111,010] ", 0

section .bss
	has_67:		resb	1
	has_66:		resb	1
	has_rex:	resb	1
	has_sib:	resb	1

	input_file_name:	resb	100
	input_file_disc:	resq	1
	output_file_disc:	resq	1
	input_command:	resb	1000
	output_command:	resb	1000
	instruction:	resb	1000

	b_input_command:	resb	1000

	operand_1:		resb 	1000
	operand_2:		resb 	1000

	operand_1_code:	resb 	100
	operand_2_code:	resb	100

	operand_1_size:	resb	100
	operand_2_size:	resb	100

	operand_1_is_mem:	resb	1
	operand_2_is_mem:	resb	1

	register_1_code		resb	10
	register_2_code		resb	10

	data_size:	resq	1

	rex:		resb	100
	rex_w:		resb	1
	rex_r:		resb	1
	rex_x:		resb	1
	rex_b:		resb	1

	prefix:		resb	10
	opcode:		resb	100
	opcode_D:	resb	10
	opcode_W:	resb	10
	mod:		resb	10
	reg_op:		resb	10
	r_m:		resb	10
	mem_data_size:	resb	10
	mem_address_size:	resb	10

	scale:		resb	10
	index_reg:		resb	10
	base_reg:		resb	10
	displacement:	resb	100
	displacement_len:	resq	1
	sib:		resb	10
	sib_ss:		resb	10
	sib_index:	resb	10
	sib_base:	resb	10
	sib_base_code:	resb	10
	sib_index_code:	resb	10
	sib_ss_code:	resb	10
	register_size:	resb	10

	index_reg_code:	resb	10
	base_reg_code:	resb	10

	output:		resb	1000
	hex_output:	resb	1000

	temp:		resb	1000
	stack:		resb	1000
	mem_address:	resb	1000
	mem_access:		resb	1000
	mem_operand:	resb	1000

	input_index:	resq	1
	imm_data:	resb	1000

section .text
	global		_main
	extern		_scanf
	extern		_printf
	extern		_fflush		
	extern		_opendir
	extern		_readdir
	extern		_closedir
	extern		_mkdir
	extern		_open
	default		rel

%macro movchar 3
	push 	r15
	push	r14

	mov		r15b,	byte[%3]
	xor		r14,	r14
	mov		r14,	%1
	add		r14,	%2
	mov		byte[r14],	r15b

	pop		r14
	pop		r15
%endmacro

%macro is_upper_case 1
	clc
	cmp		%1, "A"
	jl		%%is_upper_case_out
	cmp		%1, "Z"
	jg		%%is_upper_case_out
	stc
	%%is_upper_case_out:
%endmacro

%macro cmp_string 3
	stc
	push	rax
	push	rsi
	push	r15
	push	r14
	push	r13

	mov		r15,	-1
	mov		r13,	%1
	mov		r14,	%2

	%%cmp_string_for_1:
		inc		r15

		cmp		r15,	%3
		je		%%cmp_string_for_1_out

		cmp		byte[r13+r15],	0
		je 		%%cmp_string_for_1_out1
		cmp		byte[r14+r15],	0
		je		 %%cmp_string_for_1_out2
		cmp		byte[r13+r15],	" "
		je 		%%cmp_string_for_1_out1
		cmp		byte[r14+r15],	" "
		je		 %%cmp_string_for_1_out2
		cmp		byte[r13+r15],	":"
		je 		%%cmp_string_for_1_out1
		cmp		byte[r14+r15],	":"
		je		 %%cmp_string_for_1_out2

		mov		rax,	0
		mov		al,		byte[r13+r15]

		cmp		al,		byte[r14+r15]
		je		%%cmp_string_for_1
		clc
		jmp		%%cmp_string_for_1_out_neg
		
	%%cmp_string_for_1_out1:
		cmp		byte[r14+r15],	0
		je		 %%cmp_string_for_1_out
		cmp		byte[r14+r15],	" "
		je		 %%cmp_string_for_1_out
		cmp		byte[r14+r15],	":"
		je		 %%cmp_string_for_1_out
		clc
		jmp		%%cmp_string_for_1_out_neg

	%%cmp_string_for_1_out2:
		cmp		byte[r13+r15],	0
		je 		%%cmp_string_for_1_out
		cmp		byte[r13+r15],	" "
		je 		%%cmp_string_for_1_out
		cmp		byte[r13+r15],	":"
		je 		%%cmp_string_for_1_out
		clc
		jmp		%%cmp_string_for_1_out_neg

	%%cmp_string_for_1_out:
		stc
		
	%%cmp_string_for_1_out_neg:
	pop		r13
	pop		r14
	pop		r15
	pop		rsi
	pop		rax
%endmacro

%macro cmp_string 2
	cmp_string	%1,	%2,	1000	
%endmacro

%macro cp_string 2
	push	rcx
	push	r15
	push	r14

	mov		rcx,	0
	mov		r14,	%1
	mov		r15,	%2

	%%cp_string_for_1:
		cmp		byte[r15+rcx],	" "
		je		%%cmp_string_for_1_out
		cmp		byte[r15+rcx],	0
		je		%%cmp_string_for_1_out

		push	rax
		mov		al,		byte[r15+rcx]
		mov		byte[r14+rcx],		al
		pop		rax

		inc		rcx
		jmp		%%cp_string_for_1
	%%cmp_string_for_1_out:
		mov		byte[r14+rcx],	0

	pop		r14
	pop		r15
	pop		rcx
%endmacro

%macro cp_string2 2
	push	rcx
	push	r15
	push	r14

	mov		rcx,	0
	mov		r14,	%1
	mov		r15,	%2

	%%cp_string2_for_1:
		cmp		byte[r15+rcx],	0
		je		%%cmp_string2_for_1_out

		push	rax
		mov		al,		byte[r15+rcx]
		mov		byte[r14+rcx],		al
		pop		rax

		inc		rcx
		jmp		%%cp_string2_for_1
	%%cmp_string2_for_1_out:
		mov		byte[r14+rcx],	0

	pop		r14
	pop		r15
	pop		rcx
%endmacro

%macro cp_string 3
	push	rcx
	push	r15
	push	r14

	mov		rcx,	0
	mov		r14,	%1
	mov		r15,	%2

	%%cp_string_for_1:
		cmp		byte[r15+rcx],	" "
		je		%%cmp_string_for_1_out
		cmp		byte[r15+rcx],	0
		je		%%cmp_string_for_1_out
		cmp		rcx,	%3
		je		%%cmp_string_for_1_out

		push	rax
		mov		al,		byte[r15+rcx]
		mov		byte[r14+rcx],		al

		pop		rax

		inc		rcx
		jmp		%%cp_string_for_1
	%%cmp_string_for_1_out:
		mov		byte[r14+rcx],	0

	pop		r14
	pop		r15
	pop		rcx
%endmacro

%macro add_string 2
	push	rax
	push	rcx
	push	r15
	push	r14

	mov		rcx,	%1
	dec		rcx

	%%add_string_while_1:
		inc		rcx

		cmp		byte[rcx],	0
		jne		%%add_string_while_1
		mov		rsi,	rcx
		cp_string	rsi,	%2

	pop		r14
	pop		r15
	pop		rcx
	pop		rax
%endmacro

%macro add_string2 2
	push	rax
	push	rcx
	push	r15
	push	r14

	mov		rcx,	%1
	dec		rcx

	%%add_string2_while_1:
		inc		rcx

		cmp		byte[rcx],	0
		jne		%%add_string2_while_1
		mov		rsi,	rcx
		cp_string2	rsi,	%2

	pop		r14
	pop		r15
	pop		rcx
	pop		rax
%endmacro

%macro add_string 3
	push	rax
	push	rcx
	push	r15
	push	r14

	mov		rcx,	%1
	dec		rcx

	%%add_string_while_1:
		inc		rcx

		cmp		byte[rcx],	0
		jne		%%add_string_while_1
		mov		rsi,	rcx
		cp_string	rsi,	%2,		%3

	pop		r14
	pop		r15
	pop		rcx
	pop		rax
%endmacro

%macro deb_print 0
	push	rsi
	mov		rsi,	debug_message
	call	printString
	call	newLine
	pop		rsi
%endmacro

get_code:
	enter	0,0
	push	rcx
	push	rdx

	mov		rax,	-1
	mov		rcx,	0

	get_code_for_1:
		cmp		byte[rbx+rcx],	0
		je		get_code_for_1_out

		mov		rdx,	rbx
		add		rdx,	rcx

		get_code_while_1:
			cmp		byte[rbx+rcx],	" "
			je		get_code_while_1_out
			inc		rcx
			jmp		get_code_while_1
		get_code_while_1_out:
		inc		rcx

		cmp_string	rdx,	rsi
		jnc		get_code_for_1
		mov		rax,	rdx
		get_code_while_2:
			cmp		byte[rax],	":"
			je		get_code_while_2_out
			inc		rax
			jmp		get_code_while_2
		get_code_while_2_out:
			inc		rax

	get_code_for_1_out:

get_code_return:
	pop		rdx
	pop		rcx
	leave
	ret

get_code2:
	enter	0,0
	push	rcx
	push	rdx

	mov		rax,	-1
	mov		rcx,	0

	get_code2_for_1:
		cmp		byte[rbx+rcx],	0
		je		get_code2_for_1_out

		mov		rdx,	rbx
		add		rdx,	rcx

		get_code2_while_1:
			cmp		byte[rbx+rcx],	" "
			je		get_code2_while_1_out
			inc		rcx
			jmp		get_code2_while_1
		get_code2_while_1_out:
		inc		rcx

		cmp_string	rdx,	rsi,	rdi
		jnc		get_code2_for_1
		mov		rax,	rdx
		get_code2_while_2:
			cmp		byte[rax],	":"
			je		get_code2_while_2_out
			inc		rax
			jmp		get_code2_while_2
		get_code2_while_2_out:
			inc		rax

	get_code2_for_1_out:

get_code2_return:
	pop		rdx
	pop		rcx
	leave
	ret



bin2hex:
	enter 0, 0
	push	rcx
	push	rdx
	push	rbx

	mov		rcx,	0
	mov		rbx,	rax
	bin2hex_for_1:
		cmp		byte[rsi+rcx],	"0"
		je		bin2hex_continue

		cmp		byte[rsi+rcx],	"1"
		je		bin2hex_continue

		jmp  bin2hex_for_1_out

		bin2hex_continue:

		push	rsi
		push	rax
		push	rbx

		mov		rbx,	bin2hex_map
		lea		rsi,	[rsi+rcx]
		mov		rdi,	4
		call	get_code2
		pop		rbx
		mov		al,		byte[rax]
		mov		byte[rbx],	al
		pop		rax
		pop		rsi

		inc		rbx
		add		rcx,	4

		jmp		bin2hex_for_1

	bin2hex_for_1_out:
		mov		byte[rbx],	0

bin2hex_return:
	pop		rbx
	pop		rdx
	pop		rcx
	leave
	ret

hex2bin:
	enter 0, 0
	push	rcx
	push	rdx
	push	rbx

	mov		rcx,	0
	mov		rbx,	rax
	hex2bin_for_1:
		cmp		byte[rsi+rcx], 0
		je		hex2bin_for_1_out
		cmp		byte[rsi+rcx],	10
		je		hex2bin_for_1_out

		push	rsi
		push	rax
		push	rbx

		mov		rbx,	hex2bin_map
		lea		rsi,	[rsi+rcx]
		mov		rdi,	1
		call	get_code2

		pop		rbx
		add_string	rbx,	rax,	4
		
		pop		rax
		pop		rsi

		add		rbx,	4
		inc		rcx

		jmp		hex2bin_for_1

	hex2bin_for_1_out:
		mov		byte[rbx],	0

hex2bin_return:
	pop		rbx
	pop		rdx
	pop		rcx
	leave
	ret

dissect_prefix:
	enter	0, 0
	push	rcx

	mov		rax,	rsi
	mov		rcx,	0
	cmp		byte[rsi+rcx],	"6"
	jne		dissect_prefix_return

	inc		rcx

	cmp		byte[rsi+rcx],	"7"
	jne		skip_prefix_67
	mov		byte[has_67],	1
	inc		rcx
	cmp		byte[rsi+rcx],	"6"
	jne		dissect_prefix_return
	inc		rcx

	skip_prefix_67:

	cmp		byte[rsi+rcx],	"6"
	jne		dissect_prefix_return
	mov		byte[has_66],	1
	inc		rcx

dissect_prefix_return:
	add		rax,	rcx
	pop		rcx
	leave
	ret

dissect_rex:
	enter	0, 0
	push	rcx

	mov		rcx,	0

	cmp_string	rsi,	rex_pref,	4
	jnc		dissect_rex_return

	mov		byte[has_rex],	1

	mov		rcx,	4
	mov		al,		byte[rsi+rcx]
	mov		byte[rex_w],	al
	inc		rcx
	mov		al,		byte[rsi+rcx]
	mov		byte[rex_r],	al
	inc		rcx
	mov		al,		byte[rsi+rcx]
	mov		byte[rex_x],	al
	inc		rcx
	mov		al,		byte[rsi+rcx]
	mov		byte[rex_b],	al
	inc		rcx

dissect_rex_return:
	mov		rax,	rsi
	add		rax,	rcx	

	pop		rcx
	leave
	ret

make_mem_address:
	enter	0, 0
	push	rcx
	push	rsi
	mov		rsi,	temp
	mov		rcx,	0

	mov		byte[rsi+rcx],	"["
	inc		rcx
	mov		byte[rsi+rcx],	0

	;base
	cmp_string	mod,	mod00
	jnc		skip_rbp_base_with_mod00
	mov		rsi,	sib_base
	mov		rbx,	bp_registers
	call	get_code
	cmp		rax,	-1
	je		skip_rbp_base_with_mod00
	jmp		skip_make_mem_address_base

	skip_rbp_base_with_mod00:

	cmp		byte[sib_base],	0
	je		skip_make_mem_address_base
	add_string	temp,	sib_base

	cmp		byte[sib_index],	0
	je		make_mem_address_check_displacement
	add_string	temp,	plus_sign

	skip_make_mem_address_base:

	;index scalse
	cmp		byte[sib_index],	0
	je		skip_make_mem_address_index
	add_string	temp,	sib_index
	add_string	temp,	mul_sign
	add_string	temp,	sib_ss

	make_mem_address_check_displacement:
		cmp		byte[displacement],	0
		je		make_mem_address_return
		add_string	temp,	plus_sign

	skip_make_mem_address_index:
		cmp		byte[displacement],	0
		je		make_mem_address_return

		add_string	temp,	hex_num_sign
		add_string	temp,	displacement

make_mem_address_return:
	add_string	temp,	close_sign
	pop		rsi
	pop		rcx
	leave
	ret

make_mem_access:
	enter	0, 0
	push	rsi

	mov		byte[temp],	0

	cp_string	mem_data_size,	sixty_four
	cmp		byte[rex_w],	"1"
	je		skip_make_mem_access_mem_data_size
	cp_string	mem_data_size,	sixteen
	cmp		byte[has_66],	1
	je		skip_make_mem_access_mem_data_size
	cp_string	mem_data_size,	thirty_two
	cmp		byte[opcode_W],	"1"
	je		skip_make_mem_access_mem_data_size
	cp_string	mem_data_size,	eight

	skip_make_mem_access_mem_data_size:

	mov		rsi,	mem_data_size
	mov		rbx,	mem_data_size_map
	call	get_code

	cp_string	temp,	rax
	add_string2	temp,	ptr_str
	add_string	temp,	mem_address

make_mem_access_return:
	pop		rsi

	leave
	ret

getchar:
   push   rcx
   push   rdx
   push   rsi
   push   r11 
 
   sub    rsp, 1
   mov    rsi, rsp
   mov    rdx, 1
   mov    rax, sys_read
   syscall
   mov    al, [rsi]
   add    rsp, 1

   pop    r11
   pop    rsi
   pop    rdx
   pop    rcx
ret

write_string:
	;file discriptor in rdi
	;buffer in rsi
	;size in rdx
	;get len
	push	rsi

	push	rdi
	mov		rdi,	rsi
	call	GetStrlen
	pop		rdi

	;len in rdx
	pop		rsi

	mov		rax,	sys_write
	syscall
ret

make_displacement:
	enter	0, 0

	push	rcx
	push	rsi

	cmp		qword[displacement_len],	0
	je 		make_displacement_return

	push	rax
	mov		rax,	qword[displacement_len]
	mov		rcx,	4
	idiv		rcx
	mov		qword[displacement_len],	rax
	pop		rax

	mov		byte[temp],		0
	mov		byte[stack],	0
	mov		rcx,	0
	mov		rsi,	displacement
	make_displacement_for_1:
		cmp		rcx,	qword[displacement_len]
		je		make_displacement_for_1_out

		cp_string	stack,	temp
		mov			rsi,	displacement
		add			rsi,	rcx

		cp_string	temp,	rsi,	2
		add			rcx,	2
		add_string	temp,	stack
		mov			byte[stack],	0

		jmp		make_displacement_for_1

	make_displacement_for_1_out:

	cp_string	displacement,	temp

make_displacement_return:
	pop		rsi
	pop		rcx
	leave
	ret


_main:
	push	rbp

	;input file name
	lea		rdi,	[input_format]
	lea		rsi,	[input_file_name]
	mov		rax,	0
	call	_scanf

	;open input file
	lea		rdi,	[input_file_name]
	mov		rax,	sys_open
	mov		rsi,	O_RDWR
	mov		rdx,	0
	syscall
	mov		[input_file_disc],	rax;	file disciptor
	call	writeNum
	call	newLine

	;open output file
	mov		rdi,	output_file_name
	mov		rax,	sys_open
	mov		rsi,	O_RDWR
	or		rsi,	O_CREAT
	mov		rdx,	0q777
	syscall
	mov		[output_file_disc],	rax;	file disciptor
	call	writeNum
	call	newLine

	main_loop:

		mov		byte[b_input_command],	0
		mov		byte[has_66],	0
		mov		byte[has_67],	0
		mov		qword[input_index],	0
		mov		byte[opcode],	0
		mov		byte[opcode_D],	0
		mov		byte[opcode_W],	0
		mov		byte[operand_1],	0
		mov		byte[operand_2],	0
		mov		byte[instruction],	0
		mov		byte[output_command],	0
		mov		byte[has_sib],	0
		mov		byte[sib_ss],	0
		mov		byte[sib_index],	0
		mov		byte[sib_base],		0
		mov		byte[sib_ss_code],	0
		mov		byte[sib_index_code],	0
		mov		byte[sib_base_code],		0
		mov		byte[sib],	0
		mov		byte[displacement],	0
		mov		qword[displacement_len],	0
		mov		byte[mem_address_size],	0
		mov		byte[mem_data_size],	0
		mov		byte[mem_operand],		0
		mov		byte[mod],	0
		mov		byte[mod],	0
		mov		byte[reg_op],	0
		mov		byte[r_m],	0
		mov		byte[imm_data],	0

		; lea		rdi,	[input_format]
		; lea		rsi,	[input_command]
		; mov		rax,	0
		; call	_scanf

		mov		rcx,	0
		mov		rsi,	input_command
		main_input_while:
			; mov		rdi,	stdin
			mov		rdi,	[input_file_disc]
			call	getchar
			cmp		al,		10
			je		main_input_while_out
			cmp		al,		" "
			je		main_input_while_out

			cmp		al,		-1
			je		main_loop_out
			cmp		al,		0
			je		main_loop_out

			mov		byte[rsi+rcx],	al
			inc		rcx
			jmp		main_input_while
		main_input_while_out:
			mov		byte[rsi+rcx],	0

		cmp		byte[input_command],	0
		je		main_loop_out

		mov		rsi,	input_command
		call	printString
		call	newLine

		mov		rsi,	input_command
		mov		byte[temp],	0
		mov		rax,	temp
		call	bin2hex
		cp_string	input_command,	temp
		mov		byte[temp],	0

		mov		rsi,	input_command
		call	printString
		call	newLine

		mov		rsi,	input_command
		call	dissect_prefix
		mov		rsi,	rax
		mov		rax,	b_input_command
		call	hex2bin

		mov		byte[rex_w],	0
		mov		byte[rex_r],	"0"
		mov		byte[rex_x],	"0"
		mov		byte[rex_b],	"0"

		mov		rsi,	b_input_command
		call	dissect_rex
		mov		qword[input_index],	rax

		; mov		rsi,	qword[input_index]
		; call	printString
		; call	newLine

		;opcode
		mov		rax,	qword[input_index]
		
		cmp_string	rax,	extended_opcode_prefix,	8
		jne		skip_extended_opcode_prefix
		add_string	opcode,	extended_opcode_prefix
		add		rax,	8

		skip_extended_opcode_prefix:

		add_string	opcode,		rax,	6
		add		rax,	6
		add_string	opcode_D,	rax,	1
		inc		rax
		add_string	opcode_W,	rax,	1
		inc		rax
		mov		qword[input_index],		rax

		cp_string	temp,	opcode
		add_string	temp,	opcode_D
		add_string	temp,	opcode_W
		mov		rsi,	temp
		mov		rbx,	zero_operand_opcode
		call	get_code
		cmp		rax,	-1
		je		skip_zero_operand
		cp_string	opcode,	temp
		jmp		final

		skip_zero_operand:

		cp_string	temp,	opcode
		add_string	temp,	opcode_D
		mov		rsi,	temp
		mov		rbx,	shift_operand_opcode
		call	get_code
		cmp		rax,	-1
		je		skip_shift_instruction
		jmp		main_loop

		skip_shift_instruction:

		;MOD-REG/OP-R/M
		mov		rax,	qword[input_index]

		add_string	mod,	rax,	2
		add		rax,	2
		add_string	reg_op,	rax,	3
		add		rax,	3
		add_string	r_m,	rax,	3
		add		rax,	3

		mov		qword[input_index],		rax

		;register size
		cp_string	register_size,	thirty_two
		cmp		byte[has_66],	1
		jne		skip_reg_size_16
		cp_string	register_size,	sixteen

		skip_reg_size_16:

		cmp		byte[opcode_W],	"0"
		jne		skip_reg_size_08
		cp_string	register_size,	eight

		skip_reg_size_08:

		cmp		byte[rex_w],	"1"
		jne		skip_reg_size_64
		cp_string	register_size,	sixty_four

		skip_reg_size_64:

		cmp_string	mod,	mod11
		je		register_operand
		jmp		memory_operand

		register_operand:
			cp_string	temp,	opcode
			add_string	temp,	opcode_D

			mov		rsi,	temp

			mov		rsi,	temp
			mov		rbx,	single_operand_opcode
			call	get_code

			cmp		rax,	-1
			jne		single_register
			jmp		reg_reg

			single_register:
				add_string	opcode,	opcode_D,	1
				add_string	opcode,	reg_op

				mov		rsi,	opcode
				call	printString
				call	newLine

				cmp		byte[has_rex],	1
				je		single_register_has_rex
				jmp		single_register_no_rex

				single_register_has_rex:
					;first_opereand = register_code_map[register_size + "$" + RM + "$" + rex.B]
					cp_string	temp,	register_size,	2
					add_string	temp,	dollar_sign,	1
					add_string	temp,	r_m,			3
					add_string	temp,	dollar_sign,	1
					add_string	temp,	rex_b,			1

					mov		rsi,	temp
					mov		rbx,	register_code_map
					call	get_code
					cp_string		operand_1,	rax

					mov		rsi,	operand_1

				jmp		single_register_end

				single_register_no_rex:
					;first_opereand = register_code_map[register_size + "$" + RM + "$0"]
					cp_string	temp,	register_size,	2
					add_string	temp,	dollar_sign,	1
					add_string	temp,	r_m,			3
					add_string	temp,	dollar_sign,	1
					add_string	temp,	zero,			1

					mov		rsi,	temp
					mov		rbx,	register_code_map
					call	get_code
					cp_string		operand_1,	rax

					mov		rsi,	operand_1

				jmp		single_register_end

			single_register_end:
				jmp		register_operand_end

			reg_reg:
				cmp		byte[has_rex],	1
				je		reg_reg_has_rex
				jmp		reg_reg_no_rex

				reg_reg_has_rex:
					;first_opereand = register_code_map[register_size + "$" + RM + "$" + rex.B]
					;second_operand = register_code_map[register_size + "$" + REG + "$" + rex.R]

					cp_string	temp,	register_size,	2
					add_string	temp,	dollar_sign,	1
					add_string	temp,	r_m,			3
					add_string	temp,	dollar_sign,	1
					add_string	temp,	rex_b,			1

					mov		rsi,	temp
					mov		rbx,	register_code_map
					call	get_code
					cp_string		operand_1,	rax

					cp_string	temp,	register_size,	2
					add_string	temp,	dollar_sign,	1
					add_string	temp,	reg_op,			3
					add_string	temp,	dollar_sign,	1
					add_string	temp,	rex_r,			1

					mov		rsi,	temp
					mov		rbx,	register_code_map
					call	get_code
					cp_string		operand_2,	rax

					jmp		reg_reg_end

				reg_reg_no_rex:
					;first_opereand = register_code_map[register_size + "$" + RM + "$0"]
					;second_operand = register_code_map[register_size + "$" + REG + "$0"]

					cp_string	temp,	register_size,	2
					add_string	temp,	dollar_sign,	1
					add_string	temp,	r_m,			3
					add_string	temp,	dollar_sign,	1
					add_string	temp,	zero,			1

					mov		rsi,	temp
					mov		rbx,	register_code_map
					call	get_code
					cp_string		operand_1,	rax

					cp_string	temp,	register_size,	2
					add_string	temp,	dollar_sign,	1
					add_string	temp,	reg_op,			3
					add_string	temp,	dollar_sign,	1
					add_string	temp,	zero,			1

					mov		rsi,	temp
					mov		rbx,	register_code_map
					call	get_code
					cp_string		operand_2,	rax

					jmp		reg_reg_end

			reg_reg_end:
				mov		rsi,	opcode
				mov		rbx,	reverse_instruction_map
				call	get_code
				cmp		rax,	-1
				je		skip_reg_reg_operand_swap
				cp_string2	temp,	operand_1
				cp_string2	operand_1,	operand_2
				cp_string2	operand_2,	temp

				skip_reg_reg_operand_swap:

				jmp		register_operand_end

		register_operand_end:
			mov		rsi,	opcode
			mov		rbx,	DW_in_opcode
			call	get_code

			cmp		rax,	-1
			je		skip_dw_in_opcode
			add_string	opcode,		opcode_D
			add_string	opcode,		opcode_W

			skip_dw_in_opcode:

			mov		rsi,	opcode
			mov		rbx,	D_in_opcode
			call	get_code

			cmp		rax,	-1
			je		skip_d_in_opcode
			add_string	opcode,		opcode_D

			skip_d_in_opcode:

			;[imul,	bsr, bsf]

		jmp		final

		memory_operand:
			mov		rsi,	opcode
			mov		rbx,	DW_in_opcode
			call	get_code

			cmp		rax,	-1
			je		skip_memory_operand_dw_in_opcode
			add_string	opcode,		opcode_D
			add_string	opcode,		opcode_W

			skip_memory_operand_dw_in_opcode:

			cp_string	temp,	sixty_four
			cmp		byte[has_67],	1
			jne		skip_memory_operand_address_base_32_bit2
			cp_string	temp,	thirty_two

			skip_memory_operand_address_base_32_bit2:

			add_string	temp,	dollar_sign
			add_string	temp,	r_m
			add_string	temp,	dollar_sign
			add_string	temp,	rex_b,	1

			mov		rsi,	temp
			mov		rbx,	register_code_map
			call	get_code
			cp_string	sib_base,	rax,	3

			cmp_string r_m,	b_four
			jnc		skip_memory_operand_sib
			mov		byte[has_sib],	1

			;sib ss
			cp_string	sib_ss_code,	qword[input_index],	2
			add		qword[input_index],	2

			;sib index
			cp_string	sib_index_code,	qword[input_index],	3
			add		qword[input_index],	3

			;sib base
			cp_string	sib_base_code,	qword[input_index],	3
			add		qword[input_index],	3

			;sib scale
			mov		rsi,	sib_ss_code
			mov		rbx,	bin2dec_map
			call	get_code
			cp_string	sib_ss,	rax,	1

			;sib index
			cp_string	temp,	sixty_four
			cmp		byte[has_67],	1
			jne		skip_memory_operand_address_index_32_bit
			cp_string	temp,	thirty_two

			skip_memory_operand_address_index_32_bit:

			add_string	temp,	dollar_sign
			add_string	temp,	sib_index_code
			add_string	temp,	dollar_sign
			add_string	temp,	rex_x,	1

			mov		rsi,	temp
			mov		rbx,	register_code_map
			call	get_code
			cp_string	sib_index,	rax,	3

			;sib base
			cp_string	temp,	sixty_four
			cmp		byte[has_67],	1
			jne		skip_memory_operand_address_base_32_bit
			cp_string	temp,	thirty_two

			skip_memory_operand_address_base_32_bit:

			add_string	temp,	dollar_sign
			add_string	temp,	sib_base_code
			add_string	temp,	dollar_sign
			add_string	temp,	rex_b,	1

			mov		rsi,	temp
			mov		rbx,	register_code_map
			call	get_code
			cp_string	sib_base,	rax,	3

			skip_memory_operand_sib:

			;displacement
			mov		rax,	qword[input_index]

			;0 displacement
			cmp_string	mod,	mod00
			jnc		skip_mod_00

			cp_string	imm_data,	rax
			mov		byte[displacement],	0
			mov		qword[displacement],	0

			jmp		skip_get_displacement
			skip_mod_00:

			;8 bit displacement
			cmp_string	mod,	mod01
			jnc		skip_mod_01

			cp_string	displacement,	rax,	8
			mov		qword[displacement_len],	8
			add		rax,	8

			cp_string	imm_data,	rax

			jmp		skip_get_displacement
			skip_mod_01:

			;32 bit displacement
			cmp_string	mod,	mod10
			jnc		skip_mod_10

			cp_string	displacement,	rax,	32
			mov		qword[displacement_len],	32
			add		rax,	32

			cp_string	imm_data,	rax

			jmp		skip_get_displacement
			skip_mod_10:

			skip_get_displacement:

			cmp		qword[displacement_len],	0
			je		skip_set_displacement

			mov		rsi,	displacement
			mov		byte[temp],	0
			mov		rax,	temp
			call	bin2hex

			; mov		rsi,	temp
			; call	printString
			; call	newLine

			cp_string	displacement,	temp
			mov		rsi,	displacement
			call	make_displacement

			; mov		rsi,	displacement
			; call	printString
			; call	newLine

			skip_set_displacement:

			call	make_mem_address
			cp_string2	mem_address,	temp

			call	make_mem_access
			cp_string2	mem_operand,	temp

			cp_string	temp,	opcode
			add_string	temp,	opcode_D
			mov		rsi,	temp
			mov		rbx,	single_operand_opcode
			call	get_code
			cmp		rax,	-1
			jne		single_memory_operand
			jmp		reg_mem

			single_memory_operand:
				;opcode
				add_string	opcode,		opcode_D,	1
				add_string	opcode,		reg_op

				;operand
				cp_string2	operand_1,	mem_operand
				mov		byte[operand_2],	0
			jmp		memory_operand_end

			reg_mem:
				;operand 2
				cp_string2	operand_2,	mem_operand

				;operand 1
				cp_string	temp,	mem_data_size
				add_string	temp,	dollar_sign,	1
				add_string	temp,	reg_op,			3
				add_string	temp,	dollar_sign,	1
				add_string	temp,	rex_r,			1

				mov		rsi,	temp
				mov		rbx,	register_code_map
				call	get_code
				cp_string	operand_1,	rax

				cmp		byte[opcode_D],		"0"
				jne		skip_reg_mem_operand_swap
				cp_string2	temp,	operand_1
				cp_string2	operand_1,	operand_2
				cp_string2	operand_2,	temp

				skip_reg_mem_operand_swap:

				mov		rsi,	opcode
				mov		rbx,	reverse_instruction_map
				call	get_code
				cmp		rax,	-1
				je		skip_reg_mem_operand_swap2
				cp_string2	temp,	operand_1
				cp_string2	operand_1,	operand_2
				cp_string2	operand_2,	temp

				skip_reg_mem_operand_swap2:

			jmp	memory_operand_end

		memory_operand_end:
		jmp		final

	final:
		;instruction
		mov		rsi,	opcode
		mov		rbx,	opcode_map
		call	get_code
		cp_string	instruction,	rax
		cp_string	output_command,	instruction

		;operand 1
		cmp		byte[operand_1],	0
		je		skip_operand_1
		
		add_string2		output_command,	white_space
		add_string2		output_command,	operand_1

		skip_operand_1:

		cmp		byte[operand_2],	0
		je		skip_operand_2

		add_string	output_command,	comma
		add_string2	output_command,	operand_2

		skip_operand_2:

		; lea		rdi,	[output_format]
		; lea		rsi,	[output_command]
		; mov		rax,	0
		; call	_printf

		; mov		rsi,	output_command
		; call	printString
		; call	newLine

		mov		rsi,	output_command
		mov		rdi,	[output_file_disc]
		call	write_string

		mov		rsi,	new_line
		mov		rdi,	[output_file_disc]
		call	write_string

	jmp		main_loop

	main_loop_out:
	mov		rax,	sys_close
	mov		rdi,	[input_file_disc]
	syscall

	mov		rax,	sys_close
	mov		rdi,	[output_file_disc]
	syscall


	jmp  	Exit

Exit:
	pop		rbp
	mov		rax,	sys_exit
	mov		rbx,	0
	syscall