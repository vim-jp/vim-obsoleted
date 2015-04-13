" Vim syntax file
" Language:		shell (sh) Korn shell (ksh) bash (sh)
" Maintainer:		Charles E. Campbell  <NdrOchipS@PcampbellAfamily.Mbiz>
" Previous Maintainer:	Lennart Schultz <Lennart.Schultz@ecmwf.int>
" Last Change:		Apr 02, 2015
" Version:		135
" URL:		http://www.drchip.org/astronaut/vim/index.html#SYNTAX_SH
" For options and settings, please use:      :help ft-sh-syntax
" This file includes many ideas from ?ric Brunet (eric.brunet@ens.fr)

" For version 5.x: Clear all syntax items {{{1
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" AFAICT "." should be considered part of the iskeyword.  Using iskeywords in
" syntax is dicey, so the following code permits the user to prevent/override
"  g:sh_isk set to a string	: specify iskeyword.
"  g:sh_noisk exists	: don't change iskeyword
"  g:sh_noisk does not exist	: (default) append "." to iskeyword
if exists("g:sh_isk") && type(g:sh_isk) == 1	" user specifying iskeyword
 exe "setl isk=".g:sh_isk
elseif !exists("g:sh_noisk")		" optionally prevent appending '.' to iskeyword
 setl isk+=.
endif

" trying to answer the question: which shell is /bin/sh, really?
" If the user has not specified any of g:is_kornshell, g:is_bash, g:is_posix, g:is_sh, then guess.
if !exists("g:is_kornshell") && !exists("g:is_bash") && !exists("g:is_posix") && !exists("g:is_sh")
 let s:shell = ""
 if executable("/bin/sh")
  let s:shell = resolve("/bin/sh")
 elseif executable("/usr/bin/sh")
  let s:shell = resolve("/usr/bin/sh")
 endif
 if     s:shell =~ 'bash$'
  let g:is_bash= 1
 elseif s:shell =~ 'ksh$'
  let g:is_kornshell = 1
 elseif s:shell =~ 'dash$'
  let g:is_posix = 1
 endif
 unlet s:shell
endif

" handling /bin/sh with is_kornshell/is_sh {{{1
" b:is_sh is set when "#! /bin/sh" is found;
" However, it often is just a masquerade by bash (typically Linux)
" or kornshell (typically workstations with Posix "sh").
" So, when the user sets "g:is_bash", "g:is_kornshell",
" or "g:is_posix", a b:is_sh is converted into b:is_bash/b:is_kornshell,
" respectively.
if !exists("b:is_kornshell") && !exists("b:is_bash")
  if exists("g:is_posix") && !exists("g:is_kornshell")
   let g:is_kornshell= g:is_posix
  endif
  if exists("g:is_kornshell")
    let b:is_kornshell= 1
    if exists("b:is_sh")
      unlet b:is_sh
    endif
  elseif exists("g:is_bash")
    let b:is_bash= 1
    if exists("b:is_sh")
      unlet b:is_sh
    endif
  else
    let b:is_sh= 1
  endif
endif

" set up default g:sh_fold_enabled {{{1
if !exists("g:sh_fold_enabled")
 let g:sh_fold_enabled= 0
elseif g:sh_fold_enabled != 0 && !has("folding")
 let g:sh_fold_enabled= 0
 echomsg "Ignoring g:sh_fold_enabled=".g:sh_fold_enabled."; need to re-compile vim for +fold support"
endif
if !exists("s:sh_fold_functions")
 let s:sh_fold_functions= and(g:sh_fold_enabled,1)
endif
if !exists("s:sh_fold_heredoc")
 let s:sh_fold_heredoc  = and(g:sh_fold_enabled,2)
endif
if !exists("s:sh_fold_ifdofor")
 let s:sh_fold_ifdofor  = and(g:sh_fold_enabled,4)
endif
if g:sh_fold_enabled && &fdm == "manual"
 " Given that	the	user provided g:sh_fold_enabled
 " 	AND	g:sh_fold_enabled is manual (usual default)
 " 	implies	a desire for syntax-based folding
 setl fdm=syntax
endif

" sh syntax is case sensitive {{{1
syn case match

" Clusters: contains=@... clusters {{{1
"==================================
syn cluster shErrorList	contains=shDoError,shIfError,shInError,shCaseError,shEsacError,shCurlyError,shParenError,shTestError,shOK
if exists("b:is_kornshell")
 syn cluster ErrorList add=shDTestError
endif
syn cluster shArithParenList	contains=shArithmetic,shCaseEsac,shComment,shDeref,shDo,shDerefSimple,shEcho,shEscape,shNumber,shOperator,shPosnParm,shExSingleQuote,shExDoubleQuote,shRedir,shSingleQuote,shDoubleQuote,shStatement,shVariable,shAlias,shTest,shCtrlSeq,shSpecial,shParen,bashSpecialVariables,bashStatement,shIf,shFor
syn cluster shArithList	contains=@shArithParenList,shParenError
syn cluster shCaseEsacList	contains=shCaseStart,shCase,shCaseBar,shCaseIn,shComment,shDeref,shDerefSimple,shCaseCommandSub,shCaseExSingleQuote,shCaseSingleQuote,shCaseDoubleQuote,shCtrlSeq,@shErrorList,shStringSpecial,shCaseRange
syn cluster shCaseList	contains=@shCommandSubList,shCaseEsac,shColon,shCommandSub,shComment,shDo,shEcho,shExpr,shFor,shHereDoc,shIf,shRedir,shSetList,shSource,shStatement,shVariable,shCtrlSeq
"syn cluster shColonList	contains=@shCaseList
syn cluster shCommandSubList	contains=shArithmetic,shDeref,shDerefSimple,shEcho,shEscape,shNumber,shOption,shPosnParm,shExSingleQuote,shSingleQuote,shExDoubleQuote,shDoubleQuote,shStatement,shVariable,shSubSh,shAlias,shTest,shCtrlSeq,shSpecial,shCmdParenRegion
syn cluster shCurlyList	contains=shNumber,shComma,shDeref,shDerefSimple,shDerefSpecial
syn cluster shDblQuoteList	contains=shCommandSub,shDeref,shDerefSimple,shEscape,shPosnParm,shCtrlSeq,shSpecial
syn cluster shDerefList	contains=shDeref,shDerefSimple,shDerefVar,shDerefSpecial,shDerefWordError,shDerefPPS
syn cluster shDerefVarList	contains=shDerefOp,shDerefVarArray,shDerefOpError
syn cluster shEchoList	contains=shArithmetic,shCommandSub,shDeref,shDerefSimple,shEscape,shExpr,shExSingleQuote,shExDoubleQuote,shSingleQuote,shDoubleQuote,shCtrlSeq,shEchoQuote
syn cluster shExprList1	contains=shCharClass,shNumber,shOperator,shExSingleQuote,shExDoubleQuote,shSingleQuote,shDoubleQuote,shExpr,shDblBrace,shDeref,shDerefSimple,shCtrlSeq
syn cluster shExprList2	contains=@shExprList1,@shCaseList,shTest
syn cluster shFunctionList	contains=@shCommandSubList,shCaseEsac,shColon,shCommandSub,shComment,shDo,shEcho,shExpr,shFor,shHereDoc,shIf,shOption,shRedir,shSetList,shSource,shStatement,shVariable,shOperator,shCtrlSeq
if exists("b:is_kornshell") || exists("b:is_bash")
 syn cluster shFunctionList	add=shRepeat
 syn cluster shFunctionList	add=shDblBrace,shDblParen
