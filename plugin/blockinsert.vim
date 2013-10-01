" Easy Insert/Append to a paragraph of text
"
" Author: Dimitar Dimitrov (mitkofr@yahoo.fr), kurkale6ka
"
" Latest version at:
" https://github.com/kurkale6ka/vim-blockinsert
"
" 1. todo: Rewrite the code using a Block object where c1, c2, l1 and l2 would be
"          properties and block#ini() a method...
"
" 2. todo: When hitting <esc> after 'Enter text:', it should abort, not delete
"
" 3. todo: make the :commands accept a count as their first argument
"
" 4. todo: :Both, :QBoth -> how to give them an empty arg in input:
"          :Both '' Second\ Argument

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

" mode, ope1, ope2, col1, col2, row1, row2, text1, text2
if exists('g:blockinsert_commands') && g:blockinsert_commands == 1

   command! -nargs=* -range BlockInsert <line1>,<line2>
      \call block#ini ('c', '', 'i',  0, 0, <line1>, <line2>, '', <q-args>)

   command! -nargs=* -range BlockAppend <line1>,<line2>
      \call block#ini ('c', '', 'a',  0, 0, <line1>, <line2>, '', <q-args>)

   command! -nargs=* -range BlockQInsert <line1>,<line2>
      \call block#ini ('c', '', 'qi', 0, 0, <line1>, <line2>, '', <q-args>)

   command! -nargs=* -range BlockQAppend <line1>,<line2>
      \call block#ini ('c', '', 'qa', 0, 0, <line1>, <line2>, '', <q-args>)

   command! -nargs=* -range BlockBoth <line1>,<line2>
      \call block#ini ('c', 'i',   'a',   0, 0, <line1>, <line2>, <f-args>)

   command! -nargs=* -range BlockBSame <line1>,<line2>
      \call block#ini ('c', 'iu',  'au',  0, 0, <line1>, <line2>, <q-args>, '')

   command! -nargs=* -range BlockQBoth <line1>,<line2>
      \call block#ini ('c', 'qi',  'qa',  0, 0, <line1>, <line2>, <f-args>)

   command! -nargs=* -range BlockQBSame <line1>,<line2>
      \call block#ini ('c', 'qiu', 'qau', 0, 0, <line1>, <line2>, <q-args>, '')
endif

" Insert / Append
xmap <silent> <plug>BlockinsertVInsert
   \ :call block#ini ('v', '', 'i',  0, 0, 0, 0, '', '')<cr>

xmap <silent> <plug>BlockinsertVAppend
   \ :call block#ini ('v', '', 'a',  0, 0, 0, 0, '', '')<cr>

xmap <silent> <plug>BlockinsertVQ_Insert
   \ :call block#ini ('v', '', 'qi', 0, 0, 0, 0, '', '')<cr>

xmap <silent> <plug>BlockinsertVQ_Append
   \ :call block#ini ('v', '', 'qa', 0, 0, 0, 0, '', '')<cr>

" Insert / Append
nmap <silent> <plug>BlockinsertNInsert
   \ :<c-u>call block#ini ('n', '', 'i',  0, 0, 0, 0, '', '')<cr>

nmap <silent> <plug>BlockinsertNAppend
   \ :<c-u>call block#ini ('n', '', 'a',  0, 0, 0, 0, '', '')<cr>

nmap <silent> <plug>BlockinsertNQ_Insert
   \ :<c-u>call block#ini ('n', '', 'qi', 0, 0, 0, 0, '', '')<cr>

nmap <silent> <plug>BlockinsertNQ_Append
   \ :<c-u>call block#ini ('n', '', 'qa', 0, 0, 0, 0, '', '')<cr>

" Both Insert & Append
xmap <silent> <plug>BlockinsertVBoth
   \ :call block#ini ('v', 'i',   'a',   0, 0, 0, 0, '', '')<cr>

xmap <silent> <plug>BlockinsertVBSame
   \ :call block#ini ('v', 'iu',  'au',  0, 0, 0, 0, '', '')<cr>

xmap <silent> <plug>BlockinsertVQ_Both
   \ :call block#ini ('v', 'qi',  'qa',  0, 0, 0, 0, '', '')<cr>

xmap <silent> <plug>BlockinsertVQ_BSame
   \ :call block#ini ('v', 'qiu', 'qau', 0, 0, 0, 0, '', '')<cr>

nmap <silent> <plug>BlockinsertNBoth
   \ :<c-u>call block#ini ('n', 'i',   'a',   0, 0, 0, 0, '', '')<cr>

nmap <silent> <plug>BlockinsertNBSame
   \ :<c-u>call block#ini ('n', 'iu',  'au',  0, 0, 0, 0, '', '')<cr>

nmap <silent> <plug>BlockinsertNQ_Both
   \ :<c-u>call block#ini ('n', 'qi',  'qa',  0, 0, 0, 0, '', '')<cr>

nmap <silent> <plug>BlockinsertNQ_BSame
   \ :<c-u>call block#ini ('n', 'qiu', 'qau', 0, 0, 0, 0, '', '')<cr>

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
