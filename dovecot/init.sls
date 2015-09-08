{% from "dovecot/map.jinja" import dovecot with context %}

dovecot_packages:
  pkg.installed:
    - pkgs: {{ dovecot.packages }}
    - watch_in:
      - service: dovecot_service

/etc/dovecot/{{ dovecot.config.filename }}.conf:
  file.managed:
    - contents: |
        {{ salt['pillar.get']('dovecot:config:local',{}) | indent(8) }}
    - backup: minion
    - watch_in:
      - service: dovecot_service
    - require:
      - pkg: dovecot_packages

{% for name, content in salt['pillar.get']('dovecot:config:dovecotext',{}).items() %}
/etc/dovecot/dovecot-{{ name }}.conf.ext:
  file.managed:
    - contents: |
        {{ content | indent(8) }}
    - backup: minion
    - watch_in:
      - service: dovecot_service
    - require:
      - pkg: dovecot_packages
{% endfor %}

{% for name, content in salt['pillar.get']('dovecot:config:conf',{}).items() %}
/etc/dovecot/conf.d/{{ name }}.conf:
  file.managed:
    - contents: |
        {{ content | indent(8) }}
    - backup: minion
    - watch_in:
      - service: dovecot_service
    - require:
      - pkg: dovecot_packages
{% endfor %}

{% for name, content in salt['pillar.get']('dovecot:config:confext',{}).items() %}
/etc/dovecot/conf.d/{{ name }}.conf.ext:
  file.managed:
    - contents: |
        {{ dovecot.config.confext[name] | indent(8) }}
    - backup: minion
    - watch_in:
      - service: dovecot_service
    - require:
      - pkg: dovecot_packages
{% endfor %}

{% for name, content in salt['pillar.get']('dovecot:config:ssl_certs',{}).items() %}
/etc/ssl/private/dovecot-{{ name }}.crt:
  file.managed:
    - contents: |
        {{ content | indent(8) }}
    - user: nobody
    - group: nobody
    - mode: 444
    - backup: minion
    - watch_in:
      - service: dovecot_service
    - require:
      - pkg: dovecot_packages
{% endfor %}

{% for name, content in salt['pillar.get']('dovecot:config:ssl_keys',{}).items() %}
/etc/ssl/private/dovecot-{{ name }}.key:
  file.managed:
    - contents: |
        {{ dovecot.config.ssl_keys[name] | indent(8) }}
    - user: nobody
    - group: nobody
    - mode: 400
    - backup: minion
    - watch_in:
      - service: dovecot_service
    - require:
      - pkg: dovecot_packages
{% endfor %}

dovecot_service:
  service.running:
    - name: dovecot
    - watch:
      - file: /etc/dovecot/{{ dovecot.config.filename }}.conf
      - pkg: dovecot_packages
    - require:
      - pkg: dovecot_packages

