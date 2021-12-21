FROM python:3.8-slim

ARG ENVIRONMENT production
ARG APP_AWS_ACCESS_KEY_ID
ARG APP_AWS_SECRET_ACCESS_KEY
ARG APP_AWS_REGION

# Allow statements and log messages to immediately appear in the Knative logs
ENV PYTHONUNBUFFERED True

ENV APP_HOME /opt/app
ENV FLASK_RUN_HOST 0.0.0.0
ENV FLASK_RUN_PORT 8080
ENV FLASK_ENV ${ENVIRONMENT}
ENV PORT 8080

ENV AWS_ACCESS_KEY_ID ${APP_AWS_ACCESS_KEY_ID}
ENV AWS_SECRET_ACCESS_KEY ${APP_AWS_SECRET_ACCESS_KEY}
ENV AWS_DEFAULT_REGION ${APP_AWS_REGION}

RUN groupadd -r -g 1000 webapp
RUN useradd -r -m -u 1000 -g webapp webapp
RUN passwd -l webapp

RUN mkdir ${APP_HOME}

WORKDIR ${APP_HOME}

USER webapp
ENV PATH /home/webapp/.local/bin:$PATH
#ENV PYTHONPATH $APP_HOME

COPY requirements.txt .
COPY app.py .
COPY aws_resources.py .
COPY wsgi.py .

RUN pip install -r ./requirements.txt

EXPOSE 8080

CMD ["gunicorn", "--workers", "4", "wsgi:app"]
