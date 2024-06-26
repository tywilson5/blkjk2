.model small
.stack 100h

.data

;Configuration Messages

welcome db "Welcome to Blackjack! Input starting amount (10-1000): $", 10, 13, 0
init_amount db 10 dup (0)        ;buffer for initial amount
comp_bet dw 0                    ;computer bet buffer
decks db "Select number of card decks (1-3): ", 10, 13, 0
decks_amount db 2 dup (0)       ; buffer for number of decks

bet_mode_msg db "Select computer betting mode (c/n/a): $", 10, 13, 0
bet_mode_options db "c - Conservative, n - Normal, a - Aggressive", 10, 13, 0

diff_msg db "Select computer difficulty (e/n/h): $", 10, 13, 0
diff_options db "e - Easy, n - Normal, h - Hard", 10, 13, 0

;Game Messages

bet_prompt db "Enter your bet: $", 0
player_hand db "Your hand: ", 0
computer_hand db "Computer hand: ", 0
player_options db "1 - Keep, 2 - Add card, 3 - Forfeit: $", 0
player_wins db "You win this turn!", 0
computer_wins db "Computer wins this turn!", 0
player_bust db "You bust! Computer wins.", 0
computer_bust db "Computer busts! You win.", 0
blackjack db "Blackjack!", 0
draw db "It's a draw!", 0
play_again db "Play again? (y/n): $", 0

choices_msg db "how would you like to play this turn?"
hit_msg db "1 - Hit $", 0
stand_msg db "2 - Stand $", 0
surrender_msg db "3 - Surrender $", 0
hit_play db "Hit $", 0
stand_play db "Stand $", 0
surrender_play db "Surrender $", 0
continue_play db "Do you want to continue the game?: $", 0
end_play db "Thank you for playing Blackjack!", 0


blackjack_win db "You win!", 0
bust db "You bust! Computer wins.", 0
dealer_bust db "Computer busts! You win.", 0
dealer_win db "Computer wins!", 0
player_win db "You win the turn!", 0
;Error Messages

invalid_input db "Invalid input. Please try again.", 0

;Card Data

suits db 'C', 'D', 'H', 'S'   ;Clubs, Diamonds, Hearts, Spades
ranks db 'A', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K'
card_values db 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10 ;card values (Ace can be 11 - add later)

;Other

newline db 10, 13, '$'
entrare db "  ", "$"
selection_msg db "You have selected: ", "$"

;Start

.code
start:
    mov ax, @data
    mov ds, ax

    call amount
    call deck

    call difficulty
    call turn
    

    mov ah, 4ch
    int 21h

;Amount Configuration

amount proc
    mov ax, @data
    mov ds, ax
config_amount:
    mov ah, 09h                     ;print string
    mov dx, offset welcome
    int 21h

    mov dx, offset newline
    int 21h

    mov si, offset init_amount         ;move SI to the starting amount

read_input_amount:
    mov ah, 01h                     ;read character from input
    int 21h  
    cmp al, 0Dh                     ;check for Enter
    je done_init_input              ;if Enter, exit loop
    mov [si], al
    inc si
    jmp read_input_amount

done_init_input:
    mov byte ptr [si], '$'          ;terminate string

    ret
amount endp

;Number of Decks Configuration

deck proc 
    mov ax, @data
    mov ds, ax

config_deck:
    mov ah, 09h                     ;display string function
    mov dx, offset decks
    int 21h

    mov dx, offset newline
    int 21h

    mov si, offset decks_amount       ;move SI to decks_amount buffer 

read_decks_amount:
    mov ah, 01h                     ;read character from input
    int 21h
    cmp al, 0Dh
    je done_decks_input            ;if Enter, exit loop
    mov [si], al
    inc si  
    jmp read_decks_amount

done_decks_input:
    mov byte ptr [si], '$'          ;terminate string

    ret
deck endp 

;Difficulty Configuration

difficulty proc 
    mov ax, @data
    mov ds, ax

config_diff:
    mov ah, 09h
    diff db 'Enter difficulty: $'     ;define the difficulty prompt

    mov dx, offset diff               ;print difficulty prompt
    int 21h
    mov dx, offset newline
    int 21h
    ;display difficulty options
    easy db 'Easy', '$' 
    easy_info db 'Easy mode description$'
    mov dx, offset easy
    int 21h
    mov dx, offset newline
    int 21h
    mov dx, offset entrare
    int 21h
    mov dx, offset easy_info
    int 21h
    mov dx, offset newline
    int 21h

    med db 'Medium', '$' 
    med_info db 'Medium mode description$' 

    mov dx, offset med
    int 21h
    mov dx, offset newline
    int 21h
    mov dx, offset entrare
    int 21h
    mov dx, offset med_info
    int 21h
    mov dx, offset newline
    int 21h

    hard db 'Hard', '$' 
    hard_info db 'Hard mode description$' 
    mov dx, offset hard
    int 21h
    mov dx, offset newline
    int 21h
    mov dx, offset entrare
    int 21h
    mov dx, offset hard_info
    int 21h
    mov dx, offset newline
    int 21h


read_diff:
    mov ah, 01h                     ;read char
    int 21h
    cmp al, 0Dh                     ;check if Enter is pressed 
    je comp_diff

comp_diff:
    cmp al, 'e'
    je selection_easy
    cmp al, 'm'
    je selection_med
    cmp al, 'h'
    je selection_hard
    jmp invalid

selection_easy:
    mov ah, 09h
    mov dx, offset newline
    int 21h
    mov dx, offset selection_msg
    int 21h
    mov dx, offset easy
    int 21h
    jmp exit

