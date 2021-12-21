from flask import Flask, Response, request
import aws_resources as aws
import json

app = Flask(__name__)

# Health Check
@app.route("/healthcheck", methods=["GET"])
def healthcheck():
    """API health check"""
    
    return Response(status=200, mimetype="application/json")


# List machines attached to a particular load balancer
@app.route("/elb/<elb_name>", methods=["GET"])
def list_elb_attached_machines(elb_name):
    """List machines attached to load balancer"""

    # get attached machines
    attached_machines, status_code = aws.elb_list_attached_machines(elb_name)

    return Response(json.dumps(attached_machines), 
        status=status_code, 
        mimetype="application/json")


# Attach an instance on the load balancer
@app.route("/elb/<elb_name>", methods=["POST"])
def attach_machine_on_elb(elb_name):
    """Attach a machine on a load balancer"""

    status_code = 201         # 201 / 400 / 409

    try:
        body = request.get_json()
        machine_id = body["instanceId"]
    except:
        status_code = 400
        message = "wrong data format"

    # attach machine on elb
    machine = aws.elb_attach_machine_on_elb(elb_name, machine_id)

    return Response(json.dumps(machine), 
        status=status_code, 
        mimetype="application/json")


# Detach an instance from the load balancer
@app.route("/elb/<elb_name>", methods=["DELETE"])
def detach_machine_from_elb(elb_name):
    """Detach an instance from the load balancer"""

    status_code = 201         # 201 / 400 / 409

    try:
        body = request.get_json()
        machine_id = body["instanceId"]
    except:
        status_code = 400
        message = "wrong data format"

    # detach machine from elb
    machine = aws.elb_detach_machine_from_elb(elb_name, machine_id)

    return Response(json.dumps(machine), 
        status=status_code, 
        mimetype="application/json")
