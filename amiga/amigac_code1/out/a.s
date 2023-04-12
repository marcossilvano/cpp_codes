
out/a.elf:     file format elf32-m68k


Disassembly of section .text:

00000000 <_start>:
extern void (*__init_array_start[])() __attribute__((weak));
extern void (*__init_array_end[])() __attribute__((weak));
extern void (*__fini_array_start[])() __attribute__((weak));
extern void (*__fini_array_end[])() __attribute__((weak));

__attribute__((used)) __attribute__((section(".text.unlikely"))) void _start() {
       0:	       movem.l d2-d3/a2,-(sp)
	// initialize globals, ctors etc.
	unsigned long count;
	unsigned long i;

	count = __preinit_array_end - __preinit_array_start;
       4:	       move.l #16384,d3
       a:	       subi.l #16384,d3
      10:	       asr.l #2,d3
	for (i = 0; i < count; i++)
      12:	       move.l #16384,d0
      18:	       cmpi.l #16384,d0
      1e:	/----- beq.s 32 <_start+0x32>
      20:	|      lea 4000 <incbin_image_start>,a2
      26:	|      moveq #0,d2
		__preinit_array_start[i]();
      28:	|  /-> movea.l (a2)+,a0
      2a:	|  |   jsr (a0)
	for (i = 0; i < count; i++)
      2c:	|  |   addq.l #1,d2
      2e:	|  |   cmp.l d3,d2
      30:	|  \-- bcs.s 28 <_start+0x28>

	count = __init_array_end - __init_array_start;
      32:	\----> move.l #16384,d3
      38:	       subi.l #16384,d3
      3e:	       asr.l #2,d3
	for (i = 0; i < count; i++)
      40:	       move.l #16384,d0
      46:	       cmpi.l #16384,d0
      4c:	/----- beq.s 60 <_start+0x60>
      4e:	|      lea 4000 <incbin_image_start>,a2
      54:	|      moveq #0,d2
		__init_array_start[i]();
      56:	|  /-> movea.l (a2)+,a0
      58:	|  |   jsr (a0)
	for (i = 0; i < count; i++)
      5a:	|  |   addq.l #1,d2
      5c:	|  |   cmp.l d3,d2
      5e:	|  \-- bcs.s 56 <_start+0x56>

	main();
      60:	\----> jsr 8c <main>

	// call dtors
	count = __fini_array_end - __fini_array_start;
      66:	       move.l #16384,d2
      6c:	       subi.l #16384,d2
      72:	       asr.l #2,d2
	for (i = count; i > 0; i--)
      74:	/----- beq.s 86 <_start+0x86>
      76:	|      lea 4000 <incbin_image_start>,a2
		__fini_array_start[i - 1]();
      7c:	|  /-> subq.l #1,d2
      7e:	|  |   movea.l -(a2),a0
      80:	|  |   jsr (a0)
	for (i = count; i > 0; i--)
      82:	|  |   tst.l d2
      84:	|  \-- bne.s 7c <_start+0x7c>
}
      86:	\----> movem.l (sp)+,d2-d3/a2
      8a:	       rts

0000008c <main>:
static void Wait10() { WaitLine(0x10); }
static void Wait11() { WaitLine(0x11); }
static void Wait12() { WaitLine(0x12); }
static void Wait13() { WaitLine(0x13); }

int main() {
      8c:	                                                          link.w a5,#-52
      90:	                                                          movem.l d2-d7/a2-a4/a6,-(sp)
	SysBase = *((struct ExecBase**)4UL);
      94:	                                                          movea.l 4 <_start+0x4>,a6
      98:	                                                          move.l a6,12b9a <SysBase>
	custom = (struct Custom*)0xdff000;
      9e:	                                                          move.l #14675968,12ba4 <custom>

	// We will use the graphics library only to locate and restore the system copper list once we are through.
	GfxBase = (struct GfxBase *)OpenLibrary((CONST_STRPTR)"graphics.library",0);
      a8:	                                                          lea 32ac <incbin_player_end+0xd4>,a1
      ae:	                                                          moveq #0,d0
      b0:	                                                          jsr -552(a6)
      b4:	                                                          move.l d0,12b96 <GfxBase>
	if (!GfxBase)
      ba:	      /-------------------------------------------------- beq.w c58 <main+0xbcc>
		Exit(0);

	// used for printing
	DOSBase = (struct DosLibrary*)OpenLibrary((CONST_STRPTR)"dos.library", 0);
      be:	      |                                                   movea.l 12b9a <SysBase>,a6
      c4:	      |                                                   lea 32bd <incbin_player_end+0xe5>,a1
      ca:	      |                                                   moveq #0,d0
      cc:	      |                                                   jsr -552(a6)
      d0:	      |                                                   move.l d0,12b92 <DOSBase>
	if (!DOSBase)
      d6:	/-----|-------------------------------------------------- beq.w be8 <main+0xb5c>
		Exit(0);

#ifdef __cplusplus
	KPrintF("Hello debugger from Amiga: %ld!\n", staticClass.i);
#else
	KPrintF("Hello debugger from Amiga!\n");
      da:	|  /--|-------------------------------------------------> pea 32c9 <incbin_player_end+0xf1>
      e0:	|  |  |                                                   jsr f8e <KPrintF>
#endif
	Write(Output(), (APTR)"Hello console!\n", 15);
      e6:	|  |  |                                                   movea.l 12b92 <DOSBase>,a6
      ec:	|  |  |                                                   jsr -60(a6)
      f0:	|  |  |                                                   movea.l 12b92 <DOSBase>,a6
      f6:	|  |  |                                                   move.l d0,d1
      f8:	|  |  |                                                   move.l #13029,d2
      fe:	|  |  |                                                   moveq #15,d3
     100:	|  |  |                                                   jsr -48(a6)
	Delay(50);
     104:	|  |  |                                                   movea.l 12b92 <DOSBase>,a6
     10a:	|  |  |                                                   moveq #50,d1
     10c:	|  |  |                                                   jsr -198(a6)

	warpmode(1);
     110:	|  |  |                                                   pea 1 <_start+0x1>
     114:	|  |  |                                                   lea 1000 <warpmode>,a4
     11a:	|  |  |                                                   jsr (a4)
		register volatile const void* _a0 ASM("a0") = module;
     11c:	|  |  |                                                   lea 11704 <incbin_module_start>,a0
		register volatile const void* _a1 ASM("a1") = NULL;
     122:	|  |  |                                                   suba.l a1,a1
		register volatile const void* _a2 ASM("a2") = NULL;
     124:	|  |  |                                                   suba.l a2,a2
		register volatile const void* _a3 ASM("a3") = player;
     126:	|  |  |                                                   lea 1872 <incbin_player_start>,a3
		__asm volatile (
     12c:	|  |  |                                                   movem.l d1-d7/a4-a6,-(sp)
     130:	|  |  |                                                   jsr (a3)
     132:	|  |  |                                                   movem.l (sp)+,d1-d7/a4-a6
	// TODO: precalc stuff here
#ifdef MUSIC
	if(p61Init(module) != 0)
     136:	|  |  |                                                   addq.l #8,sp
     138:	|  |  |                                                   tst.l d0
     13a:	|  |  |  /----------------------------------------------- bne.w b38 <main+0xaac>
		KPrintF("p61Init failed!\n");
#endif
	warpmode(0);
     13e:	|  |  |  |  /-------------------------------------------> clr.l -(sp)
     140:	|  |  |  |  |                                             jsr (a4)
	Forbid();
     142:	|  |  |  |  |                                             movea.l 12b9a <SysBase>,a6
     148:	|  |  |  |  |                                             jsr -132(a6)
	SystemADKCON=custom->adkconr;
     14c:	|  |  |  |  |                                             movea.l 12ba4 <custom>,a0
     152:	|  |  |  |  |                                             move.w 16(a0),d0
     156:	|  |  |  |  |                                             move.w d0,12b84 <SystemADKCON>
	SystemInts=custom->intenar;
     15c:	|  |  |  |  |                                             move.w 28(a0),d0
     160:	|  |  |  |  |                                             move.w d0,12b88 <SystemInts>
	SystemDMA=custom->dmaconr;
     166:	|  |  |  |  |                                             move.w 2(a0),d0
     16a:	|  |  |  |  |                                             move.w d0,12b86 <SystemDMA>
	ActiView=GfxBase->ActiView; //store current view
     170:	|  |  |  |  |                                             movea.l 12b96 <GfxBase>,a6
     176:	|  |  |  |  |                                             move.l 34(a6),12b80 <ActiView>
	LoadView(0);
     17e:	|  |  |  |  |                                             suba.l a1,a1
     180:	|  |  |  |  |                                             jsr -222(a6)
	WaitTOF();
     184:	|  |  |  |  |                                             movea.l 12b96 <GfxBase>,a6
     18a:	|  |  |  |  |                                             jsr -270(a6)
	WaitTOF();
     18e:	|  |  |  |  |                                             movea.l 12b96 <GfxBase>,a6
     194:	|  |  |  |  |                                             jsr -270(a6)
	WaitVbl();
     198:	|  |  |  |  |                                             lea ed8 <WaitVbl>,a2
     19e:	|  |  |  |  |                                             jsr (a2)
	WaitVbl();
     1a0:	|  |  |  |  |                                             jsr (a2)
	OwnBlitter();
     1a2:	|  |  |  |  |                                             movea.l 12b96 <GfxBase>,a6
     1a8:	|  |  |  |  |                                             jsr -456(a6)
	WaitBlit();	
     1ac:	|  |  |  |  |                                             movea.l 12b96 <GfxBase>,a6
     1b2:	|  |  |  |  |                                             jsr -228(a6)
	Disable();
     1b6:	|  |  |  |  |                                             movea.l 12b9a <SysBase>,a6
     1bc:	|  |  |  |  |                                             jsr -120(a6)
	custom->intena=0x7fff;//disable all interrupts
     1c0:	|  |  |  |  |                                             movea.l 12ba4 <custom>,a0
     1c6:	|  |  |  |  |                                             move.w #32767,154(a0)
	custom->intreq=0x7fff;//Clear any interrupts that were pending
     1cc:	|  |  |  |  |                                             move.w #32767,156(a0)
	custom->dmacon=0x7fff;//Clear all DMA channels
     1d2:	|  |  |  |  |                                             move.w #32767,150(a0)
     1d8:	|  |  |  |  |                                             addq.l #4,sp
	for(int a=0;a<32;a++)
     1da:	|  |  |  |  |                                             moveq #0,d1
		custom->color[a]=0;
     1dc:	|  |  |  |  |        /----------------------------------> move.l d1,d0
     1de:	|  |  |  |  |        |                                    addi.l #192,d0
     1e4:	|  |  |  |  |        |                                    add.l d0,d0
     1e6:	|  |  |  |  |        |                                    move.w #0,(0,a0,d0.l)
	for(int a=0;a<32;a++)
     1ec:	|  |  |  |  |        |                                    addq.l #1,d1
     1ee:	|  |  |  |  |        |                                    moveq #32,d0
     1f0:	|  |  |  |  |        |                                    cmp.l d1,d0
     1f2:	|  |  |  |  |        +----------------------------------- bne.s 1dc <main+0x150>
	WaitVbl();
     1f4:	|  |  |  |  |        |                                    jsr (a2)
	WaitVbl();
     1f6:	|  |  |  |  |        |                                    jsr (a2)
	UWORD getvbr[] = { 0x4e7a, 0x0801, 0x4e73 }; // MOVEC.L VBR,D0 RTE
     1f8:	|  |  |  |  |        |                                    move.w #20090,-50(a5)
     1fe:	|  |  |  |  |        |                                    move.w #2049,-48(a5)
     204:	|  |  |  |  |        |                                    move.w #20083,-46(a5)
	if (SysBase->AttnFlags & AFF_68010) 
     20a:	|  |  |  |  |        |                                    movea.l 12b9a <SysBase>,a6
     210:	|  |  |  |  |        |                                    btst #0,297(a6)
     216:	|  |  |  |  |  /-----|----------------------------------- beq.w c84 <main+0xbf8>
		vbr = (APTR)Supervisor((ULONG (*)())getvbr);
     21a:	|  |  |  |  |  |     |                                    moveq #-50,d7
     21c:	|  |  |  |  |  |     |                                    add.l a5,d7
     21e:	|  |  |  |  |  |     |                                    exg d7,a5
     220:	|  |  |  |  |  |     |                                    jsr -30(a6)
     224:	|  |  |  |  |  |     |                                    exg d7,a5
	VBR=GetVBR();
     226:	|  |  |  |  |  |     |                                    move.l d0,12b8e <VBR>
	return *(volatile APTR*)(((UBYTE*)VBR)+0x6c);
     22c:	|  |  |  |  |  |     |                                    movea.l 12b8e <VBR>,a0
     232:	|  |  |  |  |  |     |                                    move.l 108(a0),d0
	SystemIrq=GetInterruptHandler(); //store interrupt register
     236:	|  |  |  |  |  |     |                                    move.l d0,12b8a <SystemIrq>

	TakeSystem();
	WaitVbl();
     23c:	|  |  |  |  |  |     |                                    jsr (a2)

	char* test = (char*)AllocMem(2502, MEMF_ANY);
     23e:	|  |  |  |  |  |     |                                    movea.l 12b9a <SysBase>,a6
     244:	|  |  |  |  |  |     |                                    move.l #2502,d0
     24a:	|  |  |  |  |  |     |                                    moveq #0,d1
     24c:	|  |  |  |  |  |     |                                    jsr -198(a6)
     250:	|  |  |  |  |  |     |                                    move.l d0,d4
	memset(test, 0xcd, 2502);
     252:	|  |  |  |  |  |     |                                    pea 9c6 <main+0x93a>
     256:	|  |  |  |  |  |     |                                    pea cd <main+0x41>
     25a:	|  |  |  |  |  |     |                                    move.l d0,-(sp)
     25c:	|  |  |  |  |  |     |                                    jsr 12d2 <memset>
	memclr(test + 2, 2502 - 4);
     262:	|  |  |  |  |  |     |                                    movea.l d4,a0
     264:	|  |  |  |  |  |     |                                    addq.l #2,a0
	__asm volatile (
     266:	|  |  |  |  |  |     |                                    move.l #2498,d5
     26c:	|  |  |  |  |  |     |                                    cmpi.l #256,d5
     272:	|  |  |  |  |  |     |                             /----- blt.w 2d0 <main+0x244>
     276:	|  |  |  |  |  |     |                             |      adda.l d5,a0
     278:	|  |  |  |  |  |     |                             |      moveq #0,d0
     27a:	|  |  |  |  |  |     |                             |      moveq #0,d1
     27c:	|  |  |  |  |  |     |                             |      moveq #0,d2
     27e:	|  |  |  |  |  |     |                             |      moveq #0,d3
     280:	|  |  |  |  |  |     |                             |  /-> movem.l d0-d3,-(a0)
     284:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     288:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     28c:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     290:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     294:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     298:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     29c:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2a0:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2a4:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2a8:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2ac:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2b0:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2b4:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2b8:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2bc:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2c0:	|  |  |  |  |  |     |                             |  |   subi.l #256,d5
     2c6:	|  |  |  |  |  |     |                             |  |   cmpi.l #256,d5
     2cc:	|  |  |  |  |  |     |                             |  \-- bge.w 280 <main+0x1f4>
     2d0:	|  |  |  |  |  |     |                             >----> cmpi.w #64,d5
     2d4:	|  |  |  |  |  |     |                             |  /-- blt.w 2f0 <main+0x264>
     2d8:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2dc:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2e0:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2e4:	|  |  |  |  |  |     |                             |  |   movem.l d0-d3,-(a0)
     2e8:	|  |  |  |  |  |     |                             |  |   subi.w #64,d5
     2ec:	|  |  |  |  |  |     |                             \--|-- bra.w 2d0 <main+0x244>
     2f0:	|  |  |  |  |  |     |                                \-> lsr.w #2,d5
     2f2:	|  |  |  |  |  |     |                                /-- bcc.w 2f8 <main+0x26c>
     2f6:	|  |  |  |  |  |     |                                |   clr.w -(a0)
     2f8:	|  |  |  |  |  |     |                                \-> moveq #16,d0
     2fa:	|  |  |  |  |  |     |                                    sub.w d5,d0
     2fc:	|  |  |  |  |  |     |                                    add.w d0,d0
     2fe:	|  |  |  |  |  |     |                                    jmp (302 <main+0x276>,pc,d0.w)
     302:	|  |  |  |  |  |     |                                    clr.l -(a0)
     304:	|  |  |  |  |  |     |                                    clr.l -(a0)
     306:	|  |  |  |  |  |     |                                    clr.l -(a0)
     308:	|  |  |  |  |  |     |                                    clr.l -(a0)
     30a:	|  |  |  |  |  |     |                                    clr.l -(a0)
     30c:	|  |  |  |  |  |     |                                    clr.l -(a0)
     30e:	|  |  |  |  |  |     |                                    clr.l -(a0)
     310:	|  |  |  |  |  |     |                                    clr.l -(a0)
     312:	|  |  |  |  |  |     |                                    clr.l -(a0)
     314:	|  |  |  |  |  |     |                                    clr.l -(a0)
     316:	|  |  |  |  |  |     |                                    clr.l -(a0)
     318:	|  |  |  |  |  |     |                                    clr.l -(a0)
     31a:	|  |  |  |  |  |     |                                    clr.l -(a0)
     31c:	|  |  |  |  |  |     |                                    clr.l -(a0)
     31e:	|  |  |  |  |  |     |                                    clr.l -(a0)
     320:	|  |  |  |  |  |     |                                    clr.l -(a0)
	FreeMem(test, 2502);
     322:	|  |  |  |  |  |     |                                    movea.l 12b9a <SysBase>,a6
     328:	|  |  |  |  |  |     |                                    movea.l d4,a1
     32a:	|  |  |  |  |  |     |                                    move.l #2502,d0
     330:	|  |  |  |  |  |     |                                    jsr -210(a6)

	USHORT* copper1 = (USHORT*)AllocMem(1024, MEMF_CHIP);
     334:	|  |  |  |  |  |     |                                    movea.l 12b9a <SysBase>,a6
     33a:	|  |  |  |  |  |     |                                    move.l #1024,d0
     340:	|  |  |  |  |  |     |                                    moveq #2,d1
     342:	|  |  |  |  |  |     |                                    jsr -198(a6)
     346:	|  |  |  |  |  |     |                                    movea.l d0,a3
	USHORT* copPtr = copper1;

	// register graphics resources with WinUAE for nicer gfx debugger experience
	debug_register_bitmap(image, "image.bpl", 320, 256, 5, debug_resource_bitmap_interleaved);
     348:	|  |  |  |  |  |     |                                    pea 1 <_start+0x1>
     34c:	|  |  |  |  |  |     |                                    pea 100 <main+0x74>
     350:	|  |  |  |  |  |     |                                    pea 140 <main+0xb4>
     354:	|  |  |  |  |  |     |                                    pea 3306 <incbin_player_end+0x12e>
     35a:	|  |  |  |  |  |     |                                    pea 4000 <incbin_image_start>
     360:	|  |  |  |  |  |     |                                    lea 115c <debug_register_bitmap.constprop.0>,a4
     366:	|  |  |  |  |  |     |                                    jsr (a4)
	debug_register_bitmap(bob, "bob.bpl", 32, 96, 5, debug_resource_bitmap_interleaved | debug_resource_bitmap_masked);
     368:	|  |  |  |  |  |     |                                    lea 32(sp),sp
     36c:	|  |  |  |  |  |     |                                    pea 3 <_start+0x3>
     370:	|  |  |  |  |  |     |                                    pea 60 <_start+0x60>
     374:	|  |  |  |  |  |     |                                    pea 20 <_start+0x20>
     378:	|  |  |  |  |  |     |                                    pea 3310 <incbin_player_end+0x138>
     37e:	|  |  |  |  |  |     |                                    pea 10802 <incbin_bob_start>
     384:	|  |  |  |  |  |     |                                    jsr (a4)
	my_strncpy(resource.name, name, sizeof(resource.name));
	debug_cmd(barto_cmd_register_resource, (unsigned int)&resource, 0, 0);
}

void debug_register_palette(const void* addr, const char* name, short numEntries, unsigned short flags) {
	struct debug_resource resource = {
     386:	|  |  |  |  |  |     |                                    clr.l -42(a5)
     38a:	|  |  |  |  |  |     |                                    clr.l -38(a5)
     38e:	|  |  |  |  |  |     |                                    clr.l -34(a5)
     392:	|  |  |  |  |  |     |                                    clr.l -30(a5)
     396:	|  |  |  |  |  |     |                                    clr.l -26(a5)
     39a:	|  |  |  |  |  |     |                                    clr.l -22(a5)
     39e:	|  |  |  |  |  |     |                                    clr.l -18(a5)
     3a2:	|  |  |  |  |  |     |                                    clr.l -14(a5)
     3a6:	|  |  |  |  |  |     |                                    clr.l -10(a5)
     3aa:	|  |  |  |  |  |     |                                    clr.l -6(a5)
     3ae:	|  |  |  |  |  |     |                                    clr.w -2(a5)
		.address = (unsigned int)addr,
     3b2:	|  |  |  |  |  |     |                                    move.l #6192,d3
	struct debug_resource resource = {
     3b8:	|  |  |  |  |  |     |                                    move.l d3,-50(a5)
     3bc:	|  |  |  |  |  |     |                                    moveq #64,d1
     3be:	|  |  |  |  |  |     |                                    move.l d1,-46(a5)
     3c2:	|  |  |  |  |  |     |                                    move.w #1,-10(a5)
     3c8:	|  |  |  |  |  |     |                                    move.w #32,-6(a5)
     3ce:	|  |  |  |  |  |     |                                    lea 20(sp),sp
	while(*source && --num > 0)
     3d2:	|  |  |  |  |  |     |                                    moveq #105,d0
	struct debug_resource resource = {
     3d4:	|  |  |  |  |  |     |                                    lea -42(a5),a0
     3d8:	|  |  |  |  |  |     |                                    lea 32a2 <incbin_player_end+0xca>,a1
	while(*source && --num > 0)
     3de:	|  |  |  |  |  |     |                                    lea -11(a5),a4
		*destination++ = *source++;
     3e2:	|  |  |  |  |  |  /--|----------------------------------> addq.l #1,a1
     3e4:	|  |  |  |  |  |  |  |                                    move.b d0,(a0)+
	while(*source && --num > 0)
     3e6:	|  |  |  |  |  |  |  |                                    move.b (a1),d0
     3e8:	|  |  |  |  |  |  |  |                                /-- beq.s 3ee <main+0x362>
     3ea:	|  |  |  |  |  |  |  |                                |   cmpa.l a0,a4
     3ec:	|  |  |  |  |  |  +--|--------------------------------|-- bne.s 3e2 <main+0x356>
	*destination = '\0';
     3ee:	|  |  |  |  |  |  |  |                                \-> clr.b (a0)
	if(*((UWORD *)UaeLib) == 0x4eb9 || *((UWORD *)UaeLib) == 0xa00e) {
     3f0:	|  |  |  |  |  |  |  |                                    move.w f0ff60 <_end+0xefd3b8>,d0
     3f6:	|  |  |  |  |  |  |  |                                    cmpi.w #20153,d0
     3fa:	|  |  |  |  |  |  |  |     /----------------------------- beq.w 9cc <main+0x940>
     3fe:	|  |  |  |  |  |  |  |     |                              cmpi.w #-24562,d0
     402:	|  |  |  |  |  |  |  |     +----------------------------- beq.w 9cc <main+0x940>
	debug_register_palette(colors, "image.pal", 32, 0);
	debug_register_copperlist(copper1, "copper1", 1024, 0);
     406:	|  |  |  |  |  |  |  |     |                              pea 400 <main+0x374>
     40a:	|  |  |  |  |  |  |  |     |                              pea 3318 <incbin_player_end+0x140>
     410:	|  |  |  |  |  |  |  |     |                              move.l a3,-(sp)
     412:	|  |  |  |  |  |  |  |     |                              lea 1222 <debug_register_copperlist.constprop.0>,a4
     418:	|  |  |  |  |  |  |  |     |                              jsr (a4)
	debug_register_copperlist(copper2, "copper2", sizeof(copper2), 0);
     41a:	|  |  |  |  |  |  |  |     |                              pea 80 <_start+0x80>
     41e:	|  |  |  |  |  |  |  |     |                              pea 3320 <incbin_player_end+0x148>
     424:	|  |  |  |  |  |  |  |     |                              pea 33fa <copper2>
     42a:	|  |  |  |  |  |  |  |     |                              jsr (a4)
	*copListEnd++ = offsetof(struct Custom, ddfstrt);
     42c:	|  |  |  |  |  |  |  |     |                              move.w #146,(a3)
	*copListEnd++ = fw;
     430:	|  |  |  |  |  |  |  |     |                              move.w #56,2(a3)
	*copListEnd++ = offsetof(struct Custom, ddfstop);
     436:	|  |  |  |  |  |  |  |     |                              move.w #148,4(a3)
	*copListEnd++ = fw+(((width>>4)-1)<<3);
     43c:	|  |  |  |  |  |  |  |     |                              move.w #208,6(a3)
	*copListEnd++ = offsetof(struct Custom, diwstrt);
     442:	|  |  |  |  |  |  |  |     |                              move.w #142,8(a3)
	*copListEnd++ = x+(y<<8);
     448:	|  |  |  |  |  |  |  |     |                              move.w #11393,10(a3)
	*copListEnd++ = offsetof(struct Custom, diwstop);
     44e:	|  |  |  |  |  |  |  |     |                              move.w #144,12(a3)
	*copListEnd++ = (xstop-256)+((ystop-256)<<8);
     454:	|  |  |  |  |  |  |  |     |                              move.w #11457,14(a3)

	copPtr = screenScanDefault(copPtr);
	//enable bitplanes	
	*copPtr++ = offsetof(struct Custom, bplcon0);
     45a:	|  |  |  |  |  |  |  |     |                              move.w #256,16(a3)
	*copPtr++ = (0<<10)/*dual pf*/|(1<<9)/*color*/|((5)<<12)/*num bitplanes*/;
     460:	|  |  |  |  |  |  |  |     |                              move.w #20992,18(a3)
	*copPtr++ = offsetof(struct Custom, bplcon1);	//scrolling
     466:	|  |  |  |  |  |  |  |     |                              move.w #258,20(a3)
     46c:	|  |  |  |  |  |  |  |     |                              lea 22(a3),a0
     470:	|  |  |  |  |  |  |  |     |                              move.l a0,12ba0 <scroll>
	scroll = copPtr;
	*copPtr++ = 0;
     476:	|  |  |  |  |  |  |  |     |                              clr.w 22(a3)
	*copPtr++ = offsetof(struct Custom, bplcon2);	//playfied priority
     47a:	|  |  |  |  |  |  |  |     |                              move.w #260,24(a3)
	*copPtr++ = 1<<6;//0x24;			//Sprites have priority over playfields
     480:	|  |  |  |  |  |  |  |     |                              move.w #64,26(a3)

	const USHORT lineSize=320/8;

	//set bitplane modulo
	*copPtr++=offsetof(struct Custom, bpl1mod); //odd planes   1,3,5
     486:	|  |  |  |  |  |  |  |     |                              move.w #264,28(a3)
	*copPtr++=4*lineSize;
     48c:	|  |  |  |  |  |  |  |     |                              move.w #160,30(a3)
	*copPtr++=offsetof(struct Custom, bpl2mod); //even  planes 2,4
     492:	|  |  |  |  |  |  |  |     |                              move.w #266,32(a3)
	*copPtr++=4*lineSize;
     498:	|  |  |  |  |  |  |  |     |                              move.w #160,34(a3)
		ULONG addr=(ULONG)planes[i];
     49e:	|  |  |  |  |  |  |  |     |                              move.l #16384,d0
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR);
     4a4:	|  |  |  |  |  |  |  |     |                              move.w #224,36(a3)
		*copListEnd++=(UWORD)(addr>>16);
     4aa:	|  |  |  |  |  |  |  |     |                              move.l d0,d1
     4ac:	|  |  |  |  |  |  |  |     |                              clr.w d1
     4ae:	|  |  |  |  |  |  |  |     |                              swap d1
     4b0:	|  |  |  |  |  |  |  |     |                              move.w d1,38(a3)
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR) + 2;
     4b4:	|  |  |  |  |  |  |  |     |                              move.w #226,40(a3)
		*copListEnd++=(UWORD)addr;
     4ba:	|  |  |  |  |  |  |  |     |                              move.w d0,42(a3)
		ULONG addr=(ULONG)planes[i];
     4be:	|  |  |  |  |  |  |  |     |                              move.l #16424,d0
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR);
     4c4:	|  |  |  |  |  |  |  |     |                              move.w #228,44(a3)
		*copListEnd++=(UWORD)(addr>>16);
     4ca:	|  |  |  |  |  |  |  |     |                              move.l d0,d1
     4cc:	|  |  |  |  |  |  |  |     |                              clr.w d1
     4ce:	|  |  |  |  |  |  |  |     |                              swap d1
     4d0:	|  |  |  |  |  |  |  |     |                              move.w d1,46(a3)
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR) + 2;
     4d4:	|  |  |  |  |  |  |  |     |                              move.w #230,48(a3)
		*copListEnd++=(UWORD)addr;
     4da:	|  |  |  |  |  |  |  |     |                              move.w d0,50(a3)
		ULONG addr=(ULONG)planes[i];
     4de:	|  |  |  |  |  |  |  |     |                              move.l #16464,d0
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR);
     4e4:	|  |  |  |  |  |  |  |     |                              move.w #232,52(a3)
		*copListEnd++=(UWORD)(addr>>16);
     4ea:	|  |  |  |  |  |  |  |     |                              move.l d0,d1
     4ec:	|  |  |  |  |  |  |  |     |                              clr.w d1
     4ee:	|  |  |  |  |  |  |  |     |                              swap d1
     4f0:	|  |  |  |  |  |  |  |     |                              move.w d1,54(a3)
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR) + 2;
     4f4:	|  |  |  |  |  |  |  |     |                              move.w #234,56(a3)
		*copListEnd++=(UWORD)addr;
     4fa:	|  |  |  |  |  |  |  |     |                              move.w d0,58(a3)
		ULONG addr=(ULONG)planes[i];
     4fe:	|  |  |  |  |  |  |  |     |                              move.l #16504,d0
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR);
     504:	|  |  |  |  |  |  |  |     |                              move.w #236,60(a3)
		*copListEnd++=(UWORD)(addr>>16);
     50a:	|  |  |  |  |  |  |  |     |                              move.l d0,d1
     50c:	|  |  |  |  |  |  |  |     |                              clr.w d1
     50e:	|  |  |  |  |  |  |  |     |                              swap d1
     510:	|  |  |  |  |  |  |  |     |                              move.w d1,62(a3)
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR) + 2;
     514:	|  |  |  |  |  |  |  |     |                              move.w #238,64(a3)
		*copListEnd++=(UWORD)addr;
     51a:	|  |  |  |  |  |  |  |     |                              move.w d0,66(a3)
		ULONG addr=(ULONG)planes[i];
     51e:	|  |  |  |  |  |  |  |     |                              move.l #16544,d0
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR);
     524:	|  |  |  |  |  |  |  |     |                              move.w #240,68(a3)
		*copListEnd++=(UWORD)(addr>>16);
     52a:	|  |  |  |  |  |  |  |     |                              move.l d0,d1
     52c:	|  |  |  |  |  |  |  |     |                              clr.w d1
     52e:	|  |  |  |  |  |  |  |     |                              swap d1
     530:	|  |  |  |  |  |  |  |     |                              move.w d1,70(a3)
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR) + 2;
     534:	|  |  |  |  |  |  |  |     |                              move.w #242,72(a3)
		*copListEnd++=(UWORD)addr;
     53a:	|  |  |  |  |  |  |  |     |                              move.w d0,74(a3)
     53e:	|  |  |  |  |  |  |  |     |                              lea 76(a3),a1
     542:	|  |  |  |  |  |  |  |     |                              move.l #6256,d2
     548:	|  |  |  |  |  |  |  |     |                              lea 24(sp),sp
     54c:	|  |  |  |  |  |  |  |     |                              lea 1830 <incbin_colors_start>,a0
     552:	|  |  |  |  |  |  |  |     |                              move.w #382,d0
     556:	|  |  |  |  |  |  |  |     |                              sub.w d3,d0
		planes[a]=(UBYTE*)(image + lineSize * a);
	copPtr = copSetPlanes(0, copPtr, planes, 5);

	// set colors
	for(int a=0; a < 32; a++)
		copPtr = copSetColor(copPtr, a, ((USHORT*)colors)[a]);
     558:	|  |  |  |  |  |  |  |  /--|----------------------------> move.w (a0)+,d1
	*copListCurrent++=offsetof(struct Custom, color[index]);
     55a:	|  |  |  |  |  |  |  |  |  |                              movea.w d0,a6
     55c:	|  |  |  |  |  |  |  |  |  |                              adda.w a0,a6
     55e:	|  |  |  |  |  |  |  |  |  |                              move.w a6,(a1)
	*copListCurrent++=color;
     560:	|  |  |  |  |  |  |  |  |  |                              addq.l #4,a1
     562:	|  |  |  |  |  |  |  |  |  |                              move.w d1,-2(a1)
	for(int a=0; a < 32; a++)
     566:	|  |  |  |  |  |  |  |  |  |                              cmpa.l d2,a0
     568:	|  |  |  |  |  |  |  |  +--|----------------------------- bne.s 558 <main+0x4cc>

	// jump to copper2
	*copPtr++ = offsetof(struct Custom, copjmp2);
     56a:	|  |  |  |  |  |  |  |  |  |                              move.w #138,204(a3)
	*copPtr++ = 0x7fff;
     570:	|  |  |  |  |  |  |  |  |  |                              move.w #32767,206(a3)

	custom->cop1lc = (ULONG)copper1;
     576:	|  |  |  |  |  |  |  |  |  |                              movea.l 12ba4 <custom>,a0
     57c:	|  |  |  |  |  |  |  |  |  |                              move.l a3,128(a0)
	custom->cop2lc = (ULONG)copper2;
     580:	|  |  |  |  |  |  |  |  |  |                              move.l #13306,132(a0)
	custom->dmacon = DMAF_BLITTER;//disable blitter dma for copjmp bug
     588:	|  |  |  |  |  |  |  |  |  |                              move.w #64,150(a0)
	custom->copjmp1 = 0x7fff; //start coppper
     58e:	|  |  |  |  |  |  |  |  |  |                              move.w #32767,136(a0)
	custom->dmacon = DMAF_SETCLR | DMAF_MASTER | DMAF_RASTER | DMAF_COPPER | DMAF_BLITTER;
     594:	|  |  |  |  |  |  |  |  |  |                              move.w #-31808,150(a0)
	*(volatile APTR*)(((UBYTE*)VBR)+0x6c) = interrupt;
     59a:	|  |  |  |  |  |  |  |  |  |                              movea.l 12b8e <VBR>,a1
     5a0:	|  |  |  |  |  |  |  |  |  |                              move.l #3656,108(a1)

	// DEMO
	SetInterruptHandler((APTR)interruptHandler);
	custom->intena = INTF_SETCLR | INTF_INTEN | INTF_VERTB;
     5a8:	|  |  |  |  |  |  |  |  |  |                              move.w #-16352,154(a0)
