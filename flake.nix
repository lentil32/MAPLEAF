{
  description = "Python venv development template";

  inputs = {
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      ...
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShellNoCC {
          name = "python-venv";
          venvDir = "./.venv";

          buildInputs = with pkgs.python3Packages; [
            # A Python interpreter including the 'venv' module is required to bootstrap
            # the environment.
            python

            # This executes some shell code to initialize a venv in $venvDir before
            # dropping into the shell
            venvShellHook

            # Those are dependencies that we would like to use from nixpkgs, which will
            # add them to PYTHONPATH and thus make them accessible from within the venv.
            numpy
            pandas
            scipy
            matplotlib
          ];

          # Run this command, only after creating the virtual environment
          postVenvCreation = ''
            unset SOURCE_DATE_EPOCH
            pip install -e .
            python3 installOptionalPackages.py
            pip install -r requirements_Dev.txt
          '';

          # Now we can execute any commands within the virtual environment.
          # This is optional and can be left out to run pip manually.
          postShellHook = ''
            # allow pip to install wheels
            unset SOURCE_DATE_EPOCH
          '';
        };
      }
    );
}
