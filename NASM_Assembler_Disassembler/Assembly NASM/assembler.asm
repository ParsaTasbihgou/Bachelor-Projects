%include "in_out.asm"
section .data

	input_format	db	"%s", 0
	input_size		dq	1000

	output_file_name	db	"output.txt",	0
	bin_out_file_name	db	"bin_out.txt",	0

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
	white_space		db	" ",	0
	new_line		db	0xA,	0
	str_imul		db	"imul",	0
	imul_reg_reg_opcode	db	"0000111110101111",	0
	imul_single_operand_opcode	db	"1111011",	0
	str_bp			db	"bp",	0
	hex_00			db	"00000000",	0
	hex_8_0			db	"00000000000000000000000000000000",	0


mem_size_map db "\
BYTE:08 \
WORD:16 \
DWORD:32 \
QWORD:64 ", 0

	dec2bin	db	"\
1:00 \
2:01 \
4:10 \
8:11 ", 0

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

	bp_registers	db	"\
rbp: \
ebp: \
bp: ",	0

;register codes
	register_code_map db "\
rax:0000$64 \
rcx:0001$64 \
rdx:0010$64 \
rbx:0011$64 \
rsp:0100$64 \
rbp:0101$64 \
rsi:0110$64 \
rdi:0111$64 \
eax:0000$32 \
ecx:0001$32 \
edx:0010$32 \
ebx:0011$32 \
esp:0100$32 \
ebp:0101$32 \
esi:0110$32 \
edi:0111$32 \
ax:0000$16 \
cx:0001$16 \
dx:0010$16 \
bx:0011$16 \
sp:0100$16 \
bp:0101$16 \
si:0110$16 \
di:0111$16 \
al:0000$08 \
cl:0001$08 \
dl:0010$08 \
bl:0011$08 \
ah:0100$08 \
ch:0101$08 \
dh:0110$08 \
bh:0111$08 \
r8:1000$64 \
r9:1001$64 \
r10:1010$64 \
r11:1011$64 \
r12:1100$64 \
r13:1101$64 \
r14:1110$64 \
r15:1111$64 \
r8d:1000$32 \
r9d:1001%32 \
r10d:1010%32 \
r11d:1011%32 \
r12d:1100%32 \
r13d:1101%32 \
r14d:1110%32 \
r15d:1111%32 \
r8w:1000$16 \
r9w:1001$16 \
r10w:1010$16 \
r11w:1011$16 \
r12w:1100$16 \
r13w:1101$16 \
r14w:1110$16 \
r15w:1111$16 \
r8b:1000$08 \
r9b:1001$08 \
r10b:1010$08 \
r11b:1011$08 \
r12b:1100$08 \
r13b:1101$08 \
r14b:1110$08 \
r15b:1111$08 ", 0

;opcodes
    reg_reg_opcode_map db "\
mov:1000100 \
add:0000000 \
adc:0001000 \
sub:0010100 \
sbb:0001100 \
and:0010000 \
or:0000100 \
xor:0011000 \
cmp:0011100 \
test:1000010 \
xchg:1000011 \
xadd:000011111100000 \
imul:0000111110101111 \
bsf:0000111110111100 \
bsr:0000111110111101 ",0

	DW_in_opcode	db	"\
0000111110101111: \
0000111110111100: \
0000111110111101: ",	0

	reg_opcode_map	db	"\
inc:1111111 \
dec:1111111 \
neg:1111011 \
not:1111011 \
idiv:1111011 \
imul:1111011 \
pop:01011 \
push:01010 \
shl:1101000 \
shr:1101000 \
call:11101000 ",0

	shift_operand_opcode	db	"\
shr:1101000 \
shl:1101000 ",	0

	shift_operand_reg_op	db	"\
shr:101 \
shl:100 ",	0

	shift_operand_displacement_opcode	db	"\
shr:1100000 \
shl:1100000 ",	0

    zero_operand_opcode	db "\
stc:11111001 \
clc:11111000 \
std:11111101 \
cld:11111100 \
syscall:0000111100000101 \
ret:11000011 ",0

	reg_reg_op_map	db	"\
idiv:111 \
imul:101 \
inc:000 \
dec:001 \
push:110 \
pop:000 \
neg:011 \
not:010 \
jmp:100 \
call:010 \
shl:100 \
shr:101 ", 0

	D_in_opcode	db	"\
000011111100000 ", 0

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

    reg_mem_opcode_map db "\
mov:100010 \
add:000000 \
adc:000100 \
sub:001010 \
sbb:000110 \
and:001000 \
or:000010 \
xor:001100 \
cmp:001110 \
test:1000010 \
xchg:1000011 \
xadd:000011111100000 \
imul:0000111110101111 \
bsf:0000111110111100 \
bsr:0000111110111101 ",0

section .bss
	input_file_name:	resb	100
	input_file_disc:	resq	1
	output_file_disc:	resq	1
	bin_out_file_disc:	resq	1

	input_command_ptr:	resq	1
	input_command:	resb	1000
	instruction:	resb	1000
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

	has_rex:	resb	1

	rex:		resb	100
	rex_w:		resb	1
	rex_r:		resb	1
	rex_x:		resb	1
	rex_b:		resb	1

	prefix:		resb	100
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

	index_reg_code:	resb	10
	base_reg_code:	resb	10

	output:		resb	1000
	hex_output:	resb	1000

	temp:		resb	1000
	stack:		resb	1000
	buffer:		resb	100
	bin_displacement:	resb 100

	is_reversed:	resb	1

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
	extern		_getline
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

