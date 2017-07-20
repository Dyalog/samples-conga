 r←test_dochttprequest dummy;srv;z;ret;find;table;data
⍝∇Test: group=Classy
⍝ Test Class-based servers

 r←''

 :If 9≠⎕NC'#.HttpServers.DocHttpRequest'
     r←'DocHttpRequest was not loaded' ⋄ →0
 :EndIf

 :Trap 0
     srv←Conga.Srv 8088 #.HttpServers.DocHttpRequest
     srv.timeout←1000         ⍝ 1 second timeout
     srv.Start
     ⎕DL 1.5×srv.timeout÷1000 ⍝ Make sure it times out
 :Else
     →fail because'Unable to start server: ',⊃⎕DMX.DM
 :EndTrap

 ret←#.HttpCommand.Get'http://localhost:8088/index.html'

 :If 0≠⊃ret.rc
     →fail⊣r←'HTTPGet failed: ',,⍕ret.rc ⋄ :EndIf

 :If ~∨/'Requesting: /index.html'⍷ret.Data
     →fail⊣r←'Unexpected return from DocHttpRequesr.' ⋄ :EndIf

fail:

 :If 9=⎕NC'srv'
     srv.Stop
 :EndIf
