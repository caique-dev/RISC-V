// #include <unistd.h>

#define STDIN_FD  0
#define STDOUT_FD 1

// Enum of possible instruction types
typedef enum InstType { R, I, S, B, U, J} InstType;

// Struct with instruction data
typedef struct InstData {
    int opcode,
        rd,
        rs1,
        rs2,
        imm,
        funct3,
        funct7;
    InstType type;
} InstData;


// read function.
// Parameters: 
//    - __fd: file descriptor.
//    - __buff: destination buffer address.
//    - __n: number of bytes to read.
//
// Returns: number of bytes read 
int read(int __fd, const void *__buf, int __n){
  int bytes;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall read (63) \n"
    "ecall \n"
    "mv %0, a0"
    : "=r"(bytes)
    :"r"(__fd), "r"(__buf), "r"(__n)
    : "a0", "a1", "a2", "a7"
  );
  return bytes;
}

// write function.
// Parameters: 
//    - __fd: file descriptor.
//    - __buff: source buffer address.
//    - __n: number of bytes to write.

// Returns: (nothing)
void write(int __fd, const void *__buf, int __n){
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :
    :"r"(__fd), "r"(__buf), "r"(__n)
    : "a0", "a1", "a2", "a7"
  );
}

// exit function.
// Parameters: 
//    - code: exit code.
//
// Returns: (nothing)
void exit(int code)
{
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (93) \n"
    "ecall"
    :
    :"r"(code)
    : "a0", "a7"
  );
}

// Receives an int value and then display its hexadecimal representation in STDOUT.
// Parameters: 
//    - val: value to convert to hexadecimal representaion and display.
//
// Returns: (nothing)
void hex_code(int val){
    char hex[11];
    unsigned int uval = (unsigned int) val, aux;
    
    hex[0] = '0';
    hex[1] = 'x';
    hex[10] = '\n';

    for (int i = 9; i > 1; i--){
        aux = uval % 16;
        if (aux >= 10)
            hex[i] = aux - 10 + 'A';
        else
            hex[i] = aux + '0';
        uval = uval / 16;
    }
    write(1, hex, 11);
}

// Compares the first n_char characters of two strings.
// Parameters: 
//    - str1: first string.
//    - str2: second string.
//    - n_char: number of chars to compare.
//
// Returns: 0 if the strings are equal, 1 or -1 if they are different
int strcmp_custom(char *str1, char *str2, int n_char){
    for (int i = 0; i < n_char; i++){
        if (str1[i] < str2 [i])
            return -1;
        else if (str1[i] > str2 [i])
            return 1;
    }    
    return 0;
}

// Reads a string of characters representing a number in decimal base from a buffer, converts to int and updates the number of chars read from the buffer.
// Parameters: 
//    - buffer: buffer address.
//    - read_chars: pointer to variable to be updated with the number of chars read form the buffer.
//
// Returns: int value computed from the 
int dec_to_int(char buffer[], int *read_chars){
    int neg = 0, val = 0, curr;
    if (buffer[0] == '-')
        neg = 1;

    curr = neg;
    while(buffer[curr] >= '0' && buffer[curr] <= '9'){
        val = val*10;
        val = val + buffer[curr] - '0';
        curr++;
    }
    if (neg == 1)
        val = -val;
    *read_chars += curr + 1;
    return val;
}

// Gets the register id from a buffer and updates the number of chars read.
// Parameters: 
//    - buffer: buffer address.
//    - read_chars: pointer to variable to be updated with the number of chars read form the buffer.
//
// Returns: Register id 
int get_register(char buffer[], int *read_chars){
    int curr = 0;
    while (buffer[curr] != 'x'){
        curr++;
    }
    curr++;
    *read_chars += curr;
    return dec_to_int(&buffer[curr], read_chars);
}

// Gets the immediate value from a buffer and updates the number of chars read.
// Parameters: 
//    - buffer: buffer address.
//    - read_chars: pointer to variable to be updated with the number of chars read form the buffer .
//
// Returns: Immediate value
int get_immediate(char buffer[], int *read_chars){
    int curr = 0;

    while (!((buffer[curr] >= '0' && buffer[curr] <= '9') ||  buffer[curr] == '-')){
        curr++;
    }
    *read_chars += curr;
    return dec_to_int(&buffer[curr], read_chars);
}

