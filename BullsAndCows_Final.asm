.data
filename: .asciiz "wordsrc.txt"
filecontent: .space 2000
answer: .byte '$','$','$','$'
#prompts in the game
title: .asciiz "\nCows and Bulls - Word Game\n"
from: .asciiz "from 3340.501 Jinhao Jie, Hao Wu, Garret Fox and Jing Chen\n\n "
menu1: .asciiz "Please choose from one of the following menu options:\n"
menu2: .asciiz "[1] Start New Game\n"
menu3: .asciiz "[2] View Instructions\n"
menu4: .asciiz "[3] Exit Game\n"
menu5: .asciiz "[4] View Credits\n"
menu6: .asciiz "Please enter your choice [1-4]:\n "
credit1: .asciiz "Team: Four Bugs Already\n3340.501 2018 Fall\nUniversit of Texas in Dallas"
credit2: .asciiz "Jinghao Jie\nHao Wu\nGarret Fox\nJing Chen\n"
credit3: .asciiz "Thank you for playing this game.\nHave Fun!!!\n"
wrongchoice: .asciiz "\n\nERROR: Please choose from 1 to 4\n"
times_guess:  .asciiz  " Please input number of times you want to try:\n"
guessprompt1: .asciiz "\nPlease enter four letter word\n"
guessprompt2: .asciiz "This word should be all low case and no repetition\n"
guessprompt3: .asciiz "Remember you can always type 1 to get tips and type 2 exit the game. Enjoy!\n"
begin:	.asciiz	"Please guess a 4-letter word(lower-case and no repeat):"
right:	.asciiz	"congraduation! That's the answer!!\n"
ncows:	.asciiz " cows \n"
nbulls:	.asciiz "  bulls and "
dupeerror: .asciiz "\nERROR: There is repeated letters.Guess again!\n"
lowcaseerror: .asciiz "\nERROR: Invalid characters. All the letters should be low case, no symbol allowed.Guess again!\n"
counterror: .asciiz "\nERROR: word should be exactly 4 letters long.Guess again!\n"
instruct: .asciiz "Guess game, enter four letter word to guess the secret\n If you get the right position and character, bull++; if you only get the right character, cow++;\n you can type 1for tips, 2 for exit the game\n  Have fun!!\n"
cows:	.word	0
bulls:	.word	0
userguess: .byte	'0','0','0','0','0'
count:   .word        1
countmax: .word  0
printcount:  .asciiz " attempt result : "
limit : .asciiz " You reached the limit of guesses ! Now restart the game!\n"
reveal: .asciiz   "The correct answer is :"
quit:     .asciiz "Now exit the game\n"
pos:      .word  0,0,0,0
printtip:  .asciiz "The first char you didn't guess is : "

############ LOSE BEEP PARAMETERS ############

tone:     .byte 51
duration: .byte 250
volume:   .byte 30
inst:    .byte 4

 tone2:     .byte 50
duration2: .byte 500
volume2:   .byte 30
inst2:    .byte 4

 tone3:     .byte 49
duration3: .byte 1000
volume3:   .byte 30
inst3:    .byte 4 

############### WIN BEEP PARAMETERS ########
tone4:     .byte 70
duration4: .byte 500
volume4:   .byte 40
inst4:    .byte 7

 tone5:     .byte 73
duration5: .byte 500
volume5:   .byte 40
inst5:    .byte 7

 tone6:     .byte 78
duration6: .byte 1000
volume6:   .byte 40
inst6:    .byte 7 

tone7:     .byte 78
duration7: .byte 500
volume7:   .byte 40
inst7:    .byte 7

 tone8:     .byte 85
duration8: .byte 500
volume8:   .byte 40
inst8:    .byte 7

 tone9:     .byte 90
duration9: .byte 1000
volume9:   .byte 40
inst9:    .byte 7 

.text

Main:

jal read_file	#read the word bank we created from high level language
jal Genword 	#call function to randomly pick up a word from word bank

menu:
jal showmenu	#print the main menu and let user choose 
li  $v0,5
syscall
move $s0,$v0	

beq $s0,1,read_user	#if user choose 1,start new game, taking input from user first
beq $s0,2,instructions	#if user choose 2,giving out the instruction                                
beq $s0,3,exit		#if user choose 3,exit game
beq $s0,4,credits	#if user choose 4,print credits                                                ############### # not done yet #######################
jal enterchoice		#make sure user pick the valid choice. Any thing other than 1-4 will give error 

#error check function for menu choice
enterchoice:
	blt $s0,1,wrongenter
	bgt $s0,4,wrongenter
jr	$ra
wrongenter:
	li  $v0,4
	la $a0,wrongchoice
	syscall
	j menu
