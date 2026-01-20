FROM nginx:alpine

LABEL maintainer="tanmay-devsecops"
LABEL project="DevSecOps Documentation Portal"

COPY docs/ /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