// Parsing of instruction with format rd_imm.
// Parameters: 
//    - buffer: buffer address.
//    - rd: pointer to variable associated with destination register.
//    - imm: pointer to variable associated with immediate.
//    - start: index of where to start reading from the buffer.
//
// Returns: (nothing)
void rd_imm(char buffer[], int *rd, int *imm, int start){
    *rd = get_register(&buffer[start], &start);
    *imm = get_immediate(&buffer[start], &start);
}

// Parsing of instruction with format r1_r2_imm.
// Parameters: 
//    - buffer: buffer address.
//    - r1: pointer to variable associated with register 1.
//    - r2: pointer to variable associated with register 2.
//    - imm: pointer to variable associated with immediate.
//    - start: index of where to start reading from the buffer.
//
// Returns: (nothing)
void r1_r2_imm(char buffer[], int *r1, int *r2, int *imm, int start){
    *r1 = get_register(&buffer[start], &start);
    *r2 = get_register(&buffer[start], &start);
    *imm = get_immediate(&buffer[start], &start);
}

// Parsing of instruction with format r1_imm_r2.
// Parameters: 
//    - buffer: buffer address.
//    - r1: pointer to variable associated with register 1.
//    - r2: pointer to variable associated with register 2.
//    - imm: pointer to variable associated with immediate.
//    - start: index of where to start reading from the buffer.
//
// Returns: (nothing)
void r1_imm_r2(char buffer[], int *r1, int *r2, int *imm, int start){
    *r1 = get_register(&buffer[start], &start);
    *imm = get_immediate(&buffer[start], &start);
    *r2 = get_register(&buffer[start], &start);
}

// Parsing of instruction with format r1_r2_r3.
// Parameters: 
//    - buffer: buffer address.
//    - r1: pointer to variable associated with register 1.
//    - r2: pointer to variable associated with register 2.
//    - r3: pointer to variable associated with register 3.
//    - start: index of where to start reading from the buffer.
//
// Returns: (nothing)
void r1_r2_r3(char buffer[], int *r1, int *r2, int *r3, int start){
    *r1 = get_register(&buffer[start], &start);
    *r2 = get_register(&buffer[start], &start);
    *r3 = get_register(&buffer[start], &start);
}

