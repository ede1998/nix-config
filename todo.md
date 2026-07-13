# Next Steps

- investigate weirdness: https://github.com/maxking/forgejo-create-pr/pull/1#issuecomment-4826760192
- CI workflow to update nix-config
- CI workflow to check nix-config
  - see ci-tests for caching stuff or just switch to a self hosted attic cache?
  - sounds useful: https://git.sysctl.io/Actions/ci
- custom package update
- fix config (xerox drivers no longer available for download -> saved locally in _wip)
- update config to 26.05
 - ollama vulkan and # Environment="OLLAMA_CONTEXT_LENGTH=64000"
- switch to sops.nix