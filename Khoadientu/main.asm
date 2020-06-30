RS EQU P0.0
RW EQU P0.1
E  EQU P0.2
SEL EQU 41H
byteout EQU P1
ORG 000H 
CLR P3.0
MOV TMOD,#00100001B
MOV TH1,#253D
MOV SCON,#50H
SETB TR1
LCALL khtaolcd
LCALL A1_Line
LCALL LINE2 
LCALL A2_Line

MAIN:
	LCALL khtaolcd
	LCALL A1_Line ;goi chtr con hien thi hang thu nhat
	CLR P3.0
	LCALL LINE2
	LCALL A2_Line ;goi chtr con hien thi hang thu hai
	ACALL DELAY1
	ACALL DELAY1
	ACALL READ_KEYPRESS
	ACALL LINE1 
	LCALL C1_Line 
	ACALL DELAY1
	ACALL CHECK_PASSWORD      
	SJMP MAIN    
;----------------------------------------------------------------------------------
khtaolcd: 
	setb e ;Enable
	clr rs ;RS low
	clr rw ;RW low
	MOV a,#38h ;tu dieu khien LCD
	LCALL KTAO
	LCALL ddelay41 ;delay 4.1 mSec
	MOV A,#38h ;function set
	LCALL KTAO
	LCALL ddelay100 ;delay
	MOV A,#38h ;function
	LCALL KTAO
	MOV A,#0ch ;tu dieu khien display on
	LCALL KTAO
	MOV A,#01h ;tu dieu khien Clear display
	LCALL KTAO
	MOV A,#06h ;tu dieu khien entry mode set
	LCALL KTAO
	MOV A,#80h ;thiet lap dia chi LCD (set DD RAM)
	LCALL KTAO
RET
;----------------------------------------------------------------------------------
;chuong trinh con delay 4.1 ms
ddelay41: 
	mov r6,#90h
del412: 
	mov r7,#200
	djnz r7,$
	djnz r6,del412
ret
;----------------------------------------------------------------------------------
;chuong trinh con delay 255 microgiay
ddelay100: 
	mov r7,#00
	djnz r7,$
ret
;----------------------------------------------------------------------------------
;Feed command/data to the LCD module
command_byte:
	clr rs ;RS low for a command byte
	ljmp bdelay
data_byte: 
    setb rs ;RS high for a data byte
bdelay: 
	clr rw ;R/W low for a write mode
	clr e
	nop
	setb e ;Enable pulse
	nop
	nop
	mov byteout,#0ffh ;configure port1 to input mode
	setb rw ;set RW to read
	clr rs ;set RS to command
	clr e ;generate enable pulse
	nop
	nop
	setb e
	lcall ddelay100
ret
;----------------------------------------------------------------------------------
;Chuong trinh con hien thi noi dung hang thu 1 tren LCD
A1_Line: 
	MOV DPTR,#A1
	lcall Write
ret
B1_Line: 
	MOV DPTR,#B1
	lcall Write
ret
C1_Line:
	MOV DPTR,#C1
	lcall Write
ret
D1_Line:
	MOV DPTR,#D1
	lcall Write
ret
E1_Line:
	MOV DPTR,#E1
	lcall Write
ret
;----------------------------------------------------------------------------------
;Chuong trinh con hien thi noi dung hang thu 2 tren LCD
A2_Line: 
	mov dptr,#A2
	lcall write
ret
D2_Line:
	MOV DPTR,#D2
	lcall Write
ret
E2_Line:
	MOV DPTR,#E2
	lcall Write
ret
;----------------------------------------------------------------------------------
;chuong trinh con khoi tao LCD
KTAO: 
	mov byteout,a
	lcall command_byte
RET
;----------------------------------------------------------------------------------
;chtr con goi data hien thi ra LCD
write: 
	MOV A,#0
	MOVC A,@a+dptr
	CJNE A,#99h,Writea
RET
Writea: 
	mov byteout,a
	acall data_byte
	inc dptr
	SJMP Write
;----------------------------------------------------------------------------------
DELAY1:
	MOV R3,#46D
BACK:  
	MOV TH0,#00000000B   
	MOV TL0,#00000000B   
	SETB TR0             
HERE1: 
	JNB TF0,HERE1         
	CLR TR0             
	CLR TF0             
	DJNZ R3,BACK