// Parses a string with a RISC-V instruction and fills an InstData struct with the instruction's data.
// Parameters: 
//    - inst: instruction string.
//    - data: pointer to InstData struct.
//
// Returns: (nothing)
void get_inst_data(char inst[], InstData *data){
    int opcode = 0,
        rd = 0,
        rs1 = 0,
        rs2 = 0,
        imm = 0,
        funct3 = 0,
        funct7 = 0;
    InstType type = I;
    if (strcmp_custom(inst, "lui", 3) == 0){
        // lui rd, IMM
        // OPCODE = 0110111 = 55
        rd_imm(inst, &rd, &imm, 3);
        opcode = 55, type = U;
    } else if (strcmp_custom(inst, "auipc ", 6) == 0){
        // auipc rd, IMM
        // OPCODE = 0010111 = 23
        rd_imm(inst, &rd, &imm, 5);
        opcode = 23, type = U;
    } else if (strcmp_custom(inst, "jal ", 4) == 0){
        // jal rd, IMM
        // OPCODE = 1101111 = 111
        rd_imm(inst, &rd, &imm, 3);
        opcode = 111, type = J;
    } else if (strcmp_custom(inst, "jalr ", 5) == 0){
        // jalr rd, IMM(rs1)
        // OPCODE = 1100111 = 103  FUNCT3 = 0
        r1_imm_r2(inst, &rd, &rs1, &imm, 4);
        opcode = 103, type = I;
    } else if (strcmp_custom(inst, "beq ", 4) == 0){
        // beq rs1, rs2, IMM
        // OPCODE = 1100011 = 99 FUNCT3 = 0
        r1_r2_imm(inst, &rs1, &rs2, &imm, 3);
        opcode = 99, type = B;
    } else if (strcmp_custom(inst, "bne ", 4) == 0){
        // bne rs1, rs2, IMM
        // OPCODE = 1100011 = 99 FUNCT3 = 1
        r1_r2_imm(inst, &rs1, &rs2, &imm, 3);
        opcode = 99, funct3 = 1, type = B;
    } else if (strcmp_custom(inst, "blt ", 4) == 0){
        // blt rs1, rs2, IMM
        // OPCODE = 1100011 = 99 FUNCT3 = 4
        r1_r2_imm(inst, &rs1, &rs2, &imm, 3);
        opcode = 99, funct3 = 4, type = B;
    } else if (strcmp_custom(inst, "bge ", 4) == 0){
        // bge rs1, rs2, IMM
        // OPCODE = 1100011 = 99 FUNCT3 = 5
        r1_r2_imm(inst, &rs1, &rs2, &imm, 3);
        opcode = 99, funct3 = 5, type = B;
    } else if (strcmp_custom(inst, "bltu ", 5) == 0){
        // bltu rs1, rs2, IMM
        // OPCODE = 1100011 = 99 FUNCT3 = 6
        r1_r2_imm(inst, &rs1, &rs2, &imm, 4);
        opcode = 99, funct3 = 6, type = B;
    } else if (strcmp_custom(inst, "bgeu ", 5) == 0){
        // bgeu rs1, rs2, IMM
        // OPCODE = 1100011 = 99 FUNCT3 = 7
        r1_r2_imm(inst, &rs1, &rs2, &imm, 4);
        opcode = 99, funct3 = 7, type = B;
    } else if (strcmp_custom(inst, "lb ", 3) == 0){
        // lb rd, IMM(rs1)
        // OPCODE = 0000011 = 3 FUNCT3 = 0
        r1_imm_r2(inst, &rd, &rs1, &imm, 2);
        opcode = 3;
    } else if (strcmp_custom(inst, "lh ", 3) == 0){
        // lh rd, IMM(rs1)
        // OPCODE = 0000011 = 3 FUNCT3 = 1
        r1_imm_r2(inst, &rd, &rs1, &imm, 2);
        opcode = 3, funct3 = 1;
    } else if (strcmp_custom(inst, "lw ", 3) == 0){
        // lw rd, IMM(rs1)
        // OPCODE = 0000011 = 3 FUNCT3 = 2
        r1_imm_r2(inst, &rd, &rs1, &imm, 2);
        opcode = 3, funct3 = 2;
    } else if (strcmp_custom(inst, "lbu ", 4) == 0){
        // lbu rd, IMM(rs1)
        // OPCODE = 0000011 = 3 FUNCT3 = 4
        r1_imm_r2(inst, &rd, &rs1, &imm, 3);
        opcode = 3, funct3 = 4;
    } else if (strcmp_custom(inst, "lhu ", 4) == 0){
        // lhu rd, IMM(rs1)
        // OPCODE = 0000011 = 3 FUNCT3 = 5
        r1_imm_r2(inst, &rd, &rs1, &imm, 3);
        opcode = 3, funct3 = 5;
    } else if (strcmp_custom(inst, "sb ", 3) == 0){
        // sb rs2, IMM(rs1)
        // OPCODE = 0100011 = 35 FUNCT3 = 0
        r1_imm_r2(inst, &rs2, &rs1, &imm, 2);
        opcode = 35, type = S;
    } else if (strcmp_custom(inst, "sh ", 3) == 0){
        // sh rs2, IMM(rs1)
        // OPCODE = 0100011 = 35 FUNCT3 = 1
        r1_imm_r2(inst, &rs2, &rs1, &imm, 2);
        opcode = 35, funct3 = 1, type = S;
    } else if (strcmp_custom(inst, "sw ", 3) == 0){
        // sw rs2, IMM(rs1)
        // OPCODE = 0100011 = 35 FUNCT3 = 2
        r1_imm_r2(inst, &rs2, &rs1, &imm, 2);
        opcode = 35, funct3 = 2, type = S;
    } else if (strcmp_custom(inst, "addi ", 5) == 0){
        // addi rd, rs1, IMM
        // OPCODE = 0010011 = 19 FUNCT3 = 0
        r1_r2_imm(inst, &rd, &rs1, &imm, 4);
        opcode = 19;
    } else if (strcmp_custom(inst, "slti ", 5) == 0){
        // slti rd, rs1, IMM
        // OPCODE = 0010011 = 19 FUNCT3 = 2
        r1_r2_imm(inst, &rd, &rs1, &imm, 4);
        opcode = 19, funct3 = 2;
    } else if (strcmp_custom(inst, "sltiu ", 6) == 0){
        // sltiu rd, rs1, IMM
        // OPCODE = 0010011 = 19 FUNCT3 = 3
        r1_r2_imm(inst, &rd, &rs1, &imm, 4);
        opcode = 19, funct3 = 3;
    } else if (strcmp_custom(inst, "xori ", 5) == 0){
        // xori rd, rs1, IMM
        // OPCODE = 0010011 = 19 FUNCT3 = 4 
        r1_r2_imm(inst, &rd, &rs1, &imm, 4);
        opcode = 19, funct3 = 4;
    } else if (strcmp_custom(inst, "ori ", 4) == 0){
        // ori rd, rs1, IMM
        // OPCODE = 0010011 = 19 FUNCT3 = 6
        r1_r2_imm(inst, &rd, &rs1, &imm, 4);
        opcode = 19, funct3 = 6;
    } else if (strcmp_custom(inst, "andi ", 5) == 0){
        // andi rd, rs1, IMM
        // OPCODE = 0010011 = 19 FUNCT3 = 7
        r1_r2_imm(inst, &rd, &rs1, &imm, 4);
        opcode = 19, funct3 = 7;
    } else if (strcmp_custom(inst, "slli ", 5) == 0){
        // slli rd, rs1, shamt
        // OPCODE = 0010011 = 19 FUNCT3 = 1
        r1_r2_imm(inst, &rd, &rs1, &imm, 4);
        opcode = 19, imm = imm%32, funct3 = 1;
    } else if (strcmp_custom(inst, "srli ", 5) == 0){
        // srli rd, rs1, shamt
        // OPCODE = 0010011 = 19 FUNCT3 = 5
        r1_r2_imm(inst, &rd, &rs1, &imm, 4);
        opcode = 19, imm = imm%32, funct3 = 5;
    } else if (strcmp_custom(inst, "srai ", 5) == 0){
        // srai rd, rs1, shamt
        // OPCODE = 0010011 = 19 FUNCT3 = 5
        r1_r2_imm(inst, &rd, &rs1, &imm, 4);
        opcode = 19, imm = imm%32 + 1024, funct3 = 5, funct7 = 32;
    } else if (strcmp_custom(inst, "add ", 4) == 0){
        // add rd, rs1, rs2
        // OPCODE = 0110011 = 51 FUNCT3 = 0  FUNCT7 = 0 
        r1_r2_r3(inst, &rd, &rs1, &rs2, 3);
        opcode = 51, type = R;
    } else if (strcmp_custom(inst, "sub ", 4) == 0){
        // sub rd, rs1, rs2
        // OPCODE = 0110011 = 51 FUNCT3 = 0  FUNCT7 = 32 
        r1_r2_r3(inst, &rd, &rs1, &rs2, 3);
        opcode = 51, funct7 = 32, type = R;
    } else if (strcmp_custom(inst, "sll ", 4) == 0){
        // sll rd, rs1, rs2
        // OPCODE = 0110011 = 51 FUNCT3 = 1  FUNCT7 = 0 
        r1_r2_r3(inst, &rd, &rs1, &rs2, 3);
        opcode = 51, funct3 = 1, type = R;
    } else if (strcmp_custom(inst, "slt ", 4) == 0){
        // slt rd, rs1, rs2
        // OPCODE = 0110011 = 51 FUNCT3 = 2  FUNCT7 = 0 
        r1_r2_r3(inst, &rd, &rs1, &rs2, 3);
        opcode = 51, funct3 = 2, type = R;
    } else if (strcmp_custom(inst, "sltu ", 5) == 0){
        // sltu rd, rs1, rs2
        // OPCODE = 0110011 = 51 FUNCT3 = 3  FUNCT7 = 0  
        r1_r2_r3(inst, &rd, &rs1, &rs2, 4);
        opcode = 51, funct3 = 3, type = R;
    } else if (strcmp_custom(inst, "xor ", 4) == 0){
        // xor rd, rs1, rs2
        // OPCODE = 0110011 = 51 FUNCT3 = 4  FUNCT7 = 0  
        r1_r2_r3(inst, &rd, &rs1, &rs2, 3);
        opcode = 51, funct3 = 4, type = R;
    } else if (strcmp_custom(inst, "srl ", 4) == 0){
        // srl rd, rs1, rs2
        // OPCODE = 0110011 = 51 FUNCT3 = 5  FUNCT7 = 0  
        r1_r2_r3(inst, &rd, &rs1, &rs2, 3);
        opcode = 51, funct3 = 5, type = R;
    } else if (strcmp_custom(inst, "sra ", 4) == 0){
        // sra rd, rs1, rs2
        // OPCODE = 0110011 = 51 FUNCT3 = 5  FUNCT7 = 32  
        r1_r2_r3(inst, &rd, &rs1, &rs2, 3);
        opcode = 51, funct3 = 5, funct7 = 32, type = R;
    } else if (strcmp_custom(inst, "or ", 3) == 0){
        // or rd, rs1, rs2
        // OPCODE = 0110011 = 51 FUNCT3 = 6  FUNCT7 = 0  
        r1_r2_r3(inst, &rd, &rs1, &rs2, 2);
        opcode = 51, funct3 = 6, type = R;
    } else if (strcmp_custom(inst, "and ", 4) == 0){
        // and rd, rs1, rs2
        // OPCODE = 0110011 = 51 FUNCT3 = 7  FUNCT7 = 0  
        r1_r2_r3(inst, &rd, &rs1, &rs2, 3);
        opcode = 51, funct3 = 7, type = R;
    }
    data->opcode = opcode;
    data->rd = rd;
    data->rs1 = rs1;
    data->rs2 = rs2;
    data->imm = imm;
    data->funct3 = funct3;
    data->funct7 = funct7;
    data->type = type;
    return;
}

