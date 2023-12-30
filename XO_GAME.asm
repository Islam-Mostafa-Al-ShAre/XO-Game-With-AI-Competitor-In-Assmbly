.model large 
.data 
   n_line DB 0AH,0DH,"$"
   MainMes db '         hi this X,O game, alot of memories right ^^ ,by the way you can choose the game difficulty by enter 1 or 2 , have fun ^^ . ' , '$'
   PlayerStartMes db "1- Player Start First ","$"
   AiStartMes  db "2- Ai Start First ", ' $'
   Space db '  ','$'
   XOMatrix db '123456789','$' 
   IntialXOMatrix db '123456789','$' 
   PlayerSymbol db 'X' 
   Symbol db 'O' 
   AiSymbol db 'O' 
   MesToPlayer db 'Choose The Number You Want To Play in' , '$'
   IligalMesToPlayer db 'make sure you enter empty position, Choose The Number You Want To Play in again.' , '$'
   PlayerWinMes db 'Ai: mmmmmm You Win I believe Next Time I will Distroy You' , '$'
   AiWinMes db 'Ai: You Have Just lost I Think You Are Not Intelligent Enough' , '$'
   DrawnMes db 'Ai: it seems we have the same Intelligent i feel offended' ,'$'
   AiWillStartFirstMes db 'Ai: I Will Start First , Why..... My Game My Rules','$'
   AiLetPlayerlStartMes db 'Ai: you Will Start Why ...... Shut up','$'
   LastPlayed db ?
   AiWasPlayed db 0b
   GameIsNotDraw db 0b
   .stack 256
