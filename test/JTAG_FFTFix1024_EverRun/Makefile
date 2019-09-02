LLVM_BIN_PATH=${MAPU_HOME}/apc/bin

VLOG_FILES:=$(shell find . -name "*.dat")

all:
	${LLVM_BIN_PATH}/llvm-mc -arch=mmpulite -filetype=obj app.m.asm  -o app.m.o
	${LLVM_BIN_PATH}/ld.gold -T ./MaPU_ASM.m.ld -n -o app.m.out  app.m.o
	${LLVM_BIN_PATH}/llvm-objdump -arch-name=mmpulite -t -disassemble  -s app.m.out > app.m.dis
	@objcopy -I elf32-little -O verilog app.m.out MIM.data
	${LLVM_BIN_PATH}/llvm-mc -arch=mspu -filetype=obj app.s.asm  -o app.s.o
	${LLVM_BIN_PATH}/ld.gold -T ./MaPU_ASM.s.ld -n -o app.s.out  app.s.o --just-symbols app.m.out
	${LLVM_BIN_PATH}/llvm-objdump -arch-name=mspu -t -disassemble  -s app.s.out > app.s.dis
	@objcopy -I elf32-little -O verilog app.s.out IM.data
vlog2asm:
	${LLVM_BIN_PATH}/llvm-mc -arch=mmpulite -filetype=obj app.m.asm  -o app.m.o
	${LLVM_BIN_PATH}/ld.gold -T ./MaPU_ASM.m.ld -n -o app.m.out  app.m.o
	${LLVM_BIN_PATH}/vlogdata2c -asm app.s.asm MaPU_ASM.s.ld $(VLOG_FILES)
	${LLVM_BIN_PATH}/llvm-mc -arch=mspu -filetype=obj app.s.vlogdata.asm  -o app.s.o
	${LLVM_BIN_PATH}/ld.gold -T ./MaPU_ASM.s.vlogdata.ld -n -o app.s.out  app.s.o --just-symbols app.m.out

clean:
	@rm -rf *.lof  *.out  *.map  *.mmap  *.sct  *.tab  *.s  *.dis  *~  *.def *.xml *.data
	@rm -rf simv*  work  *.lib++ *Log *.log *~ *.rc csrc *.key filelist.f
	@rm -rf *.vpd DVEfiles vc_hdrs.h urgReport
	@rm -rf *.o *.sym *.txt
	@rm -rf *.vlogdata.*