endif
syn cluster shHereBeginList	contains=@shCommandSubList
syn cluster shHereList	contains=shBeginHere,shHerePayload
syn cluster shHereListDQ	contains=shBeginHere,@shDblQuoteList,shHerePayload
syn cluster shIdList	contains=shCommandSub,shWrapLineOperator,shSetOption,shDeref,shDerefSimple,shRedir,shExSingleQuote,shExDoubleQuote,shSingleQuote,shDoubleQuote,shExpr,shCtrlSeq,shStringSpecial,shAtExpr
syn cluster shIfList	contains=@shLoopList,shDblBrace,shDblParen,shFunctionKey,shFunctionOne,shFunctionTwo
syn cluster shLoopList	contains=@shCaseLis,t@shErrorList,shCaseEsac,shConditional,shDblBrace,shExpr,shFor,shForPP,shIf,shOption,shSet,shTest,shTestOpr
syn cluster shSubShList	contains=@shCommandSubList,shCaseEsac,shColon,shCommandSub,shComment,shDo,shEcho,shExpr,shFor,shIf,shRedir,shSetList,shSource,shStatement,shVariable,shCtrlSeq,shOperator
syn cluster shTestList	contains=shCharClass,shCommandSub,shComment,shCtrlSeq,shDeref,shDerefSimple,shDoubleQuote,shExDoubleQuote,shExpr,shExSingleQuote,shNumber,shOperator,shSingleQuote,shTest,shTestOpr
" Echo: {{{1
" ====
" This one is needed INSIDE a CommandSub, so that `echo bla` be correct
syn region shEcho matchgroup=shStatement start="\<echo\>"  skip="\\$" matchgroup=shEchoDelim end="$" matchgroup=NONE end="[<>;&|()`]"me=e-1 end="\d[<>]"me=e-2 end="\s#"me=e-2 contains=@shEchoList skipwhite nextgroup=shQuickComment
syn region shEcho matchgroup=shStatement start="\<print\>" skip="\\$" matchgroup=shEchoDelim end="$" matchgroup=NONE end="[<>;&|()`]"me=e-1 end="\d[<>]"me=e-2 end="\s#"me=e-2 contains=@shEchoList skipwhite nextgroup=shQuickComment
syn match  shEchoQuote contained	'\%(\\\\\)*\\["`'()]'

" This must be after the strings, so that ... \" will be correct
syn region shEmbeddedEcho contained matchgroup=shStatement start="\<print\>" skip="\\$" matchgroup=shEchoDelim end="$" matchgroup=NONE end="[<>;&|`)]"me=e-1 end="\d[<>]"me=e-2 end="\s#"me=e-2 contains=shNumber,shExSingleQuote,shSingleQuote,shDeref,shDerefSimple,shSpecialVar,shOperator,shExDoubleQuote,shDoubleQuote,shCharClass,shCtrlSeq

" Alias: {{{1
" =====
if exists("b:is_kornshell") || exists("b:is_bash")
 syn match shStatement "\<alias\>"
 syn region shAlias matchgroup=shStatement start="\<alias\>\s\+\(\h[-._[:alnum:]]\+\)\@="  skip="\\$" end="\>\|`"
 syn region shAlias matchgroup=shStatement start="\<alias\>\s\+\(\h[-._[:alnum:]]\+=\)\@=" skip="\\$" end="="
endif

" Error Codes: {{{1
" ============
if !exists("g:sh_no_error")
 syn match   shDoError "\<done\>"
 syn match   shIfError "\<fi\>"
 syn match   shInError "\<in\>"
 syn match   shCaseError ";;"
 syn match   shEsacError "\<esac\>"
 syn match   shCurlyError "}"
 syn match   shParenError ")"
 syn match   shOK	'\.\(done\|fi\|in\|esac\)'
 if exists("b:is_kornshell")
  syn match     shDTestError "]]"
 endif
 syn match     shTestError "]"
endif

" Options: {{{1
" ====================
syn match   shOption	"\s\zs[-+][-_a-zA-Z0-9#]\+"
syn match   shOption	"\s\zs--[^ \t$`'"|);]\+"

" File Redirection Highlighted As Operators: {{{1
"===========================================
syn match      shRedir	"\d\=>\(&[-0-9]\)\="
syn match      shRedir	"\d\=>>-\="
syn match      shRedir	"\d\=<\(&[-0-9]\)\="
syn match      shRedir	"\d<<-\="

" Operators: {{{1
" ==========
syn match   shOperator	"<<\|>>"		contained
syn match   shOperator	"[!&;|]"		contained
syn match   shOperator	"\[[[^:]\|\]]"		contained
syn match   shOperator	"!\=="		skipwhite nextgroup=shPattern
syn match   shPattern	"\<\S\+\())\)\@="	contained contains=shExSingleQuote,shSingleQuote,shExDoubleQuote,shDoubleQuote,shDeref

" Subshells: {{{1
" ==========
syn region shExpr  transparent matchgroup=shExprRegion  start="{" end="}"		contains=@shExprList2 nextgroup=shMoreSpecial
syn region shSubSh transparent matchgroup=shSubShRegion start="[^(]\zs(" end=")"	contains=@shSubShList nextgroup=shMoreSpecial

