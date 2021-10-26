:Class HttpServerBaseExt : #.Conga.Connection
   ⍝ Base class for Http Server examples - "just override in onHtmlReq"

    :field Public Version
    :field Public Headers
    :field Public Input
    :field Public Command
    :field Public Page
    :field Public Arguments
    :field Public Body

    NL←(⎕ucs 13 10)

    ∇ sa←ServerArgs
      :Access public shared
      sa←('mode' 'Http')('BufferSize' 1000000)
    ∇       
    
    
    ∇ sp←srv ServerProperties name
      :Access Public Shared
      sp←,⊂('DecodeBuffers' 15) ⍝ Let Conga Decode as much as possible
    ∇



    ∇ MakeN arg
      :Access Public
      :Implements Constructor :Base arg
      Version←'HTTP/1.0'
      Body←⍬
    ∇

    ∇ onHTTPHeader(obj data)
      :Access public
      :if 1=≡data
        DecodeCmd data
      :else
        (Command Page Version Headers)←4↑data  
        Headers[;1]←lc¨Headers[;1]
      :endif
      datalen←⊃(GetValue'Content-Length' 'Numeric'),¯1 ⍝ ¯1 if no content length not specified
      chunked←∨/'chunked'⍷GetValue'Transfer-Encoding' ''
      done←(~chunked)∧datalen<1
      :If done
          onHtmlReq
      :EndIf
    ∇

    ∇ onHTTPBody(obj data)
      :Access public
      Body←data
      onHtmlReq
    ∇

    ∇ onHTTPChunk(obj data)
      :Access public
      Body,←data
    ∇

    ∇ onHTTPTrailer(obj data)
      :Access public
      onHtmlReq
    ∇


    ∇ onReceive(obj data)
      :Access public override
      'HttpMode'⎕SIGNAL 999
    ∇
    
    ∇onSent (obj data)
    :access public 
    s3←srv.LIB.Micros
    ⎕←s2 s3 -s1
    ∇
    ∇ onHtmlReq
      :Access public overridable
      _←SendAnswer 0 ''('You are asking for ',Page)
    ∇

    eis←{⍺←1 ⋄ ,(⊂⍣(⍺=|≡⍵))⍵} ⍝ enclose if simple
    getHeader←{(⍺[;2],⊂'')⊃⍨⍺[;1]⍳eis ⍵}
    addHeader←{0∊⍴⍺⍺ getHeader ⍺:⍺⍺⍪⍺ ⍵ ⋄ ⍺⍺}
    makeHeaders←{⎕ML←1 ⋄ 0∊⍴⍵:0 2⍴⊂'' ⋄ 2=⍴⍴⍵:⍵ ⋄ ↑2 eis ⍵}
    fmtHeaders←{⎕ML←1 ⋄ 0∊⍴⍵:'' ⋄ ∊{NL,⍨(1⊃⍵),': ',⍕2⊃⍵}¨↓⍵}

    ∇ d←HttpDate
      d←2⊃srv.LIB.GetProp'.' 'HttpDate'
    ∇

    ∇ e←SendAnswer(status hdr content);Answer
      :Access public
      hdr←'Date: ',HttpDate,NL,hdr
      :If 0≡status ⋄ status←'200 OK' ⋄ :EndIf
      :If 0≠⍴hdr ⋄ hdr←(-+/∧\(⌽hdr)∊NL)↓hdr ⋄ :EndIf
      Answer←(uc Version),' ',status,NL,((0<⍴content)/'Content-Length: ',(⍕⍴content),NL),hdr,NL,NL
      Answer←Answer,content
      e←Send Answer(Version≡'http/1.0')
    ∇
    
    ∇ e←SendAnswer1(status hdrs content)
    ⍝ status 0 or 'statuscode' 'reason phrase'
    ⍝ hdrs matrix of headers
    ⍝ content char array
      :Access public
      hdrs⍪←'Date' HttpDate  

      :If 0≡status ⋄ status←'200' 'OK' ⋄ :EndIf
      e←Send ((⊂uc Version), status,  hdrs content )('http/1.0'≡ lc Version)
    ∇
    

    ∇ e←SendFile(status hdr filename);Answer
      :Access public
      hdr←'Date: ',HttpDate,NL,hdr
      :If 0≡status ⋄ status←'200 OK' ⋄ :EndIf
      :If 0≠⍴hdr ⋄ hdr←(-+/∧\(⌽hdr)∊NL)↓hdr ⋄ :EndIf
      Answer←(uc Version),' ',status,NL,hdr,NL,NL
      e←Send(Answer filename)(Version≡'http/1.0')
    ∇

    ∇ e←SendFile1(status hdrs filename);Answer
    ⍝ status 0 or 'statuscode' 'reason phrase'
    ⍝ hdrs matrix of headers
    ⍝ filename
      :Access public
      hdrs⍪←'Date' HttpDate
      :If 0≡status ⋄ status←'200' 'OK' ⋄ :EndIf
      s1←srv.LIB.Micros
      e←Send ( (⊂uc Version), status,  hdrs (('' filename), ((hdrs⍪'' '')[hdrs[;1]⍳⊂'Content-Encoding';2]))) 3⍝(2+'http/1.0'≡ lc Version)
      s2←srv.LIB.Micros
    ∇


    ∇ DecodeCmd req;split;buf;input;args;z
     ⍝ Decode an HTTP command line: get /page&arg1=x&arg2=y
     ⍝ Return namespace containing:
     ⍝ Command: HTTP Command ('get' or 'post')
     ⍝ Headers: HTTP Headers as 2 column matrix or name/value pairs
     ⍝ Page:    Requested page
     ⍝ Arguments: Arguments to the command (cmd?arg1=value1&arg2=value2) as 2 column matrix of name/value pairs
     
      input←1⊃,req←2⊃DecodeHeader req
      'HTTPCmd'⎕NS'' ⍝ Make empty namespace
      Input←input
      Headers←{(0≠⊃∘⍴¨⍵[;1])⌿⍵}1 0↓req
     
      split←{p←(⍺⍷⍵)⍳1 ⋄ ((p-1)↑⍵)(p↓⍵)} ⍝ Split ⍵ on first occurrence of ⍺
     
      Version←⌽⊃' 'split⌽input
      Command buf←' 'split input
      buf z←'http/'split buf
      Page args←'?'split buf
     
      Arguments←(args∨.≠' ')⌿↑'='∘split¨{1↓¨(⍵='&')⊂⍵}'&',args ⍝ Cut on '&'
    ∇

    ∇ r←DecodeHeader buf;len;d;dlb;i
