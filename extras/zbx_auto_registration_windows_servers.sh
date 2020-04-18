#!/usr/bin/env bash

# Criando Grupo
curl --silent --location --request POST 'http://{{ zabbix_server_ip }}:{{ zabbix_web_port }}/api_jsonrpc.php' \
--header 'Content-Type: application/json' \
--data '{
    "jsonrpc": "2.0",
    "method": "hostgroup.create",
    "params": {
        "name": "Windows servers"
    },
    "auth": "{{ zabbix_auth_token.stdout }}",
    "id": 1
}' > /tmp/zbx_hostgroup.out

ZBX_HOSTGROUP_ID=$(cat /tmp/zbx_hostgroup.out |awk -F ":" '{ print $4 }' |cut -d"\"" -f2 |xargs)

# Criando Auto Registro
curl --silent --location --request POST 'http://{{ zabbix_server_ip }}:{{ zabbix_web_port }}/api_jsonrpc.php' \
--header 'Content-Type: application/json' \
--data '{
	"jsonrpc": "2.0",
	"method": "action.create",
	"id": 1,
	"auth": "{{ zabbix_auth_token.stdout }}",
	"params": {
		"name": "Windows Servers",
		"eventsource": 2,
		"status": 0,
		"esc_period": 120,
		"def_shortdata": "{HOST.HOST}",
		"def_longdata": "Host name: {HOST.HOST}\r\nHost IP: {HOST.IP}\r\nAgent port: {HOST.PORT}",
		"filter": {
			"evaltype": 0,
			"conditions": [
				{
					"conditiontype": 24,
					"operator": 2,
					"value": "Windows Server a31261ebf34bbbfb1a85b16d9d16327eb34ff03be76b0422c39df1309d794cbc"
				}
			]
		},
		"operations": [
			{
				"operationtype": 6,
				"optemplate": [
					{
						"templateid": "10081"
					},
					{
						"templateid": "10186"
					}
				]
			},
			{
				"operationtype": 4,
				"opgroup": [
					{
						"groupid": "${ZBX_HOSTGROUP_ID}",
						"operationid": "4"
					}
				]
			}
		]
	}
}'