import boto3
import botocore
import datetime
from dateutil.tz import tzutc

def get_instances_detailed(instances):
    """ Get instances detail

        instances: list of instance-ids
    """

    client = boto3.client("ec2")
    instances_detailed = []

    try:
        response = client.describe_instances(Filters=[{"Name": "instance-id", "Values": instances}], InstanceIds=instances)
        status_code = 200
    except client.exceptions.ClientError as error:
        status_code = 404
    except:
        status_code = 500

    # If there are instances matching instances ids
    if status_code == 200 and response["Reservations"]:
        instances_attached = response["Reservations"][0]["Instances"]

        for instance in instances_attached:
            instance_data = {
                "instanceId": instance["InstanceId"],
                "instanceType": instance["InstanceType"],
                "launchDate": instance["LaunchTime"].strftime("%Y-%m-%dT%H:%M:%S %Z")
            }

            instances_detailed.append(instance_data)

    return instances_detailed


def elb_list_target_groups_arn(elb_name):
    """Return a list of target groups from a specific arn"""

    client = boto3.client("elbv2")
    target_groups_arn = []

    # List load balancers
    try:
        lb_response = client.describe_load_balancers(Names=[elb_name])
        status_code = 200
    except client.exceptions.LoadBalancerNotFoundException as error:
        status_code = 404
    except:
        status_code = 500

    # If ELB exists
    if status_code == 200:
        for lb in lb_response["LoadBalancers"]:
            # List target groups from the load balancer
            tg_response = client.describe_target_groups(LoadBalancerArn=lb["LoadBalancerArn"])

            # Get a list of target groups arn
            for tg in tg_response["TargetGroups"]:
                target_groups_arn.append(tg["TargetGroupArn"])

    return target_groups_arn, status_code


def elb_list_attached_machines(elb_name):
    """List all machines attached to the specified load balancer"""

    client = boto3.client("elbv2")

    attached_machines = []
    target_groups_arn, status_code = elb_list_target_groups_arn(elb_name)

    # Get a list of targets from each target group
    for tg_arn in target_groups_arn:
        th_response = client.describe_target_health(TargetGroupArn=tg_arn)

        for th in th_response["TargetHealthDescriptions"]:
            attached_machines.append(th["Target"]["Id"])

    return get_instances_detailed(attached_machines), status_code


def elb_attach_machine_on_elb(elb_name, machine_id):
    """Attach an instance to a load balancer"""

    client = boto3.client("elbv2")
    machines = [machine_id]

    # Get instances details
    instances_detailed = get_instances_detailed(machines)

    # If instance exists
    if instances_detailed:
        machine = instances_detailed[0]

        # Check if instance is already registered
        attached_machines, status_code = elb_list_attached_machines(elb_name)
        is_already_attached = [instance for instance in attached_machines if instance["instanceId"] == machine_id]

        if not is_already_attached:
            # Get target groups
            target_groups_arn, status_code = elb_list_target_groups_arn(elb_name)

            # register instance to a target group
            if target_groups_arn:
                tg_arn = target_groups_arn[0]
                response = client.register_targets(TargetGroupArn=tg_arn, Targets=[{"Id": machine_id, "Port": 80}])

                # instance attached
                status_code = 201
        else:
            # instance already attached
            status_code = 409  
    else:
        # instance doesn't exists
        status_code = 404
        machine = machine_id

    return machine, status_code


def elb_detach_machine_from_elb(elb_name, machine_id):
    """Detach an instance from load balancer"""

    client = boto3.client("elbv2")
    machines = [machine_id]

    # Get instances details
    instances_detailed = get_instances_detailed(machines)

    # If instance exists
    if instances_detailed:
        machine = instances_detailed[0]

        # Check if instance is attached
        attached_machines, status_code = elb_list_attached_machines(elb_name)
        is_attached = [instance for instance in attached_machines if instance["instanceId"] == machine_id]
        
        if is_attached:
            target_groups_arn, status_code = elb_list_target_groups_arn(elb_name)

            # deregister instance from target group
            for tg_arn in target_groups_arn:
                response = client.deregister_targets(TargetGroupArn=tg_arn, Targets=[{"Id": machine_id, "Port": 80}])

                # instance detached
                status_code = 201
        else:
            # instance is not on load balancer
            status_code = 409
    else:
        # instance doesn't exists
        status_code = 404
        machine = machine_id

    return machine, status_code
