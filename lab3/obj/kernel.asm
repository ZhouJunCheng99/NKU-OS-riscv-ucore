
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	00a50513          	addi	a0,a0,10 # ffffffffc020a040 <edata>
ffffffffc020003e:	00011617          	auipc	a2,0x11
ffffffffc0200042:	55a60613          	addi	a2,a2,1370 # ffffffffc0211598 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	2ba040ef          	jal	ra,ffffffffc0204308 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	2e658593          	addi	a1,a1,742 # ffffffffc0204338 <etext+0x6>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	2fe50513          	addi	a0,a0,766 # ffffffffc0204358 <etext+0x26>
ffffffffc0200062:	05c000ef          	jal	ra,ffffffffc02000be <cprintf>

    print_kerninfo();
ffffffffc0200066:	0a0000ef          	jal	ra,ffffffffc0200106 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	2ed010ef          	jal	ra,ffffffffc0201b56 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006e:	504000ef          	jal	ra,ffffffffc0200572 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200072:	596030ef          	jal	ra,ffffffffc0203608 <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200076:	426000ef          	jal	ra,ffffffffc020049c <ide_init>
    swap_init();                // init swap
ffffffffc020007a:	7d2020ef          	jal	ra,ffffffffc020284c <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007e:	356000ef          	jal	ra,ffffffffc02003d4 <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc0200082:	a001                	j	ffffffffc0200082 <kern_init+0x4c>

ffffffffc0200084 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200084:	1141                	addi	sp,sp,-16
ffffffffc0200086:	e022                	sd	s0,0(sp)
ffffffffc0200088:	e406                	sd	ra,8(sp)
ffffffffc020008a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020008c:	39e000ef          	jal	ra,ffffffffc020042a <cons_putc>
    (*cnt) ++;
ffffffffc0200090:	401c                	lw	a5,0(s0)
}
ffffffffc0200092:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200094:	2785                	addiw	a5,a5,1
ffffffffc0200096:	c01c                	sw	a5,0(s0)
}
ffffffffc0200098:	6402                	ld	s0,0(sp)
ffffffffc020009a:	0141                	addi	sp,sp,16
ffffffffc020009c:	8082                	ret

ffffffffc020009e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	86ae                	mv	a3,a1
ffffffffc02000a2:	862a                	mv	a2,a0
ffffffffc02000a4:	006c                	addi	a1,sp,12
ffffffffc02000a6:	00000517          	auipc	a0,0x0
ffffffffc02000aa:	fde50513          	addi	a0,a0,-34 # ffffffffc0200084 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ae:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000b0:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	56f030ef          	jal	ra,ffffffffc0203e20 <vprintfmt>
    return cnt;
}
ffffffffc02000b6:	60e2                	ld	ra,24(sp)
ffffffffc02000b8:	4532                	lw	a0,12(sp)
ffffffffc02000ba:	6105                	addi	sp,sp,32
ffffffffc02000bc:	8082                	ret

ffffffffc02000be <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000be:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000c0:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c4:	f42e                	sd	a1,40(sp)
ffffffffc02000c6:	f832                	sd	a2,48(sp)
ffffffffc02000c8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ca:	862a                	mv	a2,a0
ffffffffc02000cc:	004c                	addi	a1,sp,4
ffffffffc02000ce:	00000517          	auipc	a0,0x0
ffffffffc02000d2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200084 <cputch>
ffffffffc02000d6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d8:	ec06                	sd	ra,24(sp)
ffffffffc02000da:	e0ba                	sd	a4,64(sp)
ffffffffc02000dc:	e4be                	sd	a5,72(sp)
ffffffffc02000de:	e8c2                	sd	a6,80(sp)
ffffffffc02000e0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e6:	53b030ef          	jal	ra,ffffffffc0203e20 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000ea:	60e2                	ld	ra,24(sp)
ffffffffc02000ec:	4512                	lw	a0,4(sp)
ffffffffc02000ee:	6125                	addi	sp,sp,96
ffffffffc02000f0:	8082                	ret

ffffffffc02000f2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f2:	3380006f          	j	ffffffffc020042a <cons_putc>

ffffffffc02000f6 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f6:	1141                	addi	sp,sp,-16
ffffffffc02000f8:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000fa:	366000ef          	jal	ra,ffffffffc0200460 <cons_getc>
ffffffffc02000fe:	dd75                	beqz	a0,ffffffffc02000fa <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200100:	60a2                	ld	ra,8(sp)
ffffffffc0200102:	0141                	addi	sp,sp,16
ffffffffc0200104:	8082                	ret

ffffffffc0200106 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200106:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200108:	00004517          	auipc	a0,0x4
ffffffffc020010c:	28850513          	addi	a0,a0,648 # ffffffffc0204390 <etext+0x5e>
void print_kerninfo(void) {
ffffffffc0200110:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200112:	fadff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200116:	00000597          	auipc	a1,0x0
ffffffffc020011a:	f2058593          	addi	a1,a1,-224 # ffffffffc0200036 <kern_init>
ffffffffc020011e:	00004517          	auipc	a0,0x4
ffffffffc0200122:	29250513          	addi	a0,a0,658 # ffffffffc02043b0 <etext+0x7e>
ffffffffc0200126:	f99ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020012a:	00004597          	auipc	a1,0x4
ffffffffc020012e:	20858593          	addi	a1,a1,520 # ffffffffc0204332 <etext>
ffffffffc0200132:	00004517          	auipc	a0,0x4
ffffffffc0200136:	29e50513          	addi	a0,a0,670 # ffffffffc02043d0 <etext+0x9e>
ffffffffc020013a:	f85ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020013e:	0000a597          	auipc	a1,0xa
ffffffffc0200142:	f0258593          	addi	a1,a1,-254 # ffffffffc020a040 <edata>
ffffffffc0200146:	00004517          	auipc	a0,0x4
ffffffffc020014a:	2aa50513          	addi	a0,a0,682 # ffffffffc02043f0 <etext+0xbe>
ffffffffc020014e:	f71ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200152:	00011597          	auipc	a1,0x11
ffffffffc0200156:	44658593          	addi	a1,a1,1094 # ffffffffc0211598 <end>
ffffffffc020015a:	00004517          	auipc	a0,0x4
ffffffffc020015e:	2b650513          	addi	a0,a0,694 # ffffffffc0204410 <etext+0xde>
ffffffffc0200162:	f5dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200166:	00012597          	auipc	a1,0x12
ffffffffc020016a:	83158593          	addi	a1,a1,-1999 # ffffffffc0211997 <end+0x3ff>
ffffffffc020016e:	00000797          	auipc	a5,0x0
ffffffffc0200172:	ec878793          	addi	a5,a5,-312 # ffffffffc0200036 <kern_init>
ffffffffc0200176:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020017a:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020017e:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200180:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200184:	95be                	add	a1,a1,a5
ffffffffc0200186:	85a9                	srai	a1,a1,0xa
ffffffffc0200188:	00004517          	auipc	a0,0x4
ffffffffc020018c:	2a850513          	addi	a0,a0,680 # ffffffffc0204430 <etext+0xfe>
}
ffffffffc0200190:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200192:	f2dff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200196 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200196:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200198:	00004617          	auipc	a2,0x4
ffffffffc020019c:	1c860613          	addi	a2,a2,456 # ffffffffc0204360 <etext+0x2e>
ffffffffc02001a0:	04e00593          	li	a1,78
ffffffffc02001a4:	00004517          	auipc	a0,0x4
ffffffffc02001a8:	1d450513          	addi	a0,a0,468 # ffffffffc0204378 <etext+0x46>
void print_stackframe(void) {
ffffffffc02001ac:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001ae:	1c6000ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02001b2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001b2:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001b4:	00004617          	auipc	a2,0x4
ffffffffc02001b8:	38460613          	addi	a2,a2,900 # ffffffffc0204538 <commands+0xd8>
ffffffffc02001bc:	00004597          	auipc	a1,0x4
ffffffffc02001c0:	39c58593          	addi	a1,a1,924 # ffffffffc0204558 <commands+0xf8>
ffffffffc02001c4:	00004517          	auipc	a0,0x4
ffffffffc02001c8:	39c50513          	addi	a0,a0,924 # ffffffffc0204560 <commands+0x100>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001cc:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ce:	ef1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001d2:	00004617          	auipc	a2,0x4
ffffffffc02001d6:	39e60613          	addi	a2,a2,926 # ffffffffc0204570 <commands+0x110>
ffffffffc02001da:	00004597          	auipc	a1,0x4
ffffffffc02001de:	3be58593          	addi	a1,a1,958 # ffffffffc0204598 <commands+0x138>
ffffffffc02001e2:	00004517          	auipc	a0,0x4
ffffffffc02001e6:	37e50513          	addi	a0,a0,894 # ffffffffc0204560 <commands+0x100>
ffffffffc02001ea:	ed5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001ee:	00004617          	auipc	a2,0x4
ffffffffc02001f2:	3ba60613          	addi	a2,a2,954 # ffffffffc02045a8 <commands+0x148>
ffffffffc02001f6:	00004597          	auipc	a1,0x4
ffffffffc02001fa:	3d258593          	addi	a1,a1,978 # ffffffffc02045c8 <commands+0x168>
ffffffffc02001fe:	00004517          	auipc	a0,0x4
ffffffffc0200202:	36250513          	addi	a0,a0,866 # ffffffffc0204560 <commands+0x100>
ffffffffc0200206:	eb9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    }
    return 0;
}
ffffffffc020020a:	60a2                	ld	ra,8(sp)
ffffffffc020020c:	4501                	li	a0,0
ffffffffc020020e:	0141                	addi	sp,sp,16
ffffffffc0200210:	8082                	ret

ffffffffc0200212 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200212:	1141                	addi	sp,sp,-16
ffffffffc0200214:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200216:	ef1ff0ef          	jal	ra,ffffffffc0200106 <print_kerninfo>
    return 0;
}
ffffffffc020021a:	60a2                	ld	ra,8(sp)
ffffffffc020021c:	4501                	li	a0,0
ffffffffc020021e:	0141                	addi	sp,sp,16
ffffffffc0200220:	8082                	ret

ffffffffc0200222 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200222:	1141                	addi	sp,sp,-16
ffffffffc0200224:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200226:	f71ff0ef          	jal	ra,ffffffffc0200196 <print_stackframe>
    return 0;
}
ffffffffc020022a:	60a2                	ld	ra,8(sp)
ffffffffc020022c:	4501                	li	a0,0
ffffffffc020022e:	0141                	addi	sp,sp,16
ffffffffc0200230:	8082                	ret

ffffffffc0200232 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200232:	7115                	addi	sp,sp,-224
ffffffffc0200234:	e962                	sd	s8,144(sp)
ffffffffc0200236:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200238:	00004517          	auipc	a0,0x4
ffffffffc020023c:	27050513          	addi	a0,a0,624 # ffffffffc02044a8 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200240:	ed86                	sd	ra,216(sp)
ffffffffc0200242:	e9a2                	sd	s0,208(sp)
ffffffffc0200244:	e5a6                	sd	s1,200(sp)
ffffffffc0200246:	e1ca                	sd	s2,192(sp)
ffffffffc0200248:	fd4e                	sd	s3,184(sp)
ffffffffc020024a:	f952                	sd	s4,176(sp)
ffffffffc020024c:	f556                	sd	s5,168(sp)
ffffffffc020024e:	f15a                	sd	s6,160(sp)
ffffffffc0200250:	ed5e                	sd	s7,152(sp)
ffffffffc0200252:	e566                	sd	s9,136(sp)
ffffffffc0200254:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200256:	e69ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020025a:	00004517          	auipc	a0,0x4
ffffffffc020025e:	27650513          	addi	a0,a0,630 # ffffffffc02044d0 <commands+0x70>
ffffffffc0200262:	e5dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    if (tf != NULL) {
ffffffffc0200266:	000c0563          	beqz	s8,ffffffffc0200270 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020026a:	8562                	mv	a0,s8
ffffffffc020026c:	4f2000ef          	jal	ra,ffffffffc020075e <print_trapframe>
ffffffffc0200270:	00004c97          	auipc	s9,0x4
ffffffffc0200274:	1f0c8c93          	addi	s9,s9,496 # ffffffffc0204460 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200278:	00005997          	auipc	s3,0x5
ffffffffc020027c:	7e098993          	addi	s3,s3,2016 # ffffffffc0205a58 <default_pmm_manager+0x990>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200280:	00004917          	auipc	s2,0x4
ffffffffc0200284:	27890913          	addi	s2,s2,632 # ffffffffc02044f8 <commands+0x98>
        if (argc == MAXARGS - 1) {
ffffffffc0200288:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020028a:	00004b17          	auipc	s6,0x4
ffffffffc020028e:	276b0b13          	addi	s6,s6,630 # ffffffffc0204500 <commands+0xa0>
    if (argc == 0) {
ffffffffc0200292:	00004a97          	auipc	s5,0x4
ffffffffc0200296:	2c6a8a93          	addi	s5,s5,710 # ffffffffc0204558 <commands+0xf8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020029a:	4b8d                	li	s7,3
        if ((buf = readline("")) != NULL) {
ffffffffc020029c:	854e                	mv	a0,s3
ffffffffc020029e:	70f030ef          	jal	ra,ffffffffc02041ac <readline>
ffffffffc02002a2:	842a                	mv	s0,a0
ffffffffc02002a4:	dd65                	beqz	a0,ffffffffc020029c <kmonitor+0x6a>
ffffffffc02002a6:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002aa:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002ac:	c999                	beqz	a1,ffffffffc02002c2 <kmonitor+0x90>
ffffffffc02002ae:	854a                	mv	a0,s2
ffffffffc02002b0:	03a040ef          	jal	ra,ffffffffc02042ea <strchr>
ffffffffc02002b4:	c925                	beqz	a0,ffffffffc0200324 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002b6:	00144583          	lbu	a1,1(s0)
ffffffffc02002ba:	00040023          	sb	zero,0(s0)
ffffffffc02002be:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002c0:	f5fd                	bnez	a1,ffffffffc02002ae <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002c2:	dce9                	beqz	s1,ffffffffc020029c <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002c4:	6582                	ld	a1,0(sp)
ffffffffc02002c6:	00004d17          	auipc	s10,0x4
ffffffffc02002ca:	19ad0d13          	addi	s10,s10,410 # ffffffffc0204460 <commands>
    if (argc == 0) {
ffffffffc02002ce:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d0:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002d2:	0d61                	addi	s10,s10,24
ffffffffc02002d4:	7ed030ef          	jal	ra,ffffffffc02042c0 <strcmp>
ffffffffc02002d8:	c919                	beqz	a0,ffffffffc02002ee <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002da:	2405                	addiw	s0,s0,1
ffffffffc02002dc:	09740463          	beq	s0,s7,ffffffffc0200364 <kmonitor+0x132>
ffffffffc02002e0:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	0d61                	addi	s10,s10,24
ffffffffc02002e8:	7d9030ef          	jal	ra,ffffffffc02042c0 <strcmp>
ffffffffc02002ec:	f57d                	bnez	a0,ffffffffc02002da <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02002ee:	00141793          	slli	a5,s0,0x1
ffffffffc02002f2:	97a2                	add	a5,a5,s0
ffffffffc02002f4:	078e                	slli	a5,a5,0x3
ffffffffc02002f6:	97e6                	add	a5,a5,s9
ffffffffc02002f8:	6b9c                	ld	a5,16(a5)
ffffffffc02002fa:	8662                	mv	a2,s8
ffffffffc02002fc:	002c                	addi	a1,sp,8
ffffffffc02002fe:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200302:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200304:	f8055ce3          	bgez	a0,ffffffffc020029c <kmonitor+0x6a>
}
ffffffffc0200308:	60ee                	ld	ra,216(sp)
ffffffffc020030a:	644e                	ld	s0,208(sp)
ffffffffc020030c:	64ae                	ld	s1,200(sp)
ffffffffc020030e:	690e                	ld	s2,192(sp)
ffffffffc0200310:	79ea                	ld	s3,184(sp)
ffffffffc0200312:	7a4a                	ld	s4,176(sp)
ffffffffc0200314:	7aaa                	ld	s5,168(sp)
ffffffffc0200316:	7b0a                	ld	s6,160(sp)
ffffffffc0200318:	6bea                	ld	s7,152(sp)
ffffffffc020031a:	6c4a                	ld	s8,144(sp)
ffffffffc020031c:	6caa                	ld	s9,136(sp)
ffffffffc020031e:	6d0a                	ld	s10,128(sp)
ffffffffc0200320:	612d                	addi	sp,sp,224
ffffffffc0200322:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200324:	00044783          	lbu	a5,0(s0)
ffffffffc0200328:	dfc9                	beqz	a5,ffffffffc02002c2 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020032a:	03448863          	beq	s1,s4,ffffffffc020035a <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020032e:	00349793          	slli	a5,s1,0x3
ffffffffc0200332:	0118                	addi	a4,sp,128
ffffffffc0200334:	97ba                	add	a5,a5,a4
ffffffffc0200336:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020033a:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020033e:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200340:	e591                	bnez	a1,ffffffffc020034c <kmonitor+0x11a>
ffffffffc0200342:	b749                	j	ffffffffc02002c4 <kmonitor+0x92>
            buf ++;
ffffffffc0200344:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200346:	00044583          	lbu	a1,0(s0)
ffffffffc020034a:	ddad                	beqz	a1,ffffffffc02002c4 <kmonitor+0x92>
ffffffffc020034c:	854a                	mv	a0,s2
ffffffffc020034e:	79d030ef          	jal	ra,ffffffffc02042ea <strchr>
ffffffffc0200352:	d96d                	beqz	a0,ffffffffc0200344 <kmonitor+0x112>
ffffffffc0200354:	00044583          	lbu	a1,0(s0)
ffffffffc0200358:	bf91                	j	ffffffffc02002ac <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020035a:	45c1                	li	a1,16
ffffffffc020035c:	855a                	mv	a0,s6
ffffffffc020035e:	d61ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0200362:	b7f1                	j	ffffffffc020032e <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200364:	6582                	ld	a1,0(sp)
ffffffffc0200366:	00004517          	auipc	a0,0x4
ffffffffc020036a:	1ba50513          	addi	a0,a0,442 # ffffffffc0204520 <commands+0xc0>
ffffffffc020036e:	d51ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    return 0;
ffffffffc0200372:	b72d                	j	ffffffffc020029c <kmonitor+0x6a>

ffffffffc0200374 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200374:	00011317          	auipc	t1,0x11
ffffffffc0200378:	0cc30313          	addi	t1,t1,204 # ffffffffc0211440 <is_panic>
ffffffffc020037c:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200380:	715d                	addi	sp,sp,-80
ffffffffc0200382:	ec06                	sd	ra,24(sp)
ffffffffc0200384:	e822                	sd	s0,16(sp)
ffffffffc0200386:	f436                	sd	a3,40(sp)
ffffffffc0200388:	f83a                	sd	a4,48(sp)
ffffffffc020038a:	fc3e                	sd	a5,56(sp)
ffffffffc020038c:	e0c2                	sd	a6,64(sp)
ffffffffc020038e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200390:	02031c63          	bnez	t1,ffffffffc02003c8 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200394:	4785                	li	a5,1
ffffffffc0200396:	8432                	mv	s0,a2
ffffffffc0200398:	00011717          	auipc	a4,0x11
ffffffffc020039c:	0af72423          	sw	a5,168(a4) # ffffffffc0211440 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003a0:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003a2:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003a4:	85aa                	mv	a1,a0
ffffffffc02003a6:	00004517          	auipc	a0,0x4
ffffffffc02003aa:	23250513          	addi	a0,a0,562 # ffffffffc02045d8 <commands+0x178>
    va_start(ap, fmt);
ffffffffc02003ae:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003b0:	d0fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003b4:	65a2                	ld	a1,8(sp)
ffffffffc02003b6:	8522                	mv	a0,s0
ffffffffc02003b8:	ce7ff0ef          	jal	ra,ffffffffc020009e <vcprintf>
    cprintf("\n");
ffffffffc02003bc:	00005517          	auipc	a0,0x5
ffffffffc02003c0:	1f450513          	addi	a0,a0,500 # ffffffffc02055b0 <default_pmm_manager+0x4e8>
ffffffffc02003c4:	cfbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003c8:	132000ef          	jal	ra,ffffffffc02004fa <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003cc:	4501                	li	a0,0
ffffffffc02003ce:	e65ff0ef          	jal	ra,ffffffffc0200232 <kmonitor>
ffffffffc02003d2:	bfed                	j	ffffffffc02003cc <__panic+0x58>

ffffffffc02003d4 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02003d4:	67e1                	lui	a5,0x18
ffffffffc02003d6:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc02003da:	00011717          	auipc	a4,0x11
ffffffffc02003de:	06f73723          	sd	a5,110(a4) # ffffffffc0211448 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003e2:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02003e6:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003e8:	953e                	add	a0,a0,a5
ffffffffc02003ea:	4601                	li	a2,0
ffffffffc02003ec:	4881                	li	a7,0
ffffffffc02003ee:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02003f2:	02000793          	li	a5,32
ffffffffc02003f6:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02003fa:	00004517          	auipc	a0,0x4
ffffffffc02003fe:	1fe50513          	addi	a0,a0,510 # ffffffffc02045f8 <commands+0x198>
    ticks = 0;
ffffffffc0200402:	00011797          	auipc	a5,0x11
ffffffffc0200406:	0607b723          	sd	zero,110(a5) # ffffffffc0211470 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020040a:	cb5ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020040e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020040e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200412:	00011797          	auipc	a5,0x11
ffffffffc0200416:	03678793          	addi	a5,a5,54 # ffffffffc0211448 <timebase>
ffffffffc020041a:	639c                	ld	a5,0(a5)
ffffffffc020041c:	4581                	li	a1,0
ffffffffc020041e:	4601                	li	a2,0
ffffffffc0200420:	953e                	add	a0,a0,a5
ffffffffc0200422:	4881                	li	a7,0
ffffffffc0200424:	00000073          	ecall
ffffffffc0200428:	8082                	ret

ffffffffc020042a <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020042a:	100027f3          	csrr	a5,sstatus
ffffffffc020042e:	8b89                	andi	a5,a5,2
ffffffffc0200430:	0ff57513          	andi	a0,a0,255
ffffffffc0200434:	e799                	bnez	a5,ffffffffc0200442 <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200436:	4581                	li	a1,0
ffffffffc0200438:	4601                	li	a2,0
ffffffffc020043a:	4885                	li	a7,1
ffffffffc020043c:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200440:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200442:	1101                	addi	sp,sp,-32
ffffffffc0200444:	ec06                	sd	ra,24(sp)
ffffffffc0200446:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200448:	0b2000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc020044c:	6522                	ld	a0,8(sp)
ffffffffc020044e:	4581                	li	a1,0
ffffffffc0200450:	4601                	li	a2,0
ffffffffc0200452:	4885                	li	a7,1
ffffffffc0200454:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200458:	60e2                	ld	ra,24(sp)
ffffffffc020045a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020045c:	0980006f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc0200460 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200460:	100027f3          	csrr	a5,sstatus
ffffffffc0200464:	8b89                	andi	a5,a5,2
ffffffffc0200466:	eb89                	bnez	a5,ffffffffc0200478 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200468:	4501                	li	a0,0
ffffffffc020046a:	4581                	li	a1,0
ffffffffc020046c:	4601                	li	a2,0
ffffffffc020046e:	4889                	li	a7,2
ffffffffc0200470:	00000073          	ecall
ffffffffc0200474:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200476:	8082                	ret
int cons_getc(void) {
ffffffffc0200478:	1101                	addi	sp,sp,-32
ffffffffc020047a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020047c:	07e000ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc0200480:	4501                	li	a0,0
ffffffffc0200482:	4581                	li	a1,0
ffffffffc0200484:	4601                	li	a2,0
ffffffffc0200486:	4889                	li	a7,2
ffffffffc0200488:	00000073          	ecall
ffffffffc020048c:	2501                	sext.w	a0,a0
ffffffffc020048e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200490:	064000ef          	jal	ra,ffffffffc02004f4 <intr_enable>
}
ffffffffc0200494:	60e2                	ld	ra,24(sp)
ffffffffc0200496:	6522                	ld	a0,8(sp)
ffffffffc0200498:	6105                	addi	sp,sp,32
ffffffffc020049a:	8082                	ret

ffffffffc020049c <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc020049c:	8082                	ret

ffffffffc020049e <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc020049e:	00253513          	sltiu	a0,a0,2
ffffffffc02004a2:	8082                	ret

ffffffffc02004a4 <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02004a4:	03800513          	li	a0,56
ffffffffc02004a8:	8082                	ret

ffffffffc02004aa <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004aa:	0000a797          	auipc	a5,0xa
ffffffffc02004ae:	b9678793          	addi	a5,a5,-1130 # ffffffffc020a040 <edata>
ffffffffc02004b2:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004b6:	1141                	addi	sp,sp,-16
ffffffffc02004b8:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004ba:	95be                	add	a1,a1,a5
ffffffffc02004bc:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004c0:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004c2:	659030ef          	jal	ra,ffffffffc020431a <memcpy>
    return 0;
}
ffffffffc02004c6:	60a2                	ld	ra,8(sp)
ffffffffc02004c8:	4501                	li	a0,0
ffffffffc02004ca:	0141                	addi	sp,sp,16
ffffffffc02004cc:	8082                	ret

ffffffffc02004ce <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02004ce:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d0:	0095979b          	slliw	a5,a1,0x9
ffffffffc02004d4:	0000a517          	auipc	a0,0xa
ffffffffc02004d8:	b6c50513          	addi	a0,a0,-1172 # ffffffffc020a040 <edata>
                   size_t nsecs) {
ffffffffc02004dc:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004de:	00969613          	slli	a2,a3,0x9
ffffffffc02004e2:	85ba                	mv	a1,a4
ffffffffc02004e4:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02004e6:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004e8:	633030ef          	jal	ra,ffffffffc020431a <memcpy>
    return 0;
}
ffffffffc02004ec:	60a2                	ld	ra,8(sp)
ffffffffc02004ee:	4501                	li	a0,0
ffffffffc02004f0:	0141                	addi	sp,sp,16
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004f4:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004f8:	8082                	ret

ffffffffc02004fa <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004fa:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004fe:	8082                	ret

ffffffffc0200500 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200500:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200504:	1141                	addi	sp,sp,-16
ffffffffc0200506:	e022                	sd	s0,0(sp)
ffffffffc0200508:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc020050a:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc020050e:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200510:	11053583          	ld	a1,272(a0)
ffffffffc0200514:	05500613          	li	a2,85
ffffffffc0200518:	c399                	beqz	a5,ffffffffc020051e <pgfault_handler+0x1e>
ffffffffc020051a:	04b00613          	li	a2,75
ffffffffc020051e:	11843703          	ld	a4,280(s0)
ffffffffc0200522:	47bd                	li	a5,15
ffffffffc0200524:	05700693          	li	a3,87
ffffffffc0200528:	00f70463          	beq	a4,a5,ffffffffc0200530 <pgfault_handler+0x30>
ffffffffc020052c:	05200693          	li	a3,82
ffffffffc0200530:	00004517          	auipc	a0,0x4
ffffffffc0200534:	42050513          	addi	a0,a0,1056 # ffffffffc0204950 <commands+0x4f0>
ffffffffc0200538:	b87ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc020053c:	00011797          	auipc	a5,0x11
ffffffffc0200540:	05478793          	addi	a5,a5,84 # ffffffffc0211590 <check_mm_struct>
ffffffffc0200544:	6388                	ld	a0,0(a5)
ffffffffc0200546:	c911                	beqz	a0,ffffffffc020055a <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	11043603          	ld	a2,272(s0)
ffffffffc020054c:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200550:	6402                	ld	s0,0(sp)
ffffffffc0200552:	60a2                	ld	ra,8(sp)
ffffffffc0200554:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200556:	5f00306f          	j	ffffffffc0203b46 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020055a:	00004617          	auipc	a2,0x4
ffffffffc020055e:	41660613          	addi	a2,a2,1046 # ffffffffc0204970 <commands+0x510>
ffffffffc0200562:	07800593          	li	a1,120
ffffffffc0200566:	00004517          	auipc	a0,0x4
ffffffffc020056a:	42250513          	addi	a0,a0,1058 # ffffffffc0204988 <commands+0x528>
ffffffffc020056e:	e07ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200572 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200572:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200576:	00000797          	auipc	a5,0x0
ffffffffc020057a:	4da78793          	addi	a5,a5,1242 # ffffffffc0200a50 <__alltraps>
ffffffffc020057e:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200582:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200586:	000407b7          	lui	a5,0x40
ffffffffc020058a:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020058e:	8082                	ret

ffffffffc0200590 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200590:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	1141                	addi	sp,sp,-16
ffffffffc0200594:	e022                	sd	s0,0(sp)
ffffffffc0200596:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200598:	00004517          	auipc	a0,0x4
ffffffffc020059c:	40850513          	addi	a0,a0,1032 # ffffffffc02049a0 <commands+0x540>
void print_regs(struct pushregs *gpr) {
ffffffffc02005a0:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02005a2:	b1dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02005a6:	640c                	ld	a1,8(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	41050513          	addi	a0,a0,1040 # ffffffffc02049b8 <commands+0x558>
ffffffffc02005b0:	b0fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005b4:	680c                	ld	a1,16(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	41a50513          	addi	a0,a0,1050 # ffffffffc02049d0 <commands+0x570>
ffffffffc02005be:	b01ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005c2:	6c0c                	ld	a1,24(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	42450513          	addi	a0,a0,1060 # ffffffffc02049e8 <commands+0x588>
ffffffffc02005cc:	af3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005d0:	700c                	ld	a1,32(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	42e50513          	addi	a0,a0,1070 # ffffffffc0204a00 <commands+0x5a0>
ffffffffc02005da:	ae5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005de:	740c                	ld	a1,40(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	43850513          	addi	a0,a0,1080 # ffffffffc0204a18 <commands+0x5b8>
ffffffffc02005e8:	ad7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005ec:	780c                	ld	a1,48(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	44250513          	addi	a0,a0,1090 # ffffffffc0204a30 <commands+0x5d0>
ffffffffc02005f6:	ac9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005fa:	7c0c                	ld	a1,56(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	44c50513          	addi	a0,a0,1100 # ffffffffc0204a48 <commands+0x5e8>
ffffffffc0200604:	abbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200608:	602c                	ld	a1,64(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	45650513          	addi	a0,a0,1110 # ffffffffc0204a60 <commands+0x600>
ffffffffc0200612:	aadff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200616:	642c                	ld	a1,72(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	46050513          	addi	a0,a0,1120 # ffffffffc0204a78 <commands+0x618>
ffffffffc0200620:	a9fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200624:	682c                	ld	a1,80(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	46a50513          	addi	a0,a0,1130 # ffffffffc0204a90 <commands+0x630>
ffffffffc020062e:	a91ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200632:	6c2c                	ld	a1,88(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	47450513          	addi	a0,a0,1140 # ffffffffc0204aa8 <commands+0x648>
ffffffffc020063c:	a83ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200640:	702c                	ld	a1,96(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	47e50513          	addi	a0,a0,1150 # ffffffffc0204ac0 <commands+0x660>
ffffffffc020064a:	a75ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020064e:	742c                	ld	a1,104(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	48850513          	addi	a0,a0,1160 # ffffffffc0204ad8 <commands+0x678>
ffffffffc0200658:	a67ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020065c:	782c                	ld	a1,112(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	49250513          	addi	a0,a0,1170 # ffffffffc0204af0 <commands+0x690>
ffffffffc0200666:	a59ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020066a:	7c2c                	ld	a1,120(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	49c50513          	addi	a0,a0,1180 # ffffffffc0204b08 <commands+0x6a8>
ffffffffc0200674:	a4bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200678:	604c                	ld	a1,128(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	4a650513          	addi	a0,a0,1190 # ffffffffc0204b20 <commands+0x6c0>
ffffffffc0200682:	a3dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200686:	644c                	ld	a1,136(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	4b050513          	addi	a0,a0,1200 # ffffffffc0204b38 <commands+0x6d8>
ffffffffc0200690:	a2fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200694:	684c                	ld	a1,144(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	4ba50513          	addi	a0,a0,1210 # ffffffffc0204b50 <commands+0x6f0>
ffffffffc020069e:	a21ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc02006a2:	6c4c                	ld	a1,152(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	4c450513          	addi	a0,a0,1220 # ffffffffc0204b68 <commands+0x708>
ffffffffc02006ac:	a13ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006b0:	704c                	ld	a1,160(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	4ce50513          	addi	a0,a0,1230 # ffffffffc0204b80 <commands+0x720>
ffffffffc02006ba:	a05ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006be:	744c                	ld	a1,168(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	4d850513          	addi	a0,a0,1240 # ffffffffc0204b98 <commands+0x738>
ffffffffc02006c8:	9f7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006cc:	784c                	ld	a1,176(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	4e250513          	addi	a0,a0,1250 # ffffffffc0204bb0 <commands+0x750>
ffffffffc02006d6:	9e9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006da:	7c4c                	ld	a1,184(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	4ec50513          	addi	a0,a0,1260 # ffffffffc0204bc8 <commands+0x768>
ffffffffc02006e4:	9dbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006e8:	606c                	ld	a1,192(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	4f650513          	addi	a0,a0,1270 # ffffffffc0204be0 <commands+0x780>
ffffffffc02006f2:	9cdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006f6:	646c                	ld	a1,200(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	50050513          	addi	a0,a0,1280 # ffffffffc0204bf8 <commands+0x798>
ffffffffc0200700:	9bfff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200704:	686c                	ld	a1,208(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	50a50513          	addi	a0,a0,1290 # ffffffffc0204c10 <commands+0x7b0>
ffffffffc020070e:	9b1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200712:	6c6c                	ld	a1,216(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	51450513          	addi	a0,a0,1300 # ffffffffc0204c28 <commands+0x7c8>
ffffffffc020071c:	9a3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200720:	706c                	ld	a1,224(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	51e50513          	addi	a0,a0,1310 # ffffffffc0204c40 <commands+0x7e0>
ffffffffc020072a:	995ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020072e:	746c                	ld	a1,232(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	52850513          	addi	a0,a0,1320 # ffffffffc0204c58 <commands+0x7f8>
ffffffffc0200738:	987ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020073c:	786c                	ld	a1,240(s0)
ffffffffc020073e:	00004517          	auipc	a0,0x4
ffffffffc0200742:	53250513          	addi	a0,a0,1330 # ffffffffc0204c70 <commands+0x810>
ffffffffc0200746:	979ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074a:	7c6c                	ld	a1,248(s0)
}
ffffffffc020074c:	6402                	ld	s0,0(sp)
ffffffffc020074e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200750:	00004517          	auipc	a0,0x4
ffffffffc0200754:	53850513          	addi	a0,a0,1336 # ffffffffc0204c88 <commands+0x828>
}
ffffffffc0200758:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020075a:	965ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc020075e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	1141                	addi	sp,sp,-16
ffffffffc0200760:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200762:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200764:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200766:	00004517          	auipc	a0,0x4
ffffffffc020076a:	53a50513          	addi	a0,a0,1338 # ffffffffc0204ca0 <commands+0x840>
void print_trapframe(struct trapframe *tf) {
ffffffffc020076e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200770:	94fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200774:	8522                	mv	a0,s0
ffffffffc0200776:	e1bff0ef          	jal	ra,ffffffffc0200590 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020077a:	10043583          	ld	a1,256(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	53a50513          	addi	a0,a0,1338 # ffffffffc0204cb8 <commands+0x858>
ffffffffc0200786:	939ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020078a:	10843583          	ld	a1,264(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	54250513          	addi	a0,a0,1346 # ffffffffc0204cd0 <commands+0x870>
ffffffffc0200796:	929ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020079a:	11043583          	ld	a1,272(s0)
ffffffffc020079e:	00004517          	auipc	a0,0x4
ffffffffc02007a2:	54a50513          	addi	a0,a0,1354 # ffffffffc0204ce8 <commands+0x888>
ffffffffc02007a6:	919ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007aa:	11843583          	ld	a1,280(s0)
}
ffffffffc02007ae:	6402                	ld	s0,0(sp)
ffffffffc02007b0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007b2:	00004517          	auipc	a0,0x4
ffffffffc02007b6:	54e50513          	addi	a0,a0,1358 # ffffffffc0204d00 <commands+0x8a0>
}
ffffffffc02007ba:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007bc:	903ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02007c0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007c0:	11853783          	ld	a5,280(a0)
ffffffffc02007c4:	577d                	li	a4,-1
ffffffffc02007c6:	8305                	srli	a4,a4,0x1
ffffffffc02007c8:	8ff9                	and	a5,a5,a4
    switch (cause) {
ffffffffc02007ca:	472d                	li	a4,11
ffffffffc02007cc:	06f76f63          	bltu	a4,a5,ffffffffc020084a <interrupt_handler+0x8a>
ffffffffc02007d0:	00004717          	auipc	a4,0x4
ffffffffc02007d4:	e4470713          	addi	a4,a4,-444 # ffffffffc0204614 <commands+0x1b4>
ffffffffc02007d8:	078a                	slli	a5,a5,0x2
ffffffffc02007da:	97ba                	add	a5,a5,a4
ffffffffc02007dc:	439c                	lw	a5,0(a5)
ffffffffc02007de:	97ba                	add	a5,a5,a4
ffffffffc02007e0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007e2:	00004517          	auipc	a0,0x4
ffffffffc02007e6:	11e50513          	addi	a0,a0,286 # ffffffffc0204900 <commands+0x4a0>
ffffffffc02007ea:	8d5ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007ee:	00004517          	auipc	a0,0x4
ffffffffc02007f2:	0f250513          	addi	a0,a0,242 # ffffffffc02048e0 <commands+0x480>
ffffffffc02007f6:	8c9ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007fa:	00004517          	auipc	a0,0x4
ffffffffc02007fe:	0a650513          	addi	a0,a0,166 # ffffffffc02048a0 <commands+0x440>
ffffffffc0200802:	8bdff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200806:	00004517          	auipc	a0,0x4
ffffffffc020080a:	0ba50513          	addi	a0,a0,186 # ffffffffc02048c0 <commands+0x460>
ffffffffc020080e:	8b1ff06f          	j	ffffffffc02000be <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200812:	00004517          	auipc	a0,0x4
ffffffffc0200816:	11e50513          	addi	a0,a0,286 # ffffffffc0204930 <commands+0x4d0>
ffffffffc020081a:	8a5ff06f          	j	ffffffffc02000be <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc020081e:	1141                	addi	sp,sp,-16
ffffffffc0200820:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200822:	bedff0ef          	jal	ra,ffffffffc020040e <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200826:	00011797          	auipc	a5,0x11
ffffffffc020082a:	c4a78793          	addi	a5,a5,-950 # ffffffffc0211470 <ticks>
ffffffffc020082e:	639c                	ld	a5,0(a5)
ffffffffc0200830:	06400713          	li	a4,100
ffffffffc0200834:	0785                	addi	a5,a5,1
ffffffffc0200836:	02e7f733          	remu	a4,a5,a4
ffffffffc020083a:	00011697          	auipc	a3,0x11
ffffffffc020083e:	c2f6bb23          	sd	a5,-970(a3) # ffffffffc0211470 <ticks>
ffffffffc0200842:	c711                	beqz	a4,ffffffffc020084e <interrupt_handler+0x8e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200844:	60a2                	ld	ra,8(sp)
ffffffffc0200846:	0141                	addi	sp,sp,16
ffffffffc0200848:	8082                	ret
            print_trapframe(tf);
ffffffffc020084a:	f15ff06f          	j	ffffffffc020075e <print_trapframe>
}
ffffffffc020084e:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200850:	06400593          	li	a1,100
ffffffffc0200854:	00004517          	auipc	a0,0x4
ffffffffc0200858:	0cc50513          	addi	a0,a0,204 # ffffffffc0204920 <commands+0x4c0>
}
ffffffffc020085c:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020085e:	861ff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200862 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200862:	11853783          	ld	a5,280(a0)
ffffffffc0200866:	473d                	li	a4,15
ffffffffc0200868:	1af76463          	bltu	a4,a5,ffffffffc0200a10 <exception_handler+0x1ae>
ffffffffc020086c:	00004717          	auipc	a4,0x4
ffffffffc0200870:	dd870713          	addi	a4,a4,-552 # ffffffffc0204644 <commands+0x1e4>
ffffffffc0200874:	078a                	slli	a5,a5,0x2
ffffffffc0200876:	97ba                	add	a5,a5,a4
ffffffffc0200878:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc020087a:	1101                	addi	sp,sp,-32
ffffffffc020087c:	e822                	sd	s0,16(sp)
ffffffffc020087e:	ec06                	sd	ra,24(sp)
ffffffffc0200880:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200882:	97ba                	add	a5,a5,a4
ffffffffc0200884:	842a                	mv	s0,a0
ffffffffc0200886:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc0200888:	00004517          	auipc	a0,0x4
ffffffffc020088c:	00050513          	mv	a0,a0
ffffffffc0200890:	82fff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200894:	8522                	mv	a0,s0
ffffffffc0200896:	c6bff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc020089a:	84aa                	mv	s1,a0
ffffffffc020089c:	16051c63          	bnez	a0,ffffffffc0200a14 <exception_handler+0x1b2>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc02008a0:	60e2                	ld	ra,24(sp)
ffffffffc02008a2:	6442                	ld	s0,16(sp)
ffffffffc02008a4:	64a2                	ld	s1,8(sp)
ffffffffc02008a6:	6105                	addi	sp,sp,32
ffffffffc02008a8:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc02008aa:	00004517          	auipc	a0,0x4
ffffffffc02008ae:	dde50513          	addi	a0,a0,-546 # ffffffffc0204688 <commands+0x228>
}
ffffffffc02008b2:	6442                	ld	s0,16(sp)
ffffffffc02008b4:	60e2                	ld	ra,24(sp)
ffffffffc02008b6:	64a2                	ld	s1,8(sp)
ffffffffc02008b8:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008ba:	805ff06f          	j	ffffffffc02000be <cprintf>
ffffffffc02008be:	00004517          	auipc	a0,0x4
ffffffffc02008c2:	dea50513          	addi	a0,a0,-534 # ffffffffc02046a8 <commands+0x248>
ffffffffc02008c6:	b7f5                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Exception type:Illegal instruction\n");
ffffffffc02008c8:	00004517          	auipc	a0,0x4
ffffffffc02008cc:	e0050513          	addi	a0,a0,-512 # ffffffffc02046c8 <commands+0x268>
ffffffffc02008d0:	feeff0ef          	jal	ra,ffffffffc02000be <cprintf>
            cprintf("Illegal instruction caught at 0x%x\n",tf->epc);
ffffffffc02008d4:	10843583          	ld	a1,264(s0)
ffffffffc02008d8:	00004517          	auipc	a0,0x4
ffffffffc02008dc:	e1850513          	addi	a0,a0,-488 # ffffffffc02046f0 <commands+0x290>
ffffffffc02008e0:	fdeff0ef          	jal	ra,ffffffffc02000be <cprintf>
            tf->epc+=4;
ffffffffc02008e4:	10843783          	ld	a5,264(s0)
ffffffffc02008e8:	0791                	addi	a5,a5,4
ffffffffc02008ea:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc02008ee:	bf4d                	j	ffffffffc02008a0 <exception_handler+0x3e>
            cprintf("Exception type: breakpoint\n");
ffffffffc02008f0:	00004517          	auipc	a0,0x4
ffffffffc02008f4:	e2850513          	addi	a0,a0,-472 # ffffffffc0204718 <commands+0x2b8>
ffffffffc02008f8:	fc6ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            cprintf("ebreak caught at 0x%x\n",tf->epc);
ffffffffc02008fc:	10843583          	ld	a1,264(s0)
ffffffffc0200900:	00004517          	auipc	a0,0x4
ffffffffc0200904:	e3850513          	addi	a0,a0,-456 # ffffffffc0204738 <commands+0x2d8>
ffffffffc0200908:	fb6ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            tf->epc+=2;
ffffffffc020090c:	10843783          	ld	a5,264(s0)
ffffffffc0200910:	0789                	addi	a5,a5,2
ffffffffc0200912:	10f43423          	sd	a5,264(s0)
            break;
ffffffffc0200916:	b769                	j	ffffffffc02008a0 <exception_handler+0x3e>
            cprintf("Load address misaligned\n");
ffffffffc0200918:	00004517          	auipc	a0,0x4
ffffffffc020091c:	e3850513          	addi	a0,a0,-456 # ffffffffc0204750 <commands+0x2f0>
ffffffffc0200920:	bf49                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200922:	00004517          	auipc	a0,0x4
ffffffffc0200926:	e4e50513          	addi	a0,a0,-434 # ffffffffc0204770 <commands+0x310>
ffffffffc020092a:	f94ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020092e:	8522                	mv	a0,s0
ffffffffc0200930:	bd1ff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc0200934:	84aa                	mv	s1,a0
ffffffffc0200936:	d52d                	beqz	a0,ffffffffc02008a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200938:	8522                	mv	a0,s0
ffffffffc020093a:	e25ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc020093e:	86a6                	mv	a3,s1
ffffffffc0200940:	00004617          	auipc	a2,0x4
ffffffffc0200944:	e4860613          	addi	a2,a2,-440 # ffffffffc0204788 <commands+0x328>
ffffffffc0200948:	0da00593          	li	a1,218
ffffffffc020094c:	00004517          	auipc	a0,0x4
ffffffffc0200950:	03c50513          	addi	a0,a0,60 # ffffffffc0204988 <commands+0x528>
ffffffffc0200954:	a21ff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200958:	00004517          	auipc	a0,0x4
ffffffffc020095c:	e5050513          	addi	a0,a0,-432 # ffffffffc02047a8 <commands+0x348>
ffffffffc0200960:	bf89                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200962:	00004517          	auipc	a0,0x4
ffffffffc0200966:	e5e50513          	addi	a0,a0,-418 # ffffffffc02047c0 <commands+0x360>
ffffffffc020096a:	f54ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020096e:	8522                	mv	a0,s0
ffffffffc0200970:	b91ff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc0200974:	84aa                	mv	s1,a0
ffffffffc0200976:	f20505e3          	beqz	a0,ffffffffc02008a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020097a:	8522                	mv	a0,s0
ffffffffc020097c:	de3ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200980:	86a6                	mv	a3,s1
ffffffffc0200982:	00004617          	auipc	a2,0x4
ffffffffc0200986:	e0660613          	addi	a2,a2,-506 # ffffffffc0204788 <commands+0x328>
ffffffffc020098a:	0e400593          	li	a1,228
ffffffffc020098e:	00004517          	auipc	a0,0x4
ffffffffc0200992:	ffa50513          	addi	a0,a0,-6 # ffffffffc0204988 <commands+0x528>
ffffffffc0200996:	9dfff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc020099a:	00004517          	auipc	a0,0x4
ffffffffc020099e:	e3e50513          	addi	a0,a0,-450 # ffffffffc02047d8 <commands+0x378>
ffffffffc02009a2:	bf01                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc02009a4:	00004517          	auipc	a0,0x4
ffffffffc02009a8:	e5450513          	addi	a0,a0,-428 # ffffffffc02047f8 <commands+0x398>
ffffffffc02009ac:	b719                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc02009ae:	00004517          	auipc	a0,0x4
ffffffffc02009b2:	e6a50513          	addi	a0,a0,-406 # ffffffffc0204818 <commands+0x3b8>
ffffffffc02009b6:	bdf5                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc02009b8:	00004517          	auipc	a0,0x4
ffffffffc02009bc:	e8050513          	addi	a0,a0,-384 # ffffffffc0204838 <commands+0x3d8>
ffffffffc02009c0:	bdcd                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc02009c2:	00004517          	auipc	a0,0x4
ffffffffc02009c6:	e9650513          	addi	a0,a0,-362 # ffffffffc0204858 <commands+0x3f8>
ffffffffc02009ca:	b5e5                	j	ffffffffc02008b2 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc02009cc:	00004517          	auipc	a0,0x4
ffffffffc02009d0:	ea450513          	addi	a0,a0,-348 # ffffffffc0204870 <commands+0x410>
ffffffffc02009d4:	eeaff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02009d8:	8522                	mv	a0,s0
ffffffffc02009da:	b27ff0ef          	jal	ra,ffffffffc0200500 <pgfault_handler>
ffffffffc02009de:	84aa                	mv	s1,a0
ffffffffc02009e0:	ec0500e3          	beqz	a0,ffffffffc02008a0 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02009e4:	8522                	mv	a0,s0
ffffffffc02009e6:	d79ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ea:	86a6                	mv	a3,s1
ffffffffc02009ec:	00004617          	auipc	a2,0x4
ffffffffc02009f0:	d9c60613          	addi	a2,a2,-612 # ffffffffc0204788 <commands+0x328>
ffffffffc02009f4:	0fa00593          	li	a1,250
ffffffffc02009f8:	00004517          	auipc	a0,0x4
ffffffffc02009fc:	f9050513          	addi	a0,a0,-112 # ffffffffc0204988 <commands+0x528>
ffffffffc0200a00:	975ff0ef          	jal	ra,ffffffffc0200374 <__panic>
}
ffffffffc0200a04:	6442                	ld	s0,16(sp)
ffffffffc0200a06:	60e2                	ld	ra,24(sp)
ffffffffc0200a08:	64a2                	ld	s1,8(sp)
ffffffffc0200a0a:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200a0c:	d53ff06f          	j	ffffffffc020075e <print_trapframe>
ffffffffc0200a10:	d4fff06f          	j	ffffffffc020075e <print_trapframe>
                print_trapframe(tf);
ffffffffc0200a14:	8522                	mv	a0,s0
ffffffffc0200a16:	d49ff0ef          	jal	ra,ffffffffc020075e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200a1a:	86a6                	mv	a3,s1
ffffffffc0200a1c:	00004617          	auipc	a2,0x4
ffffffffc0200a20:	d6c60613          	addi	a2,a2,-660 # ffffffffc0204788 <commands+0x328>
ffffffffc0200a24:	10100593          	li	a1,257
ffffffffc0200a28:	00004517          	auipc	a0,0x4
ffffffffc0200a2c:	f6050513          	addi	a0,a0,-160 # ffffffffc0204988 <commands+0x528>
ffffffffc0200a30:	945ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200a34 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200a34:	11853783          	ld	a5,280(a0)
ffffffffc0200a38:	0007c463          	bltz	a5,ffffffffc0200a40 <trap+0xc>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200a3c:	e27ff06f          	j	ffffffffc0200862 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200a40:	d81ff06f          	j	ffffffffc02007c0 <interrupt_handler>
	...

ffffffffc0200a50 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200a50:	14011073          	csrw	sscratch,sp
ffffffffc0200a54:	712d                	addi	sp,sp,-288
ffffffffc0200a56:	e406                	sd	ra,8(sp)
ffffffffc0200a58:	ec0e                	sd	gp,24(sp)
ffffffffc0200a5a:	f012                	sd	tp,32(sp)
ffffffffc0200a5c:	f416                	sd	t0,40(sp)
ffffffffc0200a5e:	f81a                	sd	t1,48(sp)
ffffffffc0200a60:	fc1e                	sd	t2,56(sp)
ffffffffc0200a62:	e0a2                	sd	s0,64(sp)
ffffffffc0200a64:	e4a6                	sd	s1,72(sp)
ffffffffc0200a66:	e8aa                	sd	a0,80(sp)
ffffffffc0200a68:	ecae                	sd	a1,88(sp)
ffffffffc0200a6a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a6c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a6e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a70:	fcbe                	sd	a5,120(sp)
ffffffffc0200a72:	e142                	sd	a6,128(sp)
ffffffffc0200a74:	e546                	sd	a7,136(sp)
ffffffffc0200a76:	e94a                	sd	s2,144(sp)
ffffffffc0200a78:	ed4e                	sd	s3,152(sp)
ffffffffc0200a7a:	f152                	sd	s4,160(sp)
ffffffffc0200a7c:	f556                	sd	s5,168(sp)
ffffffffc0200a7e:	f95a                	sd	s6,176(sp)
ffffffffc0200a80:	fd5e                	sd	s7,184(sp)
ffffffffc0200a82:	e1e2                	sd	s8,192(sp)
ffffffffc0200a84:	e5e6                	sd	s9,200(sp)
ffffffffc0200a86:	e9ea                	sd	s10,208(sp)
ffffffffc0200a88:	edee                	sd	s11,216(sp)
ffffffffc0200a8a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a8c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a8e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a90:	fdfe                	sd	t6,248(sp)
ffffffffc0200a92:	14002473          	csrr	s0,sscratch
ffffffffc0200a96:	100024f3          	csrr	s1,sstatus
ffffffffc0200a9a:	14102973          	csrr	s2,sepc
ffffffffc0200a9e:	143029f3          	csrr	s3,stval
ffffffffc0200aa2:	14202a73          	csrr	s4,scause
ffffffffc0200aa6:	e822                	sd	s0,16(sp)
ffffffffc0200aa8:	e226                	sd	s1,256(sp)
ffffffffc0200aaa:	e64a                	sd	s2,264(sp)
ffffffffc0200aac:	ea4e                	sd	s3,272(sp)
ffffffffc0200aae:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200ab0:	850a                	mv	a0,sp
    jal trap
ffffffffc0200ab2:	f83ff0ef          	jal	ra,ffffffffc0200a34 <trap>

ffffffffc0200ab6 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200ab6:	6492                	ld	s1,256(sp)
ffffffffc0200ab8:	6932                	ld	s2,264(sp)
ffffffffc0200aba:	10049073          	csrw	sstatus,s1
ffffffffc0200abe:	14191073          	csrw	sepc,s2
ffffffffc0200ac2:	60a2                	ld	ra,8(sp)
ffffffffc0200ac4:	61e2                	ld	gp,24(sp)
ffffffffc0200ac6:	7202                	ld	tp,32(sp)
ffffffffc0200ac8:	72a2                	ld	t0,40(sp)
ffffffffc0200aca:	7342                	ld	t1,48(sp)
ffffffffc0200acc:	73e2                	ld	t2,56(sp)
ffffffffc0200ace:	6406                	ld	s0,64(sp)
ffffffffc0200ad0:	64a6                	ld	s1,72(sp)
ffffffffc0200ad2:	6546                	ld	a0,80(sp)
ffffffffc0200ad4:	65e6                	ld	a1,88(sp)
ffffffffc0200ad6:	7606                	ld	a2,96(sp)
ffffffffc0200ad8:	76a6                	ld	a3,104(sp)
ffffffffc0200ada:	7746                	ld	a4,112(sp)
ffffffffc0200adc:	77e6                	ld	a5,120(sp)
ffffffffc0200ade:	680a                	ld	a6,128(sp)
ffffffffc0200ae0:	68aa                	ld	a7,136(sp)
ffffffffc0200ae2:	694a                	ld	s2,144(sp)
ffffffffc0200ae4:	69ea                	ld	s3,152(sp)
ffffffffc0200ae6:	7a0a                	ld	s4,160(sp)
ffffffffc0200ae8:	7aaa                	ld	s5,168(sp)
ffffffffc0200aea:	7b4a                	ld	s6,176(sp)
ffffffffc0200aec:	7bea                	ld	s7,184(sp)
ffffffffc0200aee:	6c0e                	ld	s8,192(sp)
ffffffffc0200af0:	6cae                	ld	s9,200(sp)
ffffffffc0200af2:	6d4e                	ld	s10,208(sp)
ffffffffc0200af4:	6dee                	ld	s11,216(sp)
ffffffffc0200af6:	7e0e                	ld	t3,224(sp)
ffffffffc0200af8:	7eae                	ld	t4,232(sp)
ffffffffc0200afa:	7f4e                	ld	t5,240(sp)
ffffffffc0200afc:	7fee                	ld	t6,248(sp)
ffffffffc0200afe:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200b00:	10200073          	sret
	...

ffffffffc0200b10 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200b10:	00011797          	auipc	a5,0x11
ffffffffc0200b14:	96878793          	addi	a5,a5,-1688 # ffffffffc0211478 <free_area>
ffffffffc0200b18:	e79c                	sd	a5,8(a5)
ffffffffc0200b1a:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200b1c:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200b20:	8082                	ret

ffffffffc0200b22 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200b22:	00011517          	auipc	a0,0x11
ffffffffc0200b26:	96656503          	lwu	a0,-1690(a0) # ffffffffc0211488 <free_area+0x10>
ffffffffc0200b2a:	8082                	ret

ffffffffc0200b2c <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200b2c:	715d                	addi	sp,sp,-80
ffffffffc0200b2e:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200b30:	00011917          	auipc	s2,0x11
ffffffffc0200b34:	94890913          	addi	s2,s2,-1720 # ffffffffc0211478 <free_area>
ffffffffc0200b38:	00893783          	ld	a5,8(s2)
ffffffffc0200b3c:	e486                	sd	ra,72(sp)
ffffffffc0200b3e:	e0a2                	sd	s0,64(sp)
ffffffffc0200b40:	fc26                	sd	s1,56(sp)
ffffffffc0200b42:	f44e                	sd	s3,40(sp)
ffffffffc0200b44:	f052                	sd	s4,32(sp)
ffffffffc0200b46:	ec56                	sd	s5,24(sp)
ffffffffc0200b48:	e85a                	sd	s6,16(sp)
ffffffffc0200b4a:	e45e                	sd	s7,8(sp)
ffffffffc0200b4c:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b4e:	31278f63          	beq	a5,s2,ffffffffc0200e6c <default_check+0x340>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200b52:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200b56:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200b58:	8b05                	andi	a4,a4,1
ffffffffc0200b5a:	30070d63          	beqz	a4,ffffffffc0200e74 <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0200b5e:	4401                	li	s0,0
ffffffffc0200b60:	4481                	li	s1,0
ffffffffc0200b62:	a031                	j	ffffffffc0200b6e <default_check+0x42>
ffffffffc0200b64:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0200b68:	8b09                	andi	a4,a4,2
ffffffffc0200b6a:	30070563          	beqz	a4,ffffffffc0200e74 <default_check+0x348>
        count ++, total += p->property;
ffffffffc0200b6e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b72:	679c                	ld	a5,8(a5)
ffffffffc0200b74:	2485                	addiw	s1,s1,1
ffffffffc0200b76:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b78:	ff2796e3          	bne	a5,s2,ffffffffc0200b64 <default_check+0x38>
ffffffffc0200b7c:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200b7e:	3ef000ef          	jal	ra,ffffffffc020176c <nr_free_pages>
ffffffffc0200b82:	75351963          	bne	a0,s3,ffffffffc02012d4 <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b86:	4505                	li	a0,1
ffffffffc0200b88:	317000ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0200b8c:	8a2a                	mv	s4,a0
ffffffffc0200b8e:	48050363          	beqz	a0,ffffffffc0201014 <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b92:	4505                	li	a0,1
ffffffffc0200b94:	30b000ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0200b98:	89aa                	mv	s3,a0
ffffffffc0200b9a:	74050d63          	beqz	a0,ffffffffc02012f4 <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b9e:	4505                	li	a0,1
ffffffffc0200ba0:	2ff000ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0200ba4:	8aaa                	mv	s5,a0
ffffffffc0200ba6:	4e050763          	beqz	a0,ffffffffc0201094 <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200baa:	2f3a0563          	beq	s4,s3,ffffffffc0200e94 <default_check+0x368>
ffffffffc0200bae:	2eaa0363          	beq	s4,a0,ffffffffc0200e94 <default_check+0x368>
ffffffffc0200bb2:	2ea98163          	beq	s3,a0,ffffffffc0200e94 <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200bb6:	000a2783          	lw	a5,0(s4)
ffffffffc0200bba:	2e079d63          	bnez	a5,ffffffffc0200eb4 <default_check+0x388>
ffffffffc0200bbe:	0009a783          	lw	a5,0(s3)
ffffffffc0200bc2:	2e079963          	bnez	a5,ffffffffc0200eb4 <default_check+0x388>
ffffffffc0200bc6:	411c                	lw	a5,0(a0)
ffffffffc0200bc8:	2e079663          	bnez	a5,ffffffffc0200eb4 <default_check+0x388>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bcc:	00011797          	auipc	a5,0x11
ffffffffc0200bd0:	8dc78793          	addi	a5,a5,-1828 # ffffffffc02114a8 <pages>
ffffffffc0200bd4:	639c                	ld	a5,0(a5)
ffffffffc0200bd6:	00004717          	auipc	a4,0x4
ffffffffc0200bda:	14270713          	addi	a4,a4,322 # ffffffffc0204d18 <commands+0x8b8>
ffffffffc0200bde:	630c                	ld	a1,0(a4)
ffffffffc0200be0:	40fa0733          	sub	a4,s4,a5
ffffffffc0200be4:	870d                	srai	a4,a4,0x3
ffffffffc0200be6:	02b70733          	mul	a4,a4,a1
ffffffffc0200bea:	00005697          	auipc	a3,0x5
ffffffffc0200bee:	5d668693          	addi	a3,a3,1494 # ffffffffc02061c0 <nbase>
ffffffffc0200bf2:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200bf4:	00011697          	auipc	a3,0x11
ffffffffc0200bf8:	86468693          	addi	a3,a3,-1948 # ffffffffc0211458 <npage>
ffffffffc0200bfc:	6294                	ld	a3,0(a3)
ffffffffc0200bfe:	06b2                	slli	a3,a3,0xc
ffffffffc0200c00:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c02:	0732                	slli	a4,a4,0xc
ffffffffc0200c04:	2cd77863          	bleu	a3,a4,ffffffffc0200ed4 <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c08:	40f98733          	sub	a4,s3,a5
ffffffffc0200c0c:	870d                	srai	a4,a4,0x3
ffffffffc0200c0e:	02b70733          	mul	a4,a4,a1
ffffffffc0200c12:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c14:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200c16:	4ed77f63          	bleu	a3,a4,ffffffffc0201114 <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200c1a:	40f507b3          	sub	a5,a0,a5
ffffffffc0200c1e:	878d                	srai	a5,a5,0x3
ffffffffc0200c20:	02b787b3          	mul	a5,a5,a1
ffffffffc0200c24:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200c26:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200c28:	34d7f663          	bleu	a3,a5,ffffffffc0200f74 <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc0200c2c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c2e:	00093c03          	ld	s8,0(s2)
ffffffffc0200c32:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200c36:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200c3a:	00011797          	auipc	a5,0x11
ffffffffc0200c3e:	8527b323          	sd	s2,-1978(a5) # ffffffffc0211480 <free_area+0x8>
ffffffffc0200c42:	00011797          	auipc	a5,0x11
ffffffffc0200c46:	8327bb23          	sd	s2,-1994(a5) # ffffffffc0211478 <free_area>
    nr_free = 0;
ffffffffc0200c4a:	00011797          	auipc	a5,0x11
ffffffffc0200c4e:	8207af23          	sw	zero,-1986(a5) # ffffffffc0211488 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200c52:	24d000ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0200c56:	2e051f63          	bnez	a0,ffffffffc0200f54 <default_check+0x428>
    free_page(p0);
ffffffffc0200c5a:	4585                	li	a1,1
ffffffffc0200c5c:	8552                	mv	a0,s4
ffffffffc0200c5e:	2c9000ef          	jal	ra,ffffffffc0201726 <free_pages>
    free_page(p1);
ffffffffc0200c62:	4585                	li	a1,1
ffffffffc0200c64:	854e                	mv	a0,s3
ffffffffc0200c66:	2c1000ef          	jal	ra,ffffffffc0201726 <free_pages>
    free_page(p2);
ffffffffc0200c6a:	4585                	li	a1,1
ffffffffc0200c6c:	8556                	mv	a0,s5
ffffffffc0200c6e:	2b9000ef          	jal	ra,ffffffffc0201726 <free_pages>
    assert(nr_free == 3);
ffffffffc0200c72:	01092703          	lw	a4,16(s2)
ffffffffc0200c76:	478d                	li	a5,3
ffffffffc0200c78:	2af71e63          	bne	a4,a5,ffffffffc0200f34 <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c7c:	4505                	li	a0,1
ffffffffc0200c7e:	221000ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0200c82:	89aa                	mv	s3,a0
ffffffffc0200c84:	28050863          	beqz	a0,ffffffffc0200f14 <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c88:	4505                	li	a0,1
ffffffffc0200c8a:	215000ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0200c8e:	8aaa                	mv	s5,a0
ffffffffc0200c90:	3e050263          	beqz	a0,ffffffffc0201074 <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c94:	4505                	li	a0,1
ffffffffc0200c96:	209000ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0200c9a:	8a2a                	mv	s4,a0
ffffffffc0200c9c:	3a050c63          	beqz	a0,ffffffffc0201054 <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc0200ca0:	4505                	li	a0,1
ffffffffc0200ca2:	1fd000ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0200ca6:	38051763          	bnez	a0,ffffffffc0201034 <default_check+0x508>
    free_page(p0);
ffffffffc0200caa:	4585                	li	a1,1
ffffffffc0200cac:	854e                	mv	a0,s3
ffffffffc0200cae:	279000ef          	jal	ra,ffffffffc0201726 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200cb2:	00893783          	ld	a5,8(s2)
ffffffffc0200cb6:	23278f63          	beq	a5,s2,ffffffffc0200ef4 <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc0200cba:	4505                	li	a0,1
ffffffffc0200cbc:	1e3000ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0200cc0:	32a99a63          	bne	s3,a0,ffffffffc0200ff4 <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0200cc4:	4505                	li	a0,1
ffffffffc0200cc6:	1d9000ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0200cca:	30051563          	bnez	a0,ffffffffc0200fd4 <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc0200cce:	01092783          	lw	a5,16(s2)
ffffffffc0200cd2:	2e079163          	bnez	a5,ffffffffc0200fb4 <default_check+0x488>
    free_page(p);
ffffffffc0200cd6:	854e                	mv	a0,s3
ffffffffc0200cd8:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200cda:	00010797          	auipc	a5,0x10
ffffffffc0200cde:	7987bf23          	sd	s8,1950(a5) # ffffffffc0211478 <free_area>
ffffffffc0200ce2:	00010797          	auipc	a5,0x10
ffffffffc0200ce6:	7977bf23          	sd	s7,1950(a5) # ffffffffc0211480 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200cea:	00010797          	auipc	a5,0x10
ffffffffc0200cee:	7967af23          	sw	s6,1950(a5) # ffffffffc0211488 <free_area+0x10>
    free_page(p);
ffffffffc0200cf2:	235000ef          	jal	ra,ffffffffc0201726 <free_pages>
    free_page(p1);
ffffffffc0200cf6:	4585                	li	a1,1
ffffffffc0200cf8:	8556                	mv	a0,s5
ffffffffc0200cfa:	22d000ef          	jal	ra,ffffffffc0201726 <free_pages>
    free_page(p2);
ffffffffc0200cfe:	4585                	li	a1,1
ffffffffc0200d00:	8552                	mv	a0,s4
ffffffffc0200d02:	225000ef          	jal	ra,ffffffffc0201726 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200d06:	4515                	li	a0,5
ffffffffc0200d08:	197000ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0200d0c:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200d0e:	28050363          	beqz	a0,ffffffffc0200f94 <default_check+0x468>
ffffffffc0200d12:	651c                	ld	a5,8(a0)
ffffffffc0200d14:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200d16:	8b85                	andi	a5,a5,1
ffffffffc0200d18:	54079e63          	bnez	a5,ffffffffc0201274 <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200d1c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200d1e:	00093b03          	ld	s6,0(s2)
ffffffffc0200d22:	00893a83          	ld	s5,8(s2)
ffffffffc0200d26:	00010797          	auipc	a5,0x10
ffffffffc0200d2a:	7527b923          	sd	s2,1874(a5) # ffffffffc0211478 <free_area>
ffffffffc0200d2e:	00010797          	auipc	a5,0x10
ffffffffc0200d32:	7527b923          	sd	s2,1874(a5) # ffffffffc0211480 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200d36:	169000ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0200d3a:	50051d63          	bnez	a0,ffffffffc0201254 <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200d3e:	09098a13          	addi	s4,s3,144
ffffffffc0200d42:	8552                	mv	a0,s4
ffffffffc0200d44:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200d46:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200d4a:	00010797          	auipc	a5,0x10
ffffffffc0200d4e:	7207af23          	sw	zero,1854(a5) # ffffffffc0211488 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200d52:	1d5000ef          	jal	ra,ffffffffc0201726 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200d56:	4511                	li	a0,4
ffffffffc0200d58:	147000ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0200d5c:	4c051c63          	bnez	a0,ffffffffc0201234 <default_check+0x708>
ffffffffc0200d60:	0989b783          	ld	a5,152(s3)
ffffffffc0200d64:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200d66:	8b85                	andi	a5,a5,1
ffffffffc0200d68:	4a078663          	beqz	a5,ffffffffc0201214 <default_check+0x6e8>
ffffffffc0200d6c:	0a89a703          	lw	a4,168(s3)
ffffffffc0200d70:	478d                	li	a5,3
ffffffffc0200d72:	4af71163          	bne	a4,a5,ffffffffc0201214 <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200d76:	450d                	li	a0,3
ffffffffc0200d78:	127000ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0200d7c:	8c2a                	mv	s8,a0
ffffffffc0200d7e:	46050b63          	beqz	a0,ffffffffc02011f4 <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0200d82:	4505                	li	a0,1
ffffffffc0200d84:	11b000ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0200d88:	44051663          	bnez	a0,ffffffffc02011d4 <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc0200d8c:	438a1463          	bne	s4,s8,ffffffffc02011b4 <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200d90:	4585                	li	a1,1
ffffffffc0200d92:	854e                	mv	a0,s3
ffffffffc0200d94:	193000ef          	jal	ra,ffffffffc0201726 <free_pages>
    free_pages(p1, 3);
ffffffffc0200d98:	458d                	li	a1,3
ffffffffc0200d9a:	8552                	mv	a0,s4
ffffffffc0200d9c:	18b000ef          	jal	ra,ffffffffc0201726 <free_pages>
ffffffffc0200da0:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200da4:	04898c13          	addi	s8,s3,72
ffffffffc0200da8:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200daa:	8b85                	andi	a5,a5,1
ffffffffc0200dac:	3e078463          	beqz	a5,ffffffffc0201194 <default_check+0x668>
ffffffffc0200db0:	0189a703          	lw	a4,24(s3)
ffffffffc0200db4:	4785                	li	a5,1
ffffffffc0200db6:	3cf71f63          	bne	a4,a5,ffffffffc0201194 <default_check+0x668>
ffffffffc0200dba:	008a3783          	ld	a5,8(s4)
ffffffffc0200dbe:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200dc0:	8b85                	andi	a5,a5,1
ffffffffc0200dc2:	3a078963          	beqz	a5,ffffffffc0201174 <default_check+0x648>
ffffffffc0200dc6:	018a2703          	lw	a4,24(s4)
ffffffffc0200dca:	478d                	li	a5,3
ffffffffc0200dcc:	3af71463          	bne	a4,a5,ffffffffc0201174 <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200dd0:	4505                	li	a0,1
ffffffffc0200dd2:	0cd000ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0200dd6:	36a99f63          	bne	s3,a0,ffffffffc0201154 <default_check+0x628>
    free_page(p0);
ffffffffc0200dda:	4585                	li	a1,1
ffffffffc0200ddc:	14b000ef          	jal	ra,ffffffffc0201726 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200de0:	4509                	li	a0,2
ffffffffc0200de2:	0bd000ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0200de6:	34aa1763          	bne	s4,a0,ffffffffc0201134 <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0200dea:	4589                	li	a1,2
ffffffffc0200dec:	13b000ef          	jal	ra,ffffffffc0201726 <free_pages>
    free_page(p2);
ffffffffc0200df0:	4585                	li	a1,1
ffffffffc0200df2:	8562                	mv	a0,s8
ffffffffc0200df4:	133000ef          	jal	ra,ffffffffc0201726 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200df8:	4515                	li	a0,5
ffffffffc0200dfa:	0a5000ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0200dfe:	89aa                	mv	s3,a0
ffffffffc0200e00:	48050a63          	beqz	a0,ffffffffc0201294 <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc0200e04:	4505                	li	a0,1
ffffffffc0200e06:	099000ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0200e0a:	2e051563          	bnez	a0,ffffffffc02010f4 <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc0200e0e:	01092783          	lw	a5,16(s2)
ffffffffc0200e12:	2c079163          	bnez	a5,ffffffffc02010d4 <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200e16:	4595                	li	a1,5
ffffffffc0200e18:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200e1a:	00010797          	auipc	a5,0x10
ffffffffc0200e1e:	6777a723          	sw	s7,1646(a5) # ffffffffc0211488 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200e22:	00010797          	auipc	a5,0x10
ffffffffc0200e26:	6567bb23          	sd	s6,1622(a5) # ffffffffc0211478 <free_area>
ffffffffc0200e2a:	00010797          	auipc	a5,0x10
ffffffffc0200e2e:	6557bb23          	sd	s5,1622(a5) # ffffffffc0211480 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200e32:	0f5000ef          	jal	ra,ffffffffc0201726 <free_pages>
    return listelm->next;
ffffffffc0200e36:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e3a:	01278963          	beq	a5,s2,ffffffffc0200e4c <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200e3e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e42:	679c                	ld	a5,8(a5)
ffffffffc0200e44:	34fd                	addiw	s1,s1,-1
ffffffffc0200e46:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e48:	ff279be3          	bne	a5,s2,ffffffffc0200e3e <default_check+0x312>
    }
    assert(count == 0);
ffffffffc0200e4c:	26049463          	bnez	s1,ffffffffc02010b4 <default_check+0x588>
    assert(total == 0);
ffffffffc0200e50:	46041263          	bnez	s0,ffffffffc02012b4 <default_check+0x788>
}
ffffffffc0200e54:	60a6                	ld	ra,72(sp)
ffffffffc0200e56:	6406                	ld	s0,64(sp)
ffffffffc0200e58:	74e2                	ld	s1,56(sp)
ffffffffc0200e5a:	7942                	ld	s2,48(sp)
ffffffffc0200e5c:	79a2                	ld	s3,40(sp)
ffffffffc0200e5e:	7a02                	ld	s4,32(sp)
ffffffffc0200e60:	6ae2                	ld	s5,24(sp)
ffffffffc0200e62:	6b42                	ld	s6,16(sp)
ffffffffc0200e64:	6ba2                	ld	s7,8(sp)
ffffffffc0200e66:	6c02                	ld	s8,0(sp)
ffffffffc0200e68:	6161                	addi	sp,sp,80
ffffffffc0200e6a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e6c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200e6e:	4401                	li	s0,0
ffffffffc0200e70:	4481                	li	s1,0
ffffffffc0200e72:	b331                	j	ffffffffc0200b7e <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200e74:	00004697          	auipc	a3,0x4
ffffffffc0200e78:	eac68693          	addi	a3,a3,-340 # ffffffffc0204d20 <commands+0x8c0>
ffffffffc0200e7c:	00004617          	auipc	a2,0x4
ffffffffc0200e80:	eb460613          	addi	a2,a2,-332 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0200e84:	0f000593          	li	a1,240
ffffffffc0200e88:	00004517          	auipc	a0,0x4
ffffffffc0200e8c:	ec050513          	addi	a0,a0,-320 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0200e90:	ce4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e94:	00004697          	auipc	a3,0x4
ffffffffc0200e98:	f4c68693          	addi	a3,a3,-180 # ffffffffc0204de0 <commands+0x980>
ffffffffc0200e9c:	00004617          	auipc	a2,0x4
ffffffffc0200ea0:	e9460613          	addi	a2,a2,-364 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0200ea4:	0bd00593          	li	a1,189
ffffffffc0200ea8:	00004517          	auipc	a0,0x4
ffffffffc0200eac:	ea050513          	addi	a0,a0,-352 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0200eb0:	cc4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200eb4:	00004697          	auipc	a3,0x4
ffffffffc0200eb8:	f5468693          	addi	a3,a3,-172 # ffffffffc0204e08 <commands+0x9a8>
ffffffffc0200ebc:	00004617          	auipc	a2,0x4
ffffffffc0200ec0:	e7460613          	addi	a2,a2,-396 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0200ec4:	0be00593          	li	a1,190
ffffffffc0200ec8:	00004517          	auipc	a0,0x4
ffffffffc0200ecc:	e8050513          	addi	a0,a0,-384 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0200ed0:	ca4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200ed4:	00004697          	auipc	a3,0x4
ffffffffc0200ed8:	f7468693          	addi	a3,a3,-140 # ffffffffc0204e48 <commands+0x9e8>
ffffffffc0200edc:	00004617          	auipc	a2,0x4
ffffffffc0200ee0:	e5460613          	addi	a2,a2,-428 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0200ee4:	0c000593          	li	a1,192
ffffffffc0200ee8:	00004517          	auipc	a0,0x4
ffffffffc0200eec:	e6050513          	addi	a0,a0,-416 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0200ef0:	c84ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200ef4:	00004697          	auipc	a3,0x4
ffffffffc0200ef8:	fdc68693          	addi	a3,a3,-36 # ffffffffc0204ed0 <commands+0xa70>
ffffffffc0200efc:	00004617          	auipc	a2,0x4
ffffffffc0200f00:	e3460613          	addi	a2,a2,-460 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0200f04:	0d900593          	li	a1,217
ffffffffc0200f08:	00004517          	auipc	a0,0x4
ffffffffc0200f0c:	e4050513          	addi	a0,a0,-448 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0200f10:	c64ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f14:	00004697          	auipc	a3,0x4
ffffffffc0200f18:	e6c68693          	addi	a3,a3,-404 # ffffffffc0204d80 <commands+0x920>
ffffffffc0200f1c:	00004617          	auipc	a2,0x4
ffffffffc0200f20:	e1460613          	addi	a2,a2,-492 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0200f24:	0d200593          	li	a1,210
ffffffffc0200f28:	00004517          	auipc	a0,0x4
ffffffffc0200f2c:	e2050513          	addi	a0,a0,-480 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0200f30:	c44ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 3);
ffffffffc0200f34:	00004697          	auipc	a3,0x4
ffffffffc0200f38:	f8c68693          	addi	a3,a3,-116 # ffffffffc0204ec0 <commands+0xa60>
ffffffffc0200f3c:	00004617          	auipc	a2,0x4
ffffffffc0200f40:	df460613          	addi	a2,a2,-524 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0200f44:	0d000593          	li	a1,208
ffffffffc0200f48:	00004517          	auipc	a0,0x4
ffffffffc0200f4c:	e0050513          	addi	a0,a0,-512 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0200f50:	c24ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f54:	00004697          	auipc	a3,0x4
ffffffffc0200f58:	f5468693          	addi	a3,a3,-172 # ffffffffc0204ea8 <commands+0xa48>
ffffffffc0200f5c:	00004617          	auipc	a2,0x4
ffffffffc0200f60:	dd460613          	addi	a2,a2,-556 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0200f64:	0cb00593          	li	a1,203
ffffffffc0200f68:	00004517          	auipc	a0,0x4
ffffffffc0200f6c:	de050513          	addi	a0,a0,-544 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0200f70:	c04ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f74:	00004697          	auipc	a3,0x4
ffffffffc0200f78:	f1468693          	addi	a3,a3,-236 # ffffffffc0204e88 <commands+0xa28>
ffffffffc0200f7c:	00004617          	auipc	a2,0x4
ffffffffc0200f80:	db460613          	addi	a2,a2,-588 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0200f84:	0c200593          	li	a1,194
ffffffffc0200f88:	00004517          	auipc	a0,0x4
ffffffffc0200f8c:	dc050513          	addi	a0,a0,-576 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0200f90:	be4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != NULL);
ffffffffc0200f94:	00004697          	auipc	a3,0x4
ffffffffc0200f98:	f8468693          	addi	a3,a3,-124 # ffffffffc0204f18 <commands+0xab8>
ffffffffc0200f9c:	00004617          	auipc	a2,0x4
ffffffffc0200fa0:	d9460613          	addi	a2,a2,-620 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0200fa4:	0f800593          	li	a1,248
ffffffffc0200fa8:	00004517          	auipc	a0,0x4
ffffffffc0200fac:	da050513          	addi	a0,a0,-608 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0200fb0:	bc4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0200fb4:	00004697          	auipc	a3,0x4
ffffffffc0200fb8:	f5468693          	addi	a3,a3,-172 # ffffffffc0204f08 <commands+0xaa8>
ffffffffc0200fbc:	00004617          	auipc	a2,0x4
ffffffffc0200fc0:	d7460613          	addi	a2,a2,-652 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0200fc4:	0df00593          	li	a1,223
ffffffffc0200fc8:	00004517          	auipc	a0,0x4
ffffffffc0200fcc:	d8050513          	addi	a0,a0,-640 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0200fd0:	ba4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fd4:	00004697          	auipc	a3,0x4
ffffffffc0200fd8:	ed468693          	addi	a3,a3,-300 # ffffffffc0204ea8 <commands+0xa48>
ffffffffc0200fdc:	00004617          	auipc	a2,0x4
ffffffffc0200fe0:	d5460613          	addi	a2,a2,-684 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0200fe4:	0dd00593          	li	a1,221
ffffffffc0200fe8:	00004517          	auipc	a0,0x4
ffffffffc0200fec:	d6050513          	addi	a0,a0,-672 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0200ff0:	b84ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200ff4:	00004697          	auipc	a3,0x4
ffffffffc0200ff8:	ef468693          	addi	a3,a3,-268 # ffffffffc0204ee8 <commands+0xa88>
ffffffffc0200ffc:	00004617          	auipc	a2,0x4
ffffffffc0201000:	d3460613          	addi	a2,a2,-716 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0201004:	0dc00593          	li	a1,220
ffffffffc0201008:	00004517          	auipc	a0,0x4
ffffffffc020100c:	d4050513          	addi	a0,a0,-704 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0201010:	b64ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201014:	00004697          	auipc	a3,0x4
ffffffffc0201018:	d6c68693          	addi	a3,a3,-660 # ffffffffc0204d80 <commands+0x920>
ffffffffc020101c:	00004617          	auipc	a2,0x4
ffffffffc0201020:	d1460613          	addi	a2,a2,-748 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0201024:	0b900593          	li	a1,185
ffffffffc0201028:	00004517          	auipc	a0,0x4
ffffffffc020102c:	d2050513          	addi	a0,a0,-736 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0201030:	b44ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201034:	00004697          	auipc	a3,0x4
ffffffffc0201038:	e7468693          	addi	a3,a3,-396 # ffffffffc0204ea8 <commands+0xa48>
ffffffffc020103c:	00004617          	auipc	a2,0x4
ffffffffc0201040:	cf460613          	addi	a2,a2,-780 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0201044:	0d600593          	li	a1,214
ffffffffc0201048:	00004517          	auipc	a0,0x4
ffffffffc020104c:	d0050513          	addi	a0,a0,-768 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0201050:	b24ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201054:	00004697          	auipc	a3,0x4
ffffffffc0201058:	d6c68693          	addi	a3,a3,-660 # ffffffffc0204dc0 <commands+0x960>
ffffffffc020105c:	00004617          	auipc	a2,0x4
ffffffffc0201060:	cd460613          	addi	a2,a2,-812 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0201064:	0d400593          	li	a1,212
ffffffffc0201068:	00004517          	auipc	a0,0x4
ffffffffc020106c:	ce050513          	addi	a0,a0,-800 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0201070:	b04ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201074:	00004697          	auipc	a3,0x4
ffffffffc0201078:	d2c68693          	addi	a3,a3,-724 # ffffffffc0204da0 <commands+0x940>
ffffffffc020107c:	00004617          	auipc	a2,0x4
ffffffffc0201080:	cb460613          	addi	a2,a2,-844 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0201084:	0d300593          	li	a1,211
ffffffffc0201088:	00004517          	auipc	a0,0x4
ffffffffc020108c:	cc050513          	addi	a0,a0,-832 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0201090:	ae4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201094:	00004697          	auipc	a3,0x4
ffffffffc0201098:	d2c68693          	addi	a3,a3,-724 # ffffffffc0204dc0 <commands+0x960>
ffffffffc020109c:	00004617          	auipc	a2,0x4
ffffffffc02010a0:	c9460613          	addi	a2,a2,-876 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02010a4:	0bb00593          	li	a1,187
ffffffffc02010a8:	00004517          	auipc	a0,0x4
ffffffffc02010ac:	ca050513          	addi	a0,a0,-864 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc02010b0:	ac4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(count == 0);
ffffffffc02010b4:	00004697          	auipc	a3,0x4
ffffffffc02010b8:	fb468693          	addi	a3,a3,-76 # ffffffffc0205068 <commands+0xc08>
ffffffffc02010bc:	00004617          	auipc	a2,0x4
ffffffffc02010c0:	c7460613          	addi	a2,a2,-908 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02010c4:	12500593          	li	a1,293
ffffffffc02010c8:	00004517          	auipc	a0,0x4
ffffffffc02010cc:	c8050513          	addi	a0,a0,-896 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc02010d0:	aa4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc02010d4:	00004697          	auipc	a3,0x4
ffffffffc02010d8:	e3468693          	addi	a3,a3,-460 # ffffffffc0204f08 <commands+0xaa8>
ffffffffc02010dc:	00004617          	auipc	a2,0x4
ffffffffc02010e0:	c5460613          	addi	a2,a2,-940 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02010e4:	11a00593          	li	a1,282
ffffffffc02010e8:	00004517          	auipc	a0,0x4
ffffffffc02010ec:	c6050513          	addi	a0,a0,-928 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc02010f0:	a84ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010f4:	00004697          	auipc	a3,0x4
ffffffffc02010f8:	db468693          	addi	a3,a3,-588 # ffffffffc0204ea8 <commands+0xa48>
ffffffffc02010fc:	00004617          	auipc	a2,0x4
ffffffffc0201100:	c3460613          	addi	a2,a2,-972 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0201104:	11800593          	li	a1,280
ffffffffc0201108:	00004517          	auipc	a0,0x4
ffffffffc020110c:	c4050513          	addi	a0,a0,-960 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0201110:	a64ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201114:	00004697          	auipc	a3,0x4
ffffffffc0201118:	d5468693          	addi	a3,a3,-684 # ffffffffc0204e68 <commands+0xa08>
ffffffffc020111c:	00004617          	auipc	a2,0x4
ffffffffc0201120:	c1460613          	addi	a2,a2,-1004 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0201124:	0c100593          	li	a1,193
ffffffffc0201128:	00004517          	auipc	a0,0x4
ffffffffc020112c:	c2050513          	addi	a0,a0,-992 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0201130:	a44ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201134:	00004697          	auipc	a3,0x4
ffffffffc0201138:	ef468693          	addi	a3,a3,-268 # ffffffffc0205028 <commands+0xbc8>
ffffffffc020113c:	00004617          	auipc	a2,0x4
ffffffffc0201140:	bf460613          	addi	a2,a2,-1036 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0201144:	11200593          	li	a1,274
ffffffffc0201148:	00004517          	auipc	a0,0x4
ffffffffc020114c:	c0050513          	addi	a0,a0,-1024 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0201150:	a24ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201154:	00004697          	auipc	a3,0x4
ffffffffc0201158:	eb468693          	addi	a3,a3,-332 # ffffffffc0205008 <commands+0xba8>
ffffffffc020115c:	00004617          	auipc	a2,0x4
ffffffffc0201160:	bd460613          	addi	a2,a2,-1068 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0201164:	11000593          	li	a1,272
ffffffffc0201168:	00004517          	auipc	a0,0x4
ffffffffc020116c:	be050513          	addi	a0,a0,-1056 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0201170:	a04ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201174:	00004697          	auipc	a3,0x4
ffffffffc0201178:	e6c68693          	addi	a3,a3,-404 # ffffffffc0204fe0 <commands+0xb80>
ffffffffc020117c:	00004617          	auipc	a2,0x4
ffffffffc0201180:	bb460613          	addi	a2,a2,-1100 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0201184:	10e00593          	li	a1,270
ffffffffc0201188:	00004517          	auipc	a0,0x4
ffffffffc020118c:	bc050513          	addi	a0,a0,-1088 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0201190:	9e4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201194:	00004697          	auipc	a3,0x4
ffffffffc0201198:	e2468693          	addi	a3,a3,-476 # ffffffffc0204fb8 <commands+0xb58>
ffffffffc020119c:	00004617          	auipc	a2,0x4
ffffffffc02011a0:	b9460613          	addi	a2,a2,-1132 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02011a4:	10d00593          	li	a1,269
ffffffffc02011a8:	00004517          	auipc	a0,0x4
ffffffffc02011ac:	ba050513          	addi	a0,a0,-1120 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc02011b0:	9c4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02011b4:	00004697          	auipc	a3,0x4
ffffffffc02011b8:	df468693          	addi	a3,a3,-524 # ffffffffc0204fa8 <commands+0xb48>
ffffffffc02011bc:	00004617          	auipc	a2,0x4
ffffffffc02011c0:	b7460613          	addi	a2,a2,-1164 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02011c4:	10800593          	li	a1,264
ffffffffc02011c8:	00004517          	auipc	a0,0x4
ffffffffc02011cc:	b8050513          	addi	a0,a0,-1152 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc02011d0:	9a4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011d4:	00004697          	auipc	a3,0x4
ffffffffc02011d8:	cd468693          	addi	a3,a3,-812 # ffffffffc0204ea8 <commands+0xa48>
ffffffffc02011dc:	00004617          	auipc	a2,0x4
ffffffffc02011e0:	b5460613          	addi	a2,a2,-1196 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02011e4:	10700593          	li	a1,263
ffffffffc02011e8:	00004517          	auipc	a0,0x4
ffffffffc02011ec:	b6050513          	addi	a0,a0,-1184 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc02011f0:	984ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02011f4:	00004697          	auipc	a3,0x4
ffffffffc02011f8:	d9468693          	addi	a3,a3,-620 # ffffffffc0204f88 <commands+0xb28>
ffffffffc02011fc:	00004617          	auipc	a2,0x4
ffffffffc0201200:	b3460613          	addi	a2,a2,-1228 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0201204:	10600593          	li	a1,262
ffffffffc0201208:	00004517          	auipc	a0,0x4
ffffffffc020120c:	b4050513          	addi	a0,a0,-1216 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0201210:	964ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201214:	00004697          	auipc	a3,0x4
ffffffffc0201218:	d4468693          	addi	a3,a3,-700 # ffffffffc0204f58 <commands+0xaf8>
ffffffffc020121c:	00004617          	auipc	a2,0x4
ffffffffc0201220:	b1460613          	addi	a2,a2,-1260 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0201224:	10500593          	li	a1,261
ffffffffc0201228:	00004517          	auipc	a0,0x4
ffffffffc020122c:	b2050513          	addi	a0,a0,-1248 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0201230:	944ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201234:	00004697          	auipc	a3,0x4
ffffffffc0201238:	d0c68693          	addi	a3,a3,-756 # ffffffffc0204f40 <commands+0xae0>
ffffffffc020123c:	00004617          	auipc	a2,0x4
ffffffffc0201240:	af460613          	addi	a2,a2,-1292 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0201244:	10400593          	li	a1,260
ffffffffc0201248:	00004517          	auipc	a0,0x4
ffffffffc020124c:	b0050513          	addi	a0,a0,-1280 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0201250:	924ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201254:	00004697          	auipc	a3,0x4
ffffffffc0201258:	c5468693          	addi	a3,a3,-940 # ffffffffc0204ea8 <commands+0xa48>
ffffffffc020125c:	00004617          	auipc	a2,0x4
ffffffffc0201260:	ad460613          	addi	a2,a2,-1324 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0201264:	0fe00593          	li	a1,254
ffffffffc0201268:	00004517          	auipc	a0,0x4
ffffffffc020126c:	ae050513          	addi	a0,a0,-1312 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0201270:	904ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201274:	00004697          	auipc	a3,0x4
ffffffffc0201278:	cb468693          	addi	a3,a3,-844 # ffffffffc0204f28 <commands+0xac8>
ffffffffc020127c:	00004617          	auipc	a2,0x4
ffffffffc0201280:	ab460613          	addi	a2,a2,-1356 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0201284:	0f900593          	li	a1,249
ffffffffc0201288:	00004517          	auipc	a0,0x4
ffffffffc020128c:	ac050513          	addi	a0,a0,-1344 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0201290:	8e4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201294:	00004697          	auipc	a3,0x4
ffffffffc0201298:	db468693          	addi	a3,a3,-588 # ffffffffc0205048 <commands+0xbe8>
ffffffffc020129c:	00004617          	auipc	a2,0x4
ffffffffc02012a0:	a9460613          	addi	a2,a2,-1388 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02012a4:	11700593          	li	a1,279
ffffffffc02012a8:	00004517          	auipc	a0,0x4
ffffffffc02012ac:	aa050513          	addi	a0,a0,-1376 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc02012b0:	8c4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == 0);
ffffffffc02012b4:	00004697          	auipc	a3,0x4
ffffffffc02012b8:	dc468693          	addi	a3,a3,-572 # ffffffffc0205078 <commands+0xc18>
ffffffffc02012bc:	00004617          	auipc	a2,0x4
ffffffffc02012c0:	a7460613          	addi	a2,a2,-1420 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02012c4:	12600593          	li	a1,294
ffffffffc02012c8:	00004517          	auipc	a0,0x4
ffffffffc02012cc:	a8050513          	addi	a0,a0,-1408 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc02012d0:	8a4ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == nr_free_pages());
ffffffffc02012d4:	00004697          	auipc	a3,0x4
ffffffffc02012d8:	a8c68693          	addi	a3,a3,-1396 # ffffffffc0204d60 <commands+0x900>
ffffffffc02012dc:	00004617          	auipc	a2,0x4
ffffffffc02012e0:	a5460613          	addi	a2,a2,-1452 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02012e4:	0f300593          	li	a1,243
ffffffffc02012e8:	00004517          	auipc	a0,0x4
ffffffffc02012ec:	a6050513          	addi	a0,a0,-1440 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc02012f0:	884ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02012f4:	00004697          	auipc	a3,0x4
ffffffffc02012f8:	aac68693          	addi	a3,a3,-1364 # ffffffffc0204da0 <commands+0x940>
ffffffffc02012fc:	00004617          	auipc	a2,0x4
ffffffffc0201300:	a3460613          	addi	a2,a2,-1484 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0201304:	0ba00593          	li	a1,186
ffffffffc0201308:	00004517          	auipc	a0,0x4
ffffffffc020130c:	a4050513          	addi	a0,a0,-1472 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0201310:	864ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201314 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201314:	1141                	addi	sp,sp,-16
ffffffffc0201316:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201318:	18058063          	beqz	a1,ffffffffc0201498 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc020131c:	00359693          	slli	a3,a1,0x3
ffffffffc0201320:	96ae                	add	a3,a3,a1
ffffffffc0201322:	068e                	slli	a3,a3,0x3
ffffffffc0201324:	96aa                	add	a3,a3,a0
ffffffffc0201326:	02d50d63          	beq	a0,a3,ffffffffc0201360 <default_free_pages+0x4c>
ffffffffc020132a:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020132c:	8b85                	andi	a5,a5,1
ffffffffc020132e:	14079563          	bnez	a5,ffffffffc0201478 <default_free_pages+0x164>
ffffffffc0201332:	651c                	ld	a5,8(a0)
ffffffffc0201334:	8385                	srli	a5,a5,0x1
ffffffffc0201336:	8b85                	andi	a5,a5,1
ffffffffc0201338:	14079063          	bnez	a5,ffffffffc0201478 <default_free_pages+0x164>
ffffffffc020133c:	87aa                	mv	a5,a0
ffffffffc020133e:	a809                	j	ffffffffc0201350 <default_free_pages+0x3c>
ffffffffc0201340:	6798                	ld	a4,8(a5)
ffffffffc0201342:	8b05                	andi	a4,a4,1
ffffffffc0201344:	12071a63          	bnez	a4,ffffffffc0201478 <default_free_pages+0x164>
ffffffffc0201348:	6798                	ld	a4,8(a5)
ffffffffc020134a:	8b09                	andi	a4,a4,2
ffffffffc020134c:	12071663          	bnez	a4,ffffffffc0201478 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc0201350:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201354:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201358:	04878793          	addi	a5,a5,72
ffffffffc020135c:	fed792e3          	bne	a5,a3,ffffffffc0201340 <default_free_pages+0x2c>
    base->property = n;
ffffffffc0201360:	2581                	sext.w	a1,a1
ffffffffc0201362:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0201364:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201368:	4789                	li	a5,2
ffffffffc020136a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020136e:	00010697          	auipc	a3,0x10
ffffffffc0201372:	10a68693          	addi	a3,a3,266 # ffffffffc0211478 <free_area>
ffffffffc0201376:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201378:	669c                	ld	a5,8(a3)
ffffffffc020137a:	9db9                	addw	a1,a1,a4
ffffffffc020137c:	00010717          	auipc	a4,0x10
ffffffffc0201380:	10b72623          	sw	a1,268(a4) # ffffffffc0211488 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201384:	08d78f63          	beq	a5,a3,ffffffffc0201422 <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201388:	fe078713          	addi	a4,a5,-32
ffffffffc020138c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020138e:	4801                	li	a6,0
ffffffffc0201390:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0201394:	00e56a63          	bltu	a0,a4,ffffffffc02013a8 <default_free_pages+0x94>
    return listelm->next;
ffffffffc0201398:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020139a:	02d70563          	beq	a4,a3,ffffffffc02013c4 <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020139e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02013a0:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02013a4:	fee57ae3          	bleu	a4,a0,ffffffffc0201398 <default_free_pages+0x84>
ffffffffc02013a8:	00080663          	beqz	a6,ffffffffc02013b4 <default_free_pages+0xa0>
ffffffffc02013ac:	00010817          	auipc	a6,0x10
ffffffffc02013b0:	0cb83623          	sd	a1,204(a6) # ffffffffc0211478 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02013b4:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02013b6:	e390                	sd	a2,0(a5)
ffffffffc02013b8:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02013ba:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02013bc:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc02013be:	02d59163          	bne	a1,a3,ffffffffc02013e0 <default_free_pages+0xcc>
ffffffffc02013c2:	a091                	j	ffffffffc0201406 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc02013c4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02013c6:	f514                	sd	a3,40(a0)
ffffffffc02013c8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02013ca:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc02013cc:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02013ce:	00d70563          	beq	a4,a3,ffffffffc02013d8 <default_free_pages+0xc4>
ffffffffc02013d2:	4805                	li	a6,1
ffffffffc02013d4:	87ba                	mv	a5,a4
ffffffffc02013d6:	b7e9                	j	ffffffffc02013a0 <default_free_pages+0x8c>
ffffffffc02013d8:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02013da:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02013dc:	02d78163          	beq	a5,a3,ffffffffc02013fe <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc02013e0:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc02013e4:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc02013e8:	02081713          	slli	a4,a6,0x20
ffffffffc02013ec:	9301                	srli	a4,a4,0x20
ffffffffc02013ee:	00371793          	slli	a5,a4,0x3
ffffffffc02013f2:	97ba                	add	a5,a5,a4
ffffffffc02013f4:	078e                	slli	a5,a5,0x3
ffffffffc02013f6:	97b2                	add	a5,a5,a2
ffffffffc02013f8:	02f50e63          	beq	a0,a5,ffffffffc0201434 <default_free_pages+0x120>
ffffffffc02013fc:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc02013fe:	fe078713          	addi	a4,a5,-32
ffffffffc0201402:	00d78d63          	beq	a5,a3,ffffffffc020141c <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc0201406:	4d0c                	lw	a1,24(a0)
ffffffffc0201408:	02059613          	slli	a2,a1,0x20
ffffffffc020140c:	9201                	srli	a2,a2,0x20
ffffffffc020140e:	00361693          	slli	a3,a2,0x3
ffffffffc0201412:	96b2                	add	a3,a3,a2
ffffffffc0201414:	068e                	slli	a3,a3,0x3
ffffffffc0201416:	96aa                	add	a3,a3,a0
ffffffffc0201418:	04d70063          	beq	a4,a3,ffffffffc0201458 <default_free_pages+0x144>
}
ffffffffc020141c:	60a2                	ld	ra,8(sp)
ffffffffc020141e:	0141                	addi	sp,sp,16
ffffffffc0201420:	8082                	ret
ffffffffc0201422:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201424:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc0201428:	e398                	sd	a4,0(a5)
ffffffffc020142a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020142c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020142e:	f11c                	sd	a5,32(a0)
}
ffffffffc0201430:	0141                	addi	sp,sp,16
ffffffffc0201432:	8082                	ret
            p->property += base->property;
ffffffffc0201434:	4d1c                	lw	a5,24(a0)
ffffffffc0201436:	0107883b          	addw	a6,a5,a6
ffffffffc020143a:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020143e:	57f5                	li	a5,-3
ffffffffc0201440:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201444:	02053803          	ld	a6,32(a0)
ffffffffc0201448:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc020144a:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020144c:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc0201450:	659c                	ld	a5,8(a1)
ffffffffc0201452:	01073023          	sd	a6,0(a4)
ffffffffc0201456:	b765                	j	ffffffffc02013fe <default_free_pages+0xea>
            base->property += p->property;
ffffffffc0201458:	ff87a703          	lw	a4,-8(a5)
ffffffffc020145c:	fe878693          	addi	a3,a5,-24
ffffffffc0201460:	9db9                	addw	a1,a1,a4
ffffffffc0201462:	cd0c                	sw	a1,24(a0)
ffffffffc0201464:	5775                	li	a4,-3
ffffffffc0201466:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020146a:	6398                	ld	a4,0(a5)
ffffffffc020146c:	679c                	ld	a5,8(a5)
}
ffffffffc020146e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201470:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201472:	e398                	sd	a4,0(a5)
ffffffffc0201474:	0141                	addi	sp,sp,16
ffffffffc0201476:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201478:	00004697          	auipc	a3,0x4
ffffffffc020147c:	c1068693          	addi	a3,a3,-1008 # ffffffffc0205088 <commands+0xc28>
ffffffffc0201480:	00004617          	auipc	a2,0x4
ffffffffc0201484:	8b060613          	addi	a2,a2,-1872 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0201488:	08300593          	li	a1,131
ffffffffc020148c:	00004517          	auipc	a0,0x4
ffffffffc0201490:	8bc50513          	addi	a0,a0,-1860 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc0201494:	ee1fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc0201498:	00004697          	auipc	a3,0x4
ffffffffc020149c:	c1868693          	addi	a3,a3,-1000 # ffffffffc02050b0 <commands+0xc50>
ffffffffc02014a0:	00004617          	auipc	a2,0x4
ffffffffc02014a4:	89060613          	addi	a2,a2,-1904 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02014a8:	08000593          	li	a1,128
ffffffffc02014ac:	00004517          	auipc	a0,0x4
ffffffffc02014b0:	89c50513          	addi	a0,a0,-1892 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc02014b4:	ec1fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02014b8 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02014b8:	cd51                	beqz	a0,ffffffffc0201554 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc02014ba:	00010597          	auipc	a1,0x10
ffffffffc02014be:	fbe58593          	addi	a1,a1,-66 # ffffffffc0211478 <free_area>
ffffffffc02014c2:	0105a803          	lw	a6,16(a1)
ffffffffc02014c6:	862a                	mv	a2,a0
ffffffffc02014c8:	02081793          	slli	a5,a6,0x20
ffffffffc02014cc:	9381                	srli	a5,a5,0x20
ffffffffc02014ce:	00a7ee63          	bltu	a5,a0,ffffffffc02014ea <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02014d2:	87ae                	mv	a5,a1
ffffffffc02014d4:	a801                	j	ffffffffc02014e4 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02014d6:	ff87a703          	lw	a4,-8(a5)
ffffffffc02014da:	02071693          	slli	a3,a4,0x20
ffffffffc02014de:	9281                	srli	a3,a3,0x20
ffffffffc02014e0:	00c6f763          	bleu	a2,a3,ffffffffc02014ee <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02014e4:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02014e6:	feb798e3          	bne	a5,a1,ffffffffc02014d6 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02014ea:	4501                	li	a0,0
}
ffffffffc02014ec:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc02014ee:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc02014f2:	dd6d                	beqz	a0,ffffffffc02014ec <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc02014f4:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02014f8:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc02014fc:	00060e1b          	sext.w	t3,a2
ffffffffc0201500:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201504:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201508:	02d67b63          	bleu	a3,a2,ffffffffc020153e <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc020150c:	00361693          	slli	a3,a2,0x3
ffffffffc0201510:	96b2                	add	a3,a3,a2
ffffffffc0201512:	068e                	slli	a3,a3,0x3
ffffffffc0201514:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0201516:	41c7073b          	subw	a4,a4,t3
ffffffffc020151a:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020151c:	00868613          	addi	a2,a3,8
ffffffffc0201520:	4709                	li	a4,2
ffffffffc0201522:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201526:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020152a:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc020152e:	0105a803          	lw	a6,16(a1)
ffffffffc0201532:	e310                	sd	a2,0(a4)
ffffffffc0201534:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201538:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020153a:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc020153e:	41c8083b          	subw	a6,a6,t3
ffffffffc0201542:	00010717          	auipc	a4,0x10
ffffffffc0201546:	f5072323          	sw	a6,-186(a4) # ffffffffc0211488 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020154a:	5775                	li	a4,-3
ffffffffc020154c:	17a1                	addi	a5,a5,-24
ffffffffc020154e:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201552:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201554:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201556:	00004697          	auipc	a3,0x4
ffffffffc020155a:	b5a68693          	addi	a3,a3,-1190 # ffffffffc02050b0 <commands+0xc50>
ffffffffc020155e:	00003617          	auipc	a2,0x3
ffffffffc0201562:	7d260613          	addi	a2,a2,2002 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0201566:	06200593          	li	a1,98
ffffffffc020156a:	00003517          	auipc	a0,0x3
ffffffffc020156e:	7de50513          	addi	a0,a0,2014 # ffffffffc0204d48 <commands+0x8e8>
default_alloc_pages(size_t n) {
ffffffffc0201572:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201574:	e01fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201578 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201578:	1141                	addi	sp,sp,-16
ffffffffc020157a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020157c:	c1fd                	beqz	a1,ffffffffc0201662 <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc020157e:	00359693          	slli	a3,a1,0x3
ffffffffc0201582:	96ae                	add	a3,a3,a1
ffffffffc0201584:	068e                	slli	a3,a3,0x3
ffffffffc0201586:	96aa                	add	a3,a3,a0
ffffffffc0201588:	02d50463          	beq	a0,a3,ffffffffc02015b0 <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020158c:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc020158e:	87aa                	mv	a5,a0
ffffffffc0201590:	8b05                	andi	a4,a4,1
ffffffffc0201592:	e709                	bnez	a4,ffffffffc020159c <default_init_memmap+0x24>
ffffffffc0201594:	a07d                	j	ffffffffc0201642 <default_init_memmap+0xca>
ffffffffc0201596:	6798                	ld	a4,8(a5)
ffffffffc0201598:	8b05                	andi	a4,a4,1
ffffffffc020159a:	c745                	beqz	a4,ffffffffc0201642 <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc020159c:	0007ac23          	sw	zero,24(a5)
ffffffffc02015a0:	0007b423          	sd	zero,8(a5)
ffffffffc02015a4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02015a8:	04878793          	addi	a5,a5,72
ffffffffc02015ac:	fed795e3          	bne	a5,a3,ffffffffc0201596 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc02015b0:	2581                	sext.w	a1,a1
ffffffffc02015b2:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02015b4:	4789                	li	a5,2
ffffffffc02015b6:	00850713          	addi	a4,a0,8
ffffffffc02015ba:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02015be:	00010697          	auipc	a3,0x10
ffffffffc02015c2:	eba68693          	addi	a3,a3,-326 # ffffffffc0211478 <free_area>
ffffffffc02015c6:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02015c8:	669c                	ld	a5,8(a3)
ffffffffc02015ca:	9db9                	addw	a1,a1,a4
ffffffffc02015cc:	00010717          	auipc	a4,0x10
ffffffffc02015d0:	eab72e23          	sw	a1,-324(a4) # ffffffffc0211488 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02015d4:	04d78a63          	beq	a5,a3,ffffffffc0201628 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc02015d8:	fe078713          	addi	a4,a5,-32
ffffffffc02015dc:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02015de:	4801                	li	a6,0
ffffffffc02015e0:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc02015e4:	00e56a63          	bltu	a0,a4,ffffffffc02015f8 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc02015e8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02015ea:	02d70563          	beq	a4,a3,ffffffffc0201614 <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02015ee:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02015f0:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02015f4:	fee57ae3          	bleu	a4,a0,ffffffffc02015e8 <default_init_memmap+0x70>
ffffffffc02015f8:	00080663          	beqz	a6,ffffffffc0201604 <default_init_memmap+0x8c>
ffffffffc02015fc:	00010717          	auipc	a4,0x10
ffffffffc0201600:	e6b73e23          	sd	a1,-388(a4) # ffffffffc0211478 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201604:	6398                	ld	a4,0(a5)
}
ffffffffc0201606:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201608:	e390                	sd	a2,0(a5)
ffffffffc020160a:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020160c:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020160e:	f118                	sd	a4,32(a0)
ffffffffc0201610:	0141                	addi	sp,sp,16
ffffffffc0201612:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201614:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201616:	f514                	sd	a3,40(a0)
ffffffffc0201618:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020161a:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc020161c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020161e:	00d70e63          	beq	a4,a3,ffffffffc020163a <default_init_memmap+0xc2>
ffffffffc0201622:	4805                	li	a6,1
ffffffffc0201624:	87ba                	mv	a5,a4
ffffffffc0201626:	b7e9                	j	ffffffffc02015f0 <default_init_memmap+0x78>
}
ffffffffc0201628:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020162a:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc020162e:	e398                	sd	a4,0(a5)
ffffffffc0201630:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201632:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201634:	f11c                	sd	a5,32(a0)
}
ffffffffc0201636:	0141                	addi	sp,sp,16
ffffffffc0201638:	8082                	ret
ffffffffc020163a:	60a2                	ld	ra,8(sp)
ffffffffc020163c:	e290                	sd	a2,0(a3)
ffffffffc020163e:	0141                	addi	sp,sp,16
ffffffffc0201640:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201642:	00004697          	auipc	a3,0x4
ffffffffc0201646:	a7668693          	addi	a3,a3,-1418 # ffffffffc02050b8 <commands+0xc58>
ffffffffc020164a:	00003617          	auipc	a2,0x3
ffffffffc020164e:	6e660613          	addi	a2,a2,1766 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0201652:	04900593          	li	a1,73
ffffffffc0201656:	00003517          	auipc	a0,0x3
ffffffffc020165a:	6f250513          	addi	a0,a0,1778 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc020165e:	d17fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc0201662:	00004697          	auipc	a3,0x4
ffffffffc0201666:	a4e68693          	addi	a3,a3,-1458 # ffffffffc02050b0 <commands+0xc50>
ffffffffc020166a:	00003617          	auipc	a2,0x3
ffffffffc020166e:	6c660613          	addi	a2,a2,1734 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0201672:	04600593          	li	a1,70
ffffffffc0201676:	00003517          	auipc	a0,0x3
ffffffffc020167a:	6d250513          	addi	a0,a0,1746 # ffffffffc0204d48 <commands+0x8e8>
ffffffffc020167e:	cf7fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201682 <pa2page.part.4>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201682:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201684:	00004617          	auipc	a2,0x4
ffffffffc0201688:	b0c60613          	addi	a2,a2,-1268 # ffffffffc0205190 <default_pmm_manager+0xc8>
ffffffffc020168c:	06500593          	li	a1,101
ffffffffc0201690:	00004517          	auipc	a0,0x4
ffffffffc0201694:	b2050513          	addi	a0,a0,-1248 # ffffffffc02051b0 <default_pmm_manager+0xe8>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201698:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc020169a:	cdbfe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020169e <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc020169e:	715d                	addi	sp,sp,-80
ffffffffc02016a0:	e0a2                	sd	s0,64(sp)
ffffffffc02016a2:	fc26                	sd	s1,56(sp)
ffffffffc02016a4:	f84a                	sd	s2,48(sp)
ffffffffc02016a6:	f44e                	sd	s3,40(sp)
ffffffffc02016a8:	f052                	sd	s4,32(sp)
ffffffffc02016aa:	ec56                	sd	s5,24(sp)
ffffffffc02016ac:	e486                	sd	ra,72(sp)
ffffffffc02016ae:	842a                	mv	s0,a0
ffffffffc02016b0:	00010497          	auipc	s1,0x10
ffffffffc02016b4:	de048493          	addi	s1,s1,-544 # ffffffffc0211490 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02016b8:	4985                	li	s3,1
ffffffffc02016ba:	00010a17          	auipc	s4,0x10
ffffffffc02016be:	daea0a13          	addi	s4,s4,-594 # ffffffffc0211468 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc02016c2:	0005091b          	sext.w	s2,a0
ffffffffc02016c6:	00010a97          	auipc	s5,0x10
ffffffffc02016ca:	ecaa8a93          	addi	s5,s5,-310 # ffffffffc0211590 <check_mm_struct>
ffffffffc02016ce:	a00d                	j	ffffffffc02016f0 <alloc_pages+0x52>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc02016d0:	609c                	ld	a5,0(s1)
ffffffffc02016d2:	6f9c                	ld	a5,24(a5)
ffffffffc02016d4:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc02016d6:	4601                	li	a2,0
ffffffffc02016d8:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02016da:	ed0d                	bnez	a0,ffffffffc0201714 <alloc_pages+0x76>
ffffffffc02016dc:	0289ec63          	bltu	s3,s0,ffffffffc0201714 <alloc_pages+0x76>
ffffffffc02016e0:	000a2783          	lw	a5,0(s4)
ffffffffc02016e4:	2781                	sext.w	a5,a5
ffffffffc02016e6:	c79d                	beqz	a5,ffffffffc0201714 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc02016e8:	000ab503          	ld	a0,0(s5)
ffffffffc02016ec:	021010ef          	jal	ra,ffffffffc0202f0c <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016f0:	100027f3          	csrr	a5,sstatus
ffffffffc02016f4:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc02016f6:	8522                	mv	a0,s0
ffffffffc02016f8:	dfe1                	beqz	a5,ffffffffc02016d0 <alloc_pages+0x32>
        intr_disable();
ffffffffc02016fa:	e01fe0ef          	jal	ra,ffffffffc02004fa <intr_disable>
ffffffffc02016fe:	609c                	ld	a5,0(s1)
ffffffffc0201700:	8522                	mv	a0,s0
ffffffffc0201702:	6f9c                	ld	a5,24(a5)
ffffffffc0201704:	9782                	jalr	a5
ffffffffc0201706:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201708:	dedfe0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
ffffffffc020170c:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc020170e:	4601                	li	a2,0
ffffffffc0201710:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201712:	d569                	beqz	a0,ffffffffc02016dc <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201714:	60a6                	ld	ra,72(sp)
ffffffffc0201716:	6406                	ld	s0,64(sp)
ffffffffc0201718:	74e2                	ld	s1,56(sp)
ffffffffc020171a:	7942                	ld	s2,48(sp)
ffffffffc020171c:	79a2                	ld	s3,40(sp)
ffffffffc020171e:	7a02                	ld	s4,32(sp)
ffffffffc0201720:	6ae2                	ld	s5,24(sp)
ffffffffc0201722:	6161                	addi	sp,sp,80
ffffffffc0201724:	8082                	ret

ffffffffc0201726 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201726:	100027f3          	csrr	a5,sstatus
ffffffffc020172a:	8b89                	andi	a5,a5,2
ffffffffc020172c:	eb89                	bnez	a5,ffffffffc020173e <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc020172e:	00010797          	auipc	a5,0x10
ffffffffc0201732:	d6278793          	addi	a5,a5,-670 # ffffffffc0211490 <pmm_manager>
ffffffffc0201736:	639c                	ld	a5,0(a5)
ffffffffc0201738:	0207b303          	ld	t1,32(a5)
ffffffffc020173c:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc020173e:	1101                	addi	sp,sp,-32
ffffffffc0201740:	ec06                	sd	ra,24(sp)
ffffffffc0201742:	e822                	sd	s0,16(sp)
ffffffffc0201744:	e426                	sd	s1,8(sp)
ffffffffc0201746:	842a                	mv	s0,a0
ffffffffc0201748:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020174a:	db1fe0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020174e:	00010797          	auipc	a5,0x10
ffffffffc0201752:	d4278793          	addi	a5,a5,-702 # ffffffffc0211490 <pmm_manager>
ffffffffc0201756:	639c                	ld	a5,0(a5)
ffffffffc0201758:	85a6                	mv	a1,s1
ffffffffc020175a:	8522                	mv	a0,s0
ffffffffc020175c:	739c                	ld	a5,32(a5)
ffffffffc020175e:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0201760:	6442                	ld	s0,16(sp)
ffffffffc0201762:	60e2                	ld	ra,24(sp)
ffffffffc0201764:	64a2                	ld	s1,8(sp)
ffffffffc0201766:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201768:	d8dfe06f          	j	ffffffffc02004f4 <intr_enable>

ffffffffc020176c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020176c:	100027f3          	csrr	a5,sstatus
ffffffffc0201770:	8b89                	andi	a5,a5,2
ffffffffc0201772:	eb89                	bnez	a5,ffffffffc0201784 <nr_free_pages+0x18>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201774:	00010797          	auipc	a5,0x10
ffffffffc0201778:	d1c78793          	addi	a5,a5,-740 # ffffffffc0211490 <pmm_manager>
ffffffffc020177c:	639c                	ld	a5,0(a5)
ffffffffc020177e:	0287b303          	ld	t1,40(a5)
ffffffffc0201782:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201784:	1141                	addi	sp,sp,-16
ffffffffc0201786:	e406                	sd	ra,8(sp)
ffffffffc0201788:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020178a:	d71fe0ef          	jal	ra,ffffffffc02004fa <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020178e:	00010797          	auipc	a5,0x10
ffffffffc0201792:	d0278793          	addi	a5,a5,-766 # ffffffffc0211490 <pmm_manager>
ffffffffc0201796:	639c                	ld	a5,0(a5)
ffffffffc0201798:	779c                	ld	a5,40(a5)
ffffffffc020179a:	9782                	jalr	a5
ffffffffc020179c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020179e:	d57fe0ef          	jal	ra,ffffffffc02004f4 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02017a2:	8522                	mv	a0,s0
ffffffffc02017a4:	60a2                	ld	ra,8(sp)
ffffffffc02017a6:	6402                	ld	s0,0(sp)
ffffffffc02017a8:	0141                	addi	sp,sp,16
ffffffffc02017aa:	8082                	ret

ffffffffc02017ac <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02017ac:	715d                	addi	sp,sp,-80
ffffffffc02017ae:	fc26                	sd	s1,56(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02017b0:	01e5d493          	srli	s1,a1,0x1e
ffffffffc02017b4:	1ff4f493          	andi	s1,s1,511
ffffffffc02017b8:	048e                	slli	s1,s1,0x3
ffffffffc02017ba:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017bc:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02017be:	f84a                	sd	s2,48(sp)
ffffffffc02017c0:	f44e                	sd	s3,40(sp)
ffffffffc02017c2:	f052                	sd	s4,32(sp)
ffffffffc02017c4:	e486                	sd	ra,72(sp)
ffffffffc02017c6:	e0a2                	sd	s0,64(sp)
ffffffffc02017c8:	ec56                	sd	s5,24(sp)
ffffffffc02017ca:	e85a                	sd	s6,16(sp)
ffffffffc02017cc:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017ce:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02017d2:	892e                	mv	s2,a1
ffffffffc02017d4:	8a32                	mv	s4,a2
ffffffffc02017d6:	00010997          	auipc	s3,0x10
ffffffffc02017da:	c8298993          	addi	s3,s3,-894 # ffffffffc0211458 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017de:	e3c9                	bnez	a5,ffffffffc0201860 <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02017e0:	16060163          	beqz	a2,ffffffffc0201942 <get_pte+0x196>
ffffffffc02017e4:	4505                	li	a0,1
ffffffffc02017e6:	eb9ff0ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc02017ea:	842a                	mv	s0,a0
ffffffffc02017ec:	14050b63          	beqz	a0,ffffffffc0201942 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017f0:	00010b97          	auipc	s7,0x10
ffffffffc02017f4:	cb8b8b93          	addi	s7,s7,-840 # ffffffffc02114a8 <pages>
ffffffffc02017f8:	000bb503          	ld	a0,0(s7)
ffffffffc02017fc:	00003797          	auipc	a5,0x3
ffffffffc0201800:	51c78793          	addi	a5,a5,1308 # ffffffffc0204d18 <commands+0x8b8>
ffffffffc0201804:	0007bb03          	ld	s6,0(a5)
ffffffffc0201808:	40a40533          	sub	a0,s0,a0
ffffffffc020180c:	850d                	srai	a0,a0,0x3
ffffffffc020180e:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201812:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201814:	00010997          	auipc	s3,0x10
ffffffffc0201818:	c4498993          	addi	s3,s3,-956 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020181c:	00080ab7          	lui	s5,0x80
ffffffffc0201820:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201824:	c01c                	sw	a5,0(s0)
ffffffffc0201826:	57fd                	li	a5,-1
ffffffffc0201828:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020182a:	9556                	add	a0,a0,s5
ffffffffc020182c:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020182e:	0532                	slli	a0,a0,0xc
ffffffffc0201830:	16e7f063          	bleu	a4,a5,ffffffffc0201990 <get_pte+0x1e4>
ffffffffc0201834:	00010797          	auipc	a5,0x10
ffffffffc0201838:	c6478793          	addi	a5,a5,-924 # ffffffffc0211498 <va_pa_offset>
ffffffffc020183c:	639c                	ld	a5,0(a5)
ffffffffc020183e:	6605                	lui	a2,0x1
ffffffffc0201840:	4581                	li	a1,0
ffffffffc0201842:	953e                	add	a0,a0,a5
ffffffffc0201844:	2c5020ef          	jal	ra,ffffffffc0204308 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201848:	000bb683          	ld	a3,0(s7)
ffffffffc020184c:	40d406b3          	sub	a3,s0,a3
ffffffffc0201850:	868d                	srai	a3,a3,0x3
ffffffffc0201852:	036686b3          	mul	a3,a3,s6
ffffffffc0201856:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201858:	06aa                	slli	a3,a3,0xa
ffffffffc020185a:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020185e:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201860:	77fd                	lui	a5,0xfffff
ffffffffc0201862:	068a                	slli	a3,a3,0x2
ffffffffc0201864:	0009b703          	ld	a4,0(s3)
ffffffffc0201868:	8efd                	and	a3,a3,a5
ffffffffc020186a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020186e:	0ce7fc63          	bleu	a4,a5,ffffffffc0201946 <get_pte+0x19a>
ffffffffc0201872:	00010a97          	auipc	s5,0x10
ffffffffc0201876:	c26a8a93          	addi	s5,s5,-986 # ffffffffc0211498 <va_pa_offset>
ffffffffc020187a:	000ab403          	ld	s0,0(s5)
ffffffffc020187e:	01595793          	srli	a5,s2,0x15
ffffffffc0201882:	1ff7f793          	andi	a5,a5,511
ffffffffc0201886:	96a2                	add	a3,a3,s0
ffffffffc0201888:	00379413          	slli	s0,a5,0x3
ffffffffc020188c:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc020188e:	6014                	ld	a3,0(s0)
ffffffffc0201890:	0016f793          	andi	a5,a3,1
ffffffffc0201894:	ebbd                	bnez	a5,ffffffffc020190a <get_pte+0x15e>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201896:	0a0a0663          	beqz	s4,ffffffffc0201942 <get_pte+0x196>
ffffffffc020189a:	4505                	li	a0,1
ffffffffc020189c:	e03ff0ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc02018a0:	84aa                	mv	s1,a0
ffffffffc02018a2:	c145                	beqz	a0,ffffffffc0201942 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018a4:	00010b97          	auipc	s7,0x10
ffffffffc02018a8:	c04b8b93          	addi	s7,s7,-1020 # ffffffffc02114a8 <pages>
ffffffffc02018ac:	000bb503          	ld	a0,0(s7)
ffffffffc02018b0:	00003797          	auipc	a5,0x3
ffffffffc02018b4:	46878793          	addi	a5,a5,1128 # ffffffffc0204d18 <commands+0x8b8>
ffffffffc02018b8:	0007bb03          	ld	s6,0(a5)
ffffffffc02018bc:	40a48533          	sub	a0,s1,a0
ffffffffc02018c0:	850d                	srai	a0,a0,0x3
ffffffffc02018c2:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02018c6:	4785                	li	a5,1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018c8:	00080a37          	lui	s4,0x80
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018cc:	0009b703          	ld	a4,0(s3)
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02018d0:	c09c                	sw	a5,0(s1)
ffffffffc02018d2:	57fd                	li	a5,-1
ffffffffc02018d4:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018d6:	9552                	add	a0,a0,s4
ffffffffc02018d8:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc02018da:	0532                	slli	a0,a0,0xc
ffffffffc02018dc:	08e7fd63          	bleu	a4,a5,ffffffffc0201976 <get_pte+0x1ca>
ffffffffc02018e0:	000ab783          	ld	a5,0(s5)
ffffffffc02018e4:	6605                	lui	a2,0x1
ffffffffc02018e6:	4581                	li	a1,0
ffffffffc02018e8:	953e                	add	a0,a0,a5
ffffffffc02018ea:	21f020ef          	jal	ra,ffffffffc0204308 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018ee:	000bb683          	ld	a3,0(s7)
ffffffffc02018f2:	40d486b3          	sub	a3,s1,a3
ffffffffc02018f6:	868d                	srai	a3,a3,0x3
ffffffffc02018f8:	036686b3          	mul	a3,a3,s6
ffffffffc02018fc:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02018fe:	06aa                	slli	a3,a3,0xa
ffffffffc0201900:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201904:	e014                	sd	a3,0(s0)
ffffffffc0201906:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020190a:	068a                	slli	a3,a3,0x2
ffffffffc020190c:	757d                	lui	a0,0xfffff
ffffffffc020190e:	8ee9                	and	a3,a3,a0
ffffffffc0201910:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201914:	04e7f563          	bleu	a4,a5,ffffffffc020195e <get_pte+0x1b2>
ffffffffc0201918:	000ab503          	ld	a0,0(s5)
ffffffffc020191c:	00c95793          	srli	a5,s2,0xc
ffffffffc0201920:	1ff7f793          	andi	a5,a5,511
ffffffffc0201924:	96aa                	add	a3,a3,a0
ffffffffc0201926:	00379513          	slli	a0,a5,0x3
ffffffffc020192a:	9536                	add	a0,a0,a3
}
ffffffffc020192c:	60a6                	ld	ra,72(sp)
ffffffffc020192e:	6406                	ld	s0,64(sp)
ffffffffc0201930:	74e2                	ld	s1,56(sp)
ffffffffc0201932:	7942                	ld	s2,48(sp)
ffffffffc0201934:	79a2                	ld	s3,40(sp)
ffffffffc0201936:	7a02                	ld	s4,32(sp)
ffffffffc0201938:	6ae2                	ld	s5,24(sp)
ffffffffc020193a:	6b42                	ld	s6,16(sp)
ffffffffc020193c:	6ba2                	ld	s7,8(sp)
ffffffffc020193e:	6161                	addi	sp,sp,80
ffffffffc0201940:	8082                	ret
            return NULL;
ffffffffc0201942:	4501                	li	a0,0
ffffffffc0201944:	b7e5                	j	ffffffffc020192c <get_pte+0x180>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201946:	00003617          	auipc	a2,0x3
ffffffffc020194a:	7d260613          	addi	a2,a2,2002 # ffffffffc0205118 <default_pmm_manager+0x50>
ffffffffc020194e:	10200593          	li	a1,258
ffffffffc0201952:	00003517          	auipc	a0,0x3
ffffffffc0201956:	7ee50513          	addi	a0,a0,2030 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc020195a:	a1bfe0ef          	jal	ra,ffffffffc0200374 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020195e:	00003617          	auipc	a2,0x3
ffffffffc0201962:	7ba60613          	addi	a2,a2,1978 # ffffffffc0205118 <default_pmm_manager+0x50>
ffffffffc0201966:	10f00593          	li	a1,271
ffffffffc020196a:	00003517          	auipc	a0,0x3
ffffffffc020196e:	7d650513          	addi	a0,a0,2006 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0201972:	a03fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201976:	86aa                	mv	a3,a0
ffffffffc0201978:	00003617          	auipc	a2,0x3
ffffffffc020197c:	7a060613          	addi	a2,a2,1952 # ffffffffc0205118 <default_pmm_manager+0x50>
ffffffffc0201980:	10b00593          	li	a1,267
ffffffffc0201984:	00003517          	auipc	a0,0x3
ffffffffc0201988:	7bc50513          	addi	a0,a0,1980 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc020198c:	9e9fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201990:	86aa                	mv	a3,a0
ffffffffc0201992:	00003617          	auipc	a2,0x3
ffffffffc0201996:	78660613          	addi	a2,a2,1926 # ffffffffc0205118 <default_pmm_manager+0x50>
ffffffffc020199a:	0ff00593          	li	a1,255
ffffffffc020199e:	00003517          	auipc	a0,0x3
ffffffffc02019a2:	7a250513          	addi	a0,a0,1954 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02019a6:	9cffe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02019aa <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02019aa:	1141                	addi	sp,sp,-16
ffffffffc02019ac:	e022                	sd	s0,0(sp)
ffffffffc02019ae:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019b0:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02019b2:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019b4:	df9ff0ef          	jal	ra,ffffffffc02017ac <get_pte>
    if (ptep_store != NULL) {
ffffffffc02019b8:	c011                	beqz	s0,ffffffffc02019bc <get_page+0x12>
        *ptep_store = ptep;
ffffffffc02019ba:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02019bc:	c521                	beqz	a0,ffffffffc0201a04 <get_page+0x5a>
ffffffffc02019be:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02019c0:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc02019c2:	0017f713          	andi	a4,a5,1
ffffffffc02019c6:	e709                	bnez	a4,ffffffffc02019d0 <get_page+0x26>
}
ffffffffc02019c8:	60a2                	ld	ra,8(sp)
ffffffffc02019ca:	6402                	ld	s0,0(sp)
ffffffffc02019cc:	0141                	addi	sp,sp,16
ffffffffc02019ce:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02019d0:	00010717          	auipc	a4,0x10
ffffffffc02019d4:	a8870713          	addi	a4,a4,-1400 # ffffffffc0211458 <npage>
ffffffffc02019d8:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02019da:	078a                	slli	a5,a5,0x2
ffffffffc02019dc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019de:	02e7f863          	bleu	a4,a5,ffffffffc0201a0e <get_page+0x64>
    return &pages[PPN(pa) - nbase];
ffffffffc02019e2:	fff80537          	lui	a0,0xfff80
ffffffffc02019e6:	97aa                	add	a5,a5,a0
ffffffffc02019e8:	00010697          	auipc	a3,0x10
ffffffffc02019ec:	ac068693          	addi	a3,a3,-1344 # ffffffffc02114a8 <pages>
ffffffffc02019f0:	6288                	ld	a0,0(a3)
ffffffffc02019f2:	60a2                	ld	ra,8(sp)
ffffffffc02019f4:	6402                	ld	s0,0(sp)
ffffffffc02019f6:	00379713          	slli	a4,a5,0x3
ffffffffc02019fa:	97ba                	add	a5,a5,a4
ffffffffc02019fc:	078e                	slli	a5,a5,0x3
ffffffffc02019fe:	953e                	add	a0,a0,a5
ffffffffc0201a00:	0141                	addi	sp,sp,16
ffffffffc0201a02:	8082                	ret
ffffffffc0201a04:	60a2                	ld	ra,8(sp)
ffffffffc0201a06:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0201a08:	4501                	li	a0,0
}
ffffffffc0201a0a:	0141                	addi	sp,sp,16
ffffffffc0201a0c:	8082                	ret
ffffffffc0201a0e:	c75ff0ef          	jal	ra,ffffffffc0201682 <pa2page.part.4>

ffffffffc0201a12 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201a12:	1141                	addi	sp,sp,-16
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201a14:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201a16:	e406                	sd	ra,8(sp)
ffffffffc0201a18:	e022                	sd	s0,0(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201a1a:	d93ff0ef          	jal	ra,ffffffffc02017ac <get_pte>
    if (ptep != NULL) {
ffffffffc0201a1e:	c511                	beqz	a0,ffffffffc0201a2a <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc0201a20:	611c                	ld	a5,0(a0)
ffffffffc0201a22:	842a                	mv	s0,a0
ffffffffc0201a24:	0017f713          	andi	a4,a5,1
ffffffffc0201a28:	e709                	bnez	a4,ffffffffc0201a32 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201a2a:	60a2                	ld	ra,8(sp)
ffffffffc0201a2c:	6402                	ld	s0,0(sp)
ffffffffc0201a2e:	0141                	addi	sp,sp,16
ffffffffc0201a30:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201a32:	00010717          	auipc	a4,0x10
ffffffffc0201a36:	a2670713          	addi	a4,a4,-1498 # ffffffffc0211458 <npage>
ffffffffc0201a3a:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a3c:	078a                	slli	a5,a5,0x2
ffffffffc0201a3e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a40:	04e7f063          	bleu	a4,a5,ffffffffc0201a80 <page_remove+0x6e>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a44:	fff80737          	lui	a4,0xfff80
ffffffffc0201a48:	97ba                	add	a5,a5,a4
ffffffffc0201a4a:	00010717          	auipc	a4,0x10
ffffffffc0201a4e:	a5e70713          	addi	a4,a4,-1442 # ffffffffc02114a8 <pages>
ffffffffc0201a52:	6308                	ld	a0,0(a4)
ffffffffc0201a54:	00379713          	slli	a4,a5,0x3
ffffffffc0201a58:	97ba                	add	a5,a5,a4
ffffffffc0201a5a:	078e                	slli	a5,a5,0x3
ffffffffc0201a5c:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201a5e:	411c                	lw	a5,0(a0)
ffffffffc0201a60:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201a64:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201a66:	cb09                	beqz	a4,ffffffffc0201a78 <page_remove+0x66>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201a68:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a6c:	12000073          	sfence.vma
}
ffffffffc0201a70:	60a2                	ld	ra,8(sp)
ffffffffc0201a72:	6402                	ld	s0,0(sp)
ffffffffc0201a74:	0141                	addi	sp,sp,16
ffffffffc0201a76:	8082                	ret
            free_page(page);
ffffffffc0201a78:	4585                	li	a1,1
ffffffffc0201a7a:	cadff0ef          	jal	ra,ffffffffc0201726 <free_pages>
ffffffffc0201a7e:	b7ed                	j	ffffffffc0201a68 <page_remove+0x56>
ffffffffc0201a80:	c03ff0ef          	jal	ra,ffffffffc0201682 <pa2page.part.4>

ffffffffc0201a84 <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a84:	7179                	addi	sp,sp,-48
ffffffffc0201a86:	87b2                	mv	a5,a2
ffffffffc0201a88:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a8a:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a8c:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a8e:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a90:	ec26                	sd	s1,24(sp)
ffffffffc0201a92:	f406                	sd	ra,40(sp)
ffffffffc0201a94:	e84a                	sd	s2,16(sp)
ffffffffc0201a96:	e44e                	sd	s3,8(sp)
ffffffffc0201a98:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a9a:	d13ff0ef          	jal	ra,ffffffffc02017ac <get_pte>
    if (ptep == NULL) {
ffffffffc0201a9e:	c945                	beqz	a0,ffffffffc0201b4e <page_insert+0xca>
    page->ref += 1;
ffffffffc0201aa0:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0201aa2:	611c                	ld	a5,0(a0)
ffffffffc0201aa4:	892a                	mv	s2,a0
ffffffffc0201aa6:	0016871b          	addiw	a4,a3,1
ffffffffc0201aaa:	c018                	sw	a4,0(s0)
ffffffffc0201aac:	0017f713          	andi	a4,a5,1
ffffffffc0201ab0:	e339                	bnez	a4,ffffffffc0201af6 <page_insert+0x72>
ffffffffc0201ab2:	00010797          	auipc	a5,0x10
ffffffffc0201ab6:	9f678793          	addi	a5,a5,-1546 # ffffffffc02114a8 <pages>
ffffffffc0201aba:	639c                	ld	a5,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201abc:	00003717          	auipc	a4,0x3
ffffffffc0201ac0:	25c70713          	addi	a4,a4,604 # ffffffffc0204d18 <commands+0x8b8>
ffffffffc0201ac4:	40f407b3          	sub	a5,s0,a5
ffffffffc0201ac8:	6300                	ld	s0,0(a4)
ffffffffc0201aca:	878d                	srai	a5,a5,0x3
ffffffffc0201acc:	000806b7          	lui	a3,0x80
ffffffffc0201ad0:	028787b3          	mul	a5,a5,s0
ffffffffc0201ad4:	97b6                	add	a5,a5,a3
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201ad6:	07aa                	slli	a5,a5,0xa
ffffffffc0201ad8:	8fc5                	or	a5,a5,s1
ffffffffc0201ada:	0017e793          	ori	a5,a5,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201ade:	00f93023          	sd	a5,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201ae2:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201ae6:	4501                	li	a0,0
}
ffffffffc0201ae8:	70a2                	ld	ra,40(sp)
ffffffffc0201aea:	7402                	ld	s0,32(sp)
ffffffffc0201aec:	64e2                	ld	s1,24(sp)
ffffffffc0201aee:	6942                	ld	s2,16(sp)
ffffffffc0201af0:	69a2                	ld	s3,8(sp)
ffffffffc0201af2:	6145                	addi	sp,sp,48
ffffffffc0201af4:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201af6:	00010717          	auipc	a4,0x10
ffffffffc0201afa:	96270713          	addi	a4,a4,-1694 # ffffffffc0211458 <npage>
ffffffffc0201afe:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201b00:	00279513          	slli	a0,a5,0x2
ffffffffc0201b04:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201b06:	04e57663          	bleu	a4,a0,ffffffffc0201b52 <page_insert+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b0a:	fff807b7          	lui	a5,0xfff80
ffffffffc0201b0e:	953e                	add	a0,a0,a5
ffffffffc0201b10:	00010997          	auipc	s3,0x10
ffffffffc0201b14:	99898993          	addi	s3,s3,-1640 # ffffffffc02114a8 <pages>
ffffffffc0201b18:	0009b783          	ld	a5,0(s3)
ffffffffc0201b1c:	00351713          	slli	a4,a0,0x3
ffffffffc0201b20:	953a                	add	a0,a0,a4
ffffffffc0201b22:	050e                	slli	a0,a0,0x3
ffffffffc0201b24:	953e                	add	a0,a0,a5
        if (p == page) {
ffffffffc0201b26:	00a40e63          	beq	s0,a0,ffffffffc0201b42 <page_insert+0xbe>
    page->ref -= 1;
ffffffffc0201b2a:	411c                	lw	a5,0(a0)
ffffffffc0201b2c:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201b30:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201b32:	cb11                	beqz	a4,ffffffffc0201b46 <page_insert+0xc2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201b34:	00093023          	sd	zero,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201b38:	12000073          	sfence.vma
ffffffffc0201b3c:	0009b783          	ld	a5,0(s3)
ffffffffc0201b40:	bfb5                	j	ffffffffc0201abc <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201b42:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201b44:	bfa5                	j	ffffffffc0201abc <page_insert+0x38>
            free_page(page);
ffffffffc0201b46:	4585                	li	a1,1
ffffffffc0201b48:	bdfff0ef          	jal	ra,ffffffffc0201726 <free_pages>
ffffffffc0201b4c:	b7e5                	j	ffffffffc0201b34 <page_insert+0xb0>
        return -E_NO_MEM;
ffffffffc0201b4e:	5571                	li	a0,-4
ffffffffc0201b50:	bf61                	j	ffffffffc0201ae8 <page_insert+0x64>
ffffffffc0201b52:	b31ff0ef          	jal	ra,ffffffffc0201682 <pa2page.part.4>

ffffffffc0201b56 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201b56:	00003797          	auipc	a5,0x3
ffffffffc0201b5a:	57278793          	addi	a5,a5,1394 # ffffffffc02050c8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b5e:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201b60:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b62:	00003517          	auipc	a0,0x3
ffffffffc0201b66:	67650513          	addi	a0,a0,1654 # ffffffffc02051d8 <default_pmm_manager+0x110>
void pmm_init(void) {
ffffffffc0201b6a:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b6c:	00010717          	auipc	a4,0x10
ffffffffc0201b70:	92f73223          	sd	a5,-1756(a4) # ffffffffc0211490 <pmm_manager>
void pmm_init(void) {
ffffffffc0201b74:	e8a2                	sd	s0,80(sp)
ffffffffc0201b76:	e4a6                	sd	s1,72(sp)
ffffffffc0201b78:	e0ca                	sd	s2,64(sp)
ffffffffc0201b7a:	fc4e                	sd	s3,56(sp)
ffffffffc0201b7c:	f852                	sd	s4,48(sp)
ffffffffc0201b7e:	f456                	sd	s5,40(sp)
ffffffffc0201b80:	f05a                	sd	s6,32(sp)
ffffffffc0201b82:	ec5e                	sd	s7,24(sp)
ffffffffc0201b84:	e862                	sd	s8,16(sp)
ffffffffc0201b86:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b88:	00010417          	auipc	s0,0x10
ffffffffc0201b8c:	90840413          	addi	s0,s0,-1784 # ffffffffc0211490 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b90:	d2efe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pmm_manager->init();
ffffffffc0201b94:	601c                	ld	a5,0(s0)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b96:	49c5                	li	s3,17
ffffffffc0201b98:	40100a13          	li	s4,1025
    pmm_manager->init();
ffffffffc0201b9c:	679c                	ld	a5,8(a5)
ffffffffc0201b9e:	00010497          	auipc	s1,0x10
ffffffffc0201ba2:	8ba48493          	addi	s1,s1,-1862 # ffffffffc0211458 <npage>
ffffffffc0201ba6:	00010917          	auipc	s2,0x10
ffffffffc0201baa:	90290913          	addi	s2,s2,-1790 # ffffffffc02114a8 <pages>
ffffffffc0201bae:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201bb0:	57f5                	li	a5,-3
ffffffffc0201bb2:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201bb4:	07e006b7          	lui	a3,0x7e00
ffffffffc0201bb8:	01b99613          	slli	a2,s3,0x1b
ffffffffc0201bbc:	015a1593          	slli	a1,s4,0x15
ffffffffc0201bc0:	00003517          	auipc	a0,0x3
ffffffffc0201bc4:	63050513          	addi	a0,a0,1584 # ffffffffc02051f0 <default_pmm_manager+0x128>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201bc8:	00010717          	auipc	a4,0x10
ffffffffc0201bcc:	8cf73823          	sd	a5,-1840(a4) # ffffffffc0211498 <va_pa_offset>
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201bd0:	ceefe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201bd4:	00003517          	auipc	a0,0x3
ffffffffc0201bd8:	64c50513          	addi	a0,a0,1612 # ffffffffc0205220 <default_pmm_manager+0x158>
ffffffffc0201bdc:	ce2fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201be0:	01b99693          	slli	a3,s3,0x1b
ffffffffc0201be4:	16fd                	addi	a3,a3,-1
ffffffffc0201be6:	015a1613          	slli	a2,s4,0x15
ffffffffc0201bea:	07e005b7          	lui	a1,0x7e00
ffffffffc0201bee:	00003517          	auipc	a0,0x3
ffffffffc0201bf2:	64a50513          	addi	a0,a0,1610 # ffffffffc0205238 <default_pmm_manager+0x170>
ffffffffc0201bf6:	cc8fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201bfa:	777d                	lui	a4,0xfffff
ffffffffc0201bfc:	00011797          	auipc	a5,0x11
ffffffffc0201c00:	99b78793          	addi	a5,a5,-1637 # ffffffffc0212597 <end+0xfff>
ffffffffc0201c04:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201c06:	00088737          	lui	a4,0x88
ffffffffc0201c0a:	00010697          	auipc	a3,0x10
ffffffffc0201c0e:	84e6b723          	sd	a4,-1970(a3) # ffffffffc0211458 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201c12:	00010717          	auipc	a4,0x10
ffffffffc0201c16:	88f73b23          	sd	a5,-1898(a4) # ffffffffc02114a8 <pages>
ffffffffc0201c1a:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201c1c:	4701                	li	a4,0
ffffffffc0201c1e:	4585                	li	a1,1
ffffffffc0201c20:	fff80637          	lui	a2,0xfff80
ffffffffc0201c24:	a019                	j	ffffffffc0201c2a <pmm_init+0xd4>
ffffffffc0201c26:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0201c2a:	97b6                	add	a5,a5,a3
ffffffffc0201c2c:	07a1                	addi	a5,a5,8
ffffffffc0201c2e:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201c32:	609c                	ld	a5,0(s1)
ffffffffc0201c34:	0705                	addi	a4,a4,1
ffffffffc0201c36:	04868693          	addi	a3,a3,72
ffffffffc0201c3a:	00c78533          	add	a0,a5,a2
ffffffffc0201c3e:	fea764e3          	bltu	a4,a0,ffffffffc0201c26 <pmm_init+0xd0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c42:	00093503          	ld	a0,0(s2)
ffffffffc0201c46:	00379693          	slli	a3,a5,0x3
ffffffffc0201c4a:	96be                	add	a3,a3,a5
ffffffffc0201c4c:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201c50:	972a                	add	a4,a4,a0
ffffffffc0201c52:	068e                	slli	a3,a3,0x3
ffffffffc0201c54:	96ba                	add	a3,a3,a4
ffffffffc0201c56:	c0200737          	lui	a4,0xc0200
ffffffffc0201c5a:	58e6ea63          	bltu	a3,a4,ffffffffc02021ee <pmm_init+0x698>
ffffffffc0201c5e:	00010997          	auipc	s3,0x10
ffffffffc0201c62:	83a98993          	addi	s3,s3,-1990 # ffffffffc0211498 <va_pa_offset>
ffffffffc0201c66:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201c6a:	45c5                	li	a1,17
ffffffffc0201c6c:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c6e:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201c70:	44b6ef63          	bltu	a3,a1,ffffffffc02020ce <pmm_init+0x578>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201c74:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c76:	0000f417          	auipc	s0,0xf
ffffffffc0201c7a:	7da40413          	addi	s0,s0,2010 # ffffffffc0211450 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201c7e:	7b9c                	ld	a5,48(a5)
ffffffffc0201c80:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201c82:	00003517          	auipc	a0,0x3
ffffffffc0201c86:	60650513          	addi	a0,a0,1542 # ffffffffc0205288 <default_pmm_manager+0x1c0>
ffffffffc0201c8a:	c34fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c8e:	00007697          	auipc	a3,0x7
ffffffffc0201c92:	37268693          	addi	a3,a3,882 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201c96:	0000f797          	auipc	a5,0xf
ffffffffc0201c9a:	7ad7bd23          	sd	a3,1978(a5) # ffffffffc0211450 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201c9e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201ca2:	0ef6ece3          	bltu	a3,a5,ffffffffc020259a <pmm_init+0xa44>
ffffffffc0201ca6:	0009b783          	ld	a5,0(s3)
ffffffffc0201caa:	8e9d                	sub	a3,a3,a5
ffffffffc0201cac:	0000f797          	auipc	a5,0xf
ffffffffc0201cb0:	7ed7ba23          	sd	a3,2036(a5) # ffffffffc02114a0 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0201cb4:	ab9ff0ef          	jal	ra,ffffffffc020176c <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201cb8:	6098                	ld	a4,0(s1)
ffffffffc0201cba:	c80007b7          	lui	a5,0xc8000
ffffffffc0201cbe:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0201cc0:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201cc2:	0ae7ece3          	bltu	a5,a4,ffffffffc020257a <pmm_init+0xa24>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201cc6:	6008                	ld	a0,0(s0)
ffffffffc0201cc8:	4c050363          	beqz	a0,ffffffffc020218e <pmm_init+0x638>
ffffffffc0201ccc:	6785                	lui	a5,0x1
ffffffffc0201cce:	17fd                	addi	a5,a5,-1
ffffffffc0201cd0:	8fe9                	and	a5,a5,a0
ffffffffc0201cd2:	2781                	sext.w	a5,a5
ffffffffc0201cd4:	4a079d63          	bnez	a5,ffffffffc020218e <pmm_init+0x638>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201cd8:	4601                	li	a2,0
ffffffffc0201cda:	4581                	li	a1,0
ffffffffc0201cdc:	ccfff0ef          	jal	ra,ffffffffc02019aa <get_page>
ffffffffc0201ce0:	4c051763          	bnez	a0,ffffffffc02021ae <pmm_init+0x658>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201ce4:	4505                	li	a0,1
ffffffffc0201ce6:	9b9ff0ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0201cea:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201cec:	6008                	ld	a0,0(s0)
ffffffffc0201cee:	4681                	li	a3,0
ffffffffc0201cf0:	4601                	li	a2,0
ffffffffc0201cf2:	85d6                	mv	a1,s5
ffffffffc0201cf4:	d91ff0ef          	jal	ra,ffffffffc0201a84 <page_insert>
ffffffffc0201cf8:	52051763          	bnez	a0,ffffffffc0202226 <pmm_init+0x6d0>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201cfc:	6008                	ld	a0,0(s0)
ffffffffc0201cfe:	4601                	li	a2,0
ffffffffc0201d00:	4581                	li	a1,0
ffffffffc0201d02:	aabff0ef          	jal	ra,ffffffffc02017ac <get_pte>
ffffffffc0201d06:	50050063          	beqz	a0,ffffffffc0202206 <pmm_init+0x6b0>
    assert(pte2page(*ptep) == p1);
ffffffffc0201d0a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201d0c:	0017f713          	andi	a4,a5,1
ffffffffc0201d10:	46070363          	beqz	a4,ffffffffc0202176 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201d14:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d16:	078a                	slli	a5,a5,0x2
ffffffffc0201d18:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d1a:	44c7f063          	bleu	a2,a5,ffffffffc020215a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d1e:	fff80737          	lui	a4,0xfff80
ffffffffc0201d22:	97ba                	add	a5,a5,a4
ffffffffc0201d24:	00379713          	slli	a4,a5,0x3
ffffffffc0201d28:	00093683          	ld	a3,0(s2)
ffffffffc0201d2c:	97ba                	add	a5,a5,a4
ffffffffc0201d2e:	078e                	slli	a5,a5,0x3
ffffffffc0201d30:	97b6                	add	a5,a5,a3
ffffffffc0201d32:	5efa9463          	bne	s5,a5,ffffffffc020231a <pmm_init+0x7c4>
    assert(page_ref(p1) == 1);
ffffffffc0201d36:	000aab83          	lw	s7,0(s5)
ffffffffc0201d3a:	4785                	li	a5,1
ffffffffc0201d3c:	5afb9f63          	bne	s7,a5,ffffffffc02022fa <pmm_init+0x7a4>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201d40:	6008                	ld	a0,0(s0)
ffffffffc0201d42:	76fd                	lui	a3,0xfffff
ffffffffc0201d44:	611c                	ld	a5,0(a0)
ffffffffc0201d46:	078a                	slli	a5,a5,0x2
ffffffffc0201d48:	8ff5                	and	a5,a5,a3
ffffffffc0201d4a:	00c7d713          	srli	a4,a5,0xc
ffffffffc0201d4e:	58c77963          	bleu	a2,a4,ffffffffc02022e0 <pmm_init+0x78a>
ffffffffc0201d52:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d56:	97e2                	add	a5,a5,s8
ffffffffc0201d58:	0007bb03          	ld	s6,0(a5) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0201d5c:	0b0a                	slli	s6,s6,0x2
ffffffffc0201d5e:	00db7b33          	and	s6,s6,a3
ffffffffc0201d62:	00cb5793          	srli	a5,s6,0xc
ffffffffc0201d66:	56c7f063          	bleu	a2,a5,ffffffffc02022c6 <pmm_init+0x770>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d6a:	4601                	li	a2,0
ffffffffc0201d6c:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d6e:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d70:	a3dff0ef          	jal	ra,ffffffffc02017ac <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d74:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d76:	53651863          	bne	a0,s6,ffffffffc02022a6 <pmm_init+0x750>

    p2 = alloc_page();
ffffffffc0201d7a:	4505                	li	a0,1
ffffffffc0201d7c:	923ff0ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0201d80:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201d82:	6008                	ld	a0,0(s0)
ffffffffc0201d84:	46d1                	li	a3,20
ffffffffc0201d86:	6605                	lui	a2,0x1
ffffffffc0201d88:	85da                	mv	a1,s6
ffffffffc0201d8a:	cfbff0ef          	jal	ra,ffffffffc0201a84 <page_insert>
ffffffffc0201d8e:	4e051c63          	bnez	a0,ffffffffc0202286 <pmm_init+0x730>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d92:	6008                	ld	a0,0(s0)
ffffffffc0201d94:	4601                	li	a2,0
ffffffffc0201d96:	6585                	lui	a1,0x1
ffffffffc0201d98:	a15ff0ef          	jal	ra,ffffffffc02017ac <get_pte>
ffffffffc0201d9c:	4c050563          	beqz	a0,ffffffffc0202266 <pmm_init+0x710>
    assert(*ptep & PTE_U);
ffffffffc0201da0:	611c                	ld	a5,0(a0)
ffffffffc0201da2:	0107f713          	andi	a4,a5,16
ffffffffc0201da6:	4a070063          	beqz	a4,ffffffffc0202246 <pmm_init+0x6f0>
    assert(*ptep & PTE_W);
ffffffffc0201daa:	8b91                	andi	a5,a5,4
ffffffffc0201dac:	66078763          	beqz	a5,ffffffffc020241a <pmm_init+0x8c4>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201db0:	6008                	ld	a0,0(s0)
ffffffffc0201db2:	611c                	ld	a5,0(a0)
ffffffffc0201db4:	8bc1                	andi	a5,a5,16
ffffffffc0201db6:	64078263          	beqz	a5,ffffffffc02023fa <pmm_init+0x8a4>
    assert(page_ref(p2) == 1);
ffffffffc0201dba:	000b2783          	lw	a5,0(s6)
ffffffffc0201dbe:	61779e63          	bne	a5,s7,ffffffffc02023da <pmm_init+0x884>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201dc2:	4681                	li	a3,0
ffffffffc0201dc4:	6605                	lui	a2,0x1
ffffffffc0201dc6:	85d6                	mv	a1,s5
ffffffffc0201dc8:	cbdff0ef          	jal	ra,ffffffffc0201a84 <page_insert>
ffffffffc0201dcc:	5e051763          	bnez	a0,ffffffffc02023ba <pmm_init+0x864>
    assert(page_ref(p1) == 2);
ffffffffc0201dd0:	000aa703          	lw	a4,0(s5)
ffffffffc0201dd4:	4789                	li	a5,2
ffffffffc0201dd6:	5cf71263          	bne	a4,a5,ffffffffc020239a <pmm_init+0x844>
    assert(page_ref(p2) == 0);
ffffffffc0201dda:	000b2783          	lw	a5,0(s6)
ffffffffc0201dde:	58079e63          	bnez	a5,ffffffffc020237a <pmm_init+0x824>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201de2:	6008                	ld	a0,0(s0)
ffffffffc0201de4:	4601                	li	a2,0
ffffffffc0201de6:	6585                	lui	a1,0x1
ffffffffc0201de8:	9c5ff0ef          	jal	ra,ffffffffc02017ac <get_pte>
ffffffffc0201dec:	56050763          	beqz	a0,ffffffffc020235a <pmm_init+0x804>
    assert(pte2page(*ptep) == p1);
ffffffffc0201df0:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201df2:	0016f793          	andi	a5,a3,1
ffffffffc0201df6:	38078063          	beqz	a5,ffffffffc0202176 <pmm_init+0x620>
    if (PPN(pa) >= npage) {
ffffffffc0201dfa:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201dfc:	00269793          	slli	a5,a3,0x2
ffffffffc0201e00:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e02:	34e7fc63          	bleu	a4,a5,ffffffffc020215a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e06:	fff80737          	lui	a4,0xfff80
ffffffffc0201e0a:	97ba                	add	a5,a5,a4
ffffffffc0201e0c:	00379713          	slli	a4,a5,0x3
ffffffffc0201e10:	00093603          	ld	a2,0(s2)
ffffffffc0201e14:	97ba                	add	a5,a5,a4
ffffffffc0201e16:	078e                	slli	a5,a5,0x3
ffffffffc0201e18:	97b2                	add	a5,a5,a2
ffffffffc0201e1a:	52fa9063          	bne	s5,a5,ffffffffc020233a <pmm_init+0x7e4>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201e1e:	8ac1                	andi	a3,a3,16
ffffffffc0201e20:	6e069d63          	bnez	a3,ffffffffc020251a <pmm_init+0x9c4>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201e24:	6008                	ld	a0,0(s0)
ffffffffc0201e26:	4581                	li	a1,0
ffffffffc0201e28:	bebff0ef          	jal	ra,ffffffffc0201a12 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201e2c:	000aa703          	lw	a4,0(s5)
ffffffffc0201e30:	4785                	li	a5,1
ffffffffc0201e32:	6cf71463          	bne	a4,a5,ffffffffc02024fa <pmm_init+0x9a4>
    assert(page_ref(p2) == 0);
ffffffffc0201e36:	000b2783          	lw	a5,0(s6)
ffffffffc0201e3a:	6a079063          	bnez	a5,ffffffffc02024da <pmm_init+0x984>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201e3e:	6008                	ld	a0,0(s0)
ffffffffc0201e40:	6585                	lui	a1,0x1
ffffffffc0201e42:	bd1ff0ef          	jal	ra,ffffffffc0201a12 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201e46:	000aa783          	lw	a5,0(s5)
ffffffffc0201e4a:	66079863          	bnez	a5,ffffffffc02024ba <pmm_init+0x964>
    assert(page_ref(p2) == 0);
ffffffffc0201e4e:	000b2783          	lw	a5,0(s6)
ffffffffc0201e52:	70079463          	bnez	a5,ffffffffc020255a <pmm_init+0xa04>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201e56:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201e5a:	608c                	ld	a1,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e5c:	000b3783          	ld	a5,0(s6)
ffffffffc0201e60:	078a                	slli	a5,a5,0x2
ffffffffc0201e62:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e64:	2eb7fb63          	bleu	a1,a5,ffffffffc020215a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e68:	fff80737          	lui	a4,0xfff80
ffffffffc0201e6c:	973e                	add	a4,a4,a5
ffffffffc0201e6e:	00371793          	slli	a5,a4,0x3
ffffffffc0201e72:	00093603          	ld	a2,0(s2)
ffffffffc0201e76:	97ba                	add	a5,a5,a4
ffffffffc0201e78:	078e                	slli	a5,a5,0x3
ffffffffc0201e7a:	00f60733          	add	a4,a2,a5
ffffffffc0201e7e:	4314                	lw	a3,0(a4)
ffffffffc0201e80:	4705                	li	a4,1
ffffffffc0201e82:	6ae69c63          	bne	a3,a4,ffffffffc020253a <pmm_init+0x9e4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e86:	00003a97          	auipc	s5,0x3
ffffffffc0201e8a:	e92a8a93          	addi	s5,s5,-366 # ffffffffc0204d18 <commands+0x8b8>
ffffffffc0201e8e:	000ab703          	ld	a4,0(s5)
ffffffffc0201e92:	4037d693          	srai	a3,a5,0x3
ffffffffc0201e96:	00080bb7          	lui	s7,0x80
ffffffffc0201e9a:	02e686b3          	mul	a3,a3,a4
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e9e:	577d                	li	a4,-1
ffffffffc0201ea0:	8331                	srli	a4,a4,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201ea2:	96de                	add	a3,a3,s7
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ea4:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ea6:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ea8:	2ab77b63          	bleu	a1,a4,ffffffffc020215e <pmm_init+0x608>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201eac:	0009b783          	ld	a5,0(s3)
ffffffffc0201eb0:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201eb2:	629c                	ld	a5,0(a3)
ffffffffc0201eb4:	078a                	slli	a5,a5,0x2
ffffffffc0201eb6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201eb8:	2ab7f163          	bleu	a1,a5,ffffffffc020215a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ebc:	417787b3          	sub	a5,a5,s7
ffffffffc0201ec0:	00379513          	slli	a0,a5,0x3
ffffffffc0201ec4:	97aa                	add	a5,a5,a0
ffffffffc0201ec6:	00379513          	slli	a0,a5,0x3
ffffffffc0201eca:	9532                	add	a0,a0,a2
ffffffffc0201ecc:	4585                	li	a1,1
ffffffffc0201ece:	859ff0ef          	jal	ra,ffffffffc0201726 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ed2:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201ed6:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ed8:	050a                	slli	a0,a0,0x2
ffffffffc0201eda:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201edc:	26f57f63          	bleu	a5,a0,ffffffffc020215a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ee0:	417507b3          	sub	a5,a0,s7
ffffffffc0201ee4:	00379513          	slli	a0,a5,0x3
ffffffffc0201ee8:	00093703          	ld	a4,0(s2)
ffffffffc0201eec:	953e                	add	a0,a0,a5
ffffffffc0201eee:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0201ef0:	4585                	li	a1,1
ffffffffc0201ef2:	953a                	add	a0,a0,a4
ffffffffc0201ef4:	833ff0ef          	jal	ra,ffffffffc0201726 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201ef8:	601c                	ld	a5,0(s0)
ffffffffc0201efa:	0007b023          	sd	zero,0(a5)

    assert(nr_free_store==nr_free_pages());
ffffffffc0201efe:	86fff0ef          	jal	ra,ffffffffc020176c <nr_free_pages>
ffffffffc0201f02:	2caa1663          	bne	s4,a0,ffffffffc02021ce <pmm_init+0x678>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201f06:	00003517          	auipc	a0,0x3
ffffffffc0201f0a:	69250513          	addi	a0,a0,1682 # ffffffffc0205598 <default_pmm_manager+0x4d0>
ffffffffc0201f0e:	9b0fe0ef          	jal	ra,ffffffffc02000be <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0201f12:	85bff0ef          	jal	ra,ffffffffc020176c <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f16:	6098                	ld	a4,0(s1)
ffffffffc0201f18:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0201f1c:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f1e:	00c71693          	slli	a3,a4,0xc
ffffffffc0201f22:	1cd7fd63          	bleu	a3,a5,ffffffffc02020fc <pmm_init+0x5a6>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f26:	83b1                	srli	a5,a5,0xc
ffffffffc0201f28:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f2a:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f2e:	1ce7f963          	bleu	a4,a5,ffffffffc0202100 <pmm_init+0x5aa>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f32:	7c7d                	lui	s8,0xfffff
ffffffffc0201f34:	6b85                	lui	s7,0x1
ffffffffc0201f36:	a029                	j	ffffffffc0201f40 <pmm_init+0x3ea>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201f38:	00ca5713          	srli	a4,s4,0xc
ffffffffc0201f3c:	1cf77263          	bleu	a5,a4,ffffffffc0202100 <pmm_init+0x5aa>
ffffffffc0201f40:	0009b583          	ld	a1,0(s3)
ffffffffc0201f44:	4601                	li	a2,0
ffffffffc0201f46:	95d2                	add	a1,a1,s4
ffffffffc0201f48:	865ff0ef          	jal	ra,ffffffffc02017ac <get_pte>
ffffffffc0201f4c:	1c050763          	beqz	a0,ffffffffc020211a <pmm_init+0x5c4>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201f50:	611c                	ld	a5,0(a0)
ffffffffc0201f52:	078a                	slli	a5,a5,0x2
ffffffffc0201f54:	0187f7b3          	and	a5,a5,s8
ffffffffc0201f58:	1f479163          	bne	a5,s4,ffffffffc020213a <pmm_init+0x5e4>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201f5c:	609c                	ld	a5,0(s1)
ffffffffc0201f5e:	9a5e                	add	s4,s4,s7
ffffffffc0201f60:	6008                	ld	a0,0(s0)
ffffffffc0201f62:	00c79713          	slli	a4,a5,0xc
ffffffffc0201f66:	fcea69e3          	bltu	s4,a4,ffffffffc0201f38 <pmm_init+0x3e2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201f6a:	611c                	ld	a5,0(a0)
ffffffffc0201f6c:	6a079363          	bnez	a5,ffffffffc0202612 <pmm_init+0xabc>

    struct Page *p;
    p = alloc_page();
ffffffffc0201f70:	4505                	li	a0,1
ffffffffc0201f72:	f2cff0ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0201f76:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201f78:	6008                	ld	a0,0(s0)
ffffffffc0201f7a:	4699                	li	a3,6
ffffffffc0201f7c:	10000613          	li	a2,256
ffffffffc0201f80:	85d2                	mv	a1,s4
ffffffffc0201f82:	b03ff0ef          	jal	ra,ffffffffc0201a84 <page_insert>
ffffffffc0201f86:	66051663          	bnez	a0,ffffffffc02025f2 <pmm_init+0xa9c>
    assert(page_ref(p) == 1);
ffffffffc0201f8a:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc0201f8e:	4785                	li	a5,1
ffffffffc0201f90:	64f71163          	bne	a4,a5,ffffffffc02025d2 <pmm_init+0xa7c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201f94:	6008                	ld	a0,0(s0)
ffffffffc0201f96:	6b85                	lui	s7,0x1
ffffffffc0201f98:	4699                	li	a3,6
ffffffffc0201f9a:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0201f9e:	85d2                	mv	a1,s4
ffffffffc0201fa0:	ae5ff0ef          	jal	ra,ffffffffc0201a84 <page_insert>
ffffffffc0201fa4:	60051763          	bnez	a0,ffffffffc02025b2 <pmm_init+0xa5c>
    assert(page_ref(p) == 2);
ffffffffc0201fa8:	000a2703          	lw	a4,0(s4)
ffffffffc0201fac:	4789                	li	a5,2
ffffffffc0201fae:	4ef71663          	bne	a4,a5,ffffffffc020249a <pmm_init+0x944>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201fb2:	00003597          	auipc	a1,0x3
ffffffffc0201fb6:	71e58593          	addi	a1,a1,1822 # ffffffffc02056d0 <default_pmm_manager+0x608>
ffffffffc0201fba:	10000513          	li	a0,256
ffffffffc0201fbe:	2f0020ef          	jal	ra,ffffffffc02042ae <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201fc2:	100b8593          	addi	a1,s7,256
ffffffffc0201fc6:	10000513          	li	a0,256
ffffffffc0201fca:	2f6020ef          	jal	ra,ffffffffc02042c0 <strcmp>
ffffffffc0201fce:	4a051663          	bnez	a0,ffffffffc020247a <pmm_init+0x924>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fd2:	00093683          	ld	a3,0(s2)
ffffffffc0201fd6:	000abc83          	ld	s9,0(s5)
ffffffffc0201fda:	00080c37          	lui	s8,0x80
ffffffffc0201fde:	40da06b3          	sub	a3,s4,a3
ffffffffc0201fe2:	868d                	srai	a3,a3,0x3
ffffffffc0201fe4:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fe8:	5afd                	li	s5,-1
ffffffffc0201fea:	609c                	ld	a5,0(s1)
ffffffffc0201fec:	00cada93          	srli	s5,s5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201ff0:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ff2:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201ff6:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201ff8:	16f77363          	bleu	a5,a4,ffffffffc020215e <pmm_init+0x608>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201ffc:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202000:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202004:	96be                	add	a3,a3,a5
ffffffffc0202006:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fdedb68>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020200a:	260020ef          	jal	ra,ffffffffc020426a <strlen>
ffffffffc020200e:	44051663          	bnez	a0,ffffffffc020245a <pmm_init+0x904>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202012:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202016:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202018:	000bb783          	ld	a5,0(s7)
ffffffffc020201c:	078a                	slli	a5,a5,0x2
ffffffffc020201e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202020:	12e7fd63          	bleu	a4,a5,ffffffffc020215a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0202024:	418787b3          	sub	a5,a5,s8
ffffffffc0202028:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020202c:	96be                	add	a3,a3,a5
ffffffffc020202e:	039686b3          	mul	a3,a3,s9
ffffffffc0202032:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202034:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0202038:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020203a:	12eaf263          	bleu	a4,s5,ffffffffc020215e <pmm_init+0x608>
ffffffffc020203e:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202042:	4585                	li	a1,1
ffffffffc0202044:	8552                	mv	a0,s4
ffffffffc0202046:	99b6                	add	s3,s3,a3
ffffffffc0202048:	edeff0ef          	jal	ra,ffffffffc0201726 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020204c:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202050:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202052:	078a                	slli	a5,a5,0x2
ffffffffc0202054:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202056:	10e7f263          	bleu	a4,a5,ffffffffc020215a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc020205a:	fff809b7          	lui	s3,0xfff80
ffffffffc020205e:	97ce                	add	a5,a5,s3
ffffffffc0202060:	00379513          	slli	a0,a5,0x3
ffffffffc0202064:	00093703          	ld	a4,0(s2)
ffffffffc0202068:	97aa                	add	a5,a5,a0
ffffffffc020206a:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc020206e:	953a                	add	a0,a0,a4
ffffffffc0202070:	4585                	li	a1,1
ffffffffc0202072:	eb4ff0ef          	jal	ra,ffffffffc0201726 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202076:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc020207a:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020207c:	050a                	slli	a0,a0,0x2
ffffffffc020207e:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202080:	0cf57d63          	bleu	a5,a0,ffffffffc020215a <pmm_init+0x604>
    return &pages[PPN(pa) - nbase];
ffffffffc0202084:	013507b3          	add	a5,a0,s3
ffffffffc0202088:	00379513          	slli	a0,a5,0x3
ffffffffc020208c:	00093703          	ld	a4,0(s2)
ffffffffc0202090:	953e                	add	a0,a0,a5
ffffffffc0202092:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0202094:	4585                	li	a1,1
ffffffffc0202096:	953a                	add	a0,a0,a4
ffffffffc0202098:	e8eff0ef          	jal	ra,ffffffffc0201726 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020209c:	601c                	ld	a5,0(s0)
ffffffffc020209e:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>

    assert(nr_free_store==nr_free_pages());
ffffffffc02020a2:	ecaff0ef          	jal	ra,ffffffffc020176c <nr_free_pages>
ffffffffc02020a6:	38ab1a63          	bne	s6,a0,ffffffffc020243a <pmm_init+0x8e4>
}
ffffffffc02020aa:	6446                	ld	s0,80(sp)
ffffffffc02020ac:	60e6                	ld	ra,88(sp)
ffffffffc02020ae:	64a6                	ld	s1,72(sp)
ffffffffc02020b0:	6906                	ld	s2,64(sp)
ffffffffc02020b2:	79e2                	ld	s3,56(sp)
ffffffffc02020b4:	7a42                	ld	s4,48(sp)
ffffffffc02020b6:	7aa2                	ld	s5,40(sp)
ffffffffc02020b8:	7b02                	ld	s6,32(sp)
ffffffffc02020ba:	6be2                	ld	s7,24(sp)
ffffffffc02020bc:	6c42                	ld	s8,16(sp)
ffffffffc02020be:	6ca2                	ld	s9,8(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020c0:	00003517          	auipc	a0,0x3
ffffffffc02020c4:	68850513          	addi	a0,a0,1672 # ffffffffc0205748 <default_pmm_manager+0x680>
}
ffffffffc02020c8:	6125                	addi	sp,sp,96
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02020ca:	ff5fd06f          	j	ffffffffc02000be <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02020ce:	6705                	lui	a4,0x1
ffffffffc02020d0:	177d                	addi	a4,a4,-1
ffffffffc02020d2:	96ba                	add	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc02020d4:	00c6d713          	srli	a4,a3,0xc
ffffffffc02020d8:	08f77163          	bleu	a5,a4,ffffffffc020215a <pmm_init+0x604>
    pmm_manager->init_memmap(base, n);
ffffffffc02020dc:	00043803          	ld	a6,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc02020e0:	9732                	add	a4,a4,a2
ffffffffc02020e2:	00371793          	slli	a5,a4,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020e6:	767d                	lui	a2,0xfffff
ffffffffc02020e8:	8ef1                	and	a3,a3,a2
ffffffffc02020ea:	97ba                	add	a5,a5,a4
    pmm_manager->init_memmap(base, n);
ffffffffc02020ec:	01083703          	ld	a4,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02020f0:	8d95                	sub	a1,a1,a3
ffffffffc02020f2:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02020f4:	81b1                	srli	a1,a1,0xc
ffffffffc02020f6:	953e                	add	a0,a0,a5
ffffffffc02020f8:	9702                	jalr	a4
ffffffffc02020fa:	bead                	j	ffffffffc0201c74 <pmm_init+0x11e>
ffffffffc02020fc:	6008                	ld	a0,0(s0)
ffffffffc02020fe:	b5b5                	j	ffffffffc0201f6a <pmm_init+0x414>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202100:	86d2                	mv	a3,s4
ffffffffc0202102:	00003617          	auipc	a2,0x3
ffffffffc0202106:	01660613          	addi	a2,a2,22 # ffffffffc0205118 <default_pmm_manager+0x50>
ffffffffc020210a:	1cd00593          	li	a1,461
ffffffffc020210e:	00003517          	auipc	a0,0x3
ffffffffc0202112:	03250513          	addi	a0,a0,50 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202116:	a5efe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020211a:	00003697          	auipc	a3,0x3
ffffffffc020211e:	49e68693          	addi	a3,a3,1182 # ffffffffc02055b8 <default_pmm_manager+0x4f0>
ffffffffc0202122:	00003617          	auipc	a2,0x3
ffffffffc0202126:	c0e60613          	addi	a2,a2,-1010 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020212a:	1cd00593          	li	a1,461
ffffffffc020212e:	00003517          	auipc	a0,0x3
ffffffffc0202132:	01250513          	addi	a0,a0,18 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202136:	a3efe0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020213a:	00003697          	auipc	a3,0x3
ffffffffc020213e:	4be68693          	addi	a3,a3,1214 # ffffffffc02055f8 <default_pmm_manager+0x530>
ffffffffc0202142:	00003617          	auipc	a2,0x3
ffffffffc0202146:	bee60613          	addi	a2,a2,-1042 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020214a:	1ce00593          	li	a1,462
ffffffffc020214e:	00003517          	auipc	a0,0x3
ffffffffc0202152:	ff250513          	addi	a0,a0,-14 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202156:	a1efe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020215a:	d28ff0ef          	jal	ra,ffffffffc0201682 <pa2page.part.4>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020215e:	00003617          	auipc	a2,0x3
ffffffffc0202162:	fba60613          	addi	a2,a2,-70 # ffffffffc0205118 <default_pmm_manager+0x50>
ffffffffc0202166:	06a00593          	li	a1,106
ffffffffc020216a:	00003517          	auipc	a0,0x3
ffffffffc020216e:	04650513          	addi	a0,a0,70 # ffffffffc02051b0 <default_pmm_manager+0xe8>
ffffffffc0202172:	a02fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202176:	00003617          	auipc	a2,0x3
ffffffffc020217a:	21260613          	addi	a2,a2,530 # ffffffffc0205388 <default_pmm_manager+0x2c0>
ffffffffc020217e:	07000593          	li	a1,112
ffffffffc0202182:	00003517          	auipc	a0,0x3
ffffffffc0202186:	02e50513          	addi	a0,a0,46 # ffffffffc02051b0 <default_pmm_manager+0xe8>
ffffffffc020218a:	9eafe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020218e:	00003697          	auipc	a3,0x3
ffffffffc0202192:	13a68693          	addi	a3,a3,314 # ffffffffc02052c8 <default_pmm_manager+0x200>
ffffffffc0202196:	00003617          	auipc	a2,0x3
ffffffffc020219a:	b9a60613          	addi	a2,a2,-1126 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020219e:	19300593          	li	a1,403
ffffffffc02021a2:	00003517          	auipc	a0,0x3
ffffffffc02021a6:	f9e50513          	addi	a0,a0,-98 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02021aa:	9cafe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02021ae:	00003697          	auipc	a3,0x3
ffffffffc02021b2:	15268693          	addi	a3,a3,338 # ffffffffc0205300 <default_pmm_manager+0x238>
ffffffffc02021b6:	00003617          	auipc	a2,0x3
ffffffffc02021ba:	b7a60613          	addi	a2,a2,-1158 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02021be:	19400593          	li	a1,404
ffffffffc02021c2:	00003517          	auipc	a0,0x3
ffffffffc02021c6:	f7e50513          	addi	a0,a0,-130 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02021ca:	9aafe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02021ce:	00003697          	auipc	a3,0x3
ffffffffc02021d2:	3aa68693          	addi	a3,a3,938 # ffffffffc0205578 <default_pmm_manager+0x4b0>
ffffffffc02021d6:	00003617          	auipc	a2,0x3
ffffffffc02021da:	b5a60613          	addi	a2,a2,-1190 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02021de:	1c000593          	li	a1,448
ffffffffc02021e2:	00003517          	auipc	a0,0x3
ffffffffc02021e6:	f5e50513          	addi	a0,a0,-162 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02021ea:	98afe0ef          	jal	ra,ffffffffc0200374 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02021ee:	00003617          	auipc	a2,0x3
ffffffffc02021f2:	07260613          	addi	a2,a2,114 # ffffffffc0205260 <default_pmm_manager+0x198>
ffffffffc02021f6:	07700593          	li	a1,119
ffffffffc02021fa:	00003517          	auipc	a0,0x3
ffffffffc02021fe:	f4650513          	addi	a0,a0,-186 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202202:	972fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202206:	00003697          	auipc	a3,0x3
ffffffffc020220a:	15268693          	addi	a3,a3,338 # ffffffffc0205358 <default_pmm_manager+0x290>
ffffffffc020220e:	00003617          	auipc	a2,0x3
ffffffffc0202212:	b2260613          	addi	a2,a2,-1246 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202216:	19a00593          	li	a1,410
ffffffffc020221a:	00003517          	auipc	a0,0x3
ffffffffc020221e:	f2650513          	addi	a0,a0,-218 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202222:	952fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202226:	00003697          	auipc	a3,0x3
ffffffffc020222a:	10268693          	addi	a3,a3,258 # ffffffffc0205328 <default_pmm_manager+0x260>
ffffffffc020222e:	00003617          	auipc	a2,0x3
ffffffffc0202232:	b0260613          	addi	a2,a2,-1278 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202236:	19800593          	li	a1,408
ffffffffc020223a:	00003517          	auipc	a0,0x3
ffffffffc020223e:	f0650513          	addi	a0,a0,-250 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202242:	932fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202246:	00003697          	auipc	a3,0x3
ffffffffc020224a:	22a68693          	addi	a3,a3,554 # ffffffffc0205470 <default_pmm_manager+0x3a8>
ffffffffc020224e:	00003617          	auipc	a2,0x3
ffffffffc0202252:	ae260613          	addi	a2,a2,-1310 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202256:	1a500593          	li	a1,421
ffffffffc020225a:	00003517          	auipc	a0,0x3
ffffffffc020225e:	ee650513          	addi	a0,a0,-282 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202262:	912fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202266:	00003697          	auipc	a3,0x3
ffffffffc020226a:	1da68693          	addi	a3,a3,474 # ffffffffc0205440 <default_pmm_manager+0x378>
ffffffffc020226e:	00003617          	auipc	a2,0x3
ffffffffc0202272:	ac260613          	addi	a2,a2,-1342 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202276:	1a400593          	li	a1,420
ffffffffc020227a:	00003517          	auipc	a0,0x3
ffffffffc020227e:	ec650513          	addi	a0,a0,-314 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202282:	8f2fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202286:	00003697          	auipc	a3,0x3
ffffffffc020228a:	18268693          	addi	a3,a3,386 # ffffffffc0205408 <default_pmm_manager+0x340>
ffffffffc020228e:	00003617          	auipc	a2,0x3
ffffffffc0202292:	aa260613          	addi	a2,a2,-1374 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202296:	1a300593          	li	a1,419
ffffffffc020229a:	00003517          	auipc	a0,0x3
ffffffffc020229e:	ea650513          	addi	a0,a0,-346 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02022a2:	8d2fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc02022a6:	00003697          	auipc	a3,0x3
ffffffffc02022aa:	13a68693          	addi	a3,a3,314 # ffffffffc02053e0 <default_pmm_manager+0x318>
ffffffffc02022ae:	00003617          	auipc	a2,0x3
ffffffffc02022b2:	a8260613          	addi	a2,a2,-1406 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02022b6:	1a000593          	li	a1,416
ffffffffc02022ba:	00003517          	auipc	a0,0x3
ffffffffc02022be:	e8650513          	addi	a0,a0,-378 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02022c2:	8b2fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02022c6:	86da                	mv	a3,s6
ffffffffc02022c8:	00003617          	auipc	a2,0x3
ffffffffc02022cc:	e5060613          	addi	a2,a2,-432 # ffffffffc0205118 <default_pmm_manager+0x50>
ffffffffc02022d0:	19f00593          	li	a1,415
ffffffffc02022d4:	00003517          	auipc	a0,0x3
ffffffffc02022d8:	e6c50513          	addi	a0,a0,-404 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02022dc:	898fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02022e0:	86be                	mv	a3,a5
ffffffffc02022e2:	00003617          	auipc	a2,0x3
ffffffffc02022e6:	e3660613          	addi	a2,a2,-458 # ffffffffc0205118 <default_pmm_manager+0x50>
ffffffffc02022ea:	19e00593          	li	a1,414
ffffffffc02022ee:	00003517          	auipc	a0,0x3
ffffffffc02022f2:	e5250513          	addi	a0,a0,-430 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02022f6:	87efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02022fa:	00003697          	auipc	a3,0x3
ffffffffc02022fe:	0ce68693          	addi	a3,a3,206 # ffffffffc02053c8 <default_pmm_manager+0x300>
ffffffffc0202302:	00003617          	auipc	a2,0x3
ffffffffc0202306:	a2e60613          	addi	a2,a2,-1490 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020230a:	19c00593          	li	a1,412
ffffffffc020230e:	00003517          	auipc	a0,0x3
ffffffffc0202312:	e3250513          	addi	a0,a0,-462 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202316:	85efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020231a:	00003697          	auipc	a3,0x3
ffffffffc020231e:	09668693          	addi	a3,a3,150 # ffffffffc02053b0 <default_pmm_manager+0x2e8>
ffffffffc0202322:	00003617          	auipc	a2,0x3
ffffffffc0202326:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020232a:	19b00593          	li	a1,411
ffffffffc020232e:	00003517          	auipc	a0,0x3
ffffffffc0202332:	e1250513          	addi	a0,a0,-494 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202336:	83efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020233a:	00003697          	auipc	a3,0x3
ffffffffc020233e:	07668693          	addi	a3,a3,118 # ffffffffc02053b0 <default_pmm_manager+0x2e8>
ffffffffc0202342:	00003617          	auipc	a2,0x3
ffffffffc0202346:	9ee60613          	addi	a2,a2,-1554 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020234a:	1ae00593          	li	a1,430
ffffffffc020234e:	00003517          	auipc	a0,0x3
ffffffffc0202352:	df250513          	addi	a0,a0,-526 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202356:	81efe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc020235a:	00003697          	auipc	a3,0x3
ffffffffc020235e:	0e668693          	addi	a3,a3,230 # ffffffffc0205440 <default_pmm_manager+0x378>
ffffffffc0202362:	00003617          	auipc	a2,0x3
ffffffffc0202366:	9ce60613          	addi	a2,a2,-1586 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020236a:	1ad00593          	li	a1,429
ffffffffc020236e:	00003517          	auipc	a0,0x3
ffffffffc0202372:	dd250513          	addi	a0,a0,-558 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202376:	ffffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020237a:	00003697          	auipc	a3,0x3
ffffffffc020237e:	18e68693          	addi	a3,a3,398 # ffffffffc0205508 <default_pmm_manager+0x440>
ffffffffc0202382:	00003617          	auipc	a2,0x3
ffffffffc0202386:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020238a:	1ac00593          	li	a1,428
ffffffffc020238e:	00003517          	auipc	a0,0x3
ffffffffc0202392:	db250513          	addi	a0,a0,-590 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202396:	fdffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020239a:	00003697          	auipc	a3,0x3
ffffffffc020239e:	15668693          	addi	a3,a3,342 # ffffffffc02054f0 <default_pmm_manager+0x428>
ffffffffc02023a2:	00003617          	auipc	a2,0x3
ffffffffc02023a6:	98e60613          	addi	a2,a2,-1650 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02023aa:	1ab00593          	li	a1,427
ffffffffc02023ae:	00003517          	auipc	a0,0x3
ffffffffc02023b2:	d9250513          	addi	a0,a0,-622 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02023b6:	fbffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02023ba:	00003697          	auipc	a3,0x3
ffffffffc02023be:	10668693          	addi	a3,a3,262 # ffffffffc02054c0 <default_pmm_manager+0x3f8>
ffffffffc02023c2:	00003617          	auipc	a2,0x3
ffffffffc02023c6:	96e60613          	addi	a2,a2,-1682 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02023ca:	1aa00593          	li	a1,426
ffffffffc02023ce:	00003517          	auipc	a0,0x3
ffffffffc02023d2:	d7250513          	addi	a0,a0,-654 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02023d6:	f9ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02023da:	00003697          	auipc	a3,0x3
ffffffffc02023de:	0ce68693          	addi	a3,a3,206 # ffffffffc02054a8 <default_pmm_manager+0x3e0>
ffffffffc02023e2:	00003617          	auipc	a2,0x3
ffffffffc02023e6:	94e60613          	addi	a2,a2,-1714 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02023ea:	1a800593          	li	a1,424
ffffffffc02023ee:	00003517          	auipc	a0,0x3
ffffffffc02023f2:	d5250513          	addi	a0,a0,-686 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02023f6:	f7ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02023fa:	00003697          	auipc	a3,0x3
ffffffffc02023fe:	09668693          	addi	a3,a3,150 # ffffffffc0205490 <default_pmm_manager+0x3c8>
ffffffffc0202402:	00003617          	auipc	a2,0x3
ffffffffc0202406:	92e60613          	addi	a2,a2,-1746 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020240a:	1a700593          	li	a1,423
ffffffffc020240e:	00003517          	auipc	a0,0x3
ffffffffc0202412:	d3250513          	addi	a0,a0,-718 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202416:	f5ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_W);
ffffffffc020241a:	00003697          	auipc	a3,0x3
ffffffffc020241e:	06668693          	addi	a3,a3,102 # ffffffffc0205480 <default_pmm_manager+0x3b8>
ffffffffc0202422:	00003617          	auipc	a2,0x3
ffffffffc0202426:	90e60613          	addi	a2,a2,-1778 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020242a:	1a600593          	li	a1,422
ffffffffc020242e:	00003517          	auipc	a0,0x3
ffffffffc0202432:	d1250513          	addi	a0,a0,-750 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202436:	f3ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020243a:	00003697          	auipc	a3,0x3
ffffffffc020243e:	13e68693          	addi	a3,a3,318 # ffffffffc0205578 <default_pmm_manager+0x4b0>
ffffffffc0202442:	00003617          	auipc	a2,0x3
ffffffffc0202446:	8ee60613          	addi	a2,a2,-1810 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020244a:	1e800593          	li	a1,488
ffffffffc020244e:	00003517          	auipc	a0,0x3
ffffffffc0202452:	cf250513          	addi	a0,a0,-782 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202456:	f1ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020245a:	00003697          	auipc	a3,0x3
ffffffffc020245e:	2c668693          	addi	a3,a3,710 # ffffffffc0205720 <default_pmm_manager+0x658>
ffffffffc0202462:	00003617          	auipc	a2,0x3
ffffffffc0202466:	8ce60613          	addi	a2,a2,-1842 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020246a:	1e000593          	li	a1,480
ffffffffc020246e:	00003517          	auipc	a0,0x3
ffffffffc0202472:	cd250513          	addi	a0,a0,-814 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202476:	efffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020247a:	00003697          	auipc	a3,0x3
ffffffffc020247e:	26e68693          	addi	a3,a3,622 # ffffffffc02056e8 <default_pmm_manager+0x620>
ffffffffc0202482:	00003617          	auipc	a2,0x3
ffffffffc0202486:	8ae60613          	addi	a2,a2,-1874 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020248a:	1dd00593          	li	a1,477
ffffffffc020248e:	00003517          	auipc	a0,0x3
ffffffffc0202492:	cb250513          	addi	a0,a0,-846 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202496:	edffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020249a:	00003697          	auipc	a3,0x3
ffffffffc020249e:	21e68693          	addi	a3,a3,542 # ffffffffc02056b8 <default_pmm_manager+0x5f0>
ffffffffc02024a2:	00003617          	auipc	a2,0x3
ffffffffc02024a6:	88e60613          	addi	a2,a2,-1906 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02024aa:	1d900593          	li	a1,473
ffffffffc02024ae:	00003517          	auipc	a0,0x3
ffffffffc02024b2:	c9250513          	addi	a0,a0,-878 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02024b6:	ebffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02024ba:	00003697          	auipc	a3,0x3
ffffffffc02024be:	07e68693          	addi	a3,a3,126 # ffffffffc0205538 <default_pmm_manager+0x470>
ffffffffc02024c2:	00003617          	auipc	a2,0x3
ffffffffc02024c6:	86e60613          	addi	a2,a2,-1938 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02024ca:	1b600593          	li	a1,438
ffffffffc02024ce:	00003517          	auipc	a0,0x3
ffffffffc02024d2:	c7250513          	addi	a0,a0,-910 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02024d6:	e9ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02024da:	00003697          	auipc	a3,0x3
ffffffffc02024de:	02e68693          	addi	a3,a3,46 # ffffffffc0205508 <default_pmm_manager+0x440>
ffffffffc02024e2:	00003617          	auipc	a2,0x3
ffffffffc02024e6:	84e60613          	addi	a2,a2,-1970 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02024ea:	1b300593          	li	a1,435
ffffffffc02024ee:	00003517          	auipc	a0,0x3
ffffffffc02024f2:	c5250513          	addi	a0,a0,-942 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02024f6:	e7ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc02024fa:	00003697          	auipc	a3,0x3
ffffffffc02024fe:	ece68693          	addi	a3,a3,-306 # ffffffffc02053c8 <default_pmm_manager+0x300>
ffffffffc0202502:	00003617          	auipc	a2,0x3
ffffffffc0202506:	82e60613          	addi	a2,a2,-2002 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020250a:	1b200593          	li	a1,434
ffffffffc020250e:	00003517          	auipc	a0,0x3
ffffffffc0202512:	c3250513          	addi	a0,a0,-974 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202516:	e5ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020251a:	00003697          	auipc	a3,0x3
ffffffffc020251e:	00668693          	addi	a3,a3,6 # ffffffffc0205520 <default_pmm_manager+0x458>
ffffffffc0202522:	00003617          	auipc	a2,0x3
ffffffffc0202526:	80e60613          	addi	a2,a2,-2034 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020252a:	1af00593          	li	a1,431
ffffffffc020252e:	00003517          	auipc	a0,0x3
ffffffffc0202532:	c1250513          	addi	a0,a0,-1006 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202536:	e3ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc020253a:	00003697          	auipc	a3,0x3
ffffffffc020253e:	01668693          	addi	a3,a3,22 # ffffffffc0205550 <default_pmm_manager+0x488>
ffffffffc0202542:	00002617          	auipc	a2,0x2
ffffffffc0202546:	7ee60613          	addi	a2,a2,2030 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020254a:	1b900593          	li	a1,441
ffffffffc020254e:	00003517          	auipc	a0,0x3
ffffffffc0202552:	bf250513          	addi	a0,a0,-1038 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202556:	e1ffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020255a:	00003697          	auipc	a3,0x3
ffffffffc020255e:	fae68693          	addi	a3,a3,-82 # ffffffffc0205508 <default_pmm_manager+0x440>
ffffffffc0202562:	00002617          	auipc	a2,0x2
ffffffffc0202566:	7ce60613          	addi	a2,a2,1998 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020256a:	1b700593          	li	a1,439
ffffffffc020256e:	00003517          	auipc	a0,0x3
ffffffffc0202572:	bd250513          	addi	a0,a0,-1070 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202576:	dfffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020257a:	00003697          	auipc	a3,0x3
ffffffffc020257e:	d2e68693          	addi	a3,a3,-722 # ffffffffc02052a8 <default_pmm_manager+0x1e0>
ffffffffc0202582:	00002617          	auipc	a2,0x2
ffffffffc0202586:	7ae60613          	addi	a2,a2,1966 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020258a:	19200593          	li	a1,402
ffffffffc020258e:	00003517          	auipc	a0,0x3
ffffffffc0202592:	bb250513          	addi	a0,a0,-1102 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202596:	ddffd0ef          	jal	ra,ffffffffc0200374 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020259a:	00003617          	auipc	a2,0x3
ffffffffc020259e:	cc660613          	addi	a2,a2,-826 # ffffffffc0205260 <default_pmm_manager+0x198>
ffffffffc02025a2:	0bd00593          	li	a1,189
ffffffffc02025a6:	00003517          	auipc	a0,0x3
ffffffffc02025aa:	b9a50513          	addi	a0,a0,-1126 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02025ae:	dc7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02025b2:	00003697          	auipc	a3,0x3
ffffffffc02025b6:	0c668693          	addi	a3,a3,198 # ffffffffc0205678 <default_pmm_manager+0x5b0>
ffffffffc02025ba:	00002617          	auipc	a2,0x2
ffffffffc02025be:	77660613          	addi	a2,a2,1910 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02025c2:	1d800593          	li	a1,472
ffffffffc02025c6:	00003517          	auipc	a0,0x3
ffffffffc02025ca:	b7a50513          	addi	a0,a0,-1158 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02025ce:	da7fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 1);
ffffffffc02025d2:	00003697          	auipc	a3,0x3
ffffffffc02025d6:	08e68693          	addi	a3,a3,142 # ffffffffc0205660 <default_pmm_manager+0x598>
ffffffffc02025da:	00002617          	auipc	a2,0x2
ffffffffc02025de:	75660613          	addi	a2,a2,1878 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02025e2:	1d700593          	li	a1,471
ffffffffc02025e6:	00003517          	auipc	a0,0x3
ffffffffc02025ea:	b5a50513          	addi	a0,a0,-1190 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02025ee:	d87fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02025f2:	00003697          	auipc	a3,0x3
ffffffffc02025f6:	03668693          	addi	a3,a3,54 # ffffffffc0205628 <default_pmm_manager+0x560>
ffffffffc02025fa:	00002617          	auipc	a2,0x2
ffffffffc02025fe:	73660613          	addi	a2,a2,1846 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202602:	1d600593          	li	a1,470
ffffffffc0202606:	00003517          	auipc	a0,0x3
ffffffffc020260a:	b3a50513          	addi	a0,a0,-1222 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc020260e:	d67fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc0202612:	00003697          	auipc	a3,0x3
ffffffffc0202616:	ffe68693          	addi	a3,a3,-2 # ffffffffc0205610 <default_pmm_manager+0x548>
ffffffffc020261a:	00002617          	auipc	a2,0x2
ffffffffc020261e:	71660613          	addi	a2,a2,1814 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202622:	1d200593          	li	a1,466
ffffffffc0202626:	00003517          	auipc	a0,0x3
ffffffffc020262a:	b1a50513          	addi	a0,a0,-1254 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc020262e:	d47fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202632 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0202632:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc0202636:	8082                	ret

ffffffffc0202638 <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202638:	7179                	addi	sp,sp,-48
ffffffffc020263a:	e84a                	sd	s2,16(sp)
ffffffffc020263c:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc020263e:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc0202640:	f022                	sd	s0,32(sp)
ffffffffc0202642:	ec26                	sd	s1,24(sp)
ffffffffc0202644:	e44e                	sd	s3,8(sp)
ffffffffc0202646:	f406                	sd	ra,40(sp)
ffffffffc0202648:	84ae                	mv	s1,a1
ffffffffc020264a:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc020264c:	852ff0ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc0202650:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc0202652:	cd19                	beqz	a0,ffffffffc0202670 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc0202654:	85aa                	mv	a1,a0
ffffffffc0202656:	86ce                	mv	a3,s3
ffffffffc0202658:	8626                	mv	a2,s1
ffffffffc020265a:	854a                	mv	a0,s2
ffffffffc020265c:	c28ff0ef          	jal	ra,ffffffffc0201a84 <page_insert>
ffffffffc0202660:	ed39                	bnez	a0,ffffffffc02026be <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc0202662:	0000f797          	auipc	a5,0xf
ffffffffc0202666:	e0678793          	addi	a5,a5,-506 # ffffffffc0211468 <swap_init_ok>
ffffffffc020266a:	439c                	lw	a5,0(a5)
ffffffffc020266c:	2781                	sext.w	a5,a5
ffffffffc020266e:	eb89                	bnez	a5,ffffffffc0202680 <pgdir_alloc_page+0x48>
}
ffffffffc0202670:	8522                	mv	a0,s0
ffffffffc0202672:	70a2                	ld	ra,40(sp)
ffffffffc0202674:	7402                	ld	s0,32(sp)
ffffffffc0202676:	64e2                	ld	s1,24(sp)
ffffffffc0202678:	6942                	ld	s2,16(sp)
ffffffffc020267a:	69a2                	ld	s3,8(sp)
ffffffffc020267c:	6145                	addi	sp,sp,48
ffffffffc020267e:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202680:	0000f797          	auipc	a5,0xf
ffffffffc0202684:	f1078793          	addi	a5,a5,-240 # ffffffffc0211590 <check_mm_struct>
ffffffffc0202688:	6388                	ld	a0,0(a5)
ffffffffc020268a:	4681                	li	a3,0
ffffffffc020268c:	8622                	mv	a2,s0
ffffffffc020268e:	85a6                	mv	a1,s1
ffffffffc0202690:	06d000ef          	jal	ra,ffffffffc0202efc <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202694:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202696:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0202698:	4785                	li	a5,1
ffffffffc020269a:	fcf70be3          	beq	a4,a5,ffffffffc0202670 <pgdir_alloc_page+0x38>
ffffffffc020269e:	00003697          	auipc	a3,0x3
ffffffffc02026a2:	b2268693          	addi	a3,a3,-1246 # ffffffffc02051c0 <default_pmm_manager+0xf8>
ffffffffc02026a6:	00002617          	auipc	a2,0x2
ffffffffc02026aa:	68a60613          	addi	a2,a2,1674 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02026ae:	17a00593          	li	a1,378
ffffffffc02026b2:	00003517          	auipc	a0,0x3
ffffffffc02026b6:	a8e50513          	addi	a0,a0,-1394 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc02026ba:	cbbfd0ef          	jal	ra,ffffffffc0200374 <__panic>
            free_page(page);
ffffffffc02026be:	8522                	mv	a0,s0
ffffffffc02026c0:	4585                	li	a1,1
ffffffffc02026c2:	864ff0ef          	jal	ra,ffffffffc0201726 <free_pages>
            return NULL;
ffffffffc02026c6:	4401                	li	s0,0
ffffffffc02026c8:	b765                	j	ffffffffc0202670 <pgdir_alloc_page+0x38>

ffffffffc02026ca <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc02026ca:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02026cc:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc02026ce:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02026d0:	fff50713          	addi	a4,a0,-1
ffffffffc02026d4:	17f9                	addi	a5,a5,-2
ffffffffc02026d6:	04e7ee63          	bltu	a5,a4,ffffffffc0202732 <kmalloc+0x68>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc02026da:	6785                	lui	a5,0x1
ffffffffc02026dc:	17fd                	addi	a5,a5,-1
ffffffffc02026de:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc02026e0:	8131                	srli	a0,a0,0xc
ffffffffc02026e2:	fbdfe0ef          	jal	ra,ffffffffc020169e <alloc_pages>
    assert(base != NULL);
ffffffffc02026e6:	c159                	beqz	a0,ffffffffc020276c <kmalloc+0xa2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026e8:	0000f797          	auipc	a5,0xf
ffffffffc02026ec:	dc078793          	addi	a5,a5,-576 # ffffffffc02114a8 <pages>
ffffffffc02026f0:	639c                	ld	a5,0(a5)
ffffffffc02026f2:	8d1d                	sub	a0,a0,a5
ffffffffc02026f4:	00002797          	auipc	a5,0x2
ffffffffc02026f8:	62478793          	addi	a5,a5,1572 # ffffffffc0204d18 <commands+0x8b8>
ffffffffc02026fc:	6394                	ld	a3,0(a5)
ffffffffc02026fe:	850d                	srai	a0,a0,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202700:	0000f797          	auipc	a5,0xf
ffffffffc0202704:	d5878793          	addi	a5,a5,-680 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202708:	02d50533          	mul	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020270c:	6398                	ld	a4,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020270e:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202712:	57fd                	li	a5,-1
ffffffffc0202714:	83b1                	srli	a5,a5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202716:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202718:	8fe9                	and	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc020271a:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020271c:	02e7fb63          	bleu	a4,a5,ffffffffc0202752 <kmalloc+0x88>
ffffffffc0202720:	0000f797          	auipc	a5,0xf
ffffffffc0202724:	d7878793          	addi	a5,a5,-648 # ffffffffc0211498 <va_pa_offset>
ffffffffc0202728:	639c                	ld	a5,0(a5)
    ptr = page2kva(base);
    return ptr;
}
ffffffffc020272a:	60a2                	ld	ra,8(sp)
ffffffffc020272c:	953e                	add	a0,a0,a5
ffffffffc020272e:	0141                	addi	sp,sp,16
ffffffffc0202730:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202732:	00003697          	auipc	a3,0x3
ffffffffc0202736:	a2e68693          	addi	a3,a3,-1490 # ffffffffc0205160 <default_pmm_manager+0x98>
ffffffffc020273a:	00002617          	auipc	a2,0x2
ffffffffc020273e:	5f660613          	addi	a2,a2,1526 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202742:	1f000593          	li	a1,496
ffffffffc0202746:	00003517          	auipc	a0,0x3
ffffffffc020274a:	9fa50513          	addi	a0,a0,-1542 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc020274e:	c27fd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0202752:	86aa                	mv	a3,a0
ffffffffc0202754:	00003617          	auipc	a2,0x3
ffffffffc0202758:	9c460613          	addi	a2,a2,-1596 # ffffffffc0205118 <default_pmm_manager+0x50>
ffffffffc020275c:	06a00593          	li	a1,106
ffffffffc0202760:	00003517          	auipc	a0,0x3
ffffffffc0202764:	a5050513          	addi	a0,a0,-1456 # ffffffffc02051b0 <default_pmm_manager+0xe8>
ffffffffc0202768:	c0dfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(base != NULL);
ffffffffc020276c:	00003697          	auipc	a3,0x3
ffffffffc0202770:	a1468693          	addi	a3,a3,-1516 # ffffffffc0205180 <default_pmm_manager+0xb8>
ffffffffc0202774:	00002617          	auipc	a2,0x2
ffffffffc0202778:	5bc60613          	addi	a2,a2,1468 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020277c:	1f300593          	li	a1,499
ffffffffc0202780:	00003517          	auipc	a0,0x3
ffffffffc0202784:	9c050513          	addi	a0,a0,-1600 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202788:	bedfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020278c <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc020278c:	1141                	addi	sp,sp,-16
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020278e:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0202790:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202792:	fff58713          	addi	a4,a1,-1
ffffffffc0202796:	17f9                	addi	a5,a5,-2
ffffffffc0202798:	04e7eb63          	bltu	a5,a4,ffffffffc02027ee <kfree+0x62>
    assert(ptr != NULL);
ffffffffc020279c:	c941                	beqz	a0,ffffffffc020282c <kfree+0xa0>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc020279e:	6785                	lui	a5,0x1
ffffffffc02027a0:	17fd                	addi	a5,a5,-1
ffffffffc02027a2:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02027a4:	c02007b7          	lui	a5,0xc0200
ffffffffc02027a8:	81b1                	srli	a1,a1,0xc
ffffffffc02027aa:	06f56463          	bltu	a0,a5,ffffffffc0202812 <kfree+0x86>
ffffffffc02027ae:	0000f797          	auipc	a5,0xf
ffffffffc02027b2:	cea78793          	addi	a5,a5,-790 # ffffffffc0211498 <va_pa_offset>
ffffffffc02027b6:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02027b8:	0000f717          	auipc	a4,0xf
ffffffffc02027bc:	ca070713          	addi	a4,a4,-864 # ffffffffc0211458 <npage>
ffffffffc02027c0:	6318                	ld	a4,0(a4)
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02027c2:	40f507b3          	sub	a5,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc02027c6:	83b1                	srli	a5,a5,0xc
ffffffffc02027c8:	04e7f363          	bleu	a4,a5,ffffffffc020280e <kfree+0x82>
    return &pages[PPN(pa) - nbase];
ffffffffc02027cc:	fff80537          	lui	a0,0xfff80
ffffffffc02027d0:	97aa                	add	a5,a5,a0
ffffffffc02027d2:	0000f697          	auipc	a3,0xf
ffffffffc02027d6:	cd668693          	addi	a3,a3,-810 # ffffffffc02114a8 <pages>
ffffffffc02027da:	6288                	ld	a0,0(a3)
ffffffffc02027dc:	00379713          	slli	a4,a5,0x3
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc02027e0:	60a2                	ld	ra,8(sp)
ffffffffc02027e2:	97ba                	add	a5,a5,a4
ffffffffc02027e4:	078e                	slli	a5,a5,0x3
    free_pages(base, num_pages);
ffffffffc02027e6:	953e                	add	a0,a0,a5
}
ffffffffc02027e8:	0141                	addi	sp,sp,16
    free_pages(base, num_pages);
ffffffffc02027ea:	f3dfe06f          	j	ffffffffc0201726 <free_pages>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02027ee:	00003697          	auipc	a3,0x3
ffffffffc02027f2:	97268693          	addi	a3,a3,-1678 # ffffffffc0205160 <default_pmm_manager+0x98>
ffffffffc02027f6:	00002617          	auipc	a2,0x2
ffffffffc02027fa:	53a60613          	addi	a2,a2,1338 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02027fe:	1f900593          	li	a1,505
ffffffffc0202802:	00003517          	auipc	a0,0x3
ffffffffc0202806:	93e50513          	addi	a0,a0,-1730 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc020280a:	b6bfd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc020280e:	e75fe0ef          	jal	ra,ffffffffc0201682 <pa2page.part.4>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202812:	86aa                	mv	a3,a0
ffffffffc0202814:	00003617          	auipc	a2,0x3
ffffffffc0202818:	a4c60613          	addi	a2,a2,-1460 # ffffffffc0205260 <default_pmm_manager+0x198>
ffffffffc020281c:	06c00593          	li	a1,108
ffffffffc0202820:	00003517          	auipc	a0,0x3
ffffffffc0202824:	99050513          	addi	a0,a0,-1648 # ffffffffc02051b0 <default_pmm_manager+0xe8>
ffffffffc0202828:	b4dfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(ptr != NULL);
ffffffffc020282c:	00003697          	auipc	a3,0x3
ffffffffc0202830:	92468693          	addi	a3,a3,-1756 # ffffffffc0205150 <default_pmm_manager+0x88>
ffffffffc0202834:	00002617          	auipc	a2,0x2
ffffffffc0202838:	4fc60613          	addi	a2,a2,1276 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020283c:	1fa00593          	li	a1,506
ffffffffc0202840:	00003517          	auipc	a0,0x3
ffffffffc0202844:	90050513          	addi	a0,a0,-1792 # ffffffffc0205140 <default_pmm_manager+0x78>
ffffffffc0202848:	b2dfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020284c <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc020284c:	7135                	addi	sp,sp,-160
ffffffffc020284e:	ed06                	sd	ra,152(sp)
ffffffffc0202850:	e922                	sd	s0,144(sp)
ffffffffc0202852:	e526                	sd	s1,136(sp)
ffffffffc0202854:	e14a                	sd	s2,128(sp)
ffffffffc0202856:	fcce                	sd	s3,120(sp)
ffffffffc0202858:	f8d2                	sd	s4,112(sp)
ffffffffc020285a:	f4d6                	sd	s5,104(sp)
ffffffffc020285c:	f0da                	sd	s6,96(sp)
ffffffffc020285e:	ecde                	sd	s7,88(sp)
ffffffffc0202860:	e8e2                	sd	s8,80(sp)
ffffffffc0202862:	e4e6                	sd	s9,72(sp)
ffffffffc0202864:	e0ea                	sd	s10,64(sp)
ffffffffc0202866:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202868:	3c8010ef          	jal	ra,ffffffffc0203c30 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc020286c:	0000f797          	auipc	a5,0xf
ffffffffc0202870:	ccc78793          	addi	a5,a5,-820 # ffffffffc0211538 <max_swap_offset>
ffffffffc0202874:	6394                	ld	a3,0(a5)
ffffffffc0202876:	010007b7          	lui	a5,0x1000
ffffffffc020287a:	17e1                	addi	a5,a5,-8
ffffffffc020287c:	ff968713          	addi	a4,a3,-7
ffffffffc0202880:	42e7ea63          	bltu	a5,a4,ffffffffc0202cb4 <swap_init+0x468>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc0202884:	00007797          	auipc	a5,0x7
ffffffffc0202888:	77c78793          	addi	a5,a5,1916 # ffffffffc020a000 <swap_manager_clock>
     int r = sm->init();
ffffffffc020288c:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;//use first in first out Page Replacement Algorithm
ffffffffc020288e:	0000f697          	auipc	a3,0xf
ffffffffc0202892:	bcf6b923          	sd	a5,-1070(a3) # ffffffffc0211460 <sm>
     int r = sm->init();
ffffffffc0202896:	9702                	jalr	a4
ffffffffc0202898:	8b2a                	mv	s6,a0
     
     if (r == 0)
ffffffffc020289a:	c10d                	beqz	a0,ffffffffc02028bc <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020289c:	60ea                	ld	ra,152(sp)
ffffffffc020289e:	644a                	ld	s0,144(sp)
ffffffffc02028a0:	855a                	mv	a0,s6
ffffffffc02028a2:	64aa                	ld	s1,136(sp)
ffffffffc02028a4:	690a                	ld	s2,128(sp)
ffffffffc02028a6:	79e6                	ld	s3,120(sp)
ffffffffc02028a8:	7a46                	ld	s4,112(sp)
ffffffffc02028aa:	7aa6                	ld	s5,104(sp)
ffffffffc02028ac:	7b06                	ld	s6,96(sp)
ffffffffc02028ae:	6be6                	ld	s7,88(sp)
ffffffffc02028b0:	6c46                	ld	s8,80(sp)
ffffffffc02028b2:	6ca6                	ld	s9,72(sp)
ffffffffc02028b4:	6d06                	ld	s10,64(sp)
ffffffffc02028b6:	7de2                	ld	s11,56(sp)
ffffffffc02028b8:	610d                	addi	sp,sp,160
ffffffffc02028ba:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02028bc:	0000f797          	auipc	a5,0xf
ffffffffc02028c0:	ba478793          	addi	a5,a5,-1116 # ffffffffc0211460 <sm>
ffffffffc02028c4:	639c                	ld	a5,0(a5)
ffffffffc02028c6:	00003517          	auipc	a0,0x3
ffffffffc02028ca:	f2250513          	addi	a0,a0,-222 # ffffffffc02057e8 <default_pmm_manager+0x720>
    return listelm->next;
ffffffffc02028ce:	0000f417          	auipc	s0,0xf
ffffffffc02028d2:	baa40413          	addi	s0,s0,-1110 # ffffffffc0211478 <free_area>
ffffffffc02028d6:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02028d8:	4785                	li	a5,1
ffffffffc02028da:	0000f717          	auipc	a4,0xf
ffffffffc02028de:	b8f72723          	sw	a5,-1138(a4) # ffffffffc0211468 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02028e2:	fdcfd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02028e6:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02028e8:	2e878a63          	beq	a5,s0,ffffffffc0202bdc <swap_init+0x390>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02028ec:	fe87b703          	ld	a4,-24(a5)
ffffffffc02028f0:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02028f2:	8b05                	andi	a4,a4,1
ffffffffc02028f4:	2e070863          	beqz	a4,ffffffffc0202be4 <swap_init+0x398>
     int ret, count = 0, total = 0, i;
ffffffffc02028f8:	4481                	li	s1,0
ffffffffc02028fa:	4901                	li	s2,0
ffffffffc02028fc:	a031                	j	ffffffffc0202908 <swap_init+0xbc>
ffffffffc02028fe:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0202902:	8b09                	andi	a4,a4,2
ffffffffc0202904:	2e070063          	beqz	a4,ffffffffc0202be4 <swap_init+0x398>
        count ++, total += p->property;
ffffffffc0202908:	ff87a703          	lw	a4,-8(a5)
ffffffffc020290c:	679c                	ld	a5,8(a5)
ffffffffc020290e:	2905                	addiw	s2,s2,1
ffffffffc0202910:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202912:	fe8796e3          	bne	a5,s0,ffffffffc02028fe <swap_init+0xb2>
ffffffffc0202916:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc0202918:	e55fe0ef          	jal	ra,ffffffffc020176c <nr_free_pages>
ffffffffc020291c:	5b351863          	bne	a0,s3,ffffffffc0202ecc <swap_init+0x680>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202920:	8626                	mv	a2,s1
ffffffffc0202922:	85ca                	mv	a1,s2
ffffffffc0202924:	00003517          	auipc	a0,0x3
ffffffffc0202928:	edc50513          	addi	a0,a0,-292 # ffffffffc0205800 <default_pmm_manager+0x738>
ffffffffc020292c:	f92fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202930:	31d000ef          	jal	ra,ffffffffc020344c <mm_create>
ffffffffc0202934:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc0202936:	50050b63          	beqz	a0,ffffffffc0202e4c <swap_init+0x600>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020293a:	0000f797          	auipc	a5,0xf
ffffffffc020293e:	c5678793          	addi	a5,a5,-938 # ffffffffc0211590 <check_mm_struct>
ffffffffc0202942:	639c                	ld	a5,0(a5)
ffffffffc0202944:	52079463          	bnez	a5,ffffffffc0202e6c <swap_init+0x620>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202948:	0000f797          	auipc	a5,0xf
ffffffffc020294c:	b0878793          	addi	a5,a5,-1272 # ffffffffc0211450 <boot_pgdir>
ffffffffc0202950:	6398                	ld	a4,0(a5)
     check_mm_struct = mm;
ffffffffc0202952:	0000f797          	auipc	a5,0xf
ffffffffc0202956:	c2a7bf23          	sd	a0,-962(a5) # ffffffffc0211590 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc020295a:	631c                	ld	a5,0(a4)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020295c:	ec3a                	sd	a4,24(sp)
ffffffffc020295e:	ed18                	sd	a4,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202960:	52079663          	bnez	a5,ffffffffc0202e8c <swap_init+0x640>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202964:	6599                	lui	a1,0x6
ffffffffc0202966:	460d                	li	a2,3
ffffffffc0202968:	6505                	lui	a0,0x1
ffffffffc020296a:	32f000ef          	jal	ra,ffffffffc0203498 <vma_create>
ffffffffc020296e:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202970:	52050e63          	beqz	a0,ffffffffc0202eac <swap_init+0x660>

     insert_vma_struct(mm, vma);
ffffffffc0202974:	855e                	mv	a0,s7
ffffffffc0202976:	38f000ef          	jal	ra,ffffffffc0203504 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020297a:	00003517          	auipc	a0,0x3
ffffffffc020297e:	ef650513          	addi	a0,a0,-266 # ffffffffc0205870 <default_pmm_manager+0x7a8>
ffffffffc0202982:	f3cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202986:	018bb503          	ld	a0,24(s7)
ffffffffc020298a:	4605                	li	a2,1
ffffffffc020298c:	6585                	lui	a1,0x1
ffffffffc020298e:	e1ffe0ef          	jal	ra,ffffffffc02017ac <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202992:	40050d63          	beqz	a0,ffffffffc0202dac <swap_init+0x560>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202996:	00003517          	auipc	a0,0x3
ffffffffc020299a:	f2a50513          	addi	a0,a0,-214 # ffffffffc02058c0 <default_pmm_manager+0x7f8>
ffffffffc020299e:	0000fa17          	auipc	s4,0xf
ffffffffc02029a2:	b12a0a13          	addi	s4,s4,-1262 # ffffffffc02114b0 <check_rp>
ffffffffc02029a6:	f18fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02029aa:	0000fa97          	auipc	s5,0xf
ffffffffc02029ae:	b26a8a93          	addi	s5,s5,-1242 # ffffffffc02114d0 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02029b2:	89d2                	mv	s3,s4
          check_rp[i] = alloc_page();
ffffffffc02029b4:	4505                	li	a0,1
ffffffffc02029b6:	ce9fe0ef          	jal	ra,ffffffffc020169e <alloc_pages>
ffffffffc02029ba:	00a9b023          	sd	a0,0(s3) # fffffffffff80000 <end+0x3fd6ea68>
          assert(check_rp[i] != NULL );
ffffffffc02029be:	2a050b63          	beqz	a0,ffffffffc0202c74 <swap_init+0x428>
ffffffffc02029c2:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02029c4:	8b89                	andi	a5,a5,2
ffffffffc02029c6:	28079763          	bnez	a5,ffffffffc0202c54 <swap_init+0x408>
ffffffffc02029ca:	09a1                	addi	s3,s3,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02029cc:	ff5994e3          	bne	s3,s5,ffffffffc02029b4 <swap_init+0x168>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02029d0:	601c                	ld	a5,0(s0)
ffffffffc02029d2:	00843983          	ld	s3,8(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02029d6:	0000fd17          	auipc	s10,0xf
ffffffffc02029da:	adad0d13          	addi	s10,s10,-1318 # ffffffffc02114b0 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc02029de:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02029e0:	481c                	lw	a5,16(s0)
ffffffffc02029e2:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc02029e4:	0000f797          	auipc	a5,0xf
ffffffffc02029e8:	a887be23          	sd	s0,-1380(a5) # ffffffffc0211480 <free_area+0x8>
ffffffffc02029ec:	0000f797          	auipc	a5,0xf
ffffffffc02029f0:	a887b623          	sd	s0,-1396(a5) # ffffffffc0211478 <free_area>
     nr_free = 0;
ffffffffc02029f4:	0000f797          	auipc	a5,0xf
ffffffffc02029f8:	a807aa23          	sw	zero,-1388(a5) # ffffffffc0211488 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc02029fc:	000d3503          	ld	a0,0(s10)
ffffffffc0202a00:	4585                	li	a1,1
ffffffffc0202a02:	0d21                	addi	s10,s10,8
ffffffffc0202a04:	d23fe0ef          	jal	ra,ffffffffc0201726 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202a08:	ff5d1ae3          	bne	s10,s5,ffffffffc02029fc <swap_init+0x1b0>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202a0c:	01042d03          	lw	s10,16(s0)
ffffffffc0202a10:	4791                	li	a5,4
ffffffffc0202a12:	36fd1d63          	bne	s10,a5,ffffffffc0202d8c <swap_init+0x540>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202a16:	00003517          	auipc	a0,0x3
ffffffffc0202a1a:	f3250513          	addi	a0,a0,-206 # ffffffffc0205948 <default_pmm_manager+0x880>
ffffffffc0202a1e:	ea0fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a22:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202a24:	0000f797          	auipc	a5,0xf
ffffffffc0202a28:	a407a423          	sw	zero,-1464(a5) # ffffffffc021146c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a2c:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0202a2e:	0000f797          	auipc	a5,0xf
ffffffffc0202a32:	a3e78793          	addi	a5,a5,-1474 # ffffffffc021146c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202a36:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202a3a:	4398                	lw	a4,0(a5)
ffffffffc0202a3c:	4585                	li	a1,1
ffffffffc0202a3e:	2701                	sext.w	a4,a4
ffffffffc0202a40:	30b71663          	bne	a4,a1,ffffffffc0202d4c <swap_init+0x500>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202a44:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0202a48:	4394                	lw	a3,0(a5)
ffffffffc0202a4a:	2681                	sext.w	a3,a3
ffffffffc0202a4c:	32e69063          	bne	a3,a4,ffffffffc0202d6c <swap_init+0x520>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202a50:	6689                	lui	a3,0x2
ffffffffc0202a52:	462d                	li	a2,11
ffffffffc0202a54:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202a58:	4398                	lw	a4,0(a5)
ffffffffc0202a5a:	4589                	li	a1,2
ffffffffc0202a5c:	2701                	sext.w	a4,a4
ffffffffc0202a5e:	26b71763          	bne	a4,a1,ffffffffc0202ccc <swap_init+0x480>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202a62:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc0202a66:	4394                	lw	a3,0(a5)
ffffffffc0202a68:	2681                	sext.w	a3,a3
ffffffffc0202a6a:	28e69163          	bne	a3,a4,ffffffffc0202cec <swap_init+0x4a0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202a6e:	668d                	lui	a3,0x3
ffffffffc0202a70:	4631                	li	a2,12
ffffffffc0202a72:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202a76:	4398                	lw	a4,0(a5)
ffffffffc0202a78:	458d                	li	a1,3
ffffffffc0202a7a:	2701                	sext.w	a4,a4
ffffffffc0202a7c:	28b71863          	bne	a4,a1,ffffffffc0202d0c <swap_init+0x4c0>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202a80:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202a84:	4394                	lw	a3,0(a5)
ffffffffc0202a86:	2681                	sext.w	a3,a3
ffffffffc0202a88:	2ae69263          	bne	a3,a4,ffffffffc0202d2c <swap_init+0x4e0>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202a8c:	6691                	lui	a3,0x4
ffffffffc0202a8e:	4635                	li	a2,13
ffffffffc0202a90:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202a94:	4398                	lw	a4,0(a5)
ffffffffc0202a96:	2701                	sext.w	a4,a4
ffffffffc0202a98:	33a71a63          	bne	a4,s10,ffffffffc0202dcc <swap_init+0x580>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202a9c:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202aa0:	439c                	lw	a5,0(a5)
ffffffffc0202aa2:	2781                	sext.w	a5,a5
ffffffffc0202aa4:	34e79463          	bne	a5,a4,ffffffffc0202dec <swap_init+0x5a0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202aa8:	481c                	lw	a5,16(s0)
ffffffffc0202aaa:	36079163          	bnez	a5,ffffffffc0202e0c <swap_init+0x5c0>
ffffffffc0202aae:	0000f797          	auipc	a5,0xf
ffffffffc0202ab2:	a2278793          	addi	a5,a5,-1502 # ffffffffc02114d0 <swap_in_seq_no>
ffffffffc0202ab6:	0000f717          	auipc	a4,0xf
ffffffffc0202aba:	a4270713          	addi	a4,a4,-1470 # ffffffffc02114f8 <swap_out_seq_no>
ffffffffc0202abe:	0000f617          	auipc	a2,0xf
ffffffffc0202ac2:	a3a60613          	addi	a2,a2,-1478 # ffffffffc02114f8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202ac6:	56fd                	li	a3,-1
ffffffffc0202ac8:	c394                	sw	a3,0(a5)
ffffffffc0202aca:	c314                	sw	a3,0(a4)
ffffffffc0202acc:	0791                	addi	a5,a5,4
ffffffffc0202ace:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202ad0:	fec79ce3          	bne	a5,a2,ffffffffc0202ac8 <swap_init+0x27c>
ffffffffc0202ad4:	0000f697          	auipc	a3,0xf
ffffffffc0202ad8:	a8468693          	addi	a3,a3,-1404 # ffffffffc0211558 <check_ptep>
ffffffffc0202adc:	0000f817          	auipc	a6,0xf
ffffffffc0202ae0:	9d480813          	addi	a6,a6,-1580 # ffffffffc02114b0 <check_rp>
ffffffffc0202ae4:	6c05                	lui	s8,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202ae6:	0000fc97          	auipc	s9,0xf
ffffffffc0202aea:	972c8c93          	addi	s9,s9,-1678 # ffffffffc0211458 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202aee:	0000fd97          	auipc	s11,0xf
ffffffffc0202af2:	9bad8d93          	addi	s11,s11,-1606 # ffffffffc02114a8 <pages>
ffffffffc0202af6:	00003d17          	auipc	s10,0x3
ffffffffc0202afa:	6cad0d13          	addi	s10,s10,1738 # ffffffffc02061c0 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202afe:	6562                	ld	a0,24(sp)
         check_ptep[i]=0;
ffffffffc0202b00:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b04:	4601                	li	a2,0
ffffffffc0202b06:	85e2                	mv	a1,s8
ffffffffc0202b08:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202b0a:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b0c:	ca1fe0ef          	jal	ra,ffffffffc02017ac <get_pte>
ffffffffc0202b10:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202b12:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202b14:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202b16:	16050f63          	beqz	a0,ffffffffc0202c94 <swap_init+0x448>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202b1a:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202b1c:	0017f613          	andi	a2,a5,1
ffffffffc0202b20:	10060263          	beqz	a2,ffffffffc0202c24 <swap_init+0x3d8>
    if (PPN(pa) >= npage) {
ffffffffc0202b24:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202b28:	078a                	slli	a5,a5,0x2
ffffffffc0202b2a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202b2c:	10c7f863          	bleu	a2,a5,ffffffffc0202c3c <swap_init+0x3f0>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b30:	000d3603          	ld	a2,0(s10)
ffffffffc0202b34:	000db583          	ld	a1,0(s11)
ffffffffc0202b38:	00083503          	ld	a0,0(a6)
ffffffffc0202b3c:	8f91                	sub	a5,a5,a2
ffffffffc0202b3e:	00379613          	slli	a2,a5,0x3
ffffffffc0202b42:	97b2                	add	a5,a5,a2
ffffffffc0202b44:	078e                	slli	a5,a5,0x3
ffffffffc0202b46:	97ae                	add	a5,a5,a1
ffffffffc0202b48:	0af51e63          	bne	a0,a5,ffffffffc0202c04 <swap_init+0x3b8>
ffffffffc0202b4c:	6785                	lui	a5,0x1
ffffffffc0202b4e:	9c3e                	add	s8,s8,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b50:	6795                	lui	a5,0x5
ffffffffc0202b52:	06a1                	addi	a3,a3,8
ffffffffc0202b54:	0821                	addi	a6,a6,8
ffffffffc0202b56:	fafc14e3          	bne	s8,a5,ffffffffc0202afe <swap_init+0x2b2>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202b5a:	00003517          	auipc	a0,0x3
ffffffffc0202b5e:	e9650513          	addi	a0,a0,-362 # ffffffffc02059f0 <default_pmm_manager+0x928>
ffffffffc0202b62:	d5cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = sm->check_swap();
ffffffffc0202b66:	0000f797          	auipc	a5,0xf
ffffffffc0202b6a:	8fa78793          	addi	a5,a5,-1798 # ffffffffc0211460 <sm>
ffffffffc0202b6e:	639c                	ld	a5,0(a5)
ffffffffc0202b70:	7f9c                	ld	a5,56(a5)
ffffffffc0202b72:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202b74:	2a051c63          	bnez	a0,ffffffffc0202e2c <swap_init+0x5e0>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202b78:	000a3503          	ld	a0,0(s4)
ffffffffc0202b7c:	4585                	li	a1,1
ffffffffc0202b7e:	0a21                	addi	s4,s4,8
ffffffffc0202b80:	ba7fe0ef          	jal	ra,ffffffffc0201726 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b84:	ff5a1ae3          	bne	s4,s5,ffffffffc0202b78 <swap_init+0x32c>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202b88:	855e                	mv	a0,s7
ffffffffc0202b8a:	249000ef          	jal	ra,ffffffffc02035d2 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202b8e:	77a2                	ld	a5,40(sp)
ffffffffc0202b90:	0000f717          	auipc	a4,0xf
ffffffffc0202b94:	8ef72c23          	sw	a5,-1800(a4) # ffffffffc0211488 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202b98:	7782                	ld	a5,32(sp)
ffffffffc0202b9a:	0000f717          	auipc	a4,0xf
ffffffffc0202b9e:	8cf73f23          	sd	a5,-1826(a4) # ffffffffc0211478 <free_area>
ffffffffc0202ba2:	0000f797          	auipc	a5,0xf
ffffffffc0202ba6:	8d37bf23          	sd	s3,-1826(a5) # ffffffffc0211480 <free_area+0x8>

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202baa:	00898a63          	beq	s3,s0,ffffffffc0202bbe <swap_init+0x372>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202bae:	ff89a783          	lw	a5,-8(s3)
    return listelm->next;
ffffffffc0202bb2:	0089b983          	ld	s3,8(s3)
ffffffffc0202bb6:	397d                	addiw	s2,s2,-1
ffffffffc0202bb8:	9c9d                	subw	s1,s1,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202bba:	fe899ae3          	bne	s3,s0,ffffffffc0202bae <swap_init+0x362>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202bbe:	8626                	mv	a2,s1
ffffffffc0202bc0:	85ca                	mv	a1,s2
ffffffffc0202bc2:	00003517          	auipc	a0,0x3
ffffffffc0202bc6:	e5e50513          	addi	a0,a0,-418 # ffffffffc0205a20 <default_pmm_manager+0x958>
ffffffffc0202bca:	cf4fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202bce:	00003517          	auipc	a0,0x3
ffffffffc0202bd2:	e7250513          	addi	a0,a0,-398 # ffffffffc0205a40 <default_pmm_manager+0x978>
ffffffffc0202bd6:	ce8fd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202bda:	b1c9                	j	ffffffffc020289c <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202bdc:	4481                	li	s1,0
ffffffffc0202bde:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202be0:	4981                	li	s3,0
ffffffffc0202be2:	bb1d                	j	ffffffffc0202918 <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202be4:	00002697          	auipc	a3,0x2
ffffffffc0202be8:	13c68693          	addi	a3,a3,316 # ffffffffc0204d20 <commands+0x8c0>
ffffffffc0202bec:	00002617          	auipc	a2,0x2
ffffffffc0202bf0:	14460613          	addi	a2,a2,324 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202bf4:	0ba00593          	li	a1,186
ffffffffc0202bf8:	00003517          	auipc	a0,0x3
ffffffffc0202bfc:	be050513          	addi	a0,a0,-1056 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202c00:	f74fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202c04:	00003697          	auipc	a3,0x3
ffffffffc0202c08:	dc468693          	addi	a3,a3,-572 # ffffffffc02059c8 <default_pmm_manager+0x900>
ffffffffc0202c0c:	00002617          	auipc	a2,0x2
ffffffffc0202c10:	12460613          	addi	a2,a2,292 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202c14:	0fa00593          	li	a1,250
ffffffffc0202c18:	00003517          	auipc	a0,0x3
ffffffffc0202c1c:	bc050513          	addi	a0,a0,-1088 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202c20:	f54fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202c24:	00002617          	auipc	a2,0x2
ffffffffc0202c28:	76460613          	addi	a2,a2,1892 # ffffffffc0205388 <default_pmm_manager+0x2c0>
ffffffffc0202c2c:	07000593          	li	a1,112
ffffffffc0202c30:	00002517          	auipc	a0,0x2
ffffffffc0202c34:	58050513          	addi	a0,a0,1408 # ffffffffc02051b0 <default_pmm_manager+0xe8>
ffffffffc0202c38:	f3cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202c3c:	00002617          	auipc	a2,0x2
ffffffffc0202c40:	55460613          	addi	a2,a2,1364 # ffffffffc0205190 <default_pmm_manager+0xc8>
ffffffffc0202c44:	06500593          	li	a1,101
ffffffffc0202c48:	00002517          	auipc	a0,0x2
ffffffffc0202c4c:	56850513          	addi	a0,a0,1384 # ffffffffc02051b0 <default_pmm_manager+0xe8>
ffffffffc0202c50:	f24fd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202c54:	00003697          	auipc	a3,0x3
ffffffffc0202c58:	cac68693          	addi	a3,a3,-852 # ffffffffc0205900 <default_pmm_manager+0x838>
ffffffffc0202c5c:	00002617          	auipc	a2,0x2
ffffffffc0202c60:	0d460613          	addi	a2,a2,212 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202c64:	0db00593          	li	a1,219
ffffffffc0202c68:	00003517          	auipc	a0,0x3
ffffffffc0202c6c:	b7050513          	addi	a0,a0,-1168 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202c70:	f04fd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202c74:	00003697          	auipc	a3,0x3
ffffffffc0202c78:	c7468693          	addi	a3,a3,-908 # ffffffffc02058e8 <default_pmm_manager+0x820>
ffffffffc0202c7c:	00002617          	auipc	a2,0x2
ffffffffc0202c80:	0b460613          	addi	a2,a2,180 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202c84:	0da00593          	li	a1,218
ffffffffc0202c88:	00003517          	auipc	a0,0x3
ffffffffc0202c8c:	b5050513          	addi	a0,a0,-1200 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202c90:	ee4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202c94:	00003697          	auipc	a3,0x3
ffffffffc0202c98:	d1c68693          	addi	a3,a3,-740 # ffffffffc02059b0 <default_pmm_manager+0x8e8>
ffffffffc0202c9c:	00002617          	auipc	a2,0x2
ffffffffc0202ca0:	09460613          	addi	a2,a2,148 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202ca4:	0f900593          	li	a1,249
ffffffffc0202ca8:	00003517          	auipc	a0,0x3
ffffffffc0202cac:	b3050513          	addi	a0,a0,-1232 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202cb0:	ec4fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202cb4:	00003617          	auipc	a2,0x3
ffffffffc0202cb8:	b0460613          	addi	a2,a2,-1276 # ffffffffc02057b8 <default_pmm_manager+0x6f0>
ffffffffc0202cbc:	02700593          	li	a1,39
ffffffffc0202cc0:	00003517          	auipc	a0,0x3
ffffffffc0202cc4:	b1850513          	addi	a0,a0,-1256 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202cc8:	eacfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202ccc:	00003697          	auipc	a3,0x3
ffffffffc0202cd0:	cb468693          	addi	a3,a3,-844 # ffffffffc0205980 <default_pmm_manager+0x8b8>
ffffffffc0202cd4:	00002617          	auipc	a2,0x2
ffffffffc0202cd8:	05c60613          	addi	a2,a2,92 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202cdc:	09500593          	li	a1,149
ffffffffc0202ce0:	00003517          	auipc	a0,0x3
ffffffffc0202ce4:	af850513          	addi	a0,a0,-1288 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202ce8:	e8cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202cec:	00003697          	auipc	a3,0x3
ffffffffc0202cf0:	c9468693          	addi	a3,a3,-876 # ffffffffc0205980 <default_pmm_manager+0x8b8>
ffffffffc0202cf4:	00002617          	auipc	a2,0x2
ffffffffc0202cf8:	03c60613          	addi	a2,a2,60 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202cfc:	09700593          	li	a1,151
ffffffffc0202d00:	00003517          	auipc	a0,0x3
ffffffffc0202d04:	ad850513          	addi	a0,a0,-1320 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202d08:	e6cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202d0c:	00003697          	auipc	a3,0x3
ffffffffc0202d10:	c8468693          	addi	a3,a3,-892 # ffffffffc0205990 <default_pmm_manager+0x8c8>
ffffffffc0202d14:	00002617          	auipc	a2,0x2
ffffffffc0202d18:	01c60613          	addi	a2,a2,28 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202d1c:	09900593          	li	a1,153
ffffffffc0202d20:	00003517          	auipc	a0,0x3
ffffffffc0202d24:	ab850513          	addi	a0,a0,-1352 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202d28:	e4cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202d2c:	00003697          	auipc	a3,0x3
ffffffffc0202d30:	c6468693          	addi	a3,a3,-924 # ffffffffc0205990 <default_pmm_manager+0x8c8>
ffffffffc0202d34:	00002617          	auipc	a2,0x2
ffffffffc0202d38:	ffc60613          	addi	a2,a2,-4 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202d3c:	09b00593          	li	a1,155
ffffffffc0202d40:	00003517          	auipc	a0,0x3
ffffffffc0202d44:	a9850513          	addi	a0,a0,-1384 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202d48:	e2cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202d4c:	00003697          	auipc	a3,0x3
ffffffffc0202d50:	c2468693          	addi	a3,a3,-988 # ffffffffc0205970 <default_pmm_manager+0x8a8>
ffffffffc0202d54:	00002617          	auipc	a2,0x2
ffffffffc0202d58:	fdc60613          	addi	a2,a2,-36 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202d5c:	09100593          	li	a1,145
ffffffffc0202d60:	00003517          	auipc	a0,0x3
ffffffffc0202d64:	a7850513          	addi	a0,a0,-1416 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202d68:	e0cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202d6c:	00003697          	auipc	a3,0x3
ffffffffc0202d70:	c0468693          	addi	a3,a3,-1020 # ffffffffc0205970 <default_pmm_manager+0x8a8>
ffffffffc0202d74:	00002617          	auipc	a2,0x2
ffffffffc0202d78:	fbc60613          	addi	a2,a2,-68 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202d7c:	09300593          	li	a1,147
ffffffffc0202d80:	00003517          	auipc	a0,0x3
ffffffffc0202d84:	a5850513          	addi	a0,a0,-1448 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202d88:	decfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202d8c:	00003697          	auipc	a3,0x3
ffffffffc0202d90:	b9468693          	addi	a3,a3,-1132 # ffffffffc0205920 <default_pmm_manager+0x858>
ffffffffc0202d94:	00002617          	auipc	a2,0x2
ffffffffc0202d98:	f9c60613          	addi	a2,a2,-100 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202d9c:	0e800593          	li	a1,232
ffffffffc0202da0:	00003517          	auipc	a0,0x3
ffffffffc0202da4:	a3850513          	addi	a0,a0,-1480 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202da8:	dccfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202dac:	00003697          	auipc	a3,0x3
ffffffffc0202db0:	afc68693          	addi	a3,a3,-1284 # ffffffffc02058a8 <default_pmm_manager+0x7e0>
ffffffffc0202db4:	00002617          	auipc	a2,0x2
ffffffffc0202db8:	f7c60613          	addi	a2,a2,-132 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202dbc:	0d500593          	li	a1,213
ffffffffc0202dc0:	00003517          	auipc	a0,0x3
ffffffffc0202dc4:	a1850513          	addi	a0,a0,-1512 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202dc8:	dacfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202dcc:	00003697          	auipc	a3,0x3
ffffffffc0202dd0:	bd468693          	addi	a3,a3,-1068 # ffffffffc02059a0 <default_pmm_manager+0x8d8>
ffffffffc0202dd4:	00002617          	auipc	a2,0x2
ffffffffc0202dd8:	f5c60613          	addi	a2,a2,-164 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202ddc:	09d00593          	li	a1,157
ffffffffc0202de0:	00003517          	auipc	a0,0x3
ffffffffc0202de4:	9f850513          	addi	a0,a0,-1544 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202de8:	d8cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202dec:	00003697          	auipc	a3,0x3
ffffffffc0202df0:	bb468693          	addi	a3,a3,-1100 # ffffffffc02059a0 <default_pmm_manager+0x8d8>
ffffffffc0202df4:	00002617          	auipc	a2,0x2
ffffffffc0202df8:	f3c60613          	addi	a2,a2,-196 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202dfc:	09f00593          	li	a1,159
ffffffffc0202e00:	00003517          	auipc	a0,0x3
ffffffffc0202e04:	9d850513          	addi	a0,a0,-1576 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202e08:	d6cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert( nr_free == 0);         
ffffffffc0202e0c:	00002697          	auipc	a3,0x2
ffffffffc0202e10:	0fc68693          	addi	a3,a3,252 # ffffffffc0204f08 <commands+0xaa8>
ffffffffc0202e14:	00002617          	auipc	a2,0x2
ffffffffc0202e18:	f1c60613          	addi	a2,a2,-228 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202e1c:	0f100593          	li	a1,241
ffffffffc0202e20:	00003517          	auipc	a0,0x3
ffffffffc0202e24:	9b850513          	addi	a0,a0,-1608 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202e28:	d4cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(ret==0);
ffffffffc0202e2c:	00003697          	auipc	a3,0x3
ffffffffc0202e30:	bec68693          	addi	a3,a3,-1044 # ffffffffc0205a18 <default_pmm_manager+0x950>
ffffffffc0202e34:	00002617          	auipc	a2,0x2
ffffffffc0202e38:	efc60613          	addi	a2,a2,-260 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202e3c:	10000593          	li	a1,256
ffffffffc0202e40:	00003517          	auipc	a0,0x3
ffffffffc0202e44:	99850513          	addi	a0,a0,-1640 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202e48:	d2cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(mm != NULL);
ffffffffc0202e4c:	00003697          	auipc	a3,0x3
ffffffffc0202e50:	9dc68693          	addi	a3,a3,-1572 # ffffffffc0205828 <default_pmm_manager+0x760>
ffffffffc0202e54:	00002617          	auipc	a2,0x2
ffffffffc0202e58:	edc60613          	addi	a2,a2,-292 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202e5c:	0c200593          	li	a1,194
ffffffffc0202e60:	00003517          	auipc	a0,0x3
ffffffffc0202e64:	97850513          	addi	a0,a0,-1672 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202e68:	d0cfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202e6c:	00003697          	auipc	a3,0x3
ffffffffc0202e70:	9cc68693          	addi	a3,a3,-1588 # ffffffffc0205838 <default_pmm_manager+0x770>
ffffffffc0202e74:	00002617          	auipc	a2,0x2
ffffffffc0202e78:	ebc60613          	addi	a2,a2,-324 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202e7c:	0c500593          	li	a1,197
ffffffffc0202e80:	00003517          	auipc	a0,0x3
ffffffffc0202e84:	95850513          	addi	a0,a0,-1704 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202e88:	cecfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202e8c:	00003697          	auipc	a3,0x3
ffffffffc0202e90:	9c468693          	addi	a3,a3,-1596 # ffffffffc0205850 <default_pmm_manager+0x788>
ffffffffc0202e94:	00002617          	auipc	a2,0x2
ffffffffc0202e98:	e9c60613          	addi	a2,a2,-356 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202e9c:	0ca00593          	li	a1,202
ffffffffc0202ea0:	00003517          	auipc	a0,0x3
ffffffffc0202ea4:	93850513          	addi	a0,a0,-1736 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202ea8:	cccfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(vma != NULL);
ffffffffc0202eac:	00003697          	auipc	a3,0x3
ffffffffc0202eb0:	9b468693          	addi	a3,a3,-1612 # ffffffffc0205860 <default_pmm_manager+0x798>
ffffffffc0202eb4:	00002617          	auipc	a2,0x2
ffffffffc0202eb8:	e7c60613          	addi	a2,a2,-388 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202ebc:	0cd00593          	li	a1,205
ffffffffc0202ec0:	00003517          	auipc	a0,0x3
ffffffffc0202ec4:	91850513          	addi	a0,a0,-1768 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202ec8:	cacfd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202ecc:	00002697          	auipc	a3,0x2
ffffffffc0202ed0:	e9468693          	addi	a3,a3,-364 # ffffffffc0204d60 <commands+0x900>
ffffffffc0202ed4:	00002617          	auipc	a2,0x2
ffffffffc0202ed8:	e5c60613          	addi	a2,a2,-420 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0202edc:	0bd00593          	li	a1,189
ffffffffc0202ee0:	00003517          	auipc	a0,0x3
ffffffffc0202ee4:	8f850513          	addi	a0,a0,-1800 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0202ee8:	c8cfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202eec <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202eec:	0000e797          	auipc	a5,0xe
ffffffffc0202ef0:	57478793          	addi	a5,a5,1396 # ffffffffc0211460 <sm>
ffffffffc0202ef4:	639c                	ld	a5,0(a5)
ffffffffc0202ef6:	0107b303          	ld	t1,16(a5)
ffffffffc0202efa:	8302                	jr	t1

ffffffffc0202efc <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202efc:	0000e797          	auipc	a5,0xe
ffffffffc0202f00:	56478793          	addi	a5,a5,1380 # ffffffffc0211460 <sm>
ffffffffc0202f04:	639c                	ld	a5,0(a5)
ffffffffc0202f06:	0207b303          	ld	t1,32(a5)
ffffffffc0202f0a:	8302                	jr	t1

ffffffffc0202f0c <swap_out>:
{
ffffffffc0202f0c:	711d                	addi	sp,sp,-96
ffffffffc0202f0e:	ec86                	sd	ra,88(sp)
ffffffffc0202f10:	e8a2                	sd	s0,80(sp)
ffffffffc0202f12:	e4a6                	sd	s1,72(sp)
ffffffffc0202f14:	e0ca                	sd	s2,64(sp)
ffffffffc0202f16:	fc4e                	sd	s3,56(sp)
ffffffffc0202f18:	f852                	sd	s4,48(sp)
ffffffffc0202f1a:	f456                	sd	s5,40(sp)
ffffffffc0202f1c:	f05a                	sd	s6,32(sp)
ffffffffc0202f1e:	ec5e                	sd	s7,24(sp)
ffffffffc0202f20:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202f22:	cde9                	beqz	a1,ffffffffc0202ffc <swap_out+0xf0>
ffffffffc0202f24:	8ab2                	mv	s5,a2
ffffffffc0202f26:	892a                	mv	s2,a0
ffffffffc0202f28:	8a2e                	mv	s4,a1
ffffffffc0202f2a:	4401                	li	s0,0
ffffffffc0202f2c:	0000e997          	auipc	s3,0xe
ffffffffc0202f30:	53498993          	addi	s3,s3,1332 # ffffffffc0211460 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f34:	00003b17          	auipc	s6,0x3
ffffffffc0202f38:	b8cb0b13          	addi	s6,s6,-1140 # ffffffffc0205ac0 <default_pmm_manager+0x9f8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202f3c:	00003b97          	auipc	s7,0x3
ffffffffc0202f40:	b6cb8b93          	addi	s7,s7,-1172 # ffffffffc0205aa8 <default_pmm_manager+0x9e0>
ffffffffc0202f44:	a825                	j	ffffffffc0202f7c <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f46:	67a2                	ld	a5,8(sp)
ffffffffc0202f48:	8626                	mv	a2,s1
ffffffffc0202f4a:	85a2                	mv	a1,s0
ffffffffc0202f4c:	63b4                	ld	a3,64(a5)
ffffffffc0202f4e:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202f50:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202f52:	82b1                	srli	a3,a3,0xc
ffffffffc0202f54:	0685                	addi	a3,a3,1
ffffffffc0202f56:	968fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f5a:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202f5c:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202f5e:	613c                	ld	a5,64(a0)
ffffffffc0202f60:	83b1                	srli	a5,a5,0xc
ffffffffc0202f62:	0785                	addi	a5,a5,1
ffffffffc0202f64:	07a2                	slli	a5,a5,0x8
ffffffffc0202f66:	00fc3023          	sd	a5,0(s8) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
                    free_page(page);
ffffffffc0202f6a:	fbcfe0ef          	jal	ra,ffffffffc0201726 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202f6e:	01893503          	ld	a0,24(s2)
ffffffffc0202f72:	85a6                	mv	a1,s1
ffffffffc0202f74:	ebeff0ef          	jal	ra,ffffffffc0202632 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202f78:	048a0d63          	beq	s4,s0,ffffffffc0202fd2 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202f7c:	0009b783          	ld	a5,0(s3)
ffffffffc0202f80:	8656                	mv	a2,s5
ffffffffc0202f82:	002c                	addi	a1,sp,8
ffffffffc0202f84:	7b9c                	ld	a5,48(a5)
ffffffffc0202f86:	854a                	mv	a0,s2
ffffffffc0202f88:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202f8a:	e12d                	bnez	a0,ffffffffc0202fec <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202f8c:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f8e:	01893503          	ld	a0,24(s2)
ffffffffc0202f92:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202f94:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f96:	85a6                	mv	a1,s1
ffffffffc0202f98:	815fe0ef          	jal	ra,ffffffffc02017ac <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202f9c:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f9e:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202fa0:	8b85                	andi	a5,a5,1
ffffffffc0202fa2:	cfb9                	beqz	a5,ffffffffc0203000 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202fa4:	65a2                	ld	a1,8(sp)
ffffffffc0202fa6:	61bc                	ld	a5,64(a1)
ffffffffc0202fa8:	83b1                	srli	a5,a5,0xc
ffffffffc0202faa:	00178513          	addi	a0,a5,1
ffffffffc0202fae:	0522                	slli	a0,a0,0x8
ffffffffc0202fb0:	55f000ef          	jal	ra,ffffffffc0203d0e <swapfs_write>
ffffffffc0202fb4:	d949                	beqz	a0,ffffffffc0202f46 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202fb6:	855e                	mv	a0,s7
ffffffffc0202fb8:	906fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202fbc:	0009b783          	ld	a5,0(s3)
ffffffffc0202fc0:	6622                	ld	a2,8(sp)
ffffffffc0202fc2:	4681                	li	a3,0
ffffffffc0202fc4:	739c                	ld	a5,32(a5)
ffffffffc0202fc6:	85a6                	mv	a1,s1
ffffffffc0202fc8:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202fca:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202fcc:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202fce:	fa8a17e3          	bne	s4,s0,ffffffffc0202f7c <swap_out+0x70>
}
ffffffffc0202fd2:	8522                	mv	a0,s0
ffffffffc0202fd4:	60e6                	ld	ra,88(sp)
ffffffffc0202fd6:	6446                	ld	s0,80(sp)
ffffffffc0202fd8:	64a6                	ld	s1,72(sp)
ffffffffc0202fda:	6906                	ld	s2,64(sp)
ffffffffc0202fdc:	79e2                	ld	s3,56(sp)
ffffffffc0202fde:	7a42                	ld	s4,48(sp)
ffffffffc0202fe0:	7aa2                	ld	s5,40(sp)
ffffffffc0202fe2:	7b02                	ld	s6,32(sp)
ffffffffc0202fe4:	6be2                	ld	s7,24(sp)
ffffffffc0202fe6:	6c42                	ld	s8,16(sp)
ffffffffc0202fe8:	6125                	addi	sp,sp,96
ffffffffc0202fea:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202fec:	85a2                	mv	a1,s0
ffffffffc0202fee:	00003517          	auipc	a0,0x3
ffffffffc0202ff2:	a7250513          	addi	a0,a0,-1422 # ffffffffc0205a60 <default_pmm_manager+0x998>
ffffffffc0202ff6:	8c8fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                  break;
ffffffffc0202ffa:	bfe1                	j	ffffffffc0202fd2 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202ffc:	4401                	li	s0,0
ffffffffc0202ffe:	bfd1                	j	ffffffffc0202fd2 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203000:	00003697          	auipc	a3,0x3
ffffffffc0203004:	a9068693          	addi	a3,a3,-1392 # ffffffffc0205a90 <default_pmm_manager+0x9c8>
ffffffffc0203008:	00002617          	auipc	a2,0x2
ffffffffc020300c:	d2860613          	addi	a2,a2,-728 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0203010:	06600593          	li	a1,102
ffffffffc0203014:	00002517          	auipc	a0,0x2
ffffffffc0203018:	7c450513          	addi	a0,a0,1988 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc020301c:	b58fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203020 <swap_in>:
{
ffffffffc0203020:	7179                	addi	sp,sp,-48
ffffffffc0203022:	e84a                	sd	s2,16(sp)
ffffffffc0203024:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203026:	4505                	li	a0,1
{
ffffffffc0203028:	ec26                	sd	s1,24(sp)
ffffffffc020302a:	e44e                	sd	s3,8(sp)
ffffffffc020302c:	f406                	sd	ra,40(sp)
ffffffffc020302e:	f022                	sd	s0,32(sp)
ffffffffc0203030:	84ae                	mv	s1,a1
ffffffffc0203032:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203034:	e6afe0ef          	jal	ra,ffffffffc020169e <alloc_pages>
     assert(result!=NULL);
ffffffffc0203038:	c129                	beqz	a0,ffffffffc020307a <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc020303a:	842a                	mv	s0,a0
ffffffffc020303c:	01893503          	ld	a0,24(s2)
ffffffffc0203040:	4601                	li	a2,0
ffffffffc0203042:	85a6                	mv	a1,s1
ffffffffc0203044:	f68fe0ef          	jal	ra,ffffffffc02017ac <get_pte>
ffffffffc0203048:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc020304a:	6108                	ld	a0,0(a0)
ffffffffc020304c:	85a2                	mv	a1,s0
ffffffffc020304e:	41b000ef          	jal	ra,ffffffffc0203c68 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203052:	00093583          	ld	a1,0(s2)
ffffffffc0203056:	8626                	mv	a2,s1
ffffffffc0203058:	00002517          	auipc	a0,0x2
ffffffffc020305c:	72050513          	addi	a0,a0,1824 # ffffffffc0205778 <default_pmm_manager+0x6b0>
ffffffffc0203060:	81a1                	srli	a1,a1,0x8
ffffffffc0203062:	85cfd0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0203066:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203068:	0089b023          	sd	s0,0(s3)
}
ffffffffc020306c:	7402                	ld	s0,32(sp)
ffffffffc020306e:	64e2                	ld	s1,24(sp)
ffffffffc0203070:	6942                	ld	s2,16(sp)
ffffffffc0203072:	69a2                	ld	s3,8(sp)
ffffffffc0203074:	4501                	li	a0,0
ffffffffc0203076:	6145                	addi	sp,sp,48
ffffffffc0203078:	8082                	ret
     assert(result!=NULL);
ffffffffc020307a:	00002697          	auipc	a3,0x2
ffffffffc020307e:	6ee68693          	addi	a3,a3,1774 # ffffffffc0205768 <default_pmm_manager+0x6a0>
ffffffffc0203082:	00002617          	auipc	a2,0x2
ffffffffc0203086:	cae60613          	addi	a2,a2,-850 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020308a:	07c00593          	li	a1,124
ffffffffc020308e:	00002517          	auipc	a0,0x2
ffffffffc0203092:	74a50513          	addi	a0,a0,1866 # ffffffffc02057d8 <default_pmm_manager+0x710>
ffffffffc0203096:	adefd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020309a <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc020309a:	4501                	li	a0,0
ffffffffc020309c:	8082                	ret

ffffffffc020309e <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc020309e:	4501                	li	a0,0
ffffffffc02030a0:	8082                	ret

ffffffffc02030a2 <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc02030a2:	4501                	li	a0,0
ffffffffc02030a4:	8082                	ret

ffffffffc02030a6 <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc02030a6:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02030a8:	678d                	lui	a5,0x3
ffffffffc02030aa:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc02030ac:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02030ae:	00e78023          	sb	a4,0(a5) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc02030b2:	0000e797          	auipc	a5,0xe
ffffffffc02030b6:	3ba78793          	addi	a5,a5,954 # ffffffffc021146c <pgfault_num>
ffffffffc02030ba:	4398                	lw	a4,0(a5)
ffffffffc02030bc:	4691                	li	a3,4
ffffffffc02030be:	2701                	sext.w	a4,a4
ffffffffc02030c0:	08d71f63          	bne	a4,a3,ffffffffc020315e <_clock_check_swap+0xb8>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc02030c4:	6685                	lui	a3,0x1
ffffffffc02030c6:	4629                	li	a2,10
ffffffffc02030c8:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc02030cc:	4394                	lw	a3,0(a5)
ffffffffc02030ce:	2681                	sext.w	a3,a3
ffffffffc02030d0:	20e69763          	bne	a3,a4,ffffffffc02032de <_clock_check_swap+0x238>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02030d4:	6711                	lui	a4,0x4
ffffffffc02030d6:	4635                	li	a2,13
ffffffffc02030d8:	00c70023          	sb	a2,0(a4) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc02030dc:	4398                	lw	a4,0(a5)
ffffffffc02030de:	2701                	sext.w	a4,a4
ffffffffc02030e0:	1cd71f63          	bne	a4,a3,ffffffffc02032be <_clock_check_swap+0x218>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc02030e4:	6689                	lui	a3,0x2
ffffffffc02030e6:	462d                	li	a2,11
ffffffffc02030e8:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc02030ec:	4394                	lw	a3,0(a5)
ffffffffc02030ee:	2681                	sext.w	a3,a3
ffffffffc02030f0:	1ae69763          	bne	a3,a4,ffffffffc020329e <_clock_check_swap+0x1f8>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02030f4:	6715                	lui	a4,0x5
ffffffffc02030f6:	46b9                	li	a3,14
ffffffffc02030f8:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02030fc:	4398                	lw	a4,0(a5)
ffffffffc02030fe:	4695                	li	a3,5
ffffffffc0203100:	2701                	sext.w	a4,a4
ffffffffc0203102:	16d71e63          	bne	a4,a3,ffffffffc020327e <_clock_check_swap+0x1d8>
    assert(pgfault_num==5);
ffffffffc0203106:	4394                	lw	a3,0(a5)
ffffffffc0203108:	2681                	sext.w	a3,a3
ffffffffc020310a:	14e69a63          	bne	a3,a4,ffffffffc020325e <_clock_check_swap+0x1b8>
    assert(pgfault_num==5);
ffffffffc020310e:	4398                	lw	a4,0(a5)
ffffffffc0203110:	2701                	sext.w	a4,a4
ffffffffc0203112:	12d71663          	bne	a4,a3,ffffffffc020323e <_clock_check_swap+0x198>
    assert(pgfault_num==5);
ffffffffc0203116:	4394                	lw	a3,0(a5)
ffffffffc0203118:	2681                	sext.w	a3,a3
ffffffffc020311a:	10e69263          	bne	a3,a4,ffffffffc020321e <_clock_check_swap+0x178>
    assert(pgfault_num==5);
ffffffffc020311e:	4398                	lw	a4,0(a5)
ffffffffc0203120:	2701                	sext.w	a4,a4
ffffffffc0203122:	0cd71e63          	bne	a4,a3,ffffffffc02031fe <_clock_check_swap+0x158>
    assert(pgfault_num==5);
ffffffffc0203126:	4394                	lw	a3,0(a5)
ffffffffc0203128:	2681                	sext.w	a3,a3
ffffffffc020312a:	0ae69a63          	bne	a3,a4,ffffffffc02031de <_clock_check_swap+0x138>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc020312e:	6715                	lui	a4,0x5
ffffffffc0203130:	46b9                	li	a3,14
ffffffffc0203132:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203136:	4398                	lw	a4,0(a5)
ffffffffc0203138:	4695                	li	a3,5
ffffffffc020313a:	2701                	sext.w	a4,a4
ffffffffc020313c:	08d71163          	bne	a4,a3,ffffffffc02031be <_clock_check_swap+0x118>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203140:	6705                	lui	a4,0x1
ffffffffc0203142:	00074683          	lbu	a3,0(a4) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
ffffffffc0203146:	4729                	li	a4,10
ffffffffc0203148:	04e69b63          	bne	a3,a4,ffffffffc020319e <_clock_check_swap+0xf8>
    assert(pgfault_num==6);
ffffffffc020314c:	439c                	lw	a5,0(a5)
ffffffffc020314e:	4719                	li	a4,6
ffffffffc0203150:	2781                	sext.w	a5,a5
ffffffffc0203152:	02e79663          	bne	a5,a4,ffffffffc020317e <_clock_check_swap+0xd8>
}
ffffffffc0203156:	60a2                	ld	ra,8(sp)
ffffffffc0203158:	4501                	li	a0,0
ffffffffc020315a:	0141                	addi	sp,sp,16
ffffffffc020315c:	8082                	ret
    assert(pgfault_num==4);
ffffffffc020315e:	00003697          	auipc	a3,0x3
ffffffffc0203162:	84268693          	addi	a3,a3,-1982 # ffffffffc02059a0 <default_pmm_manager+0x8d8>
ffffffffc0203166:	00002617          	auipc	a2,0x2
ffffffffc020316a:	bca60613          	addi	a2,a2,-1078 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020316e:	0a100593          	li	a1,161
ffffffffc0203172:	00003517          	auipc	a0,0x3
ffffffffc0203176:	98e50513          	addi	a0,a0,-1650 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc020317a:	9fafd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==6);
ffffffffc020317e:	00003697          	auipc	a3,0x3
ffffffffc0203182:	9d268693          	addi	a3,a3,-1582 # ffffffffc0205b50 <default_pmm_manager+0xa88>
ffffffffc0203186:	00002617          	auipc	a2,0x2
ffffffffc020318a:	baa60613          	addi	a2,a2,-1110 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020318e:	0b800593          	li	a1,184
ffffffffc0203192:	00003517          	auipc	a0,0x3
ffffffffc0203196:	96e50513          	addi	a0,a0,-1682 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc020319a:	9dafd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc020319e:	00003697          	auipc	a3,0x3
ffffffffc02031a2:	98a68693          	addi	a3,a3,-1654 # ffffffffc0205b28 <default_pmm_manager+0xa60>
ffffffffc02031a6:	00002617          	auipc	a2,0x2
ffffffffc02031aa:	b8a60613          	addi	a2,a2,-1142 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02031ae:	0b600593          	li	a1,182
ffffffffc02031b2:	00003517          	auipc	a0,0x3
ffffffffc02031b6:	94e50513          	addi	a0,a0,-1714 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc02031ba:	9bafd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02031be:	00003697          	auipc	a3,0x3
ffffffffc02031c2:	95a68693          	addi	a3,a3,-1702 # ffffffffc0205b18 <default_pmm_manager+0xa50>
ffffffffc02031c6:	00002617          	auipc	a2,0x2
ffffffffc02031ca:	b6a60613          	addi	a2,a2,-1174 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02031ce:	0b500593          	li	a1,181
ffffffffc02031d2:	00003517          	auipc	a0,0x3
ffffffffc02031d6:	92e50513          	addi	a0,a0,-1746 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc02031da:	99afd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02031de:	00003697          	auipc	a3,0x3
ffffffffc02031e2:	93a68693          	addi	a3,a3,-1734 # ffffffffc0205b18 <default_pmm_manager+0xa50>
ffffffffc02031e6:	00002617          	auipc	a2,0x2
ffffffffc02031ea:	b4a60613          	addi	a2,a2,-1206 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02031ee:	0b300593          	li	a1,179
ffffffffc02031f2:	00003517          	auipc	a0,0x3
ffffffffc02031f6:	90e50513          	addi	a0,a0,-1778 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc02031fa:	97afd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02031fe:	00003697          	auipc	a3,0x3
ffffffffc0203202:	91a68693          	addi	a3,a3,-1766 # ffffffffc0205b18 <default_pmm_manager+0xa50>
ffffffffc0203206:	00002617          	auipc	a2,0x2
ffffffffc020320a:	b2a60613          	addi	a2,a2,-1238 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020320e:	0b100593          	li	a1,177
ffffffffc0203212:	00003517          	auipc	a0,0x3
ffffffffc0203216:	8ee50513          	addi	a0,a0,-1810 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc020321a:	95afd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc020321e:	00003697          	auipc	a3,0x3
ffffffffc0203222:	8fa68693          	addi	a3,a3,-1798 # ffffffffc0205b18 <default_pmm_manager+0xa50>
ffffffffc0203226:	00002617          	auipc	a2,0x2
ffffffffc020322a:	b0a60613          	addi	a2,a2,-1270 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020322e:	0af00593          	li	a1,175
ffffffffc0203232:	00003517          	auipc	a0,0x3
ffffffffc0203236:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc020323a:	93afd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc020323e:	00003697          	auipc	a3,0x3
ffffffffc0203242:	8da68693          	addi	a3,a3,-1830 # ffffffffc0205b18 <default_pmm_manager+0xa50>
ffffffffc0203246:	00002617          	auipc	a2,0x2
ffffffffc020324a:	aea60613          	addi	a2,a2,-1302 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020324e:	0ad00593          	li	a1,173
ffffffffc0203252:	00003517          	auipc	a0,0x3
ffffffffc0203256:	8ae50513          	addi	a0,a0,-1874 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc020325a:	91afd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc020325e:	00003697          	auipc	a3,0x3
ffffffffc0203262:	8ba68693          	addi	a3,a3,-1862 # ffffffffc0205b18 <default_pmm_manager+0xa50>
ffffffffc0203266:	00002617          	auipc	a2,0x2
ffffffffc020326a:	aca60613          	addi	a2,a2,-1334 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020326e:	0ab00593          	li	a1,171
ffffffffc0203272:	00003517          	auipc	a0,0x3
ffffffffc0203276:	88e50513          	addi	a0,a0,-1906 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc020327a:	8fafd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc020327e:	00003697          	auipc	a3,0x3
ffffffffc0203282:	89a68693          	addi	a3,a3,-1894 # ffffffffc0205b18 <default_pmm_manager+0xa50>
ffffffffc0203286:	00002617          	auipc	a2,0x2
ffffffffc020328a:	aaa60613          	addi	a2,a2,-1366 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020328e:	0a900593          	li	a1,169
ffffffffc0203292:	00003517          	auipc	a0,0x3
ffffffffc0203296:	86e50513          	addi	a0,a0,-1938 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc020329a:	8dafd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc020329e:	00002697          	auipc	a3,0x2
ffffffffc02032a2:	70268693          	addi	a3,a3,1794 # ffffffffc02059a0 <default_pmm_manager+0x8d8>
ffffffffc02032a6:	00002617          	auipc	a2,0x2
ffffffffc02032aa:	a8a60613          	addi	a2,a2,-1398 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02032ae:	0a700593          	li	a1,167
ffffffffc02032b2:	00003517          	auipc	a0,0x3
ffffffffc02032b6:	84e50513          	addi	a0,a0,-1970 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc02032ba:	8bafd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc02032be:	00002697          	auipc	a3,0x2
ffffffffc02032c2:	6e268693          	addi	a3,a3,1762 # ffffffffc02059a0 <default_pmm_manager+0x8d8>
ffffffffc02032c6:	00002617          	auipc	a2,0x2
ffffffffc02032ca:	a6a60613          	addi	a2,a2,-1430 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02032ce:	0a500593          	li	a1,165
ffffffffc02032d2:	00003517          	auipc	a0,0x3
ffffffffc02032d6:	82e50513          	addi	a0,a0,-2002 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc02032da:	89afd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc02032de:	00002697          	auipc	a3,0x2
ffffffffc02032e2:	6c268693          	addi	a3,a3,1730 # ffffffffc02059a0 <default_pmm_manager+0x8d8>
ffffffffc02032e6:	00002617          	auipc	a2,0x2
ffffffffc02032ea:	a4a60613          	addi	a2,a2,-1462 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02032ee:	0a300593          	li	a1,163
ffffffffc02032f2:	00003517          	auipc	a0,0x3
ffffffffc02032f6:	80e50513          	addi	a0,a0,-2034 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc02032fa:	87afd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02032fe <_clock_init_mm>:
{     
ffffffffc02032fe:	1141                	addi	sp,sp,-16
ffffffffc0203300:	e406                	sd	ra,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0203302:	0000e797          	auipc	a5,0xe
ffffffffc0203306:	27678793          	addi	a5,a5,630 # ffffffffc0211578 <pra_list_head>
     mm->sm_priv = &pra_list_head;
ffffffffc020330a:	f51c                	sd	a5,40(a0)
     cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
ffffffffc020330c:	85be                	mv	a1,a5
ffffffffc020330e:	00003517          	auipc	a0,0x3
ffffffffc0203312:	85250513          	addi	a0,a0,-1966 # ffffffffc0205b60 <default_pmm_manager+0xa98>
ffffffffc0203316:	e79c                	sd	a5,8(a5)
ffffffffc0203318:	e39c                	sd	a5,0(a5)
     curr_ptr = &pra_list_head;
ffffffffc020331a:	0000e717          	auipc	a4,0xe
ffffffffc020331e:	26f73723          	sd	a5,622(a4) # ffffffffc0211588 <curr_ptr>
     cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
ffffffffc0203322:	d9dfc0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0203326:	60a2                	ld	ra,8(sp)
ffffffffc0203328:	4501                	li	a0,0
ffffffffc020332a:	0141                	addi	sp,sp,16
ffffffffc020332c:	8082                	ret

ffffffffc020332e <_clock_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc020332e:	03060793          	addi	a5,a2,48
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203332:	c38d                	beqz	a5,ffffffffc0203354 <_clock_map_swappable+0x26>
ffffffffc0203334:	0000e717          	auipc	a4,0xe
ffffffffc0203338:	25470713          	addi	a4,a4,596 # ffffffffc0211588 <curr_ptr>
ffffffffc020333c:	6318                	ld	a4,0(a4)
ffffffffc020333e:	cb19                	beqz	a4,ffffffffc0203354 <_clock_map_swappable+0x26>
    list_add_before(mm->sm_priv,entry);
ffffffffc0203340:	7518                	ld	a4,40(a0)
}
ffffffffc0203342:	4501                	li	a0,0
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203344:	6314                	ld	a3,0(a4)
    prev->next = next->prev = elm;
ffffffffc0203346:	e31c                	sd	a5,0(a4)
ffffffffc0203348:	e69c                	sd	a5,8(a3)
    page->visited = 1;
ffffffffc020334a:	4785                	li	a5,1
    elm->next = next;
ffffffffc020334c:	fe18                	sd	a4,56(a2)
    elm->prev = prev;
ffffffffc020334e:	fa14                	sd	a3,48(a2)
ffffffffc0203350:	ea1c                	sd	a5,16(a2)
}
ffffffffc0203352:	8082                	ret
{
ffffffffc0203354:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203356:	00003697          	auipc	a3,0x3
ffffffffc020335a:	83268693          	addi	a3,a3,-1998 # ffffffffc0205b88 <default_pmm_manager+0xac0>
ffffffffc020335e:	00002617          	auipc	a2,0x2
ffffffffc0203362:	9d260613          	addi	a2,a2,-1582 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0203366:	03a00593          	li	a1,58
ffffffffc020336a:	00002517          	auipc	a0,0x2
ffffffffc020336e:	79650513          	addi	a0,a0,1942 # ffffffffc0205b00 <default_pmm_manager+0xa38>
{
ffffffffc0203372:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203374:	800fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203378 <_clock_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203378:	7508                	ld	a0,40(a0)
{
ffffffffc020337a:	1141                	addi	sp,sp,-16
ffffffffc020337c:	e406                	sd	ra,8(sp)
ffffffffc020337e:	e022                	sd	s0,0(sp)
         assert(head != NULL);
ffffffffc0203380:	c525                	beqz	a0,ffffffffc02033e8 <_clock_swap_out_victim+0x70>
     assert(in_tick==0);
ffffffffc0203382:	e259                	bnez	a2,ffffffffc0203408 <_clock_swap_out_victim+0x90>
ffffffffc0203384:	0000e417          	auipc	s0,0xe
ffffffffc0203388:	20440413          	addi	s0,s0,516 # ffffffffc0211588 <curr_ptr>
ffffffffc020338c:	601c                	ld	a5,0(s0)
ffffffffc020338e:	4681                	li	a3,0
    return listelm->next;
ffffffffc0203390:	4605                	li	a2,1
        if (curr_ptr == head)
ffffffffc0203392:	00a78c63          	beq	a5,a0,ffffffffc02033aa <_clock_swap_out_victim+0x32>
        if (page->visited == 1) {
ffffffffc0203396:	fe07b703          	ld	a4,-32(a5)
ffffffffc020339a:	00c71e63          	bne	a4,a2,ffffffffc02033b6 <_clock_swap_out_victim+0x3e>
            page->visited = 0;
ffffffffc020339e:	fe07b023          	sd	zero,-32(a5)
ffffffffc02033a2:	679c                	ld	a5,8(a5)
        if (curr_ptr == head)
ffffffffc02033a4:	4685                	li	a3,1
ffffffffc02033a6:	fea798e3          	bne	a5,a0,ffffffffc0203396 <_clock_swap_out_victim+0x1e>
ffffffffc02033aa:	679c                	ld	a5,8(a5)
ffffffffc02033ac:	4685                	li	a3,1
        if (page->visited == 1) {
ffffffffc02033ae:	fe07b703          	ld	a4,-32(a5)
ffffffffc02033b2:	fec706e3          	beq	a4,a2,ffffffffc020339e <_clock_swap_out_victim+0x26>
ffffffffc02033b6:	c689                	beqz	a3,ffffffffc02033c0 <_clock_swap_out_victim+0x48>
ffffffffc02033b8:	0000e717          	auipc	a4,0xe
ffffffffc02033bc:	1cf73823          	sd	a5,464(a4) # ffffffffc0211588 <curr_ptr>
        struct Page *page = le2page(curr_ptr, pra_page_link);
ffffffffc02033c0:	fd078713          	addi	a4,a5,-48
            *ptr_page = page;
ffffffffc02033c4:	e198                	sd	a4,0(a1)
            cprintf("curr_ptr %p\n",curr_ptr);
ffffffffc02033c6:	00003517          	auipc	a0,0x3
ffffffffc02033ca:	80a50513          	addi	a0,a0,-2038 # ffffffffc0205bd0 <default_pmm_manager+0xb08>
ffffffffc02033ce:	85be                	mv	a1,a5
ffffffffc02033d0:	ceffc0ef          	jal	ra,ffffffffc02000be <cprintf>
            list_del(curr_ptr);           
ffffffffc02033d4:	601c                	ld	a5,0(s0)
}
ffffffffc02033d6:	60a2                	ld	ra,8(sp)
ffffffffc02033d8:	6402                	ld	s0,0(sp)
    __list_del(listelm->prev, listelm->next);
ffffffffc02033da:	6398                	ld	a4,0(a5)
ffffffffc02033dc:	679c                	ld	a5,8(a5)
ffffffffc02033de:	4501                	li	a0,0
    prev->next = next;
ffffffffc02033e0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02033e2:	e398                	sd	a4,0(a5)
ffffffffc02033e4:	0141                	addi	sp,sp,16
ffffffffc02033e6:	8082                	ret
         assert(head != NULL);
ffffffffc02033e8:	00002697          	auipc	a3,0x2
ffffffffc02033ec:	7c868693          	addi	a3,a3,1992 # ffffffffc0205bb0 <default_pmm_manager+0xae8>
ffffffffc02033f0:	00002617          	auipc	a2,0x2
ffffffffc02033f4:	94060613          	addi	a2,a2,-1728 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02033f8:	05100593          	li	a1,81
ffffffffc02033fc:	00002517          	auipc	a0,0x2
ffffffffc0203400:	70450513          	addi	a0,a0,1796 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc0203404:	f71fc0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(in_tick==0);
ffffffffc0203408:	00002697          	auipc	a3,0x2
ffffffffc020340c:	7b868693          	addi	a3,a3,1976 # ffffffffc0205bc0 <default_pmm_manager+0xaf8>
ffffffffc0203410:	00002617          	auipc	a2,0x2
ffffffffc0203414:	92060613          	addi	a2,a2,-1760 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0203418:	05200593          	li	a1,82
ffffffffc020341c:	00002517          	auipc	a0,0x2
ffffffffc0203420:	6e450513          	addi	a0,a0,1764 # ffffffffc0205b00 <default_pmm_manager+0xa38>
ffffffffc0203424:	f51fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203428 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203428:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020342a:	00002697          	auipc	a3,0x2
ffffffffc020342e:	7ce68693          	addi	a3,a3,1998 # ffffffffc0205bf8 <default_pmm_manager+0xb30>
ffffffffc0203432:	00002617          	auipc	a2,0x2
ffffffffc0203436:	8fe60613          	addi	a2,a2,-1794 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020343a:	07d00593          	li	a1,125
ffffffffc020343e:	00002517          	auipc	a0,0x2
ffffffffc0203442:	7da50513          	addi	a0,a0,2010 # ffffffffc0205c18 <default_pmm_manager+0xb50>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203446:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0203448:	f2dfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020344c <mm_create>:
mm_create(void) {
ffffffffc020344c:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020344e:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0203452:	e022                	sd	s0,0(sp)
ffffffffc0203454:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203456:	a74ff0ef          	jal	ra,ffffffffc02026ca <kmalloc>
ffffffffc020345a:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc020345c:	c115                	beqz	a0,ffffffffc0203480 <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020345e:	0000e797          	auipc	a5,0xe
ffffffffc0203462:	00a78793          	addi	a5,a5,10 # ffffffffc0211468 <swap_init_ok>
ffffffffc0203466:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0203468:	e408                	sd	a0,8(s0)
ffffffffc020346a:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc020346c:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203470:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203474:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203478:	2781                	sext.w	a5,a5
ffffffffc020347a:	eb81                	bnez	a5,ffffffffc020348a <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc020347c:	02053423          	sd	zero,40(a0)
}
ffffffffc0203480:	8522                	mv	a0,s0
ffffffffc0203482:	60a2                	ld	ra,8(sp)
ffffffffc0203484:	6402                	ld	s0,0(sp)
ffffffffc0203486:	0141                	addi	sp,sp,16
ffffffffc0203488:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020348a:	a63ff0ef          	jal	ra,ffffffffc0202eec <swap_init_mm>
}
ffffffffc020348e:	8522                	mv	a0,s0
ffffffffc0203490:	60a2                	ld	ra,8(sp)
ffffffffc0203492:	6402                	ld	s0,0(sp)
ffffffffc0203494:	0141                	addi	sp,sp,16
ffffffffc0203496:	8082                	ret

ffffffffc0203498 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0203498:	1101                	addi	sp,sp,-32
ffffffffc020349a:	e04a                	sd	s2,0(sp)
ffffffffc020349c:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020349e:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc02034a2:	e822                	sd	s0,16(sp)
ffffffffc02034a4:	e426                	sd	s1,8(sp)
ffffffffc02034a6:	ec06                	sd	ra,24(sp)
ffffffffc02034a8:	84ae                	mv	s1,a1
ffffffffc02034aa:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02034ac:	a1eff0ef          	jal	ra,ffffffffc02026ca <kmalloc>
    if (vma != NULL) {
ffffffffc02034b0:	c509                	beqz	a0,ffffffffc02034ba <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02034b2:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02034b6:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02034b8:	ed00                	sd	s0,24(a0)
}
ffffffffc02034ba:	60e2                	ld	ra,24(sp)
ffffffffc02034bc:	6442                	ld	s0,16(sp)
ffffffffc02034be:	64a2                	ld	s1,8(sp)
ffffffffc02034c0:	6902                	ld	s2,0(sp)
ffffffffc02034c2:	6105                	addi	sp,sp,32
ffffffffc02034c4:	8082                	ret

ffffffffc02034c6 <find_vma>:
    if (mm != NULL) {
ffffffffc02034c6:	c51d                	beqz	a0,ffffffffc02034f4 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc02034c8:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02034ca:	c781                	beqz	a5,ffffffffc02034d2 <find_vma+0xc>
ffffffffc02034cc:	6798                	ld	a4,8(a5)
ffffffffc02034ce:	02e5f663          	bleu	a4,a1,ffffffffc02034fa <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc02034d2:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc02034d4:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc02034d6:	00f50f63          	beq	a0,a5,ffffffffc02034f4 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02034da:	fe87b703          	ld	a4,-24(a5)
ffffffffc02034de:	fee5ebe3          	bltu	a1,a4,ffffffffc02034d4 <find_vma+0xe>
ffffffffc02034e2:	ff07b703          	ld	a4,-16(a5)
ffffffffc02034e6:	fee5f7e3          	bleu	a4,a1,ffffffffc02034d4 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc02034ea:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc02034ec:	c781                	beqz	a5,ffffffffc02034f4 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc02034ee:	e91c                	sd	a5,16(a0)
}
ffffffffc02034f0:	853e                	mv	a0,a5
ffffffffc02034f2:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc02034f4:	4781                	li	a5,0
}
ffffffffc02034f6:	853e                	mv	a0,a5
ffffffffc02034f8:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02034fa:	6b98                	ld	a4,16(a5)
ffffffffc02034fc:	fce5fbe3          	bleu	a4,a1,ffffffffc02034d2 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0203500:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0203502:	b7fd                	j	ffffffffc02034f0 <find_vma+0x2a>

ffffffffc0203504 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203504:	6590                	ld	a2,8(a1)
ffffffffc0203506:	0105b803          	ld	a6,16(a1) # 1010 <BASE_ADDRESS-0xffffffffc01feff0>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc020350a:	1141                	addi	sp,sp,-16
ffffffffc020350c:	e406                	sd	ra,8(sp)
ffffffffc020350e:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203510:	01066863          	bltu	a2,a6,ffffffffc0203520 <insert_vma_struct+0x1c>
ffffffffc0203514:	a8b9                	j	ffffffffc0203572 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203516:	fe87b683          	ld	a3,-24(a5)
ffffffffc020351a:	04d66763          	bltu	a2,a3,ffffffffc0203568 <insert_vma_struct+0x64>
ffffffffc020351e:	873e                	mv	a4,a5
ffffffffc0203520:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0203522:	fef51ae3          	bne	a0,a5,ffffffffc0203516 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0203526:	02a70463          	beq	a4,a0,ffffffffc020354e <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020352a:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc020352e:	fe873883          	ld	a7,-24(a4)
ffffffffc0203532:	08d8f063          	bleu	a3,a7,ffffffffc02035b2 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203536:	04d66e63          	bltu	a2,a3,ffffffffc0203592 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc020353a:	00f50a63          	beq	a0,a5,ffffffffc020354e <insert_vma_struct+0x4a>
ffffffffc020353e:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203542:	0506e863          	bltu	a3,a6,ffffffffc0203592 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0203546:	ff07b603          	ld	a2,-16(a5)
ffffffffc020354a:	02c6f263          	bleu	a2,a3,ffffffffc020356e <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc020354e:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc0203550:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203552:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203556:	e390                	sd	a2,0(a5)
ffffffffc0203558:	e710                	sd	a2,8(a4)
}
ffffffffc020355a:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc020355c:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc020355e:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc0203560:	2685                	addiw	a3,a3,1
ffffffffc0203562:	d114                	sw	a3,32(a0)
}
ffffffffc0203564:	0141                	addi	sp,sp,16
ffffffffc0203566:	8082                	ret
    if (le_prev != list) {
ffffffffc0203568:	fca711e3          	bne	a4,a0,ffffffffc020352a <insert_vma_struct+0x26>
ffffffffc020356c:	bfd9                	j	ffffffffc0203542 <insert_vma_struct+0x3e>
ffffffffc020356e:	ebbff0ef          	jal	ra,ffffffffc0203428 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203572:	00002697          	auipc	a3,0x2
ffffffffc0203576:	74668693          	addi	a3,a3,1862 # ffffffffc0205cb8 <default_pmm_manager+0xbf0>
ffffffffc020357a:	00001617          	auipc	a2,0x1
ffffffffc020357e:	7b660613          	addi	a2,a2,1974 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0203582:	08400593          	li	a1,132
ffffffffc0203586:	00002517          	auipc	a0,0x2
ffffffffc020358a:	69250513          	addi	a0,a0,1682 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc020358e:	de7fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203592:	00002697          	auipc	a3,0x2
ffffffffc0203596:	76668693          	addi	a3,a3,1894 # ffffffffc0205cf8 <default_pmm_manager+0xc30>
ffffffffc020359a:	00001617          	auipc	a2,0x1
ffffffffc020359e:	79660613          	addi	a2,a2,1942 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02035a2:	07c00593          	li	a1,124
ffffffffc02035a6:	00002517          	auipc	a0,0x2
ffffffffc02035aa:	67250513          	addi	a0,a0,1650 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc02035ae:	dc7fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02035b2:	00002697          	auipc	a3,0x2
ffffffffc02035b6:	72668693          	addi	a3,a3,1830 # ffffffffc0205cd8 <default_pmm_manager+0xc10>
ffffffffc02035ba:	00001617          	auipc	a2,0x1
ffffffffc02035be:	77660613          	addi	a2,a2,1910 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02035c2:	07b00593          	li	a1,123
ffffffffc02035c6:	00002517          	auipc	a0,0x2
ffffffffc02035ca:	65250513          	addi	a0,a0,1618 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc02035ce:	da7fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02035d2 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc02035d2:	1141                	addi	sp,sp,-16
ffffffffc02035d4:	e022                	sd	s0,0(sp)
ffffffffc02035d6:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02035d8:	6508                	ld	a0,8(a0)
ffffffffc02035da:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc02035dc:	00a40e63          	beq	s0,a0,ffffffffc02035f8 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02035e0:	6118                	ld	a4,0(a0)
ffffffffc02035e2:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc02035e4:	03000593          	li	a1,48
ffffffffc02035e8:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02035ea:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02035ec:	e398                	sd	a4,0(a5)
ffffffffc02035ee:	99eff0ef          	jal	ra,ffffffffc020278c <kfree>
    return listelm->next;
ffffffffc02035f2:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc02035f4:	fea416e3          	bne	s0,a0,ffffffffc02035e0 <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02035f8:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc02035fa:	6402                	ld	s0,0(sp)
ffffffffc02035fc:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc02035fe:	03000593          	li	a1,48
}
ffffffffc0203602:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203604:	988ff06f          	j	ffffffffc020278c <kfree>

ffffffffc0203608 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0203608:	715d                	addi	sp,sp,-80
ffffffffc020360a:	e486                	sd	ra,72(sp)
ffffffffc020360c:	e0a2                	sd	s0,64(sp)
ffffffffc020360e:	fc26                	sd	s1,56(sp)
ffffffffc0203610:	f84a                	sd	s2,48(sp)
ffffffffc0203612:	f052                	sd	s4,32(sp)
ffffffffc0203614:	f44e                	sd	s3,40(sp)
ffffffffc0203616:	ec56                	sd	s5,24(sp)
ffffffffc0203618:	e85a                	sd	s6,16(sp)
ffffffffc020361a:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020361c:	950fe0ef          	jal	ra,ffffffffc020176c <nr_free_pages>
ffffffffc0203620:	892a                	mv	s2,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203622:	94afe0ef          	jal	ra,ffffffffc020176c <nr_free_pages>
ffffffffc0203626:	8a2a                	mv	s4,a0

    struct mm_struct *mm = mm_create();
ffffffffc0203628:	e25ff0ef          	jal	ra,ffffffffc020344c <mm_create>
    assert(mm != NULL);
ffffffffc020362c:	842a                	mv	s0,a0
ffffffffc020362e:	03200493          	li	s1,50
ffffffffc0203632:	e919                	bnez	a0,ffffffffc0203648 <vmm_init+0x40>
ffffffffc0203634:	aeed                	j	ffffffffc0203a2e <vmm_init+0x426>
        vma->vm_start = vm_start;
ffffffffc0203636:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203638:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc020363a:	00053c23          	sd	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020363e:	14ed                	addi	s1,s1,-5
ffffffffc0203640:	8522                	mv	a0,s0
ffffffffc0203642:	ec3ff0ef          	jal	ra,ffffffffc0203504 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0203646:	c88d                	beqz	s1,ffffffffc0203678 <vmm_init+0x70>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203648:	03000513          	li	a0,48
ffffffffc020364c:	87eff0ef          	jal	ra,ffffffffc02026ca <kmalloc>
ffffffffc0203650:	85aa                	mv	a1,a0
ffffffffc0203652:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203656:	f165                	bnez	a0,ffffffffc0203636 <vmm_init+0x2e>
        assert(vma != NULL);
ffffffffc0203658:	00002697          	auipc	a3,0x2
ffffffffc020365c:	20868693          	addi	a3,a3,520 # ffffffffc0205860 <default_pmm_manager+0x798>
ffffffffc0203660:	00001617          	auipc	a2,0x1
ffffffffc0203664:	6d060613          	addi	a2,a2,1744 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0203668:	0ce00593          	li	a1,206
ffffffffc020366c:	00002517          	auipc	a0,0x2
ffffffffc0203670:	5ac50513          	addi	a0,a0,1452 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc0203674:	d01fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0203678:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020367c:	1f900993          	li	s3,505
ffffffffc0203680:	a819                	j	ffffffffc0203696 <vmm_init+0x8e>
        vma->vm_start = vm_start;
ffffffffc0203682:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203684:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203686:	00053c23          	sd	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020368a:	0495                	addi	s1,s1,5
ffffffffc020368c:	8522                	mv	a0,s0
ffffffffc020368e:	e77ff0ef          	jal	ra,ffffffffc0203504 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc0203692:	03348a63          	beq	s1,s3,ffffffffc02036c6 <vmm_init+0xbe>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203696:	03000513          	li	a0,48
ffffffffc020369a:	830ff0ef          	jal	ra,ffffffffc02026ca <kmalloc>
ffffffffc020369e:	85aa                	mv	a1,a0
ffffffffc02036a0:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02036a4:	fd79                	bnez	a0,ffffffffc0203682 <vmm_init+0x7a>
        assert(vma != NULL);
ffffffffc02036a6:	00002697          	auipc	a3,0x2
ffffffffc02036aa:	1ba68693          	addi	a3,a3,442 # ffffffffc0205860 <default_pmm_manager+0x798>
ffffffffc02036ae:	00001617          	auipc	a2,0x1
ffffffffc02036b2:	68260613          	addi	a2,a2,1666 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02036b6:	0d400593          	li	a1,212
ffffffffc02036ba:	00002517          	auipc	a0,0x2
ffffffffc02036be:	55e50513          	addi	a0,a0,1374 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc02036c2:	cb3fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02036c6:	6418                	ld	a4,8(s0)
ffffffffc02036c8:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc02036ca:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc02036ce:	2ae40063          	beq	s0,a4,ffffffffc020396e <vmm_init+0x366>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02036d2:	fe873603          	ld	a2,-24(a4)
ffffffffc02036d6:	ffe78693          	addi	a3,a5,-2
ffffffffc02036da:	20d61a63          	bne	a2,a3,ffffffffc02038ee <vmm_init+0x2e6>
ffffffffc02036de:	ff073683          	ld	a3,-16(a4)
ffffffffc02036e2:	20d79663          	bne	a5,a3,ffffffffc02038ee <vmm_init+0x2e6>
ffffffffc02036e6:	0795                	addi	a5,a5,5
ffffffffc02036e8:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc02036ea:	feb792e3          	bne	a5,a1,ffffffffc02036ce <vmm_init+0xc6>
ffffffffc02036ee:	499d                	li	s3,7
ffffffffc02036f0:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc02036f2:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02036f6:	85a6                	mv	a1,s1
ffffffffc02036f8:	8522                	mv	a0,s0
ffffffffc02036fa:	dcdff0ef          	jal	ra,ffffffffc02034c6 <find_vma>
ffffffffc02036fe:	8b2a                	mv	s6,a0
        assert(vma1 != NULL);
ffffffffc0203700:	2e050763          	beqz	a0,ffffffffc02039ee <vmm_init+0x3e6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203704:	00148593          	addi	a1,s1,1
ffffffffc0203708:	8522                	mv	a0,s0
ffffffffc020370a:	dbdff0ef          	jal	ra,ffffffffc02034c6 <find_vma>
ffffffffc020370e:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc0203710:	2a050f63          	beqz	a0,ffffffffc02039ce <vmm_init+0x3c6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0203714:	85ce                	mv	a1,s3
ffffffffc0203716:	8522                	mv	a0,s0
ffffffffc0203718:	dafff0ef          	jal	ra,ffffffffc02034c6 <find_vma>
        assert(vma3 == NULL);
ffffffffc020371c:	28051963          	bnez	a0,ffffffffc02039ae <vmm_init+0x3a6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc0203720:	00348593          	addi	a1,s1,3
ffffffffc0203724:	8522                	mv	a0,s0
ffffffffc0203726:	da1ff0ef          	jal	ra,ffffffffc02034c6 <find_vma>
        assert(vma4 == NULL);
ffffffffc020372a:	26051263          	bnez	a0,ffffffffc020398e <vmm_init+0x386>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc020372e:	00448593          	addi	a1,s1,4
ffffffffc0203732:	8522                	mv	a0,s0
ffffffffc0203734:	d93ff0ef          	jal	ra,ffffffffc02034c6 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203738:	2c051b63          	bnez	a0,ffffffffc0203a0e <vmm_init+0x406>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020373c:	008b3783          	ld	a5,8(s6)
ffffffffc0203740:	1c979763          	bne	a5,s1,ffffffffc020390e <vmm_init+0x306>
ffffffffc0203744:	010b3783          	ld	a5,16(s6)
ffffffffc0203748:	1d379363          	bne	a5,s3,ffffffffc020390e <vmm_init+0x306>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020374c:	008ab783          	ld	a5,8(s5)
ffffffffc0203750:	1c979f63          	bne	a5,s1,ffffffffc020392e <vmm_init+0x326>
ffffffffc0203754:	010ab783          	ld	a5,16(s5)
ffffffffc0203758:	1d379b63          	bne	a5,s3,ffffffffc020392e <vmm_init+0x326>
ffffffffc020375c:	0495                	addi	s1,s1,5
ffffffffc020375e:	0995                	addi	s3,s3,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203760:	f9749be3          	bne	s1,s7,ffffffffc02036f6 <vmm_init+0xee>
ffffffffc0203764:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0203766:	59fd                	li	s3,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0203768:	85a6                	mv	a1,s1
ffffffffc020376a:	8522                	mv	a0,s0
ffffffffc020376c:	d5bff0ef          	jal	ra,ffffffffc02034c6 <find_vma>
ffffffffc0203770:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0203774:	c90d                	beqz	a0,ffffffffc02037a6 <vmm_init+0x19e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203776:	6914                	ld	a3,16(a0)
ffffffffc0203778:	6510                	ld	a2,8(a0)
ffffffffc020377a:	00002517          	auipc	a0,0x2
ffffffffc020377e:	69e50513          	addi	a0,a0,1694 # ffffffffc0205e18 <default_pmm_manager+0xd50>
ffffffffc0203782:	93dfc0ef          	jal	ra,ffffffffc02000be <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203786:	00002697          	auipc	a3,0x2
ffffffffc020378a:	6ba68693          	addi	a3,a3,1722 # ffffffffc0205e40 <default_pmm_manager+0xd78>
ffffffffc020378e:	00001617          	auipc	a2,0x1
ffffffffc0203792:	5a260613          	addi	a2,a2,1442 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0203796:	0f600593          	li	a1,246
ffffffffc020379a:	00002517          	auipc	a0,0x2
ffffffffc020379e:	47e50513          	addi	a0,a0,1150 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc02037a2:	bd3fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02037a6:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc02037a8:	fd3490e3          	bne	s1,s3,ffffffffc0203768 <vmm_init+0x160>
    }

    mm_destroy(mm);
ffffffffc02037ac:	8522                	mv	a0,s0
ffffffffc02037ae:	e25ff0ef          	jal	ra,ffffffffc02035d2 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02037b2:	fbbfd0ef          	jal	ra,ffffffffc020176c <nr_free_pages>
ffffffffc02037b6:	28aa1c63          	bne	s4,a0,ffffffffc0203a4e <vmm_init+0x446>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02037ba:	00002517          	auipc	a0,0x2
ffffffffc02037be:	6c650513          	addi	a0,a0,1734 # ffffffffc0205e80 <default_pmm_manager+0xdb8>
ffffffffc02037c2:	8fdfc0ef          	jal	ra,ffffffffc02000be <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02037c6:	fa7fd0ef          	jal	ra,ffffffffc020176c <nr_free_pages>
ffffffffc02037ca:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc02037cc:	c81ff0ef          	jal	ra,ffffffffc020344c <mm_create>
ffffffffc02037d0:	0000e797          	auipc	a5,0xe
ffffffffc02037d4:	dca7b023          	sd	a0,-576(a5) # ffffffffc0211590 <check_mm_struct>
ffffffffc02037d8:	842a                	mv	s0,a0

    assert(check_mm_struct != NULL);
ffffffffc02037da:	2a050a63          	beqz	a0,ffffffffc0203a8e <vmm_init+0x486>
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02037de:	0000e797          	auipc	a5,0xe
ffffffffc02037e2:	c7278793          	addi	a5,a5,-910 # ffffffffc0211450 <boot_pgdir>
ffffffffc02037e6:	6384                	ld	s1,0(a5)
    assert(pgdir[0] == 0);
ffffffffc02037e8:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02037ea:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02037ec:	32079d63          	bnez	a5,ffffffffc0203b26 <vmm_init+0x51e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02037f0:	03000513          	li	a0,48
ffffffffc02037f4:	ed7fe0ef          	jal	ra,ffffffffc02026ca <kmalloc>
ffffffffc02037f8:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc02037fa:	14050a63          	beqz	a0,ffffffffc020394e <vmm_init+0x346>
        vma->vm_end = vm_end;
ffffffffc02037fe:	002007b7          	lui	a5,0x200
ffffffffc0203802:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc0203806:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203808:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc020380a:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc020380e:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc0203810:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc0203814:	cf1ff0ef          	jal	ra,ffffffffc0203504 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203818:	10000593          	li	a1,256
ffffffffc020381c:	8522                	mv	a0,s0
ffffffffc020381e:	ca9ff0ef          	jal	ra,ffffffffc02034c6 <find_vma>
ffffffffc0203822:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203826:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc020382a:	2aaa1263          	bne	s4,a0,ffffffffc0203ace <vmm_init+0x4c6>
        *(char *)(addr + i) = i;
ffffffffc020382e:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0203832:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0203834:	fee79de3          	bne	a5,a4,ffffffffc020382e <vmm_init+0x226>
        sum += i;
ffffffffc0203838:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc020383a:	10000793          	li	a5,256
        sum += i;
ffffffffc020383e:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203842:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203846:	0007c683          	lbu	a3,0(a5)
ffffffffc020384a:	0785                	addi	a5,a5,1
ffffffffc020384c:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc020384e:	fec79ce3          	bne	a5,a2,ffffffffc0203846 <vmm_init+0x23e>
    }
    assert(sum == 0);
ffffffffc0203852:	2a071a63          	bnez	a4,ffffffffc0203b06 <vmm_init+0x4fe>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203856:	4581                	li	a1,0
ffffffffc0203858:	8526                	mv	a0,s1
ffffffffc020385a:	9b8fe0ef          	jal	ra,ffffffffc0201a12 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc020385e:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc0203860:	0000e717          	auipc	a4,0xe
ffffffffc0203864:	bf870713          	addi	a4,a4,-1032 # ffffffffc0211458 <npage>
ffffffffc0203868:	6318                	ld	a4,0(a4)
    return pa2page(PDE_ADDR(pde));
ffffffffc020386a:	078a                	slli	a5,a5,0x2
ffffffffc020386c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020386e:	28e7f063          	bleu	a4,a5,ffffffffc0203aee <vmm_init+0x4e6>
    return &pages[PPN(pa) - nbase];
ffffffffc0203872:	00003717          	auipc	a4,0x3
ffffffffc0203876:	94e70713          	addi	a4,a4,-1714 # ffffffffc02061c0 <nbase>
ffffffffc020387a:	6318                	ld	a4,0(a4)
ffffffffc020387c:	0000e697          	auipc	a3,0xe
ffffffffc0203880:	c2c68693          	addi	a3,a3,-980 # ffffffffc02114a8 <pages>
ffffffffc0203884:	6288                	ld	a0,0(a3)
ffffffffc0203886:	8f99                	sub	a5,a5,a4
ffffffffc0203888:	00379713          	slli	a4,a5,0x3
ffffffffc020388c:	97ba                	add	a5,a5,a4
ffffffffc020388e:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc0203890:	953e                	add	a0,a0,a5
ffffffffc0203892:	4585                	li	a1,1
ffffffffc0203894:	e93fd0ef          	jal	ra,ffffffffc0201726 <free_pages>

    pgdir[0] = 0;
ffffffffc0203898:	0004b023          	sd	zero,0(s1)

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc020389c:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc020389e:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc02038a2:	d31ff0ef          	jal	ra,ffffffffc02035d2 <mm_destroy>

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc02038a6:	19fd                	addi	s3,s3,-1
    check_mm_struct = NULL;
ffffffffc02038a8:	0000e797          	auipc	a5,0xe
ffffffffc02038ac:	ce07b423          	sd	zero,-792(a5) # ffffffffc0211590 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038b0:	ebdfd0ef          	jal	ra,ffffffffc020176c <nr_free_pages>
ffffffffc02038b4:	1aa99d63          	bne	s3,a0,ffffffffc0203a6e <vmm_init+0x466>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02038b8:	00002517          	auipc	a0,0x2
ffffffffc02038bc:	63050513          	addi	a0,a0,1584 # ffffffffc0205ee8 <default_pmm_manager+0xe20>
ffffffffc02038c0:	ffefc0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038c4:	ea9fd0ef          	jal	ra,ffffffffc020176c <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc02038c8:	197d                	addi	s2,s2,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038ca:	1ea91263          	bne	s2,a0,ffffffffc0203aae <vmm_init+0x4a6>
}
ffffffffc02038ce:	6406                	ld	s0,64(sp)
ffffffffc02038d0:	60a6                	ld	ra,72(sp)
ffffffffc02038d2:	74e2                	ld	s1,56(sp)
ffffffffc02038d4:	7942                	ld	s2,48(sp)
ffffffffc02038d6:	79a2                	ld	s3,40(sp)
ffffffffc02038d8:	7a02                	ld	s4,32(sp)
ffffffffc02038da:	6ae2                	ld	s5,24(sp)
ffffffffc02038dc:	6b42                	ld	s6,16(sp)
ffffffffc02038de:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02038e0:	00002517          	auipc	a0,0x2
ffffffffc02038e4:	62850513          	addi	a0,a0,1576 # ffffffffc0205f08 <default_pmm_manager+0xe40>
}
ffffffffc02038e8:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc02038ea:	fd4fc06f          	j	ffffffffc02000be <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02038ee:	00002697          	auipc	a3,0x2
ffffffffc02038f2:	44268693          	addi	a3,a3,1090 # ffffffffc0205d30 <default_pmm_manager+0xc68>
ffffffffc02038f6:	00001617          	auipc	a2,0x1
ffffffffc02038fa:	43a60613          	addi	a2,a2,1082 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02038fe:	0dd00593          	li	a1,221
ffffffffc0203902:	00002517          	auipc	a0,0x2
ffffffffc0203906:	31650513          	addi	a0,a0,790 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc020390a:	a6bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020390e:	00002697          	auipc	a3,0x2
ffffffffc0203912:	4aa68693          	addi	a3,a3,1194 # ffffffffc0205db8 <default_pmm_manager+0xcf0>
ffffffffc0203916:	00001617          	auipc	a2,0x1
ffffffffc020391a:	41a60613          	addi	a2,a2,1050 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020391e:	0ed00593          	li	a1,237
ffffffffc0203922:	00002517          	auipc	a0,0x2
ffffffffc0203926:	2f650513          	addi	a0,a0,758 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc020392a:	a4bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020392e:	00002697          	auipc	a3,0x2
ffffffffc0203932:	4ba68693          	addi	a3,a3,1210 # ffffffffc0205de8 <default_pmm_manager+0xd20>
ffffffffc0203936:	00001617          	auipc	a2,0x1
ffffffffc020393a:	3fa60613          	addi	a2,a2,1018 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020393e:	0ee00593          	li	a1,238
ffffffffc0203942:	00002517          	auipc	a0,0x2
ffffffffc0203946:	2d650513          	addi	a0,a0,726 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc020394a:	a2bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(vma != NULL);
ffffffffc020394e:	00002697          	auipc	a3,0x2
ffffffffc0203952:	f1268693          	addi	a3,a3,-238 # ffffffffc0205860 <default_pmm_manager+0x798>
ffffffffc0203956:	00001617          	auipc	a2,0x1
ffffffffc020395a:	3da60613          	addi	a2,a2,986 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020395e:	11100593          	li	a1,273
ffffffffc0203962:	00002517          	auipc	a0,0x2
ffffffffc0203966:	2b650513          	addi	a0,a0,694 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc020396a:	a0bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020396e:	00002697          	auipc	a3,0x2
ffffffffc0203972:	3aa68693          	addi	a3,a3,938 # ffffffffc0205d18 <default_pmm_manager+0xc50>
ffffffffc0203976:	00001617          	auipc	a2,0x1
ffffffffc020397a:	3ba60613          	addi	a2,a2,954 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020397e:	0db00593          	li	a1,219
ffffffffc0203982:	00002517          	auipc	a0,0x2
ffffffffc0203986:	29650513          	addi	a0,a0,662 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc020398a:	9ebfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma4 == NULL);
ffffffffc020398e:	00002697          	auipc	a3,0x2
ffffffffc0203992:	40a68693          	addi	a3,a3,1034 # ffffffffc0205d98 <default_pmm_manager+0xcd0>
ffffffffc0203996:	00001617          	auipc	a2,0x1
ffffffffc020399a:	39a60613          	addi	a2,a2,922 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc020399e:	0e900593          	li	a1,233
ffffffffc02039a2:	00002517          	auipc	a0,0x2
ffffffffc02039a6:	27650513          	addi	a0,a0,630 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc02039aa:	9cbfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma3 == NULL);
ffffffffc02039ae:	00002697          	auipc	a3,0x2
ffffffffc02039b2:	3da68693          	addi	a3,a3,986 # ffffffffc0205d88 <default_pmm_manager+0xcc0>
ffffffffc02039b6:	00001617          	auipc	a2,0x1
ffffffffc02039ba:	37a60613          	addi	a2,a2,890 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02039be:	0e700593          	li	a1,231
ffffffffc02039c2:	00002517          	auipc	a0,0x2
ffffffffc02039c6:	25650513          	addi	a0,a0,598 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc02039ca:	9abfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2 != NULL);
ffffffffc02039ce:	00002697          	auipc	a3,0x2
ffffffffc02039d2:	3aa68693          	addi	a3,a3,938 # ffffffffc0205d78 <default_pmm_manager+0xcb0>
ffffffffc02039d6:	00001617          	auipc	a2,0x1
ffffffffc02039da:	35a60613          	addi	a2,a2,858 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02039de:	0e500593          	li	a1,229
ffffffffc02039e2:	00002517          	auipc	a0,0x2
ffffffffc02039e6:	23650513          	addi	a0,a0,566 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc02039ea:	98bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1 != NULL);
ffffffffc02039ee:	00002697          	auipc	a3,0x2
ffffffffc02039f2:	37a68693          	addi	a3,a3,890 # ffffffffc0205d68 <default_pmm_manager+0xca0>
ffffffffc02039f6:	00001617          	auipc	a2,0x1
ffffffffc02039fa:	33a60613          	addi	a2,a2,826 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc02039fe:	0e300593          	li	a1,227
ffffffffc0203a02:	00002517          	auipc	a0,0x2
ffffffffc0203a06:	21650513          	addi	a0,a0,534 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc0203a0a:	96bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma5 == NULL);
ffffffffc0203a0e:	00002697          	auipc	a3,0x2
ffffffffc0203a12:	39a68693          	addi	a3,a3,922 # ffffffffc0205da8 <default_pmm_manager+0xce0>
ffffffffc0203a16:	00001617          	auipc	a2,0x1
ffffffffc0203a1a:	31a60613          	addi	a2,a2,794 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0203a1e:	0eb00593          	li	a1,235
ffffffffc0203a22:	00002517          	auipc	a0,0x2
ffffffffc0203a26:	1f650513          	addi	a0,a0,502 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc0203a2a:	94bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(mm != NULL);
ffffffffc0203a2e:	00002697          	auipc	a3,0x2
ffffffffc0203a32:	dfa68693          	addi	a3,a3,-518 # ffffffffc0205828 <default_pmm_manager+0x760>
ffffffffc0203a36:	00001617          	auipc	a2,0x1
ffffffffc0203a3a:	2fa60613          	addi	a2,a2,762 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0203a3e:	0c700593          	li	a1,199
ffffffffc0203a42:	00002517          	auipc	a0,0x2
ffffffffc0203a46:	1d650513          	addi	a0,a0,470 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc0203a4a:	92bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a4e:	00002697          	auipc	a3,0x2
ffffffffc0203a52:	40a68693          	addi	a3,a3,1034 # ffffffffc0205e58 <default_pmm_manager+0xd90>
ffffffffc0203a56:	00001617          	auipc	a2,0x1
ffffffffc0203a5a:	2da60613          	addi	a2,a2,730 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0203a5e:	0fb00593          	li	a1,251
ffffffffc0203a62:	00002517          	auipc	a0,0x2
ffffffffc0203a66:	1b650513          	addi	a0,a0,438 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc0203a6a:	90bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a6e:	00002697          	auipc	a3,0x2
ffffffffc0203a72:	3ea68693          	addi	a3,a3,1002 # ffffffffc0205e58 <default_pmm_manager+0xd90>
ffffffffc0203a76:	00001617          	auipc	a2,0x1
ffffffffc0203a7a:	2ba60613          	addi	a2,a2,698 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0203a7e:	12e00593          	li	a1,302
ffffffffc0203a82:	00002517          	auipc	a0,0x2
ffffffffc0203a86:	19650513          	addi	a0,a0,406 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc0203a8a:	8ebfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203a8e:	00002697          	auipc	a3,0x2
ffffffffc0203a92:	41268693          	addi	a3,a3,1042 # ffffffffc0205ea0 <default_pmm_manager+0xdd8>
ffffffffc0203a96:	00001617          	auipc	a2,0x1
ffffffffc0203a9a:	29a60613          	addi	a2,a2,666 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0203a9e:	10a00593          	li	a1,266
ffffffffc0203aa2:	00002517          	auipc	a0,0x2
ffffffffc0203aa6:	17650513          	addi	a0,a0,374 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc0203aaa:	8cbfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203aae:	00002697          	auipc	a3,0x2
ffffffffc0203ab2:	3aa68693          	addi	a3,a3,938 # ffffffffc0205e58 <default_pmm_manager+0xd90>
ffffffffc0203ab6:	00001617          	auipc	a2,0x1
ffffffffc0203aba:	27a60613          	addi	a2,a2,634 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0203abe:	0bd00593          	li	a1,189
ffffffffc0203ac2:	00002517          	auipc	a0,0x2
ffffffffc0203ac6:	15650513          	addi	a0,a0,342 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc0203aca:	8abfc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203ace:	00002697          	auipc	a3,0x2
ffffffffc0203ad2:	3ea68693          	addi	a3,a3,1002 # ffffffffc0205eb8 <default_pmm_manager+0xdf0>
ffffffffc0203ad6:	00001617          	auipc	a2,0x1
ffffffffc0203ada:	25a60613          	addi	a2,a2,602 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0203ade:	11600593          	li	a1,278
ffffffffc0203ae2:	00002517          	auipc	a0,0x2
ffffffffc0203ae6:	13650513          	addi	a0,a0,310 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc0203aea:	88bfc0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203aee:	00001617          	auipc	a2,0x1
ffffffffc0203af2:	6a260613          	addi	a2,a2,1698 # ffffffffc0205190 <default_pmm_manager+0xc8>
ffffffffc0203af6:	06500593          	li	a1,101
ffffffffc0203afa:	00001517          	auipc	a0,0x1
ffffffffc0203afe:	6b650513          	addi	a0,a0,1718 # ffffffffc02051b0 <default_pmm_manager+0xe8>
ffffffffc0203b02:	873fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(sum == 0);
ffffffffc0203b06:	00002697          	auipc	a3,0x2
ffffffffc0203b0a:	3d268693          	addi	a3,a3,978 # ffffffffc0205ed8 <default_pmm_manager+0xe10>
ffffffffc0203b0e:	00001617          	auipc	a2,0x1
ffffffffc0203b12:	22260613          	addi	a2,a2,546 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0203b16:	12000593          	li	a1,288
ffffffffc0203b1a:	00002517          	auipc	a0,0x2
ffffffffc0203b1e:	0fe50513          	addi	a0,a0,254 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc0203b22:	853fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203b26:	00002697          	auipc	a3,0x2
ffffffffc0203b2a:	d2a68693          	addi	a3,a3,-726 # ffffffffc0205850 <default_pmm_manager+0x788>
ffffffffc0203b2e:	00001617          	auipc	a2,0x1
ffffffffc0203b32:	20260613          	addi	a2,a2,514 # ffffffffc0204d30 <commands+0x8d0>
ffffffffc0203b36:	10d00593          	li	a1,269
ffffffffc0203b3a:	00002517          	auipc	a0,0x2
ffffffffc0203b3e:	0de50513          	addi	a0,a0,222 # ffffffffc0205c18 <default_pmm_manager+0xb50>
ffffffffc0203b42:	833fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203b46 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203b46:	7139                	addi	sp,sp,-64
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203b48:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203b4a:	f822                	sd	s0,48(sp)
ffffffffc0203b4c:	f426                	sd	s1,40(sp)
ffffffffc0203b4e:	fc06                	sd	ra,56(sp)
ffffffffc0203b50:	f04a                	sd	s2,32(sp)
ffffffffc0203b52:	ec4e                	sd	s3,24(sp)
ffffffffc0203b54:	8432                	mv	s0,a2
ffffffffc0203b56:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203b58:	96fff0ef          	jal	ra,ffffffffc02034c6 <find_vma>

    pgfault_num++;
ffffffffc0203b5c:	0000e797          	auipc	a5,0xe
ffffffffc0203b60:	91078793          	addi	a5,a5,-1776 # ffffffffc021146c <pgfault_num>
ffffffffc0203b64:	439c                	lw	a5,0(a5)
ffffffffc0203b66:	2785                	addiw	a5,a5,1
ffffffffc0203b68:	0000e717          	auipc	a4,0xe
ffffffffc0203b6c:	90f72223          	sw	a5,-1788(a4) # ffffffffc021146c <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203b70:	c559                	beqz	a0,ffffffffc0203bfe <do_pgfault+0xb8>
ffffffffc0203b72:	651c                	ld	a5,8(a0)
ffffffffc0203b74:	08f46563          	bltu	s0,a5,ffffffffc0203bfe <do_pgfault+0xb8>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203b78:	6d1c                	ld	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc0203b7a:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203b7c:	8b89                	andi	a5,a5,2
ffffffffc0203b7e:	efb9                	bnez	a5,ffffffffc0203bdc <do_pgfault+0x96>
        perm |= (PTE_R | PTE_W);
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203b80:	767d                	lui	a2,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203b82:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203b84:	8c71                	and	s0,s0,a2
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203b86:	85a2                	mv	a1,s0
ffffffffc0203b88:	4605                	li	a2,1
ffffffffc0203b8a:	c23fd0ef          	jal	ra,ffffffffc02017ac <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    
    //if()
    
    if (*ptep == 0) {
ffffffffc0203b8e:	610c                	ld	a1,0(a0)
ffffffffc0203b90:	c9a1                	beqz	a1,ffffffffc0203be0 <do_pgfault+0x9a>
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        // 如果 PTE 存在，那么说明这一页已经映射过了但是被保存在磁盘中，需要将这一页内存交换出来
        if (swap_init_ok) {
ffffffffc0203b92:	0000e797          	auipc	a5,0xe
ffffffffc0203b96:	8d678793          	addi	a5,a5,-1834 # ffffffffc0211468 <swap_init_ok>
ffffffffc0203b9a:	439c                	lw	a5,0(a5)
ffffffffc0203b9c:	2781                	sext.w	a5,a5
ffffffffc0203b9e:	cbad                	beqz	a5,ffffffffc0203c10 <do_pgfault+0xca>
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.

            int res = swap_in(mm, addr, &page); // 将硬盘中的内容换入至 page 中
ffffffffc0203ba0:	0030                	addi	a2,sp,8
ffffffffc0203ba2:	85a2                	mv	a1,s0
ffffffffc0203ba4:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203ba6:	e402                	sd	zero,8(sp)
            int res = swap_in(mm, addr, &page); // 将硬盘中的内容换入至 page 中
ffffffffc0203ba8:	c78ff0ef          	jal	ra,ffffffffc0203020 <swap_in>
ffffffffc0203bac:	892a                	mv	s2,a0
            if(res != 0){
ffffffffc0203bae:	e92d                	bnez	a0,ffffffffc0203c20 <do_pgfault+0xda>
                cprintf("swap_in failed\n"); 
                goto failed;
                }
            page_insert(mm->pgdir, page, addr, perm); // 建立虚拟地址和物理地址之间的映射
ffffffffc0203bb0:	65a2                	ld	a1,8(sp)
ffffffffc0203bb2:	6c88                	ld	a0,24(s1)
ffffffffc0203bb4:	86ce                	mv	a3,s3
ffffffffc0203bb6:	8622                	mv	a2,s0
ffffffffc0203bb8:	ecdfd0ef          	jal	ra,ffffffffc0201a84 <page_insert>
            swap_map_swappable(mm, addr, page, 1); // 页面可交换
ffffffffc0203bbc:	6622                	ld	a2,8(sp)
ffffffffc0203bbe:	4685                	li	a3,1
ffffffffc0203bc0:	85a2                	mv	a1,s0
ffffffffc0203bc2:	8526                	mv	a0,s1
ffffffffc0203bc4:	b38ff0ef          	jal	ra,ffffffffc0202efc <swap_map_swappable>

            page->pra_vaddr = addr;
ffffffffc0203bc8:	67a2                	ld	a5,8(sp)
ffffffffc0203bca:	e3a0                	sd	s0,64(a5)
   }

   ret = 0;
failed:
    return ret;
}
ffffffffc0203bcc:	70e2                	ld	ra,56(sp)
ffffffffc0203bce:	7442                	ld	s0,48(sp)
ffffffffc0203bd0:	854a                	mv	a0,s2
ffffffffc0203bd2:	74a2                	ld	s1,40(sp)
ffffffffc0203bd4:	7902                	ld	s2,32(sp)
ffffffffc0203bd6:	69e2                	ld	s3,24(sp)
ffffffffc0203bd8:	6121                	addi	sp,sp,64
ffffffffc0203bda:	8082                	ret
        perm |= (PTE_R | PTE_W);
ffffffffc0203bdc:	49d9                	li	s3,22
ffffffffc0203bde:	b74d                	j	ffffffffc0203b80 <do_pgfault+0x3a>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203be0:	6c88                	ld	a0,24(s1)
ffffffffc0203be2:	864e                	mv	a2,s3
ffffffffc0203be4:	85a2                	mv	a1,s0
ffffffffc0203be6:	a53fe0ef          	jal	ra,ffffffffc0202638 <pgdir_alloc_page>
   ret = 0;
ffffffffc0203bea:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203bec:	f165                	bnez	a0,ffffffffc0203bcc <do_pgfault+0x86>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203bee:	00002517          	auipc	a0,0x2
ffffffffc0203bf2:	06a50513          	addi	a0,a0,106 # ffffffffc0205c58 <default_pmm_manager+0xb90>
ffffffffc0203bf6:	cc8fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203bfa:	5971                	li	s2,-4
            goto failed;
ffffffffc0203bfc:	bfc1                	j	ffffffffc0203bcc <do_pgfault+0x86>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203bfe:	85a2                	mv	a1,s0
ffffffffc0203c00:	00002517          	auipc	a0,0x2
ffffffffc0203c04:	02850513          	addi	a0,a0,40 # ffffffffc0205c28 <default_pmm_manager+0xb60>
ffffffffc0203c08:	cb6fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = -E_INVAL;
ffffffffc0203c0c:	5975                	li	s2,-3
        goto failed;
ffffffffc0203c0e:	bf7d                	j	ffffffffc0203bcc <do_pgfault+0x86>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203c10:	00002517          	auipc	a0,0x2
ffffffffc0203c14:	08050513          	addi	a0,a0,128 # ffffffffc0205c90 <default_pmm_manager+0xbc8>
ffffffffc0203c18:	ca6fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203c1c:	5971                	li	s2,-4
            goto failed;
ffffffffc0203c1e:	b77d                	j	ffffffffc0203bcc <do_pgfault+0x86>
                cprintf("swap_in failed\n"); 
ffffffffc0203c20:	00002517          	auipc	a0,0x2
ffffffffc0203c24:	06050513          	addi	a0,a0,96 # ffffffffc0205c80 <default_pmm_manager+0xbb8>
ffffffffc0203c28:	c96fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203c2c:	5971                	li	s2,-4
ffffffffc0203c2e:	bf79                	j	ffffffffc0203bcc <do_pgfault+0x86>

ffffffffc0203c30 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203c30:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203c32:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203c34:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203c36:	869fc0ef          	jal	ra,ffffffffc020049e <ide_device_valid>
ffffffffc0203c3a:	cd01                	beqz	a0,ffffffffc0203c52 <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203c3c:	4505                	li	a0,1
ffffffffc0203c3e:	867fc0ef          	jal	ra,ffffffffc02004a4 <ide_device_size>
}
ffffffffc0203c42:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203c44:	810d                	srli	a0,a0,0x3
ffffffffc0203c46:	0000e797          	auipc	a5,0xe
ffffffffc0203c4a:	8ea7b923          	sd	a0,-1806(a5) # ffffffffc0211538 <max_swap_offset>
}
ffffffffc0203c4e:	0141                	addi	sp,sp,16
ffffffffc0203c50:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203c52:	00002617          	auipc	a2,0x2
ffffffffc0203c56:	2ce60613          	addi	a2,a2,718 # ffffffffc0205f20 <default_pmm_manager+0xe58>
ffffffffc0203c5a:	45b5                	li	a1,13
ffffffffc0203c5c:	00002517          	auipc	a0,0x2
ffffffffc0203c60:	2e450513          	addi	a0,a0,740 # ffffffffc0205f40 <default_pmm_manager+0xe78>
ffffffffc0203c64:	f10fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203c68 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203c68:	1141                	addi	sp,sp,-16
ffffffffc0203c6a:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c6c:	00855793          	srli	a5,a0,0x8
ffffffffc0203c70:	c7b5                	beqz	a5,ffffffffc0203cdc <swapfs_read+0x74>
ffffffffc0203c72:	0000e717          	auipc	a4,0xe
ffffffffc0203c76:	8c670713          	addi	a4,a4,-1850 # ffffffffc0211538 <max_swap_offset>
ffffffffc0203c7a:	6318                	ld	a4,0(a4)
ffffffffc0203c7c:	06e7f063          	bleu	a4,a5,ffffffffc0203cdc <swapfs_read+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203c80:	0000e717          	auipc	a4,0xe
ffffffffc0203c84:	82870713          	addi	a4,a4,-2008 # ffffffffc02114a8 <pages>
ffffffffc0203c88:	6310                	ld	a2,0(a4)
ffffffffc0203c8a:	00001717          	auipc	a4,0x1
ffffffffc0203c8e:	08e70713          	addi	a4,a4,142 # ffffffffc0204d18 <commands+0x8b8>
ffffffffc0203c92:	00002697          	auipc	a3,0x2
ffffffffc0203c96:	52e68693          	addi	a3,a3,1326 # ffffffffc02061c0 <nbase>
ffffffffc0203c9a:	40c58633          	sub	a2,a1,a2
ffffffffc0203c9e:	630c                	ld	a1,0(a4)
ffffffffc0203ca0:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ca2:	0000d717          	auipc	a4,0xd
ffffffffc0203ca6:	7b670713          	addi	a4,a4,1974 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203caa:	02b60633          	mul	a2,a2,a1
ffffffffc0203cae:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203cb2:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cb4:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cb6:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cb8:	57fd                	li	a5,-1
ffffffffc0203cba:	83b1                	srli	a5,a5,0xc
ffffffffc0203cbc:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203cbe:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cc0:	02e7fa63          	bleu	a4,a5,ffffffffc0203cf4 <swapfs_read+0x8c>
ffffffffc0203cc4:	0000d797          	auipc	a5,0xd
ffffffffc0203cc8:	7d478793          	addi	a5,a5,2004 # ffffffffc0211498 <va_pa_offset>
ffffffffc0203ccc:	639c                	ld	a5,0(a5)
}
ffffffffc0203cce:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203cd0:	46a1                	li	a3,8
ffffffffc0203cd2:	963e                	add	a2,a2,a5
ffffffffc0203cd4:	4505                	li	a0,1
}
ffffffffc0203cd6:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203cd8:	fd2fc06f          	j	ffffffffc02004aa <ide_read_secs>
ffffffffc0203cdc:	86aa                	mv	a3,a0
ffffffffc0203cde:	00002617          	auipc	a2,0x2
ffffffffc0203ce2:	27a60613          	addi	a2,a2,634 # ffffffffc0205f58 <default_pmm_manager+0xe90>
ffffffffc0203ce6:	45d1                	li	a1,20
ffffffffc0203ce8:	00002517          	auipc	a0,0x2
ffffffffc0203cec:	25850513          	addi	a0,a0,600 # ffffffffc0205f40 <default_pmm_manager+0xe78>
ffffffffc0203cf0:	e84fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203cf4:	86b2                	mv	a3,a2
ffffffffc0203cf6:	06a00593          	li	a1,106
ffffffffc0203cfa:	00001617          	auipc	a2,0x1
ffffffffc0203cfe:	41e60613          	addi	a2,a2,1054 # ffffffffc0205118 <default_pmm_manager+0x50>
ffffffffc0203d02:	00001517          	auipc	a0,0x1
ffffffffc0203d06:	4ae50513          	addi	a0,a0,1198 # ffffffffc02051b0 <default_pmm_manager+0xe8>
ffffffffc0203d0a:	e6afc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203d0e <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203d0e:	1141                	addi	sp,sp,-16
ffffffffc0203d10:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d12:	00855793          	srli	a5,a0,0x8
ffffffffc0203d16:	c7b5                	beqz	a5,ffffffffc0203d82 <swapfs_write+0x74>
ffffffffc0203d18:	0000e717          	auipc	a4,0xe
ffffffffc0203d1c:	82070713          	addi	a4,a4,-2016 # ffffffffc0211538 <max_swap_offset>
ffffffffc0203d20:	6318                	ld	a4,0(a4)
ffffffffc0203d22:	06e7f063          	bleu	a4,a5,ffffffffc0203d82 <swapfs_write+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d26:	0000d717          	auipc	a4,0xd
ffffffffc0203d2a:	78270713          	addi	a4,a4,1922 # ffffffffc02114a8 <pages>
ffffffffc0203d2e:	6310                	ld	a2,0(a4)
ffffffffc0203d30:	00001717          	auipc	a4,0x1
ffffffffc0203d34:	fe870713          	addi	a4,a4,-24 # ffffffffc0204d18 <commands+0x8b8>
ffffffffc0203d38:	00002697          	auipc	a3,0x2
ffffffffc0203d3c:	48868693          	addi	a3,a3,1160 # ffffffffc02061c0 <nbase>
ffffffffc0203d40:	40c58633          	sub	a2,a1,a2
ffffffffc0203d44:	630c                	ld	a1,0(a4)
ffffffffc0203d46:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d48:	0000d717          	auipc	a4,0xd
ffffffffc0203d4c:	71070713          	addi	a4,a4,1808 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d50:	02b60633          	mul	a2,a2,a1
ffffffffc0203d54:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203d58:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d5a:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d5c:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d5e:	57fd                	li	a5,-1
ffffffffc0203d60:	83b1                	srli	a5,a5,0xc
ffffffffc0203d62:	8ff1                	and	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0203d64:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d66:	02e7fa63          	bleu	a4,a5,ffffffffc0203d9a <swapfs_write+0x8c>
ffffffffc0203d6a:	0000d797          	auipc	a5,0xd
ffffffffc0203d6e:	72e78793          	addi	a5,a5,1838 # ffffffffc0211498 <va_pa_offset>
ffffffffc0203d72:	639c                	ld	a5,0(a5)
}
ffffffffc0203d74:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d76:	46a1                	li	a3,8
ffffffffc0203d78:	963e                	add	a2,a2,a5
ffffffffc0203d7a:	4505                	li	a0,1
}
ffffffffc0203d7c:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d7e:	f50fc06f          	j	ffffffffc02004ce <ide_write_secs>
ffffffffc0203d82:	86aa                	mv	a3,a0
ffffffffc0203d84:	00002617          	auipc	a2,0x2
ffffffffc0203d88:	1d460613          	addi	a2,a2,468 # ffffffffc0205f58 <default_pmm_manager+0xe90>
ffffffffc0203d8c:	45e5                	li	a1,25
ffffffffc0203d8e:	00002517          	auipc	a0,0x2
ffffffffc0203d92:	1b250513          	addi	a0,a0,434 # ffffffffc0205f40 <default_pmm_manager+0xe78>
ffffffffc0203d96:	ddefc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203d9a:	86b2                	mv	a3,a2
ffffffffc0203d9c:	06a00593          	li	a1,106
ffffffffc0203da0:	00001617          	auipc	a2,0x1
ffffffffc0203da4:	37860613          	addi	a2,a2,888 # ffffffffc0205118 <default_pmm_manager+0x50>
ffffffffc0203da8:	00001517          	auipc	a0,0x1
ffffffffc0203dac:	40850513          	addi	a0,a0,1032 # ffffffffc02051b0 <default_pmm_manager+0xe8>
ffffffffc0203db0:	dc4fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203db4 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203db4:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203db8:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203dba:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203dbe:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203dc0:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203dc4:	f022                	sd	s0,32(sp)
ffffffffc0203dc6:	ec26                	sd	s1,24(sp)
ffffffffc0203dc8:	e84a                	sd	s2,16(sp)
ffffffffc0203dca:	f406                	sd	ra,40(sp)
ffffffffc0203dcc:	e44e                	sd	s3,8(sp)
ffffffffc0203dce:	84aa                	mv	s1,a0
ffffffffc0203dd0:	892e                	mv	s2,a1
ffffffffc0203dd2:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203dd6:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0203dd8:	03067e63          	bleu	a6,a2,ffffffffc0203e14 <printnum+0x60>
ffffffffc0203ddc:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203dde:	00805763          	blez	s0,ffffffffc0203dec <printnum+0x38>
ffffffffc0203de2:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203de4:	85ca                	mv	a1,s2
ffffffffc0203de6:	854e                	mv	a0,s3
ffffffffc0203de8:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203dea:	fc65                	bnez	s0,ffffffffc0203de2 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203dec:	1a02                	slli	s4,s4,0x20
ffffffffc0203dee:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203df2:	00002797          	auipc	a5,0x2
ffffffffc0203df6:	31678793          	addi	a5,a5,790 # ffffffffc0206108 <error_string+0x38>
ffffffffc0203dfa:	9a3e                	add	s4,s4,a5
}
ffffffffc0203dfc:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203dfe:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203e02:	70a2                	ld	ra,40(sp)
ffffffffc0203e04:	69a2                	ld	s3,8(sp)
ffffffffc0203e06:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e08:	85ca                	mv	a1,s2
ffffffffc0203e0a:	8326                	mv	t1,s1
}
ffffffffc0203e0c:	6942                	ld	s2,16(sp)
ffffffffc0203e0e:	64e2                	ld	s1,24(sp)
ffffffffc0203e10:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e12:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203e14:	03065633          	divu	a2,a2,a6
ffffffffc0203e18:	8722                	mv	a4,s0
ffffffffc0203e1a:	f9bff0ef          	jal	ra,ffffffffc0203db4 <printnum>
ffffffffc0203e1e:	b7f9                	j	ffffffffc0203dec <printnum+0x38>

ffffffffc0203e20 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203e20:	7119                	addi	sp,sp,-128
ffffffffc0203e22:	f4a6                	sd	s1,104(sp)
ffffffffc0203e24:	f0ca                	sd	s2,96(sp)
ffffffffc0203e26:	e8d2                	sd	s4,80(sp)
ffffffffc0203e28:	e4d6                	sd	s5,72(sp)
ffffffffc0203e2a:	e0da                	sd	s6,64(sp)
ffffffffc0203e2c:	fc5e                	sd	s7,56(sp)
ffffffffc0203e2e:	f862                	sd	s8,48(sp)
ffffffffc0203e30:	f06a                	sd	s10,32(sp)
ffffffffc0203e32:	fc86                	sd	ra,120(sp)
ffffffffc0203e34:	f8a2                	sd	s0,112(sp)
ffffffffc0203e36:	ecce                	sd	s3,88(sp)
ffffffffc0203e38:	f466                	sd	s9,40(sp)
ffffffffc0203e3a:	ec6e                	sd	s11,24(sp)
ffffffffc0203e3c:	892a                	mv	s2,a0
ffffffffc0203e3e:	84ae                	mv	s1,a1
ffffffffc0203e40:	8d32                	mv	s10,a2
ffffffffc0203e42:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203e44:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e46:	00002a17          	auipc	s4,0x2
ffffffffc0203e4a:	132a0a13          	addi	s4,s4,306 # ffffffffc0205f78 <default_pmm_manager+0xeb0>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203e4e:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203e52:	00002c17          	auipc	s8,0x2
ffffffffc0203e56:	27ec0c13          	addi	s8,s8,638 # ffffffffc02060d0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e5a:	000d4503          	lbu	a0,0(s10)
ffffffffc0203e5e:	02500793          	li	a5,37
ffffffffc0203e62:	001d0413          	addi	s0,s10,1
ffffffffc0203e66:	00f50e63          	beq	a0,a5,ffffffffc0203e82 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0203e6a:	c521                	beqz	a0,ffffffffc0203eb2 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e6c:	02500993          	li	s3,37
ffffffffc0203e70:	a011                	j	ffffffffc0203e74 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0203e72:	c121                	beqz	a0,ffffffffc0203eb2 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0203e74:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e76:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203e78:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e7a:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203e7e:	ff351ae3          	bne	a0,s3,ffffffffc0203e72 <vprintfmt+0x52>
ffffffffc0203e82:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203e86:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203e8a:	4981                	li	s3,0
ffffffffc0203e8c:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0203e8e:	5cfd                	li	s9,-1
ffffffffc0203e90:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e92:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0203e96:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e98:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0203e9c:	0ff6f693          	andi	a3,a3,255
ffffffffc0203ea0:	00140d13          	addi	s10,s0,1
ffffffffc0203ea4:	20d5e563          	bltu	a1,a3,ffffffffc02040ae <vprintfmt+0x28e>
ffffffffc0203ea8:	068a                	slli	a3,a3,0x2
ffffffffc0203eaa:	96d2                	add	a3,a3,s4
ffffffffc0203eac:	4294                	lw	a3,0(a3)
ffffffffc0203eae:	96d2                	add	a3,a3,s4
ffffffffc0203eb0:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203eb2:	70e6                	ld	ra,120(sp)
ffffffffc0203eb4:	7446                	ld	s0,112(sp)
ffffffffc0203eb6:	74a6                	ld	s1,104(sp)
ffffffffc0203eb8:	7906                	ld	s2,96(sp)
ffffffffc0203eba:	69e6                	ld	s3,88(sp)
ffffffffc0203ebc:	6a46                	ld	s4,80(sp)
ffffffffc0203ebe:	6aa6                	ld	s5,72(sp)
ffffffffc0203ec0:	6b06                	ld	s6,64(sp)
ffffffffc0203ec2:	7be2                	ld	s7,56(sp)
ffffffffc0203ec4:	7c42                	ld	s8,48(sp)
ffffffffc0203ec6:	7ca2                	ld	s9,40(sp)
ffffffffc0203ec8:	7d02                	ld	s10,32(sp)
ffffffffc0203eca:	6de2                	ld	s11,24(sp)
ffffffffc0203ecc:	6109                	addi	sp,sp,128
ffffffffc0203ece:	8082                	ret
    if (lflag >= 2) {
ffffffffc0203ed0:	4705                	li	a4,1
ffffffffc0203ed2:	008a8593          	addi	a1,s5,8
ffffffffc0203ed6:	01074463          	blt	a4,a6,ffffffffc0203ede <vprintfmt+0xbe>
    else if (lflag) {
ffffffffc0203eda:	26080363          	beqz	a6,ffffffffc0204140 <vprintfmt+0x320>
        return va_arg(*ap, unsigned long);
ffffffffc0203ede:	000ab603          	ld	a2,0(s5)
ffffffffc0203ee2:	46c1                	li	a3,16
ffffffffc0203ee4:	8aae                	mv	s5,a1
ffffffffc0203ee6:	a06d                	j	ffffffffc0203f90 <vprintfmt+0x170>
            goto reswitch;
ffffffffc0203ee8:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0203eec:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203eee:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203ef0:	b765                	j	ffffffffc0203e98 <vprintfmt+0x78>
            putch(va_arg(ap, int), putdat);
ffffffffc0203ef2:	000aa503          	lw	a0,0(s5)
ffffffffc0203ef6:	85a6                	mv	a1,s1
ffffffffc0203ef8:	0aa1                	addi	s5,s5,8
ffffffffc0203efa:	9902                	jalr	s2
            break;
ffffffffc0203efc:	bfb9                	j	ffffffffc0203e5a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203efe:	4705                	li	a4,1
ffffffffc0203f00:	008a8993          	addi	s3,s5,8
ffffffffc0203f04:	01074463          	blt	a4,a6,ffffffffc0203f0c <vprintfmt+0xec>
    else if (lflag) {
ffffffffc0203f08:	22080463          	beqz	a6,ffffffffc0204130 <vprintfmt+0x310>
        return va_arg(*ap, long);
ffffffffc0203f0c:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0203f10:	24044463          	bltz	s0,ffffffffc0204158 <vprintfmt+0x338>
            num = getint(&ap, lflag);
ffffffffc0203f14:	8622                	mv	a2,s0
ffffffffc0203f16:	8ace                	mv	s5,s3
ffffffffc0203f18:	46a9                	li	a3,10
ffffffffc0203f1a:	a89d                	j	ffffffffc0203f90 <vprintfmt+0x170>
            err = va_arg(ap, int);
ffffffffc0203f1c:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f20:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203f22:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0203f24:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203f28:	8fb5                	xor	a5,a5,a3
ffffffffc0203f2a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203f2e:	1ad74363          	blt	a4,a3,ffffffffc02040d4 <vprintfmt+0x2b4>
ffffffffc0203f32:	00369793          	slli	a5,a3,0x3
ffffffffc0203f36:	97e2                	add	a5,a5,s8
ffffffffc0203f38:	639c                	ld	a5,0(a5)
ffffffffc0203f3a:	18078d63          	beqz	a5,ffffffffc02040d4 <vprintfmt+0x2b4>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203f3e:	86be                	mv	a3,a5
ffffffffc0203f40:	00002617          	auipc	a2,0x2
ffffffffc0203f44:	27860613          	addi	a2,a2,632 # ffffffffc02061b8 <error_string+0xe8>
ffffffffc0203f48:	85a6                	mv	a1,s1
ffffffffc0203f4a:	854a                	mv	a0,s2
ffffffffc0203f4c:	240000ef          	jal	ra,ffffffffc020418c <printfmt>
ffffffffc0203f50:	b729                	j	ffffffffc0203e5a <vprintfmt+0x3a>
            lflag ++;
ffffffffc0203f52:	00144603          	lbu	a2,1(s0)
ffffffffc0203f56:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f58:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0203f5a:	bf3d                	j	ffffffffc0203e98 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0203f5c:	4705                	li	a4,1
ffffffffc0203f5e:	008a8593          	addi	a1,s5,8
ffffffffc0203f62:	01074463          	blt	a4,a6,ffffffffc0203f6a <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0203f66:	1e080263          	beqz	a6,ffffffffc020414a <vprintfmt+0x32a>
        return va_arg(*ap, unsigned long);
ffffffffc0203f6a:	000ab603          	ld	a2,0(s5)
ffffffffc0203f6e:	46a1                	li	a3,8
ffffffffc0203f70:	8aae                	mv	s5,a1
ffffffffc0203f72:	a839                	j	ffffffffc0203f90 <vprintfmt+0x170>
            putch('0', putdat);
ffffffffc0203f74:	03000513          	li	a0,48
ffffffffc0203f78:	85a6                	mv	a1,s1
ffffffffc0203f7a:	e03e                	sd	a5,0(sp)
ffffffffc0203f7c:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0203f7e:	85a6                	mv	a1,s1
ffffffffc0203f80:	07800513          	li	a0,120
ffffffffc0203f84:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0203f86:	0aa1                	addi	s5,s5,8
ffffffffc0203f88:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0203f8c:	6782                	ld	a5,0(sp)
ffffffffc0203f8e:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0203f90:	876e                	mv	a4,s11
ffffffffc0203f92:	85a6                	mv	a1,s1
ffffffffc0203f94:	854a                	mv	a0,s2
ffffffffc0203f96:	e1fff0ef          	jal	ra,ffffffffc0203db4 <printnum>
            break;
ffffffffc0203f9a:	b5c1                	j	ffffffffc0203e5a <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203f9c:	000ab603          	ld	a2,0(s5)
ffffffffc0203fa0:	0aa1                	addi	s5,s5,8
ffffffffc0203fa2:	1c060663          	beqz	a2,ffffffffc020416e <vprintfmt+0x34e>
            if (width > 0 && padc != '-') {
ffffffffc0203fa6:	00160413          	addi	s0,a2,1
ffffffffc0203faa:	17b05c63          	blez	s11,ffffffffc0204122 <vprintfmt+0x302>
ffffffffc0203fae:	02d00593          	li	a1,45
ffffffffc0203fb2:	14b79263          	bne	a5,a1,ffffffffc02040f6 <vprintfmt+0x2d6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203fb6:	00064783          	lbu	a5,0(a2)
ffffffffc0203fba:	0007851b          	sext.w	a0,a5
ffffffffc0203fbe:	c905                	beqz	a0,ffffffffc0203fee <vprintfmt+0x1ce>
ffffffffc0203fc0:	000cc563          	bltz	s9,ffffffffc0203fca <vprintfmt+0x1aa>
ffffffffc0203fc4:	3cfd                	addiw	s9,s9,-1
ffffffffc0203fc6:	036c8263          	beq	s9,s6,ffffffffc0203fea <vprintfmt+0x1ca>
                    putch('?', putdat);
ffffffffc0203fca:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203fcc:	18098463          	beqz	s3,ffffffffc0204154 <vprintfmt+0x334>
ffffffffc0203fd0:	3781                	addiw	a5,a5,-32
ffffffffc0203fd2:	18fbf163          	bleu	a5,s7,ffffffffc0204154 <vprintfmt+0x334>
                    putch('?', putdat);
ffffffffc0203fd6:	03f00513          	li	a0,63
ffffffffc0203fda:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203fdc:	0405                	addi	s0,s0,1
ffffffffc0203fde:	fff44783          	lbu	a5,-1(s0)
ffffffffc0203fe2:	3dfd                	addiw	s11,s11,-1
ffffffffc0203fe4:	0007851b          	sext.w	a0,a5
ffffffffc0203fe8:	fd61                	bnez	a0,ffffffffc0203fc0 <vprintfmt+0x1a0>
            for (; width > 0; width --) {
ffffffffc0203fea:	e7b058e3          	blez	s11,ffffffffc0203e5a <vprintfmt+0x3a>
ffffffffc0203fee:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203ff0:	85a6                	mv	a1,s1
ffffffffc0203ff2:	02000513          	li	a0,32
ffffffffc0203ff6:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0203ff8:	e60d81e3          	beqz	s11,ffffffffc0203e5a <vprintfmt+0x3a>
ffffffffc0203ffc:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0203ffe:	85a6                	mv	a1,s1
ffffffffc0204000:	02000513          	li	a0,32
ffffffffc0204004:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204006:	fe0d94e3          	bnez	s11,ffffffffc0203fee <vprintfmt+0x1ce>
ffffffffc020400a:	bd81                	j	ffffffffc0203e5a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020400c:	4705                	li	a4,1
ffffffffc020400e:	008a8593          	addi	a1,s5,8
ffffffffc0204012:	01074463          	blt	a4,a6,ffffffffc020401a <vprintfmt+0x1fa>
    else if (lflag) {
ffffffffc0204016:	12080063          	beqz	a6,ffffffffc0204136 <vprintfmt+0x316>
        return va_arg(*ap, unsigned long);
ffffffffc020401a:	000ab603          	ld	a2,0(s5)
ffffffffc020401e:	46a9                	li	a3,10
ffffffffc0204020:	8aae                	mv	s5,a1
ffffffffc0204022:	b7bd                	j	ffffffffc0203f90 <vprintfmt+0x170>
ffffffffc0204024:	00144603          	lbu	a2,1(s0)
            padc = '-';
ffffffffc0204028:	02d00793          	li	a5,45
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020402c:	846a                	mv	s0,s10
ffffffffc020402e:	b5ad                	j	ffffffffc0203e98 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc0204030:	85a6                	mv	a1,s1
ffffffffc0204032:	02500513          	li	a0,37
ffffffffc0204036:	9902                	jalr	s2
            break;
ffffffffc0204038:	b50d                	j	ffffffffc0203e5a <vprintfmt+0x3a>
            precision = va_arg(ap, int);
ffffffffc020403a:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc020403e:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0204042:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204044:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0204046:	e40dd9e3          	bgez	s11,ffffffffc0203e98 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc020404a:	8de6                	mv	s11,s9
ffffffffc020404c:	5cfd                	li	s9,-1
ffffffffc020404e:	b5a9                	j	ffffffffc0203e98 <vprintfmt+0x78>
            goto reswitch;
ffffffffc0204050:	00144603          	lbu	a2,1(s0)
            padc = '0';
ffffffffc0204054:	03000793          	li	a5,48
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204058:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020405a:	bd3d                	j	ffffffffc0203e98 <vprintfmt+0x78>
                precision = precision * 10 + ch - '0';
ffffffffc020405c:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0204060:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204064:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204066:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020406a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020406e:	fcd56ce3          	bltu	a0,a3,ffffffffc0204046 <vprintfmt+0x226>
            for (precision = 0; ; ++ fmt) {
ffffffffc0204072:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0204074:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0204078:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc020407c:	0196873b          	addw	a4,a3,s9
ffffffffc0204080:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204084:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0204088:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc020408c:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0204090:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204094:	fcd57fe3          	bleu	a3,a0,ffffffffc0204072 <vprintfmt+0x252>
ffffffffc0204098:	b77d                	j	ffffffffc0204046 <vprintfmt+0x226>
            if (width < 0)
ffffffffc020409a:	fffdc693          	not	a3,s11
ffffffffc020409e:	96fd                	srai	a3,a3,0x3f
ffffffffc02040a0:	00ddfdb3          	and	s11,s11,a3
ffffffffc02040a4:	00144603          	lbu	a2,1(s0)
ffffffffc02040a8:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040aa:	846a                	mv	s0,s10
ffffffffc02040ac:	b3f5                	j	ffffffffc0203e98 <vprintfmt+0x78>
            putch('%', putdat);
ffffffffc02040ae:	85a6                	mv	a1,s1
ffffffffc02040b0:	02500513          	li	a0,37
ffffffffc02040b4:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02040b6:	fff44703          	lbu	a4,-1(s0)
ffffffffc02040ba:	02500793          	li	a5,37
ffffffffc02040be:	8d22                	mv	s10,s0
ffffffffc02040c0:	d8f70de3          	beq	a4,a5,ffffffffc0203e5a <vprintfmt+0x3a>
ffffffffc02040c4:	02500713          	li	a4,37
ffffffffc02040c8:	1d7d                	addi	s10,s10,-1
ffffffffc02040ca:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02040ce:	fee79de3          	bne	a5,a4,ffffffffc02040c8 <vprintfmt+0x2a8>
ffffffffc02040d2:	b361                	j	ffffffffc0203e5a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02040d4:	00002617          	auipc	a2,0x2
ffffffffc02040d8:	0d460613          	addi	a2,a2,212 # ffffffffc02061a8 <error_string+0xd8>
ffffffffc02040dc:	85a6                	mv	a1,s1
ffffffffc02040de:	854a                	mv	a0,s2
ffffffffc02040e0:	0ac000ef          	jal	ra,ffffffffc020418c <printfmt>
ffffffffc02040e4:	bb9d                	j	ffffffffc0203e5a <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02040e6:	00002617          	auipc	a2,0x2
ffffffffc02040ea:	0ba60613          	addi	a2,a2,186 # ffffffffc02061a0 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc02040ee:	00002417          	auipc	s0,0x2
ffffffffc02040f2:	0b340413          	addi	s0,s0,179 # ffffffffc02061a1 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02040f6:	8532                	mv	a0,a2
ffffffffc02040f8:	85e6                	mv	a1,s9
ffffffffc02040fa:	e032                	sd	a2,0(sp)
ffffffffc02040fc:	e43e                	sd	a5,8(sp)
ffffffffc02040fe:	18a000ef          	jal	ra,ffffffffc0204288 <strnlen>
ffffffffc0204102:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204106:	6602                	ld	a2,0(sp)
ffffffffc0204108:	01b05d63          	blez	s11,ffffffffc0204122 <vprintfmt+0x302>
ffffffffc020410c:	67a2                	ld	a5,8(sp)
ffffffffc020410e:	2781                	sext.w	a5,a5
ffffffffc0204110:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0204112:	6522                	ld	a0,8(sp)
ffffffffc0204114:	85a6                	mv	a1,s1
ffffffffc0204116:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204118:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020411a:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020411c:	6602                	ld	a2,0(sp)
ffffffffc020411e:	fe0d9ae3          	bnez	s11,ffffffffc0204112 <vprintfmt+0x2f2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204122:	00064783          	lbu	a5,0(a2)
ffffffffc0204126:	0007851b          	sext.w	a0,a5
ffffffffc020412a:	e8051be3          	bnez	a0,ffffffffc0203fc0 <vprintfmt+0x1a0>
ffffffffc020412e:	b335                	j	ffffffffc0203e5a <vprintfmt+0x3a>
        return va_arg(*ap, int);
ffffffffc0204130:	000aa403          	lw	s0,0(s5)
ffffffffc0204134:	bbf1                	j	ffffffffc0203f10 <vprintfmt+0xf0>
        return va_arg(*ap, unsigned int);
ffffffffc0204136:	000ae603          	lwu	a2,0(s5)
ffffffffc020413a:	46a9                	li	a3,10
ffffffffc020413c:	8aae                	mv	s5,a1
ffffffffc020413e:	bd89                	j	ffffffffc0203f90 <vprintfmt+0x170>
ffffffffc0204140:	000ae603          	lwu	a2,0(s5)
ffffffffc0204144:	46c1                	li	a3,16
ffffffffc0204146:	8aae                	mv	s5,a1
ffffffffc0204148:	b5a1                	j	ffffffffc0203f90 <vprintfmt+0x170>
ffffffffc020414a:	000ae603          	lwu	a2,0(s5)
ffffffffc020414e:	46a1                	li	a3,8
ffffffffc0204150:	8aae                	mv	s5,a1
ffffffffc0204152:	bd3d                	j	ffffffffc0203f90 <vprintfmt+0x170>
                    putch(ch, putdat);
ffffffffc0204154:	9902                	jalr	s2
ffffffffc0204156:	b559                	j	ffffffffc0203fdc <vprintfmt+0x1bc>
                putch('-', putdat);
ffffffffc0204158:	85a6                	mv	a1,s1
ffffffffc020415a:	02d00513          	li	a0,45
ffffffffc020415e:	e03e                	sd	a5,0(sp)
ffffffffc0204160:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204162:	8ace                	mv	s5,s3
ffffffffc0204164:	40800633          	neg	a2,s0
ffffffffc0204168:	46a9                	li	a3,10
ffffffffc020416a:	6782                	ld	a5,0(sp)
ffffffffc020416c:	b515                	j	ffffffffc0203f90 <vprintfmt+0x170>
            if (width > 0 && padc != '-') {
ffffffffc020416e:	01b05663          	blez	s11,ffffffffc020417a <vprintfmt+0x35a>
ffffffffc0204172:	02d00693          	li	a3,45
ffffffffc0204176:	f6d798e3          	bne	a5,a3,ffffffffc02040e6 <vprintfmt+0x2c6>
ffffffffc020417a:	00002417          	auipc	s0,0x2
ffffffffc020417e:	02740413          	addi	s0,s0,39 # ffffffffc02061a1 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204182:	02800513          	li	a0,40
ffffffffc0204186:	02800793          	li	a5,40
ffffffffc020418a:	bd1d                	j	ffffffffc0203fc0 <vprintfmt+0x1a0>

ffffffffc020418c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020418c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020418e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204192:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0204194:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204196:	ec06                	sd	ra,24(sp)
ffffffffc0204198:	f83a                	sd	a4,48(sp)
ffffffffc020419a:	fc3e                	sd	a5,56(sp)
ffffffffc020419c:	e0c2                	sd	a6,64(sp)
ffffffffc020419e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02041a0:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02041a2:	c7fff0ef          	jal	ra,ffffffffc0203e20 <vprintfmt>
}
ffffffffc02041a6:	60e2                	ld	ra,24(sp)
ffffffffc02041a8:	6161                	addi	sp,sp,80
ffffffffc02041aa:	8082                	ret

ffffffffc02041ac <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02041ac:	715d                	addi	sp,sp,-80
ffffffffc02041ae:	e486                	sd	ra,72(sp)
ffffffffc02041b0:	e0a2                	sd	s0,64(sp)
ffffffffc02041b2:	fc26                	sd	s1,56(sp)
ffffffffc02041b4:	f84a                	sd	s2,48(sp)
ffffffffc02041b6:	f44e                	sd	s3,40(sp)
ffffffffc02041b8:	f052                	sd	s4,32(sp)
ffffffffc02041ba:	ec56                	sd	s5,24(sp)
ffffffffc02041bc:	e85a                	sd	s6,16(sp)
ffffffffc02041be:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02041c0:	c901                	beqz	a0,ffffffffc02041d0 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02041c2:	85aa                	mv	a1,a0
ffffffffc02041c4:	00002517          	auipc	a0,0x2
ffffffffc02041c8:	ff450513          	addi	a0,a0,-12 # ffffffffc02061b8 <error_string+0xe8>
ffffffffc02041cc:	ef3fb0ef          	jal	ra,ffffffffc02000be <cprintf>
readline(const char *prompt) {
ffffffffc02041d0:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02041d2:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02041d4:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02041d6:	4aa9                	li	s5,10
ffffffffc02041d8:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02041da:	0000db97          	auipc	s7,0xd
ffffffffc02041de:	e66b8b93          	addi	s7,s7,-410 # ffffffffc0211040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02041e2:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02041e6:	f11fb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc02041ea:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02041ec:	00054b63          	bltz	a0,ffffffffc0204202 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02041f0:	00a95b63          	ble	a0,s2,ffffffffc0204206 <readline+0x5a>
ffffffffc02041f4:	029a5463          	ble	s1,s4,ffffffffc020421c <readline+0x70>
        c = getchar();
ffffffffc02041f8:	efffb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc02041fc:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02041fe:	fe0559e3          	bgez	a0,ffffffffc02041f0 <readline+0x44>
            return NULL;
ffffffffc0204202:	4501                	li	a0,0
ffffffffc0204204:	a099                	j	ffffffffc020424a <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0204206:	03341463          	bne	s0,s3,ffffffffc020422e <readline+0x82>
ffffffffc020420a:	e8b9                	bnez	s1,ffffffffc0204260 <readline+0xb4>
        c = getchar();
ffffffffc020420c:	eebfb0ef          	jal	ra,ffffffffc02000f6 <getchar>
ffffffffc0204210:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0204212:	fe0548e3          	bltz	a0,ffffffffc0204202 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204216:	fea958e3          	ble	a0,s2,ffffffffc0204206 <readline+0x5a>
ffffffffc020421a:	4481                	li	s1,0
            cputchar(c);
ffffffffc020421c:	8522                	mv	a0,s0
ffffffffc020421e:	ed5fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i ++] = c;
ffffffffc0204222:	009b87b3          	add	a5,s7,s1
ffffffffc0204226:	00878023          	sb	s0,0(a5)
ffffffffc020422a:	2485                	addiw	s1,s1,1
ffffffffc020422c:	bf6d                	j	ffffffffc02041e6 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc020422e:	01540463          	beq	s0,s5,ffffffffc0204236 <readline+0x8a>
ffffffffc0204232:	fb641ae3          	bne	s0,s6,ffffffffc02041e6 <readline+0x3a>
            cputchar(c);
ffffffffc0204236:	8522                	mv	a0,s0
ffffffffc0204238:	ebbfb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i] = '\0';
ffffffffc020423c:	0000d517          	auipc	a0,0xd
ffffffffc0204240:	e0450513          	addi	a0,a0,-508 # ffffffffc0211040 <buf>
ffffffffc0204244:	94aa                	add	s1,s1,a0
ffffffffc0204246:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020424a:	60a6                	ld	ra,72(sp)
ffffffffc020424c:	6406                	ld	s0,64(sp)
ffffffffc020424e:	74e2                	ld	s1,56(sp)
ffffffffc0204250:	7942                	ld	s2,48(sp)
ffffffffc0204252:	79a2                	ld	s3,40(sp)
ffffffffc0204254:	7a02                	ld	s4,32(sp)
ffffffffc0204256:	6ae2                	ld	s5,24(sp)
ffffffffc0204258:	6b42                	ld	s6,16(sp)
ffffffffc020425a:	6ba2                	ld	s7,8(sp)
ffffffffc020425c:	6161                	addi	sp,sp,80
ffffffffc020425e:	8082                	ret
            cputchar(c);
ffffffffc0204260:	4521                	li	a0,8
ffffffffc0204262:	e91fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            i --;
ffffffffc0204266:	34fd                	addiw	s1,s1,-1
ffffffffc0204268:	bfbd                	j	ffffffffc02041e6 <readline+0x3a>

ffffffffc020426a <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020426a:	00054783          	lbu	a5,0(a0)
ffffffffc020426e:	cb91                	beqz	a5,ffffffffc0204282 <strlen+0x18>
    size_t cnt = 0;
ffffffffc0204270:	4781                	li	a5,0
        cnt ++;
ffffffffc0204272:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0204274:	00f50733          	add	a4,a0,a5
ffffffffc0204278:	00074703          	lbu	a4,0(a4)
ffffffffc020427c:	fb7d                	bnez	a4,ffffffffc0204272 <strlen+0x8>
    }
    return cnt;
}
ffffffffc020427e:	853e                	mv	a0,a5
ffffffffc0204280:	8082                	ret
    size_t cnt = 0;
ffffffffc0204282:	4781                	li	a5,0
}
ffffffffc0204284:	853e                	mv	a0,a5
ffffffffc0204286:	8082                	ret

ffffffffc0204288 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204288:	c185                	beqz	a1,ffffffffc02042a8 <strnlen+0x20>
ffffffffc020428a:	00054783          	lbu	a5,0(a0)
ffffffffc020428e:	cf89                	beqz	a5,ffffffffc02042a8 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0204290:	4781                	li	a5,0
ffffffffc0204292:	a021                	j	ffffffffc020429a <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204294:	00074703          	lbu	a4,0(a4)
ffffffffc0204298:	c711                	beqz	a4,ffffffffc02042a4 <strnlen+0x1c>
        cnt ++;
ffffffffc020429a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020429c:	00f50733          	add	a4,a0,a5
ffffffffc02042a0:	fef59ae3          	bne	a1,a5,ffffffffc0204294 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02042a4:	853e                	mv	a0,a5
ffffffffc02042a6:	8082                	ret
    size_t cnt = 0;
ffffffffc02042a8:	4781                	li	a5,0
}
ffffffffc02042aa:	853e                	mv	a0,a5
ffffffffc02042ac:	8082                	ret

ffffffffc02042ae <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02042ae:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02042b0:	0585                	addi	a1,a1,1
ffffffffc02042b2:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02042b6:	0785                	addi	a5,a5,1
ffffffffc02042b8:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02042bc:	fb75                	bnez	a4,ffffffffc02042b0 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02042be:	8082                	ret

ffffffffc02042c0 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02042c0:	00054783          	lbu	a5,0(a0)
ffffffffc02042c4:	0005c703          	lbu	a4,0(a1)
ffffffffc02042c8:	cb91                	beqz	a5,ffffffffc02042dc <strcmp+0x1c>
ffffffffc02042ca:	00e79c63          	bne	a5,a4,ffffffffc02042e2 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02042ce:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02042d0:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02042d4:	0585                	addi	a1,a1,1
ffffffffc02042d6:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02042da:	fbe5                	bnez	a5,ffffffffc02042ca <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02042dc:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02042de:	9d19                	subw	a0,a0,a4
ffffffffc02042e0:	8082                	ret
ffffffffc02042e2:	0007851b          	sext.w	a0,a5
ffffffffc02042e6:	9d19                	subw	a0,a0,a4
ffffffffc02042e8:	8082                	ret

ffffffffc02042ea <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02042ea:	00054783          	lbu	a5,0(a0)
ffffffffc02042ee:	cb91                	beqz	a5,ffffffffc0204302 <strchr+0x18>
        if (*s == c) {
ffffffffc02042f0:	00b79563          	bne	a5,a1,ffffffffc02042fa <strchr+0x10>
ffffffffc02042f4:	a809                	j	ffffffffc0204306 <strchr+0x1c>
ffffffffc02042f6:	00b78763          	beq	a5,a1,ffffffffc0204304 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02042fa:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02042fc:	00054783          	lbu	a5,0(a0)
ffffffffc0204300:	fbfd                	bnez	a5,ffffffffc02042f6 <strchr+0xc>
    }
    return NULL;
ffffffffc0204302:	4501                	li	a0,0
}
ffffffffc0204304:	8082                	ret
ffffffffc0204306:	8082                	ret

ffffffffc0204308 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204308:	ca01                	beqz	a2,ffffffffc0204318 <memset+0x10>
ffffffffc020430a:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020430c:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020430e:	0785                	addi	a5,a5,1
ffffffffc0204310:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204314:	fec79de3          	bne	a5,a2,ffffffffc020430e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204318:	8082                	ret

ffffffffc020431a <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020431a:	ca19                	beqz	a2,ffffffffc0204330 <memcpy+0x16>
ffffffffc020431c:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020431e:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0204320:	0585                	addi	a1,a1,1
ffffffffc0204322:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204326:	0785                	addi	a5,a5,1
ffffffffc0204328:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020432c:	fec59ae3          	bne	a1,a2,ffffffffc0204320 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0204330:	8082                	ret
