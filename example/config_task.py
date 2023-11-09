import ipaddress
from nornir import InitNornir
from nornir.core.task import Result, Task
from nornir_jinja2.plugins.tasks import template_string
from nornir_napalm.plugins.tasks import napalm_configure
from nornir_utils.plugins.functions import print_result

# TEMPLATE represents an option to manage multiple templates per platform
TEMPLATE = {
    "eos": "interface Ethernet1\nno switchport\nip address {{ ip_address }}\nno shutdown",
}


def get_my_interface_ip(task: Task, host_id: int) -> Result:
    ip_network = ipaddress.IPv4Network(task.host["network"])

    for count, ip_address in enumerate(ip_network):
        if host_id == count or host_id == count:
            break
    else:
        raise ValueError("Only host IDs 1 and 2 are supported")

    return Result(
        host=task.host,
        result=ipaddress.IPv4Interface(f"{ip_address}/{ip_network.prefixlen}"),
    )


def config_task(task: Task, template) -> Result:
    """Nornir task that combines two subtasks:
    - Render a configuration from a Jinja2 template
    - Push the rendered configuration to the device
    """
    result_ip = task.run(
        task=get_my_interface_ip, host_id=1 if task.host.name == "router1" else 2
    )

    render_result = task.run(
        task=template_string,
        # The right template per platform is selected
        template=template[task.host.platform],
        ip_address=str(result_ip.result),
    )

    config_result = task.run(
        task=napalm_configure,
        # The rendered configuration from previous subtask is used
        # as the configuration input
        configuration=render_result.result,
        # dry_run means the changes without applying them
        dry_run=False,
    )

    return Result(host=task.host, result=config_result)


# Initialize Nornir inventory from a file
nr = InitNornir(config_file="config.yaml")
# The `config_task` will aggregate two subtasks
result = nr.run(
    task=config_task,
    template=TEMPLATE,
)

print_result(result)