%macro set_all_zero 0
	mov		byte[bin_displacement],	0
	mov		byte[input_command_ptr],	0
	mov		byte[input_command],				0
	mov		byte[instruction],				0
	mov		byte[operand_1],						0
	mov		byte[operand_2],						0
	mov		byte[operand_1_code],				0
	mov		byte[operand_2_code],			0
	mov		byte[operand_1_size],			0
	mov		byte[operand_2_size],			0
	mov		byte[operand_1_is_mem],	0
	mov		byte[operand_2_is_mem],	0
	mov		byte[register_1_code],		0
	mov		byte[register_2_code],		0
	mov		byte[data_size],	0
	mov		byte[has_rex],	0
	mov		byte[rex],				0
	mov		byte[rex_w],		0
	mov		byte[rex_r],		0
	mov		byte[rex_x],		0
	mov		byte[rex_b],		0
	mov		byte[prefix],				0
	mov		byte[opcode],				0
	mov		byte[opcode_D],		0
	mov		byte[opcode_W],		0
	mov		byte[mod],			0
	mov		byte[reg_op],			0
	mov		byte[r_m],			0
	mov		byte[mem_data_size],		0
	mov		byte[mem_address_size],		0
	mov		byte[scale],			0
	mov		byte[index_reg],			0
	mov		byte[base_reg],			0
	mov		byte[displacement],			0
	mov		byte[displacement_len],	0
	mov		byte[sib],			0
	mov		byte[sib_ss],			0
	mov		byte[sib_index],		0
	mov		byte[sib_base],		0
	mov		byte[index_reg_code],		0
	mov		byte[base_reg_code],		0
	mov		byte[output],					0
	mov		byte[hex_output],				0
	mov		byte[temp],					0
	mov		byte[stack],					0
	mov		byte[buffer],				0
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

get_register_code:
	enter	0,0
	push	rbx
	push	rsi

	mov		rbx,	register_code_map
	call	get_code

get_register_code_return:
	pop		rsi
	pop		rbx
	leave
	ret

get_reg_reg_opcode:
	enter	0,0
	push	rbx
	push	rsi

	mov		rbx,	reg_reg_opcode_map
	call	get_code

get_reg_reg_opcode_return:
	pop		rsi
	pop		rbx
	leave
	ret

dissect_command:
	enter 	0,0

	mov 	rcx,	input_command
	xor		rdx,	rdx

	dissect_command_for_1:
		cmp		byte[rcx], " "
		je 		dissect_command_for_1_out
		cmp		byte[rcx],	0
		je		dissect_command_return

		movchar	instruction,	rdx,	rcx
		inc		rdx
		inc		rcx
		
		jmp		dissect_command_for_1

	dissect_command_for_1_out:

	inc		rcx
	is_upper_case	byte[rcx]
	jnc		operand_1_is_not_mem
	mov		byte[operand_1_is_mem],	1
	operand_1_is_not_mem:

	xor		rdx,	rdx
	dissect_command_for_2:
		cmp		byte[rcx],	","
		je		dissect_command_for_2_out
		cmp		byte[rcx],	0
		je		dissect_command_return
		cmp		byte[rcx],	10
		je		dissect_command_return

		movchar	operand_1,	rdx,	rcx

		inc		rcx
		inc		rdx

		jmp		dissect_command_for_2
	dissect_command_for_2_out:

	inc		rcx
	is_upper_case	byte[rcx]
	jnc		operand_2_is_not_mem
	mov		byte[operand_2_is_mem], 1
	operand_2_is_not_mem:

	xor		rdx,	rdx
	dissect_command_for_3:
		cmp		byte[rcx], 	0
		je		dissect_command_return
		cmp		byte[rcx],	10
		je		dissect_command_return

		movchar	operand_2,	rdx,	rcx

		inc		rcx
		inc		rdx

		jmp		dissect_command_for_3


dissect_command_return:
	leave
	ret

is_new_register:
	enter	0, 0
	push	rax

	mov		rax,	rsi
	cmp		byte[rax],	"r"
	jne		is_new_register_neg
	inc		rax
	cmp		byte[rax],	"0"
	jb		is_new_register_neg
	cmp		byte[rax],	"9"
	ja		is_new_register_neg

	stc
	jmp		is_new_register_return

	is_new_register_neg:
		clc
		jmp		is_new_register_return

is_new_register_return:
	pop		rax
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

get_mem_data_size:
	enter	0, 0
	push	rbx

	mov		rbx,	mem_size_map
	;mov	rsi,	rsi
	call	get_code

get_mem_data_size_return:
	pop		rbx
	leave
	ret

