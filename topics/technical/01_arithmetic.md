#### **1. Arithmetic Operations**
###### Opcode aritmatika EVM adalah instruksi dasar berukuran 1 byte yang digunakan oleh Ethereum Virtual Machine untuk melakukan operasi matematika (penjumlahan, pengurangan, perkalian, pembagian, modulo, eksponensial) langsung pada stack. Opcode utama meliputi `ADD (0x01)`, `SUB (0x03)`, `MUL (0x02)`, `DIV (0x04)`, `MOD (0x06)`, dan `EXP (0x0a)`, yang beroperasi pada angka 256-bit EVM dari Scratch. 
No|Opcode|Sintaks|Simbol|Kategori|Deskripsi|Contoh|Gas
|--|-----|-------|------|--------|---------|------|-----
**1.**|`ADD` _(Hex: `0x01`)_|`add(x, y)`|`+`|Aritmatika|Penjumlahan (`x + y`).|`add(1, 2)`|**_3_**
**2.**|`MUL` _(Hex: `0x02`)_|`mul(x, y)`|`*`|Aritmatika|Perkalian (`x * y`).|`mul(2, 3)`|**_5_**
**3.**|`SUB` _(Hex: `0x03`)_|`sub(x, y)`|`-`|Aritmatika|Pengurangan (`x - y`).|`sub(2, 1)`|**_3_**
**4.**|`DIV` _(Hex: `0x04`)_|`div(x, y)`|`/`|Aritmatika|Pembagian (`x / y`).|`div(4, 2)`|**_5_**
**5.**|`MOD` _(Hex: `0x06`)_|`mod(x, y)`|`%`|Aritmatika|Modulo/hasil bagi (`x % y`).|`mod(5, 2)`|**_5_**
**6.**|`EXP` _(Hex: `0x0a`)_|`exp(x, y)`|`**`|Aritmatika|Eksponen/perkalian berulang (`x ** y`).|`exp(2, 2)`|**_10_**
**7.**|`SDIV` _(Hex: `0x05`)_|`sdiv(x, y)`|`/`|Aritmatika|Pembagian bertanda (`x / y`).|`sdiv(-4, 2)`|**_5_**|
**8.**|`SMOD` _(Hex: `0x07`)_|`smod(x, y)`|`%`|Aritmatika|Modulo/hasil bagi bertanda (`x % y`).|`smod(-3, 2)`|**_5_**
**9.**|`ADDMOD` _(Hex: `0x08`)_|`addmod(x, y, n)`|`+%`|Aritmatika|Penjumlahan disertai modulo (`(x + y) % n`).|`addmod(1, 2, 2)`|**_8_**
**10.**|`MULMOD` _(Hex: `0x09`)_|`mulmod(x, y, n)`|`*%`|Aritmatika|Perkalian disertai modulo (`(x * y) % n`).|`mulmod(5, 2, 2)`|**_8_**
**11.**|`SIGNEXTEND` _(Hex: `0x0b`)_|`signextend(x, y)`||Aritmatika|Mengubah angka signed kecil menjadi 256-bit penuh tanpa mengubah nilainya (`signextend(x, y)`, dimana: `x` adalah index byte-nya dan `y` adalah nilainya).|`signextend(0, -1)`|**_5_**

