:Namespace TODServer

    ∇ RunText port;wait;data;event;obj;rc;r
     ⍝ Time of Day Server Example (use port 13) in Text mode
     
      ##.DRC←##.Conga.Init''  ⍝ initialize Conga/create LIB instance
      DONE←0 ⍝ Set global DONE to 1 to stop service
     
      :If 0≠1⊃r←##.DRC.Srv'TODtxt' ''port'Text' ⍝ start the server in Text mode
          ⎕←'Unable to start TOD server: ',⍕r
      :Else
          ⎕←'Text Mode TOD Server started on port ',⍕port
          :While ~DONE
              rc obj event data←4↑wait←##.DRC.Wait'TODtxt' 1000 ⍝ Time out now and again
              :Select rc
              :Case 0
                  :Select event
                  :Case 'Connect'
                      r←(,'ZI2,<:>,ZI2,<:>,ZI2,< >,ZI2,<->,ZI2,<->,ZI4'⎕FMT 1 6⍴⎕TS[4 5 6 3 2 1]),⎕AV[4 3]
                      {}##.DRC.Send obj r 1 ⍝ 1=Close connection
                  :Else
                      {}##.DRC.Close obj ⍝ Anything unexpected
                  :EndSelect
              :Case 100  ⍝ Time out - Housekeeping Here
              :Else
                  ⎕←'Error in Wait: ',⍕wait ⋄ DONE←1
              :EndSelect
          :EndWhile
          {}##.DRC.Close'TOD'
          ⎕←'TOD Server terminated.'
      :EndIf
    ∇

    ∇ RunCommand port;wait;data;event;obj;rc;r
     ⍝ Time of Day Server Example (use port 13) using Command mode
     
      ##.DRC←##.Conga.Init''  ⍝ initialize Conga/create LIB instance
      DONE←0 ⍝ Set global DONE to 1 to stop service
     
      :If 0≠1⊃r←##.DRC.Srv'TODcmd' ''port ⍝ start the server in Command mode (the default mode)
          ⎕←'Unable to start TOD server: ',⍕r
      :Else
          ⎕←'Command Mode TOD Server started on port ',⍕port
          :While ~DONE
              rc obj event data←4↑wait←##.DRC.Wait'TODcmd' 1000 ⍝ Time out now and again
              :Select rc
              :Case 0
                  :Select event
                  :Case 'Connect' ⍝ ignore
                  :Case 'Receive'
                      {}##.DRC.Respond obj ⎕TS 
                  :Else
                      {}##.DRC.Close obj ⍝ Anything unexpected
                  :EndSelect
              :Case 100  ⍝ Time out - Housekeeping Here
              :Else
                  ⎕←'Error in Wait: ',⍕wait ⋄ DONE←1
              :EndSelect
          :EndWhile
          {}##.DRC.Close'TOD'
          ⎕←'TOD Server terminated.'
      :EndIf
    ∇

:EndNamespace