" Tests: {{{1
"=======
syn region shExpr	matchgroup=shRange start="\[" skip=+\\\\\|\\$\|\[+ end="\]" contains=@shTestList,shSpecial
syn region shTest	transparent matchgroup=shStatement start="\<test\s" skip=+\\\\\|\\$+ matchgroup=NONE end="[;&|]"me=e-1 end="$" contains=@shExprList1
syn match  shTestOpr	contained	"<=\|>=\|!=\|==\|-.\>\|-\(nt\|ot\|ef\|eq\|ne\|lt\|le\|gt\|ge\)\>\|[!<>]"
syn match  shTestOpr	contained	'=' skipwhite nextgroup=shTestDoubleQuote,shTestSingleQuote,shTestPattern
syn match  shTestPattern	contained	'\w\+'
syn region shTestDoubleQuote	contained	start='\%(\%(\\\\\)*\\\)\@<!"' skip=+\\\\\|\\"+ end='"'
syn match  shTestSingleQuote	contained	'\\.'
syn match  shTestSingleQuote	contained	"'[^']*'"
if exists("b:is_kornshell") || exists("b:is_bash")
 syn region  shDblBrace matchgroup=Delimiter start="\[\[" skip=+\\\\\|\\$+ end="\]\]"	contains=@shTestList,shComment
 syn region  shDblParen matchgroup=Delimiter start="((" skip=+\\\\\|\\$+ end="))"	contains=@shTestList,shComment
endif

" Character Class In Range: {{{1
" =========================
syn match   shCharClass	contained	"\[:\(backspace\|escape\|return\|xdigit\|alnum\|alpha\|blank\|cntrl\|digit\|graph\|lower\|print\|punct\|space\|upper\|tab\):\]"

" Loops: do, if, while, until {{{1
" ======
if s:sh_fold_ifdofor
 syn region shDo	fold transparent matchgroup=shConditional start="\<do\>" matchgroup=shConditional end="\<done\>"			contains=@shLoopList
 syn region shIf	fold transparent matchgroup=shConditional start="\<if\_s" matchgroup=shConditional skip=+-fi\>+ end="\<;\_s*then\>" end="\<fi\>"	contains=@shIfList
 syn region shFor	fold matchgroup=shLoop start="\<for\ze\_s\s*\%(((\)\@!" end="\<in\_s" end="\<do\>"me=e-2				contains=@shLoopList,shDblParen skipwhite nextgroup=shCurlyIn
 syn region shForPP	fold matchgroup=shLoop start='\<for\>\_s*((' end='))' contains=shTestOpr
else
 syn region shDo	transparent matchgroup=shConditional start="\<do\>" matchgroup=shConditional end="\<done\>"			contains=@shLoopList
 syn region shIf	transparent matchgroup=shConditional start="\<if\_s" matchgroup=shConditional skip=+-fi\>+ end="\<;\_s*then\>" end="\<fi\>"	contains=@shIfList
 syn region shFor	matchgroup=shLoop start="\<for\ze\_s\s*\%(((\)\@!" end="\<in\>" end="\<do\>"me=e-2			contains=@shLoopList,shDblParen skipwhite nextgroup=shCurlyIn
 syn region shForPP	matchgroup=shLoop start='\<for\>\_s*((' end='))' contains=shTestOpr
endif
if exists("b:is_kornshell") || exists("b:is_bash")
 syn cluster shCaseList	add=shRepeat
 syn cluster shFunctionList	add=shRepeat
 syn region shRepeat   matchgroup=shLoop   start="\<while\_s" end="\<in\_s" end="\<do\>"me=e-2	contains=@shLoopList,shDblParen,shDblBrace
 syn region shRepeat   matchgroup=shLoop   start="\<until\_s" end="\<in\_s" end="\<do\>"me=e-2	contains=@shLoopList,shDblParen,shDblBrace
 syn region shCaseEsac matchgroup=shConditional start="\<select\s" matchgroup=shConditional end="\<in\>" end="\<do\>" contains=@shLoopList
else
 syn region shRepeat   matchgroup=shLoop   start="\<while\_s" end="\<do\>"me=e-2		contains=@shLoopList
 syn region shRepeat   matchgroup=shLoop   start="\<until\_s" end="\<do\>"me=e-2		contains=@shLoopList
endif
syn region shCurlyIn   contained	matchgroup=Delimiter start="{" end="}" contains=@shCurlyList
syn match  shComma     contained	","

" Case: case...esac {{{1
" ====
syn match   shCaseBar	contained skipwhite "\(^\|[^\\]\)\(\\\\\)*\zs|"		nextgroup=shCase,shCaseStart,shCaseBar,shComment,shCaseExSingleQuote,shCaseSingleQuote,shCaseDoubleQuote
syn match   shCaseStart	contained skipwhite skipnl "("			nextgroup=shCase,shCaseBar
if s:sh_fold_ifdofor
 syn region  shCase	fold contained skipwhite skipnl matchgroup=shSnglCase start="\%(\\.\|[^#$()'" \t]\)\{-}\zs)"  end=";;" end="esac"me=s-1 contains=@shCaseList nextgroup=shCaseStart,shCase,shComment
 syn region  shCaseEsac	fold matchgroup=shConditional start="\<case\>" end="\<esac\>"	contains=@shCaseEsacList
else
 syn region  shCase	contained skipwhite skipnl matchgroup=shSnglCase start="\%(\\.\|[^#$()'" \t]\)\{-}\zs)"  end=";;" end="esac"me=s-1 contains=@shCaseList nextgroup=shCaseStart,shCase,shComment
 syn region  shCaseEsac	matchgroup=shConditional start="\<case\>" end="\<esac\>"	contains=@shCaseEsacList
endif
syn keyword shCaseIn	contained skipwhite skipnl in			nextgroup=shCase,shCaseStart,shCaseBar,shComment,shCaseExSingleQuote,shCaseSingleQuote,shCaseDoubleQuote
if exists("b:is_bash")
 syn region  shCaseExSingleQuote	matchgroup=shQuote start=+\$'+ skip=+\\\\\|\\.+ end=+'+	contains=shStringSpecial,shSpecial	skipwhite skipnl nextgroup=shCaseBar	contained
elseif !exists("g:sh_no_error")
 syn region  shCaseExSingleQuote	matchgroup=Error start=+\$'+ skip=+\\\\\|\\.+ end=+'+	contains=shStringSpecial	skipwhite skipnl nextgroup=shCaseBar	contained
endif
syn region  shCaseSingleQuote	matchgroup=shQuote start=+'+ end=+'+		contains=shStringSpecial		skipwhite skipnl nextgroup=shCaseBar	contained
syn region  shCaseDoubleQuote	matchgroup=shQuote start=+"+ skip=+\\\\\|\\.+ end=+"+	contains=@shDblQuoteList,shStringSpecial	skipwhite skipnl nextgroup=shCaseBar	contained
syn region  shCaseCommandSub	start=+`+ skip=+\\\\\|\\.+ end=+`+		contains=@shCommandSubList		skipwhite skipnl nextgroup=shCaseBar	contained
if exists("b:is_bash")
 syn region  shCaseRange	matchgroup=Delimiter start=+\[+ skip=+\\\\+ end=+\]+	contained	contains=shCharClass
 syn match   shCharClass	'\[:\%(alnum\|alpha\|ascii\|blank\|cntrl\|digit\|graph\|lower\|print\|punct\|space\|upper\|word\|or\|xdigit\):\]'			contained
else
 syn region  shCaseRange	matchgroup=Delimiter start=+\[+ skip=+\\\\+ end=+\]+	contained
