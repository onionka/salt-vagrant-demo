include:
  - microservices_demo.docker
  - microservices_demo.nginx

{# YAML representation of https://github.com/mittwald/salt-microservices/blob/master/mwms/services.sls algorithm #}
{%- macro service(service_name) -%}
{%- set service_config = salt.pillar.get("microservices", {}).get(service_name, {}) %}
{%- set has_http = any("http" in c and c["http"] for _, c in service_config['containers']) %}
{%- set has_port = any("ports" in c and c["ports"][0] for _, c in service_config['containers']) -%}

{% if "volumes" in service_config -%}
{% for dir, mount, mode in service_config.get("volumes", []) -%}
/var/lib/services/{{ service_name }}/{{ dir }}:
  file.directory:
    - mode: 0777
    - makedirs: True
{%- endfor %}
{%- endif %}

{%- for container_name, container_config in service_config['containers']} -%}

{%- for container_number in range(container_config['instances']) -%}
{%- set container_instance_name = "%s-%d" % (container_name, container_number) %}
{%- set container_port = container_config.get("http_internal_port", 80) %}
{%- set host_port = container_config['base_port'] + container_number %}

{%- if 'http' in container_config and 'check_url' in container_config -%}
/etc/consul/service-{{ container_name }}-{{ container_port }}.json:
  file.managed:
    - source: salt://microservices_demo/files/consul.json.j2
    - template: jinja
    - context:
        service_name: {{ service_name }}
        service_id: {{ service_name }}-{{ container_number }}
        host_port: {{ host_port }}
        check_url: {{ container_config['check_url'] }}
    - watch_in:
      - cmd: consul-reload
{%- endif %}

{{ container_instance_name }}:
  mwdocker.running:
    - image: {{ container_config['docker_image'] }}
    - stateful: {{ container_config['stateful'] }}
    - dns:
      - {{ salt['grains.get']('ip4_interfaces:eth0')[0] }}
    - domain: "consul"
    - labels:
        service: {{ service_name }}
        service_goup: {{ service_name }}-{{ container_name }}

    {% if 'http' in container_config -%}
    - tcp_ports:
      - address: 0.0.0.0
      - port: {{ container_port }}
      - host_port: {{ host_port }}

    - watch_in:
      - file: /etc/nginx/sites-available/service_{{ service_name }}.conf
      - file: /etc/nginx/sites-enabled/service_{{ service_name }}.conf
    {%- elif 'tcp_ports' in container_config %}
    - tcp_ports:
      {{ dict_to_yaml(tcp_ports, 3) }}
    {%- endif %}

    {% for arg in ["environment", "restart", "user", "command"] -%}
    {% if arg in container_config -%}
    - {{ arg }}: 
        {{ dict_to_yaml(container_config[arg], ) }}
    {%- endif %}
    {%- endfor %}

    {% if "links" in container_config -%}
    - links: 
      {% for linked_container, alias in sorted(container_config["links"].items()) -%}
      - {{ linked_container }}: {{ alias }}
      {%- endfor %}
    {%- endif -%}

    {% if "volumes_from" in container_config -%}
    - volumes_from:
      {% for volume_container in container_config["volumes_from"] -%}
      - {{ volume_container}}
      {%- endfor %}
    {%- endif -%}

    {% if "volumes" in container_config -%}
    - volumes:
      {% for dir, mount, mode in container_config["volumes"] -%}
      - "{{ source_dir }}-{{ mount }}-{{ mode }}"
      {%- endfor %}
    {%- endif -%}

    {% if "volumes_from" in container_config or "volumes" in container_config or "links" in container_config -%}
    - require:
      {% for linked_container, _ in sorted(container_config.get("links", {}).items()) -%}
      - mwdocker: "{{ service_name }}-{{ linked_container }}-0"
      {%- endfor -%}

      {% for volume_container in container_config.get("volumes_from", []) -%}
      - mwdocker: "{{ service }}-{{ volume_container }}-0"
      {%- endfor -%}

      {% for dir, _, __ in container_config.get("volumes". []) -%}
      - file: "/var/lib/services/{{ service }}/{{ dir }}"
      {%- endfor -%}

      - service: docker
    {%- endif %}
{%- endfor %}
{%- endfor %}

{% if "hostname" in service_config -%}
{{ service_config.get(hostname, service_name) }}:
  host.present:
    - ip: 127.0.0.1
{%- endif %}

/etc/consul/service-{{ service_name }}.json:
  file.absent:
    - watch_in:
      - cmd: consul-reload

{% if has_http -%}
/var/log/services/{{ service_name }}:
  file.directory:
    - makedirs: True
    - user: www-data
    - group: www-data

/etc/nginx/sites-available/service_{{ service_name }}.conf:
  file.managed:
    - source: salt://microservices_demo/files/vhost.j2
    - template: jinja2
    - context:
        service_name: {{ service_name }}
        service_config:
          {{ dict_to_yaml(service_config, 5) }}
    - require:
      - file: /var/log/services/{{ service_name }}
    - watch_in:
      - service: nginx

/etc/nginx/sites-enabled/service_{{ service_name }}.conf:
  file.symlink:
    - target: /etc/nginx/sites-available/service_{{ service_name }}.conf
    - require:
      - file: /etc/nginx/sites-available/service_{{ service_name }}.conf
    - watch_in: 
      - service: nginx
{%- endif -%}

{%- endmacro %}