void slice_5(char * vet_ori, char * vet_destino, int inicio) {
  int i = 0;
  for (int counter = inicio; counter < inicio + 5; counter++) {
    vet_destino[i] = vet_ori[counter];
    i++;
  }
  vet_destino[i] = '\0';
} 

int potencia(int base, int exp) {
  if (exp == 0) {
    return 1;
  } else {
    return base * potencia(base, exp - 1);
  }
}

int char_to_int(char * vet) {
  int acumulador = 0;

  for (int i = 1; i < 5; i++) {
    int digito = vet[i] - '0';
    acumulador += digito * potencia(10, 4-i);
  }
  if (vet[0] == '-') {
    return (-1) * acumulador;
  }

  return acumulador;
}

int mask_generator(int qntd_uns, int zeros_esq) {
  int mask = -1;

  mask = (unsigned)mask >> 32 - qntd_uns;
  mask = mask << zeros_esq;

  return mask;  
}

int pack(int input, int start_bit, int end_bit, int * destino) {
  // deslocando o input
  int qntd_uns = (end_bit - start_bit) + 1 < 0 ? -((end_bit - start_bit) + 1) : (end_bit - start_bit) + 1; 
  int mask = mask_generator(qntd_uns, start_bit);
  input = input & mask;

  *destino = *destino | (unsigned)(input >> start_bit);

}