endif
" Misc: {{{1
"======
syn match   shWrapLineOperator "\\$"
syn region  shCommandSub   start="`" skip="\\\\\|\\." end="`"	contains=@shCommandSubList
syn match   shEscape	contained	'\%(^\)\@!\%(\\\\\)*\\.'

" $() and $(()): {{{1
" $(..) is not supported by sh (Bourne shell).  However, apparently
" some systems (HP?) have as their /bin/sh a (link to) Korn shell
" (ie. Posix compliant shell).  /bin/ksh should work for those
" systems too, however, so the following syntax will flag $(..) as
" an Error under /bin/sh.  By consensus of vimdev'ers!
if exists("b:is_kornshell") || exists("b:is_bash")
 syn region shCommandSub matchgroup=shCmdSubRegion start="\$("  skip='\\\\\|\\.' end=")"  contains=@shCommandSubList
 syn region shArithmetic matchgroup=shArithRegion  start="\$((" skip='\\\\\|\\.' end="))" contains=@shArithList
 syn region shArithmetic matchgroup=shArithRegion  start="\$\[" skip='\\\\\|\\.' end="\]" contains=@shArithList
 syn match  shSkipInitWS contained	"^\s\+"
elseif !exists("g:sh_no_error")
 syn region shCommandSub matchgroup=Error start="\$(" end=")" contains=@shCommandSubList
endif
syn region shCmdParenRegion matchgroup=shCmdSubRegion start="(\ze[^(]" skip='\\\\\|\\.' end=")" contains=@shCommandSubList

if exists("b:is_bash")
 syn cluster shCommandSubList add=bashSpecialVariables,bashStatement
 syn cluster shCaseList add=bashAdminStatement,bashStatement
 syn keyword bashSpecialVariables contained auto_resume BASH BASH_ALIASES BASH_ALIASES BASH_ARGC BASH_ARGC BASH_ARGV BASH_ARGV BASH_CMDS BASH_CMDS BASH_COMMAND BASH_COMMAND BASH_ENV BASH_EXECUTION_STRING BASH_EXECUTION_STRING BASH_LINENO BASH_LINENO BASHOPTS BASHOPTS BASHPID BASHPID BASH_REMATCH BASH_REMATCH BASH_SOURCE BASH_SOURCE BASH_SUBSHELL BASH_SUBSHELL BASH_VERSINFO BASH_VERSION BASH_XTRACEFD BASH_XTRACEFD CDPATH COLUMNS COLUMNS COMP_CWORD COMP_CWORD COMP_KEY COMP_KEY COMP_LINE COMP_LINE COMP_POINT COMP_POINT COMPREPLY COMPREPLY COMP_TYPE COMP_TYPE COMP_WORDBREAKS COMP_WORDBREAKS COMP_WORDS COMP_WORDS COPROC COPROC DIRSTACK EMACS EMACS ENV ENV EUID FCEDIT FIGNORE FUNCNAME FUNCNAME FUNCNEST FUNCNEST GLOBIGNORE GROUPS histchars HISTCMD HISTCONTROL HISTFILE HISTFILESIZE HISTIGNORE HISTSIZE HISTTIMEFORMAT HISTTIMEFORMAT HOME HOSTFILE HOSTNAME HOSTTYPE IFS IGNOREEOF INPUTRC LANG LC_ALL LC_COLLATE LC_CTYPE LC_CTYPE LC_MESSAGES LC_NUMERIC LC_NUMERIC LINENO LINES LINES MACHTYPE MAIL MAILCHECK MAILPATH MAPFILE MAPFILE OLDPWD OPTARG OPTERR OPTIND OSTYPE PATH PIPESTATUS POSIXLY_CORRECT POSIXLY_CORRECT PPID PROMPT_COMMAND PS1 PS2 PS3 PS4 PWD RANDOM READLINE_LINE READLINE_LINE READLINE_POINT READLINE_POINT REPLY SECONDS SHELL SHELL SHELLOPTS SHLVL TIMEFORMAT TIMEOUT TMPDIR TMPDIR UID
 syn keyword bashStatement chmod clear complete du egrep expr fgrep find gnufind gnugrep grep less ls mkdir mv rm rmdir rpm sed sleep sort strip tail touch
 syn keyword bashAdminStatement daemon killall killproc nice reload restart start status stop
 syn keyword bashStatement	command compgen
endif

if exists("b:is_kornshell")
 syn cluster shCommandSubList add=kshSpecialVariables,kshStatement
 syn cluster shCaseList add=kshStatement
 syn keyword kshSpecialVariables contained CDPATH COLUMNS EDITOR ENV ERRNO FCEDIT FPATH HISTFILE HISTSIZE HOME IFS LINENO LINES MAIL MAILCHECK MAILPATH OLDPWD OPTARG OPTIND PATH PPID PS1 PS2 PS3 PS4 PWD RANDOM REPLY SECONDS SHELL TMOUT VISUAL
 syn keyword kshStatement cat chmod clear cp du egrep expr fgrep find grep killall less ls mkdir mv nice printenv rm rmdir sed sort strip stty tail touch tput
 syn keyword kshStatement command setgroups setsenv
endif

syn match   shSource	"^\.\s"
syn match   shSource	"\s\.\s"
"syn region  shColon	start="^\s*:" end="$" end="\s#"me=e-2 contains=@shColonList
"syn region  shColon	start="^\s*\zs:" end="$" end="\s#"me=e-2
syn match   shColon	'^\s*\zs:'

" String And Character Constants: {{{1
"================================
syn match   shNumber	"-\=\<\d\+\>#\="
syn match   shCtrlSeq	"\\\d\d\d\|\\[abcfnrtv0]"		contained
if exists("b:is_bash")
 syn match   shSpecial	"\\\o\o\o\|\\x\x\x\|\\c[^"]\|\\[abefnrtv]"	contained
endif
if exists("b:is_bash")
 syn region  shExSingleQuote	matchgroup=shQuote start=+\$'+ skip=+\\\\\|\\.+ end=+'+	contains=shStringSpecial,shSpecial
 syn region  shExDoubleQuote	matchgroup=shQuote start=+\$"+ skip=+\\\\\|\\.\|\\"+ end=+"+	contains=@shDblQuoteList,shStringSpecial,shSpecial
elseif !exists("g:sh_no_error")
 syn region  shExSingleQuote	matchGroup=Error start=+\$'+ skip=+\\\\\|\\.+ end=+'+	contains=shStringSpecial
 syn region  shExDoubleQuote	matchGroup=Error start=+\$"+ skip=+\\\\\|\\.+ end=+"+	contains=shStringSpecial
