# ---
# Copyright © 2023 ORAE IBC. All Rights Reserved
# This code is licensed under the ORAE License (https://orae.one/license)
# ---

FROM python:latest
ENV PYTHONUNBUFFERED 1
WORKDIR /app
COPY . /app/
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir gunicorn
EXPOSE 5000

CMD ["gunicorn", "index:app", "--bind", "0.0.0.0:5000"]