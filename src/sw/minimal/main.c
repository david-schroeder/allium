/* SPDX-License-Identifier: Apache-2.0
 * SPDX-FileCopyrightText: David Schröder 2026
 */

#include <stdio.h>
#include <stdint.h>

volatile static uint32_t values[10];

int main(void) {
    // Fibonacci
    uint32_t a = 0;
    uint32_t b = 1;
    uint32_t c;

    volatile uint32_t *ptr = &values[0];

    for (int i = 0; i < 10; i++) {
        *ptr++ = a;
        c = a + b;
        a = b;
        b = c;
    }

    return 0;
}
