from dis import Instruction


class SIB:
	SS = ""
	INDEX = ""
	BASE = ""

	def __init__(self, str):
		if str == -1:
			self.SS = ""
			self.INDEX = ""
			self.BASE = ""

		else:
			self.SS = str[:2]
			self.INDEX = str[2:5]
			self.BASE = str[5:8]

			if self.INDEX == "100":
				self.BASE = -1
				self.INDEX = -1
				self.SS = -1

	def get_sib(self):
		return (self.SS + self.INDEX + self.BASE)

class REX:
	pref = ""
	W = ""
	R = ""
	X = ""
	B = ""

	def __init__(self, str):
		if str == -1:
			self.pref = ""
			self.W = ""
			self.R = ""
			self.X = ""
			self.B = ""

		else:
			self.pref = "0100"
			self.W = str[0]
			self.R = str[1]
			self.X = str[2]
			self.B = str[3]

	def get_rex(self):
		return (self.pref + self.W + self.R + self.X + self.B)

opcode_map = {
	"100010":	"mov",

	"000000":	"add",
	"000100":	"adc",
	"110000":	"xadd",

	"001010":	"sub",
	"000110":	"sbb",

	"001000":	"and",
	"000010":	"or",
	"001100":	"xor",

	"00001111101011": 	"imul",

	"1000011":	"xchg",
	"1000010":	"test",
	"001110":	"cmp",

	"11111001":	"stc",
	"11111000":	"clc",
	"11111100":	"cld",
	"11111101":	"std",
	"11000011":	"ret",
	"0000111100000101":	"syscall",

	"1111011100":	"mul",

	"1111011111":	"idiv",
	"1111011011":	"neg",
	"1111011010":	"not",

	"1111111000":	"inc",
	"1111111001":	"dec",

	"111101":	"imul",

	"1111111110":	"push",
	"1000111000":	"pop",

	"0000111110111100":	"bsf",
	"0000111110111101":	"bsr",

	"jmp8":		"11101011",
	"jmp32":	"11101001",
	"jcc8":		"0111",
	"jcc32":	"000011111000",
	"jmp":		["11111111", "100"],

	"call32":	"11101000",
	"call":		["11111111", "010"],
}

single_operand_opcode = [
	"1111011",
	"1111111",
	"1000111",
	"1111011",
]

DW_in_opcode = [
	"00001111101111",
]

tttn_map = {
	"0000":	"O",
	"0001":	"NO",
	"0010":	"B",
	"0010":	"NAE",
	"0011":	"NB",
	"0011":	"AE",
	"0100":	"E",
	"0100":	"Z",
	"0101":	"NE",
	"0101":	"NZ",
	"0110":	"BE",
	"0110":	"NA",
	"0111":	"NBE",
	"0111":	"A",
	"1000":	"S",
	"1001":	"NS",
	"1010":	"P",
	"1010":	"PE",
	"1011":	"NP",
	"1011":	"PO",
	"1100":	"L",
	"1100":	"NGE",
	"1101":	"NL",
	"1101":	"GE",
	"1110":	"LE",
	"1110":	"NG",
	"1111":	"NLE",
	"1111":	"G",
}

