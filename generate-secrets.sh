#!/bin/bash
# Script to generate Authelia secrets
# This will create a authelia-secrets-generated.yaml file with random secure values

set -e

echo "Generating Authelia secrets..."

# Generate random secrets as readable ASCII text, then base64 encode
# First generates hex strings (readable ASCII), then encodes to base64
LDAP_PASSWORD=$(echo -n "$(openssl rand -hex 16)" | base64 -w 0)
REDIS_PASSWORD=$(echo -n "$(openssl rand -hex 16)" | base64 -w 0)
POSTGRES_PASSWORD=$(echo -n "$(openssl rand -hex 16)" | base64 -w 0)
OIDC_HMAC_SECRET=$(echo -n "$(openssl rand -hex 32)" | base64 -w 0)
OIDC_EXAMPLE_CLIENT_SECRET=$(echo -n "$(openssl rand -hex 16)" | base64 -w 0)
JWT_SECRET=$(echo -n "$(openssl rand -hex 32)" | base64 -w 0)
SESSION_SECRET=$(echo -n "$(openssl rand -hex 32)" | base64 -w 0)
STORAGE_ENCRYPTION_KEY=$(echo -n "$(openssl rand -hex 32)" | base64 -w 0)
IDENTITY_VALIDATION_KEY=$(echo -n "$(openssl rand -hex 32)" | base64 -w 0)

# Generate RSA private key for OIDC JWKS (2048-bit) and base64 encode it
OIDC_JWKS_KEY=$(openssl genrsa 2048 2>/dev/null | base64 -w 0)

# Create the secret file
cat > authelia-secrets-generated.yaml <<EOF
---
# Auto-generated Authelia Secrets
# Generated on: $(date)
#
# IMPORTANT: Store this file securely and do not commit to version control!
#
# Apply with:
# kubectl create namespace authelia  # if not exists
# kubectl apply -f authelia-secrets-generated.yaml -n authelia

apiVersion: v1
kind: Secret
metadata:
  name: authelia-secrets
  namespace: authelia  # Update to match your namespace
type: Opaque
data:
  # Custom keys for explicit references in values.yaml
  ldap_password: "${LDAP_PASSWORD}"
  redis_password: "${REDIS_PASSWORD}"
  postgres_password: "${POSTGRES_PASSWORD}"
  oidc_hmac_secret: "${OIDC_HMAC_SECRET}"
  oidc_client_example_app_secret: "${OIDC_EXAMPLE_CLIENT_SECRET}"
  jwt_secret: "${JWT_SECRET}"
  session_secret: "${SESSION_SECRET}"
  storage_encryption_key: "${STORAGE_ENCRYPTION_KEY}"

  # RSA private key for OIDC JWKS (base64 encoded)
  oidc_jwks_key: "${OIDC_JWKS_KEY}"

  # Default keys expected by Helm chart (with dot notation)
  identity_validation.reset_password.jwt.hmac.key: "${IDENTITY_VALIDATION_KEY}"
  session.encryption.key: "${SESSION_SECRET}"
  storage.encryption.key: "${STORAGE_ENCRYPTION_KEY}"
EOF

echo ""
echo "✓ Secrets generated successfully!"
echo "✓ Saved to: authelia-secrets-generated.yaml"
echo ""
echo "IMPORTANT NOTES:"
echo "1. Store this file securely - it contains sensitive credentials"
echo "2. Add authelia-secrets-generated.yaml to your .gitignore"
echo "3. You'll need to manually configure your LDAP, Redis, and PostgreSQL with these passwords:"
echo ""
echo "   LDAP Admin Password:  ${LDAP_PASSWORD}"
echo "   Redis Password:       ${REDIS_PASSWORD}"
echo "   PostgreSQL Password:  ${POSTGRES_PASSWORD}"
echo ""
echo "4. The OIDC client secret for 'example-app':"
echo "   Client Secret:        ${OIDC_EXAMPLE_CLIENT_SECRET}"
echo ""
echo "5. Apply the secret before installing the Helm chart:"
echo "   kubectl create namespace authelia"
echo "   kubectl apply -f authelia-secrets-generated.yaml -n authelia"
