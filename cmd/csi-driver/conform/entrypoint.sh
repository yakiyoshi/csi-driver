#!/bin/sh

# Tolerate zero errors and tell the world all about it
set -xe

# Check if we are running as node-plugin
for arg in "$@"
do
    if [ "$arg" = "--node-service" ]; then
        nodeservice=true
    fi
done

if [ "$nodeservice" = true ]; then
    # Copy HPE Storage Node Conformance checks and conf in place
    cp -f "/opt/hpe-storage/lib/hpe-storage-node.service" \
      /etc/systemd/system/hpe-storage-node.service
    if [ ! -e /opt_local/hpe-storage ]; then
      mkdir -p /opt_local/hpe-storage
    fi
    cp -f "/opt/hpe-storage/lib/hpe-storage-node.sh" \
      /opt_local/hpe-storage/hpe-storage-node.sh
    chmod +x /opt_local/hpe-storage/hpe-storage-node.sh

    echo "running node conformance checks..."
    # Reload and run!
    systemctl daemon-reload
    systemctl restart hpe-storage-node

    # Copy HPE Log Collector diag script
    echo "copying hpe log collector diag script"
    cp -f "/opt/hpe-storage/bin/hpe-logcollector.sh" \
        /opt_local/hpe-storage/hpe-logcollector.sh
    chmod +x  /opt_local/hpe-storage/hpe-logcollector.sh
fi

echo "starting csi plugin..."
# Serve! Serve!!!
exec /bin/csi-driver $@
