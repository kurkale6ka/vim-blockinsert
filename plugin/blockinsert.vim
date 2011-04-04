" Easy Insert/Append to a paragraph of text
"
" Author: Dimitar Dimitrov (mitkofr@yahoo.fr), kurkale6ka
"
" Latest version at:
" http://github.com/kurkale6ka/vimfiles/blob/master/plugin/blockinsert.vim
"
" todo: make the :commands accept a count as their first argument
"
" todo: :Both, :QBoth -> how to give them an empty arg in input:
"       :Both '' Second\ Argument
"
" todo: When hitting <esc> after 'Enter text:', it should abort, not delete

if exists('g:loaded_blockinsert') || &compatible || v:version < 700

   if &compatible && &verbose

      echo "Blockinsert is not designed to work in compatible mode."

   elseif v:version < 700

      echo "Blockinsert needs Vim 7.0 or above to work correctly."
   endif

   finish
endif

let g:loaded_blockinsert = 1

let s:savecpo = &cpoptions
set cpoptions&vim

"function! s:Tab_spaces()

"normal! h

"let before_tab = virtcol('.')

"call search('[^[:tab:]]', 'W', line('.'))

"let after_tab = virtcol('.')

"call search('[[:tab:]]\+', 'Wb', line('.'))

"return after_tab - before_tab - 1

"endfunction

"while search('\t\+','W',line('.'))

"let nb_spaces = s:Tab_spaces()
"echo nb_spaces
"sleep

"execute "normal! x" . nb_spaces . "i \<esc>"
"endwhile

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

            "let current_line = substitute(getline('.'), "\<tab>", '', 'g')

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

function! BlockDoIni (mode, ope1, ope2, col1, col2, row1, row2, text1, text2) range

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

   silent! call repeat#set(":\<c-u>call BlockDoIni ('"
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

" mode, ope1, ope2, col1, col2, row1, row2, text1, text2
if exists('g:blockinsert_commands') && g:blockinsert_commands == 1

   command! -nargs=* -range BlockInsert <line1>,<line2>
      \
      \call BlockDoIni ('c', '', 'i',  0, 0, <line1>, <line2>, '', <q-args>)

   command! -nargs=* -range BlockAppend <line1>,<line2>
      \
      \call BlockDoIni ('c', '', 'a',  0, 0, <line1>, <line2>, '', <q-args>)

   command! -nargs=* -range BlockQInsert <line1>,<line2>
      \
      \call BlockDoIni ('c', '', 'qi', 0, 0, <line1>, <line2>, '', <q-args>)

   command! -nargs=* -range BlockQAppend <line1>,<line2>
      \
      \call BlockDoIni ('c', '', 'qa', 0, 0, <line1>, <line2>, '', <q-args>)

   command! -nargs=* -range BlockBoth <line1>,<line2>
      \
      \call BlockDoIni ('c', 'i',   'a',   0, 0, <line1>, <line2>, <f-args>)

   command! -nargs=* -range BlockBSame <line1>,<line2>
      \
      \call BlockDoIni ('c', 'iu',  'au',  0, 0, <line1>, <line2>, <q-args>, '')

   command! -nargs=* -range BlockQBoth <line1>,<line2>
      \
      \call BlockDoIni ('c', 'qi',  'qa',  0, 0, <line1>, <line2>, <f-args>)

   command! -nargs=* -range BlockQBSame <line1>,<line2>
      \
      \call BlockDoIni ('c', 'qiu', 'qau', 0, 0, <line1>, <line2>, <q-args>, '')
endif

" Insert / Append
xmap <silent> <plug>BlockinsertVInsert
   \
   \ :call BlockDoIni ('v', '', 'i',  0, 0, 0, 0, '', '')<cr>

xmap <silent> <plug>BlockinsertVAppend
   \
   \ :call BlockDoIni ('v', '', 'a',  0, 0, 0, 0, '', '')<cr>

