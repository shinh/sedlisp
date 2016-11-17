#!/usr/bin/env ruby

require './evalify'

$evalify = false
if ARGV[0] == '-e'
  $evalify = true
  ARGV.shift
elsif ARGV[0] == '-E'
  $evalify = true
  $eval_test_only = true
  ARGV.shift
end

ref_lisp = ARGV[0] || 'purelisp.rb'
test_lisp = ARGV[1]
test_lisp ||= File.exist?('sedlisp.sed') ? 'sedlisp.sed' : 'beflisp.bef'

COMMANDS = {
  'purelisp.rb' => ['ruby', 'purelisp.rb'],
  'rblisp.rb' => ['ruby', 'rblisp.rb'],
  'sedlisp.sed' => ['sed', '-f', 'sedlisp.sed'],
  'lisp.bef' => ['./befunge', 'lisp.bef'],
  'beflisp.bef' => ['./befunge', 'beflisp.bef'],
  'lisp' => ['./lisp'],
  'makelisp.mk' => ['make', '-f', 'makelisp.mk'],
  'makelisp2.mk' => ['make', '-f', 'makelisp2.mk'],
}

def getResult(cmd, line)
  pipe = IO.popen(cmd, 'r+')
  pipe.puts(line)
  pipe.close_write
  o = pipe.read
  if cmd[-1] == 'rblisp.rb'
    o.gsub!(/^> /, '')
  end
  o
end

num_tests = 0
fails = []

lines = File.readlines('test.l')
lineno = -1
while line = lines[lineno += 1]
  if line.sub(/;.*/, '') =~ /^ *$/
    if (/TEST LAMBDA/ =~ line &&
        (ref_lisp == 'rblisp.rb' || test_lisp == 'rblisp.rb'))
      break
    elsif /TEST EVAL/ =~ line
      $eval_test = true
      if !$evalify
        break
      end
    end
    next
  end

  next if !$eval_test && $eval_test_only

  while line =~ /;cont/
    line.sub!(/;cont/, '')
    line += lines[lineno += 1]
  end
  line.chomp!
  orig = line
  if $evalify
    line = evalify(line)
  end

  expected = getResult(COMMANDS[ref_lisp], $eval_test ? line : orig)
  expected = expected.lines.to_a[-1].to_s.chomp
  output = getResult(COMMANDS[test_lisp], line)
  actual = output.lines.to_a[-1].to_s.chomp

  if expected == actual
    puts "#{orig}: OK (#{expected})"
  else
    puts "#{orig}: FAIL expected=#{expected} actual=#{actual}"
    puts output
    fails << orig
  end
  num_tests += 1
end

if fails.empty?
  puts 'PASS'
else
  puts "Failed tests:"
  puts fails.map{|f|f.inspect}
  puts "#{fails.size} / #{num_tests} FAIL"
end
