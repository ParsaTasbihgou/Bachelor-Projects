# input_file = open("a.asm")
# for line in input_file:
# 	print (line)

##	WORKING:
#	register - register < 64bit
#	register - memory (base only)

## TODO:
#	1) single and no operand
#	2) memory address without register
#	3) REX


from atexit import register
from distutils.sysconfig import PREFIX
from shutil import move


mem_size_id = ["BYTE", "WORD", "DWORD", "QWORD"]
new_registers = []

for ind in range(8, 16):
	new_registers.append("r"+str(ind))
	new_registers.append("r"+str(ind)+"d")
	new_registers.append("r"+str(ind)+"w")
	new_registers.append("r"+str(ind)+"b")


def is_mem_access(str):
	if len(str) == 0:
		return False
	if (str[0] == '['):
		return True
	str_split = str.split()
	if str_split[0] in mem_size_id:
		return True

def is_immidiate(str):
	try:
		return int(str)
	except:
		if len(str) >= 2 and str[:2] == "0x":
			return int (str, 16)
		return False

#	return [mem_size, address, address_size]
def dissect_mem(str):
	str_split = str.split()
	mem_size = 0
	if str_split[0] == "BYTE":
		mem_size = 8
	elif str_split[0] == "WORD":
		mem_size = 16
	elif str_split[0] == "DWORD":
		mem_size = 32
	elif str_split[0] == "QWORD":
		mem_size = 64
	
	address = str_split[2][1:len(str_split[2])-1]
	address_size = 0

	return [mem_size, address, address_size]

#	return (address_size, [base, index, scale, displacement])
def dissect_address(str):
	scale = ""
	index = ""
	base = ""
	displacement = ""

	str_split = str.split('+')

	if len(str_split) == 3:
		base = str_split[0]

		temp = str_split[1].split('*')
		if len(temp) == 1:
			index = str_split[1]
		else:
			index = temp[0]
			scale = temp[1]
		
		displacement = str_split[2]

	if len(str_split) == 2:

		if str_split[0] in register_code_map:
			base = str_split[0]
			if (str_split[1][0:2] == "0x"):
				displacement = str_split[1]
			else:
				temp = str_split[1].split('*')
				index = temp[0]
				scale = temp[1]

		else:
			displacement = str_split[1]
			temp = str_split[0].split('*')
			index = temp[0]
			scale = temp[1]

	else:
		if str_split[0] in register_code_map:
			base = str_split[0]

		elif (str_split[0][0:2] == "0x"):
			displacement = str_split[0]

		else:
			temp = str_split[0].split('*')
			index = temp[0]
			scale = temp[1]

	if all([x == '0' for x in displacement[2:]]):
		displacement = ""

	address_size = 0
	if base != "":
		address_size = register_code_map[base][0]
	elif index != "":
		address_size = register_code_map[index][0]

	return (address_size, [base, index, scale, displacement])

register_code_map = {
	"al": [8, "000", 0],
	"cl": [8, "001", 0],
	"dl": [8, "010", 0],
	"bl": [8, "011", 0],
	"ah": [8, "100", 0],
	"ch": [8, "101", 0],
	"dh": [8, "110", 0],
	"bh": [8, "111", 0],

	"ax": [16, "000", 0],
	"cx": [16, "001", 0],
	"dx": [16, "010", 0],
	"bx": [16, "011", 0],
	"sp": [16, "100", 0],
	"bp": [16, "101", 0],
	"si": [16, "110", 0],
	"di": [16, "111", 0],

	"eax": [32, "000", 0],
	"ecx": [32, "001", 0],
	"edx": [32, "010", 0],
	"ebx": [32, "011", 0],
	"esp": [32, "100", 0],
	"ebp": [32, "101", 0],
	"esi": [32, "110", 0],
	"edi": [32, "111", 0],

	"rax": [64, "000", 0],
	"rcx": [64, "001", 0],
	"rdx": [64, "010", 0],
	"rbx": [64, "011", 0],
	"rsp": [64, "100", 0],
	"rbp": [64, "101", 0],
	"rsi": [64, "110", 0],
	"rdi": [64, "111", 0],

	"r8": [64, "000", 1],
	"r9": [64, "001", 1],
	"r10": [64, "010", 1],
	"r11": [64, "011", 1],
	"r12": [64, "100", 1],
	"r13": [64, "101", 1],
	"r14": [64, "110", 1],
	"r15": [64, "111", 1],

	"r8d": [32, "000", 1],
	"r9d": [32, "001", 1],
	"r10d": [32, "010", 1],
	"r11d": [32, "011", 1],
	"r12d": [32, "100", 1],
	"r13d": [32, "101", 1],
	"r14d": [32, "110", 1],
	"r15d": [32, "111", 1],

	"r8w": [16, "000", 1],
	"r9w": [16, "001", 1],
	"r10w": [16, "010", 1],
	"r11w": [16, "011", 1],
	"r12w": [16, "100", 1],
	"r13w": [16, "101", 1],
	"r14w": [16, "110", 1],
	"r15w": [16, "111", 1],

	"r8b": [8, "000", 1],
	"r9b": [8, "001", 1],
	"r10b": [8, "010", 1],
	"r11b": [8, "011", 1],
	"r12b": [8, "100", 1],
	"r13b": [8, "101", 1],
	"r14b": [8, "110", 1],
	"r15b": [8, "111", 1],
}

