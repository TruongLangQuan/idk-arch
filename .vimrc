" --- PHẦN 1: DANH SÁCH PLUGIN ---
call plug#begin('~/.vim/plugged')

" Giao diện & Trải nghiệm (VS Code & Antigravity)
Plug 'tomasiser/vim-code-dark'         " Theme VS Code
Plug 'vim-airline/vim-airline'         " Thanh trạng thái xịn
Plug 'psliwka/vim-smoothie'            " Cuộn mượt (giống Antigravity)
Plug 'Yggdroot/indentLine'             " Vạch kẻ thụt đầu dòng
Plug 'ryanoasis/vim-devicons'          " Icon đẹp (Cần cài Nerd Font trên máy)

" Tính năng IDE (Giống VS Code)
Plug 'neoclide/coc.nvim', {'branch': 'release'} " Autocomplete (LSP)
Plug 'preservim/nerdtree'                        " Thanh sidebar file
Plug 'Xuyuanp/nerdtree-git-plugin'               " Hiện trạng thái Git trong NERDTree
Plug 'junegunn/fzf.vim'                             " Tìm file nhanh (Ctrl+P)
Plug 'airblade/vim-gitgutter'                    " Báo thay đổi Git ở lề
Plug 'tpope/vim-fugitive'                        " Git cực mạnh (Commit, Push, Pull)
Plug 'rbong/vim-flog'                            " Xem Git Graph (Lịch sử đồ thị)
Plug 'kdheepak/lazygit.nvim'                     " Lazygit trong Vim (Xịn nhất)

" Tiện ích soạn thảo cực mạnh
Plug 'tpope/vim-surround'              " Đổi nhanh ngoặc: cs\"'
Plug 'tpope/vim-commentary'            " Comment nhanh: gcc
Plug 'jiangmiao/auto-pairs'            " Tự đóng ngoặc
Plug 'terryma/vim-multiple-cursors'    " Đa con trỏ (Ctrl+N)
Plug 'alvan/vim-closetag'              " Tự đóng tag HTML
Plug 'junegunn/vim-peekaboo'           " Xem lịch sử Copy/Paste

call plug#end()

" --- PHẦN 2: CẤU HÌNH CƠ BẢN ---
syntax on
set number              " Hiện số dòng
set relativenumber      " Số dòng tương đối
set mouse=a             " Dùng chuột để click/cuộn/kéo cửa sổ
set clipboard=unnamedplus " Copy/Paste ra ngoài hệ thống
set tabstop=4           " 1 Tab = 4 khoảng trắng
set shiftwidth=4
set expandtab
set termguicolors       " Màu sắc chuẩn 24-bit

" Kích hoạt Theme (Nếu lỗi E185, hãy chạy :PlugInstall trước)
silent! colorscheme codedark

" --- PHẦN 3: PHÍM TẮT & TIỆN ÍCH ---

" Ctrl + B: Bật/Tắt cây thư mục
nnoremap <C-b> :NERDTreeToggle<CR>

" Ctrl + P: Tìm file nhanh
nnoremap <C-p> :Files<CR>

" Ctrl + F: Tìm chữ trong project (cần cài ripgrep)
nnoremap <C-f> :Rg<CR>

" Alt + j/k: Di chuyển dòng code lên/xuống (Giống VS Code)
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Dùng Tab để chọn gợi ý code (Coc.nvim)
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" --- PHẦN 4: CẤU HÌNH TERMINAL (KIỂU VS CODE) ---

" Mở terminal ở dưới cùng, cao 17 dòng, tự đóng khi gõ exit
nnoremap <C-t> :botright terminal ++rows=17 ++close<CR>

" Nhấn Esc để thoát chế độ gõ trong Terminal (để nhảy lên sửa code)
tnoremap <Esc> <C-\><C-n>

" Phím tắt Alt + Mũi tên để di chuyển giữa Code và Terminal cực nhanh
tnoremap <A-Up> <C-\><C-n><C-w>k
tnoremap <A-Down> <C-\><C-n><C-w>j
nnoremap <A-Up> <C-w>k
nnoremap <A-Down> <C-w>j

" Tự động vào chế độ Insert khi click chuột vào cửa sổ Terminal
autocmd TerminalOpen * startinsert

" --- PHẦN 5: CẤU HÌNH GIT (GIỐNG VS CODE SOURCE CONTROL) ---

" Mở Lazygit (Source Control xịn nhất) - Phím tắt Ctrl+Shift+G
nnoremap <C-S-g> :LazyGit<CR>

" NERDTree Git Icons: Tự động cập nhật biểu tượng khi có thay đổi
let g:NERDTreeGitStatusUseNerdFonts = 1 " Dùng icon của Nerd Font
let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ "Unknown"   : "?"
    \ }

" Xem Git Graph (Ctrl+G rồi nhấn H)
nnoremap <C-g>h :Flog<CR>
