# Nginx Setup Guide

## Prerequisites

Before running the Nginx setup, you **MUST** configure your DNS records with your domain provider.

### Domain Configuration Steps

1. **Access Your Domain Provider's DNS Management Panel**
   - Login to your domain registrar (e.g., GoDaddy, Cloudflare, Namecheap, Route53, etc.)
   - Navigate to a DNS Management or DNS Settings section

2. **Create A Records**
   - Add A records pointing to your server's IP address
   - Required fields for each record:
     - **Type**: Select `A` (Address Record)
     - **Name/Host**: Enter subdomain name (e.g., `@` for root, `www`, `api`, `test`)
     - **Value/Points to**: Enter your server's IP address (e.g., `127.0.0.1`)
     - **TTL**: Set to `600` seconds (10 minutes) for initial setup
   - Common records to create:
     - `@` (root domain) → Your Server IP
     - `www` → Your Server IP (or CNAME pointing to root domain)
     - Subdomains (e.g., `api`, `test`, `admin`) → Your Server IP

3. **Save and Wait for Propagation**
   - Save your DNS records
   - DNS changes can take 5 minutes to 48 hours to propagate globally
   - Wait for propagation to complete before running the setup script

---

## Example DNS Configuration

Below is an example configuration used for `afetyonetimsistemi.org`:

| Type  | Name      | Value                   | TTL     |
|-------|-----------|-------------------------|---------|
| A     | @         | 127.0.0.1               | 600 sec |
| A     | subdomain | 127.0.0.1               | 600 sec |
| CNAME | www       | afetyonetimsistemi.org. | 1 Hour  |

**Notes:**

- `@` represents the root domain (e.g., `afetyonetimsistemi.org`)
- CNAME records point to another domain name, not an IP address
- Replace `127.0.0.1` with your actual server IP address
