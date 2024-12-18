.data
gridsize:   .byte 8,8
character:  .byte 0,0
box:        .byte 0,0
target:     .byte 0,0
newline:		.string "\n"
invalidString:	.string "\nThe character you just inputted is invalid. \nPlease enter another input:\n"
noChangeString:	.string "\nInput received. No changes to the board. \nPlease enter another input:\n"
resetString: .string "\nYou have inputted to reset the game. \nResetting the entire board.\n\n"
winString: .string "\nCongratulations! You successfully placed the box in the target!\n\n"
instructionString: .string "You can move using the WASD keys. \nTo restart the board press the R key. \nEnter an input:\n"
introString: .string "Welcome to Sokoban Assembly!\nInput the X and Y values for the board. \nRecommended to start with 8x8 at first. \n"
xString: .string "Input X value:\n"
yString: .string "Input Y value:\n"
seed:       .word 123 # Initial seed value 
a:          .word 1103515245 # Multiplier (values from common use table from LCG Wikipedia)
c:          .word 12345# Increment
m:          .word 2147483648 # Modulus (2^31)

.text
.globl _start

_start:
    # TODO: Generate locations for the character, box, and target. Static
    # locations in memory have been provided for the (x, y) coordinates 
    # of each of these elements.
    # 
    # There is a notrand function that you can use to start with. It's 
    # really not very good; you will replace it with your own rand function
    # later. Regardless of the source of your "random" locations, make 
    # sure that none of the items are on top of each other and that the 
    # board is solvable.
	li sp, 0x80000000
	initializeLocations:
	#todo for lorenz: make my own rand function using some sort of pseudoRandom num gen alg maybe try linear confruel alg)
	
		#todo: make user input for board size::
		la a0, introString
		li a7, 4
		ecall 
		
		
		gridsizeInput:
			la a0, xString
			li a7, 4
			ecall 
			
			li a7, 5 #syscall to read user input (stores integer input into a0)
			ecall
			beq a0, zero, badInput
			mv t0, a0 #store good input
			
			
			la a0, yString
			li a7, 4
			ecall 
			
			li a7, 5 #syscall to read user input (stores integer input into a0)
			ecall
			beq a0, zero, badInput
			mv t1, a0 #store good input
			
			# Create the grid coordinates
			j createGrid
			
		badInput:
			la a0, invalidString
			li a7, 4
			ecall 
			j gridsizeInput
		
		createGrid:
			#stores x and y value for grid
			la t3, gridsize
			sb t0, 0(t3)
			addi t3, t3, 1 # y value of grid
			sb t1, 0(t3)
			addi t3, t3, -1 #back to x value
	
		# First generate all locations for the character, box, and target.
		#location arrays
		# t1 = character
		# t2 = target
		# t3 = box
	
		#load character array into t1
		la t4, gridsize
		lb t5, 0(t4) #t5 = x value of grid
		lb t6, 1(t4) #t6 = y value of grid
		la t1, character #t1 = &character
		mv a0, t5 # set a0 = x value of grid
		jal lcgNum
		#li a0, 2 #for debugging
		sb a0, 0(t1) #set x value
		addi t1, t1, 1 #change to y value address 
		# !!!(since theyre bytes we move by a single byte)!!!

		mv a0, t6
		jal lcgNum
		#li a0, 2
		sb a0, 0(t1) #set y value
		addi t1, t1, -1 #change back to x value address
		
		#load target array into t2
		addi t6, t6, -1 # back to x value
		la t2, target
		mv a0, t5
		jal lcgNum
		la t2, target
		#li a0, 2
		sb a0, 0(t2) #set x value
		addi t2, t2, 1 #change to y value address

		mv a0, t6
		jal lcgNum
		la t2, target
		#li a0, 2
		sb a0, 0(t2) #set y value
		addi t2, t2, -1 #change back to x value address

		#check for overlap:
		#input values for t1 and t2 into the overlap funct
		lb a0, 0(t1)
		addi t1, t1, 1 #change to y value address
		lb a1, 0(t1)
		addi t1, t1, -1 #change back to x value address

		lb a2, 0(t2)
		addi t2, t2, 1 #change to y value address
		lb a3, 0(t2)
		addi t2, t2, -1 #change back to x value address

		mv a5, t5
		mv a6, t6
		jal checkOverlap	
		
		la t1, character
		la t2, target
		la t3, box
		# change new x1 and y1 value addresses (for target)
		sb a0, 0(t2) #set x value
		addi t2, t2, 1 #change to y value address
		sb a1, 0(t2) #set y value
		addi t2, t2, -1 #change back to x value address
		
		initializeBox:
			la t4, gridsize
			lb t5, 0(t4) #t5 = x value of grid
			lb t6, 1(t4) #t6 = y value of grid
			#load box array into t3
			la t3, box
			mv a0, t5
			jal lcgNum
			la t2, target
			la t3, box
			#li a0, 5
			sb a0, 0(t3) #set x value
			addi t3, t3, 1 #change to y value address

			mv a0, t6
			jal lcgNum
			la t2, target
			la t3, box
			#li a0, 7
			sb a0, 0(t3) #set y value
			addi t3, t3, -1 #change back to x value address

			#check for overlap between target and box:
			# input values for t2 and t3 into the overlap function
			lb a0, 0(t2)
			addi t2, t2, 1 #change to y value address
			lb a1, 0(t2)
			addi t2, t2, -1 #change back to x value address

			lb a2, 0(t3)
			addi t3, t3, 1 #change to y value address
			lb a3, 0(t3)
			addi t3, t3, -1 #change back to x value address

			mv a5, t5
			mv a6, t6
			jal checkOverlap

			la t1, character
			la t2, target
			la t3, box
			# change new x1 and y1 value addresses (for box)
			sb a0, 0(t3) #set x value
			addi t3, t3, 1 #change to y value address
			sb a1, 0(t3) #set y value
			addi t3, t3, -1 #change back to x value address

			#check for overlap between character and box:
			#input values for t2 and t3 into the overlap funct
			lb a0, 0(t1)
			addi t1, t1, 1 #change to y value address
			lb a1, 0(t1)
			addi t1, t1, -1 #change back to x value address

			lb a2, 0(t3)
			addi t3, t3, 1 #change to y value address
			lb a3, 0(t3)
			addi t3, t3, -1 #change back to x value address

			mv a5, t5
			mv a6, t6
			jal checkOverlap

			la t1, character
			la t2, target
			la t3, box
			# change new x1 and y1 value addresses (for box)
			sb a0, 0(t3) #set x value
			addi t3, t3, 1 #change to y value address
			sb a1, 0(t3) #set y value
			addi t3, t3, -1 #change back to x value address
			
			#check if the "changed value" of box is not equal to the character again
			lb a2, 0(t2)
			addi t2, t2, 1 #change to y value address
			lb a3, 0(t2)
			addi t2, t2, -1 #change back to x value address

			# checking the x value between box and character. If everything 
			# is fine, there is no overlap and we can move on
			bne a0, a2, solvabilityCheck 
			
			secondaryCheck:
				beq a1, a3, initializeBox
				
		#There should now be no overlap
		
		solvabilityCheck:
			# Second, Check for solvability
			# in the case where the game is not solvable, we remake the box location
			la t2, box
			lb a0, 0(t2)
			addi t2, t2, 1 
			lb a1, 0(t2)
			addi t2, t2, -1
			la t3, target
			lb a2, 0(t3)
			addi t3, t3, 1 #change to y value address
			lb a3, 0(t3)
			addi t3, t3, -1 #change back to x value address
			
			la t4, gridsize
			lb t5, 0(t4) #t5 = x value of grid
			lb t6, 1(t4) #t6 = y value of grid
			mv a5, t5
			mv a6, t6

			jal checkSolvability
			la t1, character
			la t2, target
			la t3, box
			# remake box location is the game is not solvable
			li t5, 1  
			beq a0, t5, initializeBox
   
    # TODO: Now, print the gameboard. Select symbols to represent the walls,
    # character, box, and target. Write a function that uses the location of
    # the various elements (in memory) to construct a gameboard and that 
    # prints that board one character at a time.
    # HINT: You may wish to construct the string that represents the board
    # and then print that string with a single syscall. If you do this, 
    # consider whether you want to place this string in static memory or 
    # on the stack. 
	
		
	initializeGameboard:
		la t1, character
		la t2, target
		la t3, box
		#set arguments for gameboard:
		mv a1, t1	# character array = a0
		mv a2, t2	# target array = a1
 		mv a3, t3	# box array = a2
		la a4, gridsize #gridsize array = a3

		la t6, newline
		mv a5, t6 # newline string = a4
		
		
		jal printGameboard
		
		la a0, instructionString
		li a7, 4
		ecall 
		
    # TODO: Enter a loop and wait for user input. Whenever user input is
    # received, update the gameboard state with the new location of the 
    # player (and if applicable, box and target). Print a message if the 
    # input received is invalid or if it results in no change to the game 
    # state. Otherwise, print the updated game state. 
    #
    # You will also need to restart the game if the user requests it and 
    # indicate when the box is located in the same position as the target.
    # For the former, it may be useful for this loop to exist in a function,
    # to make it cleaner to exit the game loop.

	# Precondition: the user may only use WASD to move  
	inputLoop:
		li a7, 12	#syscall to read user input (stores char input into a0)
		ecall
		
		mv t1, a0 #save input
		la a0, newline
		li a7, 4
		ecall 
		ecall
		
		mv a0, t1 # move input back for function
		
		jal interpretInput 
		
		li a7, 1 #delete later
		#ecall
		
		# set up arguments for computeAction
		# a0 = user interpretted input
		# a1 = character array
		# a2 = box array
		# a3 = grid size array
		
		la a1, character
		la a2, box
		la a3, gridsize
		
		jal computeAction
		
		# check for special inputs
		li t1, 0
		beq a0, t1, printInvalid
		li t1, 1
		beq a0, t1, printNoChange
		li t1, 3
		beq a0, t1, printReset
		
		la t1, target
		la t2, box
		mv a1, t1
		mv a2, t2
		la a0, winString
		jal checkWin
		li t6, 0
		beq a0, t6, exit #quit when the player wins
		
		#set arguments for gameboard:
		la t1, character
		la t2, target
		la t3, box
		mv a1, t1	# character array = a0
		mv a2, t2	# target array = a1
 		mv a3, t3	# box array = a2
		la a4, gridsize #gridsize array = a3

		la t6, newline
		mv a5, t6 # newline string = a4
		jal printGameboard
		
		j inputLoop
		
		printInvalid:
			la a0, invalidString
			li a7, 4
			ecall
			j inputLoop

		printNoChange:
			la a0, noChangeString
			li a7, 4
			ecall
			j inputLoop
		
		printReset:
			la a0, resetString
			li a7, 4
			ecall
			j initializeLocations

    # TODO: That's the base game! Now, pick a pair of enhancements and
    # consider how to implement them.
	
