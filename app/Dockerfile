FROM nginx:alpine

# Copy application files
COPY index.html /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Run nginx
CMD ["nginx", "-g", "daemon off;"]