#rules explaination
instructions:                                         
        li $v0,4
        la $a0,instruct
        syscall
        j menu

credits:   
        li $v0,4
        la $a0,credit1
        syscall
        
        li $v0,4
        la $a0,credit2
        syscall
        
        li $v0,4
        la $a0,credit3
        syscall
        j menu 
#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#
#read user input of their guess
read_user:
        li $v0,4
        la $a0,times_guess     #print guess how many times
        syscall

        li $v0,5
        syscall
        sw $v0,countmax         #get the max_time for guess

start:
	li $v0,4
	la $a0, guessprompt1
	syscall
	
	li $v0,4
	la $a0, guessprompt2
	syscall
	
	li $v0,4
	la $a0, guessprompt3
	syscall
	
		#get user's guess 
	li $v0, 8
	la $a0,userguess
	la $a1,64
	syscall

#v0 and v1 are used for store the number of bulls and cows 
	li	$v0, 0
	li	$v1, 0
#s0 and s1 are used to store the address of answer and user guess
	la	$s0, answer
	la	$s1, userguess
	
	lb	$t1, 0($s0) #t1-t4 store every byte in answer
	lb	$t2, 1($s0)
	lb	$t3, 2($s0)
	lb	$t4, 3($s0)

	lb	$t5, 0($s1) #t5-t9 store every byte in userguess. $t9 for make word length checking. only t5-t8 are used for main compare
	lb	$t6, 1($s1)
	lb	$t7, 2($s1)
	lb	$t8, 3($s1)	
	lb	$t9, 4($s1)
	
	#---------------2 functions now : input 1: get the first char you did not guess ; input 2: exit and show answer   -------------------####
	
	beq     $t5,49,tip		 #49 = 1 in ascii
	beq     $t5,50,showanswer 
		
	jal	errorcheck1	#repitition check
	jal	errorcheck2	#word length check
	jal	errorcheck3	#valid character check
	
	lw	$t0, count	#t0 is used for tracking how many tries user take	
	jal	compare
	sw	$v0, bulls   #position and char right
	sw	$v1, cows    #only char right

	jal	result
	addi	$t0, $t0, 1
	sw      $t0,count
	lw      $v0,bulls		
	beq	$v0, 4, success #when cow reach 4, branch to user win sectio	
	
	lw $v0,count
	lw $v1,countmax
	bgt $v0,$v1 reachlimit      #compare count and countmax , if reached , show answer and restart 
	
	
	j	start
        
#when reach 4 bulls, user win
success:
	li	$v0, 4
	la	$a0, right
	syscall	
	jal	win_sound
	j        exit

#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#
#all 3 error check, dupliation, wrong length word and not valid character	
#check duplicated letter
errorcheck1:
	beq	$t5, $t6, dupe
	beq	$t5, $t7, dupe
	beq	$t5, $t8, dupe
	beq	$t6, $t7, dupe
	beq	$t6, $t8, dupe
	beq	$t7, $t8, dupe
	jr	$ra
dupe:
	li $v0, 4
	la $a0, dupeerror
	syscall	
	j	start

#check exactly 4 letters
errorcheck2: 
	beq	$t5,0,counts  #where error happens
	beq	$t6,0,counts
	beq	$t7,0,counts
	beq	$t8,0,counts
	bne	$t9,10,counts  #also 
jr $ra

counts:
	li $v0,4
	la $a0,counterror
	syscall
	j	start


#check low case
errorcheck3: 
	blt	$t5,97,notlow
	blt	$t6,97,notlow
	blt	$t7,97,notlow
	blt	$t8,97,notlow
	bgt	$t5,122,notlow
	bgt	$t6,122,notlow
	bgt	$t7,122,notlow
	bgt	$t8,122,notlow
	jr $ra

notlow:
	li $v0,4
	la $a0,lowcaseerror
	syscall
	j	start	

#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#
#main compare functions to find how many bulls and cows user got
compare:	
n0:	bne	$t1, $t5, n1
	addi	$v0, $v0, 1
	li      $s2 ,1        #use pos[4]as index of last guess status, 1 as guessed , 0 as not guessed
	sw      $s2,pos	      # pos[0] = 1
n1:	bne	$t2,,$t6, n2
	addi	$v0, $v0, 1
	li      $s2 ,1        #use pos[4]as index of last guess status, 1 as guessed , 0 as not guessed
	sw      $s2,pos+4     #pos [1] =1
n2:	bne	$t3, $t7, n3
	addi	$v0, $v0, 1
	li      $s2 ,1       
	sw      $s2,pos+8
n3:	bne	$t4, $t8, n4
	addi 	$v0, $v0, 1
	li      $s2 ,1       
	sw      $s2,pos+12
