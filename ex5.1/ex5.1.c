// #include <unistd.h>
int main();

int read(int __fd, const void *__buf, int __n){
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall read code (63) \n"
    "ecall               # invoke syscall \n"
    "mv %0, a0           # move return value to ret_val\n"
    : "=r"(ret_val)  // Output list
    : "r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
  return ret_val;
}

void write(int __fd, const void *__buf, int __n)
{
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
}

void exit(int code)
{
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (93) \n"
    "ecall"
    :   // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
}

void _start()
{
  int ret_code = main();
  exit(ret_code);
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
  // mask = (unsigned)mask >> qntd_uns;
  mask = (unsigned)mask >> 32 - qntd_uns;
  mask = mask << zeros_esq;

  return mask;  
}

int pack(int input, int start_bit, int end_bit, int * destino) {
  // deslocando o input
  int qntd_uns = (end_bit - start_bit) + 1 < 0 ? -((end_bit - start_bit) + 1) : (end_bit - start_bit) + 1; 
  int mask = mask_generator(qntd_uns, 0);
  input = input & mask;

  *destino = *destino | input;

}

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

#define STDIN_FD  0
#define STDOUT_FD 1

int main()
{
  // int mask1 = 0b
  char input[40];
  // recebendo a string
  int n = read(STDIN_FD, input, 40);

  // separando os numeros em vetores diferentes
  char num_1_c[6];
  slice_5(input, num_1_c, 0);
  char num_2_c[6];
  slice_5(input, num_2_c, 6);
  char num_3_c[6];
  slice_5(input, num_3_c, 12);
  char num_4_c[6];
  slice_5(input, num_4_c, 18);
  char num_5_c[6];
  slice_5(input, num_5_c, 24);

  // transformando em inteiro
  int num_1 = char_to_int(num_1_c);
  int num_2 = char_to_int(num_2_c);
  int num_3 = char_to_int(num_3_c);
  int num_4 = char_to_int(num_4_c);
  int num_5 = char_to_int(num_5_c);

  int resultado = 0;
  int tam_num = 11;
  pack(num_5, 0, tam_num-1, &resultado);

  tam_num = 5;
  resultado <<= tam_num;
  pack(num_4, 0, tam_num - 1, &resultado);

  tam_num = 5;
  resultado <<= tam_num;
  pack(num_3, 0, tam_num - 1, &resultado);

  tam_num = 8;
  resultado <<= tam_num;
  pack(num_2, 0, tam_num - 1, &resultado);

  tam_num = 3;
  resultado <<= tam_num;
  pack(num_1, 0, tam_num - 1, &resultado);

  hex_code(resultado);

  return 0;
}
