docker-repo:
  repo.managed:
    - name: deb https://apt.dockerproject.org/repo debian-jessie main
    - dist: debian-jessie
    - file: /etc/apt/sources.list.d/docker.list
    - gpgcheck: 1
    - key_url: https://get.docker.com/gpg

docker-engine:
  pkg.installed:
    - require:
      - repo: docker-repo

docker:
  service.running:
    - require:
      - pkg: docker-engine
