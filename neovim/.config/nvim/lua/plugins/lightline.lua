-- Pretty status line

function setup()
  vim.opt.showmode = false

  vim.g.lightline = {
    ['colorscheme'] = 'nord';
    ['active'] = {
      ['left'] = {
        { 'mode', 'paste' };
        { 'readonly', 'filename' };
        { 'lastbuf' };
      },
      ['right'] = {
        { 'lineinfo' };
        { 'percent' };
        { 'filetype' };
      }
    },
  }
end

return {
  name = 'itchyny/lightline.vim',
  setup = setup,
}
