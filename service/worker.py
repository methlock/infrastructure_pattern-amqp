import socket
import datetime
from time import sleep
from random import randint

from models import TasksTable, Broker


def on_receive(ch, method, properties, body):
    duration = randint(5, 30)
    print(f'Received task number "{body}". Should be done in {duration} s')

    tasks = TasksTable().filter(id=body).get()
    tasks.status = 'in progress'
    tasks.worker = socket.gethostname()
    tasks.save()

    # simulate work
    sleep(duration)

    tasks.finished = datetime.datetime.now()
    tasks.status = 'finished'
    tasks.duration = duration
    tasks.save()

    ch.basic_ack(delivery_tag=method.delivery_tag)


Broker.start_consuming(on_receive)
