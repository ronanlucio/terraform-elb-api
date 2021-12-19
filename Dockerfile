FROM python:3.8-slim

ARG ENVIRONMENT production

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

ENV APP_HOME /opt/app
ENV FLASK_RUN_HOST 0.0.0.0
ENV FLASK_RUN_PORT 8080
ENV FLASK_ENV ${ENVIRONMENT}
ENV PORT 8080

RUN groupadd -r -g 1000 webapp
RUN useradd -r -m -u 1000 -g webapp webapp
RUN passwd -l webapp

RUN mkdir ${APP_HOME}

WORKDIR ${APP_HOME}

COPY requirements.txt .
COPY . .

RUN pip install -r ./requirements.txt

USER webapp

ENV PATH /home/webapp/.local/bin:$PATH
ENV PYTHONPATH $APP_HOME/$FLASK_APP
EXPOSE 8080
CMD gunicorn --workers 4 "flaskr:create_app()"
