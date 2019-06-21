from flask import Flask, jsonify

from models import TasksTable, Broker


app = Flask(__name__)


@app.route("/")
def index():
    return f"Hello from service with AMQP. This is API server!"


@app.route("/newTask")
def new_task():

    task = TasksTable()
    task.save()
    broker = Broker().new_task(exchange='', routing_key='tasks', body=str(task.id))

    return f'New task number {task.id} created and added to the queue.'


@app.route("/tasks")
def task_status():
    response = {
        task.id: {
            'created': task.created,
            'finished': task.finished,
            'status': task.status,
            'duration': task.duration,
            'worker': task.worker
        } for task in TasksTable}
    return jsonify(response)


if __name__ == "__main__":
    app.run(debug=True, host='0.0.0.0', port=5000)