int main()
{
    InstData data;
    char input[40];

    read(STDIN_FD, input, 40);

    get_inst_data(input, &data);

    int field_size = 0;
    int resultado = 0;   
    int rd_size = 5;

    switch (data.type) {
        // TIPO R
        case R:
            // funct7
            field_size = 7;
            resultado <<= field_size;
            pack(data.funct7, 0, field_size-1, &resultado);

            // rs2
            field_size = 5;
            resultado <<= field_size;
            pack(data.rs2, 0, field_size-1, &resultado);

            // rs1
            field_size = 5;
            resultado <<= field_size;
            pack(data.rs1, 0, field_size-1, &resultado);
            
            // funct3
            field_size = 3;
            resultado <<= field_size;
            pack(data.funct3, 0, field_size-1, &resultado);        
        break;
    
        case I:
            // imm
            field_size = 12;
            resultado <<= field_size;
            pack(data.imm, 0, field_size-1, &resultado);

            // rs1
            field_size = 5;
            resultado <<= field_size;
            pack(data.rs1, 0, field_size-1, &resultado);

            // funct3
            field_size = 3;
            resultado <<= field_size;
            pack(data.funct3, 0, field_size-1, &resultado);
        break;

        case S:
            // imm
            field_size = 7;
            resultado <<= field_size;
            pack(data.imm, 5, 11, &resultado);

            // rs2
            field_size = 5;
            resultado <<= field_size;
            pack(data.rs2, 0, field_size-1, &resultado);

            // rs1
            field_size = 3;
            resultado <<= field_size;
            pack(data.rs1, 0, field_size-1, &resultado);

            // funct3
            field_size = 3;
            resultado <<= field_size;
            pack(data.funct3, 0, field_size-1, &resultado);

            // imm
            field_size = 5;
            resultado <<= field_size;
            pack(data.imm, 0, field_size-1, &resultado);
        break;

        case B:
            // imm primeiro
            field_size = 1;
            resultado <<= field_size;
            pack(data.imm, 12, 12, &resultado);

            // imm segundo
            field_size = 6;
            resultado <<= field_size;
            pack(data.imm, 5, 10, &resultado);
            
            // rs2 terceiro
            field_size = 5;
            resultado <<= field_size;
            pack(data.rs2, 0, field_size-1, &resultado);

            // rs1 quarto
            field_size = 5;
            resultado <<= field_size;
            pack(data.rs1, 0, field_size-1, &resultado);

            // funct3 quinto
            field_size = 3;
            resultado <<= field_size;
            pack(data.funct3, 0, field_size-1, &resultado);

            // imm sexto 
            field_size = 4;
            resultado <<= field_size;
            pack(data.imm, 1, 4, &resultado);

            // imm setimo ultimo
            field_size = 1;
            resultado <<= field_size;
            pack(data.imm, 11, 11, &resultado);
        break;

        case U:
            // imm
            field_size = 20;
            resultado <<= field_size;
            pack(data.imm, 0, 19, &resultado);

            // rd
            field_size = 5;
            resultado <<= field_size;
            pack(data.rd, 0, field_size-1, &resultado);
        break;

        case J:
            // imm 1
            field_size = 1;
            resultado <<= field_size;
            pack(data.imm, 20, 20, &resultado);
            
            // imm 2
            field_size = 10;
            resultado <<= field_size;
            pack(data.imm, 1, 10, &resultado);

            // imm 3
            field_size = 1;
            resultado <<= field_size;
            pack(data.imm, 11, 11, &resultado);
            
            // imm 4
            field_size = 8;
            resultado <<= field_size;
            pack(data.imm, 12, 19, &resultado);
            
            // rd 5
            field_size = 5;
            resultado <<= field_size;
            pack(data.rd, 0, field_size-1, &resultado);
        break;
    }

    if (
        (data.type != S) &&
        (data.type != B)
    ) {
        // rd
        resultado <<= rd_size;
        pack(data.rd, 0, rd_size-1, &resultado);
    }

    // upcode 
    field_size = 7;
    resultado <<= field_size;
    pack(data.opcode, 0, field_size-1, &resultado);
    
    hex_code(resultado);
    
    return 0;
}

void _start(){
    int ret_code = main();
    exit(ret_code);
}