n4:	bne	$t2,$t5, n5
	addi	$v1, $v1, 1
	li      $s2 ,1       
	sw      $s2,pos+4
n5:	bne	$t3, $t5, n6
	addi	$v1, $v1, 1
	li      $s2 ,1       
	sw      $s2,pos+8
n6:	bne	$t4, $t5, n7
	addi	$v1, $v1, 1
	li      $s2 ,1       
	sw      $s2,pos+12
n7:	bne	$t1, $t6, n8
	addi	$v1, $v1, 1
	li      $s2 ,1       
	sw      $s2,pos
n8:	bne	$t3, $t6, n9
	addi	$v1, $v1, 1
	li      $s2 ,1       
	sw      $s2,pos+8
n9:	bne	$t4,$t6, n10
	addi	$v1, $v1, 1
	li      $s2 ,1       
	sw      $s2,pos+12
n10:	bne	$t1,$t7, n11
	addi	$v1, $v1, 1
	li      $s2 ,1       
	sw      $s2,pos
n11:	bne	$t2, $t7, n12
	addi	$v1, $v1, 1
	li      $s2 ,1       
	sw      $s2,pos+4
n12:	bne	$t4, $t7, n13
	addi	$v1, $v1, 1
	li      $s2 ,1       
	sw      $s2,pos+12
n13:	bne	$t1, $t8, n14
	addi	$v1, $v1, 1
	li      $s2 ,1       
	sw      $s2,pos
n14:	bne	$t2, $t8, n15
	addi	$v1, $v1, 1
	li      $s2 ,1       
	sw      $s2,pos+4
n15:	bne	$t3, $t8, n16
	addi	$v1, $v1, 1
	li      $s2 ,1       
	sw      $s2,pos+8
n16:	jr	$ra

#print the result to tell the user how many bulls and cows they got
result:

	li $v0,1
	lw $a0,count
	syscall
	
	li $v0,4
	la $a0,printcount
	syscall
	
	li	$v0, 1
	lw	$a0, bulls
	syscall	
	li	$v0, 4
	la	$a0, nbulls
	syscall
	li	$v0, 1
	lw	$a0, cows
	syscall
	li	$v0, 4
	la	$a0, ncows
	syscall
	jr $ra
	

reachlimit:
        li $v0,4
        la $a0,limit
        syscall
        
        li $v0,4
        la $a0,reveal
        syscall
        li $v0,4
        la $a0,answer
        syscall
        
        jal lose_sound
        j Main
  
 tip:
        li $v0,4
        la $a0,printtip
        syscall
 
        lw $s2,pos
        beq $s2,1,tip1
        li $v0,11
        la $a0,($t1)
        syscall
        j start
 tip1:       
        lw $s2,pos+4
        beq $s2,1,tip2
        li $v0,11
        la $a0,($t2)
        syscall
        j start
 tip2:
       lw $s2,pos+8
        beq $s2,1,tip3
        li $v0,11
        la $a0,($t3)
        syscall
        j start
 tip3:
        lw $s2,pos+12
        beq $s2,1,start
        li $v0,11
        la $a0,($t4)
        syscall
        
        j start

 showanswer:   
       
        li $v0,4
        la $a0,reveal
        syscall
        li $v0,4
        la $a0,answer
        syscall
        j exit
exit:

li $v0,4
la $a0,quit
syscall
li $v0, 10
syscall
#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------

#show the main menu and let the user choose which one to continue
showmenu:
	li $v0, 4
	la $a0, title
	syscall

	li $v0, 4
	la $a0, from
	syscall

	li $v0, 4
	la $a0, menu1
	syscall

	li $v0, 4
	la $a0, menu2
	syscall

	li $v0, 4
	la $a0, menu3
	syscall

	li $v0, 4
	la $a0, menu4
	syscall

	li $v0, 4
	la $a0, menu5
	syscall

	li $v0, 4
	la $a0, menu6
	syscall
jr $ra

#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------

#open text file of word bank and load it into memory then close it
read_file:
#open file
	li $v0, 13
	la $a0, filename
	li $a1, 0
	syscall
	move $s0, $v0  #file descriptor in $s0=descriptor

#read file
	li $v0, 14
	move $a0, $s0	#move decriptor into $a0
	la $a1, filecontent
	la $a2, 2000	#harecode the byte length of read file
	syscall

#close file
	li $v0, 16
	move $a0, $s0
	syscall

jr	$ra

#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------