dissect_mem_access:
	enter	0, 0
	push	rax
	push	rbx
	push	rcx
	push	rdx

	mov		rcx,	0
	dissect_mem_access_for_1:
		cmp		byte[rsi+rcx],	" "
		je		dissect_mem_access_for_1_out
		inc		rcx
		jmp		dissect_mem_access_for_1

	dissect_mem_access_for_1_out:
		inc		rcx
	dissect_mem_access_for_2:
		cmp		byte[rsi+rcx],	" "
		je 		dissect_mem_access_for_2_out
		inc		rcx
		jmp		dissect_mem_access_for_2

	dissect_mem_access_for_2_out:
	add		rcx,	2

	dissect_mem_access_top:

	;displacement
	cmp		byte[rsi+rcx],	"0"
	jne 	skip_displacement_1
	add		rcx,	2
	mov		qword[displacement_len],	0

	dissect_mem_access_for_3:
		cmp		byte[rsi+rcx],	"]"
		je		dissect_mem_access_for_3_out
		lea		rdx,	[rsi+rcx]
		movchar	displacement,	qword[displacement_len],	rdx
		inc		rcx
		inc		qword[displacement_len]

		; push	rsi
		; add		rsi,	rcx
		; call	printString
		; call	newLine
		; pop		rsi

		jmp	dissect_mem_access_for_3

	dissect_mem_access_for_3_out:
		mov		rdx,	displacement
		add		rdx,	qword[displacement_len]
		mov		byte[rdx],	0
		jmp		dissect_mem_access_return

	skip_displacement_1:

	mov		rax,	0
	mov		qword[temp],	0
	dissect_mem_access_for_4:
		cmp		byte[rsi+rcx],	"+"
		je		dissect_mem_access_base

		cmp		byte[rsi+rcx],	"]"
		je		dissect_mem_access_base

		cmp		byte[rsi+rcx],	"*"
		je		dissect_mem_access_index

		lea		rdx,	[rsi+rcx]
		movchar	temp,	rax,	rdx

		inc		rax
		inc		rcx
		jmp		dissect_mem_access_for_4

	dissect_mem_access_base:
		mov		rdx,	temp
		add		rdx,	rax
		mov		byte[rdx],	0

		cp_string	base_reg,	temp
		mov		rax,	0

		lea		rdx,	[rsi+rcx]
		inc		rcx

		cmp		byte[rdx],	"]"
		je		dissect_mem_access_return

		cmp		byte[rdx],	"+"
		je		dissect_mem_access_top

	dissect_mem_access_index:
		mov		rdx,	temp
		add		rdx,	rax
		mov		byte[rdx],	0
		cp_string	index_reg,	temp
		inc		rcx
		mov		al,	 byte[rsi+rcx]
		mov		byte[scale],	al

		lea		rdx,	[rsi+rcx+1]
		add		rcx,	2;	skip scale and sign

		cmp		byte[rdx],	"]"
		je		dissect_mem_access_return

		mov		qword[displacement_len],	0
		mov		rax,	0
		mov		qword[temp],	0
		cmp		byte[rdx],	"+"
		je		dissect_mem_access_top



dissect_mem_access_return:
	cmp		byte[base_reg],		0
	jne		set_mem_address_size1
	jmp		skip_set_mem_address_size1

	set_mem_address_size1:
		mov		rsi,	base_reg

		call	get_register_code
		mov		edx,	dword[rax]
		mov		dword[base_reg_code],	edx

		add		rax,	5
		mov		ax,		word[rax]
		mov		word[mem_address_size],		ax

	skip_set_mem_address_size1:
	cmp		byte[index_reg],	0
	jne		set_mem_address_size2
	jmp		skip_set_mem_address_size

	set_mem_address_size2:
		mov		rsi,	index_reg
		mov		rbx,	register_code_map
		call	get_code
		mov		edx,	dword[rax]
		mov		dword[index_reg_code],	edx
		add		rax,	5
		mov		ax,		word[rax]
		mov		word[mem_address_size],		ax

		jmp		skip_set_mem_address_size

	skip_set_mem_address_size:

	pop		rdx
	pop		rcx
	pop		rbx
	pop		rax
	leave
	ret

make_displacement:
	enter	0, 0

	push	rcx
	push	rsi

	mov		byte[bin_displacement],	0
	cmp		qword[displacement_len],	0
	je 		make_displacement_return

	cmp		qword[displacement_len],	8
	je		skip_32bit_padding

	mov		rcx,	8

	cmp		qword[displacement_len],	2
	jg		skip_make_displacement_8_bit
	mov		rcx,	2

	skip_make_displacement_8_bit:

	sub		rcx,	qword[displacement_len]
	mov		byte[temp],		0
	mov		qword[displacement_len],	8
	make_displacement_while:
		cmp		rcx,	0
		je		make_displacement_while_out

		cp_string	temp,	displacement
		cp_string	displacement,	zero
		add_string	displacement,	temp
		mov		byte[temp],		0

		dec		rcx
		jmp		make_displacement_while

	make_displacement_while_out:

	skip_32bit_padding:

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

	mov		rsi,	temp
	mov		byte[displacement],	0
	mov		rax,	displacement
	call	hex2bin

make_displacement_return:
	pop		rsi
	pop		rcx
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