xmap <silent> <plug>BlockinsertVQ_Insert
   \
   \ :call BlockDoIni ('v', '', 'qi', 0, 0, 0, 0, '', '')<cr>

xmap <silent> <plug>BlockinsertVQ_Append
   \
   \ :call BlockDoIni ('v', '', 'qa', 0, 0, 0, 0, '', '')<cr>

" Insert / Append
nmap <silent> <plug>BlockinsertNInsert
   \
   \ :<c-u>call BlockDoIni ('n', '', 'i',  0, 0, 0, 0, '', '')<cr>

nmap <silent> <plug>BlockinsertNAppend
   \
   \ :<c-u>call BlockDoIni ('n', '', 'a',  0, 0, 0, 0, '', '')<cr>

nmap <silent> <plug>BlockinsertNQ_Insert
   \
   \ :<c-u>call BlockDoIni ('n', '', 'qi', 0, 0, 0, 0, '', '')<cr>

nmap <silent> <plug>BlockinsertNQ_Append
   \
   \ :<c-u>call BlockDoIni ('n', '', 'qa', 0, 0, 0, 0, '', '')<cr>

" Both Insert & Append
xmap <silent> <plug>BlockinsertVBoth
   \
   \ :call BlockDoIni ('v', 'i',   'a',   0, 0, 0, 0, '', '')<cr>

xmap <silent> <plug>BlockinsertVBSame
   \
   \ :call BlockDoIni ('v', 'iu',  'au',  0, 0, 0, 0, '', '')<cr>

xmap <silent> <plug>BlockinsertVQ_Both
   \
   \ :call BlockDoIni ('v', 'qi',  'qa',  0, 0, 0, 0, '', '')<cr>

xmap <silent> <plug>BlockinsertVQ_BSame
   \
   \ :call BlockDoIni ('v', 'qiu', 'qau', 0, 0, 0, 0, '', '')<cr>

nmap <silent> <plug>BlockinsertNBoth
   \
   \ :<c-u>call BlockDoIni ('n', 'i',   'a',   0, 0, 0, 0, '', '')<cr>

nmap <silent> <plug>BlockinsertNBSame
   \
   \ :<c-u>call BlockDoIni ('n', 'iu',  'au',  0, 0, 0, 0, '', '')<cr>

nmap <silent> <plug>BlockinsertNQ_Both
   \
   \ :<c-u>call BlockDoIni ('n', 'qi',  'qa',  0, 0, 0, 0, '', '')<cr>

nmap <silent> <plug>BlockinsertNQ_BSame
   \
   \ :<c-u>call BlockDoIni ('n', 'qiu', 'qau', 0, 0, 0, 0, '', '')<cr>

xmap <leader>i  <plug>BlockinsertVInsert
xmap <leader>a  <plug>BlockinsertVAppend
xmap <leader>qi <plug>BlockinsertVQ_Insert
xmap <leader>qa <plug>BlockinsertVQ_Append

nmap <leader>i  <plug>BlockinsertNInsert
nmap <leader>a  <plug>BlockinsertNAppend
nmap <leader>qi <plug>BlockinsertNQ_Insert
nmap <leader>qa <plug>BlockinsertNQ_Append

xmap <leader>[]  <plug>BlockinsertVBoth
xmap <leader>[[  <plug>BlockinsertVBSame
xmap <leader>]]  <plug>BlockinsertVBSame
xmap <leader>q[] <plug>BlockinsertVQ_Both
xmap <leader>q[[ <plug>BlockinsertVQ_BSame
xmap <leader>q]] <plug>BlockinsertVQ_BSame

nmap <leader>[]  <plug>BlockinsertNBoth
nmap <leader>[[  <plug>BlockinsertNBSame
nmap <leader>]]  <plug>BlockinsertNBSame
nmap <leader>q[] <plug>BlockinsertNQ_Both
nmap <leader>q[[ <plug>BlockinsertNQ_BSame
nmap <leader>q]] <plug>BlockinsertNQ_BSame

let &cpoptions = s:savecpo
unlet s:savecpo
