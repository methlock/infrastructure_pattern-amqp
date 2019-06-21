import os
import datetime

import pika
import peewee
from peewee import MySQLDatabase


db = MySQLDatabase('db',
                   user='user', passwd='password',
                   host=os.environ['DB_HOST'],
                   port=3306)


class TasksTable(peewee.Model):
    """Python representation of 'Tasks' table from MySQL."""

    # field id will be created automatically - primary key
    status = peewee.TextField(default='initialized')
    worker = peewee.TextField(default='unassigned')
    created = peewee.DateTimeField(default=datetime.datetime.now)
    finished = peewee.DateTimeField(default=datetime.datetime.now)
    duration = peewee.IntegerField(default=0)

    class Meta:
        database = db


credentials = pika.PlainCredentials('user', 'bitnami')
parameters = pika.ConnectionParameters(os.environ['RABBIT_HOST'],
                                       5672,
                                       '/',
                                       credentials)

TasksTable.create_table()


class Broker:
    def __init__(self):
        self.connection = pika.BlockingConnection(parameters)
        self.channel = self.connection.channel()
        self.channel.queue_declare(queue='tasks')

    def new_task(self, **kwargs):
        self.channel.basic_publish(**kwargs)

    @staticmethod
    def start_consuming(callback):
        broker = Broker()
        broker.channel.basic_qos(prefetch_count=1)
        broker.channel.basic_consume(on_message_callback=callback,
                                     queue='tasks',
                                     auto_ack=False)
        print('Waiting for messages. To exit press CTRL+C')
        broker.channel.start_consuming()