endif
syn region  shSingleQuote	matchgroup=shQuote start=+'+ end=+'+		contains=@Spell
syn region  shDoubleQuote	matchgroup=shQuote start=+\%(\%(\\\\\)*\\\)\@<!"+ skip=+\\"+ end=+"+	contains=@shDblQuoteList,shStringSpecial,@Spell
"syn region  shDoubleQuote	matchgroup=shQuote start=+"+ skip=+\\"+ end=+"+	contains=@shDblQuoteList,shStringSpecial,@Spell
syn match   shStringSpecial	"[^[:print:] \t]"	contained
syn match   shStringSpecial	"\%(\\\\\)*\\[\\"'`$()#]"
syn match   shSpecial	"[^\\]\zs\%(\\\\\)*\\[\\"'`$()#]" nextgroup=shMoreSpecial,shComment
syn match   shSpecial	"^\%(\\\\\)*\\[\\"'`$()#]"	nextgroup=shComment
syn match   shMoreSpecial	"\%(\\\\\)*\\[\\"'`$()#]" nextgroup=shMoreSpecial contained

" Comments: {{{1
"==========
syn cluster	shCommentGroup	contains=shTodo,@Spell
syn keyword	shTodo	contained		COMBAK FIXME TODO XXX
syn match	shComment		"^\s*\zs#.*$"	contains=@shCommentGroup
syn match	shComment		"\s\zs#.*$"	contains=@shCommentGroup
syn match	shComment	contained	"#.*$"	contains=@shCommentGroup
syn match	shQuickComment	contained	"#.*$"

" Here Documents: {{{1
" =========================================
if version < 600
 syn region shHereDoc matchgroup=shRedir01 start="<<\s*\**END[a-zA-Z_0-9]*\**" 		matchgroup=shRedir01 end="^END[a-zA-Z_0-9]*$"	contains=@shDblQuoteList
 syn region shHereDoc matchgroup=shRedir02 start="<<-\s*\**END[a-zA-Z_0-9]*\**"		matchgroup=shRedir02 end="^\s*END[a-zA-Z_0-9]*$"	contains=@shDblQuoteList
 syn region shHereDoc matchgroup=shRedir03 start="<<\s*\**EOF\**"		matchgroup=shRedir03	end="^EOF$"	contains=@shDblQuoteList
 syn region shHereDoc matchgroup=shRedir04 start="<<-\s*\**EOF\**"		matchgroup=shRedir04	end="^\s*EOF$"	contains=@shDblQuoteList
 syn region shHereDoc matchgroup=shRedir05 start="<<\s*\**\.\**"		matchgroup=shRedir05	end="^\.$"	contains=@shDblQuoteList
 syn region shHereDoc matchgroup=shRedir06 start="<<-\s*\**\.\**"		matchgroup=shRedir06	end="^\s*\.$"	contains=@shDblQuoteList

elseif s:sh_fold_heredoc
 syn region shHereDoc matchgroup=shRedir07 fold start="<<\s*\z([^ \t|]*\)"		matchgroup=shRedir07 end="^\z1\s*$"	contains=@shDblQuoteList
 syn region shHereDoc matchgroup=shRedir08 fold start="<<\s*\"\z([^ \t|]*\)\""		matchgroup=shRedir08 end="^\z1\s*$"
 syn region shHereDoc matchgroup=shRedir09 fold start="<<\s*'\z([^ \t|]*\)'"		matchgroup=shRedir09 end="^\z1\s*$"
 syn region shHereDoc matchgroup=shRedir10 fold start="<<-\s*\z([^ \t|]*\)"		matchgroup=shRedir10 end="^\s*\z1\s*$"	contains=@shDblQuoteList
 syn region shHereDoc matchgroup=shRedir11 fold start="<<-\s*\"\z([^ \t|]*\)\""		matchgroup=shRedir11 end="^\s*\z1\s*$"
 syn region shHereDoc matchgroup=shRedir12 fold start="<<-\s*'\z([^ \t|]*\)'"		matchgroup=shRedir12 end="^\s*\z1\s*$"
 syn region shHereDoc matchgroup=shRedir13 fold start="<<\s*\\\_$\_s*\z([^ \t|]*\)"	matchgroup=shRedir13 end="^\z1\s*$"
 syn region shHereDoc matchgroup=shRedir14 fold start="<<\s*\\\_$\_s*\"\z([^ \t|]*\)\""	matchgroup=shRedir14 end="^\z1\s*$"
 syn region shHereDoc matchgroup=shRedir15 fold start="<<-\s*\\\_$\_s*'\z([^ \t|]*\)'"	matchgroup=shRedir15 end="^\s*\z1\s*$"
 syn region shHereDoc matchgroup=shRedir16 fold start="<<-\s*\\\_$\_s*\z([^ \t|]*\)"	matchgroup=shRedir16 end="^\s*\z1\s*$"
 syn region shHereDoc matchgroup=shRedir17 fold start="<<-\s*\\\_$\_s*\"\z([^ \t|]*\)\""	matchgroup=shRedir17 end="^\s*\z1\s*$"
 syn region shHereDoc matchgroup=shRedir18 fold start="<<\s*\\\_$\_s*'\z([^ \t|]*\)'"	matchgroup=shRedir18 end="^\z1\s*$"
 syn region shHereDoc matchgroup=shRedir19 fold start="<<\\\z([^ \t|]*\)"		matchgroup=shRedir19 end="^\z1\s*$"

else
 syn region shHereDoc matchgroup=shRedir20 start="<<\s*\\\=\z([^ \t|]*\)"		matchgroup=shRedir20 end="^\z1\s*$"    contains=@shDblQuoteList
 syn region shHereDoc matchgroup=shRedir21 start="<<\s*\"\z([^ \t|]*\)\""		matchgroup=shRedir21 end="^\z1\s*$"
 syn region shHereDoc matchgroup=shRedir22 start="<<-\s*\z([^ \t|]*\)"		matchgroup=shRedir22 end="^\s*\z1\s*$" contains=@shDblQuoteList
 syn region shHereDoc matchgroup=shRedir23 start="<<-\s*'\z([^ \t|]*\)'"		matchgroup=shRedir23 end="^\s*\z1\s*$"
 syn region shHereDoc matchgroup=shRedir24 start="<<\s*'\z([^ \t|]*\)'"		matchgroup=shRedir24 end="^\z1\s*$"
 syn region shHereDoc matchgroup=shRedir25 start="<<-\s*\"\z([^ \t|]*\)\""		matchgroup=shRedir25 end="^\s*\z1\s*$"
 syn region shHereDoc matchgroup=shRedir26 start="<<\s*\\\_$\_s*\z([^ \t|]*\)"		matchgroup=shRedir26 end="^\z1\s*$"
 syn region shHereDoc matchgroup=shRedir27 start="<<-\s*\\\_$\_s*\z([^ \t|]*\)"		matchgroup=shRedir27 end="^\s*\z1\s*$"
 syn region shHereDoc matchgroup=shRedir28 start="<<-\s*\\\_$\_s*'\z([^ \t|]*\)'"	matchgroup=shRedir28 end="^\s*\z1\s*$"
 syn region shHereDoc matchgroup=shRedir29 start="<<\s*\\\_$\_s*'\z([^ \t|]*\)'"	matchgroup=shRedir29 end="^\z1\s*$"
 syn region shHereDoc matchgroup=shRedir30 start="<<\s*\\\_$\_s*\"\z([^ \t|]*\)\""	matchgroup=shRedir30 end="^\z1\s*$"
 syn region shHereDoc matchgroup=shRedir31 start="<<-\s*\\\_$\_s*\"\z([^ \t|]*\)\""	matchgroup=shRedir31 end="^\s*\z1\s*$"
 syn region shHereDoc matchgroup=shRedir32 start="<<\\\z([^ \t|]*\)"		matchgroup=shRedir32 end="^\z1\s*$"
