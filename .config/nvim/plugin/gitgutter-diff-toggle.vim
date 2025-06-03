if exists('g:loaded_gitgutter_diff_toggle')
    finish
endif
let g:loaded_gitgutter_diff_toggle = 1

let g:gitgutter_diff_win_open = 0

function! ToggleGitGutterDiff()
    if g:gitgutter_diff_win_open
        " If diff is open, close it
        diffoff!
        " Find and close the diff window
        for winnr in range(1, winnr('$'))
            if getwinvar(winnr, '&buftype') ==# 'nofile'
                execute winnr.'wincmd c'
                let g:gitgutter_diff_win_open = 0
                return
            endif
        endfor
    else
        " If diff is closed, open it
        GitGutterDiffOrig
        let g:gitgutter_diff_win_open = 1
    endif
endfunction
