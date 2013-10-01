function! s:BlockDo (operation, col1, col2, row1, row2, text)

   if empty(a:col1) && a:operation =~ 'q' || '_delete_please' == a:text

      let go_start = '^'
      let go_end   = '$'

   " I (insert) and A (append)
   elseif empty(a:col1) && a:operation !~ 'q'

      let go_start = ''
      let go_end   = ''
   else
      let block = 1
   endif

   if '_delete_please' != a:text

      if 'a' == a:operation

         if exists('block')

            let operation = v:count1 . 'a' . a:text . "\<esc>"
         else
            let operation = v:count1 . 'A' . a:text . "\<esc>"
         endif

      elseif 'i' == a:operation

         if exists('block')

            let operation = v:count1 . 'i' . a:text . "\<esc>"
         else
            let operation = v:count1 . 'I' . a:text . "\<esc>"
         endif

      elseif 'qa' == a:operation

         if v:count1 > 1 && a:text !~ '^[[:space:]]*[[:digit:]]'

            let operation = v:count1 . a:text . "\<esc>"
         else
            let operation = a:text . "\<esc>"
         endif

      elseif 'qi' == a:operation

         if v:count1 > 1 && a:text !~ '^[[:space:]]*[[:digit:]]'

            let operation = v:count1 . a:text . "\<esc>"
         else
            let operation = a:text . "\<esc>"
         endif
      endif

   elseif a:operation =~ 'a'

      if v:count1 > 1

         let _count = v:count1 - 1

         let operation = _count . 'h' . v:count1 . 'x'
      else
         let operation = v:count1 . 'x'
      endif

   elseif a:operation =~ 'i'

      let operation = v:count1 . 'x'
   endif

   " Less lines to be transformed than the recorded range
   if a:row2 - a:row1 <= line('$') - line('.')

      let lastline = a:row2 - a:row1 + 1
   else
      let lastline = line('$') - line('.') + 1
   endif

   if !empty(a:col1)

      for i in range(1, lastline)

         if a:col2 >= virtcol('$')

            let test_string = matchstr(getline('.'), '\%' . a:col1 . 'v.*$')

            let go_start = a:col1 . "|:call search('" . '\%' . a:col1 . 'v.\{-}\zs[^[:space:]].*$' . "', 'c', line('.'))\<cr>"
            let go_end   = a:col1 . "|:call search('" . '\%' . a:col1 . 'v.*[^[:space:]]\+\ze.*$' . "', 'ce', line('.'))\<cr>"
         else
            let col2 = a:col2 + 1

            let test_string =
               \matchstr(getline('.'), '\%' .a:col1. 'v.*\%' . col2 . 'v')

            let go_start = a:col1 . "|:call search('" . '\%' . a:col1 . 'v.\{-}\zs[^[:space:]].*\%' . col2 . "v', 'c'  , line('.'))\<cr>"
            let go_end   = a:col1 . "|:call search('" . '\%' . a:col1 . 'v.*[^[:space:]]\+\ze.*\%' . col2 . "v', 'ce', line('.'))\<cr>"
         endif

         " +-------------------+
         " | s:test_strings[1] |
         " +-------------------+
         " |   empty portion   |
         " +-------------------+
         " | s:test_strings[2] |
         " +-------------------+
         " | s:test_strings[3] |
         " +-------------------+
         if has_key(s:test_strings, i) || test_string =~ '[^[:space:]]'

            if !has_key(s:test_strings, i)

               let s:test_strings[i] = 1
            endif

            if a:operation =~ 'a'

               execute 'normal! ' . go_end . operation
            else
               execute 'normal! ' . go_start . operation
            endif
         endif
         +
      endfor
   else
      for i in range(1, lastline)

         if getline('.') !~ '^[[:space:]]*$'

            if a:operation =~ 'a'

               execute 'normal! ' . go_end . operation
            else
               execute 'normal! ' . go_start . operation
            endif
         endif
         +
      endfor
   endif

endfunction

