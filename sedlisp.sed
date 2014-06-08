x
s/^/;mod;(lambda (n m) (- n (* (\/ n m) m)))$;\n/
# TODO: Handle negative divisions.
s/^/;\/;(lambda (n m) (div-impl n m))$;\n/
s/^/;div-impl;(lambda (n m) (if (neg? n) -1 (+ 1 (div-impl (- n m) m))))$;\n/
s/^/;*;(lambda (n m) (if (eq n 0) 0 (+ m (* (- n 1) m))))$;\n/
y/() /{}_/
x

:line_read

s/ *;.*//
s/\s\+/ /g
s/(\s\+/(/g
s/\s\+)/)/g
s/\([^ ()]\)(/\1 (/g

:loop

s/  */ /g

## i *** loop ***
## p
## x
## i *** stack ***
## p
## x

#s/( *)/nil/g

/^(if /{
  s/^(if \[\] /(if nil /
  /^(if nil /{
    s/(if nil /_ifnil /

    /^_ifnil (/{
      :remove_if_t
      s/([^()]*)/@/
      /^_ifnil (/bremove_if_t
    }
    s/^\(_ifnil \) *\S\+/\1/

    :parse_if_nil
    s/\(([^()]*)\)\([^\n]*\)/@\2\n\1/
    #s/\(.*\n\)\(.*\)@\(.*\)\n\(.*\)/\1\2\4\3/
    /^_ifnil *(/bparse_if_nil

    :resolve_if_nil_at
    s/^\(.*\n\)\(.*\)@\([^\n]*\)\n\([^\n]*\)/\1\2\4\3/
    /^\(.*\n\)\(.*\)@/bresolve_if_nil_at

    s/^_ifnil/_ift/
    bif_resolved
  }

  /^(if (/{
    :parse_if
    s/\(([^()]*)\)\([^\n]*\)/@\2\n\1/
    /^(if (/bparse_if

    :resolve_if_at
    s/^\(.*\n\)\(.*\)@\([^\n]*\)\n\([^\n]*\)/\1\2\4\3/
    /^\(.*\n\)\(.*\)@/bresolve_if_at

    s/\(.*\)\n\(.*\)/\2@\1/
    bpush_and_loop
  }

  /^(if \S\+ /{
    s/(if \S\+ /_ift /
    :parse_if_t
    s/\(([^()]*)\)\([^\n]*\)/@\2\n\1/
    #s/\(.*\n\)\(.*\)@\(.*\)\n\(.*\)/\1\2\4\3/
    /^_ift (/bparse_if_t

    :resolve_if_t_at
    s/^\(.*\n\)\(.*\)@\([^\n]*\)\n\([^\n]*\)/\1\2\4\3/
    /^\(.*\n\)\(.*\)@/bresolve_if_t_at

    /^_ift \S\+ (/{
      :remove_if_nil
      s/([^()]*)//
      /^_ift \S\+ (/bremove_if_nil
    }

    :if_resolved
    /^_ift  *@/{
      s/.*\n//
      bloop
    }

    /^_ift  *[^() ]\+/{
      s/^_ift  *\([^() ]\+\).*/\1/
      bloop
    }

    s/^/invalid if?: /
    q
  }

  s/^/invalid if?: /
  q

  :push_and_loop
  H
  s/@.*//
  bloop
}

/^(defun /{
  /^(defun \S\+ ([^()]*) .*)/!{
    s/^/invalid defun: /
    q
  }

  s/(defun \(\S\+\) (\([^()]*\)) \(.*\))/;\1;(lambda (\2) \3)$;/
  y/() /{}_/
  G
  s/^\(;\([^;]*\);[^;]*;.*\n\);\2;[^;]*;\n/\1/
  x
  s/^;[^;]*;\([^;]*\);.*/\1/
  bloop
}

/^(define /{
  /^(define \S\+ .*)/!{
    s/^/invalid define: /
    q
  }

  s/(define /(define' '/
  bloop
}

/^(quote /{
  s/(quote \(.*\)).*/\1/
  y/() /[],/
  bloop
}

/^(lambda /{
  /^(lambda ([^()]*) .*)$/!{
    s/^/invalid lambda: /
    q
  }

  y/() /{}_/
  s/$/$/
  bloop
}

# Need to handle special forms?
s/\(([^()]*)\)\(.*\)/@\2\n\1/
/^[^@]*(\(if\|defun\|quote\|lambda\|define\) /{
  # Yes.
  s/@\(.*\)\n\(.*\)/\2\1/
  s/(\(if\|defun\|quote\|lambda\|define\) /(@\1 /
  s/^\(.*\)(@\(.*\)/\2\n\1/

  #i special 1
  #p
  /^[^()]*)/!{
    :parse_special_form
    s/\(([^()]*)\)\([^\n]*\n[^\n]*\)/@\2\n;\1/
  #i special 2
  #p

    :resolve_special_form_at
    s/\(;.*\)@\([^\n]*\)\n;\([^\n]*\)/\1\3\2/
    /\(;.*\)@\([^\n]*\)\n;\([^\n]*\)/bresolve_special_form_at

    /^[^()]*)/!bparse_special_form
  }
  #i special 3
  #p

  s/\(^[^()]*)\)\([^\n]*\)\n\([^\n]*\)/(\1\n\3@\2/

  :resolve_special_at
  s/^\([^@\n]*\)@\([^\n]*\)\(.*\)\n;\(.*\)/\1\4\2\3/
  /^[^@\n]*@/bresolve_special_at

  s/\n/@/
  H
  s/@.*//
  bloop
}
s/@\(.*\)\n\(.*\)/\2\1/

s/([^()]*)/@&@/
/@/!{
  s/.*/(&) {}/
  bhandle_var
}

s/\(.*\)@\(.*\)@/\2@\1@/
:start
H

## i *** start ***
## p
## x
## i *** stack ***
## p
## x

s/@.*//

# This is unfortunate...
/(\(if\|defun\|quote\|lambda\|define\) /bloop

:handle_var
G
/^\([^\n]*[ ()]\)\([^0-9 ]\S*\)\([ ()\n]\).*\n;\2;/{
  #i variable
  #p

  :subst_variable
  s/^\([^\n]*[ ()]\)\([^0-9 ]\S*\)\([ ()\n].*\n;\2;\([^;]*\)\)/\1\4\3/
  #i var
  #p

  /^[^\n]*[ ()]\([^0-9 ]\S*\)[ ()\n].*\n;\1;/bsubst_variable
  
  #i result
  #p

  s/\n.*//

  / {}$/{
    s/(\(.*\)) {}$/\1/
    bmaybe_pop
  }

  bloop
}

s/\n.*//
/ {}$/{
  s/(\(.*\)) {}$/\1/
  bmaybe_pop
}

/({lambda/{
  #i lambda!
  #p

  s/\$/;/
  H
  s/;.*/;/
  y/{}_/()@/

  G
  s/;.*;/;/


  /^[^$]*);\s*)$/!{
    /^((lambda@*([^@)]\+/!binvalid_number_of_args

    :subst_args_lambda

    /^((lambda@*(@*)/binvalid_number_of_args

    :subst_arg_lambda

    s/^\(((lambda@*(@*\([^@);]\+\)[^);]*)[^;]*[()@]\)\2\([()@][^;]*)*;\s*\([^ ]\+\).*)\)$/\1\4\3/

    /^((lambda@*(@*\([^@);]\+\)[^);]*)[^;]*[()@]\1[()@][^;]*)*;\s*[^ ]\+.*)$/bsubst_arg_lambda


    s/^\(((lambda@*(\)@*[^@);]\+\([^;]*);\s*\)[^ )]\+/\1\2/
    /^[^;]*);\s*)$/!bsubst_args_lambda
  }

  /((lambda@*(@*)/!binvalid_number_of_args

  s/((lambda@(@*)@\(.*\));\s*)$/\1/

  y/@/ /

  x
  s/\n[^\n]*$//
  x
  bpop_context

  :invalid_number_of_args
  x
  s/.*\n/invalid number of args: /
  y/{}_@/()  /
  s/\$//g
  s/;//g
  q
}

/(+ /{
  /--/{
    s/^/invalid add: /
    q
  }
  /(+ -*[0-9]\+ -*[0-9]\+)/!{
    s/^/invalid add: /
    q
  }

  s/(+ //
  s/)//
  /^-/{
    / -/!{
      s/-\(.*\) \(.*\)/\2 \1/
      bsub
    }
    s/-//g
    s/$/\n-/
  }
  / -/{
    s/\(.*\) -/\1 /
    bsub
  }

:add
  s/\(.*\) \([0-9]*\)\(\n\(-\)\)\?/\1@ \2@ 9876543210 9876543210\n\4/

:add_loop
  s/\(.\)@\(.*\)\(.\)@\(.\)\? \(.*\1\(.*\)\) .*\3\(.*\)\n/@\2; \4\6\7\5 \5 \5\n/

  s/; .\{9\}\(.\)\([0-9]\{9\}\([0-9]\)\)\?[0-9]* \(.*\)\n\(.*\)/@\3 \4\n\1\5/

  /^@ @/{
    s/@ @. .*\n/\n1/
    s/.*\n//
    :after_addsub
    s/\(.*\)-/-\1/
    s/^-0$/0/
    # wtf...
    s/^0*\([0-9]\)/\1/
    bpop_context
  }

  s/^@/0@/
  s/ @/ 0@/

  badd_loop
}

/(- /{
  /--/{
    s/^/invalid sub: /
    q
  }
  /(- -*[0-9]\+ -*[0-9]\+)/!{
    s/^/invalid sub: /
    q
  }

  s/(- //
  s/)//
  /^-/{
    / -/!{
      s/-//
      s/$/\n-/
      badd
    }
    s/-//g
    s/\(.*\) \(.*\)/\2 \1/
  }
  / -/{
    s/-//
    badd
  }

:sub
  s/\(.*\) \([0-9]*\)\(\n\(-\)\)\?/\1@ \2@x 9876543210 0123456789\n\4@\1 \2/

:sub_loop

  s/\(.\)@\(.*\)\(.\)@\(.\)\? \(.*\1\(.*\)\) \(.*\3\(.*\)\)\n/@\2; \4\8\1\6\5 \5 \7\n/

  s/; .\{10\}\(.\)\([0-9]\{9\}\([^ ]\)\)\?[0-9]* \(.*\)\n\(.*\)/@\3 \4\n\1\5/

  /^@ @ /{
    s/.*\(-*\)@\(.*\) \(.*\)/\3 \2\n-\1/
    s/--//
    bsub
  }

  /^@ @/{
    s/@ @. .*\n/\n/
    s/@.*//
    s/.*\n//
    s/^0*\([1-9]\)/\1/
    bafter_addsub
  }

  s/^@/0@/
  s/ @/ 0@/

  bsub_loop
}

/(eq /{
  /(eq \(\S\+\) \1)/{
    s/.*/t/
    bpop_context
  }
  /(eq \(\S\+\) \(\S\+\))/{
    s/.*/nil/
    bpop_context
  }
  s/^/invalid eq: /
  q
}

/(c[ad]r /{
  s/\((c[ad]r \)\[ *\]/\1nil/
  /(c[ad]r nil *)/{
    s/.*/[]/
    bpop_context
  }

  /(car \[\S\+ *)/{
    s/(car \[\([^][,]\+\).*/\1/
    /(car/!bpop_context

    s/(car \[/_car /
    :parse_car
    s/\(\[[^][]*\]\)\([^\n]*\)/@\2\n\1/
    /_car *\[/bparse_car

    :resolve_car_at
    s/^\(.*\n\)\(.*\)@\([^\n]*\)\n\([^\n]*\)/\1\2\4\3/
    /^\(.*\n\)\(.*\)@/bresolve_car_at

    s/.*\n//

    bpop_context
  }

  /(cdr \[\S\+ *)/{
    s/(cdr \[\(.*\)\].*/\1/
    /^\[/!{
      s/^[^,]\+//
      :car_removed
      /^,/!{
        s/.*/[]/
        bpop_context
      }
      s/^,\(.*\)/[\1]/
      bpop_context
    }

    :remove_car
    s/\[[^][]*\]//
    /^\[/bremove_car

    bcar_removed
  }

  /^(car/ s/^/invalid car: /
  /^(cdr/ s/^/invalid cdr: /
  q
}

/(cons /{
  /(cons \S\+ \S\+)/{
    s/\((cons \S\+ \)\[ *\]/\1nil/
    /(cons \S\+ nil)/{
      s/(cons \(\S\+\) .*/[\1]/
      bpop_context
    }

    /(cons \S\+ [^[]/{
      s/^/tuple is not supported: /
      q
    }

    s/(cons \(\S\+\) \[\(.*\)\])/[\1,\2]/
    bpop_context
  }
  s/^/invalid cons: /
  q
}

/(atom /{
  /\[\S\+\]/{
    s/.*/[]/
    bpop_context
  }
  s/.*/t/
  bpop_context
}

/^(define' /{
  /^(define' '\S\+ .*)/!{
    s/^/invalid define: /
    q
  }

  s/(define' '\(\S\+\) \(.*\))/;\1;\2;/
  G
  s/^\(;\([^;]*\);[^;]*;.*\n\);\2;[^;]*;\n/\1/
  x
  s/^;[^;]*;\([^;]*\);.*/\1/
  bpop_context
}

/(neg? /{
  /(neg? -\S\+)/{
    s/.*/t/
    bpop_context
  }
  /(neg? \S\+)/{
    s/.*/nil/
    bpop_context
  }
  s/^/invalid neg?: /
  q
}

/(print /{
  /(print \S\+)/{
    s/(print //
    s/)//

    s/^/PRINT: /
    p
    s/PRINT: //

    bpop_context
  }
  s/^/invalid print: /
  q
}

/(\s*)/{
  s/.*/nil/
  bpop_context
}

s/^/unknown function: /
q

:maybe_pop

x
/@/{
  x
  bpop_context
}
x

bfinish

:pop_context

## i *** pop_context ***
## p
## x
## i *** stack ***
## p
## i ===
## x

H
x
h
s/\n[^\n]*\n[^\n]*$//
x
s/.*\n[^\n@]*@\([^\n@]*\)@\([^\n@]*\)\n\([^\n]*\)$/\1\3\2/

bloop

:finish

s/\[ *\]/nil/
y/[]{}_,/()()  /
s/\$//g

N

H
s/\n.*//
p
g
s/.*\n//
x
s/\n[^\n]*$//
x

bline_read
