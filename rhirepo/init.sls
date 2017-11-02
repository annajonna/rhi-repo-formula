# Completely ignore non-RHEL based systems
{% if salt['grains.get']('os_family') == 'RedHat' %}
{% from "rhirepo/map.jinja" import rhirepo with context %}

install_pubkey_rhirepo:
  file.managed:
    - name: /etc/pki/rpm-gpg/{{ rhirepo.key_name }}
    - source: {{ rhirepo.key }}
    - source_hash:  {{ rhirepo.key_hash }}

rhirepo_release:
  pkg.installed:
    - sources:
      - rhirepo-release: {{ rhirepo.rpm }}
#    - require:
#      - file: install_pubkey_rhirepo

set_pubkey_rhirepo:
  file.replace:
    - append_if_not_found: True
    - name: /etc/yum.repos.d/rhi.repo
    - pattern: '^\s*gpgkey=.*'
    - repl: 'gpgkey=file:///etc/pki/rpm-gpg/{{ rhirepo.key_name }}'
    - require:
      - pkg: rhirepo_release

set_gpg_rhirepo:
  file.replace:
    - append_if_not_found: True
    - name: /etc/yum.repos.d/rhi.repo
    - pattern: '^\s*gpgcheck=.*'
    - repl: 'gpgcheck=1'
    - require:
      - pkg: rhirepo_release

{%   for entry in rhirepo.disabled %}
disable_{{ entry }}:
  file.replace:
    - name: /etc/yum.repos.d/rhi.repo
    - pattern: '\[{{ entry }}\](.*?)enabled=[01]'
    - repl: '[{{ entry }}]\1enabled=0'
    - flags: ['DOTALL']
{%   endfor %}
{%   for entry in rhirepo.enabled %}
enable_{{ entry }}:
  file.replace:
    - name: /etc/yum.repos.d/rhi.repo
    - pattern: '\[{{ entry }}\](.*?)enabled=[01]'
    - repl: '[{{ entry }}]\1enabled=1'
    - flags: ['DOTALL']
{%   endfor %}

{%   if rhirepo.testing %}
{%     for entry in rhirepo.testing_disabled %}
disable_{{ entry }}:
  file.replace:
    - name: /etc/yum.repos.d/rhirepo-testing.repo
    - pattern: '\[{{ entry }}\](.*?)enabled=[01]'
    - repl: '[{{ entry }}]\1enabled=0'
    - flags: ['DOTALL']
{%     endfor %}
{%     for entry in rhirepo.testing_enabled %}
enable_{{ entry }}:
  file.replace:
    - name: /etc/yum.repos.d/rhirepo-testing.repo
    - pattern: '\[{{ entry }}\](.*?)enabled=[01]'
    - repl: '[{{ entry }}]\1enabled=1'
    - flags: ['DOTALL']
{%     endfor %}
{%   endif %}

{% endif %}
