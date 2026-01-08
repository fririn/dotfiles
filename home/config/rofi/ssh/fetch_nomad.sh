#!/bin/bash

# Set your Nomad server address
# This can also be set via the NOMAD_ADDR environment variable

source ".nomad_env"

OUTPUT_FILE="nomad_hosts.txt"
SSH_USER="root"

# Create or overwrite the file.
echo "# cluser_name:eligibility:ssh_user:hostname:ip" > "$OUTPUT_FILE"
echo "Generating inventory file at $OUTPUT_FILE..."
echo "---"

# FUNCTION: Fetch nodes and iterate to get specific attributes
# Usage: process_cluster "CLUSTER_NAME" "NOMAD_URL" "NOMAD_TOKEN"
process_cluster() {
    local CLUSTER_NAME="$1"
    local URL="$2"
    local TOKEN="$3"

    echo "Fetching $CLUSTER_NAME cluster ($URL)..."

    # 1. Get list of Node IDs and Names first
    # We output a space-separated string of "ID:Name:Eligibility" to loop over
    local NODES_LIST
    NODES_LIST=$(curl -s -H "X-Nomad-Token: $TOKEN" "$URL/v1/nodes" | \
        jq -r '.[] | "\(.ID)|\(.Name)|\(.SchedulingEligibility)"')

    # 2. Iterate over each node to get details
    # We set Internal Field Separator to newline to handle the list correctly
    IFS=$'\n'
    for node_info in $NODES_LIST; do
        # Split the string by pipe |
        local NODE_ID=$(echo "$node_info" | cut -d'|' -f1)
        local NODE_HOSTNAME=$(echo "$node_info" | cut -d'|' -f2)
        local NODE_ELIG=$(echo "$node_info" | cut -d'|' -f3)

        # 3. Fetch full node details to get the Attribute
        # We silence errors just in case a node disappears during the run
        local NODE_JSON
        NODE_JSON=$(curl -s -H "X-Nomad-Token: $TOKEN" "$URL/v1/node/$NODE_ID")

        # 4. Extract the specific IP attribute
        # If the attribute is missing (null), it falls back to "Unknown_IP"
        local NODE_IP
        NODE_IP=$(echo "$NODE_JSON" | jq -r '.Attributes["unique.network.ip-address"] // "Unknown_IP"')

        # 5. Append to file in the requested format
        echo "$CLUSTER_NAME:$NODE_ELIG:$SSH_USER:$NODE_HOSTNAME:$NODE_IP" >> "$OUTPUT_FILE"
    done
    unset IFS
}

# --- PROCESS CLUSTERS ---

process_cluster "EU"    "$EU_URL"    "$EU_KEY"
process_cluster "US"    "$US_URL"    "$US_KEY"
process_cluster "ASIA"  "$ASIA_URL"  "$ASIA_KEY"
process_cluster "CORGI" "$CORGI_URL" "$CORGI_KEY"


# --- COMPLETE ---
echo "---"
echo "Done. Inventory file updated."

# Count lines (minus the header)
HOST_COUNT=$(($(wc -l < "$OUTPUT_FILE") - 1))
echo "Total hosts found: $HOST_COUNT"
