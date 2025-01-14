#!/usr/bin/env bash
set -euo pipefail

rm -rf asdf-plugins
git clone --depth 1 https://github.com/mise-plugins/registry asdf-plugins
rm -f src/default_shorthands.rs

asdf_plugins=$(ls asdf-plugins/plugins)
num_plugins=$(echo "$asdf_plugins" | wc -l | tr -d ' ')
trusted=()

cat >src/default_shorthands.rs <<EOF
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// !GENERATED FILE!
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// !GENERATED FILE!
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// !GENERATED FILE!
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// This file is generated by scripts/update-shorthand-repo.sh
// DO NOT EDIT THIS FILE MANUALLY. YOUR PR WILL BE REJECTED.
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// !GENERATED FILE!
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// !GENERATED FILE!
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// !GENERATED FILE!
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

use once_cell::sync::Lazy;
use std::collections::{HashSet, HashMap};

#[rustfmt::skip]
pub static DEFAULT_SHORTHANDS: Lazy<HashMap<&'static str, &'static str>> =
    Lazy::new(|| HashMap::from([
EOF
count=0
for plugin in $asdf_plugins; do
  file="asdf-plugins/plugins/$plugin"
  repository=$(grep -e '^repository = ' "$file")
  repository="${repository/#repository = /}"
  printf "\033[2K[%03d/%d] %s\r" $((++count)) "$num_plugins" "$repository"
  if [[ $repository == "https://github.com/mise-plugins/"* ]]; then
    trusted+=("$plugin")
  elif grep -qe '^first-party = true' "$file"; then
    trusted+=("$plugin")
  fi
  #  if [[ $repository == "https://github.com/"* ]]; then
  #    owner=${repository#*github.com/}
  #    owner=${owner%/*}
  #    repo=${repository#*github.com/*/}
  #    repo=${repo%.git}
  #    stars["$owner/$repo"]="$plugin"
  #  fi
  echo "    (\"$plugin\", \"$repository\")," >>src/default_shorthands.rs
done
echo "]));" >>src/default_shorthands.rs

cat <<EOF >>src/default_shorthands.rs

#[rustfmt::skip]
pub static TRUSTED_SHORTHANDS: Lazy<HashSet<&'static str>> =
    Lazy::new(|| HashSet::from([
EOF
for plugin in "${trusted[@]}"; do
  echo "    \"$plugin\"," >>src/default_shorthands.rs
done
echo "]));" >>src/default_shorthands.rs

#cat <<EOF >>src/default_shorthands.rs
##[rustfmt::skip]
#pub static GITHUB_STARS: Lazy<HashMap<&'static str, usize>> =
#    Lazy::new(|| HashMap::from([
#EOF
#for plugin in "${!stars[@]}"; do
#  echo "    (\"$plugin\", ${stars[$plugin]})," >>src/default_shorthands.rs
#done
#echo "]));" >>src/default_shorthands.rs

rustfmt src/default_shorthands.rs

rm -rf asdf-plugins
