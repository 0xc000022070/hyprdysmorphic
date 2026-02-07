#!/usr/bin/env sh

set -e

flake_lock="${FLAKE_LOCK:-./flake.lock}"
flake_nix="${FLAKE_NIX:-./flake.nix}"

rev=$(jq -r '.nodes.hyprland.locked.rev // empty' "$flake_lock")
narHash=$(jq -r '.nodes.hyprland.locked.narHash // empty' "$flake_lock")

if [ -z "$rev" ] || [ -z "$narHash" ]; then
	echo "Could not read hyprland rev or narHash from $flake_lock" >&2
	exit 1
fi

# Escape for sed: rev is a hex string, narHash contains + and / which we use as sed delimiter
# Use | as sed delimiter to avoid clashing with sha256 value
current_rev=$(sed -n 's/.*rev = "\([0-9a-f]\{40\}\)".*/\1/p' "$flake_nix" | head -n1)
current_sha=$(sed -n 's/.*sha256 = "\(sha256-[^"]*\)".*/\1/p' "$flake_nix" | head -n1)

if [ "$current_rev" = "$rev" ] && [ "$current_sha" = "$narHash" ]; then
	echo "Override already in sync: rev=$rev sha256=$narHash"
	exit 0
fi

echo "Syncing override: rev $current_rev -> $rev, sha256 -> $narHash"

sed -i "s|rev = \"[0-9a-f]\{40\}\";|rev = \"$rev\";|" "$flake_nix"
sed -i "s|sha256 = \"sha256-[^\"]*\";|sha256 = \"$narHash\";|" "$flake_nix"

echo "Updated $flake_nix: rev=$rev sha256=$narHash"
