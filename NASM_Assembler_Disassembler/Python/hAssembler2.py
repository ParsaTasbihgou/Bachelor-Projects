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

def is_mem_access(str):
	if len(str) == 0:
		return False
	if (str[0] == '['):
		return True
	str_split = str.split()
	if str_split[0] in mem_size_id:
		return True

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
	"xadd": "110000",
	"imul": "111101"
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

	address_size = 0
	data_size = 0

	has_REX = False

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

			else:
				self.first_operand_reg_size = register_code_map[operands[0]][0]
				self.first_operand_reg_name = operands[0]

			self.data_size = max(self.first_operand_reg_size, self.second_operand_reg_size)

			# print (self.data_size)

			if (not self.first_operand_is_mem and self.first_operand_reg_name[0] == 'r') or (not self.second_operand_is_mem and self.second_operand_reg_name[0] == 'r'):
				self.has_REX = True

			if self.first_operand_is_mem and len(self.first_operand_mem_address[1][0]) != 0 and self.first_operand_mem_address[1][0][0] == 'r':
				self.has_REX = True

			if self.first_operand_is_mem and len(self.first_operand_mem_address[1][1]) != 0 and self.first_operand_mem_address[1][1][0] == 'r':
				self.has_REX = True

			if self.second_operand_is_mem and len(self.second_operand_mem_address[1][0]) != 0 and self.second_operand_mem_address[1][0][0] == 'r':
				self.has_REX = True

			if self.second_operand_is_mem and len(self.second_operand_mem_address[1][1]) != 0 and self.second_operand_mem_address[1][1][0] == 'r':
				self.has_REX = True				


			#prefix
			if (self.data_size == 16):
				self.PREFIX += "66"
			if (self.address_size == 32):
				self.PREFIX += "67"

			#opcode
			self.OPCDOE = opcode_map[self.instruction]

			#D
			if self.second_operand_is_mem:
				self.D = "1"

			#W
			if self.data_size != 8:
				self.W = "1"

			#MOD

			#reg-reg
			if not self.first_operand_is_mem and not self.second_operand_is_mem:
				self.MOD = "11"
				self.REG = register_code_map[self.second_operand_reg_name][1]
				self.RM = register_code_map[self.first_operand_reg_name][1]

				if self.has_REX:
					if self.data_size == 64:
						self.REX_W = "1"
					else:
						self.REX_W = "0"

					self.REX_X = "0"

					self.REX_R = str( register_code_map[self.second_operand_reg_name][2] )
					self.REX_B = str( register_code_map[self.first_operand_reg_name][2] )

					self.REX = "0100" + self.REX_W + self.REX_R + self.REX_X + self.REX_B


			#reg-mem
			elif self.second_operand_is_mem and (not self.first_operand_is_mem): #	first operand must be register
				self.REG = register_code_map[self.first_operand_reg_name][1]

				if len(self.second_operand_mem_address[1][3]) == 0:
					self.MOD = "00"
				elif len(self.second_operand_mem_address[1][3])-2 <= 2:
					self.MOD = "01"
				else:
					self.MOD = "10"
			
				if len(self.second_operand_mem_address[1][1]) == 0: #	no index
					if self.has_REX:
						if self.data_size == 64:
							self.REX_W = "1"
						else:
							self.REX_W = "0"

						self.REX_X = "0"
						self.REX_R = str(register_code_map[self.first_operand_reg_name][2])
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
						if self.has_REX:
							if self.data_size == 64:
								self.REX_W = "1"
							else:
								self.REX_W = "0"

							self.REX_X = str(register_code_map[self.second_operand_mem_address[1][1]][2])
							self.REX_R = str(register_code_map[self.first_operand_reg_name][2])
							if len(self.second_operand_mem_address[1][0]) > 0:
								self.REX_B = str(register_code_map[self.second_operand_mem_address[1][0]][2])
							else:
								self.REX_B = "0"

							self.REX = "0100" + self.REX_W + self.REX_R + self.REX_X + self.REX_B	

						self.MOD = "00"
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
							self.BASE = register[self.second_operand_mem_address[1][0]][1]

						self.SIB = self.SS + self.INDEX + self.BASE

						if len(self.second_operand_mem_address[1][3]) == 0:
							self.second_operand_mem_address[1][3] = "0x00000000"

						if len(self.second_operand_mem_address[1][3]) != 0: #	displacement
							if len(self.second_operand_mem_address[1][3])-2 < 2:
								for i in range(len(self.second_operand_mem_address[1][3])-2, 2):
									self.second_operand_mem_address[1][3] = '0x0' + self.second_operand_mem_address[1][3][2:]

							elif 2 < len(self.second_operand_mem_address[1][3])-2 < 8:
								for i in range(len(self.second_operand_mem_address[1][3])-2, 8):
									self.second_operand_mem_address[1][3] = '0x0' + self.second_operand_mem_address[1][3][2:]

							for i in range(len(self.second_operand_mem_address[1][3]) - 2, 1, -2):
								self.DISPLACEMENT += (self.second_operand_mem_address[1][3][i] + self.second_operand_mem_address[1][3][i+1])
				

			ans = self.REX + self.OPCDOE + self.D + self.W + self.MOD + self.REG + self.RM + self.SIB
			if self.instruction == "xadd":
				ans = self.REX + "00001111" + self.OPCDOE + self.D + self.W + self.MOD + self.REG + self.RM

			print (ans)
			self.FINAL = self.PREFIX + str( hex( int((ans), 2)))[2:] + self.DISPLACEMENT

		if self.number_operands == 1:
			if is_mem_access(operands[0]):
				self.first_operand_is_mem = True

				mem_dissected = dissect_mem(operands[0])
				
				self.first_operand_mem_size = mem_dissected[0]
				self.first_operand_mem_address = mem_dissected[1]
				self.address_size = mem_dissected[2]
			else:
				self.first_operand_reg_size = register_code_map[operands[0]][0]


# input_command = "add rax,QWORD ptr [eax+ebx*4]"
input_command = input()


# print (dissect_address(input_command))

first_space = 0
while input_command[first_space] != " ":
	first_space += 1

instruction = input_command[0:first_space]
operands = input_command[first_space+1:]
operands = operands.split(',')

command = Command(instruction= instruction, operands= operands)

print (command.FINAL)
