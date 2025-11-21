FROM nginx:alpine
WORKDIR /usr/share/nginx/html
RUN rm -rf ./*
COPY My-Portfolio/ .

EXPOSE 80
CMD ["nginx" , "-g", "daemon off;"]