exit:
    li a7, 10
    ecall
    
     
# --- HELPER FUNCTIONS ---
# Feel free to use, modify, or add to them however you see fit.
     
# Arguments: an integer MAX in a0
# Return: A number from 0 (inclusive) to MAX (exclusive)
notrand:
    mv t0, a0
    li a7, 30
    ecall             # time syscall (returns milliseconds)
    remu a0, a0, t0   # modulus on bottom bits 
    li a7, 32
    ecall             # sleeping to try to generate a different number
    jr ra

# Citation:
# Rotenberg, A. and Thomson. W. E. 1958. The Linear congruential generator. 
# https://www.geeksforgeeks.org/linear-congruence-method-for-generating-pseudo-random-numbers/ 

# Arguments: an integer MAX in a0
# Return: A number from 0 (inclusive) to MAX (exclusive) in a0
lcgNum:
	#formula: X_n+1 = (a * X_n + c) mod m
	# X_n+1 = pseudo random number (new seed to use)
	# X_n = initial seed 
	# a = multiplier (0, m)
	# c = increment (0, m)
	# m = modulus
	
	# compute the formula:
	lw t2, seed 		# initialize seed
	lw t3, a 			# initialize multiplier a
	mul t2, t2, t3		# a * X_n
	lw t3, c 			# initialize increment c
	add t2, t2, t3 		# (a * X_n) + c
	lw t3, m 			# initialize modulus
	remu t2, t2, t3		# (a * X_n + c) mod m
	
	la t3, seed # load address of seed into t4
	sw t2, 0(t3) # store the new seed for next iterations
	
    remu t2, t2, a0 # to get the number within the given range
	mv a0, t2
	ret