selection_med:
    mov ah, 09h
    mov dx, offset newline
    int 21h
    mov dx, offset selection_msg
    int 21h
    mov dx, offset med
    int 21h
    jmp exit

selection_hard:
    mov ah, 09h
    mov dx, offset newline
    int 21h
    mov dx, offset selection_msg
    int 21h
    mov dx, offset hard
    int 21h
    jmp exit

invalid:
    mov ah, 09h
    mov dx, offset newline
    diff_error db 'Invalid difficulty selection$' 
    int 21h
    mov dx, offset diff_error
    int 21h
    mov dx, offset newline
    int 21h
    jmp read_diff

exit:
    ret 
difficulty endp

;Turn Logic

turn proc 
    mov ax, @data ;initialize data segment
    mov ds, ax 

user_bet: 
    mov ah, 09h 
    mov dx, offset newline 
    int 21h
    mov dx, offset bet_prompt 
    int 21h     
    mov ah, 01h
    sub al, 30h         
    mov word ptr init_amount, ax ;update the initial amount

compare:   
    mov ah, 01h
    int 21h
    cmp al, 0Dh ;check for Enter
    je game_options
    mov [si], al
    inc si
    loop compare

game_options:                ;displays prompt
    mov ah, 09h 
    int 21h
    mov dx, offset choices_msg  
    int 21h
    mov dx, offset hit_msg 
    int 21h 
    mov dx, offset stand_msg 
    int 21h
    mov dx, offset surrender_msg 
    int 21h 
    cmp al, '1'
    je hit  
    cmp al, '2'
    je stand 
    cmp al, '3'
    je surrender

hit:
    mov ah, 09h 
    mov dx, offset newline 
    int 21h
    mov dx, offset hit_play
    int 21h 
    mov ax, offset card_values

hit_deal:
    mov [di], ax
    add ax, 18
    inc si
    cmp si, 22
    jl hit_deal
    int 21h
    mov dx, [di]
    int 21h
    mov dx, offset newline
    jmp continue_game

stand: 
    mov ah, 09h
    mov dx, offset newline
    int 21h
    mov dx, offset stand_play
    int 21h
    jmp continue_game

surrender:
    mov ah, 09h
    mov dx, offset newline
    int 21h
    mov dx, offset surrender_play
    int 21h
    jmp continue_game


done_bet_input:
    mov byte ptr [si - 1], '$' ;decrement

    mov di, si                 ;now point to starting bet amount

display_computer_bet:
    ;print computer bet message
    lea dx, card_values
    mov ah, 09h
    int 21h

display_cards:
    mov ax, offset card_values
    mov si, 0

deal_card:
    mov cx, 52

deal_card_loop:
    mov [di], ax
    add ax, 18
    inc di
    loop deal_card_loop

    ;print the dealt card
    mov ah, 09h
    mov dx, [di - 18]
    int 21h
    mov dx, offset newline
    int 21h

    ret


WIN_VALUE equ 1
LOSS_VALUE equ -1

;handle win/loss messages
update_wins_and_print_msg proc
    

    ;update player wins
    add word ptr player_wins, ax 

    add dx, offset newline
    mov ah, 09h
    int 21h
    ret

update_wins_and_print_msg endp

player_wins_game:
    mov ax, WIN_VALUE
    mov dx, offset blackjack_win
    call update_wins_and_print_msg
    jmp continue_game

player_busts:
    mov ax, LOSS_VALUE
    mov dx, offset bust
    call update_wins_and_print_msg
    jmp continue_game

dealer_busts:
    mov ax, WIN_VALUE
    mov dx, offset dealer_bust
    call update_wins_and_print_msg
    jmp continue_game

player_turn_wins:
    mov ax, WIN_VALUE
    mov dx, offset player_win
    call update_wins_and_print_msg
    jmp continue_game

dealer_wins:
    mov ax, LOSS_VALUE
    mov dx, offset dealer_win
    call update_wins_and_print_msg
    jmp continue_game

turn endp

;Continue Game Logic
continue_game proc 
    
continue_loop: ;takes care of continue game logic
    lea bx, turn
    mov ah, 09h
    mov dx, offset newline
    int 21h
    mov dx, offset continue_play
    int 21h
    cmp al, 'y'
    je continue_yes
    cmp al, 'n'
    je continue_no
     

continue_yes:
    jmp continue_loop

continue_no:
    jmp exit


turnjump:
        jmp far ptr user_bet

    user_end_game:
        ;print new line and end game message
        lea dx, end_play
        mov ah, 09h
        int 21h

        
continue_game endp

;Computer Bet Logic
computer_bet proc

    mov al, [diff]
    cmp al, 'h'
    ja invalid_diff
    

    invalid_diff:
        jmp easy_bet         ;default to easy

    easy_bet:
        ;calculate 20% under-bet using shift and add
        mov ax, word ptr [init_amount]
        mov bx, ax
        shr bx, 2
        sub ax, bx
        mov [comp_bet], ax
        ret

    medium_bet:
        ;copy player bet
         mov ax, word ptr [init_amount]
        mov [comp_bet], ax
        ret

    hard_bet:
        ;calculate 30% over-bet using shift and add
        mov ax, word ptr [init_amount]
        mov bx, ax          ;copy player bet
        shr bx, 1
        shr bx, 1
        add ax, bx
        mov [comp_bet], ax
        ret

    diff_table dw easy_bet, medium_bet, hard_bet

computer_bet endp

end start