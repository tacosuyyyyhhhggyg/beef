all:
	mkdir -p isofs
	nasm -g -f bin -O0 -l boot.lst -o isofs/boot boot.asm
	genisoimage -r -b boot -no-emul-boot -boot-load-size 4 -o boot.iso isofs
	cat ${ASM_FILENAME}.lst

clean:
	rm -rf isofs boot boot.iso
	rm *.o



# all:
# 	nasm -f elf -g -l ${ASM_FILENAME}.lst ${ASM_FILENAME}.asm
# #
# 	ld -melf_i386 ${ASM_FILENAME}.o -o ${ASM_FILENAME}

# 	cat ${ASM_FILENAME}.lst
# 	./${ASM_FILENAME}


