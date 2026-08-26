{
  pkgs,
  lib,
  config,
  ...
}: let
  shellAliases = {
    lg = "lazygit";
  };
  cfg = config.modules.dev.lazygit;
in {
  options.modules.dev.lazygit = {
    enable = lib.mkEnableOption "Enable lazygit";
  };
  config = lib.mkIf cfg.enable {
    programs.lazygit = {
      enable = true;
      package = pkgs.unstable.lazygit;
      settings = {
        keybinding.universal = {
          jumpToBlock = ["1" "2" "3" "4" "6"];
          focusMainView = "5";
        };
        git = {
          log.order = "default";
          parseEmoji = true;
          overrideGpg = true;
          diffRenderers = [
            {
              colorArg = "always";
              command = "delta --dark --paging=never"; # --tabs 2
            }
          ];
        };
        update.method = "never";
        gui = {
          border = "single";
          switchTabsWithPanelJumpKeys = true;
          showBranchCommitHash = false;
          theme = {
            activeBorderColor = ["#89b4fa" "bold"];
            inactiveBorderColor = ["#a6adc8"];
            optionsTextColor = ["#89b4fa"];
            selectedLineBgColor = ["#313244"];
            cherryPickedCommitBgColor = ["#45475a"];
            cherryPickedCommitFgColor = ["#89b4fa"];
            unstagedChangesColor = ["#f38ba8"];
            defaultFgColor = ["#cdd6f4"];
            searchingActiveBorderColor = ["#f9e2af"];
          };
          authorColors."*" = "#b4befe";
        };
        customCommands = [
          {
            key = "C";
            command = "git cz";
            context = "files";
            loadingText = "opening commitizen commit tool";
            output = "terminal";
          }
          {
            key = "E";
            description = "Add empty commit";
            context = "commits";
            command = "git commit --allow-empty -m 'empty commit'";
            loadingText = "Committing empty commit...";
          }
          {
            key = "f";
            command = "git difftool -y {{.SelectedLocalCommit.Sha}} -- {{.SelectedCommitFile.Name}}";
            context = "commitFiles";
            description = "Compare (difftool) with local copy";
          }
          {
            key = "<c-c>";
            description = "commit as non-default author";
            command = ''git commit -m "{{index .PromptResponses 0}}" --author="{{index .PromptResponses 1}} <{{index .PromptResponses 2}}>"'';
            context = "files";
            prompts = [
              {
                type = "input";
                title = "Commit Message";
                initialValue = "";
              }
              {
                type = "input";
                title = "Author Name";
                initialValue = "";
              }
              {
                type = "input";
                title = "Email Address";
                initialValue = "";
              }
            ];
            loadingText = "commiting";
          }
          {
            key = "<c-a>";
            description = "Pick AI commit";
            command = ''
              aichat "Please suggest 10 commit messages, given the following diff:

              \`\`\`diff
              $(git diff --cached)
              \`\`\`

              **Criteria:**

              1. **Format:** Each commit message must follow the conventional commits format, which is \`<type>(<scope>): <description>\`.
              2. **Relevance:** Avoid mentioning a module name unless it's directly relevant to the change.
              3. **Enumeration:** List the commit messages from 1 to 10.
              4. **Clarity and Conciseness:** Each message should clearly and concisely convey the change made.

              **Commit Message Examples:**

              - fix(app): add password regex pattern
              - test(unit): add new test cases
              - style: remove unused imports
              - refactor(pages): extract common code to \`utils/wait.ts\`

              **Recent Commits on Repo for Reference:**

              \`\`\`
              $(git log -n 10 --pretty=format:'%h %s')
              \`\`\`

              **Output Template**

              Follow this output template and ONLY output raw commit messages without spacing, numbers or other decorations.

              fix(app): add password regex pattern
              test(unit): add new test cases
              style: remove unused imports
              refactor(pages): extract common code to \`utils/wait.ts\`


              **Instructions:**

              - Take a moment to understand the changes made in the diff.
              - Think about the impact of these changes on the project (e.g., bug fixes, new features, performance improvements, code refactoring, documentation updates). It's critical to my career you abstract the changes to a higher level and not just describe the code changes.
              - Generate commit messages that accurately describe these changes, ensuring they are helpful to someone reading the project's history.
              - Remember, a well-crafted commit message can significantly aid in the maintenance and understanding of the project over time.
              - If multiple changes are present, make sure you capture them all in each commit message.

              Keep in mind you will suggest 10 commit messages. Only 1 will be used. It's better to push yourself (esp to synthesize to a higher level) and maybe wrong about some of the 10 commits because only one needs to be good. I'm looking for your best commit, not the best average commit. It's better to cover more scenarios than include a lot of overlap.

              Write your 10 commit messages below in the format shown in Output Template section above." \
                | fzf --height 40% --border --ansi --preview "echo {}" --preview-window=up:wrap \
                | xargs -I {} bash -c '
                    COMMIT_MSG_FILE=$(mktemp)
                    echo "{}" > "$COMMIT_MSG_FILE"
                    ''${EDITOR:-vim} "$COMMIT_MSG_FILE"
                    if [ -s "$COMMIT_MSG_FILE" ]; then
                        git commit -F "$COMMIT_MSG_FILE"
                    else
                        echo "Commit message is empty, commit aborted."
                    fi
                    rm -f "$COMMIT_MSG_FILE"'
            '';
            context = "files";
            output = "terminal";
          }
        ];
        disableStartupPopups = true;
        os = {
          open = "xdg-open {{filename}}";
          openLink = "xdg-open {{link}}";
        };
      };
    };

    catppuccin.lazygit = {
      enable = false;
    };

    programs.zsh.zsh-abbr.abbreviations = shellAliases;
  };
}
