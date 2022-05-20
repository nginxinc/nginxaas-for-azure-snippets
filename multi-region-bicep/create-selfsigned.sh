#!/bin/bash

set -euo pipefail

if (( $# < 2)); then
    echo "Usage: create-selfsigned.sh <akv name> <FQDN>" >&2
fi

vaultname=$1
fqdn=$2

certname=selfsigned

policy=$(jq <<EOF
{
  "issuerParameters": {
    "certificateTransparency": null,
    "name": "Self"
  },
  "keyProperties": {
    "curve": null,
    "exportable": true,
    "keySize": 2048,
    "keyType": "RSA",
    "reuseKey": true
  },
  "lifetimeActions": [
    {
      "action": {
        "actionType": "AutoRenew"
      },
      "trigger": {
        "daysBeforeExpiry": 90
      }
    }
  ],
  "secretProperties": {
    "contentType": "application/x-pem-file"
  },
  "x509CertificateProperties": {
    "keyUsage": [
      "cRLSign",
      "dataEncipherment",
      "digitalSignature",
      "keyEncipherment",
      "keyAgreement",
      "keyCertSign"
    ],
    "subject": "CN=$fqdn",
    "validityInMonths": 12
  }
}
EOF
)

az keyvault certificate create \
    --vault-name "$vaultname" \
    -p "$policy" \
    -n "$certname"

echo "Created $certname in AKV $vaultname for $fqdn"