opcode_map = {
	"mov": "100010",

	"add": "000000",
	"adc": "000100",
	"xadd": "110000",

	"sub": "001010",
	"sbb": "000110",

	"imul": "111101",
	"idiv": ["1111011","111"],

	"mul":	["1111011","100"],

	"and": "001000",
	"or": "000010",
	"xor": "001100",

	"xchg": "1000011",
	"test": "1000010",
	"cmp" : "001110",

	"inc": ["1111111", "000"],
	"dec": ["1111111", "001"],

	"stc": "11111001",
	"clc": "11111000",
	"cld": "11111100",
	"std": "11111101",

	"ret": "11000011",
	"syscall": "0000111100000101",

	"push": ["1111111", "110"],
	"pop": 	["1000111", "000"],

	"neg": 	["1111011", "011"],
	"not": 	["1111011", "010"],

	"bsf":	"0000111110111100",
	"bsr":	"0000111110111101",

	"jmp8":		"11101011",
	"jmp32":	"11101001",
	"jcc8":		"0111",
	"jcc32":	"000011111000",
	"jmp":		["11111111", "100"],

	"call32":	"11101000",
	"call":		["11111111", "010"],

	"shl":		["110100", "100"],
	"shr":		["110100", "101"],
}

tttn_map = {
	"O":	"0000",
	"NO": 	"0001",
	"B":	"0010",
	"NAE":	"0010",
	"NB":	"0011",
	"AE":	"0011",
	"E":	"0100",
	"Z":	"0100",
	"NE":	"0101",
	"NZ":	"0101",
	"BE":	"0110",
	"NA":	"0110",
	"NBE":	"0111",
	"A":	"0111",
	"S":	"1000",
	"NS":	"1001",
	"P":	"1010",
	"PE":	"1010",
	"NP":	"1011",
	"PO":	"1011",
	"L":	"1100",
	"NGE":	"1100",
	"NL":	"1101",
	"GE":	"1101",
	"LE":	"1110",
	"NG":	"1110",
	"NLE":	"1111",
	"G":	"1111",
}

opcode_imm = {
	"mov":	["1100", "011"],

	"add":	["100000", "000"],
	"adc":	["100000", "010"],
	"and":	["100000", "100"],
	"or":	["100000", "001"],
	"xor":	["100000", "110"],

	"sub":	["100000", "101"],
	"sbb": 	["100000", "011"],

	"cmp": 	["100000", "111"],
	"test":	["1111011", "000"]
}