.code

    Main Proc Far
      .startup
      
      Call MainManuView
      Cmp Al ,'1'
      je PlayerStartRestartTheGame
  AiStartRestartTheGame:
      Call IntialGame
      Call AiStartsFirst
      Call NewLine
      Call NewLine
      Call GetInput
      Jmp AiStartRestartTheGame
  PlayerStartRestartTheGame:
      Call IntialGame
      Call PlayerStartsFirst
      Call NewLine
      Call NewLine
      Call GetInput
      Jmp PlayerStartRestartTheGame      
      .exit
    Main endp  
    
    MainManuView PROC NEAR 
       Call NewLine
       Call NewLine
       MOV DX, OFFSET MainMes
       Call PrintString
       Call NewLine
       Call NewLine
       Call NewLine
       Call NewLine
       MOV DX, OFFSET PlayerStartMes
       Call PrintString
       Call NewLine
       Call NewLine
       MOV DX, OFFSET AiStartMes
       Call PrintString
       Call NewLine
       Call NewLine
       Call GetInput
       Call NewLine
       Call NewLine
       ret
    MainManuView endp
     
    ; to print the string exist in DX register
    PrintString PROC NEAR
       MOV AH , 09h
       INt 21h
       ret
    PrintString endp
    PrintSpace PROC NEAR
       Lea Dx ,Space
       MOV AH , 09h
       INt 21h
       ret
     PrintSpace endp

     PrintChar PROC NEAR
       MOV AH , 02h
       INt 21h
       ret
     PrintChar endp
     
    ;to make a new line 
    NewLine PROC NEAR
    
       LEA DX,n_line  
       MOV AH,09h 
       int 21h
       ret
    NewLine endp  
    
    ;get char fromm the player     
    GetInput PROC NEAR
       MOV AH, 01h
       int 21h
       ret
    GetInput endp
    
    ;print XO matrix
    DrawXOMatrix PROC NEAR
         mov CX ,9 
         LEA SI , XOMatrix
         MOV Bh , 3
     Again1:  
         MOV AX , CX
         div BH 
         CMP AH ,0
         jnz Col
         
     NewRow:
         Call NewLine
         Call NewLine
     Col: 
         MOV DL , [SI]
         INC SI
         Call PrintChar
         Call PrintSpace
         LOOP Again1
         Call NewLine
         Call NewLine
         ret
    DrawXOMatrix endp
    ; 
    AiStartsFirst PROC NEAR 
          Lea Dx ,AiWillStartFirstMes
          Call PrintString
          Call NewLine
          Call NewLine
          MOV BL,9
          Call DrawXOMatrix

          Again2: 
          ;Ai Is Playing
          Call Delay
          Call Ai
          Dec Bl
          Call DrawXOMatrix
          Call CheckGameState
          Cmp Bl ,0
          je ReturnAiStartsFirst
          LEA DX , MesToPlayer
          CALL PrintString
          Call NewLine
          ;Player is playing
          Call Player
          Call NewLine          
          Call DrawXOMatrix
          call CheckGameState
          Cmp Bl ,0
          Jg Again2
          
      ReturnAiStartsFirst:
          Cmp GameIsNotDraw ,1b
          je x
          ;in the case of drawning
          Mov DX ,Offset DrawnMes
          Call PrintString
          
      x:
          Ret
          
    AiStartsFirst endp
    
      PlayerStartsFirst PROC NEAR 
          Lea Dx ,AiLetPlayerlStartMes
          Call PrintString
          Call NewLine
          Call NewLine
          MOV BL,9
          Call DrawXOMatrix

      Again3: 
        
          LEA DX , MesToPlayer
          CALL PrintString
          Call NewLine
          ;Player is playing
          Call Player
          Call NewLine          
          Call DrawXOMatrix          
          call CheckGameState          
          Cmp Bl ,0
          je ReturnPlayerStartsFirst
          ;Ai Is Playing
          Call Delay
          Call Ai
          Dec Bl
          Call DrawXOMatrix
          Call CheckGameState
          Cmp Bl ,0
          Jg Again3
          
      ReturnPlayerStartsFirst:
          Cmp GameIsNotDraw ,1b
          je z
          ;in the case of drawning
          Mov DX ,Offset DrawnMes
          Call PrintString
          
      z:
          Ret
          
    PlayerStartsFirst endp
    
    Player Proc Near
    
      GetInputFromPlayer:
         ;for gets the player place wants to play in 
          Call GetInput
          ;here to check if the position which the player wants to play in is empty     
          Mov ah , 0000h
          Sub al, 30h
          Mov BP , ax
          Cmp XOMatrix[BP-1] ,39h
          jg IligalMes

      ; if the player plays in empty position    
      Ligal:
          Mov ah , PlayerSymbol
          Mov XOMatrix[BP-1] , ah
          ;if 0 than lastplayed is Player
          mov LastPlayed ,0b 
          ;dec the loop by One
          Dec Bl
          
          ret
          
      ; mes to the player if he enter nonempty position   
      IligalMes:
          Call NewLine
          Call NewLine
          Call DrawXOMatrix
          Call NewLine
          Lea Dx , IligalMesToPlayer
          Call PrintString
          Call NewLine
          Call NewLine
          Jmp GetInputFromPlayer
    Player Endp

    Ai Proc Near
      
    ;first ai find position if he plays in this position, than he will win  
      Mov Symbol , 'O'
      Call AiFindPositionToWinOrPreventPlayerWinning
      Cmp AiWasPlayed , 1b
      je ReturnFromAi
      ;if ai did not find that position,than ai  will try  finds a dangerous postion if the player play in, player will win 
      Mov Symbol , 'X'
      Call AiFindPositionToWinOrPreventPlayerWinning
      Cmp AiWasPlayed , 1b
      je ReturnFromAi 
      

      Call  AiTryToFindAPositionToMakeAChanceForHim
      
      
      ReturnFromAi:
      ; if 1 than lastplayed is Ai
      mov LastPlayed ,1b 
      ;Change AiWasPlayed to let Ai plays next round
      Mov AiWasPlayed , 0b
      ret

    Ai endp
    
    AiFindPositionToWinOrPreventPlayerWinning Proc Near
   AiCheckRow1State1:
    ;Check if position 0 and postion 1 are equal
         Mov Al , XOMatrix[0]
         And Al , XOMatrix[1]
         Cmp Al , Symbol
         Jne AiCheckRow1State2
         ;Check if position 2 is empty
         Cmp XOMatrix[2] , 39h
         jg AiCheckRow2State1
         ;if empty Ai plays in postion 2
         Mov Dl , AiSymbol
         Mov XOMatrix[2] ,Dl
         Mov AiWasPlayed , 1b
         ret
         
     AiCheckRow1State2:
         
         ;Check if position 1 and postion 2 are equal
         Mov Al , XOMatrix[1]
         And Al , XOMatrix[2]
         Cmp Al , Symbol
         Jne AiCheckRow1State3
         ;Check if postion 0 is empty
         Cmp XOMatrix[0] , 39h
         jg AiCheckRow2State1
         ;if empty Ai plays in postion 0
         Mov Dl , AiSymbol
         Mov XOMatrix[0] ,Dl
         Mov AiWasPlayed , 1b
         ret
         
     AiCheckRow1State3:
         
         ;Check if postion 0 and postion 2 are equal
         Mov Al , XOMatrix[0]
         And Al , XOMatrix[2]
         Cmp Al , Symbol
         Jne AiCheckRow2State1
         ;Check if postion 1 is empty
         Cmp XOMatrix[1] , 39h
         jg AiCheckRow2State1
         ;if empty Ai plays in postion 1
         Mov Dl , AiSymbol
         Mov XOMatrix[1] ,Dl
         Mov AiWasPlayed , 1b
         ret
     AiCheckRow2State1:
         ;Check if postion 3 and postion 4 are equal
         Mov Al , XOMatrix[3]
         And Al , XOMatrix[4]
         Cmp Al , Symbol
         Jne AiCheckRow2State2
         ;Check if postion 5 is empty
         Cmp XOMatrix[5] , 39h
         jg AiCheckRow3State1
         ;if empty Ai plays in postion 5
         Mov Dl , AiSymbol
         Mov XOMatrix[5] ,Dl
         Mov AiWasPlayed , 1b
         ret
         
     AiCheckRow2State2:
         
         ;Check if postion 4 and postion 5 are equal
         Mov Al , XOMatrix[4] 
         And Al , XOMatrix[5]
         Cmp Al , Symbol
         Jne AiCheckRow2State3
         ;Check if postion 3 is empty
         Cmp XOMatrix[3] , 39h
         jg AiCheckRow3State1
         ;if empty Ai plays in postion 3
         Mov Dl , AiSymbol
         Mov XOMatrix[3] ,Dl
         Mov AiWasPlayed , 1b
         ret
         
     AiCheckRow2State3:
         
         ;Check if postion 3 and postion 5 are equal
         Mov Al , XOMatrix[3]
         And Al , XOMatrix[5]
         Cmp Al , Symbol
         Jne AiCheckRow3State1
         ;Check if postion 4 is empty
         Cmp XOMatrix[4] , 39h
         jg AiCheckRow3State1
         ;if empty Ai plays in postion 4
         Mov Dl , AiSymbol
         Mov XOMatrix[4] ,Dl
         Mov AiWasPlayed , 1b
         ret
  
     AiCheckRow3State1:
         ;Check if postion 6 and postion 7 are equal
         Mov Al , XOMatrix[6]
         And Al , XOMatrix[7]
         Cmp Al , Symbol
         Jne AiCheckRow3State2
         ;Check if postion 8 is empty
         Cmp XOMatrix[8] , 39h
         jg AiCheckDio1State1
         ;if empty Ai plays in postion 8
         Mov Dl , AiSymbol
         Mov XOMatrix[8] ,Dl
         Mov AiWasPlayed , 1b
         ret
         
     AiCheckRow3State2:
         
         ;Check if postion 7 and postion 8 are equal
         Mov Al , XOMatrix[7]
         And Al , XOMatrix[8]
         Cmp Al , Symbol
         Jne AiCheckRow3State3
         ;Check if postion 6 is empty
         Cmp XOMatrix[6] , 39h
         jg AiCheckDio1State1
         ;if empty Ai plays in postion 6
         Mov Dl , AiSymbol
         Mov XOMatrix[6] ,Dl
         Mov AiWasPlayed , 1b
         ret
         
     AiCheckRow3State3:
         
         ;Check if postion 6 and postion 8 are equal
         Mov Al , XOMatrix[6]
         And Al , XOMatrix[8]
         Cmp Al , Symbol
         Jne AiCheckDio1State1
         ;Check if postion 7 is empty
         Cmp XOMatrix[7] , 39h
         jg AiCheckDio1State1
         ;if empty Ai plays in postion 7
         Mov Dl , AiSymbol
         Mov XOMatrix[7] ,Dl
         Mov AiWasPlayed , 1b
         ret
         
     AiCheckDio1State1:
         ;Check if postion 0 and position 4 are equal
         Mov Al , XOMatrix[0]
         And Al , XOMatrix[4]
         Cmp Al , Symbol
         Jne AiCheckDio1State2
         ;Check if postion 8 is empty
         Cmp XOMatrix[8] , 39h
         jg AiCheckDio2State1
         ;if empty, Ai plays in position 8
         Mov Dl , AiSymbol
         Mov XOMatrix[8] ,Dl
         Mov AiWasPlayed , 1b
         ret
         
     AiCheckDio1State2:
         
         ;Check if postion 4 and position 8 are equal
         Mov Al , XOMatrix[4]
         And Al , XOMatrix[8]
         Cmp Al , Symbol
         Jne  AiCheckDio1State3
         ;Check if postion 0 is empty
         Cmp XOMatrix[0] , 39h
         jg AiCheckDio2State1
         ;if empty, Ai plays in position 0
         Mov Dl , AiSymbol
         Mov XOMatrix[0] ,Dl
         Mov AiWasPlayed , 1b
         ret
         
     AiCheckDio1State3:
         
         ;Check if postion 0 and position 8 are equal
         Mov Al , XOMatrix[0]
         And Al , XOMatrix[8]
         Cmp Al , Symbol
         Jne AiCheckDio2State1
         ;Check if postion 4 is empty
         Cmp XOMatrix[4] , 39h
         jg AiCheckDio2State1
         ;if empty, Ai plays in position 4
         Mov Dl , AiSymbol
         Mov XOMatrix[4] ,Dl
         Mov AiWasPlayed , 1b
         ret  
  
     AiCheckDio2State1:
         ;Check if postion 2 and position 4 are equal
         Mov Al , XOMatrix[2]
         And Al , XOMatrix[4]
         Cmp Al , Symbol
         Jne AiCheckDio2State2
         ;Check if postion 6 is empty
         Cmp XOMatrix[6] , 39h
         jg AiCheckCol1State1
         ;if empty, Ai plays in position 6
         Mov Dl , AiSymbol
         Mov XOMatrix[6] ,Dl
         Mov AiWasPlayed , 1b
         ret
         
     AiCheckDio2State2:
         
         ;Check if postion 4 and position 6 are equal
         Mov Al , XOMatrix[4]
         And Al , XOMatrix[6]
         Cmp Al , Symbol
         Jne  AiCheckDio2State3
         ;Check if postion 2 is empty
         Cmp XOMatrix[2] , 39h
         jg AiCheckCol1State1
         ;if empty, Ai plays in position 2
         Mov Dl , AiSymbol
         Mov XOMatrix[2] ,Dl
         Mov AiWasPlayed , 1b
         ret
         
     AiCheckDio2State3:
         
         ;Check if postion 2 and position 6 are equal
         Mov Al , XOMatrix[2]
         And Al , XOMatrix[6]
         Cmp Al , Symbol
         Jne AiCheckCol1State1
         ;Check if postion 4 is empty
         Cmp XOMatrix[4] , 39h
         jg AiCheckCol1State1
         ;if empty, Ai plays in position 4
         Mov Dl , AiSymbol
         Mov XOMatrix[4] ,Dl
         Mov AiWasPlayed , 1b
         ret             
    
     AiCheckCol1State1:
         ;Check if postion 0 and postion 3 are equal
         Mov Al , XOMatrix[0]
         And Al , XOMatrix[3]
         Cmp Al , Symbol
         Jne AiCheckCol1State2
         ;Check if postion 6 is empty
         Cmp XOMatrix[6] , 39h
         jg AiCheckCol2State1
         ;if empty Ai plays in postion 6
         Mov Dl , AiSymbol
         Mov XOMatrix[6] ,Dl
         Mov AiWasPlayed , 1b
         ret
         
     AiCheckCol1State2:
         
         ;Check if postion 3 and postion 6 are equal
         Mov Al , XOMatrix[3]
         And Al , XOMatrix[6]
         Cmp Al , Symbol
         Jne AiCheckCol1State3
         ;Check if postion 0 is empty
         Cmp XOMatrix[0] , 39h
         jg AiCheckCol2State1
         ;if empty Ai plays in postion 0
         Mov Dl , AiSymbol
         Mov XOMatrix[0] ,Dl
         Mov AiWasPlayed , 1b
         ret
         
     AiCheckCol1State3:
         
         ;Check if postion 0 and postion 6 are equal
         Mov Al , XOMatrix[0]
         And Al , XOMatrix[6]
         Cmp Al , Symbol
         Jne AiCheckCol2State1
         ;Check if postion 3 is empty
         Cmp XOMatrix[3] , 39h
         jg AiCheckCol2State1
         ;if empty Ai plays in postion 3
         Mov Dl , AiSymbol
         Mov XOMatrix[3] ,Dl
         Mov AiWasPlayed , 1b
         ret 
         
     AiCheckCol2State1:
         ;Check if postion 1 and postion 4 are equal
         Mov Al , XOMatrix[1]
         And Al , XOMatrix[4]
         Cmp Al , Symbol
         Jne AiCheckCol2State2
         ;Check if postion 7 is empty
         Cmp XOMatrix[7] , 39h
         jg AiCheckCol3State1
         ;if empty Ai plays in postion 7
         Mov Dl , AiSymbol
         Mov XOMatrix[7] ,Dl
         Mov AiWasPlayed , 1b
         ret
         
     AiCheckCol2State2:
         
         ;Check if postion 4 and postion 7 are equal
         Mov Al , XOMatrix[4] 
         And Al , XOMatrix[7]
         Cmp Al , Symbol
         Jne AiCheckCol2State3
         ;Check if postion 1 is empty
         Cmp XOMatrix[1] , 39h
         jg AiCheckCol3State1
         ;if empty Ai plays in postion 1
         Mov Dl , AiSymbol
         Mov XOMatrix[1] ,Dl
         Mov AiWasPlayed , 1b
         ret
         
     AiCheckCol2State3:
         
         ;Check if postion 1 and postion 7 are equal
         Mov Al , XOMatrix[1]
         And Al , XOMatrix[7]
         Cmp Al , Symbol
         Jne AiCheckCol3State1
         ;Check if postion 4 is empty
         Cmp XOMatrix[4] , 39h
         jg AiCheckCol3State1
         ;if empty Ai plays in postion 4
         Mov Dl , AiSymbol
         Mov XOMatrix[4] ,Dl
         Mov AiWasPlayed , 1b
         ret
  
     AiCheckCol3State1:
         ;Check if postion 2 and postion 5 are equal
         Mov Al , XOMatrix[2]
         And Al , XOMatrix[5]
         Cmp Al , Symbol
         Jne AiCheckCol3State2
         ;Check if postion 8 is empty
         Cmp XOMatrix[8] , 39h
         jg ReturnFromAiFindPositionToPlayIn
         ;if empty Ai plays in postion 8
         Mov Dl , AiSymbol
         Mov XOMatrix[8] ,Dl
         Mov AiWasPlayed , 1b
         ret
         
     AiCheckCol3State2:
         
         ;Check if postion 5 and postion 8 are equal
         Mov Al , XOMatrix[5]
         And Al , XOMatrix[8]
         Cmp Al , Symbol
         Jne AiCheckCol3State3
         ;Check if postion 2 is empty
         Cmp XOMatrix[2] , 39h
         jg ReturnFromAiFindPositionToPlayIn
         ;if empty Ai plays in postion 2
         Mov Dl , AiSymbol
         Mov XOMatrix[2] ,Dl
         Mov AiWasPlayed , 1b
         ret
         
     AiCheckCol3State3:
         
         ;Check if postion 5 and postion 5 are equal
         Mov Al , XOMatrix[2]
         And Al , XOMatrix[8]
         Cmp Al , Symbol
         Jne ReturnFromAiFindPositionToPlayIn
         ;Check if postion 5 is empty
         Cmp XOMatrix[5] , 39h
         jg ReturnFromAiFindPositionToPlayIn
         ;if empty Ai plays in postion 5
         Mov Dl , AiSymbol
         Mov XOMatrix[5] ,Dl
         Mov AiWasPlayed , 1b
         ret
             
         ReturnFromAiFindPositionToPlayIn:
         ret
         
         AiFindPositionToWinOrPreventPlayerWinning endp
         
         AiTryToFindAPositionToMakeAChanceForHim Proc Near
         
         Cmp XOMatrix[4] ,39h
         jg NotCenter
         Mov Dl , AiSymbol
         Mov XOMatrix[4] ,Dl
         Ret  
     NotCenter:
         
         Mov Dl ,PlayerSymbol
         Mov Dh ,AiSymbol  
         
     Dia1:  
         Cmp XOMatrix[0] , Dl
         je Dia2
         Cmp XOMatrix[4] , Dl
         je Dia2
         Cmp XOMatrix[8] , Dl
         je Dia2
         Mov  XOMatrix[8] , Dh
         Ret
     Dia2:  
         Cmp XOMatrix[2] , Dl
         je Row3
         Cmp XOMatrix[4] , Dl
         je Row3
         Cmp XOMatrix[6] , Dl
         je Row3
         Mov  XOMatrix[6] , Dh
         Ret
     Row3:
         Cmp XOMatrix[6] , Dl
         je Row1
         Cmp XOMatrix[7] , Dl
         je Row1
         Cmp XOMatrix[8] , Dl
         je Row1
         
         Cmp XOMatrix[8] , Dh
         je PlayInIndex6
         Mov XOMatrix[8] , Dh
         Ret
     PlayInIndex6:
         Mov  XOMatrix[6] , Dh
         Ret
         
     Row1:   
         Cmp XOMatrix[0] , Dl
         je Row2
         Cmp XOMatrix[1] , Dl
         je Row2
         Cmp XOMatrix[2] , Dl
         je Row2
         
         Cmp XOMatrix[0] , Dh
         je PlayInIndex2
         Mov XOMatrix[0] , Dh
         Ret
     PlayInIndex2:
         Mov  XOMatrix[2] , Dh
         Ret          
 
     Row2:
         Cmp XOMatrix[3] , Dl
         je Col1
         Cmp XOMatrix[4] , Dl
         je Col1
         Cmp XOMatrix[5] , Dl
         je Col1
         
         Cmp XOMatrix[3] , Dh
         je PlayInIndex3
         Mov XOMatrix[3] , Dh
         Ret
     PlayInIndex5:
         Mov  XOMatrix[5] , Dh
         Ret    
     Col1:
         Cmp XOMatrix[0] , Dl
         je Col2
         Cmp XOMatrix[3] , Dl
         je Col2
         Cmp XOMatrix[6] , Dl
         je Col2
         
         Cmp XOMatrix[0] , Dh
         je PlayInIndex3
         Mov XOMatrix[0] , Dh
         Ret
     PlayInIndex3:
         Mov  XOMatrix[3] , Dh
         Ret   
     Col2:
         Cmp XOMatrix[1] , Dl
         je Col3
         Cmp XOMatrix[4] , Dl
         je Col3
         Cmp XOMatrix[7] , Dl
         je Col3
       
         Cmp XOMatrix[7] , Dh
         je PlayInIndex1
         Mov XOMatrix[7] , Dh
         Ret
     PlayInIndex1:
         Mov  XOMatrix[1] , Dh
         
        Ret   
    Col3:
         Cmp XOMatrix[2] , Dl
         je CheckIndex0IfEmpty
         Cmp XOMatrix[5] , Dl
         je CheckIndex0IfEmpty
         Cmp XOMatrix[8] , Dl
         je CheckIndex0IfEmpty
         
         Cmp XOMatrix[2] , Dh
         je PlayInIndex8
         Mov XOMatrix[2] , Dh
         Ret
     PlayInIndex8:
         Mov  XOMatrix[8] , Dh
         Ret
                  
     CheckIndex0IfEmpty:  
         Cmp XOMatrix[0] , 39h
         jg CheckIndex1IfEmpty
         Mov XOMatrix[0] , Dh 
         Ret
         
     CheckIndex1IfEmpty:  
         Cmp XOMatrix[1] , 39h
         jg CheckIndex2IfEmpty
         Mov XOMatrix[1] , Dh 
         Ret
         
     CheckIndex2IfEmpty:  
         Cmp XOMatrix[2] , 39h
         jg CheckIndex3IfEmpty
         Mov XOMatrix[2] , Dh 
         Ret
         
     CheckIndex3IfEmpty:  
         Cmp XOMatrix[3] , 39h
         jg CheckIndex4IfEmpty
         Mov XOMatrix[3] , Dh 
         Ret
         
     CheckIndex4IfEmpty:  
         Cmp XOMatrix[4] , 39h
         jg CheckIndex5IfEmpty
         Mov XOMatrix[4] , Dh 
         Ret
         
     CheckIndex5IfEmpty:  
         Cmp XOMatrix[5] , 39h
         jg CheckIndex6IfEmpty
         Mov XOMatrix[5] ,Dh 
         Ret
         
     CheckIndex6IfEmpty:  
         Cmp XOMatrix[6] , 39h
         jg CheckIndex7IfEmpty
         Mov XOMatrix[6] , Dh 
         Ret
         
     CheckIndex7IfEmpty:  
         Cmp XOMatrix[7] , 39h
         jg CheckIndex8IfEmpty
         Mov XOMatrix[7] , Dh 
         Ret
         
     CheckIndex8IfEmpty:  
      
         Mov XOMatrix[8] , Dh 

        ret
         AiTryToFindAPositionToMakeAChanceForHim Endp
         
    CheckGameState Proc Near
    
     CheckRow1:
         Mov Al , XOMatrix[0]
         And Al , XOMatrix[1]
         Cmp Al , XOMatrix[2]
         Je WinState
         
     CheckRow2:
          Mov Al , XOMatrix[3]
          And Al , XOMatrix[4]
          Cmp Al , XOMatrix[5]
          je WinState
          
      CheckRow3:
          Mov Al , XOMatrix[6]
          And Al , XOMatrix[7]
          Cmp Al , XOMatrix[8]
          je WinState
          
      CheckCol1:
          Mov Al , XOMatrix[0]
          And Al , XOMatrix[3]
          Cmp Al , XOMatrix[6]
          je WinState
          
      CheckCol2:
          Mov Al , XOMatrix[1]
          And Al , XOMatrix[4]
          Cmp Al , XOMatrix[7]
          je WinState
      CheckCol3:
          Mov Al , XOMatrix[2]
          And Al , XOMatrix[5]
          Cmp Al , XOMatrix[8]
          je WinState
      CheckDia:
          Mov Al , XOMatrix[0]
          And Al , XOMatrix[4]
          Cmp Al , XOMatrix[8]
          je WinState
      CheckDia2:
          Mov Al , XOMatrix[2]
          And Al , XOMatrix[4]
          Cmp Al , XOMatrix[6]
          je WinState
          ret
          
           ; win state    
       WinState:
          Mov GameIsNotDraw , 1b
          Cmp LastPlayed , 0b
          Jne AiWin
          
          ;if player win
          Call NewLine
          Call NewLine
          Mov dx , offset PlayerWinMes
          call PrintString
          ; we set bl register 0 to end MonkeyLevelFunc's loop
          Mov bl , 0
          ret
          
      AiWin:
          Call NewLine
          Call NewLine
          Mov dx , offset AiWinMes
          call PrintString
          ; we set bl register 0 to end MonkeyLevelFunc's loop
          Mov bl , 0          
          Ret
      CheckGameState EndP
      
      Delay Proc Near
          MOV CX, 0FH
          MOV DX, 4240H
          MOV AH, 86H
          INT 15H   
          ret
      Delay endp
      
      IntialGame Proc Near
          Mov GameIsNotDraw ,0b
          Mov BX , 9d
  IntialGameLoop:
          Dec BX
          Mov Dl ,IntialXOMatrix[Bx] 
          Mov XOMatrix[BX], dl
          Cmp Bx ,0
          jne   IntialGameLoop
       
          ret
      IntialGame Endp
 
end Main
    