#!/bin/bash

# Ask user for node name, chain id, minimum gas, and keyring backend
read -p "🔹 Enter node name (e.g., mynode): " NODE_NAME
read -p "🔹 Enter Chain ID (e.g., stochain): " CHAIN_ID
read -p "🔹 Enter minimum gas value (e.g., 0.001ustoc): " MIN_GAS

# Ask user for keyring backend and environment type (test or prod)
read -p "🔹 Choose Keyring Backend (test|os|file): " KEYRING_BACKEND
read -p "🔹 Are you setting up for production or testing environment? (test|prod): " ENVIRONMENT

# Display information for user to confirm
echo -e "\n📌 Confirm your settings:"
echo "🌟 Node: $NODE_NAME"
echo "🔗 Chain ID: $CHAIN_ID"
echo "⛽ Minimum Gas: $MIN_GAS"
echo "🔑 Keyring Backend: $KEYRING_BACKEND"
echo "⚙️ Environment: $ENVIRONMENT"
read -p "✅ Confirm (y/n)? " CONFIRM
if [[ $CONFIRM != "y" ]]; then
  echo "❌ Setup cancelled."
  exit 1
fi

# Initialize blockchain
echo "🚀 Initializing blockchain..."
stocd init "$NODE_NAME" --chain-id "$CHAIN_ID" --overwrite

# Edit minimum-gas-prices
APP_CONFIG="$HOME/.stoc/config/app.toml"
echo "⚙️ Updating minimum gas price..."
sed -i "s|minimum-gas-prices = .*|minimum-gas-prices = \"$MIN_GAS\"|" "$APP_CONFIG"

# Ask if user wants to add an existing validator to keyring
read -p "🔹 Do you want to add an existing validator to the keyring? (y/n): " ADD_EXISTING_VALIDATOR
if [[ $ADD_EXISTING_VALIDATOR == "y" ]]; then
  read -p "🔑 Enter the name of the existing validator: " EXISTING_VALIDATOR
  stod keys add "$EXISTING_VALIDATOR" --recover --keyring-backend "$KEYRING_BACKEND"
else
  read -p "🆕 Enter the new validator's name: " VALIDATOR_NAME
  stod keys add "$VALIDATOR_NAME" --keyring-backend "$KEYRING_BACKEND"
fi

# Ask for stake amount
read -p "💰 Enter stake amount for validator (e.g., 100000000ustoc): " STAKE_AMOUNT

# Display final confirmation before adding the validator to genesis
echo -e "\n📌 Final Confirmation:"
echo "🆕 Validator Name: $VALIDATOR_NAME"
echo "💰 Stake Amount: $STAKE_AMOUNT"
read -p "✅ Confirm adding validator to genesis (y/n)? " CONFIRM_GENTX
if [[ $CONFIRM_GENTX != "y" ]]; then
  echo "❌ Setup cancelled."
  exit 1
fi

# Add validator to genesis transaction
echo "🛠 Adding validator to genesis transaction..."
stocd genesis gentx "$VALIDATOR_NAME" "$STAKE_AMOUNT" --chain-id "$CHAIN_ID" --keyring-backend "$KEYRING_BACKEND"

# Collect all gentx into genesis
echo "📦 Collecting gentx..."
stocd genesis collect-gentxs

# Run blockchain
echo "✅ Done! Starting blockchain... stocd start "