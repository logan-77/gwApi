#include-once
;~ Description: Resign.
Func Resign()
 Chat_SendChat('resign', '/')
EndFunc   ;==>Resign

;~ Description: Stuck.
Func Stuck()
 Return Chat_SendChat('stuck', '/')
EndFunc   ;==>Stuck

;~ Description: Kneel.
Func Kneel()
 Return Chat_SendChat('kneel', '/')
EndFunc ;==>Kneel

#Region Emotes
;~ Description: Randomly emotes 6 different emotes (dance, clap, excited, drum, flute and violin)
Func Emoting()
   Switch (Random(1, 6, 1))
   Case 1
   Dance()
   Case 2
   Clap()
   Case 3
   Excited()
   Case 4
   Drum()
   Case 5
   Flute()
   Case 6
   Violin()
 EndSwitch
EndFunc   ;==>Emoting

;~ Description: Dance emote.
Func Dance()
   Chat_SendChat('dance', '/')
EndFunc   ;==>Dance

;~ Description: Clap emote.
Func Clap()
   Chat_SendChat('clap', '/')
EndFunc   ;==>Clap

;~ Description: Excited emote.
Func Excited()
   Chat_SendChat('excited', '/')
EndFunc   ;==>Excited

;~ Description: Drum emote.
Func Drum()
   Chat_SendChat('drum', '/')
EndFunc   ;==>Drum

;~ Description: Flute emote.
Func Flute()
   Chat_SendChat('flute', '/')
EndFunc   ;==>Flute

;~ Description: Violin emote.
Func Violin()
   Chat_SendChat('violin', '/')
EndFunc   ;==>Violin

;~ Description: Jump emote.
Func Jump()
   Chat_SendChat('jump', '/')
EndFunc   ;==>Jump
#EndRegion Emotes

