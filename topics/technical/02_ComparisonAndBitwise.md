| No | Opcode | Sintaks    | Deskripsi                                                                                               | Contoh                   |
| -- | ------ | ---------- | ------------------------------------------------------------------------------------------------------- | ------------------------ |
| **1.**  | `LT` _(Hex: `0x10`)_     | `lt(a, b)`   | Membandingkan apakah `a` lebih kecil dari `b` (unsigned). Mengembalikan `1` jika benar, `0` jika salah. | lt(3, 5) → 1             |
| **2.**  | `GT` _(Hex: `0x11`)_     | `gt(a, b)`   | Membandingkan apakah `a` lebih besar dari `b` (unsigned). Mengembalikan `1` jika benar, `0` jika salah. | gt(7, 2) → 1             |
| **3.**  | `SLT` _(Hex: `0x12`)_    | `slt(a, b)`  | Membandingkan apakah `a` lebih kecil dari `b` menggunakan signed integer.                               | slt(-3, 2) → 1           |
| **4.**  | `SGT` _(Hex: `0x13`)_    | `sgt(a, b)`  | Membandingkan apakah `a` lebih besar dari `b` menggunakan signed integer.                               | sgt(-1, -5) → 1          |
| **5.**  | `EQ` _(Hex: `0x14`)_     | `eq(a, b)`   | Membandingkan apakah `a` sama dengan `b`. Mengembalikan `1` jika sama, `0` jika berbeda.                | eq(5, 5) → 1             |
| **6.**  | `ISZERO` _(Hex: `0x15`)_ | `iszero(a)`  | Mengembalikan `1` jika nilai `a` sama dengan `0`, jika tidak maka `0`.                                  | iszero(0) → 1            |
| **7.**  | `AND` _(Hex: `0x16`)_    | `and(a, b)`  | Operasi bitwise AND antara `a` dan `b`. Setiap bit bernilai `1` hanya jika kedua bit bernilai `1`.      | and(6, 3) → 2            |
| **8.**  | `OR` _(Hex: `0x17`)_     | `or(a, b)`   | Operasi bitwise OR antara `a` dan `b`. Bit bernilai `1` jika salah satu bit bernilai `1`.               | or(6, 3) → 7             |
| **9.**  | `XOR` _(Hex: `0x18`)_    | `xor(a, b)`  | Operasi bitwise XOR antara `a` dan `b`. Bit bernilai `1` jika kedua bit berbeda.                        | xor(6, 3) → 5            |
| **10.** | `NOT` _(Hex: `0x19`)_    | `not(a)`     | Melakukan inversi bit (bitwise NOT) terhadap `a`. Semua bit dibalik.                                    | not(0x00) → 0xffff…ffff  |
| **11.** | `BYTE` _(Hex: `0x1a`)_   | `byte(n, x)` | Mengambil byte ke-`n` dari nilai `x`. Byte dihitung dari kiri (most significant byte).                  | byte(0, 0x123456) → 0x12 |
| **12.** | `SHL` _(Hex: `0x1b`)_    | `shl(n, x)`  | Melakukan shift bit ke kiri sebanyak `n` bit.                                                           | shl(1, 3) → 6            |
| **13.** | `SHR` _(Hex: `0x1c`)_    | `shr(n, x)`  | Melakukan shift bit ke kanan sebanyak `n` bit (unsigned).                                               | shr(1, 8) → 4            |
| **14.** | `SAR` _(Hex: `0x1d`)_    | `sar(n, x)`  | Melakukan shift bit ke kanan sebanyak `n` bit dengan mempertahankan tanda (signed shift).               | sar(1, -4) → -2          |

####
```Solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Counter {
    uint256 public counter;

    function increase() public {
        counter += 1;
    }

    function decrease() public {
        require(counter > 0);
        counter -= 1;
    }
}```
