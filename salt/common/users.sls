{% set user_group = 6000 %}

users:
  group.present:
    - gid: {{ user_group }}
    - system: True

{%- for username, user in salt.pillar.get("users").items() %}
{#-
{{ username }}:
  user.absent:
    - purge: True
    - force: True
#}
{{ username }}:
  user.present:
    - fullname: {{ user['fullname'] }}
    - shell: "/bin/zsh"
    - home: "/home/{{ username }}"
    - uid: {{ user['user_id'] }}
    - gid: {{ user_group }}
    - system: {{ user['system'] }}
    - groups:
      - users
{% endfor %}