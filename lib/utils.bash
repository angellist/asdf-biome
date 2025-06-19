#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/biomejs/biome"
TOOL_NAME="biome"
TOOL_TEST="biome --version"

# sed requires escaped slashes, while grep does not, but we want to keep the major release prefixes consistent, so we
# use this to escape the slashes in the prefixes.
escape_slashes() {
	local input="$1"
	echo "$input" | sed 's/\//\\\//g'
}

MAJOR_1_PREFIX='cli/v'
MAJOR_2_PREFIX='@biomejs/biome@'

# match either @biomejs/biome@X.Y.Z or cli/vX.Y.Z
RELEASE_REGEX="^\($MAJOR_1_PREFIX\|$MAJOR_2_PREFIX\)[0-9]\+\.[0-9]\+\.[0-9]\+$"
REPLACE_RELEASE_REGEX="s/^($(escape_slashes $MAJOR_1_PREFIX)|$(escape_slashes $MAJOR_2_PREFIX))//"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if biome is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		grep -o "$RELEASE_REGEX" | # Match semantic versioning tags
		sed -E "$REPLACE_RELEASE_REGEX"
}

list_all_versions() {
	list_github_tags
}

binary_suffix() {
	local suffix

	if [[ "$OSTYPE" == "darwin"* ]]; then
		suffix="-darwin-arm64"
	elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
		suffix="-linux-x64"
	else
		fail "Unsupported OS: $OSTYPE"
	fi

	echo "$suffix"
}

release_file() {
	local download_path="$1"

	echo "$download_path/$TOOL_NAME$(binary_suffix)"
}

download_release() {
	local version filename url major_prefix
	version="$1"
	filename="$2"

	echo "$version"
	echo "$filename"

	if [[ "$version" =~ "^2" ]]; then
		major_prefix="$MAJOR_2_PREFIX"
	elif [[ "$version" =~ "^1" ]]; then
		major_prefix="$MAJOR_1_PREFIX"
	else
		fail "Unsupported version: $version"
		return 1
	fi

	url="$GH_REPO/releases/download/${major_prefix}${version}/biome$(binary_suffix)"

	echo "* Downloading $TOOL_NAME release $version..."
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"
		mv $(release_file $ASDF_DOWNLOAD_PATH) "$install_path/$TOOL_NAME"
		chmod +x "$install_path/$TOOL_NAME"

		# Assert biome executable exists.
		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