class Command :
	instruction = ""
	operands = []
	number_operands = 0

	second_operand_is_mem = False
	first_operand_is_mem = False

	second_operand_mem_size = 0
	first_operand_mem_size = 0

	second_operand_mem_address = ""
	first_operand_mem_address = ""

	second_operand_reg_size = 0
	first_operand_reg_size = 0
	
	second_operand_reg_name = 0
	first_operand_reg_name = 0

	first_operand_is_imm = False
	first_operand_imm = 0
	first_operand_data_size = 0

	second_operand_is_imm = False
	second_operand_imm = 0
	second_operand_data_size = 0

	address_size = 0
	data_size = 0

	has_REX = False
	is_reversed = False

	PREFIX = ""
	REX = ""
	REX_W = ""
	REX_R = ""
	REX_X = ""
	REX_B = ""
	OPCDOE = ""
	D = "0"
	W = "0"
	MOD = ""
	REG = ""
	RM = ""
	SIB = ""
	SS = ""
	INDEX = ""
	BASE = ""
	DISPLACEMENT = ""
	DATA = ""

	FINAL = ""

	def __init__(self, instruction, operands):
		self.instruction = instruction
		self.operands = operands
		self.number_operands = len(operands)
		self.has_REX = False

		if self.number_operands == 2:
			if is_mem_access(operands[1]):
				self.second_operand_is_mem = True

				mem_dissected = dissect_mem(operands[1])

				self.second_operand_mem_size = mem_dissected[0]
				self.second_operand_mem_address = mem_dissected[1]
				self.address_size = mem_dissected[2]
				self.second_operand_mem_address = dissect_address(mem_dissected[1])
				self.address_size = self.second_operand_mem_address[0]

			elif is_immidiate(operands[1]):
				self.second_operand_is_imm = True
				self.second_operand_imm = is_immidiate(operands[1])
				self.second_operand_data_size = 2
				if self.second_operand_imm > 127:
					self.second_operand_data_size = 8
				self.second_operand_imm = str(hex(self.second_operand_imm))

			else:
				self.second_operand_reg_size = register_code_map[operands[1]][0]
				self.second_operand_reg_name = operands[1]

			if is_mem_access(operands[0]):
				self.first_operand_is_mem = True

				mem_dissected = dissect_mem(operands[0])
				
				self.first_operand_mem_size = mem_dissected[0]
				self.first_operand_mem_address = mem_dissected[1]
				self.first_operand_mem_address = dissect_address(mem_dissected[1])
				self.address_size = self.first_operand_mem_address[0]

			elif is_immidiate(operands[0]):
				self.first_operand_is_imm = True
				self.first_operand_imm = is_immidiate(operands[0])
				self.first_operand_data_size = 2
				if self.first_operand_imm > 127:
					self.first_operand_data_size = 8
				self.first_operand_imm = str(hex(self.first_operand_imm))

			else:
				self.first_operand_reg_size = register_code_map[operands[0]][0]
				self.first_operand_reg_name = operands[0]

			self.data_size = max(self.first_operand_reg_size, self.second_operand_reg_size)

			if self.instruction in ["shl", "shr"] or self.second_operand_is_imm:
				self.data_size = max (self.first_operand_reg_size, self.first_operand_mem_size)

			# print (self.data_size)

			if (not self.first_operand_is_mem and self.first_operand_reg_name in new_registers) or (not self.second_operand_is_mem and self.second_operand_reg_name in new_registers):
				self.has_REX = True

			if self.first_operand_is_mem and len(self.first_operand_mem_address[1][0]) != 0 and self.first_operand_mem_address[1][0] in new_registers:
				self.has_REX = True

			if self.first_operand_is_mem and len(self.first_operand_mem_address[1][1]) != 0 and self.first_operand_mem_address[1][1] in new_registers:
				self.has_REX = True

			if self.second_operand_is_mem and len(self.second_operand_mem_address[1][0]) != 0 and self.second_operand_mem_address[1][0] in new_registers:
				self.has_REX = True

			if self.second_operand_is_mem and len(self.second_operand_mem_address[1][1]) != 0 and self.second_operand_mem_address[1][1] in new_registers:
				self.has_REX = True
				self.REX_W = "1"		

			if self.data_size == 64:
				self.has_REX = True
				self.REX_W = "1"		

			#prefix
			if (self.address_size == 32):
				self.PREFIX += "67"
			if (self.data_size == 16):
				self.PREFIX += "66"

			#opcode
			self.OPCDOE = opcode_map[self.instruction]

			#D
			if self.second_operand_is_mem and not self.is_reversed:
				self.D = "1"
			if self.is_reversed:
				self.D = "0"

			#W
			# print (self.data_size)
			if self.data_size != 8:
				self.W = "1"

			#MOD

			#reg-reg
			if not self.first_operand_is_mem and not self.second_operand_is_mem:
				self.MOD = "11"
				if not self.second_operand_is_imm:
					self.REG = register_code_map[self.second_operand_reg_name][1]
				# else:
				# 	# print (opcode_map[self.instruction][1])
				# 	self.REG = opcode_map[self.instruction][1]

				self.RM = register_code_map[self.first_operand_reg_name][1]

				if self.has_REX:
					if self.data_size == 64:
						self.REX_W = "1"
					else:
						self.REX_W = "0"

					self.REX_X = "0"

					if not self.second_operand_is_imm:
						self.REX_R = str( register_code_map[self.second_operand_reg_name][2] )
					else:
						self.REX_R = "0"

					self.REX_B = str( register_code_map[self.first_operand_reg_name][2] )

					self.REX = "0100" + self.REX_W + self.REX_R + self.REX_X + self.REX_B

			if self.first_operand_is_mem and not self.second_operand_is_mem:
				self.is_reversed = True

				self.second_operand_is_mem , self.first_operand_is_mem = self.first_operand_is_mem, self.second_operand_is_mem
				self.second_operand_mem_size, self.first_operand_mem_size = self.first_operand_mem_size, self.second_operand_mem_size
				self.second_operand_mem_address, self.first_operand_mem_address = self.first_operand_mem_address, self.second_operand_mem_address
				self.second_operand_reg_size, self.first_operand_reg_size = self.first_operand_reg_size, self.second_operand_reg_size
				self.second_operand_reg_name, self.first_operand_reg_name = self.first_operand_reg_name, self.second_operand_reg_name


			if True:

				#reg-mem
				if self.second_operand_is_mem and (not self.first_operand_is_mem): #	first operand must be register
					if not self.second_operand_is_imm:
						self.REG = register_code_map[self.first_operand_reg_name][1]
					# print (self.REG)

					if len(self.second_operand_mem_address[1][3]) == 0:
						self.MOD = "00"
					elif len(self.second_operand_mem_address[1][3])-2 <= 2:
						self.MOD = "01"
					else:
						self.MOD = "10"

					if len(self.second_operand_mem_address[1][0]) != 0 and self.second_operand_mem_address[1][0][-2:] == "bp" and self.MOD == "00":
						self.MOD = "01"
						self.second_operand_mem_address[1][3] = "0x00"
				
					if len(self.second_operand_mem_address[1][1]) == 0: #	no index
						if self.has_REX:
							if self.data_size == 64:
								self.REX_W = "1"
							else:
								self.REX_W = "0"

							self.REX_X = "0"
							if not self.second_operand_is_imm:
								 self.REX_R = str(register_code_map[self.first_operand_reg_name][2])
							else:
								self.REX_R = "0"

							if len(self.second_operand_mem_address[1][0]) > 0:
								self.REX_B = str(register_code_map[self.second_operand_mem_address[1][0]][2])
							else:
								self.REX_B = "0"

							self.REX = "0100" + self.REX_W + self.REX_R + self.REX_X + self.REX_B

						if len(self.second_operand_mem_address[1][0]) == 0: #	no base -> direct addressing
							self.MOD = "00"
							self.RM = "100"

							self.SS = "00"
							self.INDEX = "100"
							self.BASE = "101"
							self.SIB = self.SS + self.INDEX + self.BASE


						else: #		base + displacement
							self.RM = register_code_map[self.second_operand_mem_address[1][0]][1]

						if len(self.second_operand_mem_address[1][3]) != 0: #	displacement

							if len(self.second_operand_mem_address[1][3])-2 < 2:
								for i in range(len(self.second_operand_mem_address[1][3])-2, 2):
									self.second_operand_mem_address[1][3] = '0x0' + self.second_operand_mem_address[1][3][2:]

							elif 2 < len(self.second_operand_mem_address[1][3])-2 < 8:
								for i in range(len(self.second_operand_mem_address[1][3])-2, 8):
									self.second_operand_mem_address[1][3] = '0x0' + self.second_operand_mem_address[1][3][2:]

							for i in range(len(self.second_operand_mem_address[1][3]) - 2, 1, -2):
								self.DISPLACEMENT += (self.second_operand_mem_address[1][3][i] + self.second_operand_mem_address[1][3][i+1])

					else: #		has index -> SIB
						# print ("data size: ", self.data_size, self.has_REX)
						if self.has_REX:
							if self.data_size == 64:
								self.REX_W = "1"
							else:
								self.REX_W = "0"

							self.REX_X = str(register_code_map[self.second_operand_mem_address[1][1]][2])

							if not self.second_operand_is_imm:
								self.REX_R = str(register_code_map[self.first_operand_reg_name][2])
							else:
								self.REX_R = "0"

							if len(self.second_operand_mem_address[1][0]) > 0:
								self.REX_B = str(register_code_map[self.second_operand_mem_address[1][0]][2])
							else:
								self.REX_B = "0"

							self.REX = "0100" + self.REX_W + self.REX_R + self.REX_X + self.REX_B	

						self.RM = "100"
						self.INDEX = register_code_map[self.second_operand_mem_address[1][1]][1]

						if self.second_operand_mem_address[1][2] == '1':
							self.SS = "00"
						elif self.second_operand_mem_address[1][2] == '2':
							self.SS = "01"
						elif self.second_operand_mem_address[1][2] == '4':
							self.SS = "10"
						elif self.second_operand_mem_address[1][2] == '8':
							self.SS = "11"

						if len(self.second_operand_mem_address[1][0]) == 0:
							self.BASE = "101"
						else:
							self.BASE = register_code_map[self.second_operand_mem_address[1][0]][1]

						self.SIB = self.SS + self.INDEX + self.BASE

					# Displacement

					# print (self.second_operand_mem_address[1][3][2], " -- ", int(self.second_operand_mem_address[1][3][2], 16))

					if self.second_operand_mem_address[1][0] == "": # No base -> 32 bit displacement
						for i in range(max(len(self.second_operand_mem_address[1][3])-2, 0), 8):
							self.second_operand_mem_address[1][3] = '0x0' + self.second_operand_mem_address[1][3][2:]

						self.DISPLACEMENT = ""
						for i in range(len(self.second_operand_mem_address[1][3]) - 2, 1, -2):
							self.DISPLACEMENT += (self.second_operand_mem_address[1][3][i] + self.second_operand_mem_address[1][3][i+1])

					elif len(self.second_operand_mem_address[1][3]) == 4 and int(self.second_operand_mem_address[1][3][2], 16) > 8:
						self.MOD = "10"
						for i in range(len(self.second_operand_mem_address[1][3])-2, 8):
							self.second_operand_mem_address[1][3] = '0x0' + self.second_operand_mem_address[1][3][2:]
						self.DISPLACEMENT = ""
						for i in range(len(self.second_operand_mem_address[1][3]) - 2, 1, -2):
							self.DISPLACEMENT += (self.second_operand_mem_address[1][3][i] + self.second_operand_mem_address[1][3][i+1])

					elif len(self.second_operand_mem_address[1][3]) != 0: #	displacement
						if len(self.second_operand_mem_address[1][3])-2 < 2:
							for i in range(len(self.second_operand_mem_address[1][3])-2, 2):
								self.second_operand_mem_address[1][3] = '0x0' + self.second_operand_mem_address[1][3][2:]

						elif 2 < len(self.second_operand_mem_address[1][3])-2 < 8:
							for i in range(len(self.second_operand_mem_address[1][3])-2, 8):
								self.second_operand_mem_address[1][3] = '0x0' + self.second_operand_mem_address[1][3][2:]

						self.DISPLACEMENT = ""
						for i in range(len(self.second_operand_mem_address[1][3]) - 2, 1, -2):
							self.DISPLACEMENT += (self.second_operand_mem_address[1][3][i] + self.second_operand_mem_address[1][3][i+1])
				
			if self.instruction in ["xchg", "test"]:
				self.D = ""
			if self.instruction in ["bsf", "bsr"]:
				self.D = ""
				self.W = ""

			if self.instruction in ["shl", "shr"]:
				if self.first_operand_reg_name == "cl" or self.second_operand_reg_name == "cl":
					self.D = "1"
					self.OPCDOE = opcode_map[self.instruction][0]
					self.REG = opcode_map[self.instruction][1]

				elif self.second_operand_is_imm:
					self.OPCDOE = "1100000"
					self.REG = opcode_map[self.instruction][1]
					self.D = ""
					for i in range(len(self.second_operand_imm)-2, 2):
						self.second_operand_imm = '0x0' + self.second_operand_imm[2:]

					for i in range(len(self.second_operand_imm) - 2, 1, -2):
						self.DISPLACEMENT += (self.second_operand_imm[i] + self.second_operand_imm[i+1])

			elif self.second_operand_is_imm:
				self.OPCDOE = opcode_imm[instruction][0]
				self.REG = opcode_imm[instruction][1]
				if self.second_operand_data_size <= 2:
					self.D = "1"
				else:
					self.D = "0"

				for i in range(len(self.second_operand_imm)-2, self.second_operand_data_size):
					self.second_operand_imm = '0x0' + self.second_operand_imm[2:]

				for i in range(len(self.second_operand_imm) - 2, 1, -2):
					self.DISPLACEMENT += (self.second_operand_imm[i] + self.second_operand_imm[i+1])

			# print (self.OPCDOE, self.RM, self.REG, self.second_operand_reg_name)
			# print (self.REX)

			if self.instruction in ["bsf", "bsr"]:
				self.REG, self.RM = self.RM, self.REG
				self.REX = "0100" + self.REX_W + self.REX_B + self.REX_X + self.REX_R

			ans = self.REX + self.OPCDOE + self.D + self.W + self.MOD + self.REG + self.RM + self.SIB
			if self.instruction == "xadd":
				ans = self.REX + "00001111" + self.OPCDOE + self.D + self.W + self.MOD + self.REG + self.RM + self.SIB
			if self.instruction == "imul" and not self.first_operand_is_mem and not self.second_operand_is_mem:
				self.REX = "0100" + self.REX_W + self.REX_B + self.REX_X + self.REX_R
				ans = self.REX + "00001111" + "10101111" + self.MOD + self.RM + self.REG + self.SIB				

			# print (ans)
			ans = str( hex( int((ans), 2)))[2:]
			ans = ans.zfill(len(ans) + (len(ans)%2))
			self.FINAL = self.PREFIX + ans + self.DISPLACEMENT

		if self.number_operands == 1:
			if is_mem_access(operands[0]):
				self.first_operand_is_mem = True

				mem_dissected = dissect_mem(operands[0])
				
				self.first_operand_mem_size = mem_dissected[0]
				self.first_operand_mem_address = mem_dissected[1]
				
				self.first_operand_mem_address = dissect_address(mem_dissected[1])

				self.address_size = self.first_operand_mem_address[0]

				self.data_size = self.first_operand_mem_size

			elif is_immidiate(operands[0]):
				self.first_operand_is_imm = True
				self.first_operand_imm = is_immidiate(operands[0])
				self.first_operand_data_size = 2
				if self.first_operand_imm > 127:
					self.first_operand_data_size = 8

				self.first_operand_imm = str(hex(self.first_operand_imm))

			else:
				self.first_operand_reg_size = register_code_map[operands[0]][0]
				self.first_operand_reg_name = operands[0]
				self.data_size = self.first_operand_reg_size

			if not self.first_operand_is_imm:
				if (not self.first_operand_is_mem and self.first_operand_reg_name in new_registers):
					self.has_REX = True

				if self.first_operand_is_mem and len(self.first_operand_mem_address[1][0]) != 0 and self.first_operand_mem_address[1][0] in new_registers:
					self.has_REX = True

				if self.first_operand_is_mem and len(self.first_operand_mem_address[1][1]) != 0 and self.first_operand_mem_address[1][1] in new_registers:
					self.has_REX = True

				if self.data_size == 64 and not self.first_operand_is_imm:
					self.has_REX = True
					self.REX_W = "1"

				# print (self.data_size, self.first_operand_is_imm)

				# prefix
				if (self.address_size == 32):
					self.PREFIX += "67"
				if (self.data_size == 16):
					self.PREFIX += "66"

				#opcode
				self.OPCDOE = opcode_map[self.instruction][0]

				#W
				if self.data_size != 8:
					self.W = "1"
				else:
					self.W = "0"
				if self.instruction[0] == 'j' or self.instruction == "call":
					self.W = ""

				# reg
				self.REG = opcode_map[self.instruction][1]

				if not self.first_operand_is_mem:
					self.MOD = "11"
					self.RM = register_code_map[self.first_operand_reg_name][1]

					if self.has_REX:
						if self.data_size == 64:
							self.REX_W = "1"
						else:
							self.REX_W = "0"

						self.REX_X = "0"
						self.REX_R = "0"
						self.REX_B = str( register_code_map[self.first_operand_reg_name][2] )

						self.REX = "0100" + self.REX_W + self.REX_R + self.REX_X + self.REX_B

				else:
					if len(self.first_operand_mem_address[1][3]) == 0:
						self.MOD = "00"
					elif len(self.first_operand_mem_address[1][3])-2 <= 2:
						self.MOD = "01"
					else:
						self.MOD = "10"

					# print (self.first_operand_mem_address[1][0][-2:])

					if len(self.first_operand_mem_address[1][0]) != 0 and self.first_operand_mem_address[1][0][-2:] == "bp" and self.MOD == "00":
						self.MOD = "01"
						self.first_operand_mem_address[1][3] = "0x00"
				
					if len(self.first_operand_mem_address[1][1]) == 0: #	no index
						if self.has_REX:
							if self.data_size == 64:
								self.REX_W = "1"
							else:
								self.REX_W = "0"

							self.REX_X = "0"
							self.REX_R = "0"

						if len(self.first_operand_mem_address[1][0]) == 0: #	no base -> direct addressing
							self.MOD = "00"
							self.RM = "100"

							self.SS = "00"
							self.INDEX = "100"
							self.BASE = "101"
							self.SIB = self.SS + self.INDEX + self.BASE

							self.REX_B = "0"

						else: #		base + displacement
							self.REX_B = str(register_code_map[self.first_operand_mem_address[1][0]][2])
							self.RM = register_code_map[self.first_operand_mem_address[1][0]][1]

						if len(self.first_operand_mem_address[1][3]) != 0: #	displacement

							if len(self.first_operand_mem_address[1][3])-2 < 2:
								for i in range(len(self.first_operand_mem_address[1][3])-2, 2):
									self.first_operand_mem_address[1][3] = '0x0' + self.first_operand_mem_address[1][3][2:]

							elif 2 < len(self.first_operand_mem_address[1][3])-2 < 8:
								for i in range(len(self.first_operand_mem_address[1][3])-2, 8):
									self.first_operand_mem_address[1][3] = '0x0' + self.first_operand_mem_address[1][3][2:]

							for i in range(len(self.first_operand_mem_address[1][3]) - 2, 1, -2):
								self.DISPLACEMENT += (self.first_operand_mem_address[1][3][i] + self.first_operand_mem_address[1][3][i+1])

						if self.has_REX:
							self.REX = "0100" + self.REX_W + self.REX_R + self.REX_X + self.REX_B

					else: #		has index -> SIB
						# print ("data size: ", self.data_size, self.has_REX)
						if self.has_REX:
							if self.data_size == 64:
								self.REX_W = "1"
							else:
								self.REX_W = "0"

							self.REX_X = str(register_code_map[self.first_operand_mem_address[1][1]][2])
							self.REX_R = "0"
							self.REX_B = str(register_code_map[self.first_operand_mem_address[1][0]][2])
							self.REX = "0100" + self.REX_W + self.REX_R + self.REX_X + self.REX_B	

						self.RM = "100"
						self.INDEX = register_code_map[self.first_operand_mem_address[1][1]][1]

						if self.first_operand_mem_address[1][2] == '1':
							self.SS = "00"
						elif self.first_operand_mem_address[1][2] == '2':
							self.SS = "01"
						elif self.first_operand_mem_address[1][2] == '4':
							self.SS = "10"
						elif self.first_operand_mem_address[1][2] == '8':
							self.SS = "11"

						if len(self.first_operand_mem_address[1][0]) == 0:
							self.BASE = "101"
						else:
							self.BASE = register_code_map[self.first_operand_mem_address[1][0]][1]

						# print (self.SS , self.INDEX , self.BASE)
						self.SIB = self.SS + self.INDEX + self.BASE

					# Displacement
					if self.first_operand_mem_address[1][0] == "": # No base -> 32 bit displacement
						for i in range(max(len(self.first_operand_mem_address[1][3])-2, 0), 8):
							self.first_operand_mem_address[1][3] = '0x0' + self.first_operand_mem_address[1][3][2:]

						self.DISPLACEMENT = ""
						for i in range(len(self.first_operand_mem_address[1][3]) - 2, 1, -2):
							self.DISPLACEMENT += (self.first_operand_mem_address[1][3][i] + self.first_operand_mem_address[1][3][i+1])

					elif len(self.first_operand_mem_address[1][3]) == 4 and int(self.first_operand_mem_address[1][3][2], 16) > 8:
						self.MOD = "10"
						for i in range(len(self.first_operand_mem_address[1][3])-2, 8):
							self.first_operand_mem_address[1][3] = '0x0' + self.first_operand_mem_address[1][3][2:]
						self.DISPLACEMENT = ""
						for i in range(len(self.first_operand_mem_address[1][3]) - 2, 1, -2):
							self.DISPLACEMENT += (self.first_operand_mem_address[1][3][i] + self.first_operand_mem_address[1][3][i+1])

					elif len(self.first_operand_mem_address[1][3]) != 0: #	displacement
						if len(self.first_operand_mem_address[1][3])-2 < 2:
							for i in range(len(self.first_operand_mem_address[1][3])-2, 2):
								self.first_operand_mem_address[1][3] = '0x0' + self.first_operand_mem_address[1][3][2:]

						elif 2 < len(self.first_operand_mem_address[1][3])-2 < 8:
							for i in range(len(self.first_operand_mem_address[1][3])-2, 8):
								self.first_operand_mem_address[1][3] = '0x0' + self.first_operand_mem_address[1][3][2:]

						self.DISPLACEMENT = ""
						for i in range(len(self.first_operand_mem_address[1][3]) - 2, 1, -2):
							self.DISPLACEMENT += (self.first_operand_mem_address[1][3][i] + self.first_operand_mem_address[1][3][i+1])
			
			elif self.instruction[0] == 'j':
				if self.first_operand_is_imm:
					self.REX = ""
					self.W = ""
					self.MOD = ""
					self.REG = ""
					self.RM = ""
					self.SIB = ""

					for i in range(len(self.first_operand_imm)-2, self.first_operand_data_size):
						self.first_operand_imm = '0x0' + self.first_operand_imm[2:]
					self.DISPLACEMENT = ""
					for i in range(len(self.first_operand_imm) - 2, 1, -2):
						self.DISPLACEMENT += (self.first_operand_imm[i] + self.first_operand_imm[i+1])

					cond = self.instruction[1:]
					# print (cond, self.DISPLACEMENT, self.first_operand_imm)

					if cond == "mp":
						self.OPCDOE = opcode_map["jmp"+str(self.first_operand_data_size * 4)]
					else:
						self.OPCDOE = opcode_map["jcc"+str(self.first_operand_data_size * 4)] + tttn_map[cond.upper()]

			elif self.instruction == "call":
				self.REX = ""
				self.W = ""
				self.MOD = ""
				self.REG = ""
				self.RM = ""
				self.SIB = ""

				for i in range(len(self.first_operand_imm)-2, 8):
					self.first_operand_imm = '0x0' + self.first_operand_imm[2:]
				self.DISPLACEMENT = ""
				for i in range(len(self.first_operand_imm) - 2, 1, -2):
					self.DISPLACEMENT += (self.first_operand_imm[i] + self.first_operand_imm[i+1])

				self.OPCDOE = opcode_map["call32"]

			if self.instruction in ["shl", "shr"]:
				self.W = "0" + self.W

			if self.instruction in ["imul"]:
				self.OPCDOE = "1111011"
				self.REG = "101"


			ans = self.REX + self.OPCDOE + self.W + self.MOD + self.REG + self.RM + self.SIB

			# print ("--> ", self.REX , self.OPCDOE , self.W , self.MOD , self.REG , self.RM , self.SIB)
			# print (ans)
			ans = str( hex( int((ans), 2)))[2:]
			# print (ans)
			ans = ans.zfill(len(ans) + (len(ans)%2))
			self.FINAL = self.PREFIX + ans + self.DISPLACEMENT

		elif self.number_operands == 0:
			self.FINAL = str( hex( int((opcode_map[self.instruction]), 2)))[2:]
			self.FINAL = self.FINAL.zfill(len(self.FINAL) + len(self.FINAL)%2)