# Arguments: x1 value in a0, y1 value in a1, x2 value in a3, y2 value in a4, grid x in a5, grid y in a6
# Return: new x2 value in a0, new y2 value in a1
checkOverlap:
	addi sp, sp, -4          # Allocate space on the stack for ra and two local variables
    sw ra, 4(sp)             # Save return address on the stack
	
	mv t0, a0 # t0 = t1 x value
    mv t1, a1 # t1 = t1 y value
	mv t2, a2 # t2 = t2 x value
    mv t3, a3 # t3 = t2 y value
	
	valueCheck:
		bne t0, t2, done # check if x values are the same
		bne t1, t3, done # check if y values are the same
		
		#since both are equal we must switch then check again
		
		mv a0, a5
		#li a0, 8 #change this later for user inputted coordinates
		jal lcgNum
		mv t2, a0 # t0 = new t0 x value
	
		mv a0, a6
		#li a0, 8 #change this later for user inputted coordinates
		jal lcgNum
		mv t3, a0 # t1 = new t1 y value
		j valueCheck
		
	done:
		# return the new values
		mv a0, t2
		mv a1, t3
		lw ra, 4(sp)             # Restore return address from the stack
    	addi sp, sp, 4 
		ret
	
# Arguments: box x value in a0, box y value in a1, target x value in a2, target y value in a3, grid x in a5, grid y in a6
# Return: 0 in a0 if solvable, 1 in a0 if unsolvable
checkSolvability:
	#check that the box isnt in the corner
	#check that the box is at the wall but also the target is 
	mv t0, a0 # t0 = box x value
    mv t1, a1 # t1 = box y value
	mv t2, a2 # t2 = target x value
    mv t3, a3 # t3 = target y value
	
	mv t4, a5 # grid max x value
	mv t5, a6 # grid max y value
	addi t4, t4, -1
	addi t5, t5, -1
	
	checkLeftWall:
		#check if the box x value is equivalent to the leftmost available column
		bne t0, zero, checkRightWall
		#check if it is in the top left or bottom left corner
		beq t1, zero, unsolvable # top left (0, 0)
		beq t1, t5, unsolvable # bottom left (0, 7) change if we dont wanna do 8x8
		
		#check if the target is at the same wall as the box
		# if it is, then the game is solvable
		beq t2, zero, solvable
		
	checkRightWall:
		#check if the box x value is equivalent to the rightmost available column
		bne t0, t4, checkTopWall
		
		beq t1, zero, unsolvable # top right (7, 0)
		beq t1, t5, unsolvable # bottom right (7, 7) change if we dont wanna do 8x8
		
		#check if the target is at the same wall as the box
		# if it is, then the game is solvable
		beq t2, t4, solvable
		
	# After the two vertical wall checks, it cannot be in the corner,  
	# but the target and box could still be in separate areas
	# resulting in an unsolvable game.
	
	checkTopWall:
		#check if the box y value is equivalent to the topmost available row
		bne t1, zero, checkBottomWall
		
		#check if the target is at the same wall as the box
		# if it is, then the game is solvable
		beq t2, zero, solvable
		# otherwise unsolvable
		j unsolvable
		
	checkBottomWall:
		#check if the box y value is equivalent to the bottommost available row
		bne t1, t5, solvable
		
		#check if the target is at the same wall as the box
		# if it is, then the game is solvable
		beq t2, t5, solvable
		# otherwise unsolvable
		j unsolvable
		
	unsolvable:
		li a0, 1
		ret 
		
	solvable:
		li a0, 0
		ret 
	
	