function! s:Get_text (ope, text1, text2)

   if !empty(a:text1)

      let text1 = a:text1

   elseif a:ope !~ 'u'

      if a:ope =~ 'i' && !&rightleft || a:ope =~ 'a' && &rightleft

         if a:ope !~ 'q'

            let text1 = input('Left text: ')
         else
            let text1 = input('Left actions: ')
         endif
      else
         if a:ope !~ 'q'

            let text1 = input('Right text: ')
         else
            let text1 = input('Right actions: ')
         endif
      endif

   elseif a:ope =~ 'u'

      if !empty(a:text2)

         let text1 = a:text2
      else
         if a:ope !~ 'q'

            let text1 = input('Surround text: ')
         else
            let text1 = input('Surround actions: ')
         endif
      endif
   endif

   if empty(text1)

      let text1 = '_delete_please'
   endif

   return text1

endfunction

function! block#ini (mode, ope1, ope2, col1, col2, row1, row2, text1, text2) range

   " Get texts
   if !empty(a:ope1)

      let text1 = s:Get_text (a:ope1, a:text1, '')
   else
      let text1 = ''
   endif

   if !empty(a:ope2)

      let text2 = s:Get_text (a:ope2, a:text2, text1)
   else
      let text2 = ''
   endif

   " Get operations ([q]i, [q]a)
   if (a:ope1 !~ 'u')

      let ope1 = a:ope1
      let ope2 = a:ope2
   else
      let ope1 = substitute(a:ope1, 'u', '', '')
      let ope2 = substitute(a:ope2, 'u', '', '')
   endif

   " Get columns
   if 'v' == a:mode

      if "\<c-v>" == visualmode() ||
         \  'v' ==# visualmode() && a:firstline == a:lastline

         let mode = 'vbr'

         if virtcol("'<") < virtcol("'>")

            let col1 = virtcol("'<")
            let col2 = virtcol("'>")
         else
            let col1 = virtcol("'>")
            let col2 = virtcol("'<")
         endif
      else
         let mode = 'vlr'
      endif

   elseif 'c' == a:mode && a:row1 != a:row2 && 0 != a:row1

      let mode = 'cr'
   else
      let mode = a:mode
   endif

   if 'vbr' == a:mode

      let col1 = virtcol('.')
      let col2 = col1 + a:col2 - a:col1
   endif

   if !exists('col1')

      let col1 = 0
      let col2 = 0
   endif

   " Get rows
   " no range given
   " Limitation: if a:mode is 'c' and there is a visual selection on the
   "             current line only, the range will still be re-calculated.
   "             This is because there is no way in Vim to know what the
   "             current mode is!
   if 'n' == a:mode || 'c' == a:mode && a:row1 == a:row2

      '{

      " at BOF
      " todo: take into account paragraph macros
      if getline('.') =~ '[^[:space:]]'

         let row1 = 1
      else
         +
         let row1 = line('.')
      endif

      if getline("'}") =~ '[^[:space:]]'

         let row2 = line('$')
      else
         let row2 = line("'}") - 1
      endif

      let _row1 = 0
      let _row2 = 0

      " use previous range
   elseif a:mode =~ 'r'

      let  row1 = a:row1
      let  row2 = a:row2
      let _row1 = a:row1
      let _row2 = a:row2
   else
      let  row1 = a:firstline
      let  row2 = a:lastline
      let _row1 = a:firstline
      let _row2 = a:lastline
   endif

   " Execute operations
   if !empty(ope1) && !empty(ope2)

      let line_bak = line('.')
   endif

   let s:test_strings = {}

   if !empty(ope2)

      call s:BlockDo (ope2, col1, col2, row1, row2, text2)

      if !empty(ope1)

         execute line_bak
      endif
   endif

   if !empty(ope1)

      call s:BlockDo (ope1, col1, col2, row1, row2, text1)
   endif

   " Repeat
   " When enabled (my case :), it is causing problems
   let virtualedit_bak = &virtualedit
   set virtualedit=

   silent! call repeat#set(":\<c-u>call block#ini ('"
      \       .  mode .
      \"', '" .  ope1 .
      \"', '" .  ope2 .
      \"',  " .  col1 .
      \" ,  " .  col2 .
      \" ,  " . _row1 .
      \" ,  " . _row2 .
      \" , '" . text1 .
      \"', '" . text2 .
      \"')\<cr>"
      \)

   let &virtualedit = virtualedit_bak

endfunction