_main:
	push	rbp

	;input file name
	lea		rdi,	[input_format]
	lea		rsi,	[input_file_name]
	mov		rax,	0
	call	_scanf

	mov		rsi,	input_file_name
	call	printString
	call	newLine

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

	;open binary output file
	mov		rdi,	bin_out_file_name
	mov		rax,	sys_open
	mov		rsi,	O_RDWR
	or		rsi,	O_CREAT
	mov		rdx,	0q777
	syscall
	mov		[bin_out_file_disc],	rax;	file disciptor
	call	writeNum
	call	newLine

	main_loop:
		mov		qword[output],	0
		mov		byte[prefix],	0
		mov		byte[rex],		0
		mov		byte[sib],		0

		mov		byte[scale],	0
		mov		byte[index_reg],	0
		mov		byte[base_reg],		0
		mov		byte[displacement],	0
		mov		byte[mem_address_size],	32

		mov		byte[has_rex],		0
		mov		byte[hex_output],	0
		mov		byte[is_reversed],	0

		set_all_zero

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
		mov		rbx,	zero_operand_opcode
		call	get_code
		cmp		rax,	-1
		je		skip_zero_operand_command
		cp_string	output,		rax
		jmp		final
		
		skip_zero_operand_command:

		mov		qword[instruction],	0
		mov		qword[operand_1],	0
		mov		qword[operand_2],	0
		mov		byte[operand_1_is_mem],	0
		mov		byte[operand_2_is_mem],	0

		call	dissect_command

		cmp		byte[operand_1_is_mem], 0
		je		operand_1_is_reg
		jmp		operand_1_is_memory

		cmp		byte[operand_2_is_mem], 0
		je		operand_2_is_reg

		operand_1_is_memory:
			cmp		byte[operand_2],	0
			je		single_memory

			cmp		byte[operand_2],	"1"
			je		single_memory

			cmp		byte[operand_2],	"0"
			jne		skip_hex_imm_data
			mov		rax,	operand_2
			add		rax,	2
			cp_string	displacement,	rax

			mov		rsi,	displacement
			mov		rax,	temp
			call	hex2bin
			cp_string	displacement,	temp
			mov		rsi,	displacement

			call	make_displacement

			mov		rsi,	displacement
			mov		qword[displacement_len],	0
			jmp		single_memory

			skip_hex_imm_data:

			;swap operands and set opcode D
			mov		byte[is_reversed],	1
			cp_string2	temp,	operand_1
			cp_string2	operand_1,	operand_2
			cp_string2	operand_2,	temp
			mov		byte[temp],	0

			mov		rsi,	operand_1
			call	get_register_code

			cp_string	operand_1_code,	rax

			mov		eax,	dword[operand_1_code]
			mov		dword[register_1_code],		eax

			mov		rax,	operand_1_code
			add		rax,	5
			mov		bx,		word[rax]
			mov		word[operand_1_size],	bx

			jmp		register_memory	

			; jmp		final

		operand_1_is_reg:
			mov		rsi,	operand_1
			call	get_register_code

			cp_string	operand_1_code,	rax

			mov		eax,	dword[operand_1_code]
			mov		dword[register_1_code],		eax

			mov		rax,	operand_1_code
			add		rax,	5
			mov		bx,		word[rax]
			mov		word[operand_1_size],	bx

			cmp		byte[operand_2],	0
			je		single_register

			cmp		byte[operand_2],	"1"
			je		single_register
			cmp		byte[operand_2],	"0"
			jne		skip_hex_imm_data2
			mov		rax,	operand_2
			add		rax,	2
			cp_string	displacement,	rax

			mov		rsi,	displacement
			mov		rax,	temp
			call	hex2bin
			cp_string	displacement,	temp
			mov		rsi,	displacement

			call	make_displacement

			mov		rsi,	displacement
			mov		qword[displacement_len],	0
			jmp		single_register

			skip_hex_imm_data2:

			cmp		byte[operand_2_is_mem],	0
			je		both_operand_reg

			cmp		byte[operand_2_is_mem],	1
			je		register_memory

		operand_2_is_reg:
			mov		rsi,	operand_2
			call	get_register_code
			cp_string	operand_2_code,		rax

			mov		eax,	dword[operand_2_code]
			mov		dword[register_2_code],		eax

			mov		rax,	operand_2_code
			add		rax,	5
			mov		bx,		word[rax]
			mov		word[operand_2_size],	bx

		single_register:
			;rex
			mov		rsi,	operand_1
			call	is_new_register
			jnc		skip_single_register_is_new
			mov		byte[has_rex],	1

			skip_single_register_is_new:

			cmp_string	operand_1_size,	sixty_four
			jnc		skip_single_register_is_64_bit
			mov		byte[has_rex],	1
			mov		byte[rex_w],	"1"

			skip_single_register_is_64_bit:

			;prefix
			cmp_string	operand_1_size,	sixteen
			jnc		skip_single_register_pref_66
			add_string	prefix,		b_sixty_six

			skip_single_register_pref_66:

			;opcode
			mov		rsi,	instruction
			mov		rbx,	reg_opcode_map
			call	get_code
			cp_string	opcode,	rax

			;opcode w
			mov		byte[opcode_W],	"1"
			cmp_string	operand_1_size,	eight
			jnc		skip_single_register_is_8_bit
			mov		byte[opcode_W],	"0"

			skip_single_register_is_8_bit:

			;REG/OP
			mov		rsi,	instruction
			mov		rbx,	reg_reg_op_map
			call	get_code
			cp_string	reg_op,	rax

			;mod
			cp_string	mod,	mod11

			;R/M
			mov		rax,	operand_1_code
			inc		rax
			cp_string	r_m,	rax,	3

			;rex
			cmp		byte[has_rex],	1
			jne		skip_single_register_rex
			mov		byte[rex_w],	"0"
			cmp_string	operand_1_size,	sixty_four
			jnc		skip_single_register_rex_64_bit
			mov		byte[rex_w],	"1"

			skip_single_register_rex_64_bit:

			mov		byte[rex_r],	"0"
			mov		byte[rex_x],	"0"
			mov		al,		byte[operand_1_code]
			mov		byte[rex_b],	al

			add_string	rex,	rex_pref,	4
			add_string	rex,	rex_w,	1
			add_string	rex,	rex_r,	1
			add_string	rex,	rex_x,	1
			add_string	rex,	rex_b,	1

			skip_single_register_rex:

			mov		rsi,	instruction
			mov		rbx,	shift_operand_opcode
			call	get_code
			cmp		rax,	-1
			je		skip_reg_index_shift_instruction
			cp_string	opcode,		rax
			mov		rsi,	instruction
			mov		rbx,	shift_operand_reg_op
			call	get_code
			cp_string	reg_op,		rax

			skip_reg_index_shift_instruction:

			cmp		byte[operand_2],	"0"
			jne		skip_reg_index_shift_instruction2
			mov		rsi,	instruction
			mov		rbx,	shift_operand_displacement_opcode
			call	get_code
			cp_string	opcode,		rax

			skip_reg_index_shift_instruction2:
			
			add_string	output,	prefix
			add_string	output,	rex
			add_string	output,	opcode
			add_string	output,	opcode_W,	1
			add_string	output,	mod,		2
			add_string	output,	reg_op,		3
			add_string	output,	r_m,		3
			jmp		final

		single_memory:
			mov		rsi,	operand_1
			call	get_mem_data_size
			mov		ax,		word[rax]
			mov		word[mem_data_size],	ax

			mov		rsi,	operand_1
			call	dissect_mem_access

			mov		rax,	[displacement_len]

			;rex
			mov		rsi,	base_reg
			call	is_new_register
			jnc		skip_single_memory_is_new1
			mov		byte[has_rex],	1

			skip_single_memory_is_new1:

			mov		rsi,	index_reg
			call	is_new_register
			jnc		skip_single_memory_is_new2
			mov		byte[has_rex],	1

			skip_single_memory_is_new2:

			cmp_string	mem_data_size,	sixty_four
			jnc		skip_single_memory_is_64_bit
			mov		byte[has_rex],	1
			mov		byte[rex_w],	"1"

			skip_single_memory_is_64_bit:

			;prefix
			cmp_string	mem_address_size,	thirty_two
			jnc		skip_single_memory_pref_67
			add_string	prefix,		b_sixty_seven

			skip_single_memory_pref_67:

			cmp_string	mem_data_size,	sixteen
			jnc		skip_single_memory_pref_66
			add_string	prefix,		b_sixty_six

			skip_single_memory_pref_66:

			;opcode
			mov		rsi,	instruction
			mov		rbx,	reg_opcode_map
			call	get_code
			cp_string	opcode,	rax

			;opcode w
			mov		byte[opcode_W],	"1"
			cmp_string	operand_1_size,	eight
			jnc		skip_single_memory_is_8_bit
			mov		byte[opcode_W],	"0"

			skip_single_memory_is_8_bit:

			;REG/OP
			mov		rsi,	instruction
			mov		rbx,	reg_reg_op_map
			call	get_code
			cp_string	reg_op,	rax

			;MOD
			cp_string	mod,	mod00

			cmp		qword[displacement_len],	2
			jle		single_memory_set_mod_01
			jg		single_memory_set_mod_10
			jmp		skip_single_memory_set_mod

			single_memory_set_mod_01:
				cmp		qword[displacement_len],	0
				je		skip_single_memory_set_mod
				cmp		byte[displacement],		0
				je		skip_single_memory_set_mod
				cp_string	mod,	mod01
				jmp		skip_single_memory_set_mod
			single_memory_set_mod_10:
				cp_string	mod,	mod10
				jmp		skip_set_mod
			skip_single_memory_set_mod:

			cmp_string	mod,	mod00
			jnc		skip_mem_change_displacement_for_bp
			mov		rsi,	base_reg
			mov		rbx,	bp_registers
			call	get_code
			cmp		rax,	-1
			je		skip_mem_change_displacement_for_bp

			cp_string	mod,	mod01
			cp_string	displacement,	hex_00
			mov		qword[displacement_len],	2

			skip_mem_change_displacement_for_bp:

			;rex
			cmp		byte[has_rex],	1
			jne		skip_single_memory_rex_2
			
			;has_rex
			;rex w
			mov		byte[rex_w],	"1"
			cmp_string		mem_data_size, sixty_four
			je		skip_single_memory_set_rex_w
			mov		byte[rex_w],	"0"
			skip_single_memory_set_rex_w:

			;rex x
			mov		byte[rex_x],	"0"

			;rex r
			mov		byte[rex_r],	"0"
			skip_single_memory_rex_2:

			cmp		byte[index_reg],	0
			je		single_memory_no_index
			jmp		single_memory_has_index

			single_memory_no_index:
				cmp		byte[base_reg],		0
				je		single_memory_direct_addressing
				jmp		single_memory_base_and_displacement

				single_memory_direct_addressing:
					cp_string	mod,	mod00
					cp_string	r_m,	b_four
					cp_string	sib_ss,	mod00
					cp_string	sib_index,	b_four
					cp_string	sib_base,	b_five
					
					add_string	sib,	sib_ss
					add_string	sib,	sib_index
					add_string	sib,	sib_base

					mov		byte[rex_b],	"0"

					jmp		end_single_memory_no_index

				single_memory_base_and_displacement:
					mov		rax,	base_reg_code
					inc		rax
					cp_string	r_m,	rax,	3
					mov		byte[sib],	0
					mov		rax,	base_reg_code
					mov		al,		byte[rax]
					mov		byte[rex_b],	al
					jmp		end_single_memory_no_index


				end_single_memory_no_index:

				cmp		byte[has_rex],	1
				jne		skip_single_memory_build_rex
				cp_string	rex,	rex_pref,	4
				add_string	rex,	rex_w,	1
				add_string	rex,	rex_r,	1
				add_string	rex,	rex_x,	1
				add_string	rex,	rex_b,	1

				skip_single_memory_build_rex:

				cmp_string	instruction,	str_imul
				jnc		skip_mem_no_index_change_opcode_for_imul
				cp_string	opcode,	imul_single_operand_opcode
				cp_string	reg_op,	b_five

				skip_mem_no_index_change_opcode_for_imul:

				mov		rsi,	instruction
				mov		rbx,	shift_operand_opcode
				call	get_code
				cmp		rax,	-1
				je		skip_mem_no_index_shift_instruction
				cp_string	opcode,		rax
				mov		rsi,	instruction
				mov		rbx,	shift_operand_reg_op
				call	get_code
				cp_string	reg_op,		rax

				skip_mem_no_index_shift_instruction:

				cmp		byte[operand_2],	"0"
				jne		skip_mem_no_index_shift_instruction2
				mov		rsi,	instruction
				mov		rbx,	shift_operand_displacement_opcode
				call	get_code
				cp_string	opcode,		rax

				skip_mem_no_index_shift_instruction2:

				add_string	output,	prefix
				add_string	output,	rex
				add_string	output,	opcode
				; add_string	output,	opcode_D,	1
				add_string	output,	opcode_W,	1
				add_string	output,	mod,		2
				add_string	output,	reg_op,		3
				add_string	output,	r_m,		3
				add_string	output,	sib
				add_string	output,	displacement

			jmp		final

			single_memory_has_index:	;has sib
				;rex
				cmp		byte[has_rex],	1
				jne		skip_single_memory_has_index_rex
				mov		al,		byte[index_reg_code]
				mov		byte[rex_x],	al

				mov		byte[rex_r],	"0"

				mov		al,		byte[base_reg_code]
				mov		byte[rex_b],	al

				cp_string	rex,	rex_pref,	4
				add_string	rex,	rex_w,	1
				add_string	rex,	rex_r,	1
				add_string	rex,	rex_x,	1
				add_string	rex,	rex_b,	1

				skip_single_memory_has_index_rex:

				;R/M
				cp_string	r_m,	b_four

				;sib index
				mov		rax,	index_reg_code
				inc		rax
				cp_string	sib_index,	rax,	3

				;sib ss
				mov		rsi,	scale
				mov		rbx,	dec2bin
				call	get_code
				cp_string	sib_ss,	rax

				;sib base
				cp_string	sib_base,	b_five
				cmp		byte[base_reg],	0
				je		skip_single_memory_set_sib_base
				mov		rax,	base_reg_code
				inc		rax
				cp_string	sib_base,	rax,	3

				skip_single_memory_set_sib_base:

				add_string	sib,	sib_ss
				add_string	sib,	sib_index
				add_string	sib,	sib_base

				cmp_string	instruction,	str_imul
				jnc		skip_mem_has_index_change_opcode_for_imul
				cp_string	opcode,	imul_single_operand_opcode
				cp_string	reg_op,	b_five

				skip_mem_has_index_change_opcode_for_imul:

				mov		rsi,	instruction
				mov		rbx,	shift_operand_opcode
				call	get_code
				cmp		rax,	-1
				je		skip_mem_has_index_shift_instruction
				cp_string	opcode,		rax
				mov		rsi,	instruction
				mov		rbx,	shift_operand_reg_op
				call	get_code
				cp_string	reg_op,		rax

				skip_mem_has_index_shift_instruction:

				cmp		byte[operand_2],	"0"
				jne		skip_mem_has_index_shift_instruction2
				mov		rsi,	instruction
				mov		rbx,	shift_operand_displacement_opcode
				call	get_code
				cp_string	opcode,		rax

				skip_mem_has_index_shift_instruction2:

				add_string	output,	prefix
				add_string	output,	rex
				add_string	output,	opcode
				add_string	output,	opcode_D,	1
				add_string	output,	opcode_W,	1
				add_string	output,	mod,		2
				add_string	output,	reg_op,		3
				add_string	output,	r_m,		3
				add_string	output,	sib
				add_string	output,	displacement

			jmp		final


		both_operand_reg:
			mov		rsi,	operand_2
			call	get_register_code
			cp_string	operand_2_code,		rax

			mov		eax,	dword[operand_2_code]
			mov		dword[register_2_code],		eax

			mov		rax,	operand_2_code
			add		rax,	5
			mov		bx,		word[rax]
			mov		word[operand_2_size],	bx

			mov		byte[has_rex],	0

			;Prefix
			cmp_string	operand_1_size,	sixteen
			jne		skip_prefix
			add_string prefix,	b_sixty_six
			skip_prefix:

			;opcode
			mov		rsi,	instruction
			call	get_reg_reg_opcode
			cp_string	opcode,	rax

			;Opcode W
			mov		byte[opcode_W],	"1"

			cmp_string	operand_1_size,	eight
			jnc		skip_opcode_w
			mov		byte[opcode_W],	"0"
			skip_opcode_w:

			;Opcode D
			mov		byte[opcode_D],	"0"
			
			;MOD
			cp_string	mod,	mod11

			;REG/OP
			mov		rax,	register_2_code
			inc		rax
			cp_string	reg_op,		rax

			;R/M
			mov		rax,	register_1_code
			inc		rax
			cp_string	r_m,	rax

			;has rex?
			mov		byte[rex_w],	"0"

			cmp_string	operand_1_size,	sixty_four
			jc 		enable_rex64
			cmp		byte[register_1_code],	"1"
			je		enable_rex
			cmp		byte[register_2_code],	"1"
			je		enable_rex
			jmp		skip_rex

			enable_rex64:
				mov		byte[rex_w], 	"1"
			enable_rex:
				mov		byte[has_rex],	1
				mov		al,		byte[register_2_code]
				mov		byte[rex_r],	al
				mov		byte[rex_x],	"0"
				mov		al,		byte[register_1_code]
				mov		byte[rex_b],	al

				cp_string	rex,	rex_pref
				add_string	rex,	rex_w,	1
				add_string	rex,	rex_r,	1
				add_string	rex,	rex_x,	1
				add_string	rex,	rex_b,	1

			skip_rex:

			cmp_string	instruction,	str_imul
			jnc		skip_reg_reg_change_opcode_for_imul
			cp_string	opcode,		imul_reg_reg_opcode
			mov		byte[opcode_W],		0

			skip_reg_reg_change_opcode_for_imul:

			add_string	output,	prefix
			add_string	output,	rex
			add_string	output,	opcode
			add_string	output,	opcode_W,	1
			add_string	output,	mod,		2
			add_string	output,	reg_op,		3
			add_string	output,	r_m,		3

			jmp		final
		
		register_memory:
			mov		rsi,	operand_2
			call	get_mem_data_size
			mov		ax,		word[rax]
			mov		word[mem_data_size],	ax

			;REG/OP
			mov		rax,	register_1_code
			inc		rax
			cp_string	reg_op,	rax

			mov		rsi,	operand_2
			call	dissect_mem_access

			cmp_string	mem_data_size,	sixty_four
			jc		set_has_rex

			mov		rsi,	operand_1
			call 	is_new_register
			jc		set_has_rex

			mov		rsi,	base_reg
			call	is_new_register
			jc		set_has_rex

			mov		rsi,	index_reg
			call	is_new_register
			jc		set_has_rex

			jmp		skip_set_has_rex

			set_has_rex:
				mov		byte[has_rex],	1
			skip_set_has_rex:
			
			;MOD
			cp_string	mod,	mod00

			cmp		qword[displacement_len],	2
			jle		set_mod_01
			jg		set_mod_10
			jmp		skip_set_mod

			set_mod_01:
				cmp		qword[displacement_len],	0
				je		skip_set_mod
				cp_string	mod,	mod01
				jmp		skip_set_mod
			set_mod_10:
				cp_string	mod,	mod10
				jmp		skip_set_mod
			skip_set_mod:

			cmp_string	mod,	mod00
			jnc		skip_reg_mem_change_displacement_for_bp
			mov		rsi,	base_reg
			mov		rbx,	bp_registers
			call	get_code
			cmp		rax,	-1
			je		skip_reg_mem_change_displacement_for_bp

			cp_string	mod,	mod01
			cp_string	displacement,	hex_00

			skip_reg_mem_change_displacement_for_bp:

			;Prefix
			cmp_string	mem_address_size,	thirty_two
			jne		skip_prefix_67
			add_string	prefix,	b_sixty_seven

			skip_prefix_67:

			cmp_string	mem_data_size,	sixteen
			jne		skip_prefix2
			add_string prefix,	b_sixty_six
			skip_prefix2:

			;opcode
			mov		rsi,	instruction
			mov		rbx,	reg_mem_opcode_map
			call	get_code
			cp_string	opcode,	rax

			;Opcode W
			mov		byte[opcode_W],	"1"

			cmp_string	mem_data_size,	eight
			jnc		skip_opcode_w2
			mov		byte[opcode_W],	"0"
			skip_opcode_w2:

			;Opcode D
			mov		byte[opcode_D],	"1"
			cmp		byte[is_reversed],	1
			jne		skip_reset_opcode_d
			mov		byte[opcode_D],	"0"

			skip_reset_opcode_d:

			;rex
			cmp		byte[has_rex],	1
			jne		skip_rex_2
			
			;has_rex
			;rex w
			mov		byte[rex_w],	"1"
			cmp_string		mem_data_size, sixty_four
			je		skip_set_rex_w
			mov		byte[rex_w],	"0"
			skip_set_rex_w:

			;rex x
			mov		byte[rex_x],	"0"

			;rex r
			mov		al,		byte[register_1_code]
			mov		byte[rex_r],	al

			;rex b
			mov		byte[rex_b],	"0"
			cmp		byte[base_reg],  0
			je		skip_set_rex_b

			mov		al,		byte[base_reg_code]
			mov		byte[rex_b],	al

			skip_set_rex_b:
			cp_string	rex,	rex_pref
			add_string	rex,	rex_w,	1
			add_string	rex,	rex_r,	1
			add_string	rex,	rex_x,	1
			add_string	rex,	rex_b,	1
			
			skip_rex_2:

			cmp		byte[index_reg],	0
			je		no_index
			jmp		has_index

			no_index:
				cmp		byte[base_reg],		0
				je		direct_addressing
				jmp		base_and_displacement

				direct_addressing:
					cp_string	mod,	mod00
					cp_string	r_m,	b_four
					cp_string	sib_ss,	mod00
					cp_string	sib_index,	b_four
					cp_string	sib_base,	b_five
					
					add_string	sib,	sib_ss
					add_string	sib,	sib_index
					add_string	sib,	sib_base

					jmp		end_reg_mem_no_index

				base_and_displacement:
					mov		rax,	base_reg_code
					inc		rax
					cp_string	r_m,	rax,	3
					mov		byte[sib],	0
					jmp		end_reg_mem_no_index


				end_reg_mem_no_index:

				call	make_displacement

				mov		rsi,	opcode
				mov		rbx,	DW_in_opcode
				call	get_code
				cmp		rax,	-1
				je 		skip_reg_mem_no_index_change_imul
				mov		byte[opcode_D],	0
				mov		byte[opcode_W],	0

				skip_reg_mem_no_index_change_imul:

				mov		rsi,	opcode
				mov		rbx,	D_in_opcode
				call	get_code
				cmp		rax,	-1
				je 		skip_reg_mem_no_index_d_in_opcode
				mov		byte[opcode_D],	0

				skip_reg_mem_no_index_d_in_opcode:

				add_string	output,	prefix
				add_string	output,	rex
				add_string	output,	opcode
				add_string	output,	opcode_D,	1
				add_string	output,	opcode_W,	1
				add_string	output,	mod,		2
				add_string	output,	reg_op,		3
				add_string	output,	r_m,		3
				add_string	output,	sib
				add_string	output,	displacement
				jmp		final

			has_index:
				mov		al,		byte[index_reg_code]
				mov		byte[rex_x],	al
				cmp		byte[has_rex],	1
				jne		skip_set_rex_x
				mov		rdx,	rex
				add		rdx,	6
				mov		al,		byte[rex_x]
				mov		byte[rdx],	al

				skip_set_rex_x:

				;R/M
				cp_string	r_m,	b_four

				;sib index
				mov		rax,	index_reg_code
				inc		rax
				cp_string	sib_index,	rax,	3

				;sib ss
				mov		rsi,	scale
				mov		rbx,	dec2bin
				call	get_code
				cp_string	sib_ss,	rax

				;sib base
				cp_string	sib_base,	b_five
				cmp		byte[base_reg],	0
				je		reg_mem_index_no_base
				mov		rax,	base_reg_code
				inc		rax
				cp_string	sib_base,	rax,	3

				reg_mem_index_no_base:
					mov		qword[displacement_len],	8
					cp_string	displacement,	hex_8_0


				call	make_displacement

				add_string	sib,	sib_ss
				add_string	sib,	sib_index
				add_string	sib,	sib_base

				mov		rsi,	opcode
				mov		rbx,	DW_in_opcode
				call	get_code
				cmp		rax,	-1
				je 		skip_reg_mem_has_index_change_imul
				mov		byte[opcode_D],	0
				mov		byte[opcode_W],	0

				skip_reg_mem_has_index_change_imul:

								mov		rsi,	opcode
				mov		rbx,	D_in_opcode
				call	get_code
				cmp		rax,	-1
				je 		skip_reg_mem_has_index_d_in_opcode
				mov		byte[opcode_D],	0

				skip_reg_mem_has_index_d_in_opcode:

				add_string	output,	prefix
				add_string	output,	rex
				add_string	output,	opcode
				add_string	output,	opcode_D,	1
				add_string	output,	opcode_W,	1
				add_string	output,	mod,		2
				add_string	output,	reg_op,		3
				add_string	output,	r_m,		3
				add_string	output,	sib
				add_string	output,	displacement

				jmp		final

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	final:
		;binary output
		mov		rsi,	output
		mov		rdi,	[bin_out_file_disc]
		call	write_string

		mov		rsi,	output
		call	printString
		call	newLine

		;hex
		mov		rsi,	output
		mov		rax,	hex_output
		mov		byte[hex_output],	0
		call	bin2hex
		cp_string		output,		hex_output
		add_string2		output,		white_space
		add_string2		output,		input_command

		mov		rsi,	output
		call	printString
		call	newLine
		call	newLine

		mov		rsi,	output
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

	mov		rax,	sys_exit
	mov		rdi,	[bin_out_file_disc]
	syscall

	jmp  	Exit

Exit:
	pop		rbp
	mov		rax,	sys_exit
	mov		rbx,	0
	syscall