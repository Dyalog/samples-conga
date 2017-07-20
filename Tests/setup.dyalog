 r←setup dummy
⍝ Setup testing of CONGA v3 Samples
⍝ If you set #.CONGALIB, you can point to non-default Conga DLLs

 :If 0=⎕NC'#.Conga'
     :Trap 0
         ⎕SE.SALT.Load'[dyalog]/Library/Core/Tool -target=#'
         {}#.Tool.Prepare'conga'
     :Else
         r←'Unable to Tool.Prepare ''conga'': ',,⍕⎕DM
     :EndTrap
 :EndIf
 Conga←#.Conga

 :Trap 0
     iConga←('CONGALIB'{0=#.⎕NC ⍺:⍵ ⋄ ⍎'#.',⍺}'')Conga.Init''
 :Else
     →0⊣r←'Conga.Init failed: ',⊃⎕DMX.DM
 :EndTrap

 r←verify_empty iConga

 :If 0=⎕NC'#.HttpCommand'
     #.⎕SE.SALT.Load'HttpCommand -target=#'
 :EndIf

 :If 0=⎕NC'#.HttpServers'
     '#.HttpServers'⎕NS''
     ⎕SE.SALT.Load'[Dyalog]/Samples/Conga/HttpServers/*.dyalog -target=#.HttpServers'
 :EndIf
