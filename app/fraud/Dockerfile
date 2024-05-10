FROM public.ecr.aws/docker/library/python:3

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY python-worker.py .

CMD [ "python", "./load_payments_worker.py" ]