Easy Insert/Append to a paragraph of text
=========================================

A plugin intended to make life simpler when inserting or appending characters  
to blocks of text

<h2>1. Normal mode</h2>

Blockinsert can take a range but if no such is given it will act upon the  
current paragraph.

       First line of code
          Another line of code
    Yet another one
       Last line of code

<h3>1.1 Insert</h3>

`[count] \i-` will transform the above into: (count 3 used)

        ---First line of code
            ---Another line of code
    ---Yet another one
        ---Last line of code

<h3>1.2 Append</h3>

`[count] \a>` will transform the above into: (count 2 used)

        ---First line of code>>
            ---Another line of code>>
    ---Yet another one>>
        ---Last line of code>>

<h3>1.3 Delete</h3>

`[count] \i` or `\a` without any text will delete as many characters: (`3\i` used)

        First line of code>>
            Another line of code>>
    Yet another one>>
        Last line of code>>

<h3>1.4 Act on both ends</h3>

`[count] \[]` will use both `\i` and `\a`: (`2\[]` Left text:`*`, Right text:`**` used)

        Note: the same `[count]` will be applied to both operations

        **First line of code>>****
            **Another line of code>>****
    **Yet another one>>****
        **Last line of code>>****

<h3>1.5 Act on both ends using the same text</h3>

`[count] \[[` will use both `\i` and `\a` and the same text: (`|` used)

        |**First line of code>>****|
            |**Another line of code>>****|
    |**Yet another one>>****|
        |**Last line of code>>****|

<h3>1.6 Record</h3>

`\qi`, `\qa` and `\q[]` will execute rather than write the text in input.

Example with `\qa gUaW`:

        |**First line of CODE>>****|
            |**Another line of CODE>>****|
    |**Yet another ONE>>****|
        |**Last line of CODE>>****|

<h3>1.7 Repeat</h3>

This plugin integrates with Tim Pope's repeat plugin. It means that you can use  
**. (dot)** to repeat any blockinsert mapping you just used!

For more information see: http://github.com/tpope/vim-repeat

<h2>2. Visual mode</h2>

The visual mappings do the same work as the normal ones,  
The only difference is that here the range is defined by the selected lines.

There is one special case. When selecting text in visual block mode, the  
boundaries of the text acted upon are defined by the limits of the visual area.

_Example:_ (the `<bar>`s represent our selection)

    Some text here                |stridx(    |       end of this line
    Some other text...            |strridx(   |       text after a function
    Let's start a third line      |strlen(    |       ...finish this line
    End of paragraph              |substitute(|       end indeed.

Now that a selection has been defined, all you need to do is type:  
`\a` followed by `)`  
and your text will become:

    Some text here                 stridx()           end of this line
    Some other text...             strridx()          text after a function
    Let's start a third line       strlen()           ...finish this line
    End of paragraph               substitute()       end indeed.

<h2>3. Commands</h2>

The following commands are also available, meant as an alternative to the  
normal and visual mappings:

    BlockInsert       text
    BlockAppend       text
    BlockQInsert      actions
    BlockQAppend      actions
    BlockBoth         text1 text2
    BlockBothSame     text
    BlockQBoth        actions1 actions2
    BlockQBothSame    actions

The commands are disabled by default. Put this line in your _vimrc_ if you want  
them enabled:

    :let g:blockinsert_commands = 1

_@Todo:_ make the commands accept a count as their first argument

<h2>4. Custom mappings</h2>

You have the possibility to define your own custom mappings in your _vimrc_:

    vmap <leader>i  <plug>blockinsert-i
    vmap <leader>a  <plug>blockinsert-a
    vmap <leader>qi <plug>blockinsert-qi
    vmap <leader>qa <plug>blockinsert-qa

    nmap <leader>i  <plug>blockinsert-i
    nmap <leader>a  <plug>blockinsert-a
    nmap <leader>qi <plug>blockinsert-qi
    nmap <leader>qa <plug>blockinsert-qa

    vmap <leader>[]  <plug>blockinsert-b
    vmap <leader>[[  <plug>blockinsert-ub
    vmap <leader>]]  <plug>blockinsert-ub
    vmap <leader>q[] <plug>blockinsert-qb
    vmap <leader>q[[ <plug>blockinsert-uqb
    vmap <leader>q]] <plug>blockinsert-uqb

    nmap <leader>[]  <plug>blockinsert-b
    nmap <leader>[[  <plug>blockinsert-ub
    nmap <leader>]]  <plug>blockinsert-ub
    nmap <leader>q[] <plug>blockinsert-qb
    nmap <leader>q[[ <plug>blockinsert-uqb
    nmap <leader>q]] <plug>blockinsert-uqb

_Note:_ You can replace `\i`, `\a`, `\qi`, `\qa`, `\[]`, `\[[`, `\]]`, `\q[]`, `\q[[`, `\q]]`
      with whatever you like.