# input_command = "add rax,QWORD ptr [eax+ebx*4]"
input_command = input()

# exit()

# print (dissect_address(input_command))

if " " in input_command:
	first_space = 0
	while input_command[first_space] != " ":
		first_space += 1

	instruction = input_command[0:first_space]
	operands = input_command[first_space+1:]
	operands = operands.split(',')

	if instruction in ["shl", "shr"]:
		if len(operands) == 2 and operands[1] == "1":
			operands = [operands[0]]

	if instruction == "imul" and len(operands) == 3:
		operands_red = operands[:2]
		imm_data = str(hex(int(operands[2])))[2:]
		D = "0"
		if len(imm_data) <= 2:
			D = "1"

		data = ""
		sz = 8

		if D == "1":
			sz = 2

		imm_data = "0"*(sz - len(imm_data)) + imm_data

		for i in range(len(imm_data)-2, -1, -2):
			data += imm_data[i] + imm_data[i+1]

		command = Command(instruction= instruction, operands= operands_red)
		cd = command.REX + "011010" + D + "1" + command.MOD + command.RM + command.REG + command.SIB 
		if command.second_operand_is_mem or command.first_operand_is_mem:
			cd = command.REX + "011010" + D + "1" + command.MOD + command.REG + command.RM + command.SIB 
		cd = str( hex( int((cd), 2)))[2:]
		cd = cd.zfill(len(cd) + (len(cd)%2))
		cd = command.PREFIX + cd + data
		print (cd)
	else:
		command = Command(instruction= instruction, operands= operands)
		print (command.FINAL)

else:
	command = Command(instruction= input_command, operands=[])
	print (command.FINAL)

