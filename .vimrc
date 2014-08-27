"      ___                       ___           ___           ___      
"     /\__\          ___        /\__\         /\  \         /\  \     
"    /:/  /         /\  \      /::|  |       /::\  \       /::\  \    
"   /:/  /          \:\  \    /:|:|  |      /:/\:\  \     /:/\:\  \   
"  /:/__/  ___      /::\__\  /:/|:|__|__   /::\~\:\  \   /:/  \:\  \  
"  |:|  | /\__\  __/:/\/__/ /:/ |::::\__\ /:/\:\ \:\__\ /:/__/ \:\__\ 
"  |:|  |/:/  / /\/:/  /    \/__/~~/:/  / \/_|::\/:/  / \:\  \  \/__/ 
"  |:|__/:/  /  \::/__/           /:/  /     |:|::/  /   \:\  \       
"   \::::/__/    \:\__\          /:/  /      |:|\/__/     \:\  \      
"    ~~~~         \/__/         /:/  /       |:|  |        \:\__\     
"                               \/__/         \|__|         \/__/     

" Coding Rules {{{
"==============================================================================
" Author:   <B4B4R07> BABAROT
" Contacts: <b4b4r07@gmail.com>
"
" - License
"  The MIT License (MIT)
"  
"  Copyright (c) 2014 B4B4R07
"  
"  Permission is hereby granted, free of charge, to any person obtaining a copy of
"  this software and associated documentation files (the "Software"), to deal in
"  the Software without restriction, including without limitation the rights to
"  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
"  of the Software, and to permit persons to whom the Software is furnished to do
"  so, subject to the following conditions:
"  
"  The above copyright notice and this permission notice shall be included in all
"  copies or substantial portions of the Software.
"  
"  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
"  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
"  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
"  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
"  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
"  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
"  SOFTWARE.
"}}}

" Initial: {{{1
"==============================================================================

" Skip initialization for vim-tiny or vim-small
if !1 | finish | endif

" Use plain vim
" when vim was invoked by 'sudo' command.
" or, invoked as 'git difftool'
if exists('$SUDO_USER') || exists('$GIT_DIR')
	finish
endif

" Only once execution when starting vim
if has('vim_starting')
	" Necesary for lots of cool vim things
	set nocompatible
	" Define entire file encoding
	scriptencoding utf-8

	" Vim starting time
	if has('reltime')
		let g:startuptime = reltime()
		augroup vimrc-startuptime
			autocmd! VimEnter * let g:startuptime = reltime(g:startuptime) | redraw
						\ | echomsg 'startuptime: ' . reltimestr(g:startuptime)
		augroup END
	endif
endif

" Use another vimrc for development
if getcwd() ==# expand('~/.vim/dev')
	let s:devfile = fnamemodify(findfile(".vimrc.dev", getcwd().";".expand("$HOME")), ":p")
	if filereadable(s:devfile)
		autocmd! VimEnter * execute 'source ' . s:devfile
					\ | echomsg "source '" . s:devfile . "'!"
		finish
	endif
endif

" Operating System
let g:is_windows = has('win16') || has('win32') || has('win64')
let g:is_cygwin = has('win32unix')
let g:is_mac = !g:is_windows && !g:is_cygwin
			\ && (has('mac') || has('macunix') || has('gui_macvim') ||
			\    (!executable('xdg-open') &&
			\    system('uname') =~? '^darwin'))
let g:is_unix = !g:is_mac && has('unix')

" Define neobundle runtimepath
if g:is_windows
	let $DOTVIM=expand('~/vimfiles')
else
	let $DOTVIM=expand('~/.vim')
endif
let $VIMBUNDLE=$DOTVIM . '/bundle'
let $NEOBUNDLEPATH=$VIMBUNDLE . '/neobundle.vim'

" Environment variable
let $MYVIMRC = expand('~/.vimrc')

" Enable/Disable {{{
let s:true  = 1
let s:false = 0

let s:enable_sujest_neobundleinit      = s:true
let s:enable_eof_to_bof                = s:true
let g:enable_auto_highlight_cursorline = s:false
let s:enable_save_window_position      = s:false
let g:enable_buftabs                   = s:true
let s:enable_restore_cursor_position   = s:true
"}}}

function! s:bundled(bundle) "{{{
	if !isdirectory($VIMBUNDLE)
		return 0
	endif
	if stridx(&runtimepath, $NEOBUNDLEPATH) == -1
		return 0
	endif

	if a:bundle ==# 'neobundle.vim'
		return 1
	else
		return neobundle#is_installed(a:bundle)
	endif
endfunction "}}}
"}}}1

" NeoBundle: {{{1
" No introduction.
"==============================================================================
filetype off

" Add neobundle to runtimepath
if has('vim_starting') && isdirectory($NEOBUNDLEPATH)
	set runtimepath+=$NEOBUNDLEPATH
endif

if s:bundled('neobundle.vim') "{{{
	let g:neobundle#enable_tail_path = 1
	let g:neobundle#default_options = {
				\ 'same' : { 'stay_same' : 1, 'overwrite' : 0 },
				\ '_' : { 'overwrite' : 0 },
				\ }
	call neobundle#rc($VIMBUNDLE)

	" Taking care of NeoBundle by itself
	NeoBundleFetch 'Shougo/neobundle.vim'

	" NeoBundle List
	NeoBundle 'Shougo/unite.vim'
	NeoBundle 'Shougo/vimproc', {
				\ 'build': {
				\ 'windows': 'make -f make_mingw32.mak',
				\ 'cygwin': 'make -f make_cygwin.mak',
				\ 'mac': 'make -f make_mac.mak',
				\ 'unix': 'make -f make_unix.mak',
				\ }}
	NeoBundle has('lua') ? 'Shougo/neocomplete' : 'Shougo/neocomplcache'
	NeoBundleLazy 'Shougo/vimshell', {
				\ 'autoload' : { 'commands' : [ 'VimShell', "VimShellPop", "VimShellInteractive" ] }
				\}
	NeoBundleLazy 'Shougo/unite-outline', {
				\ 'depends' : 'Shougo/unite.vim',
				\ 'autoload' : {
				\   'unite_sources' : 'outline' },
				\ }
	NeoBundleLazy 'Shougo/unite-help', { 'autoload' : {
				\ 'unite_sources' : 'help'
				\ }}
	NeoBundleLazy 'Shougo/neomru.vim', { 'autoload' : {
				\ 'unite_sources' : 'file_mru',
				\ }}
	NeoBundle 'Shougo/vimfiler'
	call neobundle#config('vimfiler', {
				\ 'lazy' : 1,
				\ 'depends' : 'Shougo/unite.vim',
				\ 'autoload' : {
				\    'commands' : [{ 'name' : 'VimFiler',
				\                    'complete' : 'customlist,vimfiler#complete' },
				\                  'VimFilerExplorer',
				\                  'Edit', 'Read', 'Source', 'Write'],
				\    'mappings' : ['<Plug>(vimfiler_switch)']
				\ }
				\ })
	NeoBundle 'Shougo/vimshell'
	call neobundle#config('vimshell', {
				\ 'lazy' : 1,
				\ 'autoload' : {
				\   'commands' : [{ 'name' : 'VimShell',
				\                   'complete' : 'customlist,vimshell#complete'},
				\                 'VimShellExecute', 'VimShellInteractive',
				\                 'VimShellTerminal', 'VimShellPop'],
				\   'mappings' : ['<Plug>(vimshell_switch)']
				\ }})
	NeoBundleLazy 'glidenote/memolist.vim', { 'autoload' : {
				\ 'commands' : ['MemoNew', 'MemoGrep']
				\ }}
	NeoBundleLazy 'thinca/vim-scouter', '', 'same', { 'autoload' : {
				\ 'commands' : 'Scouter'
				\ }}
	NeoBundleLazy 'thinca/vim-ref', { 'autoload' : {
				\ 'commands' : 'Ref'
				\ }}
	NeoBundle 'thinca/vim-quickrun'
	NeoBundle 'thinca/vim-unite-history', '', 'same'
	NeoBundle 'thinca/vim-splash'
	NeoBundle 'thinca/vim-portal'
	NeoBundle 'thinca/vim-poslist'
	NeoBundleLazy 'thinca/vim-qfreplace', '', 'same', { 'autoload' : {
				\ 'filetypes' : ['unite', 'quickfix'],
				\ }}
	NeoBundle 'tyru/nextfile.vim'
	NeoBundle 'tyru/skk.vim'
	NeoBundleLazy 'tyru/eskk.vim', { 'autoload' : {
				\ 'mappings' : [['i', '<Plug>(eskk:toggle)']],
				\ }}
	NeoBundleLazy 'tyru/open-browser.vim', '', 'same', { 'autoload' : {
				\ 'mappings' : '<Plug>(open-browser-wwwsearch)',
				\ }}
	NeoBundleLazy 'tyru/restart.vim', '', 'same', {
				\ 'gui' : 1,
				\ 'autoload' : {
				\  'commands' : 'Restart'
				\ }}
	NeoBundleLazy 'sjl/gundo.vim', '', 'same', { 'autoload' : {
				\ 'commands' : 'GundoToggle'
				\ }}
	NeoBundle 'ujihisa/neco-look'
	NeoBundleLazy 'ujihisa/unite-colorscheme', '', 'same'
	NeoBundle 'b4b4r07/mru.vim'
	NeoBundle 'b4b4r07/vim-autocdls'
	NeoBundle 'b4b4r07/vim-shellutils'
	NeoBundle 'nathanaelkane/vim-indent-guides'
	if !has('gui_running')
		"NeoBundle 'b4b4r07/buftabs'
		NeoBundle 'b4b4r07/vim-buftabs'
	endif
	if has('gui_running')
		NeoBundle 'itchyny/lightline.vim'
	endif
	NeoBundle 'scrooloose/syntastic'
	NeoBundle 'tpope/vim-surround'
	NeoBundle 'tpope/vim-repeat'
	NeoBundleLazy 'tpope/vim-markdown', { 'autoload' : {
				\ 'filetypes' : ['markdown'] }}
	NeoBundleLazy 'tpope/vim-fugitive', { 'autoload': {
				\ 'commands': ['Gcommit', 'Gblame', 'Ggrep', 'Gdiff'] }}
	NeoBundle 'osyo-manga/vim-anzu'
	NeoBundle 'LeafCage/yankround.vim'
	NeoBundle 'LeafCage/foldCC'
	NeoBundle 'junegunn/vim-easy-align'
	NeoBundle 'jiangmiao/auto-pairs'
	NeoBundleLazy 'mattn/gist-vim', {
				\ 'depends': ['mattn/webapi-vim' ],
				\ 'autoload' : {
				\   'commands' : 'Gist' }}
	NeoBundleLazy 'mattn/webapi-vim', {
				\ 'autoload' : {
				\   'function_prefix': 'webapi'
				\ }}
	NeoBundleLazy 'mattn/benchvimrc-vim', {
				\ 'autoload' : {
				\   'commands' : [
				\     'BenchVimrc'
				\   ]},
				\ }
	NeoBundle 'vim-scripts/Align'
	NeoBundle 'vim-scripts/FavEx'
	NeoBundleLazy 'DirDiff.vim', { 'autoload' : {
				\ 'commands' : 'DirDiff'
				\ }}
	NeoBundleLazy 'mattn/excitetranslate-vim', {
				\ 'depends': 'mattn/webapi-vim',
				\ 'autoload' : { 'commands': ['ExciteTranslate']}
				\ }
	NeoBundleLazy 'jnwhiteh/vim-golang',{
				\ "autoload" : {"filetypes" : ["go"]}
				\}
	NeoBundleLazy 'basyura/TweetVim', { 
				\'depends' : ['basyura/twibill.vim', 'tyru/open-browser.vim'],
				\ 'autoload' : { 'commands' : 'TweetVimHomeTimeline' }
				\ }
	NeoBundle 'kana/vim-gf-user'
	NeoBundle 'yomi322/unite-tweetvim'
	NeoBundle 'kien/ctrlp.vim'

	" Japanese help
	NeoBundle 'vim-jp/vimdoc-ja'

	" Colorscheme plugins
	NeoBundle 'b4b4r07/solarized.vim', { "base" : $HOME."/.vim/colors" }
	NeoBundle 'nanotech/jellybeans.vim', { "base" : $HOME."/.vim/colors" }
	NeoBundle 'tomasr/molokai', { "base" : $HOME."/.vim/colors" }
	NeoBundle 'w0ng/vim-hybrid', { "base" : $HOME."/.vim/colors" }

	" Disable plugins
	if g:enable_buftabs == s:true && !has('gui_running')
		NeoBundleDisable lightline.vim
	endif
	NeoBundleDisable ctrlp.vim
	NeoBundleDisable skk.vim
	NeoBundleDisable eskk.vim
	NeoBundleDisable mru.vim

	filetype plugin indent on

	NeoBundleCheck

	" Source plugin file for NeoBundle
	let g:plugin_vimrc = expand('~/.vimrc.plugin')
	if filereadable(g:plugin_vimrc)
		execute 'source ' . g:plugin_vimrc
	endif
	"}}}
