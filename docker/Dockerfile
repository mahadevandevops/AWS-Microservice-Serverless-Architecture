# Use the official Nginx image as the base image
FROM nginx:latest

# Create the directory where the HTML file will be copied
RUN mkdir -p /usr/share/nginx/html/api/

# Copy the HTML file to the Nginx web directory
COPY index.html /usr/share/nginx/html/api/index.html

# Expose port 80
EXPOSE 80
