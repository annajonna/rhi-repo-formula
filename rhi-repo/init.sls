# Completely ignore non-RHEL based systems
{% if salt['grains.get']('os_family') == 'RedHat' %}
{% from "rhi-repo/map.jinja" import rhi-repo with context %}

install_pubkey_rhi-repo:
  file.managed:
    - name: /etc/pki/rpm-gpg/{{ rhi-repo.key_name }}
    - source: {{ rhi-repo.key }}
    - source_hash:  {{ rhi-repo.key_hash }}

rhi-repo_release:
  pkg.installed:
    - sources:
      - rhi-repo-release: {{ rhi-repo.rpm }}
#    - require:
#      - file: install_pubkey_rhi-repo

set_pubkey_rhi-repo:
  file.replace:
    - append_if_not_found: True
    - name: /etc/yum.repos.d/rhi.repo
    - pattern: '^\s*gpgkey=.*'
    - repl: 'gpgkey=file:///etc/pki/rpm-gpg/{{ rhi-repo.key_name }}'
    - require:
      - pkg: rhi-repo_release

set_gpg_rhi-repo:
  file.replace:
    - append_if_not_found: True
    - name: /etc/yum.repos.d/rhi.repo
    - pattern: '^\s*gpgcheck=.*'
    - repl: 'gpgcheck=1'
    - require:
      - pkg: rhi-repo_release

{%   for entry in rhi-repo.disabled %}
disable_{{ entry }}:
  file.replace:
    - name: /etc/yum.repos.d/rhi.repo
    - pattern: '\[{{ entry }}\](.*?)enabled=[01]'
    - repl: '[{{ entry }}]\1enabled=0'
    - flags: ['DOTALL']
{%   endfor %}
{%   for entry in rhi-repo.enabled %}
enable_{{ entry }}:
  file.replace:
    - name: /etc/yum.repos.d/rhi.repo
    - pattern: '\[{{ entry }}\](.*?)enabled=[01]'
    - repl: '[{{ entry }}]\1enabled=1'
    - flags: ['DOTALL']
{%   endfor %}

{%   if rhi-repo.testing %}
{%     for entry in rhi-repo.testing_disabled %}
disable_{{ entry }}:
  file.replace:
    - name: /etc/yum.repos.d/rhi-repo-testing.repo
    - pattern: '\[{{ entry }}\](.*?)enabled=[01]'
    - repl: '[{{ entry }}]\1enabled=0'
    - flags: ['DOTALL']
{%     endfor %}
{%     for entry in rhi-repo.testing_enabled %}
enable_{{ entry }}:
  file.replace:
    - name: /etc/yum.repos.d/rhi-repo-testing.repo
    - pattern: '\[{{ entry }}\](.*?)enabled=[01]'
    - repl: '[{{ entry }}]\1enabled=1'
    - flags: ['DOTALL']
{%     endfor %}
{%   endif %}

{% endif %}