endif

" Here Strings: {{{1
" =============
" available for: bash; ksh (really should be ksh93 only) but not if its a posix
if exists("b:is_bash") || (exists("b:is_kornshell") && !exists("g:is_posix"))
 syn match shRedir "<<<"	skipwhite	nextgroup=shCmdParenRegion
endif

" Identifiers: {{{1
"=============
syn match  shSetOption	"\s\zs[-+][a-zA-Z0-9]\+\>"	contained
syn match  shVariable	"\<\([bwglsav]:\)\=[a-zA-Z0-9.!@_%+,]*\ze="	nextgroup=shSetIdentifier
syn match  shSetIdentifier	"="		contained	nextgroup=shCmdParenRegion,shPattern,shDeref,shDerefSimple,shDoubleQuote,shExDoubleQuote,shSingleQuote,shExSingleQuote
syn region shAtExpr	contained	start="@(" end=")" contains=@shIdList
if exists("b:is_bash")
 syn region shSetList oneline matchgroup=shSet start="\<\(declare\|typeset\|local\|export\|unset\)\>\ze[^/]" end="$"	matchgroup=shSetListDelim end="\ze[}|);&]" matchgroup=NONE end="\ze\s\+#\|="	contains=@shIdList
 syn region shSetList oneline matchgroup=shSet start="\<set\>\ze[^/]" end="\ze[;|)]\|$"			matchgroup=shSetListDelim end="\ze[}|);&]" matchgroup=NONE end="\ze\s\+="	contains=@shIdList
elseif exists("b:is_kornshell")
 syn region shSetList oneline matchgroup=shSet start="\<\(typeset\|export\|unset\)\>\ze[^/]" end="$"		matchgroup=shSetListDelim end="\ze[}|);&]" matchgroup=NONE end="\ze\s\+[#=]"	contains=@shIdList
 syn region shSetList oneline matchgroup=shSet start="\<set\>\ze[^/]" end="$"				matchgroup=shSetListDelim end="\ze[}|);&]" matchgroup=NONE end="\ze\s\+[#=]"	contains=@shIdList
else
 syn region shSetList oneline matchgroup=shSet start="\<\(set\|export\|unset\)\>\ze[^/]" end="$"		matchgroup=shSetListDelim end="\ze[}|);&]" matchgroup=NONE end="\ze\s\+[#=]"	contains=@shIdList
endif

" Functions: {{{1
if !exists("g:is_posix")
 syn keyword shFunctionKey function	skipwhite skipnl nextgroup=shFunctionTwo
endif

if exists("b:is_bash")
 if s:sh_fold_functions
  syn region shFunctionOne	fold	matchgroup=shFunction start="^\s*\h[-a-zA-Z_0-9]*\s*()\_s*{"	end="}"	contains=@shFunctionList			skipwhite skipnl nextgroup=shFunctionStart,shQuickComment
  syn region shFunctionTwo	fold	matchgroup=shFunction start="\h[-a-zA-Z_0-9]*\s*\%(()\)\=\_s*{"	end="}"	contains=shFunctionKey,@shFunctionList contained	skipwhite skipnl nextgroup=shFunctionStart,shQuickComment
  syn region shFunctionThree	fold	matchgroup=shFunction start="^\s*\h[-a-zA-Z_0-9]*\s*()\_s*("	end=")"	contains=@shFunctionList			skipwhite skipnl nextgroup=shFunctionStart,shQuickComment
  syn region shFunctionFour	fold	matchgroup=shFunction start="\h[-a-zA-Z_0-9]*\s*\%(()\)\=\_s*)"	end=")"	contains=shFunctionKey,@shFunctionList contained	skipwhite skipnl nextgroup=shFunctionStart,shQuickComment
 else
  syn region shFunctionOne		matchgroup=shFunction start="^\s*\h[-a-zA-Z_0-9]*\s*()\_s*{"	end="}"	contains=@shFunctionList
  syn region shFunctionTwo		matchgroup=shFunction start="\h[-a-zA-Z_0-9]*\s*\%(()\)\=\_s*{"	end="}"	contains=shFunctionKey,@shFunctionList contained
  syn region shFunctionThree		matchgroup=shFunction start="^\s*\h[-a-zA-Z_0-9]*\s*()\_s*("	end=")"	contains=@shFunctionList
  syn region shFunctionFour		matchgroup=shFunction start="\h[-a-zA-Z_0-9]*\s*\%(()\)\=\_s*("	end=")"	contains=shFunctionKey,@shFunctionList contained
 endif
else
 if s:sh_fold_functions
  syn region shFunctionOne	fold	matchgroup=shFunction start="^\s*\h\w*\s*()\_s*{"	end="}"	contains=@shFunctionList	       skipwhite skipnl		nextgroup=shFunctionStart,shQuickComment
  syn region shFunctionTwo	fold	matchgroup=shFunction start="\h\w*\s*\%(()\)\=\_s*{"	end="}"	contains=shFunctionKey,@shFunctionList contained skipwhite skipnl	nextgroup=shFunctionStart,shQuickComment
  syn region shFunctionThree	fold	matchgroup=shFunction start="^\s*\h\w*\s*()\_s*("	end=")"	contains=@shFunctionList	       skipwhite skipnl		nextgroup=shFunctionStart,shQuickComment
  syn region shFunctionFour	fold	matchgroup=shFunction start="\h\w*\s*\%(()\)\=\_s*("	end=")"	contains=shFunctionKey,@shFunctionList contained skipwhite skipnl	nextgroup=shFunctionStart,shQuickComment
 else
  syn region shFunctionOne		matchgroup=shFunction start="^\s*\h\w*\s*()\_s*{"	end="}"	contains=@shFunctionList
  syn region shFunctionTwo		matchgroup=shFunction start="\h\w*\s*\%(()\)\=\_s*{"	end="}"	contains=shFunctionKey,@shFunctionList contained
  syn region shFunctionThree		matchgroup=shFunction start="^\s*\h\w*\s*()\_s*("	end=")"	contains=@shFunctionList
  syn region shFunctionFour		matchgroup=shFunction start="\h\w*\s*\%(()\)\=\_s*("	end=")"	contains=shFunctionKey,@shFunctionList contained
 endif
