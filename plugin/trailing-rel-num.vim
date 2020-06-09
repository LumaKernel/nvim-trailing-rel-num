let s:ns = nvim_create_namespace('nvim-trailing-rel-num')
let s:Highlight = 'TrailingRelNum'

let g:traling_rel_num_blacklist = get(g:, 'traling_rel_num_blacklist', [
      \   'startify',
      \ ])

func! s:check_buf(bufnum) abort
  let filetype = getbufvar(a:bufnum, '&filetype')
  if index(g:traling_rel_num_blacklist, filetype) >= 0
    return 0
  endif
  return 1
endfunc

func! s:clean() abort
  let bufnum = bufnr()
  call nvim_buf_clear_namespace(bufnum, s:ns, 0, -1)
  return ''
endfunc

func! s:refresh() abort
  let [bufnum, lnum; _] = getcurpos()
  if !s:check_buf(bufnum)
    return ''
  endif
  call nvim_buf_clear_namespace(bufnum, s:ns, 0, -1)
  let vis_start = line('w0')
  let vis_end = line('w$')
  for i in range(vis_start, vis_end)
    let str_to_show = i == lnum ? '' : string(abs(i - lnum))
    call nvim_buf_set_virtual_text(
          \   bufnum,
          \   s:ns,
          \   i - 1,
          \   [
          \     [
          \       str_to_show,
          \       s:Highlight
          \     ],
          \   ],
          \   {}
          \ )
  endfor
  return ''
endfunc

augroup nvim-trailing-rel-num
  autocmd!
  autocmd WinLeave,BufWinLeave,BufLeave * call s:clean()
  autocmd CursorMoved,WinEnter,BufEnter,BufWinEnter,BufNewFile,VimEnter,WinNew * call s:refresh()
augroup END