⍝ Decode HTML Header
      r←0(0 2⍴⊂'')
      dlb←{(+/∧\' '=⍵)↓⍵} ⍝ delete leading blanks
      :If 0<i←⊃{((NL,NL)⍷⍵)/⍳⍴⍵}buf
          len←(¯1+⍴NL,NL)+i
          d←(⍴NL)↓¨{(NL⍷⍵)⊂⍵}NL,len↑buf
          d←↑{((p-1)↑⍵)((p←⍵⍳':')↓⍵)}¨d
          d[;1]←lc¨d[;1]
          d[;2]←dlb¨d[;2]
          r←len d
      :EndIf
    ∇
    ∇ r←lc x;t
      t←⎕AV ⋄ t[⎕AV⍳⎕A]←'abcdefghijklmnopqrstuvwxyz'
      r←t[⎕AV⍳x]
    ∇

    ∇ r←uc x;t
      t←⎕AV ⋄ t[⎕AV⍳'abcdefghijklmnopqrstuvwxyz']←⎕A
      r←t[⎕AV⍳x]
    ∇

    ∇ r←GetValue(name type);i;h
     :access public
     ⍝ Extract value from HTTP Header structure returned by DecodeHeader
     
      :If (1↑⍴Headers)<i←Headers[;1]⍳⊂lc name
          r←⍬ ⍝ Not found
      :Else
          r←⊃Headers[i;2]
          :If 'Numeric'≡type
              r←1⊃2⊃⎕VFI r
          :EndIf
      :EndIf
    ∇

:EndClass
