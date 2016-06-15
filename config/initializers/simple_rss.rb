SimpleRSS.class_eval do
   def unescape(content)
     if content =~ /([^-_.!~*'()a-zA-Z\d;\/?:@&=+$,\[\]]%)/ then
       CGI.unescape(content).gsub(/(<!\[CDATA\[|\]\]>)/,'').strip
     else
       content.gsub(/(<!\[CDATA\[|\]\]>)/,'').strip
     end
   end
end
