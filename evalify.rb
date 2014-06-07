#!/usr/bin/env ruby

def evalify(c)
  o = File.read('eval.l').sub(/; TEST.*/ms, '')
  c.lines.each do |line|
    line.sub!(/;.*/, '')
    next if line =~ /^$/
    o += "(eval (quote #{line.chomp}))\n"
  end
  o
end

if $0 == __FILE__
  puts evalify($<.read)
end
