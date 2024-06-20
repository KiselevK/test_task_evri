FROM nginx:alpine

ARG jmeter_report_path
COPY ${jmeter_report_path} /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
