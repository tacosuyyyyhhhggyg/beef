bits 16

org 7C00h

;;; Set the default state, no way to make this a function yet
;;; as the instruction pointer is still in limbo.
        ;; Don't need cli or sti as these are atomic operations.
        ;;  -- Thanks Love4Boobies.
        xor bx, bx
        mov es, bx
        ;; mov fs, bx
        ;; mov gs, bx
        mov ds, bx
        mov ss, bx
        ;; Setup a stack
        mov sp,0x7c00


        ;; enforce CS:IP
        jmp 0x0000: start

        ;; various bits of information for a temporary cache.
        drive_number db 0xf
        version_number db 0x00
        boot_loader_name dd  0xbadbeef5
        mmap_count db 0xff
        mmap_start dw 0xffff

start:

        mov [drive_number], dl  ; drive number for INT 13 calls.

;;; Opens the A20 gate, assuming BIOS is 2002 or newer.
;;; Modified: AX
enable_A20_gate:
        mov ax, 0x2401
        int 0x15

;;; Trashes everything, but returns number of entries in bp
detect_upper_memory:
        mov [mmap_start], di
    .upper_memory_interrupt:
        mov edx, 0x0534D4150
        mov eax, 0xe820
        mov [es:di + 20], dword 1
        mov ecx, 24
        int 0x15

        ;; request a second set of maps
    .second_set:
        jmp short .upper_memory_interrupt

        ;; list is complete when ebx is 0
        inc bp
        add di, 24
        test ebx, ebx

        jne short .second_set
        mov [mmap_count], bp
        clc


;;; Read from drive
;;; ES BX AX CX DX are modified.
load_kernel:
        mov ax, 0x2000
        mov es, ax
        xor bx, bx
        mov ax, 0x0209
        mov cx, 0x0003
        xor dx, dx
        int 0x13



;;; Load the gdt tables
load_gdt:
        cli


        lgdt [gdt_desc]
        mov eax, cr0
        or al, 1
        mov cr0, eax


        jmp 08h:bit32_kernel

gdt:

gdt_null:
       dd 0
       dd 0

gdt_code:
        dw 0xffff
        dw 0
        db 0
        db 10011010b
        db 11001111b
        db 0

gdt_data:
        dw 0xffff
        dw 0
        db 0
        db 10010010b
        db 11001111b
        db 0

gdt_end:


gdt_desc:
         dw gdt_end - gdt - 1
         dd gdt

;;; our "kernel"
bits 32
bit32_kernel:
        jmp $




times 510-($-$$) db 0x0
dw 0xAA55
