{
  plugins = {
    nvim-autopairs = {
      enable = true;
      settings = {
        check_ts = true;
        fast_wrap = {
          chars = ["{" "[" "(" "\"" "'"];
          offset = 0;
          pattern = "[=[[%'%\"%>%]%)%}%,%]]=]";
          keys = "qwertyuiopzxcvbnmasdfghjkl";
          check_comma = true;
          highlight = "PmenuSel";
          highlight_grey = "LineNr";
        };
      };
    };
  };
}