# Arguments: character array in a0, target array in a1, box array in a2, gameboard array in a3, newline string in a4
# Return: nothing (but print out the board)
	printGameboard:
	#initialize the x-values and y-values for character
	#loading t0 to a0[0]
	lb t0, 0(a1)
	#INCREMENT A00000
	#initialize the x-values and y-values for target
	lb t1, 0(a2)
	
	#initialize the x-values and y-values for box
	lb t2, 0(a3)
	
	#initialize the x-values and y-values for grid size (starts on x value)
	lb t3, 0(a4)
	
	#increment counter
	li t4, -1 	# x value counter
	li t5, -1	# y value counter
	
	#number and symbol register
	li t6, -1

	# Example of gameboard
	# (-1, -1) (0, -1) (1, -1) (2, -1) (3, -1) (4, -1)
	# (-1,  0) (0,  0) (1,  0) (2,  0) (3,  0) (4,  0) 
	# (-1,  1) (0,  1) (1,  1) (2,  1) (3,  1) (4,  1)
	# (-1,  2) (0,  2) (1,  2) (2,  2) (3,  2) (4,  2)
	# (-1,  3) (0,  3) (1,  3) (2,  3) (3,  3) (4,  3)
	# (-1,  4) (0,  4) (1,  4) (2,  4) (3,  4) (4,  4)
	
	# 111111
	# 100001
	# 193801
	# 100001
	# 111111
	
	# legend
	# 1 = wall
	# 0 = empty space
	# 9 = character
	# 3 = box
	# 4 = target
	
	# Now we can check all of the if statements
	printTopWall:
		bne t6, t5, printLeftWall	# if the y value counter != -1 then its not at the top wall
		beq t4, t3, printRightWall	# if the x value counter != grid max x value then its not the right wall
		li a0, 1 
		li a7, 1 	# system call code for print_integer
		ecall 	# print the string
		j increment
		
	printLeftWall:
		bne t6, t4, printRightWall	# if the x value counter != -1 then its not the left wall
		li a0, 1 
		li a7, 1 	# system call code for print_integer
		ecall 	# print the string
		j increment
			
	printRightWall:
		bne t3, t4, printBottomWall	# if the x value counter != grid max x value then its not the right wall
		li a0, 1 
		li a7, 1 	# system call code for print_integer
		ecall 	# print the string
		j printNewline
		
	printBottomWall:
		addi a4, a4, 1	# go to grid max y value
		lb t3, 0(a4)
		bne t5, t3, printCharacter	# if the y value counter != grid max y value then its not the left wall
		addi a4, a4, -1	# go to grid max y value
		lb t3, 0(a4)
		li a0, 1 
		li a7, 1 	# system call code for print_integer
		ecall 	# print the string
		j increment
		
	printCharacter:
		# go to grid max x value if they branched 
		# (since if we branch, it'll stay at grid[1] instead of grid[0])
		addi a4, a4, -1	# go to grid max y value
		lb t3, 0(a4)
		
		# make sure that the x and y value counters are at the character coordinate
		bne t4, t0, printTarget	# x value
		addi a1, a1, 1	# go to character y value
		lb t0, 0(a1) # load character y value

		
		bne t5, t0, decrementChar	# y value
		addi a1, a1, -1	# go to character x value
		lb t0, 0(a1) # load character x value
		li a0, 9 
		li a7, 1 	# system call code for print_integer
		ecall 	# print the string
		j increment
	
	decrementChar:
		# Sole purpose to decrement the char array when we branch in printCharacter when checking y value
		addi a1, a1, -1	# go to character y value
		lb t0, 0(a1) # load character y value
		j printTarget
	
	printTarget:
		# make sure that the x and y value counters are at the character coordinate
		bne t4, t1, printBox	# x value
		addi a2, a2, 1	# go to target y value
		lb t1, 0(a2) # load target y value
		
		bne t5, t1, decrementTarget	# y value
		addi a2, a2, -1	# go to target y value
		lb t1, 0(a2) # load target y value
		
		li a0, 8 
		li a7, 1 	# system call code for print_integer
		ecall 	# print the string
		j increment
		
	decrementTarget:
		# Sole purpose to decrement the char array when we branch in printCharacter when checking y value
		addi a2, a2, -1	# go to target y value
		lb t1, 0(a2) # load target y value
		j printBox
		
	printBox:
		# make sure that the x and y value counters are at the character coordinate
		bne t4, t2, printEmptySpace	# x value
		addi a3, a3, 1	# go to target y value
		lb t2, 0(a3) # load target y value

		bne t5, t2, decrementBox	# y value
		addi a3, a3, -1	# go to target y value
		lb t2, 0(a3) # load target y value
		li a0, 3 
		li a7, 1 	# system call code for print_integer
		ecall 	# print the string
		j increment
		
	decrementBox:
		# Sole purpose to decrement the char array when we branch in printCharacter when checking y value
		addi a3, a3, -1	# go to target y value
		lb t2, 0(a3) # load target y value
		j printEmptySpace
		
	printEmptySpace:
		li a0, 0 
		li a7, 1 	# system call code for print_integer
		ecall 	# print the integer
		j increment
		
	printNewline:
		mv a0, a5	# set a0 = \n
		li a7, 4	# system call code for print_string
		ecall
		addi a4, a4, 1	# go to grid max y value
		lb t3, 0(a4)
		beq t5, t3, complete
		addi a4, a4, -1	# go to grid max y value
		lb t3, 0(a4)
		# since it has reached a new line, we increment the y value 
		# and reset out x value
		addi t5, t5, 1	# increment the y value
		li t4, -1
		j printTopWall
		
	increment:
		addi t4, t4, 1	# increment the x value
		j printTopWall
		
	complete:
		# make sure that the x and y value counters are at the very last coordinate
		#bne t4, t3, printTopWall	# x value
		#addi t3, t3, 1	# go to grid max y value
		#bne t5, t3, printTopWall	# y value
		#addi t3, t3, -1	# go back to grid max x value
		
		# if it is the last one, we just give space below the gameboard
		mv a0, a5	# set a0 = \n
		li a7, 4	# system call code for print_string
		ecall
		ecall
		ret
	