register_code_map = {
	"8$000$0":	"al",
	"8$001$0":	"cl",
	"8$010$0":	"dl",
	"8$011$0":	"bl",
	"8$100$0":	"ah",
	"8$101$0":	"ch",
	"8$110$0":	"dh",
	"8$111$0":	"bh",

	"16$000$0":	"ax",
	"16$001$0":	"cx",
	"16$010$0":	"dx",
	"16$011$0":	"bx",
	"16$100$0":	"sp",
	"16$101$0":	"bp",
	"16$110$0":	"si",
	"16$111$0":	"di",

	"32$000$0":	"eax",
	"32$001$0":	"ecx",
	"32$010$0":	"edx",
	"32$011$0":	"ebx",
	"32$100$0":	"esp",
	"32$101$0":	"ebp",
	"32$110$0":	"esi",
	"32$111$0":	"edi",

	"64$000$0":	"rax",
	"64$001$0":	"rcx",
	"64$010$0":	"rdx",
	"64$011$0":	"rbx",
	"64$100$0":	"rsp",
	"64$101$0":	"rbp",
	"64$110$0":	"rsi",
	"64$111$0":	"rdi",

	"64$000$1":	"r8",
	"64$001$1":	"r9",
	"64$010$1":	"r10",
	"64$011$1":	"r11",
	"64$100$1":	"r12",
	"64$101$1":	"r13",
	"64$110$1":	"r14",
	"64$111$1":	"r15",

	"32$000$1":	"r8d",
	"32$001$1":	"r9d",
	"32$010$1":	"r10d",
	"32$011$1":	"r11d",
	"32$100$1":	"r12d",
	"32$101$1":	"r13d",
	"32$110$1":	"r14d",
	"32$111$1":	"r15d",

	"16$000$1":	"r8w",
	"16$001$1":	"r9w",
	"16$010$1":	"r10w",
	"16$011$1":	"r11w",
	"16$100$1":	"r12w",
	"16$101$1":	"r13w",
	"16$110$1":	"r14w",
	"16$111$1":	"r15w",

	"8$000$1":	"r8b",
	"8$001$1":	"r9b",
	"8$010$1":	"r10b",
	"8$011$1":	"r11b",
	"8$100$1":	"r12b",
	"8$101$1":	"r13b",
	"8$110$1":	"r14b",
	"8$111$1":	"r15b",
}

def reverse(str1):
	s = ""
	for i in range(len(str1)-2, -1, -2):
		s += (str1[i] + str1[i+1])

	# print ("--> ", s)

	while len(s) and s[0] == "0":
		s = s[1:]

	# print ("--< ", s)
	return s.lower()

def make_mem_address(mem_size, reg_size, base, index, scale, disp, has_rex, rex):
	address = []
	pref = ""
	if mem_size == "8":
		pref += "BYTE"
	if mem_size == "16":
		pref += "WORD"
	if mem_size == "32":
		pref += "DWORD"
	if mem_size == "64":
		pref += "QWORD"
	pref += " PTR "

	if base != -1:
		if has_rex:
			base = register_code_map[str(reg_size) + "$" + base + "$" + rex.B]

		else:
			base = register_code_map[str(reg_size) + "$" + base + "$0"]

		address.append(base)

	if index != -1:
		if scale == "00":
			scale = "*1"
		elif scale == "01":
			scale = "*2"
		elif scale == "10":
			scale = "*4"
		elif scale == "11":
			scale = "*8"

		if has_rex:
			index = register_code_map[str(reg_size) + "$" + index + "$" + rex.X]
		else:
			base = register_code_map[str(reg_size) + "$" + index + "$0"]

		address.append((index + scale))

	if disp != -1 and disp != "":
		address.append("0x"+disp)

	address = pref + "[" + "+".join(address) + "]"

	return address

input_command = input()

has_67 = False
has_66 = False
has_rex = False
has_sib = False

rex = REX(-1)
sib = SIB(-1)

instruction = ""

first_opereand = ""
second_operand = ""

if input_command[:2] == "67":
	has_67 = True
	input_command = input_command[2:]

if input_command[:2] == "66":
	has_66 = True
	input_command = input_command[2:]

if input_command[0] == "4":
	has_rex = True
	temp = input_command[1]
	input_command = input_command[2:]
	temp =  str (bin (int (str (temp), 16)))[2:].zfill(4)
	rex = REX(temp)
	
opcode = ""

if input_command[:2] == "0f":
	opcode += "00001111"
	input_command = input_command[2:]

temp = input_command[:2]
input_command = input_command[2:]
temp = str( bin (int (temp, 16)))[2:].zfill(8)

opcode += temp[:6]
D = temp[6]
W = temp[7]

