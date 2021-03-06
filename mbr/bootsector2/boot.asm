
;; We are bootloader
%define BOOTLOADER


%include "inc/env.inc"
%include "inc/io.inc"
%include "inc/vga.inc"

org ORG_ADDRESS

entry:
	jmp start ;; without this, the functions in below will be excuted!
	DECLARE_IO_API

;; main proc
start:
	set_vga_mode VGA_MODE_80x25_2color_text
	mov si, msg
	call puts
	call CheckExtInt13H

	mov si, msgPrompt
	call puts
	getc
	
	mov si, msgLoadingSector
	call puts

	;xor ax, ax	
	mov ax, 0x8000
	mov es, ax
	mov bx, 0
	call Read

	mov si, msgMove
	call puts

	mov ax, 0x8000
	mov ds, ax
	xor si, si

	mov ax, 0
	mov es, ax
	mov di, 0x6000

	mov cx, 512
	rep movsb

	mov si, msgDone
	call puts

	mov si, msgInvoke
	call puts

	;;mov ax, 0
	;;mov cs, ax
	jmp 0000:0x6000


end:
	mov si, msgProgramEnd
	call puts
	jmp $

CheckExtInt13H:
	mov ah, 0x41		;           功能号是 41H
	mov bx, 0x55aa;         入口参数之一
	mov dl, 0x80	;             第二个参数表示要测试的 驱动器， 80H 是第一块硬盘，则81H是第二块……
	int 13h
	cmp bx, 0xaa55;        如果存在扩展 13H 功能，则bx==AA55H
	jz Surpportted
NotSurpportted:
	mov si, msgNoturpportExtInt13H
	call puts
	ret
Surpportted:
	mov si, msgSurpportExtInt13H
	call puts
	ret

Read: ;; the 0,0,2 sector
	mov al, 1	;;==>要写入的扇区数
	mov ch, 0	;;==>磁道号
	mov cl, 2	;;===>扇区号
	mov dl, 80h	;;==>软驱A
	mov dh, 0	;;==>0号磁头,软盘0面
	mov ah, 2	;;===>int 13h功能号,写扇区
	int 13h
	ret

;; data section
;; NOTE: for bootloader, binary format object
;; donot use section .data, this will make wrong object size
;; refer to $ and $$
msg db 'Checking HD Controller ...', 13, 10, 0
msgSurpportExtInt13H db 'Surpport extended functions!', 13, 10, 0
msgNoturpportExtInt13H db 'Not Surpport extended functions!', 13, 10, 0
msgPrompt db 'Input any char to continue >> ', 13, 10, 0
msgLoadingSector db 'Loading sector-1 ...', 13, 10, 0
msgProgramEnd db 'Program terminated.', 13, 10, 0
msgMove db 'Moving to 0x6000', 13, 10, 0
msgDone db 'Done!', 13, 10, 0
msgInvoke db 'Invoking sector-1 ...', 13, 10, 0
crlf db 13, 10

;; Footer of bootloader
FitBootloaderto512WithZero
ADDBOOTFLAG
;;-----------------------------------------------------------------------------
;; end of file