#randomly select a word from word bank which is generated from high level language
Genword:
	la $s0,filecontent	#load address of word bank in $s0
	li $t0, 0	#loop counter

	li $v0, 42
	li $a1, 496	#upper boundary 496 (total 496 word in bank)
	syscall		#generate a random number between 0-100

	sll $a0,$a0,2	#random number *4, word aligned
	add $t1,$s0,$a0	#caculate the address for offset stored in $t1 and base in $s0

	#copy string into the anser byte by byte
	read_word:	
	la  $t2, answer		#load the address of answer
	add $t2, $t0,$t2	#calculate the store byte position
	lb  $s1, ($t1)	#load the content from $t1
	sb  $s1, ($t2)
	addi $t1,$t1,1
	addi $t0,$t0,1
	bne $t0,4,read_word #when loop count 4, quit loop. copy done
		
jr	$ra

#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-------#-----
# play sound effect
lose_sound:
##### BEEP 1 ######
 li $v0,31 
 la $t0,tone 
 lbu $a0,0($t0) 
 addi $t2,$a0,12 
 
 la $t1,duration 
 lbu $a1,0($t1) 
 
  la $t2,inst 
 lbu $a2,0($t2) 
 
 la $t3,volume 
 lbu $a3,0($t3)
 syscall
 
  li $v0, 32
  li $a0, 200
  syscall
 ###### BEEP 2 ###### 
 li $v0,31 
 la $t0,tone2 
 lbu $a0,0($t0) 
 addi $t2,$a0,12 
 
 la $t1,duration2 
 lbu $a1,0($t1) 
 
  la $t2,inst2 
 lbu $a2,0($t2) 
 
 la $t3,volume2 
 lbu $a3,0($t3)
 syscall 
 
  li $v0, 32
  li $a0, 175
  syscall
##### BEEP 3 ######### 
  li $v0,31 
 la $t0,tone3 
 lbu $a0,0($t0) 
 addi $t2,$a0,12 
 
 la $t1,duration3 
 lbu $a1,0($t1) 
 
  la $t2,inst3 
 lbu $a2,0($t2) 
 
 la $t3,volume3 
 lbu $a3,0($t3)
 syscall 
 

  li $v0, 32
  li $a0, 1000
  syscall
 
 jr $ra

 
win_sound:
 ###### BEEP 4 #####
  li $v0,31 
 la $t0,tone4 
 lbu $a0,0($t0) 
 addi $t2,$a0,12 
 


 
 la $t1,duration4 
 lbu $a1,0($t1) 
 
  la $t2,inst4 
 lbu $a2,0($t2) 
 
 la $t3,volume4 
 lbu $a3,0($t3)
 syscall
 
  li $v0, 32
  li $a0, 140
  syscall
 ##### BEEP 5 ###### 
 li $v0,31 
 la $t0,tone5 
 lbu $a0,0($t0) 
 addi $t2,$a0,12 
 
 la $t1,duration5 
 lbu $a1,0($t1) 
 
  la $t2,inst5 
 lbu $a2,0($t2) 
 
 la $t3,volume5 
 lbu $a3,0($t3)
 syscall 
 
  li $v0, 32
  li $a0, 140
  syscall
####### BEEP 6 ########### 
  li $v0,31 
 la $t0,tone6 
 lbu $a0,0($t0) 
 addi $t2,$a0,12 
 
 la $t1,duration6 
 lbu $a1,0($t1) 
 
  la $t2,inst6 
 lbu $a2,0($t2) 
 
 la $t3,volume6 
 lbu $a3,0($t3)
 syscall 
 
   li $v0, 32
  li $a0, 140
  syscall
 
  ###### BEEP 7 #####
  li $v0,31 
 la $t0,tone7 
 lbu $a0,0($t0) 
 addi $t2,$a0,12 
 


 
 la $t1,duration7 
 lbu $a1,0($t1) 
 
  la $t2,inst7 
 lbu $a2,0($t2) 
 
 la $t3,volume7 
 lbu $a3,0($t3)
 syscall
 
  li $v0, 32
  li $a0, 140
  syscall
 ##### BEEP 8 ###### 
 li $v0,31 
 la $t0,tone8 
 lbu $a0,0($t0) 
 addi $t2,$a0,12 
 
 la $t1,duration8 
 lbu $a1,0($t1) 
 
  la $t2,inst8 
 lbu $a2,0($t2) 
 
 la $t3,volume8 
 lbu $a3,0($t3)
 syscall 
 
  li $v0, 32
  li $a0, 140
  syscall
  
####### BEEP 9 ########### 
  li $v0,31 
 la $t0,tone9 
 lbu $a0,0($t0) 
 addi $t2,$a0,12 
 
 la $t1,duration9 
 lbu $a1,0($t1) 
 
  la $t2,inst9 
 lbu $a2,0($t2) 
 
 la $t3,volume9 
 lbu $a3,0($t3)
 syscall 
 
 
jr   $ra
