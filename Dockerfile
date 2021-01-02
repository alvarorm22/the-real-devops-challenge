FROM python:3.6.12-alpine3.12  

ADD app.py /
ADD requirements.txt /
RUN mkdir /src
ADD src/* /src/

RUN apk update 

RUN pip3 install -r requirements.txt

CMD [ "python3", "./app.py" ]

EXPOSE 8080
