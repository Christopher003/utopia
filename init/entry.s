;MBOOT_HEADER_MAGIC 	equ 	0x1BADB002 	; Multiboot 魔数，由规范决定的
MBOOT_HEADER_MAGIC 	equ 	0x1BADB002	; Multiboot 魔数，由规范决定的

MBOOT_PAGE_ALIGN 	equ 	1 << 0		; 0 号位表示所有的引导模块将按页(4KB)边界对齐
MBOOT_MEM_INFO 		equ 	1 << 1		; 1 号位通过 Multiboot 信息结构的 mem_* 域包括可用内存的信息
MBOOT_CMDLINE       equ     1 << 2      ; 2 号位表示启用命令行参数
MBOOT_HEADER_FLAGS 	equ 	MBOOT_PAGE_ALIGN | MBOOT_MEM_INFO | MBOOT_CMDLINE
MBOOT_CHECKSUM 		equ 	-(MBOOT_HEADER_MAGIC + MBOOT_HEADER_FLAGS)

[BITS 32]  	; 所有代码以 32-bit 的方式编译

[SECTION .multiboot]
dd MBOOT_HEADER_MAGIC 	; GRUB 会通过这个魔数判断该映像是否支持
dd MBOOT_HEADER_FLAGS   ; GRUB 的一些加载时选项，其详细注释在定义处
dd MBOOT_CHECKSUM	   ; 检测数值，其含义在定义处
dd 0, 0, 0, 0, 0
dd 1
dd 80, 24
dd 0

extern _start
[SECTION .text] 	; 代码段从这里开始

[GLOBAL start] 		; 内核代码入口，此处提供该声明给 ld 链接器
[GLOBAL glb_mboot_ptr] 	; 全局的 struct multiboot * 变量\
global __cxa_pure_virtual
global _ZdlPvm
global stop
global kern_stack
[EXTERN kernelEntry] 	; 声明内核 C 代码的入口函数

start:
	cli  			 ; 此时还没有设置好保护模式的中断处理
				 ; 所以必须关闭中断
	mov esp, STACK_TOP  	 ; 设置内核栈地址
	mov ebp, 0 		 ; 帧指针修改为 0
	and esp, 0FFFFFFF0H	 ; 栈地址按照16字节对齐
	mov [glb_mboot_ptr], ebx ; 将 ebx 中存储的指针存入全局变量
	; call cons


	; push ebx
	call _start
	; call kernelEntry		 ; 调用内核入口函数
stop:
	hlt
	jmp stop

section .bss align=16				; 未初始化的数据段从这里开始
stack:
kern_stack equ $
	resb 32768	 ; 这里作为内核栈
glb_mboot_ptr: 			 ; 全局的 multiboot 结构体指针
	resb 4

STACK_TOP equ $-stack-1 	 ; 内核栈顶，$ 符指代是当前地址