RET
;----------------------------------------------------------------------------------
READ_KEYPRESS: 
	LCALL CLRSCR
	LCALL LINE1 
	LCALL B1_Line
	LCALL LINE2
	MOV R0,#5D
	MOV R1,#160D
ROTATE:
	LCALL KEY_SCAN
	MOV @R1,A
	MOV byteout , A 
	LCALL data_byte
	LCALL DELAY2
	INC R1
	DJNZ R0,ROTATE
RET
;----------------------------------------------------------------------------------
CLRSCR:
	MOV A,#01H
	LCALL KTAO
RET
;----------------------------------------------------------------------------------
KEY_SCAN:
	MOV P2,#11111111B 
	CLR P2.0 
	JB P2.4, NEXT1 
	MOV A,#49D
RET
NEXT1:
	JB P2.5,NEXT2
	MOV A,#50D
RET
NEXT2: 
	JB P2.6,NEXT3
	MOV A,#51D
RET
NEXT3: 
	JB P2.7,NEXT4
	MOV A,#65D
RET
NEXT4:
	SETB P2.0
	CLR P2.1 
	JB P2.4, NEXT5 
	MOV A,#52D
RET
NEXT5:
	JB P2.5,NEXT6
	MOV A,#53D
RET
NEXT6: 
	JB P2.6,NEXT7
	MOV A,#54D
RET
NEXT7: 
	JB P2.7,NEXT8
	MOV A,#66D
RET
NEXT8:
	SETB P2.1
	CLR P2.2
	JB P2.4, NEXT9 
	MOV A,#55D
RET
NEXT9:
	JB P2.5,NEXT10
	MOV A,#56D
RET
NEXT10: 
	JB P2.6,NEXT11
	MOV A,#57D
RET
NEXT11: 
	JB P2.7,NEXT12
	MOV A,#67D
RET
NEXT12:
	SETB P2.2
	CLR P2.3
	JB P2.4, NEXT13 
	MOV A,#42D
RET
NEXT13:
	JB P2.5,NEXT14
	MOV A,#48D
RET
NEXT14: 
	JB P2.6,NEXT15
	MOV A,#35D
RET
NEXT15: 
	JB P2.7,NEXT16
	MOV A,#68D
RET
NEXT16:
	LJMP KEY_SCAN
;----------------------------------------------------------------------------------
LINE2:
	MOV A,#0C0H 
	LCALL KTAO
RET   
;----------------------------------------------------------------------------------
LINE1: 
	MOV A,#06h ;tu dieu khien entry mode set
	LCALL KTAO
	MOV A,#80H    
	LCALL KTAO
RET
;----------------------------------------------------------------------------------
DELAY2: 
	MOV R3,#250D
BACK2:   
	MOV TH0,#0FCH 
	MOV TL0,#018H 
	SETB TR0 
HERE2:  
	JNB TF0,HERE2 
	CLR TR0 
	CLR TF0 
	DJNZ R3,BACK2
RET  
;----------------------------------------------------------------------------------
CHECK_PASSWORD:
	MOV R0,#5D
	MOV R1,#160D
	MOV DPTR,#PASSW 
RPT:
	CLR A
	MOVC A,@A+DPTR
	XRL A,@R1
	JNZ FAIL
	INC R1
	INC DPTR
	DJNZ R0,RPT
	ACALL CLRSCR
	ACALL LINE1
	LCALL D1_Line
	ACALL LINE2
	ACALL DELAY1
	SETB P2.0
	LCALL D2_Line 
	ACALL DELAY1
	SJMP GOBACK
FAIL:
	ACALL CLRSCR 
	ACALL LINE1
	LCALL E1_Line 
	ACALL DELAY1
	ACALL LINE2
	LCALL E2_Line
	ACALL DELAY1
GOBACK:
	RET
;---------------------------------------------------------------------------------- 
A1: DB 'PASSWORD BASED',099h
A2: DB 'SECURITY SYSTEM',099h
B1: DB "INPUT 5 DIGITS",099h
C1: DB "CHECK PASSWORD",099h
D1: DB "ACCESS GRANTED",099h
D2: DB "DOOR OPENED",099h
E1: DB "WRONG PASSWORD",099h
E2: DB "ACCESS DENIED",099h
PASSW: DB 49D,50D,51D,52D,53D,0
END