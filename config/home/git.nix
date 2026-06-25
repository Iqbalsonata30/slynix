{pkgs, ...}: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Iqbal Sonata";
        email = "iqbalsonata2@gmail.com";
      };
      pull.rebase = true;
      diff.tool = "vimdiff";
      difftool.prompt = false;
      merge.tool = "vimdiff";

    };
  };
  programs.git-credential-oauth.enable = true;

  programs.gh.enable = true;
  programs.gh.settings.git_protocol = "ssh";
  programs.gh.settings.aliases = {
    co = "pr checkout";
    pv = "pr view";
  };
}