displacement = ""
imm_data = ""

# print (opcode, D, W, len(input_command))
#	no operand
# print (opcode)


if len(input_command) == 0:
	opcode += D+W

else:
	temp = input_command[:2]
	input_command = input_command[2:]
	temp = str( bin (int (temp, 16)))[2:].zfill(8)

	MOD = temp[:2]
	REG = temp[2:5]
	RM = temp[5:8]

	# print (MOD, REG, RM)

	#	find register size
	register_size = "32"
	if has_66:
		register_size = "16"
	if W == "0":
		register_size = "8"
	if has_rex and rex.W == "1":
		register_size = "64"

	if MOD == "11": #	reg - reg
		imm_data = reverse (input_command)
		input_command = ""

		#	single operand
		if opcode+D in single_operand_opcode:
			opcode = opcode+D+REG
			if has_rex:
				first_opereand = register_code_map[register_size + "$" + RM + "$" + rex.B]
			else:
				first_opereand = register_code_map[register_size + "$" + RM + "$0"]

		else:
			if has_rex:
				first_opereand = register_code_map[register_size + "$" + RM + "$" + rex.B]
				second_operand = register_code_map[register_size + "$" + REG + "$" + rex.R]
			else:
				first_opereand = register_code_map[register_size + "$" + RM + "$0"]
				second_operand = register_code_map[register_size + "$" + REG + "$0"]

				# print (opcode)
		if opcode in DW_in_opcode:
			opcode = opcode+D+W

		if opcode_map[opcode] in ["imul", "bsr", "bsf"]:
			first_opereand, second_operand = second_operand, first_opereand

	else: # 	reg - mem
		if opcode in DW_in_opcode:
			opcode = opcode+D+W

		if RM == "100": #	sib
			has_sib = True
			temp = input_command[:2]
			input_command = input_command[2:]
			temp = str( bin (int (temp, 16)))[2:].zfill(8)

			sib = SIB(temp)

		if MOD == "00":
			displacement = ""
			imm_data = reverse (input_command)
			input_command = ""

		elif MOD == "01":
			displacement = reverse (input_command[:2])
			input_command = input_command[2:]
			imm_data = reverse (input_command)
			input_command = ""

		elif MOD == "10":
			displacement = reverse (input_command[:8])
			input_command = input_command[8:]
			imm_data = reverse (input_command)
			input_command = ""

		address_size = 64
		if has_67:
			address_size = 32

		#	single operand
		if opcode+D in single_operand_opcode:
			opcode = opcode+D+REG
			if has_sib:
				first_opereand = make_mem_address(register_size, address_size, sib.BASE, sib.INDEX, sib.SS, displacement, has_rex, rex)
			else:
				first_opereand = make_mem_address(register_size, address_size, RM, -1, -1, displacement, has_rex, rex)

		else:
			if has_rex:
				first_opereand = register_code_map[register_size + "$" + REG + "$" + rex.R]
			else:
				first_opereand = register_code_map[register_size + "$" + REG + "$0"]

			if has_sib:
				second_operand = make_mem_address(register_size, address_size, sib.BASE, sib.INDEX, sib.SS, displacement, has_rex, rex)
			else:
				second_operand = make_mem_address(register_size, address_size, RM, -1, -1, displacement, has_rex, rex)

			if D == "0":
				first_opereand, second_operand = second_operand, first_opereand

		if opcode_map[opcode] in ["bsf", "bsr"]:
			first_opereand, second_operand = second_operand, first_opereand

instruction = opcode_map[opcode]

if first_opereand == "" and second_operand == "":
	print (instruction)
elif first_opereand == "":
	print (instruction + " " + second_operand)
elif second_operand == "":
	print (instruction + " " + first_opereand)
else:
	print (instruction + " " + first_opereand + "," + second_operand)

# print (rex.get_rex(), opcode, D, W, MOD, REG, RM, sib.get_sib(), displacement, imm_data)

