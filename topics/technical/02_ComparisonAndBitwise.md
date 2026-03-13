No.    | Opcode                   | Sintaks      | Simbol   | Kategori                 | Deskripsi                                    | Contoh                                      | Gas
-------|--------------------------|--------------|----------|--------------------------|----------------------------------------------|---------------------------------------------|----------
**1.** | `LT` _(Hex: `0x10`)_     | `lt(x, y)`   | `<`      | Perbandingan dan Bitwise | Membandingkan apakah `x < y`.                | `lt(1, 2)`: _true_ <br> `lt(2, 1)`: _false_ | **_3_**
**2.** | `GT` _(Hex: `0x11`)_     | `gt(x, y)`   | `>`      | Perbandingan dan Bitwise | Membandingkan apakah `x > y`.                | `gt(1, 2)`: _false_ <br> `gt(2, 1)`: _true_ | **_3_**
**3.** | `EQ` _(Hex: `0x14`)_     | `eq(x, y)`   | `==`     | Perbandingan dan Bitwise | Mengecek apakah `x == y`.                    | `eq(1, 1)`: _true_ <br> `eq(2, 1)`: _false_ | **_3_**
**4.** | `OR` _(Hex: `0x17`)_     | `or(x, y)`   | `\|\|`   | Perbandingan dan Bitwise | Mengecek kondisi `true` diantara `x` dan `y` | `or(0, 1)`: _true_                          | **_3_**
**5.** | `AND` _(Hex: `0x00`)_    | `and(x, y)`  | `&&`     | Perbandingan dan Bitwise | 
**6.** | `NOT` _(Hex: `0x00`)_    | `not(x, y)`  | `!`      | Perbandingan dan Bitwise | 
**7.** | `XOR` _(Hex: `0x00`)_    | `xor(x, y)`  | `^`      | Perbandingan dan Bitwise | 
**8.** | `ISZERO` _(Hex: `0x00`)_ | `iszero(x )` |          | Perbandingan dan Bitwise | 
