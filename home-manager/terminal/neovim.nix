{ pkgs, ... }:
{
  home.sessionVariables = {
    VISUAL = "${pkgs.neovim}/bin/nvim";
    EDITOR = "${pkgs.neovim}/bin/nvim";
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
      " change leader to space
      let mapleader=" "

      " minimum cursor distance to top/bottom of file when scrolling
      set scrolloff=5

      " always show line numbers
      set number

      " allow use of mouse
      set mouse=a

      " indicate line wrap
      let &showbreak = '↪'

      " enable tab-completion
      set wildmenu
      " auto-complete to longest existing element, on second tab cycle through possible commands
      set wildmode=list:longest,full

      " ignore compiled files
      set wildignore=*.o,*~,*.pyc

      " ignore temporary file
      set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store

      " show line,position in file in bottom left corner
      set ruler

      " highlight syntax
      syntax enable

      " create shortcut for :noh
      noremap <leader>h :noh<CR>

      " create shortcut for formatting entire file and jump back to original position
      noremap <leader>= gg=G<C-O>

      " Press Esc for normal mode in terminal
      tnoremap <Esc> <C-\><C-n>

      au BufNewFile,BufRead *.txt,*.md,*.tex set complete+=kspell

      " set formatting program
      au FileType json   setlocal equalprg=python\ -m\ json.tool
      au FileType rust   setlocal equalprg=rustfmt
      "au FileType rust   setlocal foldmethod=syntax
      au FileType python setlocal equalprg=autopep8\ -aaaaaaa\ -

      " sort comma separated line of numbers
      "noremap <leader>s :s/.*/\=join(sort(split(submatch(0), '\s*,\s*'), 'N'), ', ')<CR>:noh<CR>

      " auto-indent lines
      set autoindent

      " always show signcolumns
      set signcolumn=yes
    '';
  };
}
