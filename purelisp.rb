#!/usr/bin/env ruby

$vals = {}

def parse_sexpr(s, orig)
  case s.strip
  when /^\(/
    s = $'
    r = []
    while s !~ /^\)/
      raise "invalid sexpr: #{orig}" if s.empty?
      x, s = parse_sexpr(s, orig)
      r << x
      s.lstrip!
    end
    [r, $']
  when /^-?\d+/
    [$&.to_i, $']
  when /^t\b/
    [:t, $']
  when /^nil\b/
    [[], $']
  when /^([^() ]+)/
    [$1, $']
  end
end

def atom?(sexpr)
  !sexpr.is_a?(Array) || sexpr == []
end

def eval_sexpr(sexpr, vals)
  if atom?(sexpr)
    return vals[sexpr] || $vals[sexpr] || sexpr
  end

  op, *args = sexpr
  case op
  when 'if'
    raise "invalid if: #{stringify_sexpr(sexpr)}" if args.size != 3
    cond = eval_sexpr(args[0], vals)
    result = cond != [] ? eval_sexpr(args[1], vals) : eval_sexpr(args[2], vals)
    return result
  when 'defun'
    if (args.size != 3 || !args[0].is_a?(String) || !args[1].is_a?(Array) ||
        !args[1].all?{|a|a.is_a?(String)})
      raise "invalid defun: #{stringify_sexpr(sexpr)}"
    end
    $vals[args[0]] = {:args => args[1], :expr => args[2]}
    return args[0]
  when 'lambda'
    if (args.size != 2 ||
        !args[0].is_a?(Array) || !args[0].all?{|a|a.is_a?(String)})
      raise "invalid lambda: #{stringify_sexpr(sexpr)}"
    end
    return {:args => args[0], :expr => args[1]}
  when 'define'
    if args.size != 2 || !args[0].is_a?(String)
      raise "invalid define: #{stringify_sexpr(sexpr)}"
    end
    $vals[args[0]] = eval_sexpr(args[1], vals)
    return []
  when 'quote'
    raise "invalid quote: #{stringify_sexpr(sexpr)}" if args.size != 1
    return args[0]
  end

  op = eval_sexpr(op, vals)
  args = args.map{|a|eval_sexpr(a, vals)}

  case op
  when Hash
    if op[:args].size != args.size
      raise "invalid number of args: #{stringify_sexpr(sexpr)}"
    end
    vals = {}
    op[:args].zip(args){|k, v|vals[k] = v}
    eval_sexpr(op[:expr], vals)
  when '+'
    raise "invalid add: #{stringify_sexpr(sexpr)}" if args.size != 2
    args[0] + args[1]
  when '-'
    raise "invalid sub: #{stringify_sexpr(sexpr)}" if args.size != 2
    args[0] - args[1]
  when '*'
    raise "invalid mul: #{stringify_sexpr(sexpr)}" if args.size != 2
    args[0] * args[1]
  when '/'
    raise "invalid div: #{stringify_sexpr(sexpr)}" if args.size != 2
    args[0] / args[1]
  when 'mod'
    raise "invalid mod: #{stringify_sexpr(sexpr)}" if args.size != 2
    args[0] % args[1]
  when 'eq'
    raise "invalid eq: #{stringify_sexpr(sexpr)}" if args.size != 2
    args[0] == args[1] ? :t : []
  when 'car'
    if args.size != 1 || !args[0].is_a?(Array)
      raise "invalid car: #{stringify_sexpr(sexpr)}"
    end
    args[0][0] || []
  when 'cdr'
    if args.size != 1 || !args[0].is_a?(Array)
      raise "invalid cdr: #{stringify_sexpr(sexpr)}"
    end
    args[0][1..-1] || []
  when 'cons'
    if args.size != 2 || !args[1].is_a?(Array)
      raise "invalid cons: #{stringify_sexpr(sexpr)}"
    end
    [args[0]] + args[1]
  when 'atom'
    raise "invalid atom: #{stringify_sexpr(sexpr)}" if args.size != 1
    atom?(args[0]) ? :t : []
  when 'neg?'
    raise "invalid neg?: #{stringify_sexpr(sexpr)}" if args.size != 1
    args[0] < 0 ? :t : []
  when 'print'
    raise "invalid print: #{stringify_sexpr(sexpr)}" if args.size != 1
    puts "PRINT: #{stringify_sexpr(args[0])}"
    args[0]
  else
    raise "undefined function: #{op}"
  end
end

def stringify_sexpr(sexpr)
  if sexpr == []
    'nil'
  elsif sexpr == :t
    't'
  elsif sexpr.is_a?(Array)
    '(' + sexpr.map{|s|stringify_sexpr(s)} * ' ' + ')'
  else
    sexpr.to_s
  end
end

$<.each do |line|
  line.sub!(/;.*/, '')
  next if line =~ /^$/
  line.gsub!(/\s+/, ' ')
  sexpr, rest = parse_sexpr(line, line)
  raise "invalid sexpr: #{line}" if !rest.empty?
  puts stringify_sexpr(eval_sexpr(sexpr, {}))
end
