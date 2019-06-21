# Infrastructure design pattern with API, workers, message broker and database.
Scheme of microservice is following:
```
+--------+                                  +----------------------+
| User 1 | <--+                    +----+   |       +----------+   |     
+--------+    |    +-----+ <-----> | DB | <-+   +-> | Worker 1 | --+ 
              +--> | API |         +----+       |   +----------+   |                       
+--------+    |    +-----+ --+                  |                  |
| User 2 | <--+              |    +--------+    |   +----------+   |         
+--------+                   +--> | Broker | <--+-> | Worker 2 | --+                             
                                  +--------+        +----------+                  
                                                        ...
```

What is going on
-
At API, there are three endpoints:

- **/** - basic info
- **/newTask** - create new task and return its id, task is send to broker
- **/tasks** - list of all tasks, you can check status here

Worker consuming `tasks` queue. It took new or unprocessed message and do 
"something" (and updates task info).

In case of worker failure, its message is consumed by another worker.


Prequisities
-
- Terraform
- DigitalOcean account


Setup
-
Just go to `/terraform` folder and fill `terraform.tfvars`, then do these commands:
```bash
terraform init     # setup terraform plugins
terraform plan     # preview the changes to infrastructure
terraform apply    # build infrastructure
terraform destroy  # when you've seen enough
```