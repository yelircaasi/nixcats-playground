{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (inputs.nixCats) utils;
    luaPath = "${./.}";
    forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
    extra_pkg_config = {allowUnfree = true;};
    dependencyOverlays = [(utils.standardPluginOverlay inputs)];
    categoryDefinitions = {
      pkgs,
      settings,
      categories,
      extra,
      name,
      mkNvimPlugin,
      ...
    } @ packageDef: {
      lspsAndRuntimeDeps = {
        general = with pkgs; [
          universal-ctags
          ripgrep
          fd
        ];
        lint = with pkgs; [
        ];
        debug = with pkgs; {
          go = [delve];
        };
        go = with pkgs; [
          gopls
          gotools
          go-tools
          gccgo
        ];
        format = with pkgs; [
        ];
        neonixdev = {
          inherit (pkgs) nix-doc lua-language-server nixd;
        };
      };

      startupPlugins = {
        debug = with pkgs.vimPlugins; [
          nvim-nio
        ];
        general = with pkgs.vimPlugins; {
          always = [
            lze
            vim-repeat
            plenary-nvim
          ];
          extra = [
            oil-nvim
            nvim-web-devicons
          ];
        };
        themer = with pkgs.vimPlugins; (
          builtins.getAttr (categories.colorscheme or "onedark") {
            "onedark" = onedark-nvim;
            "catppuccin" = catppuccin-nvim;
            "catppuccin-mocha" = catppuccin-nvim;
            "tokyonight" = tokyonight-nvim;
            "tokyonight-day" = tokyonight-nvim;
          }
        );
      };

      optionalPlugins = {
        debug = with pkgs.vimPlugins; {
          default = [
            nvim-dap
            nvim-dap-ui
            nvim-dap-virtual-text
          ];
          go = [nvim-dap-go];
        };
        lint = with pkgs.vimPlugins; [
          nvim-lint
        ];
        format = with pkgs.vimPlugins; [
          conform-nvim
        ];
        markdown = with pkgs.vimPlugins; [
          markdown-preview-nvim
        ];
        neonixdev = with pkgs.vimPlugins; [
          lazydev-nvim
        ];
        general = {
          cmp = with pkgs.vimPlugins; [
            # cmp stuff
            nvim-cmp
            luasnip
            friendly-snippets
            cmp_luasnip
            cmp-buffer
            cmp-path
            cmp-nvim-lua
            cmp-nvim-lsp
            cmp-cmdline
            cmp-nvim-lsp-signature-help
            cmp-cmdline-history
            lspkind-nvim
          ];
          treesitter = with pkgs.vimPlugins; [
            nvim-treesitter-textobjects
            nvim-treesitter.withAllGrammars
          ];
          telescope = with pkgs.vimPlugins; [
            telescope-fzf-native-nvim
            telescope-ui-select-nvim
            telescope-nvim
          ];
          always = with pkgs.vimPlugins; [
            nvim-lspconfig
            lualine-nvim
            gitsigns-nvim
            vim-sleuth
            vim-fugitive
            vim-rhubarb
            nvim-surround
          ];
          extra = with pkgs.vimPlugins; [
            fidget-nvim
            # lualine-lsp-progress
            which-key-nvim
            comment-nvim
            undotree
            indent-blankline-nvim
            vim-startuptime
          ];
        };
      };

      sharedLibraries = {
        general = with pkgs; [];
      };

      environmentVariables = {
        test = {
          default = {
            CATTESTVARDEFAULT = "It worked!";
          };
          subtest1 = {
            CATTESTVAR = "It worked!";
          };
          subtest2 = {
            CATTESTVAR3 = "It didn't work!";
          };
        };
      };

      extraWrapperArgs = {
        test = [
          ''--set CATTESTVAR2 "It worked again!"''
        ];
      };

      extraPython3Packages = {
        test = _: [];
      };
      extraLuaPackages = {
        general = [(_: [])];
      };

      extraCats = {
        test = [
          ["test" "default"]
        ];
        debug = [
          ["debug" "default"]
        ];
        go = [
          ["debug" "go"] # yes it has to be a list of lists
        ];
      };
    };

    packageDefinitions = {
      nixCats = {pkgs, ...} @ misc: {
        settings = {
          aliases = ["vim" "vimcat"];
          wrapRc = true;
          configDirName = "nixCats-nvim";
        };
        categories = {
          markdown = true;
          general = true;
          lint = true;
          format = true;
          neonixdev = true;
          test = {
            subtest1 = true;
          };

          lspDebugMode = false;
          themer = true;
          colorscheme = "onedark";
        };
        extra = {
          nixdExtras = {
            nixpkgs = nixpkgs;
          };
        };
      };
      regularCats = {pkgs, ...} @ misc: {
        settings = {
          wrapRc = false;
          configDirName = "nixCats-nvim";

          aliases = ["testCat"];

        };
        categories = {
          markdown = true;
          general = true;
          neonixdev = true;
          lint = true;
          format = true;
          test = true;
          lspDebugMode = false;
          themer = true;
          colorscheme = "catppuccin";
        };
        extra = {
          nixdExtras = {
            nixpkgs = nixpkgs;
          };
          # yes even tortured inputs work.
          theBestCat = "says meow!!";
          theWorstCat = {
            thing'1 = ["MEOW" '']]' ]=][=[HISSS]]"[[''];
            thing2 = [
              {
                thing3 = ["give" "treat"];
              }
              "I LOVE KEYBOARDS"
              (utils.n2l.types.inline-safe.mk ''[[I am a]] .. [[ lua ]] .. type("value")'')
            ];
            thing4 = "couch is for scratching";
          };
        };
      };
    };

    defaultPackageName = "nixCats";
  in
    forEachSystem (system: let
      nixCatsBuilder =
        utils.baseBuilder luaPath {
          inherit nixpkgs system dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions;
      defaultPackage = nixCatsBuilder defaultPackageName;
      pkgs = import nixpkgs {inherit system;};
    in {
      packages = utils.mkAllWithDefault defaultPackage;
      devShells = {
        default = pkgs.mkShell {
          name = defaultPackageName;
          packages = [defaultPackage];
          inputsFrom = [];
          shellHook = ''
          '';
        };
      };
    })
    // (let
      nixosModule = utils.mkNixosModules {
        inherit
          defaultPackageName
          dependencyOverlays
          luaPath
          categoryDefinitions
          packageDefinitions
          extra_pkg_config
          nixpkgs
          ;
      };
      homeModule = utils.mkHomeModules {
        inherit
          defaultPackageName
          dependencyOverlays
          luaPath
          categoryDefinitions
          packageDefinitions
          extra_pkg_config
          nixpkgs
          ;
      };
    in {
      overlays =
        utils.makeOverlays luaPath {
          inherit nixpkgs dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions
        defaultPackageName;

      nixosModules.default = nixosModule;
      homeModules.default = homeModule;

      inherit utils nixosModule homeModule;
      inherit (utils) templates;
    });

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/ae2fb9f1fb5fcf17fb59f25c2a881c170c501d6f";
    nixCats.url = "github:BirdeeHub/nixCats-nvim/0c0b02bea3dbdff81bfb38c89a4c4799a43431e6";
  };
}
