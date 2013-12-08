nasm.exe -f obj -l %1.list %1.asm
LINK86.EXE %1.obj TO %1.lnk NOBIND
LOC86.exe %1.lnk TO %1.exe AD(SM(PROGRAM(10000H), CONSTSEG(18000H)))
OH86.EXE %1.exe