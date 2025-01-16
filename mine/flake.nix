{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";

  outputs = {
    self,
    nixpkgs,
    nixCats,
    ...
  } @ inputs: let
    inherit (nixCats) utils;
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
        general = with pkgs; [];
      };

      startupPlugins = {
        gitPlugins = with pkgs.neovimPlugins; [];
        general = with pkgs.vimPlugins; [];
      };

      optionalPlugins = {
        gitPlugins = with pkgs.neovimPlugins; [];
        general = with pkgs.vimPlugins; [];
      };

      sharedLibraries = {
        general = with pkgs; [];
      };

      environmentVariables = {
        test = {
          CATTESTVAR = "It worked!";
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
        test = [(_: [])];
      };
    };

    packageDefinitions = {
      nixcats = {pkgs, ...}: {
        settings = {
          wrapRc = true;
          aliases = ["testAlias"];
        };
        categories = {
          general = true;
          gitPlugins = true;
          customPlugins = true;
          test = true;
          example = {
            youCan = "add more than just booleans";
            toThisSet = [
              "and the contents of this categories set"
              "will be accessible to your lua with"
              "nixCats('path.to.value')"
              "see :help nixCats"
            ];
          };
        };
      };
    };
    defaultPackageName = "nixcats";
  in
    forEachSystem (system: let
      defaultPackage = utils.baseBuilder luaPath {inherit nixpkgs system dependencyOverlays extra_pkg_config;} categoryDefinitions packageDefinitions defaultPackageName;

      pkgs = import nixpkgs {inherit system;};

      nixosModule =
        utils.mkNixosModules
        {
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

      homeModule =
        utils.mkHomeModules
        {
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
      packages = utils.mkAllWithDefault defaultPackage;

      devShells.default =
        pkgs.mkShell
        {
          name = defaultPackageName;
          packages = [defaultPackage];
          inputsFrom = [];
          shellHook = '''';
        };

      overlays =
        utils.makeOverlays
        luaPath
        {inherit nixpkgs dependencyOverlays extra_pkg_config;}
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
