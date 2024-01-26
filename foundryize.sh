#!/bin/bash
echo "  "
echo -e "                   \e[1;32;7m Foundryize \e[0m            "
echo    "   Bash utility to install foundry to an existing project."
echo    "   Version 0.1.0"
echo -e  "   =============\n"
# Prompt the user for the folder where Solidity files are stored, including contract name
read -p "  Please enter the path to the folder containing the contract files (default: src): " contracts_folder
echo "   "

# Set a default path if the user presses Enter
contracts_folder=${contracts_folder:-src}

# Check if the contracts folder exists
if [ ! -d "$contracts_folder" ]; then
  echo "Error: '$contracts_folder' folder does not exist."
  exit 1
fi

# Print the folder path for confirmation
echo "Configuring foundry source to: ./$contracts_folder"

# Check if 'forge' command is installed
if ! command -v forge &>/dev/null; then
  echo "Foundry is not installed. Installing it now..."
  # Install Foundry using curl and bash
  curl -L https://foundry.paradigm.xyz | bash
else
  echo "Foundry is already installed."
fi

# Initialize Foundry with 'forge init'
forge init temp_foundry_install --no-git --force

# Copy the "lib" folder from the temporary installation directory to the current directory
cp -r "temp_foundry_install/lib" ./lib

# Clean up the temporary installation directory
rm -rf "temp_foundry_install"

# Check if 'remappings.txt' exists in the current directory
if [ -e "remappings.txt" ]; then
  echo "Updating existing remappings.txt. Please ensure it is up to date for Foundry to work correctly."

  # Use a loop to read each line from the output of 'forge remappings'
  # and append it to 'remappings.txt' if it's not already present
  while IFS= read -r line; do
    if ! grep -qF "$line" "remappings.txt"; then
      echo "$line" >> "remappings.txt"
    fi
  done < <(forge remappings)
else
  echo "Auto-generating remappings.txt..."
  # Generate a new remappings.txt using 'forge remappings'
  forge remappings > remappings.txt
fi

# Create a foundry.toml file with the specified content
cat <<EOL > foundry.toml
[profile.default]
src = "$contracts_folder"
out = 'foundry-out'
libs = ['node_modules', 'lib']
test = 'foundry-test'
cache_path  = 'foundry-cache'

# See more config options https://book.getfoundry.sh/reference/config.html
EOL

# Separator line
echo -e "\n"
echo "========================================================================="
echo -e "\n"
# Inform the user about the next steps
echo -e "   \e[32mAll set! Go forth and code like a Foundry ninja. 💻🚀"
echo -e "   Next steps: Create tests in 'foundry-test' folder and run 'forge test'."
echo -e "   Learn more: Visit \e[4;32mhttps://book.getfoundry.sh/\e[0m"
# Separator line
echo -e "\n"
echo "========================================================================="