# Arguments: input character w, a, s, or d in a0
# Return: 1 = w, 2 = a, 3 = s, 4 = d, 5 = r, and 0 if invalid input
interpretInput:
	li t1, 'w'	# ASCII value of 'w'
    li t2, 'a'  # ASCII value of 'a'           
    li t3, 's'  # ASCII value of 's' 
    li t4, 'd'	# ASCII value of 'd'
	li t5, 'r'	# ASCII value of 'r'
	
	wKey:
		bne a0, t1, aKey	# check if the input is w
		li a0, 1
		ret
	
	aKey:
		bne a0, t2, sKey	# check if the input is w
		li a0, 2
		ret
	
	sKey:
		bne a0, t3, dKey	# check if the input is w
		li a0, 3
		ret
	
	dKey:
		bne a0, t4, rKey	# check if the input is w
		li a0, 4
		ret
	
	rKey:
		bne a0, t5, invalidInput	# check if the input is w
		li a0, 5
		ret
		
	invalidInput:
		li a0, 0
		ret
	
# Arguments: number from 0-5 from interpretInput in a0, character array in a1, box array in a2, gridsize in a3
# Return: 0 if invalid input, 1 if input is valid but cannot be computed, 2 if input is valid and change has been made, 3 for reset
computeAction:
	#initialize the x-value for character
	#loading t0 to a0[0]
	lb t1, 0(a1)
	#initialize the x-value for box
	lb t2, 0(a2)
	
	#initialize the x-values for gridsize
	lb t3, 0(a3)
	
	# initiialize number comparison (starting with invalid input)
	li t4, 0 

	#check which input it was 
	beq a0, t4, invalid
	li t4, 1 # switch input comparison to w
	beq a0, t4, moveUp
	li t4, 2 # switch input comparison to a
	beq a0, t4, moveLeft
	li t4, 3 # switch input comparison to s
	beq a0, t4, moveDown
	li t4, 4 # switch input comparison to d
	beq a0, t4, moveRight
	li t4, 5
	beq a0, t4, restart

	moveDown:
		# initialize registers and values:
		# t1 = char x value
		# t2 = box x value
		# t3 = grid y value
		# t4 = num comparison
		# t5 = char y value + 1
		# t6 = box y value + 1
		
		# store the updated movement value in t5
		addi a1, a1, 1	# go to character y value + 1
		lb t5, 0(a1)	# char y value
		addi t5, t5, 1	# char y value + 1
	
		addi a3, a3, 1	# go to grid max y value
		lb t3, 0(a3)	# grid y value
	
		# first check if there is a wall above
		beq t5, t3, cannotBeDone	# if the character moves up they will be in the wall
		
		# check if there is a box 
		# check if the x values are the same
		beq t2, t1, checkBoxDownY # the character x value and box x value
		
		# otherwise move up
		sb t5, 0(a1) # store the updated movement value back into the y value of character
		j validAndChange
	
	checkBoxDownY:
		# changes t2 from box x value to box y value
		
		#check that the move down goes into the box
		addi a2, a2, 1 # go to box y value
		lb t2, 0(a2)
		beq t5, t2, moveBoxDown
		# otherwise move up
		sb t5, 0(a1) # store the updated movement value back into the y value of character
		j validAndChange

	moveBoxDown:
		# before we can move the box and the player we must check
		# that there isnt a wall above
		
		#first check if there is a wall below
		lb t6, 0(a2)
		addi t6, t6, 1 # box y + 1
		
		# check if the box moves into 
		beq t6, t3, cannotBeDone	# if the character moves up the box will be in the wall
		
		# everything should be fine so move the player and the box
		sb t5, 0(a1) # stores updated move to char y
		sb t6, 0(a2) # stores updated move to box y
		
		j validAndChange
		
	moveRight:
		# initialize registers and values:
		# t1 = char x value
		# t2 = box y value
		# t3 = grid max x value
		# t4 = num comparison
		# t5 = char x value + 1
		# t6 = box x value + 1
		
		# store the updated movement value in t5
		lb t5, 0(a1)	# char x value
		addi t5, t5, 1	# char x value + 1
	
		lb t3, 0(a3)	# grid max x value
	
		# first check if there is a wall to the right
		beq t5, t3, cannotBeDone	# if the character moves up they will be in the wall
		
		# check if there is a box 
		# check if the y values are the same
		addi a2, a2, 1 # go to box y value
		lb t2, 0(a2)
		addi a1, a1, 1 # go to box y value
		lb t1, 0(a1)
		addi a1, a1, -1 # go to box x value again
		beq t2, t1, checkBoxRightX # the character y value and box y value
		
		# otherwise move right
		sb t5, 0(a1) # store the updated movement value back into the y value of character
		j validAndChange

	checkBoxRightX:
		# changes t2 from box y value to box x value
		
		#check that the move right goes into the box
		addi a2, a2, -1 # go to box x value
		lb t2, 0(a2)
		beq t5, t2, moveBoxRight
		# otherwise move right
		sb t5, 0(a1) # store the updated movement value back into the y value of character
		j validAndChange

	moveBoxRight:
		# before we can move the box and the player we must check
		# that there isnt a wall above
		
		#first check if there is a wall to the right
		lb t6, 0(a2) # box x value
		addi t6, t6, 1 # box x + 1
		
		beq t6, t3, cannotBeDone # if the character moves up the box will be in the wall
		
		# everything should be fine so move the player and the box
		sb t5, 0(a1) # stores updated move to char y
		sb t6, 0(a2) # stores updated move to box y
		
		j validAndChange	
	
	moveUp:
		# initialize registers and values:
		# t1 = char x value
		# t2 = box x value
		# t3 = -1 (top border)
		# t4 = num comparison
		# t5 = char y value - 1
		# t6 = box y value - 1
		
		# store the updated movement value in t5
		addi a1, a1, 1	# go to character y value + 1
		lb t5, 0(a1)	# char y value
		addi t5, t5, -1	# char y value - 1
	
		li t3, -1	# grid y value
	
		# first check if there is a wall above
		beq t5, t3, cannotBeDone	# if the character moves up they will be in the wall
		
		# check if there is a box 
		# check if the x values are the same
		beq t2, t1, checkBoxUpY # the character x value and box x value
		
		# otherwise move up
		sb t5, 0(a1) # store the updated movement value back into the y value of character
		j validAndChange
	
	checkBoxUpY:
		# changes t2 from box x value to box y value
		
		#check that the move down goes into the box
		addi a2, a2, 1 # go to box y value
		lb t2, 0(a2)
		beq t5, t2, moveBoxUp
		# otherwise move up
		sb t5, 0(a1) # store the updated movement value back into the y value of character
		j validAndChange

	moveBoxUp:
		# before we can move the box and the player we must check
		# that there isnt a wall above
		
		#first check if there is a wall above
		lb t6, 0(a2)
		addi t6, t6, -1 # box y - 1
		
		#check if the box gets pushed into the wall
		beq t6, t3, cannotBeDone
		
		# everything should be fine so move the player and the box
		sb t5, 0(a1) # stores updated move to char y
		sb t6, 0(a2) # stores updated move to box y
		
		j validAndChange

	moveLeft:
		# initialize registers and values:
		# t1 = char x value
		# t2 = box y value
		# t3 = -1
		# t4 = num comparison
		# t5 = char x value + 1
		# t6 = box x value + 1
		
		# store the updated movement value in t5
		lb t5, 0(a1)	# char x value
		addi t5, t5, -1	# char x value - 1
	
		li t3, -1	# grid max left x value
	
		# first check if there is a wall to the left
		beq t5, t3, cannotBeDone	# if the character moves up they will be in the wall
		
		# check if there is a box 
		# check if the y values are the same
		addi a2, a2, 1 # go to box y value
		lb t2, 0(a2)
		addi a1, a1, 1 # go to box y value
		lb t1, 0(a1)
		addi a1, a1, -1 # go to box x value again
		beq t2, t1, checkBoxLeftX # the character y value and box y value
		
		# otherwise move left
		sb t5, 0(a1) # store the updated movement value back into the y value of character
		j validAndChange

	checkBoxLeftX:
		# changes t2 from box y value to box x value
		
		#check that the move left goes into the box
		addi a2, a2, -1 # go to box x value
		lb t2, 0(a2)
		beq t5, t2, moveBoxLeft
		# otherwise move right
		sb t5, 0(a1) # store the updated movement value back into the y value of character
		j validAndChange

	moveBoxLeft:
		# before we can move the box and the player we must check
		# that there isnt a wall above
		
		#first check if there is a wall to the left
		lb t6, 0(a2) # box x value
		addi t6, t6, -1 # box x - 1
		
		beq t6, t3, cannotBeDone 
		
		# everything should be fine so move the player and the box
		sb t5, 0(a1) # stores updated move to char y
		sb t6, 0(a2) # stores updated move to box y
		
		j validAndChange	
	
	
	invalid:
		li a0, 0
		ret
	
	cannotBeDone:
		li a0, 1
		ret

	validAndChange:
		li a0, 2
		ret
	
	restart:
		li a0, 3
		ret

checkWin:
	lb t1, 0(a1) # target x
	lb t2, 1(a1) # target y
	lb t3, 0(a2) # box x
	lb t4, 1(a2) # box y
	
	bne t1, t3, noWin
	bne t2, t4, noWin
	
	li a7, 4
	ecall
	li a0, 0
	ret

	noWin:
		li a1, 1
		ret


	
	
