#!/bin/bash

# Enable logging
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=========================================="
echo "Starting User-Data Script Execution"
echo "Time: $(date)"
echo "=========================================="

# Update system
echo "Step 1: Updating system packages..."
dnf update -y || yum update -y
echo "✓ System updated"

# Install NGINX
echo "Step 2: Installing NGINX..."
dnf install -y nginx || yum install -y nginx

if [ $? -eq 0 ]; then
    echo "✓ NGINX installed successfully"
else
    echo "✗ NGINX installation failed!"
    exit 1
fi

# Get instance private IP
echo "Step 3: Getting private IP address..."
PRIVATE_IP=$(hostname -I | awk '{print $1}')
echo "Private IP: $PRIVATE_IP"

# Create backup of original index.html
if [ -f /usr/share/nginx/html/index.html ]; then
    echo "Backing up original index.html..."
    cp /usr/share/nginx/html/index.html /usr/share/nginx/html/index.html.backup
fi

# Create HTML file with dynamic IP
echo "Step 4: Creating HTML file..."
cat > /usr/share/nginx/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>CSA DevOps Exam</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .container {
            text-align: center;
            background: white;
            padding: 50px;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            max-width: 500px;
        }
        h1 {
            color: #333;
            margin-bottom: 20px;
            font-size: 2em;
        }
        .ip-label {
            color: #666;
            font-size: 1.1em;
            margin-bottom: 10px;
        }
        .ip {
            color: #667eea;
            font-weight: bold;
            font-size: 1.5em;
            padding: 10px 20px;
            background: #f0f4ff;
            border-radius: 8px;
            display: inline-block;
        }
        .status {
            margin-top: 30px;
            padding: 10px;
            background: #d4edda;
            border: 1px solid #c3e6cb;
            border-radius: 5px;
            color: #155724;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>CSA DevOps Exam</h1>
        <p class="ip-label">Instance IP:</p>
        <div class="ip">PRIVATE_IP_PLACEHOLDER</div>
        <div class="status">
            ✓ NGINX is running successfully
        </div>
    </div>
</body>
</html>
EOF

# Replace placeholder with actual IP
sed -i "s/PRIVATE_IP_PLACEHOLDER/$PRIVATE_IP/g" /usr/share/nginx/html/index.html

echo "✓ HTML file created"

# Verify file was created
if [ -f /usr/share/nginx/html/index.html ]; then
    echo "✓ Verified: index.html exists"
    echo "Content preview:"
    head -20 /usr/share/nginx/html/index.html
else
    echo "✗ Error: index.html was not created!"
    exit 1
fi

# Start NGINX
echo "Step 5: Starting NGINX service..."
systemctl start nginx

if [ $? -eq 0 ]; then
    echo "✓ NGINX started successfully"
else
    echo "✗ Failed to start NGINX!"
    exit 1
fi

# Enable NGINX to start on boot
echo "Step 6: Enabling NGINX on boot..."
systemctl enable nginx
echo "✓ NGINX enabled on boot"

# Check NGINX status
echo "Step 7: Checking NGINX status..."
systemctl status nginx --no-pager

# Test if NGINX is responding locally
echo "Step 8: Testing NGINX locally..."
sleep 3
curl -s http://localhost | head -20

if [ $? -eq 0 ]; then
    echo "✓ NGINX is responding to local requests"
else
    echo "✗ NGINX is not responding!"
fi

# Final status
echo ""
echo "=========================================="
echo "User-Data Script Completed Successfully"
echo "Time: $(date)"
echo "=========================================="
echo ""
echo "Summary:"
echo "- Private IP: $PRIVATE_IP"
echo "- NGINX Status: $(systemctl is-active nginx)"
echo "- NGINX Enabled: $(systemctl is-enabled nginx)"
echo ""
echo "Check this log at: /var/log/user-data.log"
echo "=========================================="