#ifdef MUSIC
	custom->intena = INTF_SETCLR | INTF_EXTER; // ThePlayer needs INTF_EXTER
     5ae:	|  |  |  |  |  |  |  |  |  |                              move.w #-24576,154(a0)
#endif

	custom->intreq=(1<<INTB_VERTB);//reset vbl req
     5b4:	|  |  |  |  |  |  |  |  |  |                              move.w #32,156(a0)
__attribute__((always_inline)) inline short MouseLeft(){return !((*(volatile UBYTE*)0xbfe001)&64);}	
     5ba:	|  |  |  |  |  |  |  |  |  |                              move.b bfe001 <_end+0xbeb459>,d0

	while(!MouseLeft()) {
     5c0:	|  |  |  |  |  |  |  |  |  |                              btst #6,d0
     5c4:	|  |  |  |  |  |  |  |  |  |  /-------------------------- beq.w 74e <main+0x6c2>
     5c8:	|  |  |  |  |  |  |  |  |  |  |                           lea 1650 <__umodsi3>,a4
     5ce:	|  |  |  |  |  |  |  |  |  |  |                           lea 3347 <sinus40>,a3
		volatile ULONG vpos=*(volatile ULONG*)0xDFF004;
     5d4:	|  |  |  |  |  |  |  |  |  |  |  /----------------------> move.l dff004 <_end+0xdec45c>,d0
     5da:	|  |  |  |  |  |  |  |  |  |  |  |                        move.l d0,-50(a5)
		if(((vpos >> 8) & 511) == line)
     5de:	|  |  |  |  |  |  |  |  |  |  |  |                        move.l -50(a5),d0
     5e2:	|  |  |  |  |  |  |  |  |  |  |  |                        lsr.l #8,d0
     5e4:	|  |  |  |  |  |  |  |  |  |  |  |                        andi.l #511,d0
     5ea:	|  |  |  |  |  |  |  |  |  |  |  |                        moveq #16,d1
     5ec:	|  |  |  |  |  |  |  |  |  |  |  |                        cmp.l d0,d1
     5ee:	|  |  |  |  |  |  |  |  |  |  |  +----------------------- bne.s 5d4 <main+0x548>
		Wait10();
		int f = frameCounter & 255;
     5f0:	|  |  |  |  |  |  |  |  |  |  |  |                        move.w 12b9e <frameCounter>,d7

		// clear
		WaitBlit();
     5f6:	|  |  |  |  |  |  |  |  |  |  |  |                        movea.l 12b96 <GfxBase>,a6
     5fc:	|  |  |  |  |  |  |  |  |  |  |  |                        jsr -228(a6)
		custom->bltcon0 = A_TO_D | DEST;
     600:	|  |  |  |  |  |  |  |  |  |  |  |                        movea.l 12ba4 <custom>,a0
     606:	|  |  |  |  |  |  |  |  |  |  |  |                        move.w #496,64(a0)
		custom->bltcon1 = 0;
     60c:	|  |  |  |  |  |  |  |  |  |  |  |                        move.w #0,66(a0)
		custom->bltadat = 0;
     612:	|  |  |  |  |  |  |  |  |  |  |  |                        move.w #0,116(a0)
		custom->bltdpt = (APTR)image + 320 / 8 * 200 * 5;
     618:	|  |  |  |  |  |  |  |  |  |  |  |                        move.l #56384,84(a0)
		custom->bltdmod = 0;
     620:	|  |  |  |  |  |  |  |  |  |  |  |                        move.w #0,102(a0)
		custom->bltafwm = custom->bltalwm = 0xffff;
     626:	|  |  |  |  |  |  |  |  |  |  |  |                        move.w #-1,70(a0)
     62c:	|  |  |  |  |  |  |  |  |  |  |  |                        move.w #-1,68(a0)
		custom->bltsize = ((56 * 5) << HSIZEBITS) | (320/16);
     632:	|  |  |  |  |  |  |  |  |  |  |  |                        move.w #17940,88(a0)
     638:	|  |  |  |  |  |  |  |  |  |  |  |                        moveq #0,d6
     63a:	|  |  |  |  |  |  |  |  |  |  |  |                        moveq #0,d5

		// blit
		for(short i = 0; i < 16; i++) {
			const short x = i * 16 + sinus32[(frameCounter + i) % sizeof(sinus32)] * 2;
     63c:	|  |  |  |  |  |  |  |  |  |  |  |                    /-> movea.w 12b9e <frameCounter>,a0
     642:	|  |  |  |  |  |  |  |  |  |  |  |                    |   pea 33 <_start+0x33>
     646:	|  |  |  |  |  |  |  |  |  |  |  |                    |   movea.w a0,a6
     648:	|  |  |  |  |  |  |  |  |  |  |  |                    |   pea (0,a6,d5.l)
     64c:	|  |  |  |  |  |  |  |  |  |  |  |                    |   jsr (a4)
     64e:	|  |  |  |  |  |  |  |  |  |  |  |                    |   addq.l #8,sp
     650:	|  |  |  |  |  |  |  |  |  |  |  |                    |   lea 3387 <sinus32>,a0
     656:	|  |  |  |  |  |  |  |  |  |  |  |                    |   moveq #0,d3
     658:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.b (0,a0,d0.l),d3
     65c:	|  |  |  |  |  |  |  |  |  |  |  |                    |   add.l d6,d3
     65e:	|  |  |  |  |  |  |  |  |  |  |  |                    |   add.w d3,d3
			const short y = sinus40[((frameCounter + i) * 2) & 63] / 2;
     660:	|  |  |  |  |  |  |  |  |  |  |  |                    |   movea.w 12b9e <frameCounter>,a0
     666:	|  |  |  |  |  |  |  |  |  |  |  |                    |   movea.w a0,a6
     668:	|  |  |  |  |  |  |  |  |  |  |  |                    |   lea (0,a6,d5.l),a0
     66c:	|  |  |  |  |  |  |  |  |  |  |  |                    |   adda.l a0,a0
     66e:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.l a0,d0
     670:	|  |  |  |  |  |  |  |  |  |  |  |                    |   moveq #62,d1
     672:	|  |  |  |  |  |  |  |  |  |  |  |                    |   and.l d1,d0
     674:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.b (0,a3,d0.l),d2
     678:	|  |  |  |  |  |  |  |  |  |  |  |                    |   lsr.b #1,d2
			const APTR src = (APTR)bob + 32 / 8 * 10 * 16 * (i % 6);
     67a:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w d5,d0
     67c:	|  |  |  |  |  |  |  |  |  |  |  |                    |   moveq #6,d1
     67e:	|  |  |  |  |  |  |  |  |  |  |  |                    |   ext.l d0
     680:	|  |  |  |  |  |  |  |  |  |  |  |                    |   divs.w d1,d0
     682:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.l d0,d4
     684:	|  |  |  |  |  |  |  |  |  |  |  |                    |   swap d4
     686:	|  |  |  |  |  |  |  |  |  |  |  |                    |   muls.w #640,d4
     68a:	|  |  |  |  |  |  |  |  |  |  |  |                    |   addi.l #67586,d4

			WaitBlit();
     690:	|  |  |  |  |  |  |  |  |  |  |  |                    |   movea.l 12b96 <GfxBase>,a6
     696:	|  |  |  |  |  |  |  |  |  |  |  |                    |   jsr -228(a6)
			custom->bltcon0 = 0xca | SRCA | SRCB | SRCC | DEST | ((x & 15) << ASHIFTSHIFT); // A = source, B = mask, C = background, D = destination
     69a:	|  |  |  |  |  |  |  |  |  |  |  |                    |   moveq #0,d0
     69c:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w d3,d0
     69e:	|  |  |  |  |  |  |  |  |  |  |  |                    |   moveq #12,d1
     6a0:	|  |  |  |  |  |  |  |  |  |  |  |                    |   lsl.l d1,d0
     6a2:	|  |  |  |  |  |  |  |  |  |  |  |                    |   movea.l 12ba4 <custom>,a0
     6a8:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w d0,d1
     6aa:	|  |  |  |  |  |  |  |  |  |  |  |                    |   ori.w #4042,d1
     6ae:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w d1,64(a0)
			custom->bltcon1 = ((x & 15) << BSHIFTSHIFT);
     6b2:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w d0,66(a0)
			custom->bltapt = src;
     6b6:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.l d4,80(a0)
			custom->bltamod = 32 / 8;
     6ba:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w #4,100(a0)
			custom->bltbpt = src + 32 / 8 * 1;
     6c0:	|  |  |  |  |  |  |  |  |  |  |  |                    |   addq.l #4,d4
     6c2:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.l d4,76(a0)
			custom->bltbmod = 32 / 8;
     6c6:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w #4,98(a0)
			custom->bltcpt = custom->bltdpt = (APTR)image + 320 / 8 * 5 * (200 + y) + x / 8;
     6cc:	|  |  |  |  |  |  |  |  |  |  |  |                    |   andi.l #255,d2
     6d2:	|  |  |  |  |  |  |  |  |  |  |  |                    |   addi.l #200,d2
     6d8:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.l d2,d0
     6da:	|  |  |  |  |  |  |  |  |  |  |  |                    |   add.l d2,d0
     6dc:	|  |  |  |  |  |  |  |  |  |  |  |                    |   add.l d2,d0
     6de:	|  |  |  |  |  |  |  |  |  |  |  |                    |   lsl.l #3,d0
     6e0:	|  |  |  |  |  |  |  |  |  |  |  |                    |   add.l d2,d0
     6e2:	|  |  |  |  |  |  |  |  |  |  |  |                    |   lsl.l #3,d0
     6e4:	|  |  |  |  |  |  |  |  |  |  |  |                    |   asr.w #3,d3
     6e6:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w d3,d1
     6e8:	|  |  |  |  |  |  |  |  |  |  |  |                    |   ext.l d1
     6ea:	|  |  |  |  |  |  |  |  |  |  |  |                    |   movea.l d0,a6
     6ec:	|  |  |  |  |  |  |  |  |  |  |  |                    |   lea (0,a6,d1.l),a1
     6f0:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.l a1,d0
     6f2:	|  |  |  |  |  |  |  |  |  |  |  |                    |   addi.l #16384,d0
     6f8:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.l d0,84(a0)
     6fc:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.l d0,72(a0)
			custom->bltcmod = custom->bltdmod = (320 - 32) / 8;
     700:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w #36,102(a0)
     706:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w #36,96(a0)
			custom->bltafwm = custom->bltalwm = 0xffff;
     70c:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w #-1,70(a0)
     712:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w #-1,68(a0)
			custom->bltsize = ((16 * 5) << HSIZEBITS) | (32/16);
     718:	|  |  |  |  |  |  |  |  |  |  |  |                    |   move.w #5122,88(a0)
		for(short i = 0; i < 16; i++) {
     71e:	|  |  |  |  |  |  |  |  |  |  |  |                    |   addq.l #1,d5
     720:	|  |  |  |  |  |  |  |  |  |  |  |                    |   addq.l #8,d6
     722:	|  |  |  |  |  |  |  |  |  |  |  |                    |   moveq #16,d3
     724:	|  |  |  |  |  |  |  |  |  |  |  |                    |   cmp.l d5,d3
     726:	|  |  |  |  |  |  |  |  |  |  |  |                    \-- bne.w 63c <main+0x5b0>
     72a:	|  |  |  |  |  |  |  |  |  |  |  |                        move.w f0ff60 <_end+0xefd3b8>,d0
     730:	|  |  |  |  |  |  |  |  |  |  |  |                        cmpi.w #20153,d0
     734:	|  |  |  |  |  |  |  |  |  |  |  |                    /-- beq.w 84c <main+0x7c0>
     738:	|  |  |  |  |  |  |  |  |  |  |  |                    |   cmpi.w #-24562,d0
     73c:	|  |  |  |  |  |  |  |  |  |  |  |                    +-- beq.w 84c <main+0x7c0>
__attribute__((always_inline)) inline short MouseLeft(){return !((*(volatile UBYTE*)0xbfe001)&64);}	
     740:	|  |  |  |  |  |  |  |  |  |  |  |  /-----------------|-> move.b bfe001 <_end+0xbeb459>,d0
	while(!MouseLeft()) {
     746:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   btst #6,d0
     74a:	|  |  |  |  |  |  |  |  |  |  |  +--|-----------------|-- bne.w 5d4 <main+0x548>
		register volatile const void* _a3 ASM("a3") = player;
     74e:	|  |  |  |  |  |  |  |  |  |  >--|--|-----------------|-> lea 1872 <incbin_player_start>,a3
		register volatile const void* _a6 ASM("a6") = (void*)0xdff000;
     754:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l #14675968,a6
		__asm volatile (
     75a:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movem.l d0-d1/a0-a1,-(sp)
     75e:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr 8(a3)
     762:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movem.l (sp)+,d0-d1/a0-a1
	WaitVbl();
     766:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr (a2)
	WaitBlit();
     768:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b96 <GfxBase>,a6
     76e:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr -228(a6)
	custom->intena=0x7fff;//disable all interrupts
     772:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12ba4 <custom>,a0
     778:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.w #32767,154(a0)
	custom->intreq=0x7fff;//Clear any interrupts that were pending
     77e:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.w #32767,156(a0)
	custom->dmacon=0x7fff;//Clear all DMA channels
     784:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.w #32767,150(a0)
	*(volatile APTR*)(((UBYTE*)VBR)+0x6c) = interrupt;
     78a:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b8e <VBR>,a1
     790:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.l 12b8a <SystemIrq>,108(a1)
	custom->cop1lc=(ULONG)GfxBase->copinit;
     798:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b96 <GfxBase>,a6
     79e:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.l 38(a6),128(a0)
	custom->cop2lc=(ULONG)GfxBase->LOFlist;
     7a4:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.l 50(a6),132(a0)
	custom->copjmp1=0x7fff; //start coppper
     7aa:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.w #32767,136(a0)
	custom->intena=SystemInts|0x8000;
     7b0:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.w 12b88 <SystemInts>,d0
     7b6:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   ori.w #-32768,d0
     7ba:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.w d0,154(a0)
	custom->dmacon=SystemDMA|0x8000;
     7be:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.w 12b86 <SystemDMA>,d0
     7c4:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   ori.w #-32768,d0
     7c8:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.w d0,150(a0)
	custom->adkcon=SystemADKCON|0x8000;
     7cc:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.w 12b84 <SystemADKCON>,d0
     7d2:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   ori.w #-32768,d0
     7d6:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   move.w d0,158(a0)
	WaitBlit();	
     7da:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr -228(a6)
	DisownBlitter();
     7de:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b96 <GfxBase>,a6
     7e4:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr -462(a6)
	Enable();
     7e8:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b9a <SysBase>,a6
     7ee:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr -126(a6)
	LoadView(ActiView);
     7f2:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b96 <GfxBase>,a6
     7f8:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b80 <ActiView>,a1
     7fe:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr -222(a6)
	WaitTOF();
     802:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b96 <GfxBase>,a6
     808:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr -270(a6)
	WaitTOF();
     80c:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b96 <GfxBase>,a6
     812:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr -270(a6)
	Permit();
     816:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b9a <SysBase>,a6
     81c:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr -138(a6)
#endif

	// END
	FreeSystem();

	CloseLibrary((struct Library*)DOSBase);
     820:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b9a <SysBase>,a6
     826:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b92 <DOSBase>,a1
     82c:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr -414(a6)
	CloseLibrary((struct Library*)GfxBase);
     830:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b9a <SysBase>,a6
     836:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movea.l 12b96 <GfxBase>,a1
     83c:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   jsr -414(a6)
}
     840:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   moveq #0,d0
     842:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   movem.l -92(a5),d2-d7/a2-a4/a6
     848:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   unlk a5
     84a:	|  |  |  |  |  |  |  |  |  |  |  |  |                 |   rts
		UaeLib(88, arg1, arg2, arg3, arg4);
     84c:	|  |  |  |  |  |  |  |  |  |  |  |  |                 \-> clr.l -(sp)
     84e:	|  |  |  |  |  |  |  |  |  |  |  |  |                     clr.l -(sp)
     850:	|  |  |  |  |  |  |  |  |  |  |  |  |                     clr.l -(sp)
     852:	|  |  |  |  |  |  |  |  |  |  |  |  |                     clr.l -(sp)
     854:	|  |  |  |  |  |  |  |  |  |  |  |  |                     pea 58 <_start+0x58>
     858:	|  |  |  |  |  |  |  |  |  |  |  |  |                     movea.l #15794016,a6
     85e:	|  |  |  |  |  |  |  |  |  |  |  |  |                     jsr (a6)
		debug_filled_rect(f + 100, 200*2, f + 400, 220*2, 0x0000ff00); // 0x00RRGGBB
     860:	|  |  |  |  |  |  |  |  |  |  |  |  |                     andi.w #255,d7
     864:	|  |  |  |  |  |  |  |  |  |  |  |  |                     move.w d7,d2
     866:	|  |  |  |  |  |  |  |  |  |  |  |  |                     addi.w #400,d2
	debug_cmd(barto_cmd_filled_rect, (((unsigned int)left) << 16) | ((unsigned int)top), (((unsigned int)right) << 16) | ((unsigned int)bottom), color);
     86a:	|  |  |  |  |  |  |  |  |  |  |  |  |                     swap d2
     86c:	|  |  |  |  |  |  |  |  |  |  |  |  |                     clr.w d2
     86e:	|  |  |  |  |  |  |  |  |  |  |  |  |                     ori.w #440,d2
     872:	|  |  |  |  |  |  |  |  |  |  |  |  |                     move.w d7,d0
     874:	|  |  |  |  |  |  |  |  |  |  |  |  |                     addi.w #100,d0
     878:	|  |  |  |  |  |  |  |  |  |  |  |  |                     swap d0
     87a:	|  |  |  |  |  |  |  |  |  |  |  |  |                     clr.w d0
     87c:	|  |  |  |  |  |  |  |  |  |  |  |  |                     ori.w #400,d0
	if(*((UWORD *)UaeLib) == 0x4eb9 || *((UWORD *)UaeLib) == 0xa00e) {
     880:	|  |  |  |  |  |  |  |  |  |  |  |  |                     move.w (a6),d1
     882:	|  |  |  |  |  |  |  |  |  |  |  |  |                     lea 20(sp),sp
     886:	|  |  |  |  |  |  |  |  |  |  |  |  |                     cmpi.w #20153,d1
     88a:	|  |  |  |  |  |  |  |  |  |  |  |  |              /----- bne.w 950 <main+0x8c4>
		UaeLib(88, arg1, arg2, arg3, arg4);
     88e:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      move.l #65280,-(sp)
     894:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      move.l d2,-(sp)
     896:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      move.l d0,-(sp)
     898:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      pea 2 <_start+0x2>
     89c:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      pea 58 <_start+0x58>
     8a0:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      movea.l #15794016,a6
     8a6:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      jsr (a6)
		debug_rect(f + 90, 190*2, f + 400, 220*2, 0x000000ff); // 0x00RRGGBB
     8a8:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      move.w d7,d0
     8aa:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      addi.w #90,d0
	debug_cmd(barto_cmd_rect, (((unsigned int)left) << 16) | ((unsigned int)top), (((unsigned int)right) << 16) | ((unsigned int)bottom), color);
     8ae:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      swap d0
     8b0:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      clr.w d0
     8b2:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      ori.w #380,d0
	if(*((UWORD *)UaeLib) == 0x4eb9 || *((UWORD *)UaeLib) == 0xa00e) {
     8b6:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      move.w (a6),d1
     8b8:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      lea 20(sp),sp
     8bc:	|  |  |  |  |  |  |  |  |  |  |  |  |              |      cmpi.w #20153,d1
     8c0:	|  |  |  |  |  |  |  |  |  |  |  |  |        /-----|----- bne.w 98e <main+0x902>
		UaeLib(88, arg1, arg2, arg3, arg4);
     8c4:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  /--|----> pea ff <main+0x73>
     8c8:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      move.l d2,-(sp)
     8ca:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      move.l d0,-(sp)
     8cc:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      pea 1 <_start+0x1>
     8d0:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      pea 58 <_start+0x58>
     8d4:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      movea.l #15794016,a6
     8da:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      jsr (a6)
		debug_text(f+ 130, 209*2, "This is a WinUAE debug overlay", 0x00ff00ff);
     8dc:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      addi.w #130,d7
	debug_cmd(barto_cmd_text, (((unsigned int)left) << 16) | ((unsigned int)top), (unsigned int)text, color);
     8e0:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      swap d7
     8e2:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      clr.w d7
     8e4:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      ori.w #418,d7
	if(*((UWORD *)UaeLib) == 0x4eb9 || *((UWORD *)UaeLib) == 0xa00e) {
     8e8:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      move.w (a6),d0
     8ea:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      lea 20(sp),sp
     8ee:	|  |  |  |  |  |  |  |  |  |  |  |  |        |  |  |      cmpi.w #20153,d0
     8f2:	|  |  |  |  |  |  |  |  |  |  |  |  |  /-----|--|--|----- bne.s 926 <main+0x89a>
		UaeLib(88, arg1, arg2, arg3, arg4);
     8f4:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  /--|--|--|----> move.l #16711935,-(sp)
     8fa:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |      pea 3328 <incbin_player_end+0x150>
     900:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |      move.l d7,-(sp)
     902:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |      pea 3 <_start+0x3>
     906:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |      pea 58 <_start+0x58>
     90a:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |      jsr f0ff60 <_end+0xefd3b8>
}
     910:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |      lea 20(sp),sp
__attribute__((always_inline)) inline short MouseLeft(){return !((*(volatile UBYTE*)0xbfe001)&64);}	
     914:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  /-> move.b bfe001 <_end+0xbeb459>,d0
	while(!MouseLeft()) {
     91a:	|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |   btst #6,d0
     91e:	|  |  |  |  |  |  |  |  |  |  |  \--|--|--|--|--|--|--|-- bne.w 5d4 <main+0x548>
     922:	|  |  |  |  |  |  |  |  |  |  \-----|--|--|--|--|--|--|-- bra.w 74e <main+0x6c2>
	if(*((UWORD *)UaeLib) == 0x4eb9 || *((UWORD *)UaeLib) == 0xa00e) {
     926:	|  |  |  |  |  |  |  |  |  |        |  >--|--|--|--|--|-> cmpi.w #-24562,d0
     92a:	|  |  |  |  |  |  |  |  |  |        +--|--|--|--|--|--|-- bne.w 740 <main+0x6b4>
		UaeLib(88, arg1, arg2, arg3, arg4);
     92e:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |  |  |   move.l #16711935,-(sp)
     934:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |  |  |   pea 3328 <incbin_player_end+0x150>
     93a:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |  |  |   move.l d7,-(sp)
     93c:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |  |  |   pea 3 <_start+0x3>
     940:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |  |  |   pea 58 <_start+0x58>
     944:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |  |  |   jsr f0ff60 <_end+0xefd3b8>
}
     94a:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |  |  |   lea 20(sp),sp
     94e:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |  |  \-- bra.s 914 <main+0x888>
	if(*((UWORD *)UaeLib) == 0x4eb9 || *((UWORD *)UaeLib) == 0xa00e) {
     950:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |  \----> cmpi.w #-24562,d1
     954:	|  |  |  |  |  |  |  |  |  |        +--|--|--|--|-------- bne.w 740 <main+0x6b4>
		UaeLib(88, arg1, arg2, arg3, arg4);
     958:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         move.l #65280,-(sp)
     95e:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         move.l d2,-(sp)
     960:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         move.l d0,-(sp)
     962:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         pea 2 <_start+0x2>
     966:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         pea 58 <_start+0x58>
     96a:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         movea.l #15794016,a6
     970:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         jsr (a6)
		debug_rect(f + 90, 190*2, f + 400, 220*2, 0x000000ff); // 0x00RRGGBB
     972:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         move.w d7,d0
     974:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         addi.w #90,d0
	debug_cmd(barto_cmd_rect, (((unsigned int)left) << 16) | ((unsigned int)top), (((unsigned int)right) << 16) | ((unsigned int)bottom), color);
     978:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         swap d0
     97a:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         clr.w d0
     97c:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         ori.w #380,d0
	if(*((UWORD *)UaeLib) == 0x4eb9 || *((UWORD *)UaeLib) == 0xa00e) {
     980:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         move.w (a6),d1
     982:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         lea 20(sp),sp
     986:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  |         cmpi.w #20153,d1
     98a:	|  |  |  |  |  |  |  |  |  |        |  |  |  |  \-------- beq.w 8c4 <main+0x838>
     98e:	|  |  |  |  |  |  |  |  |  |        |  |  |  \----------> cmpi.w #-24562,d1
     992:	|  |  |  |  |  |  |  |  |  |        \--|--|-------------- bne.w 740 <main+0x6b4>
		UaeLib(88, arg1, arg2, arg3, arg4);
     996:	|  |  |  |  |  |  |  |  |  |           |  |               pea ff <main+0x73>
     99a:	|  |  |  |  |  |  |  |  |  |           |  |               move.l d2,-(sp)
     99c:	|  |  |  |  |  |  |  |  |  |           |  |               move.l d0,-(sp)
     99e:	|  |  |  |  |  |  |  |  |  |           |  |               pea 1 <_start+0x1>
     9a2:	|  |  |  |  |  |  |  |  |  |           |  |               pea 58 <_start+0x58>
     9a6:	|  |  |  |  |  |  |  |  |  |           |  |               movea.l #15794016,a6
     9ac:	|  |  |  |  |  |  |  |  |  |           |  |               jsr (a6)
		debug_text(f+ 130, 209*2, "This is a WinUAE debug overlay", 0x00ff00ff);
     9ae:	|  |  |  |  |  |  |  |  |  |           |  |               addi.w #130,d7
	debug_cmd(barto_cmd_text, (((unsigned int)left) << 16) | ((unsigned int)top), (unsigned int)text, color);
     9b2:	|  |  |  |  |  |  |  |  |  |           |  |               swap d7
     9b4:	|  |  |  |  |  |  |  |  |  |           |  |               clr.w d7
     9b6:	|  |  |  |  |  |  |  |  |  |           |  |               ori.w #418,d7
	if(*((UWORD *)UaeLib) == 0x4eb9 || *((UWORD *)UaeLib) == 0xa00e) {
     9ba:	|  |  |  |  |  |  |  |  |  |           |  |               move.w (a6),d0
     9bc:	|  |  |  |  |  |  |  |  |  |           |  |               lea 20(sp),sp
     9c0:	|  |  |  |  |  |  |  |  |  |           |  |               cmpi.w #20153,d0
     9c4:	|  |  |  |  |  |  |  |  |  |           |  \-------------- beq.w 8f4 <main+0x868>
     9c8:	|  |  |  |  |  |  |  |  |  |           \----------------- bra.w 926 <main+0x89a>
     9cc:	|  |  |  |  |  |  |  |  |  \----------------------------> clr.l -(sp)
     9ce:	|  |  |  |  |  |  |  |  |                                 clr.l -(sp)
     9d0:	|  |  |  |  |  |  |  |  |                                 pea -50(a5)
     9d4:	|  |  |  |  |  |  |  |  |                                 pea 4 <_start+0x4>
     9d8:	|  |  |  |  |  |  |  |  |                                 jsr eb8 <debug_cmd.part.0>
     9de:	|  |  |  |  |  |  |  |  |                                 lea 16(sp),sp
	debug_register_copperlist(copper1, "copper1", 1024, 0);
     9e2:	|  |  |  |  |  |  |  |  |                                 pea 400 <main+0x374>
     9e6:	|  |  |  |  |  |  |  |  |                                 pea 3318 <incbin_player_end+0x140>
     9ec:	|  |  |  |  |  |  |  |  |                                 move.l a3,-(sp)
     9ee:	|  |  |  |  |  |  |  |  |                                 lea 1222 <debug_register_copperlist.constprop.0>,a4
     9f4:	|  |  |  |  |  |  |  |  |                                 jsr (a4)
	debug_register_copperlist(copper2, "copper2", sizeof(copper2), 0);
     9f6:	|  |  |  |  |  |  |  |  |                                 pea 80 <_start+0x80>
     9fa:	|  |  |  |  |  |  |  |  |                                 pea 3320 <incbin_player_end+0x148>
     a00:	|  |  |  |  |  |  |  |  |                                 pea 33fa <copper2>
     a06:	|  |  |  |  |  |  |  |  |                                 jsr (a4)
	*copListEnd++ = offsetof(struct Custom, ddfstrt);
     a08:	|  |  |  |  |  |  |  |  |                                 move.w #146,(a3)
	*copListEnd++ = fw;
     a0c:	|  |  |  |  |  |  |  |  |                                 move.w #56,2(a3)
	*copListEnd++ = offsetof(struct Custom, ddfstop);
     a12:	|  |  |  |  |  |  |  |  |                                 move.w #148,4(a3)
	*copListEnd++ = fw+(((width>>4)-1)<<3);
     a18:	|  |  |  |  |  |  |  |  |                                 move.w #208,6(a3)
	*copListEnd++ = offsetof(struct Custom, diwstrt);
     a1e:	|  |  |  |  |  |  |  |  |                                 move.w #142,8(a3)
	*copListEnd++ = x+(y<<8);
     a24:	|  |  |  |  |  |  |  |  |                                 move.w #11393,10(a3)
	*copListEnd++ = offsetof(struct Custom, diwstop);
     a2a:	|  |  |  |  |  |  |  |  |                                 move.w #144,12(a3)
	*copListEnd++ = (xstop-256)+((ystop-256)<<8);
     a30:	|  |  |  |  |  |  |  |  |                                 move.w #11457,14(a3)
	*copPtr++ = offsetof(struct Custom, bplcon0);
     a36:	|  |  |  |  |  |  |  |  |                                 move.w #256,16(a3)
	*copPtr++ = (0<<10)/*dual pf*/|(1<<9)/*color*/|((5)<<12)/*num bitplanes*/;
     a3c:	|  |  |  |  |  |  |  |  |                                 move.w #20992,18(a3)
	*copPtr++ = offsetof(struct Custom, bplcon1);	//scrolling
     a42:	|  |  |  |  |  |  |  |  |                                 move.w #258,20(a3)
     a48:	|  |  |  |  |  |  |  |  |                                 lea 22(a3),a0
     a4c:	|  |  |  |  |  |  |  |  |                                 move.l a0,12ba0 <scroll>
	*copPtr++ = 0;
     a52:	|  |  |  |  |  |  |  |  |                                 clr.w 22(a3)
	*copPtr++ = offsetof(struct Custom, bplcon2);	//playfied priority
     a56:	|  |  |  |  |  |  |  |  |                                 move.w #260,24(a3)
	*copPtr++ = 1<<6;//0x24;			//Sprites have priority over playfields
     a5c:	|  |  |  |  |  |  |  |  |                                 move.w #64,26(a3)
	*copPtr++=offsetof(struct Custom, bpl1mod); //odd planes   1,3,5
     a62:	|  |  |  |  |  |  |  |  |                                 move.w #264,28(a3)
	*copPtr++=4*lineSize;
     a68:	|  |  |  |  |  |  |  |  |                                 move.w #160,30(a3)
	*copPtr++=offsetof(struct Custom, bpl2mod); //even  planes 2,4
     a6e:	|  |  |  |  |  |  |  |  |                                 move.w #266,32(a3)
	*copPtr++=4*lineSize;
     a74:	|  |  |  |  |  |  |  |  |                                 move.w #160,34(a3)
		ULONG addr=(ULONG)planes[i];
     a7a:	|  |  |  |  |  |  |  |  |                                 move.l #16384,d0
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR);
     a80:	|  |  |  |  |  |  |  |  |                                 move.w #224,36(a3)
		*copListEnd++=(UWORD)(addr>>16);
     a86:	|  |  |  |  |  |  |  |  |                                 move.l d0,d1
     a88:	|  |  |  |  |  |  |  |  |                                 clr.w d1
     a8a:	|  |  |  |  |  |  |  |  |                                 swap d1
     a8c:	|  |  |  |  |  |  |  |  |                                 move.w d1,38(a3)
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR) + 2;
     a90:	|  |  |  |  |  |  |  |  |                                 move.w #226,40(a3)
		*copListEnd++=(UWORD)addr;
     a96:	|  |  |  |  |  |  |  |  |                                 move.w d0,42(a3)
		ULONG addr=(ULONG)planes[i];
     a9a:	|  |  |  |  |  |  |  |  |                                 move.l #16424,d0
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR);
     aa0:	|  |  |  |  |  |  |  |  |                                 move.w #228,44(a3)
		*copListEnd++=(UWORD)(addr>>16);
     aa6:	|  |  |  |  |  |  |  |  |                                 move.l d0,d1
     aa8:	|  |  |  |  |  |  |  |  |                                 clr.w d1
     aaa:	|  |  |  |  |  |  |  |  |                                 swap d1
     aac:	|  |  |  |  |  |  |  |  |                                 move.w d1,46(a3)
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR) + 2;
     ab0:	|  |  |  |  |  |  |  |  |                                 move.w #230,48(a3)
		*copListEnd++=(UWORD)addr;
     ab6:	|  |  |  |  |  |  |  |  |                                 move.w d0,50(a3)
		ULONG addr=(ULONG)planes[i];
     aba:	|  |  |  |  |  |  |  |  |                                 move.l #16464,d0
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR);
     ac0:	|  |  |  |  |  |  |  |  |                                 move.w #232,52(a3)
		*copListEnd++=(UWORD)(addr>>16);
     ac6:	|  |  |  |  |  |  |  |  |                                 move.l d0,d1
     ac8:	|  |  |  |  |  |  |  |  |                                 clr.w d1
     aca:	|  |  |  |  |  |  |  |  |                                 swap d1
     acc:	|  |  |  |  |  |  |  |  |                                 move.w d1,54(a3)
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR) + 2;
     ad0:	|  |  |  |  |  |  |  |  |                                 move.w #234,56(a3)
		*copListEnd++=(UWORD)addr;
     ad6:	|  |  |  |  |  |  |  |  |                                 move.w d0,58(a3)
		ULONG addr=(ULONG)planes[i];
     ada:	|  |  |  |  |  |  |  |  |                                 move.l #16504,d0
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR);
     ae0:	|  |  |  |  |  |  |  |  |                                 move.w #236,60(a3)
		*copListEnd++=(UWORD)(addr>>16);
     ae6:	|  |  |  |  |  |  |  |  |                                 move.l d0,d1
     ae8:	|  |  |  |  |  |  |  |  |                                 clr.w d1
     aea:	|  |  |  |  |  |  |  |  |                                 swap d1
     aec:	|  |  |  |  |  |  |  |  |                                 move.w d1,62(a3)
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR) + 2;
     af0:	|  |  |  |  |  |  |  |  |                                 move.w #238,64(a3)
		*copListEnd++=(UWORD)addr;
     af6:	|  |  |  |  |  |  |  |  |                                 move.w d0,66(a3)
		ULONG addr=(ULONG)planes[i];
     afa:	|  |  |  |  |  |  |  |  |                                 move.l #16544,d0
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR);
     b00:	|  |  |  |  |  |  |  |  |                                 move.w #240,68(a3)
		*copListEnd++=(UWORD)(addr>>16);
     b06:	|  |  |  |  |  |  |  |  |                                 move.l d0,d1
     b08:	|  |  |  |  |  |  |  |  |                                 clr.w d1
     b0a:	|  |  |  |  |  |  |  |  |                                 swap d1
     b0c:	|  |  |  |  |  |  |  |  |                                 move.w d1,70(a3)
		*copListEnd++=offsetof(struct Custom, bplpt[0]) + (i + bplPtrStart) * sizeof(APTR) + 2;
     b10:	|  |  |  |  |  |  |  |  |                                 move.w #242,72(a3)
		*copListEnd++=(UWORD)addr;
     b16:	|  |  |  |  |  |  |  |  |                                 move.w d0,74(a3)
     b1a:	|  |  |  |  |  |  |  |  |                                 lea 76(a3),a1
     b1e:	|  |  |  |  |  |  |  |  |                                 move.l #6256,d2
     b24:	|  |  |  |  |  |  |  |  |                                 lea 24(sp),sp
     b28:	|  |  |  |  |  |  |  |  |                                 lea 1830 <incbin_colors_start>,a0
     b2e:	|  |  |  |  |  |  |  |  |                                 move.w #382,d0
     b32:	|  |  |  |  |  |  |  |  |                                 sub.w d3,d0
     b34:	|  |  |  |  |  |  |  |  \-------------------------------- bra.w 558 <main+0x4cc>
		KPrintF("p61Init failed!\n");
     b38:	|  |  |  >--|--|--|--|----------------------------------> pea 32f5 <incbin_player_end+0x11d>
     b3e:	|  |  |  |  |  |  |  |                                    jsr f8e <KPrintF>
     b44:	|  |  |  |  |  |  |  |                                    addq.l #4,sp
	warpmode(0);
     b46:	|  |  |  |  |  |  |  |                                    clr.l -(sp)
     b48:	|  |  |  |  |  |  |  |                                    jsr (a4)
	Forbid();
     b4a:	|  |  |  |  |  |  |  |                                    movea.l 12b9a <SysBase>,a6
     b50:	|  |  |  |  |  |  |  |                                    jsr -132(a6)
	SystemADKCON=custom->adkconr;
     b54:	|  |  |  |  |  |  |  |                                    movea.l 12ba4 <custom>,a0
     b5a:	|  |  |  |  |  |  |  |                                    move.w 16(a0),d0
     b5e:	|  |  |  |  |  |  |  |                                    move.w d0,12b84 <SystemADKCON>
	SystemInts=custom->intenar;
     b64:	|  |  |  |  |  |  |  |                                    move.w 28(a0),d0
     b68:	|  |  |  |  |  |  |  |                                    move.w d0,12b88 <SystemInts>
	SystemDMA=custom->dmaconr;
     b6e:	|  |  |  |  |  |  |  |                                    move.w 2(a0),d0
     b72:	|  |  |  |  |  |  |  |                                    move.w d0,12b86 <SystemDMA>
	ActiView=GfxBase->ActiView; //store current view
     b78:	|  |  |  |  |  |  |  |                                    movea.l 12b96 <GfxBase>,a6
     b7e:	|  |  |  |  |  |  |  |                                    move.l 34(a6),12b80 <ActiView>
	LoadView(0);
     b86:	|  |  |  |  |  |  |  |                                    suba.l a1,a1
     b88:	|  |  |  |  |  |  |  |                                    jsr -222(a6)
	WaitTOF();
     b8c:	|  |  |  |  |  |  |  |                                    movea.l 12b96 <GfxBase>,a6
     b92:	|  |  |  |  |  |  |  |                                    jsr -270(a6)
	WaitTOF();
     b96:	|  |  |  |  |  |  |  |                                    movea.l 12b96 <GfxBase>,a6
     b9c:	|  |  |  |  |  |  |  |                                    jsr -270(a6)
	WaitVbl();
     ba0:	|  |  |  |  |  |  |  |                                    lea ed8 <WaitVbl>,a2
     ba6:	|  |  |  |  |  |  |  |                                    jsr (a2)
	WaitVbl();
     ba8:	|  |  |  |  |  |  |  |                                    jsr (a2)
	OwnBlitter();
     baa:	|  |  |  |  |  |  |  |                                    movea.l 12b96 <GfxBase>,a6
     bb0:	|  |  |  |  |  |  |  |                                    jsr -456(a6)
	WaitBlit();	
     bb4:	|  |  |  |  |  |  |  |                                    movea.l 12b96 <GfxBase>,a6
     bba:	|  |  |  |  |  |  |  |                                    jsr -228(a6)
	Disable();
     bbe:	|  |  |  |  |  |  |  |                                    movea.l 12b9a <SysBase>,a6
     bc4:	|  |  |  |  |  |  |  |                                    jsr -120(a6)
	custom->intena=0x7fff;//disable all interrupts
     bc8:	|  |  |  |  |  |  |  |                                    movea.l 12ba4 <custom>,a0
     bce:	|  |  |  |  |  |  |  |                                    move.w #32767,154(a0)
	custom->intreq=0x7fff;//Clear any interrupts that were pending
     bd4:	|  |  |  |  |  |  |  |                                    move.w #32767,156(a0)
	custom->dmacon=0x7fff;//Clear all DMA channels
     bda:	|  |  |  |  |  |  |  |                                    move.w #32767,150(a0)
     be0:	|  |  |  |  |  |  |  |                                    addq.l #4,sp
	for(int a=0;a<32;a++)
     be2:	|  |  |  |  |  |  |  |                                    moveq #0,d1
     be4:	|  |  |  |  |  |  |  \----------------------------------- bra.w 1dc <main+0x150>
		Exit(0);
     be8:	>--|--|--|--|--|--|-------------------------------------> suba.l a6,a6
     bea:	|  |  |  |  |  |  |                                       moveq #0,d1
     bec:	|  |  |  |  |  |  |                                       jsr -144(a6)
	KPrintF("Hello debugger from Amiga!\n");
     bf0:	|  |  |  |  |  |  |                                       pea 32c9 <incbin_player_end+0xf1>
     bf6:	|  |  |  |  |  |  |                                       jsr f8e <KPrintF>
	Write(Output(), (APTR)"Hello console!\n", 15);
     bfc:	|  |  |  |  |  |  |                                       movea.l 12b92 <DOSBase>,a6
     c02:	|  |  |  |  |  |  |                                       jsr -60(a6)
     c06:	|  |  |  |  |  |  |                                       movea.l 12b92 <DOSBase>,a6
     c0c:	|  |  |  |  |  |  |                                       move.l d0,d1
     c0e:	|  |  |  |  |  |  |                                       move.l #13029,d2
     c14:	|  |  |  |  |  |  |                                       moveq #15,d3
     c16:	|  |  |  |  |  |  |                                       jsr -48(a6)
	Delay(50);
     c1a:	|  |  |  |  |  |  |                                       movea.l 12b92 <DOSBase>,a6
     c20:	|  |  |  |  |  |  |                                       moveq #50,d1
     c22:	|  |  |  |  |  |  |                                       jsr -198(a6)
	warpmode(1);
     c26:	|  |  |  |  |  |  |                                       pea 1 <_start+0x1>
     c2a:	|  |  |  |  |  |  |                                       lea 1000 <warpmode>,a4
     c30:	|  |  |  |  |  |  |                                       jsr (a4)
		register volatile const void* _a0 ASM("a0") = module;
     c32:	|  |  |  |  |  |  |                                       lea 11704 <incbin_module_start>,a0
		register volatile const void* _a1 ASM("a1") = NULL;
     c38:	|  |  |  |  |  |  |                                       suba.l a1,a1
		register volatile const void* _a2 ASM("a2") = NULL;
     c3a:	|  |  |  |  |  |  |                                       suba.l a2,a2
		register volatile const void* _a3 ASM("a3") = player;
     c3c:	|  |  |  |  |  |  |                                       lea 1872 <incbin_player_start>,a3
		__asm volatile (
     c42:	|  |  |  |  |  |  |                                       movem.l d1-d7/a4-a6,-(sp)
     c46:	|  |  |  |  |  |  |                                       jsr (a3)
     c48:	|  |  |  |  |  |  |                                       movem.l (sp)+,d1-d7/a4-a6
	if(p61Init(module) != 0)
     c4c:	|  |  |  |  |  |  |                                       addq.l #8,sp
     c4e:	|  |  |  |  |  |  |                                       tst.l d0
     c50:	|  |  |  |  \--|--|-------------------------------------- beq.w 13e <main+0xb2>
     c54:	|  |  |  \-----|--|-------------------------------------- bra.w b38 <main+0xaac>
		Exit(0);
     c58:	|  |  \--------|--|-------------------------------------> movea.l 12b92 <DOSBase>,a6
     c5e:	|  |           |  |                                       moveq #0,d1
     c60:	|  |           |  |                                       jsr -144(a6)
	DOSBase = (struct DosLibrary*)OpenLibrary((CONST_STRPTR)"dos.library", 0);
     c64:	|  |           |  |                                       movea.l 12b9a <SysBase>,a6
     c6a:	|  |           |  |                                       lea 32bd <incbin_player_end+0xe5>,a1
     c70:	|  |           |  |                                       moveq #0,d0
     c72:	|  |           |  |                                       jsr -552(a6)
     c76:	|  |           |  |                                       move.l d0,12b92 <DOSBase>
	if (!DOSBase)
     c7c:	|  \-----------|--|-------------------------------------- bne.w da <main+0x4e>
     c80:	\--------------|--|-------------------------------------- bra.w be8 <main+0xb5c>
	APTR vbr = 0;
     c84:	               \--|-------------------------------------> moveq #0,d0
	VBR=GetVBR();
     c86:	                  |                                       move.l d0,12b8e <VBR>
	return *(volatile APTR*)(((UBYTE*)VBR)+0x6c);
     c8c:	                  |                                       movea.l 12b8e <VBR>,a0
     c92:	                  |                                       move.l 108(a0),d0
	SystemIrq=GetInterruptHandler(); //store interrupt register
     c96:	                  |                                       move.l d0,12b8a <SystemIrq>
	WaitVbl();
     c9c:	                  |                                       jsr (a2)
	char* test = (char*)AllocMem(2502, MEMF_ANY);
     c9e:	                  |                                       movea.l 12b9a <SysBase>,a6
     ca4:	                  |                                       move.l #2502,d0
     caa:	                  |                                       moveq #0,d1
     cac:	                  |                                       jsr -198(a6)
     cb0:	                  |                                       move.l d0,d4
	memset(test, 0xcd, 2502);
     cb2:	                  |                                       pea 9c6 <main+0x93a>
     cb6:	                  |                                       pea cd <main+0x41>
     cba:	                  |                                       move.l d0,-(sp)
     cbc:	                  |                                       jsr 12d2 <memset>
	memclr(test + 2, 2502 - 4);
     cc2:	                  |                                       movea.l d4,a0
     cc4:	                  |                                       addq.l #2,a0
	__asm volatile (
     cc6:	                  |                                       move.l #2498,d5
     ccc:	                  |                                       cmpi.l #256,d5
     cd2:	                  |                                /----- blt.w d30 <main+0xca4>
     cd6:	                  |                                |      adda.l d5,a0
     cd8:	                  |                                |      moveq #0,d0
     cda:	                  |                                |      moveq #0,d1
     cdc:	                  |                                |      moveq #0,d2
     cde:	                  |                                |      moveq #0,d3
     ce0:	                  |                                |  /-> movem.l d0-d3,-(a0)
     ce4:	                  |                                |  |   movem.l d0-d3,-(a0)
     ce8:	                  |                                |  |   movem.l d0-d3,-(a0)
     cec:	                  |                                |  |   movem.l d0-d3,-(a0)
     cf0:	                  |                                |  |   movem.l d0-d3,-(a0)
     cf4:	                  |                                |  |   movem.l d0-d3,-(a0)
     cf8:	                  |                                |  |   movem.l d0-d3,-(a0)
     cfc:	                  |                                |  |   movem.l d0-d3,-(a0)
     d00:	                  |                                |  |   movem.l d0-d3,-(a0)
     d04:	                  |                                |  |   movem.l d0-d3,-(a0)
     d08:	                  |                                |  |   movem.l d0-d3,-(a0)
     d0c:	                  |                                |  |   movem.l d0-d3,-(a0)
     d10:	                  |                                |  |   movem.l d0-d3,-(a0)
     d14:	                  |                                |  |   movem.l d0-d3,-(a0)
     d18:	                  |                                |  |   movem.l d0-d3,-(a0)
     d1c:	                  |                                |  |   movem.l d0-d3,-(a0)
     d20:	                  |                                |  |   subi.l #256,d5
     d26:	                  |                                |  |   cmpi.l #256,d5
     d2c:	                  |                                |  \-- bge.w ce0 <main+0xc54>
     d30:	                  |                                >----> cmpi.w #64,d5
     d34:	                  |                                |  /-- blt.w d50 <main+0xcc4>
     d38:	                  |                                |  |   movem.l d0-d3,-(a0)
     d3c:	                  |                                |  |   movem.l d0-d3,-(a0)
     d40:	                  |                                |  |   movem.l d0-d3,-(a0)
     d44:	                  |                                |  |   movem.l d0-d3,-(a0)
     d48:	                  |                                |  |   subi.w #64,d5
     d4c:	                  |                                \--|-- bra.w d30 <main+0xca4>
     d50:	                  |                                   \-> lsr.w #2,d5
     d52:	                  |                                   /-- bcc.w d58 <main+0xccc>
     d56:	                  |                                   |   clr.w -(a0)
     d58:	                  |                                   \-> moveq #16,d0
     d5a:	                  |                                       sub.w d5,d0
     d5c:	                  |                                       add.w d0,d0
     d5e:	                  |                                       jmp (d62 <main+0xcd6>,pc,d0.w)
     d62:	                  |                                       clr.l -(a0)
     d64:	                  |                                       clr.l -(a0)
     d66:	                  |                                       clr.l -(a0)
     d68:	                  |                                       clr.l -(a0)
     d6a:	                  |                                       clr.l -(a0)
     d6c:	                  |                                       clr.l -(a0)
     d6e:	                  |                                       clr.l -(a0)
     d70:	                  |                                       clr.l -(a0)
     d72:	                  |                                       clr.l -(a0)
     d74:	                  |                                       clr.l -(a0)
     d76:	                  |                                       clr.l -(a0)
     d78:	                  |                                       clr.l -(a0)
     d7a:	                  |                                       clr.l -(a0)
     d7c:	                  |                                       clr.l -(a0)
     d7e:	                  |                                       clr.l -(a0)
     d80:	                  |                                       clr.l -(a0)
	FreeMem(test, 2502);
     d82:	                  |                                       movea.l 12b9a <SysBase>,a6
     d88:	                  |                                       movea.l d4,a1
     d8a:	                  |                                       move.l #2502,d0
     d90:	                  |                                       jsr -210(a6)
	USHORT* copper1 = (USHORT*)AllocMem(1024, MEMF_CHIP);
     d94:	                  |                                       movea.l 12b9a <SysBase>,a6
     d9a:	                  |                                       move.l #1024,d0
     da0:	                  |                                       moveq #2,d1
     da2:	                  |                                       jsr -198(a6)
     da6:	                  |                                       movea.l d0,a3
	debug_register_bitmap(image, "image.bpl", 320, 256, 5, debug_resource_bitmap_interleaved);
     da8:	                  |                                       pea 1 <_start+0x1>
     dac:	                  |                                       pea 100 <main+0x74>
     db0:	                  |                                       pea 140 <main+0xb4>
     db4:	                  |                                       pea 3306 <incbin_player_end+0x12e>
     dba:	                  |                                       pea 4000 <incbin_image_start>
     dc0:	                  |                                       lea 115c <debug_register_bitmap.constprop.0>,a4
     dc6:	                  |                                       jsr (a4)
	debug_register_bitmap(bob, "bob.bpl", 32, 96, 5, debug_resource_bitmap_interleaved | debug_resource_bitmap_masked);
     dc8:	                  |                                       lea 32(sp),sp
     dcc:	                  |                                       pea 3 <_start+0x3>
     dd0:	                  |                                       pea 60 <_start+0x60>
     dd4:	                  |                                       pea 20 <_start+0x20>
     dd8:	                  |                                       pea 3310 <incbin_player_end+0x138>
     dde:	                  |                                       pea 10802 <incbin_bob_start>
     de4:	                  |                                       jsr (a4)
	struct debug_resource resource = {
     de6:	                  |                                       clr.l -42(a5)
     dea:	                  |                                       clr.l -38(a5)
     dee:	                  |                                       clr.l -34(a5)
     df2:	                  |                                       clr.l -30(a5)
     df6:	                  |                                       clr.l -26(a5)
     dfa:	                  |                                       clr.l -22(a5)
     dfe:	                  |                                       clr.l -18(a5)
     e02:	                  |                                       clr.l -14(a5)
     e06:	                  |                                       clr.l -10(a5)
     e0a:	                  |                                       clr.l -6(a5)
     e0e:	                  |                                       clr.w -2(a5)
		.address = (unsigned int)addr,
     e12:	                  |                                       move.l #6192,d3
	struct debug_resource resource = {
     e18:	                  |                                       move.l d3,-50(a5)
     e1c:	                  |                                       moveq #64,d1
     e1e:	                  |                                       move.l d1,-46(a5)
     e22:	                  |                                       move.w #1,-10(a5)
     e28:	                  |                                       move.w #32,-6(a5)
     e2e:	                  |                                       lea 20(sp),sp
	while(*source && --num > 0)
     e32:	                  |                                       moveq #105,d0
	struct debug_resource resource = {
     e34:	                  |                                       lea -42(a5),a0
     e38:	                  |                                       lea 32a2 <incbin_player_end+0xca>,a1
	while(*source && --num > 0)
     e3e:	                  |                                       lea -11(a5),a4
     e42:	                  \-------------------------------------- bra.w 3e2 <main+0x356>
     e46:	                                                          nop

00000e48 <interruptHandler>:
static __attribute__((interrupt)) void interruptHandler() {
     e48:	    movem.l d0-d1/a0-a1/a3/a6,-(sp)
	custom->intreq=(1<<INTB_VERTB); custom->intreq=(1<<INTB_VERTB); //reset vbl req. twice for a4000 bug.
     e4c:	    movea.l 12ba4 <custom>,a0
     e52:	    move.w #32,156(a0)
     e58:	    move.w #32,156(a0)
	if(scroll) {
     e5e:	    movea.l 12ba0 <scroll>,a0
     e64:	    cmpa.w #0,a0
     e68:	/-- beq.s e8c <interruptHandler+0x44>
		int sin = sinus15[frameCounter & 63];
     e6a:	|   move.w 12b9e <frameCounter>,d0
     e70:	|   moveq #63,d1
     e72:	|   and.l d1,d0
     e74:	|   lea 33ba <sinus15>,a1
     e7a:	|   move.b (0,a1,d0.l),d0
     e7e:	|   moveq #0,d1
     e80:	|   move.b d0,d1
		*scroll = sin | (sin << 4);
     e82:	|   lsl.l #4,d1
     e84:	|   andi.w #255,d0
     e88:	|   or.w d1,d0
     e8a:	|   move.w d0,(a0)
		register volatile const void* _a3 ASM("a3") = player;
     e8c:	\-> lea 1872 <incbin_player_start>,a3
		register volatile const void* _a6 ASM("a6") = (void*)0xdff000;
     e92:	    movea.l #14675968,a6
		__asm volatile (
     e98:	    movem.l d0-a2/a4-a5,-(sp)
     e9c:	    jsr 4(a3)
     ea0:	    movem.l (sp)+,d0-a2/a4-a5
	frameCounter++;
     ea4:	    move.w 12b9e <frameCounter>,d0
     eaa:	    addq.w #1,d0
     eac:	    move.w d0,12b9e <frameCounter>
}
     eb2:	    movem.l (sp)+,d0-d1/a0-a1/a3/a6
     eb6:	    rte

00000eb8 <debug_cmd.part.0>:
		UaeLib(88, arg1, arg2, arg3, arg4);
     eb8:	move.l 16(sp),-(sp)
     ebc:	move.l 16(sp),-(sp)
     ec0:	move.l 16(sp),-(sp)
     ec4:	move.l 16(sp),-(sp)
     ec8:	pea 58 <_start+0x58>
     ecc:	jsr f0ff60 <_end+0xefd3b8>
}
     ed2:	lea 20(sp),sp
     ed6:	rts

00000ed8 <WaitVbl>:
void WaitVbl() {
     ed8:	             subq.l #8,sp
	if(*((UWORD *)UaeLib) == 0x4eb9 || *((UWORD *)UaeLib) == 0xa00e) {
     eda:	             move.w f0ff60 <_end+0xefd3b8>,d0
     ee0:	             cmpi.w #20153,d0
     ee4:	      /----- beq.s f58 <WaitVbl+0x80>
     ee6:	      |      cmpi.w #-24562,d0
     eea:	      +----- beq.s f58 <WaitVbl+0x80>
		volatile ULONG vpos=*(volatile ULONG*)0xDFF004;
     eec:	/-----|----> move.l dff004 <_end+0xdec45c>,d0
     ef2:	|     |      move.l d0,(sp)
		vpos&=0x1ff00;
     ef4:	|     |      move.l (sp),d0
     ef6:	|     |      andi.l #130816,d0
     efc:	|     |      move.l d0,(sp)
		if (vpos!=(311<<8))
     efe:	|     |      move.l (sp),d0
     f00:	|     |      cmpi.l #79616,d0
     f06:	+-----|----- beq.s eec <WaitVbl+0x14>
		volatile ULONG vpos=*(volatile ULONG*)0xDFF004;
     f08:	|  /--|----> move.l dff004 <_end+0xdec45c>,d0
     f0e:	|  |  |      move.l d0,4(sp)
		vpos&=0x1ff00;
     f12:	|  |  |      move.l 4(sp),d0
     f16:	|  |  |      andi.l #130816,d0
     f1c:	|  |  |      move.l d0,4(sp)
		if (vpos==(311<<8))
     f20:	|  |  |      move.l 4(sp),d0
     f24:	|  |  |      cmpi.l #79616,d0
     f2a:	|  +--|----- bne.s f08 <WaitVbl+0x30>
     f2c:	|  |  |      move.w f0ff60 <_end+0xefd3b8>,d0
     f32:	|  |  |      cmpi.w #20153,d0
     f36:	|  |  |  /-- beq.s f42 <WaitVbl+0x6a>
     f38:	|  |  |  |   cmpi.w #-24562,d0
     f3c:	|  |  |  +-- beq.s f42 <WaitVbl+0x6a>
}
     f3e:	|  |  |  |   addq.l #8,sp
     f40:	|  |  |  |   rts
     f42:	|  |  |  \-> clr.l -(sp)
     f44:	|  |  |      clr.l -(sp)
     f46:	|  |  |      clr.l -(sp)
     f48:	|  |  |      pea 5 <_start+0x5>
     f4c:	|  |  |      jsr eb8 <debug_cmd.part.0>(pc)
}
     f50:	|  |  |      lea 16(sp),sp
     f54:	|  |  |      addq.l #8,sp
     f56:	|  |  |      rts
     f58:	|  |  \----> clr.l -(sp)
     f5a:	|  |         clr.l -(sp)
     f5c:	|  |         pea 1 <_start+0x1>
     f60:	|  |         pea 5 <_start+0x5>
     f64:	|  |         jsr eb8 <debug_cmd.part.0>(pc)
}
     f68:	|  |         lea 16(sp),sp
		volatile ULONG vpos=*(volatile ULONG*)0xDFF004;
     f6c:	|  |         move.l dff004 <_end+0xdec45c>,d0
     f72:	|  |         move.l d0,(sp)
		vpos&=0x1ff00;
     f74:	|  |         move.l (sp),d0
     f76:	|  |         andi.l #130816,d0
     f7c:	|  |         move.l d0,(sp)
		if (vpos!=(311<<8))
     f7e:	|  |         move.l (sp),d0
     f80:	|  |         cmpi.l #79616,d0
     f86:	\--|-------- beq.w eec <WaitVbl+0x14>
     f8a:	   \-------- bra.w f08 <WaitVbl+0x30>

00000f8e <KPrintF>:
void KPrintF(const char* fmt, ...) {
     f8e:	    lea -128(sp),sp
     f92:	    movem.l a2-a3/a6,-(sp)
	if(*((UWORD *)UaeDbgLog) == 0x4eb9 || *((UWORD *)UaeDbgLog) == 0xa00e) {
     f96:	    move.w f0ff60 <_end+0xefd3b8>,d0
     f9c:	    cmpi.w #20153,d0
     fa0:	/-- beq.s fcc <KPrintF+0x3e>
     fa2:	|   cmpi.w #-24562,d0
     fa6:	+-- beq.s fcc <KPrintF+0x3e>
		RawDoFmt((CONST_STRPTR)fmt, vl, KPutCharX, 0);
     fa8:	|   movea.l 12b9a <SysBase>,a6
     fae:	|   movea.l 144(sp),a0
     fb2:	|   lea 148(sp),a1
     fb6:	|   lea 167a <KPutCharX>,a2
     fbc:	|   suba.l a3,a3
     fbe:	|   jsr -522(a6)
}
     fc2:	|   movem.l (sp)+,a2-a3/a6
     fc6:	|   lea 128(sp),sp
     fca:	|   rts
		RawDoFmt((CONST_STRPTR)fmt, vl, PutChar, temp);
     fcc:	\-> movea.l 12b9a <SysBase>,a6
     fd2:	    movea.l 144(sp),a0
     fd6:	    lea 148(sp),a1
     fda:	    lea 1688 <PutChar>,a2
     fe0:	    lea 12(sp),a3
     fe4:	    jsr -522(a6)
		UaeDbgLog(86, temp);
     fe8:	    move.l a3,-(sp)
     fea:	    pea 56 <_start+0x56>
     fee:	    jsr f0ff60 <_end+0xefd3b8>
	if(*((UWORD *)UaeDbgLog) == 0x4eb9 || *((UWORD *)UaeDbgLog) == 0xa00e) {
     ff4:	    addq.l #8,sp
}
     ff6:	    movem.l (sp)+,a2-a3/a6
     ffa:	    lea 128(sp),sp
     ffe:	    rts

00001000 <warpmode>:
void warpmode(int on) { // bool
    1000:	       subq.l #4,sp
    1002:	       move.l a2,-(sp)
    1004:	       move.l d2,-(sp)
	if(*((UWORD *)UaeConf) == 0x4eb9 || *((UWORD *)UaeConf) == 0xa00e) {
    1006:	       move.w f0ff60 <_end+0xefd3b8>,d0
    100c:	       cmpi.w #20153,d0
    1010:	   /-- beq.s 1020 <warpmode+0x20>
    1012:	   |   cmpi.w #-24562,d0
    1016:	   +-- beq.s 1020 <warpmode+0x20>
}
    1018:	   |   move.l (sp)+,d2
    101a:	   |   movea.l (sp)+,a2
    101c:	   |   addq.l #4,sp
    101e:	   |   rts
		UaeConf(82, -1, on ? "cpu_speed max" : "cpu_speed real", 0, &outbuf, 1);
    1020:	   \-> tst.l 16(sp)
    1024:	/----- beq.w 10c4 <warpmode+0xc4>
    1028:	|      pea 1 <_start+0x1>
    102c:	|      moveq #15,d2
    102e:	|      add.l sp,d2
    1030:	|      move.l d2,-(sp)
    1032:	|      clr.l -(sp)
    1034:	|      pea 3247 <incbin_player_end+0x6f>
    103a:	|      pea ffffffff <_end+0xfffed457>
    103e:	|      pea 52 <_start+0x52>
    1042:	|      movea.l #15794016,a2
    1048:	|      jsr (a2)
		UaeConf(82, -1, on ? "cpu_cycle_exact false" : "cpu_cycle_exact true", 0, &outbuf, 1);
    104a:	|      pea 1 <_start+0x1>
    104e:	|      move.l d2,-(sp)
    1050:	|      clr.l -(sp)
    1052:	|      pea 3255 <incbin_player_end+0x7d>
    1058:	|      pea ffffffff <_end+0xfffed457>
    105c:	|      pea 52 <_start+0x52>
    1060:	|      jsr (a2)
		UaeConf(82, -1, on ? "cpu_memory_cycle_exact false" : "cpu_memory_cycle_exact true", 0, &outbuf, 1);
    1062:	|      lea 48(sp),sp
    1066:	|      pea 1 <_start+0x1>
    106a:	|      move.l d2,-(sp)
    106c:	|      clr.l -(sp)
    106e:	|      pea 326b <incbin_player_end+0x93>
    1074:	|      pea ffffffff <_end+0xfffed457>
    1078:	|      pea 52 <_start+0x52>
    107c:	|      jsr (a2)
		UaeConf(82, -1, on ? "blitter_cycle_exact false" : "blitter_cycle_exact true", 0, &outbuf, 1);
    107e:	|      pea 1 <_start+0x1>
    1082:	|      move.l d2,-(sp)
    1084:	|      clr.l -(sp)
    1086:	|      pea 3288 <incbin_player_end+0xb0>
    108c:	|      pea ffffffff <_end+0xfffed457>
    1090:	|      pea 52 <_start+0x52>
    1094:	|      jsr (a2)
    1096:	|      lea 48(sp),sp
		UaeConf(82, -1, on ? "warp true" : "warp false", 0, &outbuf, 1);
    109a:	|      move.l #12761,d0
    10a0:	|      pea 1 <_start+0x1>
    10a4:	|      move.l d2,-(sp)
    10a6:	|      clr.l -(sp)
    10a8:	|      move.l d0,-(sp)
    10aa:	|      pea ffffffff <_end+0xfffed457>
    10ae:	|      pea 52 <_start+0x52>
    10b2:	|      jsr f0ff60 <_end+0xefd3b8>
}
    10b8:	|      lea 24(sp),sp
    10bc:	|  /-> move.l (sp)+,d2
    10be:	|  |   movea.l (sp)+,a2
    10c0:	|  |   addq.l #4,sp
    10c2:	|  |   rts
		UaeConf(82, -1, on ? "cpu_speed max" : "cpu_speed real", 0, &outbuf, 1);
    10c4:	\--|-> pea 1 <_start+0x1>
    10c8:	   |   moveq #15,d2
    10ca:	   |   add.l sp,d2
    10cc:	   |   move.l d2,-(sp)
    10ce:	   |   clr.l -(sp)
    10d0:	   |   pea 31ee <incbin_player_end+0x16>
    10d6:	   |   pea ffffffff <_end+0xfffed457>
    10da:	   |   pea 52 <_start+0x52>
    10de:	   |   movea.l #15794016,a2
    10e4:	   |   jsr (a2)
		UaeConf(82, -1, on ? "cpu_cycle_exact false" : "cpu_cycle_exact true", 0, &outbuf, 1);
    10e6:	   |   pea 1 <_start+0x1>
    10ea:	   |   move.l d2,-(sp)
    10ec:	   |   clr.l -(sp)
    10ee:	   |   pea 31fd <incbin_player_end+0x25>
    10f4:	   |   pea ffffffff <_end+0xfffed457>
    10f8:	   |   pea 52 <_start+0x52>
    10fc:	   |   jsr (a2)
		UaeConf(82, -1, on ? "cpu_memory_cycle_exact false" : "cpu_memory_cycle_exact true", 0, &outbuf, 1);
    10fe:	   |   lea 48(sp),sp
    1102:	   |   pea 1 <_start+0x1>
    1106:	   |   move.l d2,-(sp)
    1108:	   |   clr.l -(sp)
    110a:	   |   pea 3212 <incbin_player_end+0x3a>
    1110:	   |   pea ffffffff <_end+0xfffed457>
    1114:	   |   pea 52 <_start+0x52>
    1118:	   |   jsr (a2)
		UaeConf(82, -1, on ? "blitter_cycle_exact false" : "blitter_cycle_exact true", 0, &outbuf, 1);
    111a:	   |   pea 1 <_start+0x1>
    111e:	   |   move.l d2,-(sp)
    1120:	   |   clr.l -(sp)
    1122:	   |   pea 322e <incbin_player_end+0x56>
    1128:	   |   pea ffffffff <_end+0xfffed457>
    112c:	   |   pea 52 <_start+0x52>
    1130:	   |   jsr (a2)
    1132:	   |   lea 48(sp),sp
		UaeConf(82, -1, on ? "warp true" : "warp false", 0, &outbuf, 1);
    1136:	   |   move.l #12771,d0
    113c:	   |   pea 1 <_start+0x1>
    1140:	   |   move.l d2,-(sp)
    1142:	   |   clr.l -(sp)
    1144:	   |   move.l d0,-(sp)
    1146:	   |   pea ffffffff <_end+0xfffed457>
    114a:	   |   pea 52 <_start+0x52>
    114e:	   |   jsr f0ff60 <_end+0xefd3b8>
}
    1154:	   |   lea 24(sp),sp
    1158:	   \-- bra.w 10bc <warpmode+0xbc>

0000115c <debug_register_bitmap.constprop.0>:
void debug_register_bitmap(const void* addr, const char* name, short width, short height, short numPlanes, unsigned short flags) {
    115c:	       link.w a5,#-52
    1160:	       movem.l d2-d4/a2,-(sp)
    1164:	       movea.l 12(a5),a1
    1168:	       move.l 16(a5),d4
    116c:	       move.l 20(a5),d3
    1170:	       move.l 24(a5),d2
	struct debug_resource resource = {
    1174:	       clr.l -42(a5)
    1178:	       clr.l -38(a5)
    117c:	       clr.l -34(a5)
    1180:	       clr.l -30(a5)
    1184:	       clr.l -26(a5)
    1188:	       clr.l -22(a5)
    118c:	       clr.l -18(a5)
    1190:	       clr.l -14(a5)
    1194:	       clr.w -10(a5)
    1198:	       move.l 8(a5),-50(a5)
		.size = width / 8 * height * numPlanes,
    119e:	       move.w d4,d0
    11a0:	       asr.w #3,d0
    11a2:	       muls.w d3,d0
    11a4:	       move.l d0,d1
    11a6:	       add.l d0,d1
    11a8:	       add.l d1,d1
    11aa:	       add.l d1,d0
	struct debug_resource resource = {
    11ac:	       move.l d0,-46(a5)
    11b0:	       move.w d2,-8(a5)
    11b4:	       move.w d4,-6(a5)
    11b8:	       move.w d3,-4(a5)
    11bc:	       move.w #5,-2(a5)
	if (flags & debug_resource_bitmap_masked)
    11c2:	       btst #1,d2
    11c6:	   /-- beq.s 11ce <debug_register_bitmap.constprop.0+0x72>
		resource.size *= 2;
    11c8:	   |   add.l d0,d0
    11ca:	   |   move.l d0,-46(a5)
	while(*source && --num > 0)
    11ce:	   \-> move.b (a1),d0
    11d0:	       lea -42(a5),a0
    11d4:	/----- beq.s 11e6 <debug_register_bitmap.constprop.0+0x8a>
    11d6:	|      lea -11(a5),a2
		*destination++ = *source++;
    11da:	|  /-> addq.l #1,a1
    11dc:	|  |   move.b d0,(a0)+
	while(*source && --num > 0)
    11de:	|  |   move.b (a1),d0
    11e0:	+--|-- beq.s 11e6 <debug_register_bitmap.constprop.0+0x8a>
    11e2:	|  |   cmpa.l a0,a2
    11e4:	|  \-- bne.s 11da <debug_register_bitmap.constprop.0+0x7e>
	*destination = '\0';
    11e6:	\----> clr.b (a0)
	if(*((UWORD *)UaeLib) == 0x4eb9 || *((UWORD *)UaeLib) == 0xa00e) {
    11e8:	       move.w f0ff60 <_end+0xefd3b8>,d0
    11ee:	       cmpi.w #20153,d0
    11f2:	   /-- beq.s 1204 <debug_register_bitmap.constprop.0+0xa8>
    11f4:	   |   cmpi.w #-24562,d0
    11f8:	   +-- beq.s 1204 <debug_register_bitmap.constprop.0+0xa8>
}
    11fa:	   |   movem.l -68(a5),d2-d4/a2
    1200:	   |   unlk a5
    1202:	   |   rts
    1204:	   \-> clr.l -(sp)
    1206:	       clr.l -(sp)
    1208:	       pea -50(a5)
    120c:	       pea 4 <_start+0x4>
    1210:	       jsr eb8 <debug_cmd.part.0>(pc)
    1214:	       lea 16(sp),sp
    1218:	       movem.l -68(a5),d2-d4/a2
    121e:	       unlk a5
    1220:	       rts

00001222 <debug_register_copperlist.constprop.0>:
	};
	my_strncpy(resource.name, name, sizeof(resource.name));
	debug_cmd(barto_cmd_register_resource, (unsigned int)&resource, 0, 0);
}

void debug_register_copperlist(const void* addr, const char* name, unsigned int size, unsigned short flags) {
    1222:	       link.w a5,#-52
    1226:	       move.l a2,-(sp)
    1228:	       movea.l 12(a5),a1
	struct debug_resource resource = {
    122c:	       clr.l -42(a5)
    1230:	       clr.l -38(a5)
    1234:	       clr.l -34(a5)
    1238:	       clr.l -30(a5)
    123c:	       clr.l -26(a5)
    1240:	       clr.l -22(a5)
    1244:	       clr.l -18(a5)
    1248:	       clr.l -14(a5)
    124c:	       clr.l -10(a5)
    1250:	       clr.l -6(a5)
    1254:	       clr.w -2(a5)
    1258:	       move.l 8(a5),-50(a5)
    125e:	       move.l 16(a5),-46(a5)
    1264:	       move.w #2,-10(a5)
	while(*source && --num > 0)
    126a:	       move.b (a1),d0
    126c:	       lea -42(a5),a0
    1270:	/----- beq.s 1282 <debug_register_copperlist.constprop.0+0x60>
    1272:	|      lea -11(a5),a2
		*destination++ = *source++;
    1276:	|  /-> addq.l #1,a1
    1278:	|  |   move.b d0,(a0)+
	while(*source && --num > 0)
    127a:	|  |   move.b (a1),d0
    127c:	+--|-- beq.s 1282 <debug_register_copperlist.constprop.0+0x60>
    127e:	|  |   cmpa.l a0,a2
    1280:	|  \-- bne.s 1276 <debug_register_copperlist.constprop.0+0x54>
	*destination = '\0';
    1282:	\----> clr.b (a0)
	if(*((UWORD *)UaeLib) == 0x4eb9 || *((UWORD *)UaeLib) == 0xa00e) {
    1284:	       move.w f0ff60 <_end+0xefd3b8>,d0
    128a:	       cmpi.w #20153,d0
    128e:	   /-- beq.s 129e <debug_register_copperlist.constprop.0+0x7c>
    1290:	   |   cmpi.w #-24562,d0
    1294:	   +-- beq.s 129e <debug_register_copperlist.constprop.0+0x7c>
		.type = debug_resource_type_copperlist,
		.flags = flags,
	};
	my_strncpy(resource.name, name, sizeof(resource.name));
	debug_cmd(barto_cmd_register_resource, (unsigned int)&resource, 0, 0);
}
    1296:	   |   movea.l -56(a5),a2
    129a:	   |   unlk a5
    129c:	   |   rts
    129e:	   \-> clr.l -(sp)
    12a0:	       clr.l -(sp)
    12a2:	       pea -50(a5)
    12a6:	       pea 4 <_start+0x4>
    12aa:	       jsr eb8 <debug_cmd.part.0>(pc)
    12ae:	       lea 16(sp),sp
    12b2:	       movea.l -56(a5),a2
    12b6:	       unlk a5
    12b8:	       rts

000012ba <strlen>:
	while(*s++)
    12ba:	   /-> movea.l 4(sp),a0
    12be:	   |   tst.b (a0)+
    12c0:	/--|-- beq.s 12ce <strlen+0x14>
    12c2:	|  |   move.l a0,-(sp)
    12c4:	|  \-- jsr 12ba <strlen>(pc)
    12c8:	|      addq.l #4,sp
    12ca:	|      addq.l #1,d0
}
    12cc:	|      rts
	unsigned long t=0;
    12ce:	\----> moveq #0,d0
}
    12d0:	       rts

000012d2 <memset>:
void* memset(void *dest, int val, unsigned long len) {
    12d2:	                      movem.l d2-d7/a2,-(sp)
    12d6:	                      move.l 32(sp),d0
    12da:	                      move.l 36(sp),d4
    12de:	                      movea.l 40(sp),a0
	while(len-- > 0)
    12e2:	                      lea -1(a0),a1
    12e6:	                      cmpa.w #0,a0
    12ea:	               /----- beq.w 13a0 <memset+0xce>
		*ptr++ = val;
    12ee:	               |      move.b d4,d7
    12f0:	               |      move.l d0,d2
    12f2:	               |      neg.l d2
    12f4:	               |      moveq #3,d1
    12f6:	               |      and.l d2,d1
    12f8:	               |      moveq #5,d3
    12fa:	               |      cmp.l a1,d3
    12fc:	/--------------|----- bcc.w 143c <memset+0x16a>
    1300:	|              |      tst.l d1
    1302:	|        /-----|----- beq.w 13da <memset+0x108>
    1306:	|        |     |      movea.l d0,a1
    1308:	|        |     |      move.b d4,(a1)
	while(len-- > 0)
    130a:	|        |     |      btst #1,d2
    130e:	|        |     |  /-- beq.w 13a6 <memset+0xd4>
		*ptr++ = val;
    1312:	|        |     |  |   move.b d4,1(a1)
	while(len-- > 0)
    1316:	|        |     |  |   move.l d0,d2
    1318:	|        |     |  |   subq.l #1,d2
    131a:	|        |     |  |   moveq #3,d3
    131c:	|        |     |  |   and.l d3,d2
    131e:	|  /-----|-----|--|-- bne.w 1408 <memset+0x136>
		*ptr++ = val;
    1322:	|  |     |     |  |   lea 3(a1),a2
    1326:	|  |     |     |  |   move.b d4,2(a1)
	while(len-- > 0)
    132a:	|  |     |     |  |   lea -4(a0),a1
    132e:	|  |     |     |  |   move.l a0,d3
    1330:	|  |     |     |  |   sub.l d1,d3
    1332:	|  |     |     |  |   moveq #0,d5
    1334:	|  |     |     |  |   move.b d4,d5
    1336:	|  |     |     |  |   move.l d5,d6
    1338:	|  |     |     |  |   swap d6
    133a:	|  |     |     |  |   clr.w d6
    133c:	|  |     |     |  |   move.l d4,d2
    133e:	|  |     |     |  |   lsl.w #8,d2
    1340:	|  |     |     |  |   swap d2
    1342:	|  |     |     |  |   clr.w d2
    1344:	|  |     |     |  |   lsl.l #8,d5
    1346:	|  |     |     |  |   or.l d6,d2
    1348:	|  |     |     |  |   or.l d5,d2
    134a:	|  |     |     |  |   move.b d7,d2
    134c:	|  |     |     |  |   movea.l d0,a0
    134e:	|  |     |     |  |   adda.l d1,a0
    1350:	|  |     |     |  |   moveq #-4,d1
    1352:	|  |     |     |  |   and.l d3,d1
    1354:	|  |     |     |  |   add.l a0,d1
		*ptr++ = val;
    1356:	|  |  /--|-----|--|-> move.l d2,(a0)+
	while(len-- > 0)
    1358:	|  |  |  |     |  |   cmp.l a0,d1
    135a:	|  |  +--|-----|--|-- bne.s 1356 <memset+0x84>
    135c:	|  |  |  |     |  |   moveq #3,d1
    135e:	|  |  |  |     |  |   and.l d3,d1
    1360:	|  |  |  |     +--|-- beq.s 13a0 <memset+0xce>
    1362:	|  |  |  |     |  |   moveq #-4,d1
    1364:	|  |  |  |     |  |   and.l d1,d3
    1366:	|  |  |  |     |  |   lea (0,a2,d3.l),a0
    136a:	|  |  |  |     |  |   suba.l d3,a1
		*ptr++ = val;
    136c:	|  |  |  |  /--|--|-> move.b d4,(a0)
	while(len-- > 0)
    136e:	|  |  |  |  |  |  |   cmpa.w #0,a1
    1372:	|  |  |  |  |  +--|-- beq.s 13a0 <memset+0xce>
		*ptr++ = val;
    1374:	|  |  |  |  |  |  |   move.b d4,1(a0)
	while(len-- > 0)
    1378:	|  |  |  |  |  |  |   moveq #1,d3
    137a:	|  |  |  |  |  |  |   cmp.l a1,d3
    137c:	|  |  |  |  |  +--|-- beq.s 13a0 <memset+0xce>
		*ptr++ = val;
    137e:	|  |  |  |  |  |  |   move.b d4,2(a0)
	while(len-- > 0)
    1382:	|  |  |  |  |  |  |   moveq #2,d1
    1384:	|  |  |  |  |  |  |   cmp.l a1,d1
    1386:	|  |  |  |  |  +--|-- beq.s 13a0 <memset+0xce>
		*ptr++ = val;
    1388:	|  |  |  |  |  |  |   move.b d4,3(a0)
	while(len-- > 0)
    138c:	|  |  |  |  |  |  |   moveq #3,d3
    138e:	|  |  |  |  |  |  |   cmp.l a1,d3
    1390:	|  |  |  |  |  +--|-- beq.s 13a0 <memset+0xce>
		*ptr++ = val;
    1392:	|  |  |  |  |  |  |   move.b d4,4(a0)
	while(len-- > 0)
    1396:	|  |  |  |  |  |  |   moveq #4,d1
    1398:	|  |  |  |  |  |  |   cmp.l a1,d1
    139a:	|  |  |  |  |  +--|-- beq.s 13a0 <memset+0xce>
		*ptr++ = val;
    139c:	|  |  |  |  |  |  |   move.b d4,5(a0)
}
    13a0:	|  |  |  |  |  \--|-> movem.l (sp)+,d2-d7/a2
    13a4:	|  |  |  |  |     |   rts
		*ptr++ = val;
    13a6:	|  |  |  |  |     \-> lea 1(a1),a2
	while(len-- > 0)
    13aa:	|  |  |  |  |         lea -2(a0),a1
    13ae:	|  |  |  |  |         move.l a0,d3
    13b0:	|  |  |  |  |         sub.l d1,d3
    13b2:	|  |  |  |  |         moveq #0,d5
    13b4:	|  |  |  |  |         move.b d4,d5
    13b6:	|  |  |  |  |         move.l d5,d6
    13b8:	|  |  |  |  |         swap d6
    13ba:	|  |  |  |  |         clr.w d6
    13bc:	|  |  |  |  |         move.l d4,d2
    13be:	|  |  |  |  |         lsl.w #8,d2
    13c0:	|  |  |  |  |         swap d2
    13c2:	|  |  |  |  |         clr.w d2
    13c4:	|  |  |  |  |         lsl.l #8,d5
    13c6:	|  |  |  |  |         or.l d6,d2
    13c8:	|  |  |  |  |         or.l d5,d2
    13ca:	|  |  |  |  |         move.b d7,d2
    13cc:	|  |  |  |  |         movea.l d0,a0
    13ce:	|  |  |  |  |         adda.l d1,a0
    13d0:	|  |  |  |  |         moveq #-4,d1
    13d2:	|  |  |  |  |         and.l d3,d1
    13d4:	|  |  |  |  |         add.l a0,d1
    13d6:	|  |  +--|--|-------- bra.w 1356 <memset+0x84>
	unsigned char *ptr = (unsigned char *)dest;
    13da:	|  |  |  \--|-------> movea.l d0,a2
    13dc:	|  |  |     |         move.l a0,d3
    13de:	|  |  |     |         sub.l d1,d3
    13e0:	|  |  |     |         moveq #0,d5
    13e2:	|  |  |     |         move.b d4,d5
    13e4:	|  |  |     |         move.l d5,d6
    13e6:	|  |  |     |         swap d6
    13e8:	|  |  |     |         clr.w d6
    13ea:	|  |  |     |         move.l d4,d2
    13ec:	|  |  |     |         lsl.w #8,d2
    13ee:	|  |  |     |         swap d2
    13f0:	|  |  |     |         clr.w d2
    13f2:	|  |  |     |         lsl.l #8,d5
    13f4:	|  |  |     |         or.l d6,d2
    13f6:	|  |  |     |         or.l d5,d2
    13f8:	|  |  |     |         move.b d7,d2
    13fa:	|  |  |     |         movea.l d0,a0
    13fc:	|  |  |     |         adda.l d1,a0
    13fe:	|  |  |     |         moveq #-4,d1
    1400:	|  |  |     |         and.l d3,d1
    1402:	|  |  |     |         add.l a0,d1
    1404:	|  |  +-----|-------- bra.w 1356 <memset+0x84>
		*ptr++ = val;
    1408:	|  \--|-----|-------> lea 2(a1),a2
	while(len-- > 0)
    140c:	|     |     |         lea -3(a0),a1
    1410:	|     |     |         move.l a0,d3
    1412:	|     |     |         sub.l d1,d3
    1414:	|     |     |         moveq #0,d5
    1416:	|     |     |         move.b d4,d5
    1418:	|     |     |         move.l d5,d6
    141a:	|     |     |         swap d6
    141c:	|     |     |         clr.w d6
    141e:	|     |     |         move.l d4,d2
    1420:	|     |     |         lsl.w #8,d2
    1422:	|     |     |         swap d2
    1424:	|     |     |         clr.w d2
    1426:	|     |     |         lsl.l #8,d5
    1428:	|     |     |         or.l d6,d2
    142a:	|     |     |         or.l d5,d2
    142c:	|     |     |         move.b d7,d2
    142e:	|     |     |         movea.l d0,a0
    1430:	|     |     |         adda.l d1,a0
    1432:	|     |     |         moveq #-4,d1
    1434:	|     |     |         and.l d3,d1
    1436:	|     |     |         add.l a0,d1
    1438:	|     \-----|-------- bra.w 1356 <memset+0x84>
	unsigned char *ptr = (unsigned char *)dest;
    143c:	\-----------|-------> movea.l d0,a0
    143e:	            \-------- bra.w 136c <memset+0x9a>

00001442 <memcpy>:
void* memcpy(void *dest, const void *src, unsigned long len) {
    1442:	             movem.l d2-d5,-(sp)
    1446:	             move.l 20(sp),d0
    144a:	             move.l 24(sp),d1
    144e:	             move.l 28(sp),d2
	while(len--)
    1452:	             move.l d2,d4
    1454:	             subq.l #1,d4
    1456:	             tst.l d2
    1458:	/----------- beq.s 14b2 <memcpy+0x70>
    145a:	|            moveq #6,d3
    145c:	|            cmp.l d4,d3
    145e:	|  /-------- bcc.s 14b8 <memcpy+0x76>
    1460:	|  |         move.l d0,d3
    1462:	|  |         or.l d1,d3
    1464:	|  |         moveq #3,d5
    1466:	|  |         and.l d5,d3
    1468:	|  |         movea.l d1,a0
    146a:	|  |         addq.l #1,a0
    146c:	|  |  /----- bne.s 14bc <memcpy+0x7a>
    146e:	|  |  |      movea.l d0,a1
    1470:	|  |  |      suba.l a0,a1
    1472:	|  |  |      moveq #2,d3
    1474:	|  |  |      cmp.l a1,d3
    1476:	|  |  +----- bcc.s 14bc <memcpy+0x7a>
    1478:	|  |  |      movea.l d1,a0
    147a:	|  |  |      movea.l d0,a1
    147c:	|  |  |      moveq #-4,d3
    147e:	|  |  |      and.l d2,d3
    1480:	|  |  |      add.l d1,d3
		*d++ = *s++;
    1482:	|  |  |  /-> move.l (a0)+,(a1)+
	while(len--)
    1484:	|  |  |  |   cmp.l a0,d3
    1486:	|  |  |  \-- bne.s 1482 <memcpy+0x40>
    1488:	|  |  |      moveq #-4,d3
    148a:	|  |  |      and.l d2,d3
    148c:	|  |  |      movea.l d0,a0
    148e:	|  |  |      adda.l d3,a0
    1490:	|  |  |      add.l d3,d1
    1492:	|  |  |      sub.l d3,d4
    1494:	|  |  |      moveq #3,d5
    1496:	|  |  |      and.l d5,d2
    1498:	+--|--|----- beq.s 14b2 <memcpy+0x70>
		*d++ = *s++;
    149a:	|  |  |      movea.l d1,a1
    149c:	|  |  |      move.b (a1),(a0)
	while(len--)
    149e:	|  |  |      tst.l d4
    14a0:	+--|--|----- beq.s 14b2 <memcpy+0x70>
		*d++ = *s++;
    14a2:	|  |  |      move.b 1(a1),1(a0)
	while(len--)
    14a8:	|  |  |      subq.l #1,d4
    14aa:	+--|--|----- beq.s 14b2 <memcpy+0x70>
		*d++ = *s++;
    14ac:	|  |  |      move.b 2(a1),2(a0)
}
    14b2:	>--|--|----> movem.l (sp)+,d2-d5
    14b6:	|  |  |      rts
    14b8:	|  \--|----> movea.l d1,a0
    14ba:	|     |      addq.l #1,a0
    14bc:	|     \----> movea.l d0,a1
    14be:	|            add.l d2,d1
		*d++ = *s++;
    14c0:	|        /-> move.b -1(a0),(a1)+
	while(len--)
    14c4:	|        |   cmpa.l d1,a0
    14c6:	\--------|-- beq.s 14b2 <memcpy+0x70>
    14c8:	         |   addq.l #1,a0
    14ca:	         \-- bra.s 14c0 <memcpy+0x7e>

000014cc <memmove>:
void* memmove(void *dest, const void *src, unsigned long len) {
    14cc:	             movem.l d2-d4/a2,-(sp)
    14d0:	             move.l 20(sp),d0
    14d4:	             move.l 24(sp),d1
    14d8:	             move.l 28(sp),d2
		while (len--)
    14dc:	             movea.l d2,a1
    14de:	             subq.l #1,a1
	if (d < s) {
    14e0:	             cmp.l d0,d1
    14e2:	      /----- bls.s 154a <memmove+0x7e>
		while (len--)
    14e4:	      |      tst.l d2
    14e6:	/-----|----- beq.s 1544 <memmove+0x78>
    14e8:	|     |      moveq #6,d3
    14ea:	|     |      movea.l d1,a0
    14ec:	|     |      addq.l #1,a0
    14ee:	|     |      cmp.l a1,d3
    14f0:	|  /--|----- bcc.s 156e <memmove+0xa2>
    14f2:	|  |  |      move.l d0,d3
    14f4:	|  |  |      sub.l a0,d3
    14f6:	|  |  |      moveq #2,d4
    14f8:	|  |  |      cmp.l d3,d4
    14fa:	|  +--|----- bcc.s 156e <memmove+0xa2>
    14fc:	|  |  |      move.l d0,d3
    14fe:	|  |  |      or.l d1,d3
    1500:	|  |  |      moveq #3,d4
    1502:	|  |  |      and.l d4,d3
    1504:	|  +--|----- bne.s 156e <memmove+0xa2>
    1506:	|  |  |      movea.l d1,a0
    1508:	|  |  |      movea.l d0,a2
    150a:	|  |  |      moveq #-4,d3
    150c:	|  |  |      and.l d2,d3
    150e:	|  |  |      add.l d1,d3
			*d++ = *s++;
    1510:	|  |  |  /-> move.l (a0)+,(a2)+
		while (len--)
    1512:	|  |  |  |   cmp.l a0,d3
    1514:	|  |  |  \-- bne.s 1510 <memmove+0x44>
    1516:	|  |  |      moveq #-4,d3
    1518:	|  |  |      and.l d2,d3
    151a:	|  |  |      movea.l d0,a2
    151c:	|  |  |      adda.l d3,a2
    151e:	|  |  |      movea.l d1,a0
    1520:	|  |  |      adda.l d3,a0
    1522:	|  |  |      suba.l d3,a1
    1524:	|  |  |      moveq #3,d1
    1526:	|  |  |      and.l d1,d2
    1528:	+--|--|----- beq.s 1544 <memmove+0x78>
			*d++ = *s++;
    152a:	|  |  |      move.b (a0),(a2)
		while (len--)
    152c:	|  |  |      cmpa.w #0,a1
    1530:	+--|--|----- beq.s 1544 <memmove+0x78>
			*d++ = *s++;
    1532:	|  |  |      move.b 1(a0),1(a2)
		while (len--)
    1538:	|  |  |      moveq #1,d3
    153a:	|  |  |      cmp.l a1,d3
    153c:	+--|--|----- beq.s 1544 <memmove+0x78>
			*d++ = *s++;
    153e:	|  |  |      move.b 2(a0),2(a2)
}
    1544:	>--|--|----> movem.l (sp)+,d2-d4/a2
    1548:	|  |  |      rts
		const char *lasts = s + (len - 1);
    154a:	|  |  \----> lea (0,a1,d1.l),a0
		char *lastd = d + (len - 1);
    154e:	|  |         adda.l d0,a1
		while (len--)
    1550:	|  |         tst.l d2
    1552:	+--|-------- beq.s 1544 <memmove+0x78>
    1554:	|  |         move.l a0,d1
    1556:	|  |         sub.l d2,d1
			*lastd-- = *lasts--;
    1558:	|  |     /-> move.b (a0),(a1)
		while (len--)
    155a:	|  |     |   subq.l #1,a0
    155c:	|  |     |   subq.l #1,a1
    155e:	|  |     |   cmp.l a0,d1
    1560:	+--|-----|-- beq.s 1544 <memmove+0x78>
			*lastd-- = *lasts--;
    1562:	|  |     |   move.b (a0),(a1)
		while (len--)
    1564:	|  |     |   subq.l #1,a0
    1566:	|  |     |   subq.l #1,a1
    1568:	|  |     |   cmp.l a0,d1
    156a:	|  |     \-- bne.s 1558 <memmove+0x8c>
    156c:	+--|-------- bra.s 1544 <memmove+0x78>
    156e:	|  \-------> movea.l d0,a1
    1570:	|            add.l d2,d1
			*d++ = *s++;
    1572:	|        /-> move.b -1(a0),(a1)+
		while (len--)
    1576:	|        |   cmpa.l d1,a0
    1578:	\--------|-- beq.s 1544 <memmove+0x78>
    157a:	         |   addq.l #1,a0
    157c:	         \-- bra.s 1572 <memmove+0xa6>
    157e:	             nop

00001580 <__mulsi3>:
	.text
	.type __mulsi3, function
	.globl	__mulsi3
__mulsi3:
	.cfi_startproc
	movew	sp@(4), d0	/* x0 -> d0 */
    1580:	move.w 4(sp),d0
	muluw	sp@(10), d0	/* x0*y1 */
    1584:	mulu.w 10(sp),d0
	movew	sp@(6), d1	/* x1 -> d1 */
    1588:	move.w 6(sp),d1
	muluw	sp@(8), d1	/* x1*y0 */
    158c:	mulu.w 8(sp),d1
	addw	d1, d0
    1590:	add.w d1,d0
	swap	d0
    1592:	swap d0
	clrw	d0
    1594:	clr.w d0
	movew	sp@(6), d1	/* x1 -> d1 */
    1596:	move.w 6(sp),d1
	muluw	sp@(10), d1	/* x1*y1 */
    159a:	mulu.w 10(sp),d1
	addl	d1, d0
    159e:	add.l d1,d0
	rts
    15a0:	rts

000015a2 <__udivsi3>:
	.text
	.type __udivsi3, function
	.globl	__udivsi3
__udivsi3:
	.cfi_startproc
	movel	d2, sp@-
    15a2:	       move.l d2,-(sp)
	.cfi_adjust_cfa_offset 4
	movel	sp@(12), d1	/* d1 = divisor */
    15a4:	       move.l 12(sp),d1
	movel	sp@(8), d0	/* d0 = dividend */
    15a8:	       move.l 8(sp),d0

	cmpl	#0x10000, d1 /* divisor >= 2 ^ 16 ?   */
    15ac:	       cmpi.l #65536,d1
	jcc	3f		/* then try next algorithm */
    15b2:	   /-- bcc.s 15ca <__udivsi3+0x28>
	movel	d0, d2
    15b4:	   |   move.l d0,d2
	clrw	d2
    15b6:	   |   clr.w d2
	swap	d2
    15b8:	   |   swap d2
	divu	d1, d2          /* high quotient in lower word */
    15ba:	   |   divu.w d1,d2
	movew	d2, d0		/* save high quotient */
    15bc:	   |   move.w d2,d0
	swap	d0
    15be:	   |   swap d0
	movew	sp@(10), d2	/* get low dividend + high rest */
    15c0:	   |   move.w 10(sp),d2
	divu	d1, d2		/* low quotient */
    15c4:	   |   divu.w d1,d2
	movew	d2, d0
    15c6:	   |   move.w d2,d0
	jra	6f
    15c8:	/--|-- bra.s 15fa <__udivsi3+0x58>

3:	movel	d1, d2		/* use d2 as divisor backup */
    15ca:	|  \-> move.l d1,d2
4:	lsrl	#1, d1	/* shift divisor */
    15cc:	|  /-> lsr.l #1,d1
	lsrl	#1, d0	/* shift dividend */
    15ce:	|  |   lsr.l #1,d0
	cmpl	#0x10000, d1 /* still divisor >= 2 ^ 16 ?  */
    15d0:	|  |   cmpi.l #65536,d1
	jcc	4b
    15d6:	|  \-- bcc.s 15cc <__udivsi3+0x2a>
	divu	d1, d0		/* now we have 16-bit divisor */
    15d8:	|      divu.w d1,d0
	andl	#0xffff, d0 /* mask out divisor, ignore remainder */
    15da:	|      andi.l #65535,d0

/* Multiply the 16-bit tentative quotient with the 32-bit divisor.  Because of
   the operand ranges, this might give a 33-bit product.  If this product is
   greater than the dividend, the tentative quotient was too large. */
	movel	d2, d1
    15e0:	|      move.l d2,d1
	mulu	d0, d1		/* low part, 32 bits */
    15e2:	|      mulu.w d0,d1
	swap	d2
    15e4:	|      swap d2
	mulu	d0, d2		/* high part, at most 17 bits */
    15e6:	|      mulu.w d0,d2
	swap	d2		/* align high part with low part */
    15e8:	|      swap d2
	tstw	d2		/* high part 17 bits? */
    15ea:	|      tst.w d2
	jne	5f		/* if 17 bits, quotient was too large */
    15ec:	|  /-- bne.s 15f8 <__udivsi3+0x56>
	addl	d2, d1		/* add parts */
    15ee:	|  |   add.l d2,d1
	jcs	5f		/* if sum is 33 bits, quotient was too large */
    15f0:	|  +-- bcs.s 15f8 <__udivsi3+0x56>
	cmpl	sp@(8), d1	/* compare the sum with the dividend */
    15f2:	|  |   cmp.l 8(sp),d1
	jls	6f		/* if sum > dividend, quotient was too large */
    15f6:	+--|-- bls.s 15fa <__udivsi3+0x58>
5:	subql	#1, d0	/* adjust quotient */
    15f8:	|  \-> subq.l #1,d0

6:	movel	sp@+, d2
    15fa:	\----> move.l (sp)+,d2
	.cfi_adjust_cfa_offset -4
	rts
    15fc:	       rts

000015fe <__divsi3>:
	.text
	.type __divsi3, function
	.globl	__divsi3
 __divsi3:
 	.cfi_startproc
	movel	d2, sp@-
    15fe:	    move.l d2,-(sp)
	.cfi_adjust_cfa_offset 4

	moveq	#1, d2	/* sign of result stored in d2 (=1 or =-1) */
    1600:	    moveq #1,d2
	movel	sp@(12), d1	/* d1 = divisor */
    1602:	    move.l 12(sp),d1
	jpl	1f
    1606:	/-- bpl.s 160c <__divsi3+0xe>
	negl	d1
    1608:	|   neg.l d1
	negb	d2		/* change sign because divisor <0  */
    160a:	|   neg.b d2
1:	movel	sp@(8), d0	/* d0 = dividend */
    160c:	\-> move.l 8(sp),d0
	jpl	2f
    1610:	/-- bpl.s 1616 <__divsi3+0x18>
	negl	d0
    1612:	|   neg.l d0
	negb	d2
    1614:	|   neg.b d2

2:	movel	d1, sp@-
    1616:	\-> move.l d1,-(sp)
	.cfi_adjust_cfa_offset 4
	movel	d0, sp@-
    1618:	    move.l d0,-(sp)
	.cfi_adjust_cfa_offset 4
	jbsr	__udivsi3	/* divide abs(dividend) by abs(divisor) */
    161a:	    bsr.s 15a2 <__udivsi3>
	addql	#8, sp
    161c:	    addq.l #8,sp
	.cfi_adjust_cfa_offset -8

	tstb	d2
    161e:	    tst.b d2
	jpl	3f
    1620:	/-- bpl.s 1624 <__divsi3+0x26>
	negl	d0
    1622:	|   neg.l d0

3:	movel	sp@+, d2
    1624:	\-> move.l (sp)+,d2
	.cfi_adjust_cfa_offset -4
	rts
    1626:	    rts

00001628 <__modsi3>:
	.text
	.type __modsi3, function
	.globl	__modsi3
__modsi3:
	.cfi_startproc
	movel	sp@(8), d1	/* d1 = divisor */
    1628:	move.l 8(sp),d1
	movel	sp@(4), d0	/* d0 = dividend */
    162c:	move.l 4(sp),d0
	movel	d1, sp@-
    1630:	move.l d1,-(sp)
	.cfi_adjust_cfa_offset 4
	movel	d0, sp@-
    1632:	move.l d0,-(sp)
	.cfi_adjust_cfa_offset 4
	jbsr	__divsi3
    1634:	bsr.s 15fe <__divsi3>
	addql	#8, sp
    1636:	addq.l #8,sp
	.cfi_adjust_cfa_offset -8
	movel	sp@(8), d1	/* d1 = divisor */
    1638:	move.l 8(sp),d1
	movel	d1, sp@-
    163c:	move.l d1,-(sp)
	.cfi_adjust_cfa_offset 4
	movel	d0, sp@-
    163e:	move.l d0,-(sp)
	.cfi_adjust_cfa_offset 4
	jbsr	__mulsi3	/* d0 = (a/b)*b */
    1640:	bsr.w 1580 <__mulsi3>
	addql	#8, sp
    1644:	addq.l #8,sp
	.cfi_adjust_cfa_offset -8
	movel	sp@(4), d1	/* d1 = dividend */
    1646:	move.l 4(sp),d1
	subl	d0, d1		/* d1 = a - (a/b)*b */
    164a:	sub.l d0,d1
	movel	d1, d0
    164c:	move.l d1,d0
	rts
    164e:	rts

00001650 <__umodsi3>:
	.text
	.type __umodsi3, function
	.globl	__umodsi3
__umodsi3:
	.cfi_startproc
	movel	sp@(8), d1	/* d1 = divisor */
    1650:	move.l 8(sp),d1
	movel	sp@(4), d0	/* d0 = dividend */
    1654:	move.l 4(sp),d0
	movel	d1, sp@-
    1658:	move.l d1,-(sp)
	.cfi_adjust_cfa_offset 4
	movel	d0, sp@-
    165a:	move.l d0,-(sp)
	.cfi_adjust_cfa_offset 4
	jbsr	__udivsi3
    165c:	bsr.w 15a2 <__udivsi3>
	addql	#8, sp
    1660:	addq.l #8,sp
	.cfi_adjust_cfa_offset -8
	movel	sp@(8), d1	/* d1 = divisor */
    1662:	move.l 8(sp),d1
	movel	d1, sp@-
    1666:	move.l d1,-(sp)
	.cfi_adjust_cfa_offset 4
	movel	d0, sp@-
    1668:	move.l d0,-(sp)
	.cfi_adjust_cfa_offset 4
	jbsr	__mulsi3	/* d0 = (a/b)*b */
    166a:	bsr.w 1580 <__mulsi3>
	addql	#8, sp
    166e:	addq.l #8,sp
	.cfi_adjust_cfa_offset -8
	movel	sp@(4), d1	/* d1 = dividend */
    1670:	move.l 4(sp),d1
	subl	d0, d1		/* d1 = a - (a/b)*b */
    1674:	sub.l d0,d1
	movel	d1, d0
    1676:	move.l d1,d0
	rts
    1678:	rts

0000167a <KPutCharX>:
	.type KPutCharX, function
	.globl	KPutCharX

KPutCharX:
	.cfi_startproc
    move.l  a6, -(sp)
    167a:	move.l a6,-(sp)
	.cfi_adjust_cfa_offset 4
    move.l  4.w, a6
    167c:	movea.l 4 <_start+0x4>,a6
    jsr     -0x204(a6)
    1680:	jsr -516(a6)
    move.l (sp)+, a6
    1684:	movea.l (sp)+,a6
	.cfi_adjust_cfa_offset -4
    rts
    1686:	rts

00001688 <PutChar>:
	.type PutChar, function
	.globl	PutChar

PutChar:
	.cfi_startproc
	move.b d0, (a3)+
    1688:	move.b d0,(a3)+
	rts
    168a:	rts

0000168c <_doynaxdepack_asm>:

	|Entry point. Wind up the decruncher
	.type _doynaxdepack_asm,function
	.globl _doynaxdepack_asm
_doynaxdepack_asm:
	movea.l	(a0)+,a2				|Unaligned literal buffer at the end of
    168c:	                         movea.l (a0)+,a2
	adda.l	a0,a2					|the stream
    168e:	                         adda.l a0,a2
	move.l	a2,a3
    1690:	                         movea.l a2,a3
	move.l	(a0)+,d0				|Seed the shift register
    1692:	                         move.l (a0)+,d0
	moveq	#0x38,d4				|Masks for match offset extraction
    1694:	                         moveq #56,d4
	moveq	#8,d5
    1696:	                         moveq #8,d5
	bra.s	.Lliteral
    1698:	   /-------------------- bra.s 1702 <_doynaxdepack_asm+0x76>

	|******** Copy a literal sequence ********

.Llcopy:							|Copy two bytes at a time, with the
	move.b	(a0)+,(a1)+				|deferral of the length LSB helping
    169a:	/--|-------------------> move.b (a0)+,(a1)+
	move.b	(a0)+,(a1)+				|slightly in the unrolling
    169c:	|  |                     move.b (a0)+,(a1)+
	dbf		d1,.Llcopy
    169e:	+--|-------------------- dbf d1,169a <_doynaxdepack_asm+0xe>

	lsl.l	#2,d0					|Copy odd bytes separately in order
    16a2:	|  |                     lsl.l #2,d0
	bcc.s	.Lmatch					|to keep the source aligned
    16a4:	|  |     /-------------- bcc.s 16a8 <_doynaxdepack_asm+0x1c>
.Llsingle:
	move.b	(a2)+,(a1)+
    16a6:	|  |  /--|-------------> move.b (a2)+,(a1)+

	|******** Process a match ********

	|Start by refilling the bit-buffer
.Lmatch:
	DOY_REFILL1 mprefix
    16a8:	|  |  |  >-------------> tst.w d0
    16aa:	|  |  |  |           /-- bne.s 16b4 <_doynaxdepack_asm+0x28>
	cmp.l	a0,a3					|Take the opportunity to test for the
    16ac:	|  |  |  |           |   cmpa.l a0,a3
	bls.s	.Lreturn				|end of the stream while refilling
    16ae:	|  |  |  |           |   bls.s 1726 <doy_table+0x6>
.Lmrefill:
	DOY_REFILL2
    16b0:	|  |  |  |           |   move.w (a0)+,d0
    16b2:	|  |  |  |           |   swap d0

.Lmprefix:
	|Fetch the first three bits identifying the match length, and look up
	|the corresponding table entry
	rol.l	#3+3,d0
    16b4:	|  |  |  |           \-> rol.l #6,d0
	move.w	d0,d1
    16b6:	|  |  |  |               move.w d0,d1
	and.w	d4,d1
    16b8:	|  |  |  |               and.w d4,d1
	eor.w	d1,d0
    16ba:	|  |  |  |               eor.w d1,d0
	movem.w	doy_table(pc,d1.w),d2/d3/a4
    16bc:	|  |  |  |               movem.w (1720 <doy_table>,pc,d1.w),d2-d3/a4

	|Extract the offset bits and compute the relative source address from it
	rol.l	d2,d0					|Reduced by 3 to account for 8x offset
    16c2:	|  |  |  |               rol.l d2,d0
	and.w	d0,d3					|scaling
    16c4:	|  |  |  |               and.w d0,d3
	eor.w	d3,d0
    16c6:	|  |  |  |               eor.w d3,d0
	suba.w	d3,a4
    16c8:	|  |  |  |               suba.w d3,a4
	adda.l	a1,a4
    16ca:	|  |  |  |               adda.l a1,a4

	|Decode the match length
	DOY_REFILL
    16cc:	|  |  |  |               tst.w d0
    16ce:	|  |  |  |           /-- bne.s 16d4 <_doynaxdepack_asm+0x48>
    16d0:	|  |  |  |           |   move.w (a0)+,d0
    16d2:	|  |  |  |           |   swap d0
	and.w	d5,d1					|Check the initial length bit from the
    16d4:	|  |  |  |           \-> and.w d5,d1
	beq.s	.Lmcopy					|type triple
    16d6:	|  |  |  |  /----------- beq.s 16ee <_doynaxdepack_asm+0x62>

	moveq	#1,d1					|This loops peeks at the next flag
    16d8:	|  |  |  |  |            moveq #1,d1
	tst.l	d0						|through the sign bit bit while keeping
    16da:	|  |  |  |  |            tst.l d0
	bpl.s	.Lmendlen2				|the LSB in carry
    16dc:	|  |  |  |  |  /-------- bpl.s 16ea <_doynaxdepack_asm+0x5e>
	lsl.l	#2,d0
    16de:	|  |  |  |  |  |         lsl.l #2,d0
	bpl.s	.Lmendlen1
    16e0:	|  |  |  |  |  |  /----- bpl.s 16e8 <_doynaxdepack_asm+0x5c>
.Lmgetlen:
	addx.b	d1,d1
    16e2:	|  |  |  |  |  |  |  /-> addx.b d1,d1
	lsl.l	#2,d0
    16e4:	|  |  |  |  |  |  |  |   lsl.l #2,d0
	bmi.s	.Lmgetlen
    16e6:	|  |  |  |  |  |  |  \-- bmi.s 16e2 <_doynaxdepack_asm+0x56>
.Lmendlen1:
	addx.b	d1,d1
    16e8:	|  |  |  |  |  |  \----> addx.b d1,d1
.Lmendlen2:
	|Copy the match data a word at a time. Note that the minimum length is
	|two bytes
	lsl.l	#2,d0					|The trailing length payload bit is
    16ea:	|  |  |  |  |  \-------> lsl.l #2,d0
	bcc.s	.Lmhalf					|stored out-of-order
    16ec:	|  |  |  |  |        /-- bcc.s 16f0 <_doynaxdepack_asm+0x64>
.Lmcopy:
	move.b	(a4)+,(a1)+
    16ee:	|  |  |  |  >--------|-> move.b (a4)+,(a1)+
.Lmhalf:
	move.b	(a4)+,(a1)+
    16f0:	|  |  |  |  |        \-> move.b (a4)+,(a1)+
	dbf		d1,.Lmcopy
    16f2:	|  |  |  |  \----------- dbf d1,16ee <_doynaxdepack_asm+0x62>

	|Fetch a bit flag to see whether what follows is a literal run or
	|another match
	add.l	d0,d0
    16f6:	|  |  |  |               add.l d0,d0
	bcc.s	.Lmatch
    16f8:	|  |  |  \-------------- bcc.s 16a8 <_doynaxdepack_asm+0x1c>


	|******** Process a run of literal bytes ********

	DOY_REFILL						|Replenish the shift-register
    16fa:	|  |  |                  tst.w d0
    16fc:	|  +--|----------------- bne.s 1702 <_doynaxdepack_asm+0x76>
    16fe:	|  |  |                  move.w (a0)+,d0
    1700:	|  |  |                  swap d0
.Lliteral:
	|Extract delta-coded run length in the same swizzled format as the
	|matches above
	moveq	#0,d1
    1702:	|  \--|----------------> moveq #0,d1
	add.l	d0,d0
    1704:	|     |                  add.l d0,d0
	bcc.s	.Llsingle				|Single out the one-byte case
    1706:	|     \----------------- bcc.s 16a6 <_doynaxdepack_asm+0x1a>
	bpl.s	.Llendlen
    1708:	|                 /----- bpl.s 1710 <_doynaxdepack_asm+0x84>
.Llgetlen:
	addx.b	d1,d1
    170a:	|                 |  /-> addx.b d1,d1
	lsl.l	#2,d0
    170c:	|                 |  |   lsl.l #2,d0
	bmi.s	.Llgetlen
    170e:	|                 |  \-- bmi.s 170a <_doynaxdepack_asm+0x7e>
.Llendlen:
	addx.b	d1,d1
    1710:	|                 \----> addx.b d1,d1
	|or greater, in which case the sixteen guaranteed bits in the buffer
	|may have run out.
	|In the latter case simply give up and stuff the payload bits back onto
	|the stream before fetching a literal 16-bit run length instead
.Llcopy_near:
	dbvs	d1,.Llcopy
    1712:	\--------------------/-X dbv.s d1,169a <_doynaxdepack_asm+0xe>

	add.l	d0,d0
    1716:	                     |   add.l d0,d0
	eor.w	d1,d0		
    1718:	                     |   eor.w d1,d0
	ror.l	#7+1,d0					|Note that the constant MSB acts as a
    171a:	                     |   ror.l #8,d0
	move.w	(a0)+,d1				|substitute for the unfetched stop bit
    171c:	                     |   move.w (a0)+,d1
	bra.s	.Llcopy_near
    171e:	                     \-- bra.s 1712 <_doynaxdepack_asm+0x86>

00001720 <doy_table>:
    1720:	......Nu........
doy_table:
	DOY_OFFSET 3,1					|Short A
.Lreturn:
	rts
	DOY_OFFSET 4,1					|Long A
	dc.w	0						|(Empty hole)
    1730:	...?............
	DOY_OFFSET 6,1+8				|Short B
	dc.w	0						|(Empty hole)
	DOY_OFFSET 7,1+16				|Long B
	dc.w	0						|(Empty hole)
    1740:	.............o..
	DOY_OFFSET 8,1+8+64				|Short C
	dc.w	0						|(Empty hole)
	DOY_OFFSET 10,1+16+128			|Long C
	dc.w	0						|(Empty hole)
    1750:	.............o

Disassembly of section CODE:

0000175e <_doynaxdepack_vasm>:
		swap.w	d0						;encoder is in on the scheme
		endm

		;Entry point. Wind up the decruncher
_doynaxdepack_vasm:
		movea.l	(a0)+,a2				;Unaligned literal buffer at the end of
    175e:	movea.l (a0)+,a2
		adda.l	a0,a2					;the stream
    1760:	adda.l a0,a2
		move.l	a2,a3
    1762:	movea.l a2,a3
		move.l	(a0)+,d0				;Seed the shift register
    1764:	move.l (a0)+,d0
		moveq	#@70,d4					;Masks for match offset extraction
    1766:	moveq #56,d4
		moveq	#@10,d5
    1768:	moveq #8,d5
		bra.s	doy_literal
    176a:	bra.s 17d4 <doy_full_000006>

0000176c <doy_lcopy>:


		;******** Copy a literal sequence ********

doy_lcopy:								;Copy two bytes at a time, with the
		move.b	(a0)+,(a1)+				;deferral of the length LSB helping
    176c:	/-> move.b (a0)+,(a1)+
		move.b	(a0)+,(a1)+				;slightly in the unrolling
    176e:	|   move.b (a0)+,(a1)+
		dbf		d1,doy_lcopy
    1770:	\-- dbf d1,176c <doy_lcopy>

		lsl.l	#2,d0					;Copy odd bytes separately in order
    1774:	    lsl.l #2,d0
		bcc.s	doy_match				;to keep the source aligned
    1776:	    bcc.s 177a <doy_match>

00001778 <doy_lsingle>:
doy_lsingle:
		move.b	(a2)+,(a1)+
    1778:	move.b (a2)+,(a1)+

0000177a <doy_match>:
		tst.w	d0
    177a:	tst.w d0
		bne.s	\1
    177c:	bne.s 1786 <doy_mprefix>
		;******** Process a match ********

		;Start by refilling the bit-buffer
doy_match:
		DOY_REFILL1 doy_mprefix
		cmp.l	a0,a3					;Take the opportunity to test for the
    177e:	cmpa.l a0,a3
		bls.s	doy_return				;end of the stream while refilling
    1780:	bls.s 17f8 <doy_return>

00001782 <doy_mrefill>:
		move.w	(a0)+,d0				;old, but that's fine as long as the
    1782:	move.w (a0)+,d0
		swap.w	d0						;encoder is in on the scheme
    1784:	swap d0

00001786 <doy_mprefix>:
		DOY_REFILL2

doy_mprefix:
		;Fetch the first three bits identifying the match length, and look up
		;the corresponding table entry
		rol.l	#3+3,d0
    1786:	rol.l #6,d0
		move.w	d0,d1
    1788:	move.w d0,d1
		and.w	d4,d1
    178a:	and.w d4,d1
		eor.w	d1,d0
    178c:	eor.w d1,d0
		movem.w	doy_table(pc,d1.w),d2/d3/a4
    178e:	movem.w (17f2 <doy_table>,pc,d1.w),d2-d3/a4

		;Extract the offset bits and compute the relative source address from it
		rol.l	d2,d0					;Reduced by 3 to account for 8x offset
    1794:	rol.l d2,d0
		and.w	d0,d3					;scaling
    1796:	and.w d0,d3
		eor.w	d3,d0
    1798:	eor.w d3,d0
		suba.w	d3,a4
    179a:	suba.w d3,a4
		adda.l	a1,a4
    179c:	adda.l a1,a4
		tst.w	d0
    179e:	tst.w d0
		bne.s	\1
    17a0:	bne.s 17a6 <doy_full_000003>
		move.w	(a0)+,d0				;old, but that's fine as long as the
    17a2:	move.w (a0)+,d0
		swap.w	d0						;encoder is in on the scheme
    17a4:	swap d0

000017a6 <doy_full_000003>:

		;Decode the match length
		DOY_REFILL
		and.w	d5,d1					;Check the initial length bit from the
    17a6:	and.w d5,d1
		beq.s	doy_mcopy				;type triple
    17a8:	beq.s 17c0 <doy_mcopy>

		moveq	#1,d1					;This loops peeks at the next flag
    17aa:	moveq #1,d1
		tst.l	d0						;through the sign bit bit while keeping
    17ac:	tst.l d0
		bpl.s	doy_mendlen2			;the LSB in carry
    17ae:	bpl.s 17bc <doy_mendlen2>
		lsl.l	#2,d0
    17b0:	lsl.l #2,d0
		bpl.s	doy_mendlen1
    17b2:	bpl.s 17ba <doy_mendlen1>

000017b4 <doy_mgetlen>:
doy_mgetlen:
		addx.b	d1,d1
    17b4:	/-> addx.b d1,d1
		lsl.l	#2,d0
    17b6:	|   lsl.l #2,d0
		bmi.s	doy_mgetlen
    17b8:	\-- bmi.s 17b4 <doy_mgetlen>

000017ba <doy_mendlen1>:
doy_mendlen1:
		addx.b	d1,d1
    17ba:	addx.b d1,d1

000017bc <doy_mendlen2>:
doy_mendlen2:

		;Copy the match data a word at a time. Note that the minimum length is
		;two bytes
		lsl.l	#2,d0					;The trailing length payload bit is
    17bc:	lsl.l #2,d0
		bcc.s	doy_mhalf				;stored out-of-order
    17be:	bcc.s 17c2 <doy_mhalf>

000017c0 <doy_mcopy>:
doy_mcopy:
		move.b	(a4)+,(a1)+
    17c0:	move.b (a4)+,(a1)+

000017c2 <doy_mhalf>:
doy_mhalf:
		move.b	(a4)+,(a1)+
    17c2:	move.b (a4)+,(a1)+
		dbf		d1,doy_mcopy
    17c4:	dbf d1,17c0 <doy_mcopy>

		;Fetch a bit flag to see whether what follows is a literal run or
		;another match
		add.l	d0,d0
    17c8:	add.l d0,d0
		bcc.s	doy_match
    17ca:	bcc.s 177a <doy_match>
		tst.w	d0
    17cc:	tst.w d0
		bne.s	\1
    17ce:	bne.s 17d4 <doy_full_000006>
		move.w	(a0)+,d0				;old, but that's fine as long as the
    17d0:	move.w (a0)+,d0
		swap.w	d0						;encoder is in on the scheme
    17d2:	swap d0

000017d4 <doy_full_000006>:

		DOY_REFILL						;Replenish the shift-register
doy_literal:
		;Extract delta-coded run length in the same swizzled format as the
		;matches above
		moveq	#0,d1
    17d4:	moveq #0,d1
		add.l	d0,d0
    17d6:	add.l d0,d0
		bcc.s	doy_lsingle				;Single out the one-byte case
    17d8:	bcc.s 1778 <doy_lsingle>
		bpl.s	doy_lendlen
    17da:	bpl.s 17e2 <doy_lendlen>

000017dc <doy_lgetlen>:
doy_lgetlen:
		addx.b	d1,d1
    17dc:	/-> addx.b d1,d1
		lsl.l	#2,d0
    17de:	|   lsl.l #2,d0
		bmi.s	doy_lgetlen
    17e0:	\-- bmi.s 17dc <doy_lgetlen>

000017e2 <doy_lendlen>:
doy_lendlen:
		addx.b	d1,d1
    17e2:	addx.b d1,d1

000017e4 <doy_lcopy_near>:
		;or greater, in which case the sixteen guaranteed bits in the buffer
		;may have run out.
		;In the latter case simply give up and stuff the payload bits back onto
		;the stream before fetching a literal 16-bit run length instead
doy_lcopy_near:
		dbvs	d1,doy_lcopy
    17e4:	/-> dbv.s d1,176c <doy_lcopy>

		add.l	d0,d0
    17e8:	|   add.l d0,d0
		eor.w	d1,d0		
    17ea:	|   eor.w d1,d0
		ror.l	#7+1,d0					;Note that the constant MSB acts as a
    17ec:	|   ror.l #8,d0
		move.w	(a0)+,d1				;substitute for the unfetched stop bit
    17ee:	|   move.w (a0)+,d1
		bra.s	doy_lcopy_near
    17f0:	\-- bra.s 17e4 <doy_lcopy_near>

000017f2 <doy_table>:
    17f2:	ori.b #7,d0
    17f6:	.short 0xffff

000017f8 <doy_return>:
		endm

doy_table:
		DOY_OFFSET 3,1					;Short A
doy_return:
		rts
    17f8:	rts
    17fa:	ori.b #15,d1
    17fe:	.short 0xffff
    1800:	ori.b #3,d0
    1804:	.short 0x003f
    1806:	.short 0xfff7
    1808:	ori.b #4,d0
    180c:	.short 0x007f
    180e:	.short 0xffef
    1810:	ori.b #5,d0
    1814:	.short 0x00ff
    1816:	.short 0xffb7
    1818:	ori.b #7,d0
    181c:	.short 0x03ff
    181e:	.short 0xff6f
    1820:	ori.b #7,d0
    1824:	.short 0x03ff
    1826:	.short 0xfeb7
    1828:	ori.b #10,d0
    182c:	.short 0x1fff
    182e:	.short 0xfb6f
