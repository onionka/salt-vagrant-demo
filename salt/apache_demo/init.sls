apache2:
  pkg.installed

apache2 Service:
  service.running:
    - name: apache2
    - enable: True
    - require:
      - pkg: apache2
    - watch:
      - file: /var/www/html/{{ pillar['domain'] }}/public_html

Turn Off KeepAlive:
  file.replace:
    - name: /etc/apache2/apache2.conf
    - pattern: 'KeepAlive On'
    - repl: 'KeepAlive Off'
    - show_changes: True
    - require:
      - pkg: apache2

/etc/apache2/conf-available/tune_apache.conf:
  file.managed:
    - source: salt://apache_demo/files/conf.d/tune_apache.conf
    - require:
      - pkg: apache2

Enable tune_apache:
  apache_conf.enabled:
    - name: tune_apache
    - require:
      - pkg: apache2

/var/www/html/{{ pillar['domain'] }}:
  file.directory

/var/www/html/{{ pillar['domain'] }}/log:
  file.directory

/var/www/html/{{ pillar['domain'] }}/backups:
  file.directory

/var/www/html/{{ pillar['domain'] }}/public_html:
  file.recurse:
    - source: salt://apache_demo/files/site

000-default:
  apache_site.disabled:
    - require:
      - pkg: apache2

/etc/apache2/sites-available/{{ pillar['domain'] }}.conf:
  apache.configfile:
    - config:
      - VirtualHost:
          this: '*:80'
          ServerName:
            - {{ pillar['domain'] }}
          ServerAlias:
            - www.{{ pillar['domain'] }}
          DocumentRoot: /var/www/html/{{ pillar['domain'] }}/public_html
          ErrorLog: /var/www/html/{{ pillar['domain'] }}/log/error.log
          CustomLog: /var/www/html/{{ pillar['domain'] }}/log/access.log combined

{{ pillar['domain'] }}:
  apache_site.enabled:
    - require:
      - pkg: apache2