endif

" Parameter Dereferencing: {{{1
" ========================
syn match  shDerefSimple	"\$\%(\k\+\|\d\)"
syn region shDeref	matchgroup=PreProc start="\${" end="}"	contains=@shDerefList,shDerefVarArray
if !exists("g:sh_no_error")
 syn match  shDerefWordError	"[^}$[]"	contained
endif
syn match  shDerefSimple	"\$[-#*@!?]"
syn match  shDerefSimple	"\$\$"
if exists("b:is_bash") || exists("b:is_kornshell")
 syn region shDeref	matchgroup=PreProc start="\${##\=" end="}"	contains=@shDerefList
 syn region shDeref	matchgroup=PreProc start="\${\$\$" end="}"	contains=@shDerefList
endif

" bash: ${!prefix*} and ${#parameter}: {{{1
" ====================================
if exists("b:is_bash")
 syn region shDeref	matchgroup=PreProc start="\${!" end="\*\=}"	contains=@shDerefList,shDerefOp
 syn match  shDerefVar	contained	"{\@<=!\k\+"		nextgroup=@shDerefVarList
endif

syn match  shDerefSpecial	contained	"{\@<=[-*@?0]"		nextgroup=shDerefOp,shDerefOpError
syn match  shDerefSpecial	contained	"\({[#!]\)\@<=[[:alnum:]*@_]\+"	nextgroup=@shDerefVarList,shDerefOp
syn match  shDerefVar	contained	"{\@<=\k\+"		nextgroup=@shDerefVarList

" sh ksh bash : ${var[... ]...}  array reference: {{{1
syn region  shDerefVarArray   contained	matchgroup=shDeref start="\[" end="]"	contains=@shCommandSubList nextgroup=shDerefOp,shDerefOpError

" Special ${parameter OPERATOR word} handling: {{{1
" sh ksh bash : ${parameter:-word}    word is default value
" sh ksh bash : ${parameter:=word}    assign word as default value
" sh ksh bash : ${parameter:?word}    display word if parameter is null
" sh ksh bash : ${parameter:+word}    use word if parameter is not null, otherwise nothing
"    ksh bash : ${parameter#pattern}  remove small left  pattern
"    ksh bash : ${parameter##pattern} remove large left  pattern
"    ksh bash : ${parameter%pattern}  remove small right pattern
"    ksh bash : ${parameter%%pattern} remove large right pattern
"        bash : ${parameter^pattern}  Case modification
"        bash : ${parameter^^pattern} Case modification
"        bash : ${parameter,pattern}  Case modification
"        bash : ${parameter,,pattern} Case modification
syn cluster shDerefPatternList	contains=shDerefPattern,shDerefString
if !exists("g:sh_no_error")
 syn match shDerefOpError	contained	":[[:punct:]]"
endif
syn match  shDerefOp	contained	":\=[-=?]"	nextgroup=@shDerefPatternList
syn match  shDerefOp	contained	":\=+"	nextgroup=@shDerefPatternList
if exists("b:is_bash") || exists("b:is_kornshell")
 syn match  shDerefOp	contained	"#\{1,2}"	nextgroup=@shDerefPatternList
 syn match  shDerefOp	contained	"%\{1,2}"	nextgroup=@shDerefPatternList
 syn match  shDerefPattern	contained	"[^{}]\+"	contains=shDeref,shDerefSimple,shDerefPattern,shDerefString,shCommandSub,shDerefEscape nextgroup=shDerefPattern
 syn region shDerefPattern	contained	start="{" end="}"	contains=shDeref,shDerefSimple,shDerefString,shCommandSub nextgroup=shDerefPattern
 syn match  shDerefEscape	contained	'\%(\\\\\)*\\.'
endif
if exists("b:is_bash")
 syn match  shDerefOp	contained	"[,^]\{1,2}"	nextgroup=@shDerefPatternList
endif
syn region shDerefString	contained	matchgroup=shDerefDelim start=+\%(\\\)\@<!'+ end=+'+		contains=shStringSpecial
syn region shDerefString	contained	matchgroup=shDerefDelim start=+\%(\\\)\@<!"+ skip=+\\"+ end=+"+	contains=@shDblQuoteList,shStringSpecial
syn match  shDerefString	contained	"\\["']"	nextgroup=shDerefPattern

if exists("b:is_bash")
 " bash : ${parameter:offset}
 " bash : ${parameter:offset:length}
 syn region shDerefOp	contained	start=":[$[:alnum:]_]"me=e-1 end=":"me=e-1 end="}"me=e-1 contains=@shCommandSubList nextgroup=shDerefPOL
 syn match  shDerefPOL	contained	":[^}]\+"	contains=@shCommandSubList

 " bash : ${parameter//pattern/string}
 " bash : ${parameter//pattern}
 syn match  shDerefPPS	contained	'/\{1,2}'	nextgroup=shDerefPPSleft
 syn region shDerefPPSleft	contained	start='.'	skip=@\%(\\\\\)*\\/@ matchgroup=shDerefOp	end='/' end='\ze}' nextgroup=shDerefPPSright contains=@shCommandSubList
 syn region shDerefPPSright	contained	start='.'	skip=@\%(\\\\\)\+@		end='\ze}'	contains=@shCommandSubList
endif

" Arithmetic Parenthesized Expressions: {{{1
"syn region shParen matchgroup=shArithRegion start='[^$]\zs(\%(\ze[^(]\|$\)' end=')' contains=@shArithParenList
syn region shParen matchgroup=shArithRegion start='\$\@!(\%(\ze[^(]\|$\)' end=')' contains=@shArithParenList

" Useful sh Keywords: {{{1
" ===================
syn keyword shStatement break cd chdir continue eval exec exit kill newgrp pwd read readonly return shift test trap ulimit umask wait
syn keyword shConditional contained elif else then
if !exists("g:sh_no_error")
 syn keyword shCondError elif else then
endif

" Useful ksh Keywords: {{{1
" ====================
if exists("b:is_kornshell") || exists("b:is_bash")
 syn keyword shStatement autoload bg false fc fg functions getopts hash history integer jobs let nohup printf r stop suspend times true type unalias whence
 if exists("g:is_posix")
  syn keyword shStatement command
 else
  syn keyword shStatement time
 endif

