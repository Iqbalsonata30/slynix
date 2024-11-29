{ pkgs,lib,...}:


{
  programs.tmux = {
    enable = true;
    mouse = true;
    aggressiveResize = true;
    baseIndex = 1;
    newSession = true;
    shortcut = "f";
    terminal = "xterm-256color";
    keyMode = "vi";
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = dracula;
        extraConfig = ''
            set -g @dracula-plugins "git"
            set -g @dracula-show-left-icon session
            set -g @dracula-show-fahrenheit false
        '';
      }
      {
        plugin = resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = continuum;
        extraConfig = ''
            set -g @continuum-restore 'off'
            set -g @continuum-save-interval '5' # minutes
        '';
      }
      {
        plugin = open;
      }
      {
        plugin = yank;
        extraConfig = # tmux
          ''
          bind Enter copy-mode # enter copy mode

          set -g @shell_mode 'vi'
          set -g @yank_selection_mouse 'clipboard'

          run -b 'tmux bind -t vi-copy v begin-selection 2> /dev/null || true'
          run -b 'tmux bind -T copy-mode-vi v send -X begin-selection 2> /dev/null || true'
          run -b 'tmux bind -t vi-copy C-v rectangle-toggle 2> /dev/null || true'
          run -b 'tmux bind -T copy-mode-vi C-v send -X rectangle-toggle 2> /dev/null || true'
          run -b 'tmux bind -t vi-copy y copy-selection 2> /dev/null || true'
          run -b 'tmux bind -T copy-mode-vi y send -X copy-selection-and-cancel 2> /dev/null || true'
          run -b 'tmux bind -t vi-copy Escape cancel 2> /dev/null || true'
          run -b 'tmux bind -T copy-mode-vi Escape send -X cancel 2> /dev/null || true'
          run -b 'tmux bind -t vi-copy H start-of-line 2> /dev/null || true'
          run -b 'tmux bind -T copy-mode-vi H send -X start-of-line 2> /dev/null || true'
          run -b 'tmux bind -t vi-copy L end-of-line 2> /dev/null || true'
          run -b 'tmux bind -T copy-mode-vi L send -X end-of-line 2> /dev/null || true'
          '';
      }
      {
        plugin = copycat;
      }
      {
        plugin = logging;
      }
    ];
    extraConfig = ''
        set-option -ga terminal-overrides ",xterm-256color:Tc"


        bind b split-window -h -c "#{pane_current_path}"
        bind v split-window -v -c "#{pane_current_path}"

        bind r source-file ~/.config/tmux/tmux.conf \: display-message "Loaded tmux config"

        color_status_text="colour245"
        color_window_off_status_bg="colour238"
        color_light="white" #colour015
        color_dark="colour232" # black= colour232
        color_window_off_status_current_bg="colour254"

        bind -r k select-pane -U
        bind -r j select-pane -D
        bind -r h select-pane -R
        bind -r l select-pane -L
    '';
  };
}
