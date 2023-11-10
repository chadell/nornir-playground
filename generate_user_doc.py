import jinja2

template = """Workstation Number: {{ user_number }}

- Router1: {{ ip_address }}:{{ port_1 }}
- Router2: {{ ip_address }}:{{ port_2 }}

More info available at:
https://github.com/chadell/nornir-playground
\n
"""

environment = jinja2.Environment()
template = environment.from_string(template)

IP_ADDRESSES = ["1.1.1.1", "1.1.1.2", "1.1.1.3", "1.1.1.4"]

number_users_per_vm = 14
start_port = 12000
user_number = 1

final_text = ""

for ip_address in IP_ADDRESSES:
    for user in range(number_users_per_vm):
        base_port = start_port + user * 2 + 1
        final_text += template.render(
            user_number=user_number,
            ip_address=ip_address,
            port_1=base_port,
            port_2=base_port + 1,
        )
        user_number += 1

print(final_text)
