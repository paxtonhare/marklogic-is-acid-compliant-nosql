#!/bin/bash

##
# Demonstrates a multi-statement transaction with a commit
#
# See http://developer.marklogic.com/blog/marklogic_is_acid_compliant_nosql
#

HOSTNAME=localhost
PORT=8000
USER=admin
PASSWORD=admin

# create the transaction and get the location
printf "Creating a new Transaction:"
TX_ID=$(curl --anyauth --user ${USER}:${PASSWORD} -X POST -d "" -i \
  -s -H "Content-type: text/plain" \
  http://${HOSTNAME}:${PORT}/v1/transactions | tr -d '\r' | sed -En 's/^Location: \/v1\/transactions\/(.*)/\1/p')
printf " ${TX_ID}\n"

echo "Inserting Doc 1"
curl --anyauth --user ${USER}:${PASSWORD} -X PUT -d '{"hello":"world"}' -i \
  -H "Content-type: application/json" \
  "http://${HOSTNAME}:${PORT}/v1/documents?uri=/hello-world.json&txid=${TX_ID}"

echo "Inserting Doc 2"
curl --anyauth --user ${USER}:${PASSWORD} -X PUT -d '{"goodbye":"world"}' -i \
  -H "Content-type: application/json" \
  "http://${HOSTNAME}:${PORT}/v1/documents?uri=/goodbye-world.json&txid=${TX_ID}"

echo ""
echo "Ask for Documents before commit"
curl --anyauth --user ${USER}:${PASSWORD} -X GET -i \
  -H "Accept: multipart/mixed; boundary=document-part-boundary" \
  "http://${HOSTNAME}:${PORT}/v1/documents?uri=/hello-world.json&uri=/goodbye-world.json"

echo ""
printf "Committing Transaction: ${TX_ID}"

curl --anyauth --user ${USER}:${PASSWORD} -X POST -d "" -i \
  -H "Content-type: text/plain" \
  "http://${HOSTNAME}:${PORT}/v1/transactions/${TX_ID}?result=commit"
if [[ $? != 0 ]] ; then
  echo "error on commit"
  exit 1
fi
printf " ...Done.\n"

echo ""
echo "Ask for Documents after commit"
curl --anyauth --user ${USER}:${PASSWORD} -X GET -i \
  -H "Accept: multipart/mixed; boundary=document-part-boundary" \
  "http://${HOSTNAME}:${PORT}/v1/documents?uri=/hello-world.json&uri=/goodbye-world.json"


# TX=$(curl --anyauth --user ${USER}:${PASSWORD} -X POST -d "" -i \
#   -s -H "Content-type: text/plain" \
#   http://${HOSTNAME}:${PORT}/v1/transactions | grep Location)

# echo ${TX}
