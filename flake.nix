{
  description = "Reproduction: shell-lsp ignores options set by a sourced zsh file";

  inputs.released.url = "github:stubbedev/shell-lsp/v0.5.21";

  outputs =
    { self, released }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = f: released.inputs.nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      packages = forAllSystems (system: {
        # The test suite already ran upstream; skipping it here keeps the reproduction fast.
        shell-lsp = released.packages.${system}.default.overrideAttrs { doCheck = false; };
      });

      apps = forAllSystems (
        system:
        let
          pkgs = released.inputs.nixpkgs.legacyPackages.${system};
          shell-lsp = self.packages.${system}.shell-lsp;
          before = pkgs.writeShellApplication {
            name = "before";
            runtimeInputs = [ shell-lsp ];
            text = ''
              cd ${self}
              echo "shell-lsp v0.5.21 (Nix stamps it with its commit date: $(shell-lsp --version))"
              shell-lsp check --profile strict -f gcc bin || true
            '';
          };
        in
        {
          before = {
            type = "app";
            program = "${before}/bin/before";
          };
          default = self.apps.${system}.before;
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = released.inputs.nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [
              pkgs.just
              pkgs.zsh
              self.packages.${system}.shell-lsp
            ];
          };
        }
      );
    };
}
