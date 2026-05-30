-- ==============================================================================
--                    NEOVIM LUA OPTIONS & KEYMAPS (VS Code Style)
-- ==============================================================================

-- Bật Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Cấu hình cơ bản (Chuẩn hệ thống)
vim.opt.number = true                 -- Hiện số dòng
vim.opt.relativenumber = true         -- Hiện số dòng tương đối
vim.opt.mouse = "a"                   -- Bật chuột toàn diện
vim.opt.clipboard = "unnamedplus"     -- Đồng bộ Clipboard với hệ thống
vim.opt.termguicolors = true          -- Bật màu sắc chuẩn 24-bit
vim.opt.encoding = "utf-8"            -- Mã hóa UTF-8 chuẩn

-- Thiết lập thụt lề (Indentation)
vim.opt.expandtab = true              -- Chuyển Tab thành Space
vim.opt.tabstop = 4                   -- 1 Tab = 4 khoảng trắng
vim.opt.shiftwidth = 4                -- 4 khoảng trắng khi dịch lề
vim.opt.softtabstop = 4               -- Thụt lề mềm 4 khoảng trắng
vim.opt.smarttab = true               -- Nhấn tab chèn space thông minh
vim.opt.autoindent = true             -- Tự động thụt lề dòng mới
vim.opt.smartindent = true            -- Thụt lề thông minh theo cú pháp

-- Tối ưu hóa tìm kiếm
vim.opt.ignorecase = true             -- Không phân biệt hoa/thường khi tìm kiếm
vim.opt.smartcase = true              -- Tự phân biệt hoa/thường khi gõ chữ hoa
vim.opt.hlsearch = true               -- Highlight từ khóa tìm kiếm
vim.opt.incsearch = true              -- Tìm kiếm ngay khi đang nhập chữ

-- Tối ưu hóa tốc độ & lưu trữ
vim.opt.backup = false                -- Tránh tạo file backup
vim.opt.writebackup = false           -- Tránh tạo file backup khi đang ghi
vim.opt.swapfile = false              -- Tránh tạo file swap (.swp)
vim.opt.updatetime = 300              -- Phản hồi LSP và GitGutter nhanh hơn (300ms)

-- ==============================================================================
--                               PHÍM TẮT & TIỆN ÍCH
-- ==============================================================================

-- Alt + j/k: Di chuyển dòng code đang chọn lên/xuống (VS Code style)
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { silent = true })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { silent = true })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { silent = true })
