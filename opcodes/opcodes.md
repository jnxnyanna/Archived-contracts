- **Level:** dasar
- **Tingkat kesulitan:** -

#### **1. Operator Aritmatika**
###### Opcode aritmatika EVM adalah instruksi dasar berukuran 1 byte yang digunakan oleh Ethereum Virtual Machine untuk melakukan operasi matematika (penjumlahan, pengurangan, perkalian, pembagian, modulo, eksponensial) langsung pada stack. Opcode utama meliputi `ADD (0x01)`, `SUB (0x03)`, `MUL (0x02)`, `DIV (0x04)`, `MOD (0x06)`, dan `EXP (0x0a)`, yang beroperasi pada angka 256-bit EVM dari Scratch. 
Opcode|Sintaks|Simbol|Kategori|Deskripsi|Contoh|Gas
------|-------|------|--------|---------|------|-----
`add`|`add(x, y)`|`+`|Aritmatika|Penjumlahan `(x + y)`|`add(1, 2)`|_3_
`sub`|`sub(x, y)`|`-`|Aritmatika|Pengurangan `(x - y)`|`sub(2, 1)`|_3_
`mul`|`mul(x, y)`|`*`|Aritmatika|Perkalian `(x * y)`|`mul(2, 3)`|_5_
`div`|`div(x, y)`|`/`|Aritmatika|Pembagian `(x / y)`|`div(4, 2)`|_5_
`mod`|`mod(x, y)`|`%`|Aritmatika|Modulo/hasil bagi `(x % y)`|`mod(5, 2)`|_5_
`exp`|`exp(x, y)`|`**`|Aritmatika|Eksponen/perkalian berulang `(x ** y)`|`exp(2, 2)`|_5_
`smod`|`smod(x, y)`|`%`|Aritmatika|Modulo/hasil bagi bertanda `(x % y)`|`smod(-3, 2)`|_5_
