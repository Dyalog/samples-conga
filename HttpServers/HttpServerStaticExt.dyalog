:Class HttpServerStaticExt : HttpServerBaseExt       
⍝∇:require =HttpServerBaseExt

⍝ An example of an Http Server capable of servicing requests for files in a folder

     FOLDER←'c:\tmp' ⍝ /// Should be a constructor argument

        NL←⎕UCS 13 10   
        dtb←{                                           ⍝ Drop Trailing Blanks.
     ⍺←' ' ⋄ 1<|≡⍵:(⊂⍺)∇¨⍵                       ⍝ nested?
     2<⍴⍴⍵:(¯1↓⍴⍵){(⍺,1↓⍴⍵)⍴⍵}⍺ ∇,[¯1↓⍳⍴⍴⍵]⍵     ⍝ array
     1≥⍴⍴⍵:(-+/∧\⌽⍵∊⍺)↓⍵                         ⍝ vector
     (~⌽∧\⌽∧⌿⍵∊⍺)/⍵                              ⍝ matrix
 }

        ∇ct←ContentType page;ext;list
          list ← 3 2 ⍴'pdf' 'application/pdf' 'txt' 'text/html' 'log' 'text/html'
         
          ext← dtb  {(1-(⌽⍵)⍳'.')↑⍵ }page 
          
        ct←⊃(list[;2],⊂'text/html')[    list[;1]⍳⊂ext]
        ∇

        ∇ MakeN arg
          :Access Public
          :Implements Constructor :Base arg
        ∇
    
        ∇ onHtmlReq;html;headers;hd;e;enc;con
          :Access public override 
          headers← 0 2 ⍴⍬
          headers⍪←'Server' 'ClassyDyalog'
          headers⍪←'Content-Type' (ContentType Page)
          enc← GetValue 'Accept-Encoding' ''
          con← 'deflate' 'gzip' { ((⊂''), ⍺)[1+⍸⍺∊⍵] }    ','{1↓¨(⍺=⍺,⍵)⊂⍺,⍵} enc   
          :if 0<≢con
            headers⍪←'Content-Encoding' con
          :endif
          e←SendFile1 0 headers (FOLDER,Page)
          :if 1039=⊃e
               SendAnswer1 ('404' 'Not Found') headers ''
          :endif
        ∇


    :endclass   
   
