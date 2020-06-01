include:
  - oh-my-zsh.zsh

{% set users = pillar["users"] %}
{% for username, user in users.items() %}
{% set user_home_folder = "/home/" + username %}

clone_oh_my_zsh_repo_{{ username }}:
  git.latest:
    - name: https://github.com/robbyrussell/oh-my-zsh.git
    - rev: master
    - target: "{{ user_home_folder }}/.oh-my-zsh"
    - unless: "test -d {{ user_home_folder }}/.oh-my-zsh"
    - require_in:
      - file: zshrc_{{ username }}
    - require:
      - pkg: zsh

zshrc_{{ username }}:
  file.managed:
    - name: "{{ user_home_folder }}/.zshrc"
    - source: salt://oh-my-zsh/files/.zshrc
    - user: {{ username }}
    - mode: '0644'

set_oh_my_zsh_folder_and_file_permissions_{{ username }}:
  file.directory:
    - name: "{{ user_home_folder }}/.oh-my-zsh"
    - user: {{ username }}
    - file_mode: 744
    - dir_mode: 755
    - makedirs: True
    - recurse:
      - user
      - mode
    - require:
      - git: clone_oh_my_zsh_repo_{{ username }}
    - require_in:
      - file: zshrc_{{ username }}

{% endfor %}