else "{{{
	" Set neobundle rootdirectory
	if g:is_windows
		let s:bundle_root = expand('$HOME/AppData/Roaming/vim/bundle')
	else
		let s:bundle_root = expand('~/.vim/bundle')
	endif
	let s:neobundle_root = s:bundle_root . '/neobundle.vim'

	" If neobundle doesn't exist
	command! NeoBundleInit call s:neobundle_init()
	function! s:neobundle_init() "{{{
		echon "Installing neobundle.vim..."
		call mkdir(s:bundle_root, 'p')
		execute 'cd' s:bundle_root
		call system('git clone git://github.com/Shougo/neobundle.vim')
		if v:shell_error
			echoerr "neobundle.vim installation has failed!"
			finish
		endif
		execute 'set runtimepath+=' . s:bundle_root . '/neobundle.vim'
		call neobundle#rc(s:bundle_root)
		NeoBundleInstall
		highlight Finish cterm=underline ctermfg=red ctermfg=black gui=underline guifg=red guibg=black
		echo "Finish!"
	endfunction "}}}

	"call s:neobundle_init()
	if s:enable_sujest_neobundleinit == s:true
		autocmd! VimEnter * echohl WarningMsg
					\ | echo "You should do ':NeoBundleInit' at first!"
					\ | echohl None
	endif
endif "}}}

" Filetype start
filetype plugin indent on
"}}}1

" Utilities: {{{1
" Functions that are described in this section is general functions.
" It is not general, for example, functions used in a dedicated purpose
" has been described in the setting position.
"==============================================================================
function! s:b4b4r07() "{{{
	hide enew
	setlocal buftype=nofile nowrap nolist nonumber bufhidden=wipe
	setlocal modifiable nocursorline nocursorcolumn

	let b4b4r07 = []
	call add(b4b4r07, '                                                   B4B4R07''s vimrc.')
	call add(b4b4r07, '.______    _  _    .______    _  _    .______        ___    ______  ')
	call add(b4b4r07, '|   _  \  | || |   |   _  \  | || |   |   _  \      / _ \  |____  | ')
	call add(b4b4r07, '|  |_)  | | || |_  |  |_)  | | || |_  |  |_)  |    | | | |     / /  ')
	call add(b4b4r07, '|   _  <  |__   _| |   _  <  |__   _| |      /     | | | |    / /   ')
	call add(b4b4r07, '|  |_)  |    | |   |  |_)  |    | |   |  |\  \----.| |_| |   / /    ')
	call add(b4b4r07, '|______/     |_|   |______/     |_|   | _| `._____| \___/   /_/     ')
	call add(b4b4r07, 'If it is being displayed, the vim plugins are not set and installed.')
	call add(b4b4r07, 'In this environment, run '':NeoBundleInit'' if you setup vim plugin.')

	silent put =repeat([''], winheight(0)/2 - len(b4b4r07)/2)
	let space = repeat(' ', winwidth(0)/2 - strlen(b4b4r07[0])/2)
	for line in b4b4r07
		put =space . line
	endfor
	silent put =repeat([''], winheight(0)/2 - len(b4b4r07)/2 + 1)
	silent file B4B4R07
	1

	execute 'syntax match Directory display ' . '"'. '^\s\+\U\+$'. '"'
	setlocal nomodifiable
	redraw
	let char = getchar()
	silent enew
	call feedkeys(type(char) == type(0) ? nr2char(char) : char)
endfunction "}}}
function! s:SID() "{{{
	return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID$')
endfunction "}}}
function! s:has_plugin(name) "{{{
	let nosuffix = a:name =~? '\.vim$' ? a:name[:-5] : a:name
	let suffix   = a:name =~? '\.vim$' ? a:name      : a:name . '.vim'
	return &rtp =~# '\c\<' . nosuffix . '\>'
				\   || globpath(&rtp, suffix, 1) != ''
				\   || globpath(&rtp, nosuffix, 1) != ''
				\   || globpath(&rtp, 'autoload/' . suffix, 1) != ''
				\   || globpath(&rtp, 'autoload/' . tolower(suffix), 1) != ''
endfunction "}}}
function! s:escape_filename(fname) "{{{
	let esc_filename_chars = ' *?[{`$%#"|!<>();&' . "'\t\n"
	if exists("*fnameescape")
		return fnameescape(a:fname)
	else
		return escape(a:fname, esc_filename_chars)
	endif
endfunction "}}}
function! s:is_exist(path) "{{{
	let path = glob(simplify(a:path))
	if exists("*s:escape_filename")
		let path = s:escape_filename(path)
	endif
	return empty(path) ? 0 : 1
endfunction "}}}
function! s:get_dir_separator() "{{{
  return fnamemodify('.', ':p')[-1 :]
endfunction "}}}
function! s:echomsg(hl, msg) "{{{
	execute 'echohl' a:hl
	try
		echomsg a:msg
	finally
		echohl None
	endtry
endfunction "}}}
function! s:errormsg(msg) "{{{
	echohl ErrorMsg
	echo 'ERROR: ' . a:msg
	echohl None
endfunction "}}}
function! s:warningmsg(msg) "{{{
	echohl WarningMsg
	echo 'WARNING: ' . a:msg
	echohl None
endfunction "}}}
function! s:confirm(msg) "{{{
	return input(printf('%s [y/N]: ', a:msg)) =~? '^y\%[es]$'
endfunction "}}}
function! s:execute_keep_view(expr) "{{{
	let wininfo = winsaveview()
	execute a:expr
	call winrestview(wininfo)
endfunction "}}}
function! s:move_middle_line() "{{{
	let strwidth = strdisplaywidth(getline('.'))
	let winwidth = winwidth(0)

	if strwidth < winwidth
		call cursor(0, col('$') / 2)
	else
		normal! gm
	endif
endfunction "}}}
function! s:check_flag(flag) "{{{
	if exists('b:' . a:flag)
		return b:{a:flag}
	endif
	if exists('g:' . a:flag)
		return g:{a:flag}
	endif
	return 0
endfunction "}}}
function! s:mkdir(file, ...) "{{{
	let f = a:0 ? fnamemodify(a:file, a:1) : a:file
	if !isdirectory(f)
		call mkdir(f, 'p')
	endif
endfunction "}}}
function! s:auto_mkdir(dir, force) "{{{
	if !isdirectory(a:dir) && (a:force ||
				\ input(printf('"%s" does not exist. Create? [y/N] ', a:dir)) =~? '^y\%[es]$')
		call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
	endif
endfunction "}}}
function! s:smart_foldcloser() "{{{
	if foldlevel('.') == 0
		normal! zM
		return
	endif

	let foldc_lnum = foldclosed('.')
	normal! zc
	if foldc_lnum == -1
		return
	endif

	if foldclosed('.') != foldc_lnum
		return
	endif
	normal! zM
endfunction
"}}}
function! s:rename(new, type) "{{{
	if a:type ==# 'file'
		if empty(a:new)
			let new = input('New filename: ', expand('%:p:h') . '/', 'file')
		else
			let new = a:new
		endif
	elseif a:type ==# 'ext'
		if empty(a:new)
			let ext = input('New extention: ', '', 'filetype')
			let new = expand('%:p:t:r')
			if !empty(ext)
				let new .= '.' . ext
			endif
		else
			let new = expand('%:p:t:r') . '.' . a:new
		endif
	endif

	if filereadable(new)
		redraw
		echo printf("overwrite `%s'? ", new)
		if nr2char(getchar()) ==? 'y'
			silent call delete(new)
		else
			return
		endif
	endif

	if new != '' && new !=# 'file'
		execute 'file' new
		execute 'setlocal filetype=' . fnamemodify(new, ':e')
		write
		call delete(expand('#'))
	endif
endfunction "}}}
function! s:delete(bang) "{{{
	let file = expand('%:p')
	if filereadable(file)
		if empty(a:bang)
			redraw | echo 'Delete "' . file . '"? [y/N]: '
		endif
		if !empty(a:bang) || nr2char(getchar()) ==? 'y'
			if delete(file) == 0
				let bufname = bufname(fnamemodify(file, ':p'))
				if bufexists(bufname) && buflisted(bufname)
					execute "bwipeout" bufname
				endif
				echo "Deleted '" . file . "', successfully!"
				return 1
			endif
			echo "Could not delete '" . file . "'"
		else
			echo "Do nothing."
		endif
	else
		echohl WarningMsg | echo "The '" . file . "' does not exist." | echohl NONE
	endif
endfunction "}}}
function! s:rand(n) "{{{
	let match_end = matchend(reltimestr(reltime()), '\d\+\.') + 1
	return reltimestr(reltime())[match_end : ] % (a:n + 1)
endfunction "}}}
function! s:random_string(n) "{{{
	let n = a:n ==# '' ? 8 : a:n
	let s = []
	let chars = split('0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', '\ze')
	let max = len(chars) - 1
	for x in range(n)
		call add(s, (chars[s:rand(max)]))
	endfor
	let @+ = join(s, '')
	echo join(s, '')
endfunction "}}}
function! s:move(file, bang, base) "{{{
	let pwd = getcwd()
	cd `=a:base`
	try
		let from = expand('%:p')
		let to = simplify(expand(a:file))
		let bang = a:bang
		if isdirectory(to)
			let to .= '/' . fnamemodify(from, ':t')
		endif
		if filereadable(to) && !bang
			echo '"' . to . '" is exists. Overwrite? [yN]'
			if nr2char(getchar()) !=? 'y'
				echo 'Cancelled.'
				return
			endif
			let bang = '!'
		endif
		let dir = fnamemodify(to, ':h')
		call s:mkdir(dir)
		execute 'saveas' . bang '`=to`'
		call delete(from)
	finally
		cd `=pwd`
	endtry
endfunction "}}}
function! s:make_junkfile() "{{{
	let junk_dir = $HOME . '/.vim/junk'. strftime('/%Y/%m/%d')
	if !isdirectory(junk_dir)
		call mkdir(junk_dir, 'p')
	endif

	let ext = input('Junk Ext: ')
	let filename = junk_dir . tolower(strftime('/%A')) . strftime('_%H%M%S')
	if !empty(ext)
		let filename = filename . '.' . ext
	endif
	execute 'edit ' . filename
