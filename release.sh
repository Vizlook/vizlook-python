#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# Define the path to the version file
VERSION_FILE="src/vizlook/_version.py"
# Ensure the directory for the version file exists
mkdir -p "$(dirname "$VERSION_FILE")"

echo "Starting Python package release process (Poetry)..."

# Handle command-line arguments to determine version update type or specific version number
# Default version increment type is 'patch'
VERSION_INPUT_TYPE="patch" 

if [ -n "$1" ]; then # Check if an argument is provided
    # Check if the argument is one of the predefined version types
    if [[ "$1" =~ ^(patch|minor|major)$ ]]; then
        VERSION_INPUT_TYPE="$1"
        echo "Performing a $VERSION_INPUT_TYPE version update."
    # Check if the argument is a PEP 440 compliant semantic version number (e.g., 1.2.3, 1.0.0b1)
    # This regex is a simplified check; 'poetry version' will perform more thorough validation.
    elif [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+([a-zA-Z0-9\.-]+)?$ ]]; then
        VERSION_INPUT_TYPE="$1" # Use the provided version number directly
        echo "Releasing with specific version: v$VERSION_INPUT_TYPE."
    else
        echo "Error: Invalid version type or number '$1'."
        echo "Please use 'patch', 'minor', 'major' or a PEP 440 compliant semantic version number (e.g., 1.2.3, 1.0.0b1)."
        exit 1
    fi
else
    echo "No version type specified, defaulting to 'patch' version update."
fi

# 1. Automatically update version number in pyproject.toml
echo "1. Updating version number in pyproject.toml using Poetry..."
# 'poetry version' command updates pyproject.toml and does not automatically commit or tag.
# It accepts 'patch', 'minor', 'major' for incrementing, or a specific version string.
poetry version "$VERSION_INPUT_TYPE"

# Get the updated version number from pyproject.toml
# 'poetry version --short' returns only the version string.
PACKAGE_VERSION=$(poetry version --short)
echo "New package version: v$PACKAGE_VERSION"

# 1.1. Synchronize __version__ in _version.py
echo "1.1. Synchronizing __version__ in $VERSION_FILE..."

# Check if the file exists, if not, create it with initial content.
if [ ! -f "$VERSION_FILE" ]; then
    echo "Creating $VERSION_FILE with initial version..."
    echo "__title__ = \"vizlook\"" > "$VERSION_FILE"
    echo "__version__ = \"$PACKAGE_VERSION\"" >> "$VERSION_FILE"
else
    # Use sed to replace the __version__ line with the new version.
    # The 's' command is for substitute. '.*' matches any characters.
    # The 'g' flag for sed is global, but not strictly needed here as we expect one match per line.
    # macOS/BSD 'sed' requires an argument for -i, e.g., -i '' or -i .bak
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/__version__ = \".*\"/__version__ = \"$PACKAGE_VERSION\"/" "$VERSION_FILE"
    else
        sed -i "s/__version__ = \".*\"/__version__ = \"$PACKAGE_VERSION\"/" "$VERSION_FILE"
    fi
fi
echo "Updated $VERSION_FILE to __version__ = \"$PACKAGE_VERSION\""


# 2. Automatically build the package
echo "2. Building the project into sdist and wheel formats..."
# This creates package distribution files in the 'dist/' directory.
rm -rf dist
poetry build


# 3. Automatically commit to Git
echo "3. Committing version update, _version.py, and build artifacts (if applicable) to Git..."
git add pyproject.toml # Always commit the updated pyproject.toml
git add "$VERSION_FILE" # Add the updated _version.py file
# Uncomment the following line if you want to commit 'poetry.lock' (if it changed).
# git add poetry.lock
# By default, 'dist/' directory is usually ignored in Git (.gitignore),
# and it's generally not recommended to commit build artifacts.
git commit -m "Release v$PACKAGE_VERSION"

# 4. Automatically publish to PyPI
echo "4. Publishing package to PyPI..."
# Ensure you are authenticated with PyPI (e.g., via 'poetry config pypi-token.pypi <your_token>').
poetry publish

# 5. Automatically push a Git tag to the repository
echo "5. Creating and pushing Git Tag..."
git tag "v$PACKAGE_VERSION"
git push # Push the new commit to the remote repository
git push --tags # Push the new tag to the remote repository

echo "Python package release process completed! Version v$PACKAGE_VERSION has been published to PyPI."