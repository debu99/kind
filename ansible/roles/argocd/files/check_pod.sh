#!/bin/bash

LABEL_KEY=$1
LABEL_VALUE=$2
NAMESPACE=${3:-default}

if [[ -z ${LABEL_KEY} ]] || [[ -z ${LABEL_VALUE} ]]; then
	echo "[ERROR] required parameters are missing. exiting..!"
	exit 9
else
	echo "[INFO] arguments: LABEL_KEY=${LABEL_KEY} LABEL_VALUE=${LABEL_VALUE} NAMESPACE=${NAMESPACE}"
fi

if [[ ! -f ~/.kube/config ]]; then
  echo "[ERROR] kube_config doesn't exist..!"
  exit 9
else
  CLIENT_CERT=`cat ~/.kube/config | grep client-certificate-data | awk -F' ' '{print $2}'`
  CLIENT_KEY=`cat ~/.kube/config | grep client-key-data | awk -F' ' '{print $2}'`
  CERT_AUTH=`cat ~/.kube/config | grep certificate-authority-data | awk -F' ' '{print $2}'`
  echo $CLIENT_CERT | base64 -d > /tmp/client.pem
  echo $CLIENT_KEY | base64 -d > /tmp/client_key.pem
  echo $CERT_AUTH | base64 -d > /tmp/ca.pem
fi

APISERVER=https://$(kubectl -n default get endpoints kubernetes -o json | jq -r '[.subsets[].addresses[].ip,.subsets[].ports[].port]|join(":")')

function checkHealth {
  LABEL=$1
  VALUE=$2
	POD_NAME=''
	snum=0
	enum=50
	failure=1
	while [[ $snum -le $enum ]]; do 
		POD_NAME=`curl -s --cert /tmp/client.pem --key /tmp/client_key.pem --cacert /tmp/ca.pem -H 'Accept: application/json' $APISERVER/api/v1/namespaces/$NAMESPACE/pods | jq -re '.items[].metadata|select(.labels."'${LABEL}'"=="'${VALUE}'")|.name'`
		if [[ $POD_NAME == '' ]]; then
			echo -n "."
			sleep 6
			((snum++))
		else
			failure=0
			break
		fi
	done
	if [[ $failure -eq 1 ]]; then
		echo "POD_NAME failure"
		exit 1
	else
		echo "POD_NAME=$POD_NAME in $NAMESPACE is starting..."
	fi

	snum=0
	enum=50
	failure=1
	while [[ $snum -le $enum ]]; do 
		POD_STATUS=`curl -s --cert /tmp/client.pem --key /tmp/client_key.pem --cacert /tmp/ca.pem -H 'Accept: application/json' $APISERVER/api/v1/namespaces/$NAMESPACE/pods/$POD_NAME | jq -re '.status.phase'`
		if [[ $POD_STATUS == 'Running' ]]; then
			failure=0
			break
		else
			echo -n "."
			sleep 6
			((snum++))
		fi
	done
	if [[ $failure -eq 1 ]]; then
		echo "POD_NAME=$POD_NAME in $NAMESPACE failure"
		exit 2
	else
		echo "POD_NAME=$POD_NAME in $NAMESPACE is running..."
	fi
}

checkHealth $LABEL_KEY $LABEL_VALUE