endfunction "}}}
function! s:copy_current_path(file) "{{{
	let l:path = a:file ? expand('%:p') : expand('%:p:h')
	if g:is_windows
		let @* = substitute(l:path, '\\/', '\\', 'g')
	else
		let @* = l:path
	endif
	echon l:path
endfunction "}}}
function! s:find_tabnr(bufnr) "{{{
	for tabnr in range(1, tabpagenr("$"))
		if index(tabpagebuflist(tabnr), a:bufnr) !=# -1
			return tabnr
		endif
	endfor
	return -1
endfunction "}}}
function! s:find_winnr(bufnr) "{{{
	for winnr in range(1, winnr("$"))
		if a:bufnr ==# winbufnr(winnr)
			return winnr
		endif
	endfor
	return 1
endfunction "}}}
function! s:recycle_open(default_open, path) "{{{
	let default_action = a:default_open . ' ' . a:path
	if bufexists(a:path)
		let bufnr = bufnr(a:path)
		let tabnr = s:find_tabnr(bufnr)
		if tabnr ==# -1
			execute default_action
			return
		endif
		execute 'tabnext ' . tabnr
		let winnr = s:find_winnr(bufnr)
		execute winnr . 'wincmd w'
	else
		execute default_action
	endif
endfunction "}}}
function! s:load_source(path) "{{{
	let path = expand(a:path)
	if filereadable(path)
		execute 'source ' . path
	endif
endfunction "}}}
function! s:open(file) "{{{
	if !executable("open") | return 0 | endif
	let file = empty(a:file) ? expand('%') : fnamemodify(a:file, ':p')
	call system(printf('%s %s &', 'open', shellescape(file)))
	return 1
endfunction "}}}
function! s:smart_bwipeout(buf, bang) "{{{
	" Bwipeout! all buffers
	if !empty(a:bang)
		for i in range(1, bufnr('$'))
			if bufexists(i)
				execute 'bwipeout! ' . i
			endif
		endfor
		return 1
	endif

	if a:buf == 0
		" Priority
		" 1. windows (LOW)
		" 2. tabpages
		" 3. buffers (HIGH)
		if winnr('$') != 1
			quit
			return 0
		endif

		if tabpagenr('$') != 1
			tabclose
			return 0
		endif
	endif

	let bufname = empty(bufname(bufnr('%'))) ? bufnr('%') . "#" : bufname(bufnr('%'))
	if &modified
		echo printf("'%s' is unsaved. Quit!? [y/N/w] ", bufname)
		let c = nr2char(getchar())

		if c ==? 'w'
			let filename = ''
			if bufname(bufnr("%")) ==# filename
				redraw
				while empty(filename)
					let filename = input('Tell me filename: ')
				endwhile
			endif
			execute "write " . filename
			bwipeout!
			return
		endif

		redraw
		if c ==? 'y'
			echo "Bwipeout! " . bufname
			bwipeout!
		else
			echo "Do nothing"
		endif
	else
		echo "Bwipeout " . bufname
		bwipeout
	endif
	if !s:has_plugin('vim-buftabs')
		call s:get_buflists('')
	endif
endfunction "}}}
function! s:newbuf(buf, bang) "{{{
	let buf = empty(a:buf) ? '' : a:buf
	execute "new" buf | only
	if !empty(a:bang)
		let bufname = empty(buf) ? '[Scratch]' : buf
		setlocal bufhidden=unload
		setlocal nobuflisted
		setlocal buftype=nofile
		setlocal noswapfile
		silent file `=bufname`
	endif
endfunction "}}}
function! s:get_buflists(mode) "{{{
	if a:mode ==# 'n'
		silent bnext
	endif
	if a:mode ==# 'p'
		silent bprev
	endif

	let list  = ''
	let lists = []
	for buf in range(1, bufnr('$'))
		if bufexists(buf) && buflisted(buf)
			let list  = bufnr(buf) . "#" . fnamemodify(bufname(buf), ':t')
			let list .= getbufvar(buf, "&modified") ? '+' : ''
			if bufnr('%') ==# buf
				let list = "[" . list . "]"
			else
				let list = " " . list . " "
			endif
			call add(lists, list)
		endif
	endfor
	echo join(lists, "")
endfunction
"}}}
function! s:buf_enqueue(buf) "{{{
	let buf = fnamemodify(a:buf, ':p')
	if bufexists(buf) && buflisted(buf) && filereadable(buf)
		let idx = match(s:bufqueue ,buf)
		if idx != -1
			call remove(s:bufqueue, idx)
		endif
		call add(s:bufqueue, buf)
	endif
endfunction "}}}
function! s:buf_dequeue(buf) "{{{
	if empty(s:bufqueue)
		throw 'bufqueue: Empty queue.'
	endif

	if a:buf =~# '\d\+'
		return remove(s:bufqueue, a:buf)
	else
		return remove(s:bufqueue, index(s:bufqueue, a:buf))
	endif
endfunction "}}}
function! s:buf_restore() "{{{
	try
		execute 'edit' s:buf_dequeue(-1)
	catch /^bufqueue:/
		echohl ErrorMsg
		echomsg v:exception
		echohl None
	endtry
endfunction "}}}
function! s:toggle_option(option_name) "{{{
	execute 'setlocal' a:option_name . '!'
	execute 'setlocal' a:option_name . '?'
endfunction "}}}
function! s:toggle_variable(variable_name) "{{{
	if eval(a:variable_name)
		execute 'let' a:variable_name . ' = 0'
	else
		execute 'let' a:variable_name . ' = 1'
	endif
	echo printf('%s = %s', a:variable_name, eval(a:variable_name))
endfunction "}}}
function! S(f, ...) "{{{
	" Ref: http://goo.gl/S4JFkn
	" Call a script local function.
	" Usage:
	" - S('local_func')
	"   -> call s:local_func() in current file.
	" - S('plugin/hoge.vim:local_func', 'string', 10)
	"   -> call s:local_func('string', 10) in *plugin/hoge.vim.
	" - S('plugin/hoge:local_func("string", 10)')
	"   -> call s:local_func("string", 10) in *plugin/hoge(.vim)?.
	let [file, func] =a:f =~# ':' ?  split(a:f, ':') : [expand('%:p'), a:f]
	let fname = matchstr(func, '^\w*')

	" Get sourced scripts.
	redir =>slist
	silent scriptnames
	redir END

	let filepat = '\V' . substitute(file, '\\', '/', 'g') . '\v%(\.vim)?$'
	for s in split(slist, "\n")
		let p = matchlist(s, '^\s*\(\d\+\):\s*\(.*\)$')
		if empty(p)
			continue
		endif
		let [nr, sfile] = p[1 : 2]
		let sfile = fnamemodify(sfile, ':p:gs?\\?/?')
		if sfile =~# filepat &&
					\    exists(printf("*\<SNR>%d_%s", nr, fname))
			let cfunc = printf("\<SNR>%d_%s", nr, func)
			break
		endif
	endfor

	if !exists('nr')
		echoerr 'Not sourced: ' . file
		return
	elseif !exists('cfunc')
		let file = fnamemodify(file, ':p')
		echoerr printf(
					\    'File found, but function is not defined: %s: %s()', file, fname)
		return
	endif

	return 0 <= match(func, '^\w*\s*(.*)\s*$')
				\      ? eval(cfunc) : call(cfunc, a:000)