" Useful bash Keywords: {{{1
" =====================
 if exists("b:is_bash")
  syn keyword shStatement bind builtin dirs disown enable help local logout popd pushd shopt source
 else
  syn keyword shStatement login newgrp
 endif
endif

" Synchronization: {{{1
" ================
if !exists("sh_minlines")
  let sh_minlines = 200
endif
if !exists("sh_maxlines")
  let sh_maxlines = 2 * sh_minlines
endif
exec "syn sync minlines=" . sh_minlines . " maxlines=" . sh_maxlines
syn sync match shCaseEsacSync	grouphere	shCaseEsac	"\<case\>"
syn sync match shCaseEsacSync	groupthere	shCaseEsac	"\<esac\>"
syn sync match shDoSync	grouphere	shDo	"\<do\>"
syn sync match shDoSync	groupthere	shDo	"\<done\>"
syn sync match shForSync	grouphere	shFor	"\<for\>"
syn sync match shForSync	groupthere	shFor	"\<in\>"
syn sync match shIfSync	grouphere	shIf	"\<if\>"
syn sync match shIfSync	groupthere	shIf	"\<fi\>"
syn sync match shUntilSync	grouphere	shRepeat	"\<until\>"
syn sync match shWhileSync	grouphere	shRepeat	"\<while\>"

" Default Highlighting: {{{1
" =====================
hi def link shArithRegion	shShellVariables
hi def link shAtExpr	shSetList
hi def link shBeginHere	shRedir
hi def link shCaseBar	shConditional
hi def link shCaseCommandSub	shCommandSub
hi def link shCaseDoubleQuote	shDoubleQuote
hi def link shCaseIn	shConditional
hi def link shQuote	shOperator
hi def link shCaseSingleQuote	shSingleQuote
hi def link shCaseStart	shConditional
hi def link shCmdSubRegion	shShellVariables
hi def link shColon	shComment
hi def link shDerefOp	shOperator
hi def link shDerefPOL	shDerefOp
hi def link shDerefPPS	shDerefOp
hi def link shDeref	shShellVariables
hi def link shDerefDelim	shOperator
hi def link shDerefSimple	shDeref
hi def link shDerefSpecial	shDeref
hi def link shDerefString	shDoubleQuote
hi def link shDerefVar	shDeref
hi def link shDoubleQuote	shString
hi def link shEcho	shString
hi def link shEchoDelim	shOperator
hi def link shEchoQuote	shString
hi def link shForPP	shLoop
hi def link shEmbeddedEcho	shString
hi def link shEscape	shCommandSub
hi def link shExDoubleQuote	shDoubleQuote
hi def link shExSingleQuote	shSingleQuote
hi def link shFunction	Function
hi def link shHereDoc	shString
hi def link shHerePayload	shHereDoc
hi def link shLoop	shStatement
hi def link shMoreSpecial	shSpecial
hi def link shOption	shCommandSub
hi def link shPattern	shString
hi def link shParen	shArithmetic
hi def link shPosnParm	shShellVariables
hi def link shQuickComment	shComment
hi def link shRange	shOperator
hi def link shRedir	shOperator
hi def link shSetListDelim	shOperator
hi def link shSetOption	shOption
hi def link shSingleQuote	shString
hi def link shSource	shOperator
hi def link shStringSpecial	shSpecial
hi def link shSubShRegion	shOperator
hi def link shTestOpr	shConditional
hi def link shTestPattern	shString
hi def link shTestDoubleQuote	shString
hi def link shTestSingleQuote	shString
hi def link shVariable	shSetList
hi def link shWrapLineOperator	shOperator

if exists("b:is_bash")
  hi def link bashAdminStatement	shStatement
  hi def link bashSpecialVariables	shShellVariables
  hi def link bashStatement		shStatement
  hi def link shFunctionParen		Delimiter
  hi def link shFunctionDelim		Delimiter
  hi def link shCharClass		shSpecial
endif
if exists("b:is_kornshell")
  hi def link kshSpecialVariables	shShellVariables
  hi def link kshStatement		shStatement
  hi def link shFunctionParen		Delimiter
endif

if !exists("g:sh_no_error")
 hi def link shCaseError		Error
 hi def link shCondError		Error
 hi def link shCurlyError		Error
 hi def link shDerefError		Error
 hi def link shDerefOpError		Error
 hi def link shDerefWordError		Error
 hi def link shDoError		Error
 hi def link shEsacError		Error
 hi def link shIfError		Error
 hi def link shInError		Error
 hi def link shParenError		Error
 hi def link shTestError		Error
 if exists("b:is_kornshell")
   hi def link shDTestError		Error
 endif
endif

hi def link shArithmetic		Special
hi def link shCharClass		Identifier
hi def link shSnglCase		Statement
hi def link shCommandSub		Special
hi def link shComment		Comment
hi def link shConditional		Conditional
hi def link shCtrlSeq		Special
hi def link shExprRegion		Delimiter
hi def link shFunctionKey		Function
hi def link shFunctionName		Function
hi def link shNumber		Number
hi def link shOperator		Operator
hi def link shRepeat		Repeat
hi def link shSet		Statement
hi def link shSetList		Identifier
hi def link shShellVariables		PreProc
hi def link shSpecial		Special
hi def link shStatement		Statement
hi def link shString		String
hi def link shTodo		Todo
hi def link shAlias		Identifier
hi def link shRedir01		shRedir
hi def link shRedir02		shRedir
hi def link shRedir03		shRedir
hi def link shRedir04		shRedir
hi def link shRedir05		shRedir
hi def link shRedir06		shRedir
hi def link shRedir07		shRedir
hi def link shRedir08		shRedir
hi def link shRedir09		shRedir
hi def link shRedir10		shRedir
hi def link shRedir11		shRedir
hi def link shRedir12		shRedir
hi def link shRedir13		shRedir
hi def link shRedir14		shRedir
hi def link shRedir15		shRedir
hi def link shRedir16		shRedir
hi def link shRedir17		shRedir
hi def link shRedir18		shRedir
hi def link shRedir19		shRedir
hi def link shRedir20		shRedir
hi def link shRedir21		shRedir
hi def link shRedir22		shRedir
hi def link shRedir23		shRedir
hi def link shRedir24		shRedir
hi def link shRedir25		shRedir
hi def link shRedir26		shRedir
hi def link shRedir27		shRedir
hi def link shRedir28		shRedir
hi def link shRedir29		shRedir
hi def link shRedir30		shRedir
hi def link shRedir31		shRedir
hi def link shRedir32		shRedir

" Set Current Syntax: {{{1
" ===================
if exists("b:is_bash")
 let b:current_syntax = "bash"
elseif exists("b:is_kornshell")
 let b:current_syntax = "ksh"
else
 let b:current_syntax = "sh"
endif

" vim: ts=16 fdm=marker
