#!/bin/bash
yum update -y
yum install -y httpd

# Start the httpd service
service httpd start
chkconfig httpd on

# Get instance metadata
INSTANCE_ID=$(TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
&& curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/instance-id)
AVAILABILITY_ZONE=$(TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
&& curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/placement/availability-zone)

# Create the default response HTML file
echo "<html><body><h1>Hello from $INSTANCE_ID in $AVAILABILITY_ZONE.</h1></body></html>" > /var/www/html/index.html