endfunction "}}}
function! HomedirOrBackslash() "{{{
	if getcmdtype() == ':' && (getcmdline() =~# '^e ' || getcmdline() =~? '^r\?!' || getcmdline() =~? '^cd ')
		return '~/'
	else
		return '\'
	endif
endfunction "}}}
function! GetDate() "{{{
	return strftime("%Y/%m/%d %H:%M")
endfunction "}}}
function! GetDocumentPosition() "{{{
	return float2nr(str2float(line('.')) / str2float(line('$')) * 100) . "%"
endfunction "}}}
function! GetTildaPath(tail) "{{{
	return a:tail ? expand('%:h:~') : expand('%:~')
endfunction "}}}
function! GetCharacterCode() "{{{
	let str = iconv(matchstr(getline('.'), '.', col('.') - 1), &enc, &fenc)
	let out = '0x'
	for i in range(strlen(str))
		let out .= printf('%02X', char2nr(str[i]))
	endfor
	if str ==# ''
		let out .= '00'
	endif
	return out
endfunction "}}}
function! GetFileSize() "{{{
	let size = &encoding ==# &fileencoding || &fileencoding ==# ''
				\        ? line2byte(line('$') + 1) - 1 : getfsize(expand('%'))

	if size < 0
		let size = 0
	endif
	for unit in ['B', 'KB', 'MB']
		if size < 1024
			return size . unit
		endif
		let size = size / 1024
	endfor
	return size . 'GB'
endfunction "}}}
function! GetBufname(bufnr, tail) "{{{
	let bufname = bufname(a:bufnr)
	if bufname =~# '^[[:alnum:].+-]\+:\\\\'
		let bufname = substitute(bufname, '\\', '/', 'g')
	endif
	let buftype = getbufvar(a:bufnr, '&buftype')
	if bufname ==# ''
		if buftype ==# ''
			return '[No Name]'
		elseif buftype ==# 'quickfix'
			return '[Quickfix List]'
		elseif buftype ==# 'nofile' || buftype ==# 'acwrite'
			return '[Scratch]'
		endif
	endif
	if buftype ==# 'nofile' || buftype ==# 'acwrite'
		return bufname
	endif
	if a:tail
		return fnamemodify(bufname, ':t')
	endif
	let fullpath = fnamemodify(bufname, ':p')
	if exists('b:lcd') && b:lcd !=# ''
		let bufname = matchstr(fullpath, '^\V\(' . escape(b:lcd, '\')
					\ . '\v)?[/\\]?\zs.*')
	endif
	return bufname
endfunction "}}}
function! GetFileInfo() "{{{
	let line  = ''
	if bufname(bufnr("%")) == ''
		let line .= 'No name'
	else
		let line .= '"'
		let line .= expand('%:p:~')
		let line .= ' (' . line('.') . '/' . line('$') . ') '
		"let line .= '--' . 100 * line('.') / line('$') . '%--'
		let line .= GetDocumentPosition()
		let line .= '"'
	endif
	return line
endfunction "}}}
function! Scouter(file, ...) "{{{
	" Measure fighting power of Vim!
	" :echo len(readfile($MYVIMRC))
	let pat = '^\s*$\|^\s*"'
	let lines = readfile(a:file)
	if !a:0 || !a:1
		let lines = split(substitute(join(lines, "\n"), '\n\s*\\', '', 'g'), "\n")
	endif
	return len(filter(lines,'v:val !~ pat'))
endfunction " }}}
function! WordCount(...) "{{{
	if a:0 == 0
		return s:WordCountStr
	endif
	let cidx = 3
	silent! let cidx = s:WordCountDict[a:1]
	let s:WordCountStr = ''
	let s:saved_status = v:statusmsg
	exec "silent normal! g\<c-g>"
	if v:statusmsg !~ '^--'
		let str = ''
		silent! let str = split(v:statusmsg, ';')[cidx]
		let cur = str2nr(matchstr(str, '\d\+'))
		let end = str2nr(matchstr(str, '\d\+\s*$'))
		if a:1 == 'char'
			let cr = &ff == 'dos' ? 2 : 1
			let cur -= cr * (line('.') - 1)
			let end -= cr * line('$')
		endif
		let s:WordCountStr = printf('%d/%d', cur, end)
		let s:WordCountStr = printf('%d', end)
	endif
	let v:statusmsg = s:saved_status
	return s:WordCountStr
endfunction "}}}
function! GetBufInfo() "{{{
	echo '[ fpath ]' expand('%:p')
	echo '[ bufnr ]' bufnr('%')
	if filereadable(expand('%'))
		echo '[ mtime ]' strftime('%Y-%m-%d %H:%M:%S', getftime(expand('%')))
	endif
	echo '[ fline ]' line('$') 'lines'
	"echo '[ fsize ]' s:GetBufByte() 'bytes'
	echo '[ fsize ]' GetFileSize()
	echo '[ power ]' Scouter($MYVIMRC)
endfunction "}}}
function! TrailingSpaceWarning() "{{{
	if !exists("b:trailing_space_warning")
		if search('\s\+$', 'nw') != 0
			let b:trailing_space_warning = '[SPC:' . search('\s\+$', 'nw') . ']'
		else
			let b:trailing_space_warning = ''
		endif
	endif
	return b:trailing_space_warning
endfunction
" Recalculate the trailing whitespace warning when idle, and after saving
autocmd CursorHold,BufWritePost * unlet! b:trailing_space_warning
"}}}
"}}}1

" Priority: {{{
" In this section, the settings a higher priority than the setting items
" of the other sections will be described.
"==============================================================================
if !s:has_plugin('neobundle.vim')
	command! B4B4R07 call s:b4b4r07()
	autocmd VimEnter * call s:b4b4r07()
endif

" Restore the buffer that has been deleted {{{
let s:bufqueue = []
augroup buffer-queue-restore
	autocmd!
	autocmd BufDelete * call <SID>buf_enqueue(expand('#'))
augroup END
"}}}

" Backup automatically {{{
set backup
if g:is_windows
	set backupdir=$VIM/backup
	set backupext=.bak
else
	call s:mkdir(expand('~/.vim/backup'))
	augroup backup-files-automatically
		autocmd!
		autocmd BufWritePre * call UpdateBackupFile()
	augroup END

	function! UpdateBackupFile()
		let dir = strftime("~/.backup/vim/%Y/%m/%d", localtime())
		if !isdirectory(dir)
			let retval = system("mkdir -p " . dir)
			let retval = system("chown goth:staff " . dir)
		endif
		execute "set backupdir=" . dir
		unlet dir
		let ext = strftime("%H_%M_%S", localtime())
		execute "set backupext=." . ext
		unlet ext
	endfunction
endif
" }}}

" Swap settings {{{
call s:mkdir(expand('~/.vim/swap'))
set swapfile
set directory=~/.vim/swap
" }}}
"}}}

" Appearance: {{{1
" In this section, interface of Vim, that is, colorscheme, statusline and
" tabpages line is set.
"==============================================================================

" Essentials
syntax enable
syntax on

" Colorscheme "{{{
set background=dark
set t_Co=256
if &t_Co < 256
	colorscheme default
else
	if has('gui_running') && !g:is_windows
		" For MacVim, only
		if s:bundled('solarized.vim')
			colorscheme solarized
		endif
	else
		" Vim for CUI
		if s:bundled('solarized.vim')
			colorscheme solarized
		elseif s:bundled('vim-hybrid')
			colorscheme hybrid
		elseif s:bundled('jellybeans.vim')
			colorscheme jellybeans
		else
			colorscheme desert
		endif
	endif
endif "}}}

set laststatus=2
"set statusline=%!MakeStatusLine()
set showtabline=2
set tabline=%!MakeTabLine()

" StatusLine {{{
set laststatus=2
highlight BlackWhite ctermfg=black ctermbg=white cterm=none guifg=black guibg=white gui=none
highlight WhiteBlack ctermfg=white ctermbg=black cterm=none guifg=white guibg=black gui=none

set statusline=
set statusline+=%#BlackWhite#
set statusline+=%{pathshorten(getcwd())}/
set statusline+=%f
set statusline+=\ %m
set statusline+=%#StatusLine#
set statusline+=%=                          "Separation"
set statusline+=%#BlackWhite#
if exists('*StatuslineTrailingSpaceWarning')
	set statusline+=%{StatuslineTrailingSpaceWarning()}
endif
set statusline+=%y%{'['.(&fenc!=''?&fenc:&enc).':'.&ff.']'}
set statusline+=%r
set statusline+=%h
set statusline+=%w
if exists('*GetFileSize')
	set statusline+=[%{GetFileSize()}]
endif
if exists('*GetCharacterCode')
	set statusline+=[%{GetCharacterCode()}]
endif
set statusline+=\ %4l/%4LL,%3cC\ %3p%%
if exists('*WordCount')
	set statusline+=\ [WC=%{WordCount()}]
endif
if exists('*GetDate')
	set statusline+=\ (%{GetDate()})
endif
"}}}

function! s:tabpage_label(n) "{{{
	let n = a:n
	let bufnrs = tabpagebuflist(n)
	let curbufnr = bufnrs[tabpagewinnr(n) - 1]

	let hi = n == tabpagenr() ? 'TabLineSel' : 'TabLine'

	let label = ''
	let no = len(bufnrs)
	if no == 1
		let no = ''
	endif
	let mod = len(filter(bufnrs, 'getbufvar(v:val, "&modified")')) ? '+' : ''
	let sp = (no . mod) ==# '' ? '' : ' '
	let fname = GetBufname(curbufnr, 1)

	if no !=# ''
		let label .= '%#' . hi . 'Number#' . no
	endif
	let label .= '%#' . hi . '#'
	let label .= fname . sp . mod

	return '%' . a:n . 'T' . label . '%T%#TabLineFill#'
endfunction "}}}

function! MakeTabLine() "{{{
	let titles = map(range(1, tabpagenr('$')), 's:tabpage_label(v:val)')
	let sep = ' | '
	let tabs = join(titles, sep) . sep . '%#TabLineFill#%T'

	hi TabLinePwd ctermfg=white
	let info = '%#TabLinePwd#'
	let info .= fnamemodify(getcwd(), ':~') . ' '
	return tabs . '%=' . info
endfunction "}}}

" Emphasize statusline in the insert mode {{{
if !s:has_plugin('lightline.vim')
	if has('syntax')
		augroup InsertHook
			autocmd!
			autocmd InsertEnter * call s:colorize_statusline_insert('Enter')
			autocmd InsertLeave * call s:colorize_statusline_insert('Leave')
		augroup END
	endif

	let g:hi_insert = 'highlight StatusLine guifg=black guibg=darkyellow gui=none ctermfg=black ctermbg=darkyellow cterm=none'
	let s:slhlcmd = ''
	function! s:colorize_statusline_insert(mode)
		if a:mode == 'Enter'
			silent! let s:slhlcmd = 'highlight ' . s:get_statusline_highlight('StatusLine')
			silent exec g:hi_insert
		else
			highlight clear StatusLine
			silent exec s:slhlcmd
		endif
	endfunction

	function! s:get_statusline_highlight(hi)
		redir => hl
		exec 'highlight '.a:hi
		redir END
		let hl = substitute(hl, '[\r\n]', '', 'g')
		let hl = substitute(hl, 'xxx', '', '')
		return hl
	endfunction
endif
" }}}

" Cursor line/column {{{
set cursorline
"set cursorcolumn
"set colorcolumn=80

augroup auto-cursorcolumn-emphasis
	autocmd!
	autocmd CursorMoved,CursorMovedI * call s:auto_cursorcolumn('CursorMoved')
	autocmd CursorHold,CursorHoldI * call s:auto_cursorcolumn('CursorHold')
	autocmd WinEnter * call s:auto_cursorcolumn('WinEnter')
	autocmd WinLeave * call s:auto_cursorcolumn('WinLeave')

	let s:cursorcolumn_lock = 0
	function! s:auto_cursorcolumn(event)
		if a:event ==# 'WinEnter'
			setlocal cursorcolumn
			let s:cursorcolumn_lock = 2
		elseif a:event ==# 'WinLeave'
			setlocal nocursorcolumn
		elseif a:event ==# 'CursorMoved'
			if s:cursorcolumn_lock
				if 1 < s:cursorcolumn_lock
					let s:cursorcolumn_lock = 1
				else
					setlocal nocursorcolumn
					let s:cursorcolumn_lock = 0
				endif
			endif
		elseif a:event ==# 'CursorHold'
			setlocal cursorcolumn
			let s:cursorcolumn_lock = 1
		endif
	endfunction
augroup END
"}}}

" GUI IME Cursor colors {{{
if has('multi_byte_ime') || has('xim')
	highlight Cursor guibg=NONE guifg=Yellow
	highlight CursorIM guibg=NONE guifg=Red
	set iminsert=0 imsearch=0
	if has('xim') && has('GUI_GTK')
		""set imactivatekey=s-space
	endif
	inoremap <silent> <ESC><ESC>:set iminsert=0<CR>
endif "}}}

" Display zenkaku-space {{{
augroup hilight-idegraphic-space
	autocmd!
	autocmd VimEnter,ColorScheme * highlight IdeographicSpace term=underline ctermbg=DarkGreen guibg=DarkGreen
	autocmd WinEnter * match IdeographicSpace /　/
augroup END "}}}
"}}}1

" Options: {{{1
" SEE ALSO :help 'option-list'
"==============================================================================

" No redraw
set lazyredraw

" Fast terminal connection
set ttyfast

" Enable the mode line
set modeline

" The length of the mode line
set modelines=5

" Vim internal help with the command K
set keywordprg=:help

" Language help
set helplang& helplang=ja

" Ignore case
set ignorecase

" Smart ignore case
set smartcase

" Enable the incremental search
set incsearch

" Emphasize the search pattern
set hlsearch

" Have Vim automatically reload changed files on disk. Very useful when using
" git and switching between branches
set autoread

" Automatically write buffers to file when current window switches to another
" buffer as a result of :next, :make, etc. See :h autowrite.
set autowrite

" Behavior when you switch buffers
set switchbuf=useopen,usetab,newtab

" Moves the cursor to the same column when cursor move
set nostartofline

" The length of the tab
set tabstop=4

" Do not convert tabs to spaces
set noexpandtab

" When starting a new line, indent in automatic
set autoindent

" The function of the backspace
set backspace=indent,eol,start

" When the search is finished, search again from the BOF
set wrapscan

" Emphasize the matching parenthesis
set showmatch

" Emphasize time
set matchtime=1

" Increase the corresponding pairs
set matchpairs+=<:>

" Extend the command line completion
set wildmenu

" Wildmenu mode
set wildmode=longest,full

set wildignore=.git,.hg,.svn
set wildignore+=*.jpg,*.jpeg,*.bmp,*.gif,*.png
set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest,*.so,*.out,*.class
set wildignore+=*.swp,*.swo,*.swn
set wildignore+=*.DS_Store

set shiftwidth=4
set smartindent
set smarttab
set whichwrap=b,s,h,l,<,>,[,]

" Hide buffers instead of unloading them
set hidden

set textwidth=0
set formatoptions-=t
set formatoptions-=c
set formatoptions-=r
set formatoptions-=o
set formatoptions-=v
set formatoptions+=l
set number

" Show line and column number
set ruler

set list
set listchars=tab:>-,trail:-,nbsp:%,extends:>,precedes:<,eol:<
set listchars=eol:<,tab:>.
set t_Co=256
set nrformats=alpha,hex
set winaltkeys=no
set visualbell
set vb t_vb=
set noequalalways
set history=10000

set wrap

" String to put at the start of lines that have been wrapped.
let &showbreak = '+++ '

" Always display a status line
set laststatus=2

" Set command window height to reduce number of 'Press ENTER...' prompts
set cmdheight=2

" Show current mode (insert, visual, normal, etc.)
set showmode

" Show last command in status line
set showcmd

" Lets vim set the title of the console
set notitle

set lines=50
set columns=160
set previewheight=10
set helpheight=999
set mousehide
set virtualedit=block
set virtualedit& virtualedit+=block

" Make it normal in UTF-8 in Unix.
set encoding=utf-8

" Select newline character (either or both of CR and LF depending on system) automatically
" Default fileformat.
set fileformat=unix
" Automatic recognition of a new line cord.
set fileformats=unix,dos,mac
" A fullwidth character is displayed in vim properly.
if exists('&ambiwidth')
	set ambiwidth=double
endif

set fileencodings=iso-2022-jp,cp932,sjis,euc-jp,utf-8

set foldenable
"set foldmethod=marker
"set foldopen=all
"set foldclose=all
set foldlevel=0
"set foldnestmax=2
set foldcolumn=2

" IM settings
" IM off when starting up
set iminsert=0 imsearch=0
" Use IM always
"set noimdisable
" Disable IM on cmdline
set noimcmdline

" Change some neccesary settings for win
if g:is_windows
	set shellslash "Exchange path separator
endif

if has('persistent_undo')
	set undofile
	let &undodir = $DOTVIM . '/undo'
	call s:mkdir(&undodir)
endif

" Use clipboard
if has('clipboard')
	set clipboard=unnamed
endif

if has('patch-7.4.338')
	set breakindent
endif

" GUI options {{{
" No menubar
set guioptions-=m
" No frame
set guioptions-=C
set guioptions-=T
" No right scroolbar
set guioptions-=r
set guioptions-=R
" No left scroolbar
set guioptions-=l
set guioptions-=L
" No under scroolbar
set guioptions-=b
"}}}

"}}}1

" Commands: {{{1
"==============================================================================

command! -bar EchoRTP       echo substitute(&runtimepath, ',', '\n', 'g')
"command! -bar EchoHighlight echo synIDattr(synID(line('.'),col('.'),0),'name') synIDattr(synIDtrans(synID(line('.'),col('.'),1)),'name')
command! -bar EchoBufKind   setlocal bufhidden? buftype? swapfile? buflisted?

" Open new buffer or scratch buffer with bang
command! -bang -nargs=? -complete=file BufNew call <SID>newbuf(<q-args>, <q-bang>)

" Bwipeout(!) for all-purpose
command -nargs=0 -bang Bwipeout call <SID>smart_bwipeout(0, <q-bang>)

" Delete the current buffer and the file
command! -bang -nargs=0 -complete=buffer Delete call s:delete(<bang>0)

" Open a file.
command! -nargs=? -complete=file Open call <SID>open(<q-args>)

" Show all runtimepaths
command! -bar RTP echo substitute(&runtimepath, ',', "\n", 'g')

" Measure fighting strength of Vim
command! -bar -bang -nargs=? -complete=file Scouter echo Scouter(empty(<q-args>) ? $MYVIMRC : expand(<q-args>), <bang>0)

" Make the notitle file called 'Junk'
command! -nargs=0 JunkFile call s:make_junkfile()

" Get buffer queue list for restore
command! -nargs=0 BufQueue echo len(s:bufqueue)
			\ ? reverse(split(substitute(join(s:bufqueue, ' '), $HOME, '~', 'g')))
			\ : "No buffers in 's:bufqueue'."

" Get buffer list like ':ls'
command! -nargs=0 BufList call s:get_buflists('')

" Remove EOL ^M
command! RemoveCr call s:execute_keep_view('silent! %substitute/\r$//g | nohlsearch')

" Remove EOL space
command! RemoveEolSpace call s:execute_keep_view('silent! %substitute/ \+$//g | nohlsearch')

" Remove blank line
command! RemoveBlankLine silent! global/^$/delete | nohlsearch | normal! ``

" Get current file path
command! CopyCurrentPath call s:copy_current_path(1)

" Get current directory path
command! CopyCurrentDir call s:copy_current_path(0)

" Make random string such as password
command! -nargs=? RandomString call s:random_string(<q-args>)

" Rename
command! -nargs=1 -bang -bar -complete=file Rename call s:move(<q-args>, <q-bang>, expand('%:h'))

" Move
command! -nargs=1 -bang -bar -complete=file Move call s:move(<q-args>, <q-bang>, getcwd())

" Rename the current editing file
command! -nargs=? -complete=file Rename call s:rename(<q-args>, 'file')

" Change the current editing file extention
command! -nargs=? -complete=filetype ReExt  call s:rename(<q-args>, 'ext')

" View all mappings
command! -nargs=* -complete=mapping AllMaps map <args> | map! <args> | lmap <args>

" Delete hidden buffer
command! -bar DeleteHideBuffer call s:delete_hide_buffer()

" Delete type of nofile buffer
command! -bar DeleteNoFileBuffer call s:delete_no_file_buffer()

" Command group opening with a specific character code again
" In particular effective when I am garbled in a terminal
command! -bang -bar -complete=file -nargs=? Utf8      edit<bang> ++enc=utf-8 <args>
command! -bang -bar -complete=file -nargs=? Iso2022jp edit<bang> ++enc=iso-2022-jp <args>
command! -bang -bar -complete=file -nargs=? Cp932     edit<bang> ++enc=cp932 <args>
command! -bang -bar -complete=file -nargs=? Euc       edit<bang> ++enc=euc-jp <args>
command! -bang -bar -complete=file -nargs=? Utf16     edit<bang> ++enc=ucs-2le <args>
command! -bang -bar -complete=file -nargs=? Utf16be   edit<bang> ++enc=ucs-2 <args>
command! -bang -bar -complete=file -nargs=? Jis       Iso2022jp<bang> <args>
command! -bang -bar -complete=file -nargs=? Sjis      Cp932<bang> <args>
command! -bang -bar -complete=file -nargs=? Unicode   Utf16<bang> <args>

" Tried to make a file note version
" Don't save it because dangerous.
command! WUtf8      setlocal fenc=utf-8
command! WIso2022jp setlocal fenc=iso-2022-jp
command! WCp932     setlocal fenc=cp932
command! WEuc       setlocal fenc=euc-jp
command! WUtf16     setlocal fenc=ucs-2le
command! WUtf16be   setlocal fenc=ucs-2
command! WJis       WIso2022jp
command! WSjis      WCp932
command! WUnicode   WUtf16

" Appoint a line feed
command! -bang -complete=file -nargs=? WUnix write<bang> ++fileformat=unix <args> | edit <args>
command! -bang -complete=file -nargs=? WDos  write<bang> ++fileformat=dos <args>  | edit <args>
command! -bang -complete=file -nargs=? WMac  write<bang> ++fileformat=mac <args>  | edit <args>
"}}}1

" Mappings: {{{1
"==============================================================================

" It is likely to be changed by $VIM/vimrc.
if has('vim_starting')
	mapclear
	mapclear!
endif

" Use backslash
if g:is_mac
	noremap ¥ \
	noremap \ ¥
endif

" Define mapleader
let mapleader = ","
let maplocalleader = ","

" function's commands {{{
" Smart folding close
nnoremap <silent><C-_> :<C-u>call <SID>smart_foldcloser()<CR>

"map <C-k> <Nop>
"map! <C-k> <Nop>
nnoremap <C-k> <C-k><C-a>

" Kill buffer
nnoremap <silent> <C-x>k     :call <SID>smart_bwipeout(0, '')<CR>
nnoremap <silent> <C-x>K     :call <SID>smart_bwipeout(1, 1)<CR>
nnoremap <silent> <C-x><C-k> :call <SID>smart_bwipeout(1, '')<CR>

" Restore buffers
"nnoremap <silent> <C-x>u :<C-u>call <SID>buf_dequeue()<CR>
nnoremap <silent> <C-x>u :<C-u>call <SID>buf_restore()<CR>

" Move middle of current line (not middle of screen)
nnoremap <silent> gm :<C-u>call <SID>move_middle_line()<CR>

" Open vimrc with tab
nnoremap <silent> <Space>. :call <SID>recycle_open('edit', $MYVIMRC)<CR>

" Open the buffer again with tabpages
command! -nargs=? -complete=buffer ROT call <SID>recycle_open('tabedit', empty(<q-args>) ? expand('#') : expand(<q-args>))

" Make junkfile
nnoremap <silent> <Space>e  :<C-u>JunkFile<CR>

" Easy typing tilda insted of backslash
cnoremap <expr> <Bslash> HomedirOrBackslash()
"}}}

" swap ; and : {{{
nnoremap ; :
vnoremap ; :
nnoremap q; q:
vnoremap q; q:
nnoremap : ;
vnoremap : ;
"}}}

" Easy escaping jj {{{
inoremap jj <ESC>
cnoremap <expr> j getcmdline()[getcmdpos()-2] ==# 'j' ? "\<BS>\<C-c>" : 'j'
vnoremap <C-j><C-j> <ESC>
onoremap jj <ESC>
inoremap j<Space> j
onoremap j<Space> j
"}}}

" switch j,k and gj,gk {{{
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
nnoremap gj j
nnoremap gk k
vnoremap gj j
vnoremap gk k

if s:enable_eof_to_bof == s:true
	function! Up(key)
		if line(".") == 1
			return ":call cursor(line('$'), col('.'))\<CR>"
		else
			return a:key
		endif
	endfunction
	function! Down(key)
		if line(".") == line("$")
			return ":call cursor(1, col('.'))\<CR>"
		else
			return a:key
		endif
	endfunction
	nnoremap <expr><silent> k Up("gk")
	nnoremap <expr><silent> j Down("gj")
endif "}}}

" virtual replace mode {{{
nnoremap R gR
nnoremap gR R
"}}}

" Buffer and Tabs {{{
if s:has_plugin('vim-buftabs')
	nnoremap <silent> <C-j> :<C-u>silent! bnext<CR>
	nnoremap <silent> <C-k> :<C-u>silent! bprev<CR>
else
	nnoremap <silent> <C-j> :<C-u>call <SID>get_buflists('p')<CR>
	nnoremap <silent> <C-k> :<C-u>call <SID>get_buflists('n')<CR>
endif

nnoremap <silent> <C-h> :<C-u>silent! tabnext<CR>
nnoremap <silent> <C-l> :<C-u>silent! tabprev<CR>
nnoremap <silent> tt  :<C-u>tabe<CR>
"}}}

" Auto pair {{{
inoremap [ []<LEFT>
inoremap ( ()<LEFT>
inoremap " ""<LEFT>
inoremap ' ''<LEFT>
inoremap ` ``<LEFT>
"}}}

" Cursor like Emacs {{{
inoremap <C-h> <Backspace>
inoremap <C-d> <Delete>
inoremap <C-m> <Return>
inoremap <C-i> <Tab>
cnoremap <C-k> <UP>
cnoremap <C-j> <DOWN>
cnoremap <C-l> <RIGHT>
cnoremap <C-h> <LEFT>
cnoremap <C-d> <DELETE>
cnoremap <C-m> <CR>
cnoremap <C-p> <UP>
cnoremap <C-n> <DOWN>
cnoremap <C-f> <RIGHT>
cnoremap <C-b> <LEFT>
cnoremap <C-a> <HOME>
cnoremap <C-e> <END>
nnoremap <C-a> ^
nnoremap <C-e> $
nnoremap + <C-a>
nnoremap - <C-x>
"}}}

" Nop features {{{
nnoremap q: <Nop>
nnoremap q/ <Nop>
nnoremap q? <Nop>
nnoremap <Up> <Nop>
nnoremap <Down> <Nop>
nnoremap <Left> <Nop>
nnoremap <Right> <Nop>
nnoremap ZZ <Nop>
nnoremap ZQ <Nop>
"}}}

" Window split {{{
nnoremap s <Nop>
nnoremap sp <C-u>:split<CR>
nnoremap vs <C-u>:vsplit<CR>
nnoremap ss <C-w>w
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap sh <C-w>h
" _ : Quick horizontal splits
nnoremap _  :sp<CR>
" | : Quick vertical splits
nnoremap <bar>  :vsp<CR>

"}}}

" Like an Emacs {{{
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-d> <Del>
cnoremap <C-h> <BS>
"}}}

" Folding {{{
nnoremap <expr>l foldclosed('.') != -1 ? 'zo' : 'l'
nnoremap <expr>h col('.') == 1 && foldlevel(line('.')) > 0 ? 'zc' : 'h'
nnoremap <silent>z0 :<C-u>set foldlevel=<C-r>=foldlevel('.')<CR><CR>
"}}}

" Useful settings {{{
inoremap <silent> <C-CR> <Esc>:set expandtab<CR>a<CR> <Esc>:set noexpandtab<CR>a<BS>

nnoremap <Leader>wc :%s/\i\+/&/gn<CR>
vnoremap <Leader>wc :s/\i\+/&/gn<CR>
nnoremap gs :<C-u>%s///g<Left><Left><Left>
vnoremap gs :s///g<Left><Left><Left>

" Add a relative number toggle
nnoremap <silent> <Leader>r :<C-u>set relativenumber!<CR>

" Add a spell check toggle
nnoremap <silent> <Leader>s :<C-u>set spell!<CR>

" Goto {num} row like a {num}gg, {num}G and :{num}<CR>
nnoremap <expr><Tab> v:count !=0 ? "G" : "\<Tab>"

nnoremap <silent>~ :let &tabstop = (&tabstop * 2 > 16) ? 2 : &tabstop * 2<CR>:echo 'tabstop:' &tabstop<CR>

" Move to top/center/bottom
noremap <expr> zz (winline() == (winheight(0)+1)/ 2) ?
			\ 'zt' : (winline() == 1)? 'zb' : 'zz'

" Reset highlight searching
nnoremap <silent> <ESC><ESC> :nohlsearch<CR>

" Go to last last changes
nnoremap <C-g> zRg;zz

" key map ^,$ to <Space>h,l. Because ^ and $ is difficult to type and damage little finger!!!
noremap <Space>h ^
noremap <Space>l $

" Type 'v', select end of line in visual mode
vnoremap v $h

nnoremap Y y$
nnoremap n nzz
nnoremap N Nzz

nnoremap <Space>/  *<C-o>
nnoremap g<Space>/ g*<C-o>
nnoremap S *zz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz

"noremap <Space>O  :<C-u>for i in range(v:count1) \| call append(line('.'), '') \| endfor<CR>
"nnoremap <Space>O  :<C-u>for i in range(v:count1) \| call append(line('.')-1, '') \| endfor<CR>

nnoremap <C-g> 1<C-g>
noremap g<CR> g;
nnoremap <silent><CR> :<C-u>silent w<CR>

" swap gf and gF
noremap gf gF
noremap gF gf

" IM off when breaking insert-mode
inoremap <ESC> <ESC>
inoremap <C-[> <ESC>

" Don't use Ex mode, use Q for formatting
nnoremap Q gq

" Insert null line
"nnoremap <silent><CR> :<C-u>call append(expand('.'), '')<CR>j

nnoremap <silent>W :<C-u>keepjumps normal! }<CR>
nnoremap <silent>B :<C-u>keepjumps normal! {<CR>
"}}}
"}}}1

" Plugins: {{{1
"==============================================================================

" mru.vim {{{
if s:bundled('mru.vim')
	let MRU_Use_Alt_useopen = 1         "Open MRU by line number
	let MRU_Window_Height   = 15
	let MRU_Max_Entries     = 100
	let MRU_Use_CursorLine  = 1
	nnoremap <silent><Space>j :MRU<CR>
endif
" }}}
" unite.vim {{{
if s:bundled('unite.vim')
	let g:unite_winwidth                   = 40
	let g:unite_source_file_mru_limit      = 300
	let g:unite_enable_start_insert        = 0            "off is zero
	let g:unite_enable_split_vertically    = 0
	let g:unite_source_history_yank_enable = 1            "enable history/yank
	let g:unite_source_file_mru_filename_format  = ''
	let g:unite_kind_jump_list_after_jump_scroll = 0
	"nnoremap <silent><Space>j :Unite file_mru -direction=botright -toggle<CR>
	"nnoremap <silent><Space>o :Unite outline  -direction=botright -toggle<CR>
	let g:unite_split_rule = 'botright'
	nnoremap <silent><Space>o :Unite outline -vertical -winwidth=40 -toggle<CR>
	"nnoremap <silent><Space>o :Unite outline -vertical -no-quit -winwidth=40 -toggle<CR>
endif
" }}}
" neocomplete.vim {{{
if s:bundled('neocomplete')
	let g:neocomplete#enable_at_startup = 1
	let g:neocomplete#disable_auto_complete = 0
	let g:neocomplete#enable_ignore_case = 1
	let g:neocomplete#enable_smart_case = 1
	if !exists('g:neocomplete#keyword_patterns')
		let g:neocomplete#keyword_patterns = {}
	endif
	let g:neocomplete#keyword_patterns._ = '\h\w*'
elseif s:bundled('neocomplcache')
	let g:neocomplcache_enable_at_startup = 1
	let g:Neocomplcache_disable_auto_complete = 0
	let g:neocomplcache_enable_ignore_case = 1
	let g:neocomplcache_enable_smart_case = 1
	if !exists('g:neocomplcache_keyword_patterns')
		let g:neocomplcache_keyword_patterns = {}
	endif
	let g:neocomplcache_keyword_patterns._ = '\h\w*'
	let g:neocomplcache_enable_camel_case_completion = 1
	let g:neocomplcache_enable_underbar_completion = 1
endif
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"

highlight Pmenu      ctermbg=lightcyan ctermfg=black
highlight PmenuSel   ctermbg=blue      ctermfg=black
highlight PmenuSbari ctermbg=darkgray
highlight PmenuThumb ctermbg=lightgray
" }}}
" lightline.vim {{{
if s:bundled('lightline.vim')
	let s:use_buftabs = 0
	let g:lightline = {
				\ 'colorscheme': 'solarized',
				\ 'mode_map': {'c': 'NORMAL'},
				\ 'active': {
				\   'left':  [ [ 'mode', 'paste' ], [ 'fugitive', 'filepath'], [ 'filename' ] ],
				\   'right' : [ [ 'date' ], [ 'lineinfo', 'percent' ], [ 'filetype', 'fileencoding', 'fileformat' ] ],
				\ },
				\ 'component_function': {
				\   'modified': 'MyModified',
				\   'readonly': 'MyReadonly',
				\   'fugitive': 'MyFugitive',
				\   'filepath': 'MyFilepath',
				\   'filename': 'MyFilename',
				\   'fileformat': 'MyFileformat',
				\   'filetype': 'MyFiletype',
				\   'fileencoding': 'MyFileencoding',
				\   'mode': 'MyMode',
				\   'date': 'MyDate'
				\ }
				\ }

	function! MyDate()
		return strftime("%Y/%m/%d %H:%M")
	endfunction

	function! MyModified()
		return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
	endfunction

	function! MyReadonly()
		return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? 'x' : ''
	endfunction

	function! MyFilepath()
		"return expand('%:p:h')
		return expand('%:~:h') . "/"
	endfunction

	function! MyFilename()
		return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
					\ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
					\  &ft == 'unite' ? unite#get_status_string() :
					\  &ft == 'vimshell' ? vimshell#get_status_string() :
					\ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
					\ ('' != MyModified() ? ' ' . MyModified() : '')
	endfunction

	function! MyFugitive()
		try
			if &ft !~? 'vimfiler\|gundo' && exists('*fugitive#head')
				return fugitive#head()
			endif
		catch
		endtry
		return ''
	endfunction

	function! MyFileformat()
		return winwidth(0) > 70 ? &fileformat : ''
	endfunction

	function! MyFiletype()
		return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'NONE') : ''
	endfunction

	function! MyFileencoding()
		return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
	endfunction

	function! MyMode()
		return winwidth(0) > 60 ? lightline#mode() : ''
	endfunction

	" http://ac-mopp.blogspot.jp/2014/03/lightlinevim.html {{{
	let g:mline_bufhist_queue = []
	let g:mline_bufhist_limit = 4
	let g:mline_bufhist_exclution_pat = '^$\|.jax$\|vimfiler:\|\[unite\]\|tagbar'
	let g:mline_bufhist_enable = 1
	command! Btoggle :let g:mline_bufhist_enable = g:mline_bufhist_enable ? 0 : 1 | :redrawstatus!

	function! Mline_buflist()
		if &filetype =~? 'unite\|vimfiler\|tagbar' || !&modifiable || len(g:mline_bufhist_queue) == 0 || g:mline_bufhist_enable == 0
			return ''
		endif

		let current_buf_nr = bufnr('%')
		let buf_names_str = ''
		let last = g:mline_bufhist_queue[-1]
		for i in g:mline_bufhist_queue
			let t = fnamemodify(i, ':t')
			let n = bufnr(t)

			if n != current_buf_nr
				let buf_names_str .= printf('[%d]:%s' . (i == last ? '' : ' | '), n, t)
			endif
		endfor

		return buf_names_str
	endfunction

	function! s:update_recent_buflist(file)
		if a:file =~? g:mline_bufhist_exclution_pat
			" exclusion from queue
			return
		endif

		if len(g:mline_bufhist_queue) == 0
			" init
			for i in range(min( [ bufnr('$'), g:mline_bufhist_limit + 1 ] ))
				let t = bufname(i)
				if bufexists(i) && t !~? g:mline_bufhist_exclution_pat
					call add(g:mline_bufhist_queue, fnamemodify(t, ':p'))
				endif
			endfor
		endif

		" update exist buffer
		let idx = index(g:mline_bufhist_queue, a:file)
		if 0 <= idx
			call remove(g:mline_bufhist_queue, idx)
		endif

		call insert(g:mline_bufhist_queue, a:file)

		if g:mline_bufhist_limit + 1 < len(g:mline_bufhist_queue)
			call remove(g:mline_bufhist_queue, -1)
		endif
	endfunction

	augroup general
		autocmd!
		autocmd TabEnter,BufWinEnter * call s:update_recent_buflist(expand('<amatch>'))
	augroup END
	"}}}
endif
" }}}
" vim-buftabs {{{
if s:bundled('vim-buftabs')
	let g:buftabs_in_statusline   = 1
	let g:buftabs_in_cmdline      = 0
	let g:buftabs_only_basename   = 1
	let g:buftabs_marker_start    = "["
	let g:buftabs_marker_end      = "]"
	let g:buftabs_separator       = "#"
	let g:buftabs_marker_modified = "+"
	let g:buftabs_active_highlight_group = "Visual"
	let g:buftabs_statusline_highlight_group = 'BlackWhite'
endif
"}}}
" buftabs.vim {{{
if s:bundled('buftabs')
	let g:buftabs_in_statusline   = 1
	let g:buftabs_in_cmdline      = 0
	let g:buftabs_only_basename   = 1
	let g:buftabs_marker_start    = "["
	let g:buftabs_marker_end      = "]"
	let g:buftabs_separator       = "#"
	let g:buftabs_marker_modified = "+"
	let g:buftabs_active_highlight_group = "Visual"
	let g:buftabs_statusline_highlight_group = 'BlackWhite'
	if exists('b:anan_usodesu') "{{{
		" MyColor {{{
		highlight StatusMyColor1 ctermfg=black ctermbg=white cterm=none guifg=black guibg=white gui=none
		highlight StatusMyColor2 ctermfg=white ctermbg=black cterm=none guifg=white guibg=black gui=none
		highlight link StatusDefaultColor StatusLine
		"}}}

		set laststatus=2
		set statusline=
		"if exists('g:enable_buftabs') && g:enable_buftabs == s:true
		"set statusline+=%{buftabs}
		"else
		set statusline+=%#StatusMyColor1#
		"set statusline+=%{getcwd()}/
		set statusline+=%{pathshorten(getcwd())}/
		set statusline+=%f
		set statusline+=\ %m
		set statusline+=%#StatusDefaultColor#
		"endif
		set statusline+=%=
		set statusline+=%#StatusMyColor1#
		set statusline+=%{StatuslineTrailingSpaceWarning()}
		set statusline+=%y%{'['.(&fenc!=''?&fenc:&enc).':'.&ff.']'}
		set statusline+=%r
		set statusline+=%h
		set statusline+=%w
		set statusline+=[%{GetFileSize()}]
		set statusline+=[%{GetCharacterCode()}]
		set statusline+=\ %4l/%4LL,%3cC\ %3p%%
		if exists('*WordCount')
			set statusline+=\ [WC=%{WordCount()}]
		endif
		set statusline+=\ (%{GetDate()})

		let g:buftabs_in_statusline   = 1
		let g:buftabs_only_basename   = 1
		let g:buftabs_marker_start    = "["
		let g:buftabs_marker_end      = "]"
		let g:buftabs_separator       = "#"
		let g:buftabs_marker_modified = "+"
		let g:buftabs_active_highlight_group = "Visual"
	endif "}}}
endif
" }}}
" splash.vim {{{
if s:bundled('vim-splash')
	"let g:loaded_splash = 1
	let s:vim_intro = $HOME . "/.vim/bundle/vim-splash/sample/intro"
	if !isdirectory(s:vim_intro)
		call mkdir(s:vim_intro, 'p')
		execute ":lcd " . s:vim_intro . "/.."
		call system('git clone https://gist.github.com/OrgaChem/7630711 intro')
	endif
	let g:splash#path = expand(s:vim_intro . '/vim_intro.txt')
endif
" }}}
" vim-anzu {{{
if s:bundled('vim-anzu')
	nmap n <Plug>(anzu-n-with-echo)zz
	nmap N <Plug>(anzu-N-with-echo)zz
	nmap * <Plug>(anzu-star-with-echo)zz
	nmap # <Plug>(anzu-sharp-with-echo)zz
	"nmap n <Plug>(anzu-mode-n)
	"nmap N <Plug>(anzu-mode-N)
endif
" }}}
" yankround.vim {{{
if s:bundled('yankround.vim')
	nmap p <Plug>(yankround-p)
	xmap p <Plug>(yankround-p)
	nmap P <Plug>(yankround-P)
	nmap gp <Plug>(yankround-gp)
	xmap gp <Plug>(yankround-gp)
	nmap gP <Plug>(yankround-gP)
	nmap <C-p> <Plug>(yankround-prev)
	nmap <C-n> <Plug>(yankround-next)
	let g:yankround_max_history = 100
	if s:bundled('unite.vim')
		nnoremap <Space>p :Unite yankround -direction=botright -toggle<CR>
	endif
endif
" }}}
" vim-gist {{{
if s:bundled('gist-vim')
	let g:github_user = 'b4b4r07'
	let g:github_token = '0417d1aeeb1016c444c5'
	let g:gist_curl_options = "-k"
	let g:gist_detect_filetype = 1
endif
" }}}
" excitetranslate-vim {{{
if s:bundled('excitetranslate-vim')
	xnoremap E :ExciteTranslate<CR>
endif
" }}}
" gundo.vim {{{
if s:bundled('gundo.vim')
	nmap <Leader>U :<C-u>GundoToggle<CR>
	let g:gundo_auto_preview = 0
endif
" }}}
" quickrun.vim {{{
if s:bundled('vim-quickrun')
	let g:quickrun_config = {}
	let g:quickrun_config.markdown = {
				\ 'outputter' : 'null',
				\ 'command'   : 'open',
				\ 'cmdopt'    : '-a',
				\ 'args'      : 'Marked',
				\ 'exec'      : '%c %o %a %s',
				\ }
endif
" }}}
" vimshell {{{
if s:bundled('vimshell')
	let g:vimshell_prompt_expr = 'getcwd()." > "'
	let g:vimshell_prompt_pattern = '^\f\+ > '
	augroup my-vimshell
		autocmd!
		autocmd FileType vimshell
					\ imap <expr> <buffer> <C-n> pumvisible() ? "\<C-n>" : "\<Plug>(vimshell_history_neocomplete)"
	augroup END
endif
" }}}
" skk.vim {{{
if s:bundled('skk.vim')
	set imdisable
	let skk_jisyo = '~/SKK_JISYO.L'
	let skk_large_jisyo = '~/SKK_JISYO.L'
	let skk_auto_save_jisyo = 1
	let skk_keep_state =0
	let skk_egg_like_newline = 1
	let skk_show_annotation = 1
	let skk_use_face = 1
endif
" }}}
" eskk.vim {{{
if s:bundled('eskk.vim')
	set imdisable
	let g:eskk#directory = '~/SKK_JISYO.L'
	let g:eskk#dictionary = { 'path': "~/SKK_JISYO.L", 'sorted': 0, 'encoding': 'utf-8', }
	let g:eskk#large_dictionary = { 'path': "~/SKK_JISYO.L", 'sorted': 1, 'encoding': 'utf-8', }
	let g:eskk#enable_completion = 1
endif
" }}}
" foldCC {{{
if s:bundled('foldCC')
	set foldtext=foldCC#foldtext()
	let g:foldCCtext_head = 'v:folddashes. " "'
	let g:foldCCtext_tail = 'printf(" %s[%4d lines Lv%-2d]%s", v:folddashes, v:foldend-v:foldstart+1, v:foldlevel, v:folddashes)'
	let g:foldCCtext_enable_autofdc_adjuster = 1
endif
" }}}
" portal.vim {{{
if s:bundled('vim-portal')
	nmap <Leader>pb <Plug>(portal-gun-blue)
	nmap <Leader>po <Plug>(portal-gun-orange)
	nnoremap <Leader>pr :<C-u>PortalReset<CR>
endif
" }}}
" restart.vim {{{
if s:bundled('restart.vim')
	if has('gui_running')
		let g:restart_sessionoptions
					\ = 'blank,buffers,curdir,folds,help,localoptions,tabpages'
		command!
					\   RestartWithSession
					\   -bar
					\   let g:restart_sessionoptions = 'blank,curdir,folds,help,localoptions,tabpages'
					\   | Restart
	endif
endif
" }}}
" vim-poslist {{{
if s:bundled('vim-poslist')
	map <C-o> <Plug>(poslist-prev-pos)
	map <C-i> <Plug>(poslist-next-pos)
endif
" }}}
" vim-autocdls {{{
if s:bundled('vim-autocdls')
	let g:autocdls_autols#enable = 1
	let g:autocdls_set_cmdheight = 2
	let g:autocdls_show_filecounter = 1
	let g:autocdls_show_pwd = 0
	let g:autocdls_alter_letter = 1
	let g:autocdls_newline_disp = 0
	let g:autocdls_ls_highlight = 1
	let g:autocdls_lsgrep_ignorecase = 1
endif
" }}}
" vim-shellutils {{{
if s:bundled('vim-shellutils')
	let g:shellutils_disable_commands = ['Ls']
endif
" }}}
" vim-indent-guides {{{
if s:bundled('vim-indent-guides')
	hi IndentGuidesOdd  ctermbg=DarkGreen
	hi IndentGuidesEven ctermbg=Black
	let g:indent_guides_enable_on_vim_startup = 0
	let g:indent_guides_start_level = 1
	let g:indent_guides_auto_colors = 0
	let g:indent_guides_guide_size = 1
endif
" }}}
" }}}1

" Misc: {{{1
" Experimental setup and settings that do not belong to any section
" will be described in this section.
"==============================================================================

call s:mkdir(expand('$HOME/.vim/colors'))

nnoremap <silent> ciy ciw<C-r>0<ESC>:let@/=@1<CR>:noh<CR>
nnoremap <silent> cy   ce<C-r>0<ESC>:let@/=@1<CR>:noh<CR>

function! s:tabdrop(target)
	let target = empty(a:target) ? expand('%:p') : bufname(a:target + 0)
	if !empty(target) && bufexists(target) && buflisted(target)
		execute 'tabedit' target
	else
		echohl WarningMsg | echo "Could not tabedit" | echohl None
	endif
endfunction
command! -nargs=? Tab call s:tabdrop(<q-args>)

function! s:to_fullpath(filename)
	let name = substitute(fnamemodify(a:filename, ":p"), '\', '/', "g")
	if filereadable(name)
		return name
	else
		return a:filename
	endif
endfunction

function! s:remove_swapfile() "{{{
	let save_wilfignore = &wildignore
	setlocal wildignore=
	let target = &directory
	let list = split(glob(target."**/*.sw{p,o}"), '\n')
	for file in list
		call delete(file)
		echo file
	endfor
	let &wildignore = save_wilfignore
endfunction "}}}
command! RemoveSwapfile call <SID>remove_swapfile()

function! s:mkdir(dir)
	if !isdirectory(a:dir)
		call mkdir(a:dir, "p")
	endif
endfunction

function! s:file_complete(A, L, P) "{{{
	let lists = []
	let filelist = glob(getcwd() . "/*")

	for file in split(filelist, "\n")
		if !isdirectory(file)
			call add(lists, fnamemodify(file, ":t"))
		endif
	endfor
	return lists
endfunction
"command! -nargs=1 -complete=customlist,<SID>file_complete Edit edit<bang> <args>
"command! -nargs=1 -complete=customlist,<SID>file_complete Cat call s:cat(<f-args>)
"}}}

augroup cursor-highlight-emphatic "{{{
	autocmd!
	autocmd CursorMoved,CursorMovedI,WinLeave * hi! link CursorLine CursorLine | hi! link CursorColumn CursorColumn
	autocmd CursorHold,CursorHoldI            * hi! link CursorLine Visual     | hi! link CursorColumn Visual
augroup END "}}}
augroup vim-startup-nomodified "{{{
	autocmd!
	autocmd VimEnter * set nomodified
augroup END "}}}
augroup auto-make-directory "{{{
	autocmd!
	autocmd BufWritePre * call s:auto_mkdir(expand('<afile>:p:h'), v:cmdbang)
augroup END "}}}
augroup word-count "{{{
	autocmd!
	autocmd BufWinEnter,InsertLeave,CursorHold * if exists('*WordCount') | call WordCount('char') | endif
augroup END
let s:WordCountStr = ''
let s:WordCountDict = {'word': 2, 'char': 3, 'byte': 4}
"}}}
augroup ctrl-g-information "{{{
	autocmd!
	"autocmd CursorHold,CursorHoldI * redraw
	"autocmd CursorHold,CursorHoldI * execute "normal! 1\<C-g>"
	"autocmd CursorHold,CursorHoldI * execute "echo GetFileInfo()"
augroup END "}}}
augroup vimrc-auto-mkdir "{{{
	autocmd!
	autocmd BufWritePre * call s:auto_mkdir(expand('<afile>:p:h'), v:cmdbang)
	function! s:auto_mkdir(dir, force)
		if !isdirectory(a:dir)
					\   && (a:force
					\       || input("'" . a:dir . "' does not exist. Create? [y/N]") =~? '^y\%[es]$')
			call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
		endif
	endfunction
augroup END "}}}
augroup file-only-window "{{{
	autocmd!
	autocmd BufRead * execute ":only"
augroup END "}}}
augroup cd-file-parentdir "{{{
	autocmd!
	"autocmd BufRead,BufEnter * lcd %:p:h
	autocmd BufRead,BufEnter * execute ":lcd " . expand("%:p:h")
augroup END "}}}
augroup echo-file-path "{{{
	autocmd!
	autocmd WinEnter * execute "normal! 1\<C-g>"
augroup END "}}}
augroup no-comment "{{{
	autocmd!
	autocmd FileType * setlocal formatoptions-=ro
augroup END "}}}
augroup gvim-window-siz "{{{
	autocmd!
	autocmd GUIEnter * setlocal lines=50
	autocmd GUIEnter * setlocal columns=160
augroup END "}}}
augroup only-window-help "{{{
	autocmd!
	"autocmd BufEnter *.jax only
	autocmd Filetype help only
augroup END "}}}

" Launched with -b option {{{
if has('vim_starting') && &binary
	augroup vimrc-xxd
		autocmd!
		autocmd BufReadPost * if &l:binary | setlocal filetype=xxd | endif
	augroup END
endif "}}}

" Add execute permission {{{
if executable('chmod')
	augroup vimrc-autoexecutable
		autocmd!
		autocmd BufWritePost * call s:add_permission_x()
	augroup END

	function! s:add_permission_x()
		let file = expand('%:p')
		if !executable(file)
			if getline(1) =~# '^#!'
						\ || &ft =~ "\\(z\\|c\\|ba\\)\\?sh$"
						\ && input(printf('"%s" is not perm 755. Change mode? [y/N] ', expand('%:t'))) =~? '^y\%[es]$'
				call system("chmod 755 " . shellescape(file))
				redraw | echo "Set permission 755!"
			endif
		endif
	endfunction
endif "}}}

" Restore cursor position {{{
function! s:RestoreCursorPostion()
	if line("'\"") <= line("$")
		normal! g`"
		return 1
	endif
endfunction
if s:enable_restore_cursor_position == s:true
	augroup restore-cursor-position
		autocmd!
		autocmd BufWinEnter * call s:RestoreCursorPostion()
	augroup END
endif "}}}

" View directory {{{
call s:mkdir(expand('$HOME/.vim/view'))
set viewdir=~/.vim/view
set viewoptions-=options
set viewoptions+=slash,unix
augroup vimrc-view
	autocmd!
	autocmd BufLeave * if expand('%') !=# '' && &buftype ==# ''
				\ | mkview
				\ | endif
	autocmd BufReadPost * if !exists('b:view_loaded') &&
				\   expand('%') !=# '' && &buftype ==# ''
				\ | silent! loadview
				\ | let b:view_loaded = 1
				\ | endif
	autocmd VimLeave * call map(split(glob(&viewdir . '/*'), "\n"), 'delete(v:val)')
augroup END "}}}

" Automatically save and restore window size {{{
augroup vim-save-window
	autocmd!
	autocmd VimLeavePre * call s:save_window()
	function! s:save_window()
		let options = [
					\ 'set columns=' . &columns,
					\ 'set lines=' . &lines,
					\ 'winpos ' . getwinposx() . ' ' . getwinposy(),
					\ ]
		call writefile(options, g:save_window_file)
	endfunction
augroup END
let g:save_window_file = expand('$HOME/.vimwinpos')
if s:enable_save_window_position
	if filereadable(g:save_window_file)
		execute 'source' g:save_window_file
	endif
endif "}}}

" MRU {{{
if !s:has_plugin('mru.vim')
	" MRU configuration variables {{{
	if !exists('s:MRU_File')
		if has('unix') || has('macunix')
			let s:MRU_File = $HOME . '/.vim_mru_files'
		else
			let s:MRU_File = $VIM . '/_vim_mru_files'
			if has('win32')
				if $USERPROFILE != ''
					let s:MRU_File = $USERPROFILE . '\_vim_mru_files'
				endif
			endif
		endif
	endif
	"}}}
	function! s:MRU_LoadList() "{{{
		if filereadable(s:MRU_File)
			let s:MRU_files = readfile(s:MRU_File)
			if s:MRU_files[0] =~# '^#'
				call remove(s:MRU_files, 0)
			else
				let s:MRU_files = []
			endif
		else
			let s:MRU_files = []
		endif
	endfunction
	"}}}
	function! s:MRU_SaveList() "{{{
		let l = []
		call add(l, '# Most recently used files list')
		call extend(l, s:MRU_files)
		call writefile(l, s:MRU_File)
	endfunction "}}}
	function! s:MRU_AddList(buf) "{{{
		if s:mru_list_locked
			return
		endif

		let fname = fnamemodify(bufname(a:buf + 0), ':p')
		if fname == ''
			return
		endif

		if &buftype != ''
			return
		endif

		if index(s:MRU_files, fname) == -1
			if !filereadable(fname)
				return
			endif
		endif

		call s:MRU_LoadList()
		call filter(s:MRU_files, 'v:val !=# fname')
		call insert(s:MRU_files, fname, 0)

		"let s:MRU_Max_Entries = 100
		"if len(s:MRU_files) > s:MRU_Max_Entries
		"	call remove(s:MRU_files, s:MRU_Max_Entries, -1)
		"endif

		call s:MRU_SaveList()

		let bname = '__MRU_Files__'
		let winnum = bufwinnr(bname)
		if winnum != -1
			let cur_winnr = winnr()
			call s:MRU_Create_Window()
			if winnr() != cur_winnr
				exe cur_winnr . 'wincmd w'
			endif
		endif
	endfunction "}}}
	function! s:MRU_RemoveList() "{{{
		call s:MRU_LoadList()
		let lnum = line('.')
		call remove(s:MRU_files, line('.')-1)
		call s:MRU_SaveList()
		close
		call s:MRU_Create_Window()
		call cursor(lnum, 1)
	endfunction "}}}
	function! s:MRU_Open_File() range "{{{
		for f in getline(a:firstline, a:lastline)
			if f == ''
				continue
			endif

			let file = substitute(f, '^.*| ','','')
			let winnum = bufwinnr('^' . file . '$')
			if winnum != -1
				exe winnum . 'wincmd w'
			else
				silent! close
			endif
			exe 'edit ' . fnameescape(substitute(file, '\\', '/', 'g'))
		endfor
	endfunction "}}}
	function! s:MRU_Create_Window() "{{{
		if &filetype == 'mru' && bufname("%") ==# '__MRU_Files__'
			quit
			return
		endif

		call s:MRU_LoadList()
		if empty(s:MRU_files)
			echohl WarningMsg | echo 'MRU file list is empty' | echohl None
			return
		endif

		let bname = '__MRU_Files__'
		"let winnum = bufwinnr(bname)
		"if winnum != -1
		"	if winnr() != winnum
		"		exe winnum . 'wincmd w'
		"	endif

		"	setlocal modifiable
		"	" Delete the contents of the buffer to the black-hole register
		"	silent! %delete _
		"else
		" If the __MRU_Files__ buffer exists, then reuse it. Otherwise open
		" a new buffer
		let bufnum = bufnr(bname)
		"if bufnum == -1
		"	let wcmd = bname
		"else
		"	let wcmd = '+buffer' . bufnum
		"endif
		let wcmd = bufnum == -1 ? bname : '+buffer' . bufnum
		let s:MRU_Window_Height = &lines / 3
		exe 'silent! botright ' . s:MRU_Window_Height . 'split ' . wcmd
		"endif

		" Mark the buffer as scratch
		setlocal buftype=nofile
		setlocal bufhidden=delete
		setlocal noswapfile
		setlocal nowrap
		setlocal nobuflisted
		setlocal filetype=mru
		setlocal winfixheight
		setlocal modifiable

		let old_cpoptions = &cpoptions
		set cpoptions&vim

		" Create mappings to select and edit a file from the MRU list
		nnoremap <buffer> <silent> <CR> :call <SID>MRU_Open_File()<CR>
		vnoremap <buffer> <silent> <CR> :call <SID>MRU_Open_File()<CR>
		"nnoremap <buffer> <silent> q    :close<CR>
		"nnoremap <buffer> <silent> R    :call <SID>MRU_RemoveList()<CR>
		"nnoremap <buffer> <silent> K    :call <SID>MRU_RemoveList('force')<CR>
		nnoremap <buffer> <silent> K    :call <SID>MRU_RemoveList()<CR>
		nnoremap <buffer> <silent> S    :setlocal modifiable<CR>:sort<CR>:setlocal nomodifiable<CR>

		" Restore the previous cpoptions settings
		let &cpoptions = old_cpoptions

		let output = copy(s:MRU_files)

		let s:MRU_Auto_Remove_Deadfiles = 1
		if s:MRU_Auto_Remove_Deadfiles
			let idx = 0
			for file in output
				if !filereadable(file)
					call remove(output, idx)
					continue
				endif
				let idx += 1
			endfor
		endif

		silent! 0put =output

		" Delete the empty line at the end of the buffer
		silent! $delete _
		let glist = getline(1, '$')
		let max = 0
		let max_h = 0
		for idx in range(0, len(glist)-1)
			if strlen(fnamemodify(glist[idx], ':t')) > max
				let max = strlen(fnamemodify(glist[idx], ':t'))
			endif
			if strlen(substitute(fnamemodify(glist[idx], ':p:h'), '^.*\/', '', '')) > max_h
				let max_h = strlen(substitute(fnamemodify(glist[idx], ':p:h'), '^.*\/', '', ''))
			endif
		endfor
		for idx in range(0, len(glist)-1)
			let glist[idx] = printf("%-" . max .  "s | %-" . max_h . "s | %s" ,
						\ fnamemodify(glist[idx], ':t'), substitute(fnamemodify(glist[idx], ':p:h'), '^.*\/', '', ''), glist[idx])
		endfor
		silent! %delete _
		call setline(1, glist)
		if glist[idx] == '| '
			silent! $delete _
		endif

		exe 'syntax match Directory display ' . '"'. '|\zs[^|]*\ze|'. '"'
		exe 'syntax match Constant  display ' . '"' . '[^|]*[\/]' . '"'

		setlocal nonumber
		setlocal cursorline

		" Move the cursor to the beginning of the file
		normal! gg

		setlocal nomodifiable
	endfunction "}}}
	" MRU Essentials {{{
	nnoremap <silent><Space>j :MRU<CR>
	let s:mru_list_locked = 0
	" Load the MRU list on plugin startup
	"call s:MRU_LoadList()
	command! -nargs=0 MRU call s:MRU_Create_Window()
	autocmd VimEnter     * call s:MRU_LoadList()
	autocmd BufRead      * call s:MRU_AddList(expand('<abuf>'))
	autocmd BufNewFile   * call s:MRU_AddList(expand('<abuf>'))
	autocmd BufWritePost * call s:MRU_AddList(expand('<abuf>'))
	autocmd QuickFixCmdPre  *grep* let s:mru_list_locked = 1
	autocmd QuickFixCmdPost *grep* let s:mru_list_locked = 0
	"}}}
endif
"}}}

" Loading divided files {{{
let g:local_vimrc = expand('~/.vimrc.local')
if filereadable(g:local_vimrc)
	execute 'source ' . g:local_vimrc
endif
"}}}

" Must be written at the last.  see :help 'secure'.
set secure

" vim:fdm=marker fdc=3 ft=vim ts=2 sw=2 sts=2:
"}}}0
